import AVFoundation
import Flutter
import Foundation

@objcMembers
final class AudioMetadataBridge: NSObject {
  static let shared = AudioMetadataBridge()

  private let channelName = "com.omao/audio_metadata"
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
    case "extractEmbeddedMetadata":
      extractEmbeddedMetadata(call.arguments, result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func extractEmbeddedMetadata(_ arguments: Any?, result: @escaping FlutterResult) {
    guard
      let payload = arguments as? [String: Any],
      let inputPath = payload["inputPath"] as? String,
      !inputPath.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    else {
      result(
        FlutterError(
          code: "invalid_arguments",
          message: "Missing inputPath",
          details: nil
        )
      )
      return
    }

    DispatchQueue.global(qos: .userInitiated).async {
      let asset = AVURLAsset(url: URL(fileURLWithPath: inputPath))
      let metadata = self.resolveMetadata(from: asset)

      DispatchQueue.main.async {
        result(metadata)
      }
    }
  }

  private func resolveMetadata(from asset: AVURLAsset) -> [String: String] {
    var payload: [String: String] = [:]

    if let title = firstStringValue(
      from: AVMetadataItem.metadataItems(
        from: asset.commonMetadata,
        withKey: AVMetadataKey.commonKeyTitle,
        keySpace: .common
      )
    ) {
      payload["title"] = title
    }

    if let artist = firstStringValue(
      from: AVMetadataItem.metadataItems(
        from: asset.commonMetadata,
        withKey: AVMetadataKey.commonKeyArtist,
        keySpace: .common
      )
    ) {
      payload["artist"] = artist
    }

    if let album = firstStringValue(
      from: AVMetadataItem.metadataItems(
        from: asset.commonMetadata,
        withKey: AVMetadataKey.commonKeyAlbumName,
        keySpace: .common
      )
    ) {
      payload["album"] = album
    }

    if payload["artist"] == nil || payload["album"] == nil || payload["title"] == nil {
      for format in asset.availableMetadataFormats {
        let items = asset.metadata(forFormat: format)
        if payload["title"] == nil,
          let title = firstMatchingString(in: items, keyCandidates: ["title"])
        {
          payload["title"] = title
        }
        if payload["artist"] == nil,
          let artist = firstMatchingString(in: items, keyCandidates: ["artist", "albumArtist", "author"])
        {
          payload["artist"] = artist
        }
        if payload["album"] == nil,
          let album = firstMatchingString(in: items, keyCandidates: ["albumName", "album"])
        {
          payload["album"] = album
        }
      }
    }

    return payload
  }

  private func firstStringValue(from items: [AVMetadataItem]) -> String? {
    for item in items {
      if let value = normalizedString(from: item) {
        return value
      }
    }
    return nil
  }

  private func firstMatchingString(
    in items: [AVMetadataItem],
    keyCandidates: [String]
  ) -> String? {
    let keySet = Set(keyCandidates)
    for item in items {
      let rawKey = item.commonKey?.rawValue ?? item.identifier?.rawValue ?? "\(String(describing: item.key))"
      let normalizedKey = rawKey.lowercased()
      if keySet.contains(where: { normalizedKey.contains($0.lowercased()) }),
        let value = normalizedString(from: item)
      {
        return value
      }
    }
    return nil
  }

  private func normalizedString(from item: AVMetadataItem) -> String? {
    if let stringValue = item.stringValue?.trimmingCharacters(in: .whitespacesAndNewlines),
      !stringValue.isEmpty
    {
      return stringValue
    }

    if let numberValue = item.numberValue {
      return "\(numberValue)"
    }

    if let value = item.value as? String {
      let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
      if !trimmed.isEmpty {
        return trimmed
      }
    }

    return nil
  }
}
