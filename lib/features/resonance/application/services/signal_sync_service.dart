import 'dart:async';
import 'dart:convert';

import '../../../../core/bluetooth/ble_signal_arbitrator.dart';
import '../../../../core/bluetooth/models/ble_signal.dart';
import '../../../../core/logging/app_logger.dart';
import '../../domain/models/signal_timeline.dart';

/// Synchronizes signal output with audio playback position.
/// Uses 200ms timer to interpolate between keyframes and submit to BLE.
class SignalSyncService {
  final BleSignalArbitrator _arbitrator;
  final Duration Function() _getPosition;

  Timer? _syncTimer;
  SignalTimeline? _timeline;

  static const _syncInterval = Duration(milliseconds: 200);

  SignalSyncService({
    required BleSignalArbitrator arbitrator,
    required Duration Function() getPosition,
  })  : _arbitrator = arbitrator,
        _getPosition = getPosition;

  bool get isActive => _syncTimer != null;

  /// Parse a signal timeline from JSON content.
  SignalTimeline parseTimeline(String jsonContent) {
    final data = json.decode(jsonContent) as Map<String, dynamic>;
    return SignalTimeline.fromJson(data);
  }

  /// Start syncing with the given timeline.
  void start(SignalTimeline timeline) {
    _timeline = timeline;
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(_syncInterval, (_) => _tick());
    AppLogger().debug('SignalSyncService started');
  }

  /// Pause syncing and release the resonance signal source.
  void pause() {
    _syncTimer?.cancel();
    _syncTimer = null;
    _arbitrator.releaseSource(SignalSource.resonance);
  }

  /// Resume syncing.
  void resume() {
    if (_timeline == null) return;
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(_syncInterval, (_) => _tick());
  }

  /// Stop syncing completely.
  void stop() {
    _syncTimer?.cancel();
    _syncTimer = null;
    _timeline = null;
    _arbitrator.releaseSource(SignalSource.resonance);
  }

  void _tick() {
    final timeline = _timeline;
    if (timeline == null || timeline.keyframes.isEmpty) return;

    final positionMs = _getPosition().inMilliseconds;
    final (swing, vibration) = _interpolate(timeline.keyframes, positionMs);

    // Skip sending if both values are zero
    if (swing == 0 && vibration == 0) return;

    _arbitrator.submitSignal(BleSignal(
      swing: swing,
      vibration: vibration,
      source: SignalSource.resonance,
    ));
  }

  /// Binary search + linear interpolation between adjacent keyframes.
  (int swing, int vibration) _interpolate(
    List<SignalKeyframe> keyframes,
    int positionMs,
  ) {
    if (keyframes.isEmpty) return (0, 0);

    // Before first keyframe
    if (positionMs <= keyframes.first.timestampMs) {
      return (keyframes.first.swing, keyframes.first.vibration);
    }

    // After last keyframe
    if (positionMs >= keyframes.last.timestampMs) {
      return (keyframes.last.swing, keyframes.last.vibration);
    }

    // Binary search for the interval
    int low = 0;
    int high = keyframes.length - 1;

    while (low < high - 1) {
      final mid = (low + high) ~/ 2;
      if (keyframes[mid].timestampMs <= positionMs) {
        low = mid;
      } else {
        high = mid;
      }
    }

    final a = keyframes[low];
    final b = keyframes[high];
    final range = b.timestampMs - a.timestampMs;

    if (range == 0) return (a.swing, a.vibration);

    final t = (positionMs - a.timestampMs) / range;

    return (
      (a.swing + (b.swing - a.swing) * t).round(),
      (a.vibration + (b.vibration - a.vibration) * t).round(),
    );
  }

  void dispose() {
    stop();
  }
}
