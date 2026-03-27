import Flutter
import Foundation
import SwiftUI

#if canImport(Translation)
import Translation
#endif

@objcMembers
final class TextTranslationBridge: NSObject {
  static let shared = TextTranslationBridge()

  private let channelName = "com.omao/translation"
  private var channel: FlutterMethodChannel?
  private weak var rootViewController: UIViewController?

  #if canImport(Translation)
  @available(iOS 18.0, *)
  private let coordinator = TranslationCoordinator()

  @available(iOS 18.0, *)
  private var hostingController: UIHostingController<HiddenTranslationView>?
  #endif

  private override init() {}

  func attach(to controller: FlutterViewController) {
    rootViewController = controller
    channel = FlutterMethodChannel(name: channelName, binaryMessenger: controller.binaryMessenger)
    channel?.setMethodCallHandler { [weak self] call, result in
      self?.handle(call, result: result)
    }

    #if canImport(Translation)
    if #available(iOS 18.0, *) {
      ensureTranslationHostAttached(to: controller)
    }
    #endif
  }

  func detach() {
    channel?.setMethodCallHandler(nil)
    channel = nil

    #if canImport(Translation)
    if #available(iOS 18.0, *) {
      hostingController?.willMove(toParent: nil)
      hostingController?.view.removeFromSuperview()
      hostingController?.removeFromParent()
      hostingController = nil
    }
    #endif

    rootViewController = nil
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "translateBatch":
      translateBatch(call.arguments, result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func translateBatch(_ arguments: Any?, result: @escaping FlutterResult) {
    guard
      let payload = arguments as? [String: Any],
      let texts = payload["texts"] as? [String],
      let sourceLanguage = payload["sourceLanguage"] as? String,
      let targetLanguage = payload["targetLanguage"] as? String
    else {
      result(
        FlutterError(
          code: "invalid_arguments",
          message: "Missing texts or targetLanguage",
          details: nil
        )
      )
      return
    }

    if texts.isEmpty {
      result([])
      return
    }

    #if canImport(Translation)
    guard #available(iOS 18.0, *) else {
      result(
        FlutterError(
          code: "unavailable",
          message: "当前 iOS 系统版本不支持本地字幕翻译，需要 iOS 18 或更高版本",
          details: nil
        )
      )
      return
    }

    guard let controller = rootViewController else {
      result(
        FlutterError(
          code: "missing_view_controller",
          message: "无法获取翻译宿主视图",
          details: nil
        )
      )
      return
    }

    ensureTranslationHostAttached(to: controller)
    coordinator.submit(
      request: TranslationRequest(
        texts: texts,
        sourceLanguage: normalizeAppleLanguageIdentifier(sourceLanguage),
        targetLanguage: normalizeAppleLanguageIdentifier(targetLanguage)
      ),
      result: result
    )
    #else
    result(
      FlutterError(
        code: "unavailable",
        message: "当前构建环境不支持 Apple Translation framework",
        details: nil
      )
    )
    #endif
  }

  private func normalizeAppleLanguageIdentifier(_ value: String) -> String {
    if value.lowercased().starts(with: "zh") {
      return "zh-Hans"
    }
    if value.lowercased().starts(with: "ja") {
      return "ja"
    }
    return value
  }

  #if canImport(Translation)
  @available(iOS 18.0, *)
  private func ensureTranslationHostAttached(to controller: UIViewController) {
    if hostingController != nil {
      return
    }

    let host = UIHostingController(rootView: HiddenTranslationView(coordinator: coordinator))
    host.view.backgroundColor = .clear
    host.view.isUserInteractionEnabled = false
    host.view.translatesAutoresizingMaskIntoConstraints = false
    host.view.alpha = 0.01

    controller.addChild(host)
    controller.view.addSubview(host.view)
    NSLayoutConstraint.activate([
      host.view.widthAnchor.constraint(equalToConstant: 1),
      host.view.heightAnchor.constraint(equalToConstant: 1),
      host.view.topAnchor.constraint(equalTo: controller.view.topAnchor),
      host.view.leadingAnchor.constraint(equalTo: controller.view.leadingAnchor),
    ])
    host.didMove(toParent: controller)
    hostingController = host
  }
  #endif
}

#if canImport(Translation)
@available(iOS 18.0, *)
private struct TranslationRequest {
  let id = UUID()
  let texts: [String]
  let sourceLanguage: String
  let targetLanguage: String
}

@available(iOS 18.0, *)
private final class TranslationCoordinator: ObservableObject {
  @Published var activeRequest: TranslationRequest?
  @Published var requestToken = UUID()

  private var pendingResult: FlutterResult?

  func submit(request: TranslationRequest, result: @escaping FlutterResult) {
    guard pendingResult == nil else {
      result(
        FlutterError(
          code: "translation_busy",
          message: "字幕翻译处理中，请稍后重试",
          details: nil
        )
      )
      return
    }

    pendingResult = result
    activeRequest = request
    requestToken = request.id
  }

  func complete(requestID: UUID, translations: [String]) {
    guard activeRequest?.id == requestID else { return }
    let result = pendingResult
    pendingResult = nil
    activeRequest = nil
    result?(translations)
  }

  func fail(requestID: UUID, error: Error) {
    guard activeRequest?.id == requestID else { return }
    let result = pendingResult
    pendingResult = nil
    activeRequest = nil
    result?(
      FlutterError(
        code: "translate_failed",
        message: error.localizedDescription,
        details: nil
      )
    )
  }
}

@available(iOS 18.0, *)
private struct HiddenTranslationView: View {
  @ObservedObject var coordinator: TranslationCoordinator
  @State private var configuration: TranslationSession.Configuration?

  var body: some View {
    Color.clear
      .frame(width: 1, height: 1)
      .task(id: coordinator.requestToken) {
        guard let request = coordinator.activeRequest else { return }
        configuration = TranslationSession.Configuration(
          source: Locale.Language(identifier: request.sourceLanguage),
          target: Locale.Language(identifier: request.targetLanguage)
        )
      }
      .translationTask(configuration) { session in
        guard let request = coordinator.activeRequest else { return }

        do {
          try await session.prepareTranslation()
          let requests = request.texts.enumerated().map { index, text in
            TranslationSession.Request(
              sourceText: text,
              clientIdentifier: String(index)
            )
          }
          let responses = try await session.translations(from: requests)
          let translatedByIndex = Dictionary(
            uniqueKeysWithValues: responses.map { response in
              (
                Int(response.clientIdentifier) ?? 0,
                response.targetText
              )
            }
          )
          let translations = request.texts.indices.map { index in
            translatedByIndex[index] ?? ""
          }

          coordinator.complete(requestID: request.id, translations: translations)
        } catch {
          coordinator.fail(requestID: request.id, error: error)
        }
      }
  }
}
#endif
