import AVFoundation
import Flutter
import Foundation

@objcMembers
final class AudioArtworkBridge: NSObject {
  static let shared = AudioArtworkBridge()

  private let channelName = "com.omao/audio_artwork"
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
    case "extractEmbeddedArtwork":
      extractEmbeddedArtwork(call.arguments, result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func extractEmbeddedArtwork(_ arguments: Any?, result: @escaping FlutterResult) {
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

    DispatchQueue.global(qos: .userInitiated).async {
      let inputURL = URL(fileURLWithPath: inputPath)
      let asset = AVURLAsset(url: inputURL)

      guard let artworkData = self.resolveArtworkData(from: asset) else {
        DispatchQueue.main.async {
          result(nil)
        }
        return
      }

      do {
        let actualOutputPath = self.buildOutputPath(
          suggestedOutputPath: outputPath,
          artworkData: artworkData
        )
        let outputURL = URL(fileURLWithPath: actualOutputPath)

        try FileManager.default.createDirectory(
          at: outputURL.deletingLastPathComponent(),
          withIntermediateDirectories: true,
          attributes: nil
        )
        if FileManager.default.fileExists(atPath: actualOutputPath) {
          try FileManager.default.removeItem(at: outputURL)
        }
        try artworkData.write(to: outputURL, options: .atomic)

        DispatchQueue.main.async {
          result(actualOutputPath)
        }
      } catch {
        DispatchQueue.main.async {
          result(
            FlutterError(
              code: "extract_artwork_failed",
              message: error.localizedDescription,
              details: nil
            )
          )
        }
      }
    }
  }

  private func resolveArtworkData(from asset: AVURLAsset) -> Data? {
    let commonArtwork = AVMetadataItem.metadataItems(
      from: asset.commonMetadata,
      withKey: AVMetadataKey.commonKeyArtwork,
      keySpace: .common
    )

    for item in commonArtwork {
      if let data = extractData(from: item) {
        return data
      }
    }

    for format in asset.availableMetadataFormats {
      for item in asset.metadata(forFormat: format) {
        if let data = extractData(from: item) {
          return data
        }
      }
    }

    return nil
  }

  private func extractData(from item: AVMetadataItem) -> Data? {
    if let data = item.dataValue, !data.isEmpty {
      return data
    }

    if let data = item.value as? Data, !data.isEmpty {
      return data
    }

    if
      let dictionary = item.value as? NSDictionary,
      let data = dictionary["data"] as? Data,
      !data.isEmpty
    {
      return data
    }

    return nil
  }

  private func buildOutputPath(suggestedOutputPath: String, artworkData: Data) -> String {
    let suggestedURL = URL(fileURLWithPath: suggestedOutputPath)
    let directoryURL = suggestedURL.deletingLastPathComponent()
    let baseName = suggestedURL.deletingPathExtension().lastPathComponent
    let ext = detectArtworkExtension(from: artworkData)

    var candidateURL = directoryURL.appendingPathComponent("\(baseName).\(ext)")
    var counter = 1
    while FileManager.default.fileExists(atPath: candidateURL.path) {
      candidateURL = directoryURL.appendingPathComponent("\(baseName)(\(counter)).\(ext)")
      counter += 1
    }

    return candidateURL.path
  }

  private func detectArtworkExtension(from data: Data) -> String {
    let bytes = [UInt8](data.prefix(16))

    if bytes.count >= 3,
      bytes[0] == 0xFF,
      bytes[1] == 0xD8,
      bytes[2] == 0xFF
    {
      return "jpg"
    }

    if bytes.count >= 8,
      bytes[0] == 0x89,
      bytes[1] == 0x50,
      bytes[2] == 0x4E,
      bytes[3] == 0x47
    {
      return "png"
    }

    if bytes.count >= 6 {
      let header = String(bytes: bytes.prefix(6), encoding: .ascii)
      if header == "GIF87a" || header == "GIF89a" {
        return "gif"
      }
    }

    if bytes.count >= 12 {
      let riff = String(bytes: bytes.prefix(4), encoding: .ascii)
      let webp = String(bytes: bytes[8..<12], encoding: .ascii)
      if riff == "RIFF" && webp == "WEBP" {
        return "webp"
      }
    }

    if bytes.count >= 2, bytes[0] == 0x42, bytes[1] == 0x4D {
      return "bmp"
    }

    return "jpg"
  }
}
