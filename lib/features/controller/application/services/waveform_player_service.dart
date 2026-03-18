import 'dart:async';

import '../../../../core/bluetooth/ble_signal_arbitrator.dart';
import '../../../../core/bluetooth/models/ble_signal.dart';
import '../../../../core/logging/app_logger.dart';
import '../../domain/models/waveform.dart';

/// Plays a waveform by interpolating keyframes and submitting BLE signals
/// at 200ms intervals. Ported from the old Java WaveformPlayer.
class WaveformPlayerService {
  static const _tag = 'WaveformPlayerService';
  static const _tickInterval = Duration(milliseconds: 200);

  final BleSignalArbitrator _arbitrator;

  Timer? _timer;
  Waveform? _waveform;
  int _elapsedMs = 0;
  int _swingIntensity = 0;
  int _vibrationIntensity = 0;

  WaveformPlayerService(this._arbitrator);

  bool get isPlaying => _timer != null;

  Waveform? get currentWaveform => _waveform;

  int get swingIntensity => _swingIntensity;

  int get vibrationIntensity => _vibrationIntensity;

  void play(Waveform waveform) {
    _waveform = waveform;
    _elapsedMs = 0;
    _ensureTimer();
    AppLogger().debug('$_tag: playing ${waveform.name}');
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _waveform = null;
    _elapsedMs = 0;
    _swingIntensity = 0;
    _vibrationIntensity = 0;
    _arbitrator.releaseSource(SignalSource.preset);
    AppLogger().debug('$_tag: stopped');
  }

  void setSwingIntensity(int value) {
    _swingIntensity = value.clamp(0, 100);
    if (_swingIntensity == 0 && _vibrationIntensity == 0) {
      _timer?.cancel();
      _timer = null;
      _arbitrator.releaseSource(SignalSource.preset);
    } else {
      _ensureTimer();
    }
  }

  void setVibrationIntensity(int value) {
    _vibrationIntensity = value.clamp(0, 100);
    if (_swingIntensity == 0 && _vibrationIntensity == 0) {
      _timer?.cancel();
      _timer = null;
      _arbitrator.releaseSource(SignalSource.preset);
    } else {
      _ensureTimer();
    }
  }

  void _ensureTimer() {
    if (_waveform == null) return;
    if (_swingIntensity == 0 && _vibrationIntensity == 0) return;
    _timer ??= Timer.periodic(_tickInterval, (_) => _tick());
  }

  void _tick() {
    final waveform = _waveform;
    if (waveform == null) return;
    if (_swingIntensity == 0 && _vibrationIntensity == 0) return;

    final totalMs = waveform.durationMs;
    final positionMs = totalMs > 0 ? _elapsedMs % totalMs : 0;

    final (baseSwing, baseVibration) = _interpolate(
      waveform.keyframes,
      positionMs,
    );

    final swing = (baseSwing * _swingIntensity / 100).round().clamp(0, 100);
    final vibration =
        (baseVibration * _vibrationIntensity / 100).round().clamp(0, 100);

    _arbitrator.submitSignal(
      BleSignal(swing: swing, vibration: vibration, source: SignalSource.preset),
    );

    _elapsedMs += _tickInterval.inMilliseconds;
  }

  /// 在关键帧之间线性插值
  (int swing, int vibration) _interpolate(
    List<WaveformKeyframe> keyframes,
    int positionMs,
  ) {
    if (keyframes.isEmpty) return (50, 50);
    if (keyframes.length == 1) {
      return (keyframes.first.swingValue, keyframes.first.vibrationValue);
    }

    if (positionMs <= keyframes.first.timeMs) {
      return (keyframes.first.swingValue, keyframes.first.vibrationValue);
    }
    if (positionMs >= keyframes.last.timeMs) {
      return (keyframes.last.swingValue, keyframes.last.vibrationValue);
    }

    for (var i = 0; i < keyframes.length - 1; i++) {
      final a = keyframes[i];
      final b = keyframes[i + 1];

      if (positionMs >= a.timeMs && positionMs <= b.timeMs) {
        final range = b.timeMs - a.timeMs;
        if (range == 0) return (a.swingValue, a.vibrationValue);

        final t = (positionMs - a.timeMs) / range;
        return (
          (a.swingValue + (b.swingValue - a.swingValue) * t).round(),
          (a.vibrationValue + (b.vibrationValue - a.vibrationValue) * t)
              .round(),
        );
      }
    }

    return (keyframes.last.swingValue, keyframes.last.vibrationValue);
  }

  void dispose() {
    stop();
  }
}
