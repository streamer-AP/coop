import 'dart:async';

import '../../../../core/bluetooth/ble_signal_arbitrator.dart';
import '../../../../core/bluetooth/models/ble_signal.dart';
import '../../../../core/logging/app_logger.dart';
import '../../domain/models/waveform.dart';

class WaveformPlayerService {
  static const _tag = 'WaveformPlayerService';
  static const _defaultTickInterval = Duration(milliseconds: 200);

  final BleSignalArbitrator _arbitrator;

  Timer? _timer;
  Waveform? _swingWaveform;
  Waveform? _vibrationWaveform;
  int _elapsedMs = 0;
  int _swingIntensity = 0;
  int _vibrationIntensity = 0;

  WaveformPlayerService(this._arbitrator);

  bool get isPlaying => _timer != null;

  Waveform? get swingWaveform => _swingWaveform;

  Waveform? get vibrationWaveform => _vibrationWaveform;

  void update({
    Waveform? swingWaveform,
    Waveform? vibrationWaveform,
    required int swingIntensity,
    required int vibrationIntensity,
  }) {
    _swingWaveform = swingWaveform;
    _vibrationWaveform = vibrationWaveform;
    _swingIntensity = swingIntensity.clamp(0, 100);
    _vibrationIntensity = vibrationIntensity.clamp(0, 100);

    AppLogger().debug(
      '$_tag: update '
      'swingWaveform=${_swingWaveform?.name} '
      'vibrationWaveform=${_vibrationWaveform?.name} '
      'swingIntensity=$_swingIntensity '
      'vibrationIntensity=$_vibrationIntensity',
    );

    if (_swingIntensity == 0 && _vibrationIntensity == 0) {
      _timer?.cancel();
      _timer = null;
      _arbitrator.releaseSource(SignalSource.preset);
    } else {
      _ensureTimer();
    }
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _swingWaveform = null;
    _vibrationWaveform = null;
    _elapsedMs = 0;
    _swingIntensity = 0;
    _vibrationIntensity = 0;
    _arbitrator.releaseSource(SignalSource.preset);
    AppLogger().debug('$_tag: stopped');
  }

  void _ensureTimer() {
    if (_swingIntensity == 0 && _vibrationIntensity == 0) return;
    _timer ??= Timer.periodic(_defaultTickInterval, (_) => _tick());
  }

  void _tick() {
    if (_swingIntensity == 0 && _vibrationIntensity == 0) return;

    final swing = _computeChannelValue(_swingWaveform, _swingIntensity);
    final vibration = _computeChannelValue(
      _vibrationWaveform,
      _vibrationIntensity,
    );

    // AppLogger().debug(
    //   '$_tag: tick elapsedMs=$_elapsedMs send=[$swing, $vibration]',
    // );

    _arbitrator.submitSignal(
      BleSignal(
        swing: swing,
        vibration: vibration,
        source: SignalSource.preset,
      ),
    );

    _elapsedMs += _defaultTickInterval.inMilliseconds;
  }

  int _computeChannelValue(Waveform? waveform, int intensity) {
    if (waveform == null || intensity == 0) return 0;

    final totalMs = waveform.durationMs;
    final positionMs = totalMs > 0 ? _elapsedMs % totalMs : 0;
    final baseValue = _interpolate(waveform.keyframes, positionMs);

    return (baseValue * intensity / 100).round().clamp(0, 100);
  }

  int _interpolate(List<WaveformKeyframe> keyframes, int positionMs) {
    if (keyframes.isEmpty) return 50;
    if (keyframes.length == 1) return keyframes.first.value;

    if (positionMs <= keyframes.first.timeMs) return keyframes.first.value;
    if (positionMs >= keyframes.last.timeMs) return keyframes.last.value;

    for (var i = 0; i < keyframes.length - 1; i++) {
      final a = keyframes[i];
      final b = keyframes[i + 1];

      if (positionMs >= a.timeMs && positionMs <= b.timeMs) {
        final range = b.timeMs - a.timeMs;
        if (range == 0) return a.value;

        final t = (positionMs - a.timeMs) / range;
        return (a.value + (b.value - a.value) * t).round();
      }
    }

    return keyframes.last.value;
  }

  void dispose() {
    stop();
  }
}
