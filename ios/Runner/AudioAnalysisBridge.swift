import AVFoundation
import Flutter
import Foundation

@objcMembers
final class AudioAnalysisBridge: NSObject {
  static let shared = AudioAnalysisBridge()

  private let channelName = "com.omao/audio_analysis"
  private var channel: FlutterMethodChannel?
  private static let chunkMs = 200

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
    case "analyzeAudio":
      analyzeAudio(call.arguments, result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func analyzeAudio(_ arguments: Any?, result: @escaping FlutterResult) {
    guard
      let payload = arguments as? [String: Any],
      let audioFilePath = payload["audioFilePath"] as? String
    else {
      result(
        FlutterError(code: "invalid_args", message: "audioFilePath is required", details: nil))
      return
    }

    DispatchQueue.global(qos: .userInitiated).async {
      do {
        let json = try Self.performAnalysis(audioFilePath: audioFilePath)
        DispatchQueue.main.async { result(json) }
      } catch {
        DispatchQueue.main.async {
          result(
            FlutterError(
              code: "analysis_failed", message: error.localizedDescription, details: nil))
        }
      }
    }
  }

  private static func performAnalysis(audioFilePath: String) throws -> String {
    let url = URL(fileURLWithPath: audioFilePath)
    let asset = AVURLAsset(url: url)

    guard let track = asset.tracks(withMediaType: .audio).first else {
      throw NSError(
        domain: "AudioAnalysis", code: 1,
        userInfo: [NSLocalizedDescriptionKey: "No audio track found"])
    }

    let outputSettings: [String: Any] = [
      AVFormatIDKey: kAudioFormatLinearPCM,
      AVLinearPCMBitDepthKey: 16,
      AVLinearPCMIsFloatKey: false,
      AVLinearPCMIsBigEndianKey: false,
      AVLinearPCMIsNonInterleaved: false,
      AVNumberOfChannelsKey: 1,
      AVSampleRateKey: 44100,
    ]

    let reader = try AVAssetReader(asset: asset)
    let output = AVAssetReaderTrackOutput(track: track, outputSettings: outputSettings)
    output.alwaysCopiesSampleData = false
    reader.add(output)
    reader.startReading()

    let sampleRate = 44100
    let samplesPerChunk = sampleRate * chunkMs / 1000
    let dsp = AudioEnergyAnalyzer(sampleRate: sampleRate)

    var keyframes: [[String: Int]] = [["timestampMs": 0, "swing": 0, "vibration": 0]]
    var timestampMs = 0
    var accumulatedSamples = [Float]()

    while reader.status == .reading {
      guard let sampleBuffer = output.copyNextSampleBuffer() else { break }
      guard let blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer) else {
        CMSampleBufferInvalidate(sampleBuffer)
        continue
      }

      var length = 0
      var dataPointer: UnsafeMutablePointer<Int8>?
      CMBlockBufferGetDataPointer(blockBuffer, atOffset: 0, lengthAtOffsetOut: nil,
                                  totalLengthOut: &length, dataPointerOut: &dataPointer)

      if let ptr = dataPointer {
        let shortCount = length / 2
        ptr.withMemoryRebound(to: Int16.self, capacity: shortCount) { shorts in
          for i in 0..<shortCount {
            accumulatedSamples.append(Float(shorts[i]) / 32768.0)
          }
        }
      }
      CMSampleBufferInvalidate(sampleBuffer)

      while accumulatedSamples.count >= samplesPerChunk {
        let chunk = Array(accumulatedSamples.prefix(samplesPerChunk))
        accumulatedSamples.removeFirst(samplesPerChunk)
        let r = dsp.process(mono: chunk)
        timestampMs += chunkMs
        keyframes.append(["timestampMs": timestampMs, "swing": r.swing, "vibration": r.vibration])
      }
    }

    // Process remaining
    if accumulatedSamples.count > 1 {
      let r = dsp.process(mono: accumulatedSamples)
      timestampMs += chunkMs
      keyframes.append(["timestampMs": timestampMs, "swing": r.swing, "vibration": r.vibration])
    }

    keyframes.append(["timestampMs": timestampMs + 200, "swing": 0, "vibration": 0])

    let root: [String: Any] = ["keyframes": keyframes]
    let data = try JSONSerialization.data(withJSONObject: root)
    return String(data: data, encoding: .utf8) ?? "{\"keyframes\":[]}"
  }

  // MARK: - DSP Classes

  private final class OnePoleFilter {
    enum FilterType { case lowpass, highpass }
    private let type: FilterType
    private let alpha: Float
    private var y: Float = 0
    private var xPrev: Float = 0

    init(type: FilterType, cutoffHz: Float, sampleRate: Int) {
      self.type = type
      let rc = 1.0 / (6.2831855 * max(0.001, cutoffHz))
      let dt = 1.0 / Float(max(1, sampleRate))
      alpha = type == .lowpass ? dt / (rc + dt) : rc / (rc + dt)
    }

    func reset() { y = 0; xPrev = 0 }

    func process(_ x: Float) -> Float {
      if type == .lowpass {
        y += alpha * (x - y)
        return y
      }
      y = alpha * (y + x - xPrev)
      xPrev = x
      return y
    }
  }

  private final class BandEnergy {
    private let hp: OnePoleFilter
    private let lp: OnePoleFilter

    init(hpHz: Float, lpHz: Float, sampleRate: Int) {
      hp = OnePoleFilter(type: .highpass, cutoffHz: hpHz, sampleRate: sampleRate)
      lp = OnePoleFilter(type: .lowpass, cutoffHz: lpHz, sampleRate: sampleRate)
    }

    func reset() { hp.reset(); lp.reset() }

    func computeRms(_ mono: [Float]) -> Float {
      var sumSq: Float = 0
      for s in mono { let y = lp.process(hp.process(s)); sumSq += y * y }
      return sqrt(sumSq / Float(max(1, mono.count)))
    }
  }

  private final class BeatDetector {
    private let low: OnePoleFilter
    private var mean: Float = 0
    private var meanSq: Float = 0
    private var lastBeatTime: Float = -10
    private let k: Float = 1.5
    private let muAlpha: Float = 0.02
    private let minInterval: Float = 0.12

    init(sampleRate: Int) {
      low = OnePoleFilter(type: .lowpass, cutoffHz: 150, sampleRate: sampleRate)
    }

    func reset() { low.reset(); mean = 0; meanSq = 0; lastBeatTime = -10 }

    func processChunk(_ mono: [Float], timeNow: Float) -> Bool {
      var sumSq: Float = 0
      for s in mono { let lp = low.process(s); sumSq += lp * lp }
      let rms = sqrt(sumSq / Float(max(1, mono.count)))
      mean = (1 - muAlpha) * mean + muAlpha * rms
      meanSq = (1 - muAlpha) * meanSq + muAlpha * rms * rms
      let std = sqrt(max(0, meanSq - mean * mean))
      let thr = mean + k * std
      let isBeat = rms > thr && timeNow - lastBeatTime > minInterval
      if isBeat { lastBeatTime = timeNow }
      return isBeat
    }
  }

  private final class RhythmProcessor {
    private let band: BandEnergy
    init(sampleRate: Int) { band = BandEnergy(hpHz: 100, lpHz: 6000, sampleRate: sampleRate) }
    func reset() { band.reset() }
    func compute(_ mono: [Float]) -> Float { band.computeRms(mono) }
  }

  private final class VocalProcessor {
    private let band: BandEnergy
    private var env: Float = 0
    private let alpha: Float = 0.15
    init(sampleRate: Int) { band = BandEnergy(hpHz: 200, lpHz: 5000, sampleRate: sampleRate) }
    func reset() { band.reset(); env = 0 }
    func compute(_ mono: [Float]) -> Float {
      let rms = band.computeRms(mono)
      env += alpha * (rms - env)
      return env
    }
  }

  private struct AnalysisResult {
    let swing: Int
    let vibration: Int
  }

  private final class AudioEnergyAnalyzer {
    private let sampleRate: Int
    private let beat: BeatDetector
    private let rhythm: RhythmProcessor
    private let vocal: VocalProcessor
    private var smoothed: Float = 0
    private var agcPeak: Float = 0.1
    private let smooth: Float = 0.2
    private let agcDecay: Float = 0.9975
    private let beatBoost: Float = 1.2
    private let rhythmWeight: Float = 0.5
    private let vocalWeight: Float = 0.5
    private var timeSeconds: Double = 0

    init(sampleRate: Int) {
      self.sampleRate = sampleRate
      beat = BeatDetector(sampleRate: sampleRate)
      rhythm = RhythmProcessor(sampleRate: sampleRate)
      vocal = VocalProcessor(sampleRate: sampleRate)
    }

    func process(mono: [Float]) -> AnalysisResult {
      timeSeconds += Double(mono.count) / Double(sampleRate)
      _ = beat.processChunk(mono, timeNow: Float(timeSeconds))

      let rhythmVal = rhythm.compute(mono)
      let vocalVal = vocal.compute(mono)

      let combined = beatBoost * (rhythmVal * rhythmWeight + vocalVal * vocalWeight)
      smoothed += smooth * (combined - smoothed)
      agcPeak = max(smoothed, agcPeak * agcDecay)

      let normalized = smoothed / max(0.001, agcPeak)
      let energy = min(1, max(0, normalized)) * 100
      let rhythmNorm = min(1, max(0, rhythmVal / max(0.001, agcPeak))) * 100

      let swing = clampFloor(Int(rhythmNorm.rounded()))
      let vibration = clampFloor(Int(energy.rounded()))
      return AnalysisResult(swing: swing, vibration: vibration)
    }

    private func clampFloor(_ v: Int) -> Int {
      let clamped = min(100, max(0, v))
      return (clamped >= 1 && clamped <= 14) ? 15 : clamped
    }
  }
}
