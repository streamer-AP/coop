import AVFoundation
import Flutter
import Foundation

@objcMembers
final class MediaExtractionBridge: NSObject {
  static let shared = MediaExtractionBridge()

  private let channelName = "com.omao/media_extraction"
  private var channel: FlutterMethodChannel?

  private override init() {}

  func attach(to messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(name: channelName, binaryMessenger: messenger)
    channel?.setMethodCallHandler { [weak self] call, result in
      self?.handle(call, result: result)
    }
  }

  func detach() {
    channel?.setMethodCallHandler(nil)
    channel = nil
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "extractAudio":
      extractAudio(call.arguments, result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func extractAudio(_ arguments: Any?, result: @escaping FlutterResult) {
    guard
      let payload = arguments as? [String: Any],
      let inputPath = payload["inputPath"] as? String,
      let outputPath = payload["outputPath"] as? String
    else {
      result(
        FlutterError(
          code: "invalid_arguments",
          message: "Missing inputPath or outputPath",
          details: nil
        )
      )
      return
    }

    let inputURL = URL(fileURLWithPath: inputPath)
    let outputURL = URL(fileURLWithPath: outputPath)
    let asset = AVURLAsset(url: inputURL)

    guard !asset.tracks(withMediaType: .audio).isEmpty else {
      result(
        FlutterError(
          code: "missing_audio_track",
          message: "Video does not contain an audio track",
          details: nil
        )
      )
      return
    }

    guard
      let exportSession = AVAssetExportSession(
        asset: asset,
        presetName: AVAssetExportPresetAppleM4A
      )
    else {
      result(
        FlutterError(
          code: "export_session_unavailable",
          message: "Unable to create audio export session",
          details: nil
        )
      )
      return
    }

    try? FileManager.default.removeItem(at: outputURL)
    try? FileManager.default.createDirectory(
      at: outputURL.deletingLastPathComponent(),
      withIntermediateDirectories: true,
      attributes: nil
    )

    exportSession.outputURL = outputURL
    exportSession.outputFileType = .m4a
    exportSession.shouldOptimizeForNetworkUse = false

    exportSession.exportAsynchronously {
      DispatchQueue.main.async {
        switch exportSession.status {
        case .completed:
          result(outputPath)
        case .failed:
          result(
            FlutterError(
              code: "extract_audio_failed",
              message: exportSession.error?.localizedDescription ?? "Unknown export error",
              details: nil
            )
          )
        case .cancelled:
          result(
            FlutterError(
              code: "extract_audio_cancelled",
              message: "Audio extraction was cancelled",
              details: nil
            )
          )
        default:
          result(
            FlutterError(
              code: "extract_audio_failed",
              message: "Audio extraction did not finish successfully",
              details: nil
            )
          )
        }
      }
    }
  }
}
