import Flutter
import Foundation

/// Native channel skeleton for Flutter <-> native <-> Unity relay.
///
/// Current behavior is intentionally safe/no-op:
/// - page switching and Unity lifecycle are tracked in memory only
/// - outbound Flutter -> Unity messages are cached and optionally forwarded to
///   a future Unity plugin callback
/// - inbound Unity -> Flutter messages can already be dispatched through
///   `UnityChannelBridge.dispatchUnityMessage(_:)`
@objcMembers
final class UnityChannelBridge: NSObject {
  static let shared = UnityChannelBridge()

  private let nativeChannelName = "com.omao/native"
  private let unityChannelName = "com.omao/unity"

  private var nativeChannel: FlutterMethodChannel?
  private var unityChannel: FlutterMethodChannel?

  private(set) var isUnityInitialized = false
  private(set) var isUnityVisible = false
  private(set) var lastFlutterMessageJSON: String?

  private var flutterToUnityRelay: ((String) -> Void)?

  private override init() {}

  func attach(to messenger: FlutterBinaryMessenger) {
    nativeChannel = FlutterMethodChannel(name: nativeChannelName, binaryMessenger: messenger)
    unityChannel = FlutterMethodChannel(name: unityChannelName, binaryMessenger: messenger)

    nativeChannel?.setMethodCallHandler { [weak self] call, result in
      self?.handleNativeMethodCall(call, result: result)
    }
    unityChannel?.setMethodCallHandler { [weak self] call, result in
      self?.handleUnityMethodCall(call, result: result)
    }
  }

  func detach() {
    nativeChannel?.setMethodCallHandler(nil)
    unityChannel?.setMethodCallHandler(nil)
    nativeChannel = nil
    unityChannel = nil
  }

  /// Future Unity plugin hook:
  /// register a relay that receives JSON messages from Flutter.
  func setFlutterToUnityRelay(_ relay: ((String) -> Void)?) {
    flutterToUnityRelay = relay
  }

  /// Future Unity plugin entrypoint:
  /// forward JSON messages from Unity/native into Flutter.
  @objc static func dispatchUnityMessage(_ json: String) {
    shared.dispatchUnityMessage(json)
  }

  private func dispatchUnityMessage(_ json: String) {
    DispatchQueue.main.async { [weak self] in
      self?.unityChannel?.invokeMethod("onUnityMessage", arguments: json)
    }
  }

  private func handleNativeMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "switchToUnity":
      isUnityVisible = true
      result(nil)
    case "switchToFlutter":
      isUnityVisible = false
      result(nil)
    case "initUnityEngine":
      isUnityInitialized = true
      result(nil)
    case "destroyUnityEngine":
      isUnityInitialized = false
      isUnityVisible = false
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func handleUnityMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "sendToUnity":
      guard let json = makeJSONString(from: call.arguments) else {
        result(
          FlutterError(
            code: "invalid_arguments",
            message: "sendToUnity expects a JSON string or JSON-compatible map/list",
            details: nil
          )
        )
        return
      }

      lastFlutterMessageJSON = json
      flutterToUnityRelay?(json)
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func makeJSONString(from arguments: Any?) -> String? {
    switch arguments {
    case let string as String:
      return string
    case let dictionary as [String: Any]:
      return serializeJSONObject(dictionary)
    case let array as [Any]:
      return serializeJSONObject(array)
    case let dictionary as [AnyHashable: Any]:
      var normalized: [String: Any] = [:]
      dictionary.forEach { key, value in
        normalized[String(describing: key)] = value
      }
      return serializeJSONObject(normalized)
    default:
      return nil
    }
  }

  private func serializeJSONObject(_ object: Any) -> String? {
    guard JSONSerialization.isValidJSONObject(object) else {
      return nil
    }

    do {
      let data = try JSONSerialization.data(withJSONObject: object)
      return String(data: data, encoding: .utf8)
    } catch {
      return nil
    }
  }
}
