import '../domain/models/waveform.dart';

class ControllerDebugWaveformPresets {
  static List<Waveform> buildForChannel(WaveformChannel channel) {
    return channel == WaveformChannel.swing
        ? buildSwingWaveforms()
        : buildVibrationWaveforms();
  }

  static List<String> orderedNamesFor(WaveformChannel channel) {
    return buildForChannel(
      channel,
    ).map((waveform) => waveform.name).toList(growable: false);
  }
  static bool isBuiltIn(Waveform data) {
    final name = data.name.trim();
    if (name.isEmpty) {
      return false;
    }
    return buildForChannel(data.channel).any((waveform) => waveform.name == name);
  }

  static List<Waveform> buildSwingWaveforms() {
    return [
      _buildDebugWaveformFromSliderValues(
        name: '羽毛轻扫',
        channel: WaveformChannel.swing,
        sliderValues: const [
          [26, 26, 28, 30, 32, 34, 36, 38],
          [40, 38, 36, 34, 32, 30, 28, 26],
          [26, 28, 30, 32, 30, 28, 26, 26],
          [26, 0, 0, 0, 0, 0, 0, 0],
        ],
      ),
      _buildDebugWaveformFromSliderValues(
        name: '深海呼吸',
        channel: WaveformChannel.swing,
        sliderValues: const [
          [26, 28, 30, 32, 34, 36, 38, 40],
          [42, 44, 46, 46, 44, 42, 40, 38],
          [36, 34, 32, 30, 28, 26, 26, 0],
        ],
      ),
      _buildDebugWaveformFromSliderValues(
        name: '午后清风',
        channel: WaveformChannel.swing,
        sliderValues: const [
          [26, 29, 28, 31, 30, 33, 32, 35],
          [34, 37, 36, 34, 32, 33, 30, 31],
          [28, 29, 26, 26, 0, 0, 0, 0],
        ],
      ),
      _buildDebugWaveformFromSliderValues(
        name: '晨露微光',
        channel: WaveformChannel.swing,
        sliderValues: const [
          [26, 26, 28, 28, 30, 30, 32, 34],
          [36, 38, 40, 42, 42, 40, 38, 36],
          [34, 32, 30, 30, 28, 28, 26, 26],
        ],
      ),
      _buildDebugWaveformFromSliderValues(
        name: '溪流潺潺',
        channel: WaveformChannel.swing,
        sliderValues: const [
          [26, 28, 30, 32, 34, 36, 38, 36],
          [38, 40, 38, 36, 34, 32, 30, 28],
          [26, 26, 26, 0, 0, 0, 0, 0],
        ],
      ),
      _buildDebugWaveformFromSliderValues(
        name: '丝绸摩挲',
        channel: WaveformChannel.swing,
        sliderValues: const [
          [26, 28, 30, 32, 34, 36, 38, 40],
          [40, 38, 36, 34, 32, 30, 28, 26],
          [26, 26, 0, 0, 0, 0, 0, 0],
        ],
      ),
      _buildDebugWaveformFromSliderValues(
        name: '深海潜流',
        channel: WaveformChannel.swing,
        sliderValues: const [
          [26, 28, 30, 32, 34, 36, 38, 40],
          [42, 40, 38, 36, 34, 32, 30, 28],
        ],
      ),
      _buildDebugWaveformFromSliderValues(
        name: '耳鬓斯磨',
        channel: WaveformChannel.swing,
        sliderValues: const [
          [26, 28, 30, 34, 38, 40, 42, 42],
          [40, 38, 34, 30, 28, 26, 26, 0],
        ],
      ),
      _buildDebugWaveformFromSliderValues(
        name: '钟摆催眠',
        channel: WaveformChannel.swing,
        sliderValues: const [
          [26, 30, 34, 38, 40, 42, 40, 38],
          [34, 30, 26, 26, 26, 26, 0, 0],
        ],
      ),
      _buildDebugWaveformFromSliderValues(
        name: '琴弦共鸣',
        channel: WaveformChannel.swing,
        sliderValues: const [
          [26, 32, 38, 42, 40, 36, 30, 28],
          [30, 36, 40, 38, 32, 0, 0, 0],
        ],
      ),
      _buildDebugWaveformFromSliderValues(
        name: '惊涛骇浪',
        channel: WaveformChannel.swing,
        sliderValues: const [
          [26, 30, 40, 50, 46, 36, 30, 40],
          [55, 46, 36, 26, 0, 0, 0, 0],
        ],
      ),
      _buildDebugWaveformFromSliderValues(
        name: '陨石坠落',
        channel: WaveformChannel.swing,
        sliderValues: const [
          [26, 30, 34, 40, 46, 52, 46, 34],
          [26, 26, 0, 0, 0, 0, 0, 0],
        ],
      ),
    ];
  }

  static List<Waveform> buildVibrationWaveforms() {
    return [
      _buildDebugWaveformFromSliderValues(
        name: '星夜呢喃',
        channel: WaveformChannel.vibration,
        sliderValues: const [
          [28, 28, 28, 30, 30, 32, 32, 32],
          [30, 30, 28, 28, 28, 28, 30, 30],
          [32, 32, 32, 30, 30, 28, 28, 28],
          [28, 0, 0, 0, 0, 0, 0, 0],
        ],
      ),
      _buildDebugWaveformFromSliderValues(
        name: '绵绵细雨',
        channel: WaveformChannel.vibration,
        sliderValues: const [
          [26, 34, 26, 38, 28, 36, 26, 40],
          [30, 34, 26, 38, 28, 36, 26, 40],
          [30, 34, 26, 38, 28, 36, 26, 34],
        ],
      ),
      _buildDebugWaveformFromSliderValues(
        name: '潮汐呼吸',
        channel: WaveformChannel.vibration,
        sliderValues: const [
          [26, 28, 30, 32, 34, 36, 38, 40],
          [42, 44, 46, 46, 44, 42, 40, 38],
          [36, 34, 32, 30, 28, 26, 26, 0],
        ],
      ),
      _buildDebugWaveformFromSliderValues(
        name: '麦浪起伏',
        channel: WaveformChannel.vibration,
        sliderValues: const [
          [26, 30, 34, 38, 34, 30, 26, 30],
          [34, 38, 34, 30, 26, 30, 34, 38],
          [34, 30, 26, 26, 0, 0, 0, 0],
        ],
      ),
      _buildDebugWaveformFromSliderValues(
        name: '心跳同频',
        channel: WaveformChannel.vibration,
        sliderValues: const [
          [26, 50, 26, 26, 44, 26, 26, 26],
          [50, 26, 26, 44, 26, 26, 26, 26],
          [26, 0, 0, 0, 0, 0, 0, 0],
        ],
      ),
      _buildDebugWaveformFromSliderValues(
        name: '指尖魔法',
        channel: WaveformChannel.vibration,
        sliderValues: const [
          [26, 26, 58, 26, 26, 58, 26, 26],
          [58, 26, 26, 58, 26, 26, 58, 26],
        ],
      ),
      _buildDebugWaveformFromSliderValues(
        name: '极光爆发',
        channel: WaveformChannel.vibration,
        sliderValues: const [
          [26, 30, 34, 38, 42, 46, 52, 58],
          [64, 70, 64, 58, 52, 46, 38, 0],
        ],
      ),
      _buildDebugWaveformFromSliderValues(
        name: '荒原疾驰',
        channel: WaveformChannel.vibration,
        sliderValues: const [
          [26, 46, 42, 50, 44, 52, 46, 50],
          [44, 52, 46, 50, 44, 26, 0, 0],
        ],
      ),
      _buildDebugWaveformFromSliderValues(
        name: '骤雨拍打',
        channel: WaveformChannel.vibration,
        sliderValues: const [
          [26, 70, 26, 58, 26, 78, 26, 50],
          [26, 74, 26, 54, 26, 0, 0, 0],
        ],
      ),
      _buildDebugWaveformFromSliderValues(
        name: '暗潮低鸣',
        channel: WaveformChannel.vibration,
        sliderValues: const [
          [26, 30, 34, 38, 40, 42, 42, 40],
          [38, 34, 30, 26, 0, 0, 0, 0],
        ],
      ),
      _buildDebugWaveformFromSliderValues(
        name: '萤火微光',
        channel: WaveformChannel.vibration,
        sliderValues: const [
          [26, 26, 26, 52, 26, 26, 46, 26],
          [26, 58, 26, 26, 42, 26, 26, 52],
          [26, 26, 26, 0, 0, 0, 0, 0],
        ],
      ),
      _buildDebugWaveformFromSliderValues(
        name: '蜻蜓点水',
        channel: WaveformChannel.vibration,
        sliderValues: const [
          [26, 78, 26, 26, 26, 72, 26, 26],
          [26, 82, 26, 0, 0, 0, 0, 0],
        ],
      ),
    ];
  }

  static Waveform _buildDebugWaveformFromSliderValues({
    required String name,
    required WaveformChannel channel,
    required List<List<int>> sliderValues,
  }) {
    final keyframes = <WaveformKeyframe>[];
    var timeMs = 1000;

    for (final sliderRow in sliderValues) {
      for (final value in sliderRow) {
        keyframes.add(WaveformKeyframe(timeMs: timeMs, value: value));
        timeMs += 1000;
      }
    }

    return _buildDebugWaveform(
      name: name,
      channel: channel,
      durationMs: keyframes.length * 1000,
      keyframes: keyframes,
    );
  }

  static Waveform _buildDebugWaveform({
    required String name,
    required WaveformChannel channel,
    required int durationMs,
    required List<WaveformKeyframe> keyframes,
  }) {
    return Waveform(
      id: 0,
      name: name,
      channel: channel,
      durationMs: durationMs,
      signalIntervalMs: 200,
      signalDelayMs: 0,
      isBuiltIn: true,
      keyframes: keyframes,
    );
  }
}
