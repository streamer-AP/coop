import 'dart:async';
import 'dart:typed_data';

import '../logging/app_logger.dart';
import 'ble_connection_manager.dart';
import 'ble_device_protocol.dart';
import 'models/ble_signal.dart';

/// Sends BLE signals at 200ms intervals via a timed queue.
class BleSignalSender {
  static const _tag = 'BleSignalSender';

  final BleConnectionManager _connectionManager;
  final BleDeviceProtocol _protocol;

  Timer? _timer;
  BleSignal? _currentSignal;
  Uint8List? _lastPayload;
  bool _stopAfterCurrentSend = false;
  bool _hasLoggedDisconnectedSkip = false;

  static const sendInterval = Duration(milliseconds: 200);

  BleSignalSender(this._connectionManager, this._protocol);

  bool get isRunning => _timer != null;

  Uint8List? get lastPayload => _lastPayload;

  BleSignal? get currentSignal => _currentSignal;

  void start() {
    if (_timer != null) return;
    _timer = Timer.periodic(sendInterval, (_) => _sendSignal());
    AppLogger().debug('$_tag: started');
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _currentSignal = null;
    _lastPayload = null;
    _hasLoggedDisconnectedSkip = false;
    AppLogger().debug('$_tag: stopped');
  }

  void updateSignal(BleSignal signal) {
    _currentSignal = signal;
    _stopAfterCurrentSend = _isIdleSignal(signal);
    _hasLoggedDisconnectedSkip = false;
    if (_timer == null) {
      start();
    }
  }

  Future<void> _sendSignal() async {
    if (_currentSignal == null) return;

    final signal = _currentSignal!;
    if (!_connectionManager.isConnected) {
      if (_isIdleSignal(signal)) {
        AppLogger().debug(
          '$_tag: idle signal skipped because device not connected, stopping sender',
        );
        stop();
        return;
      }

      if (!_hasLoggedDisconnectedSkip) {
        _hasLoggedDisconnectedSkip = true;
        AppLogger().debug('$_tag: skip send, device not connected');
      }
      return;
    }

    _hasLoggedDisconnectedSkip = false;
    final payload = _protocol.encodeSignal(signal);
    _lastPayload = payload;
    // AppLogger().debug(
    //   '$_tag: sending signal '
    //   'swing=${signal.swing} vibration=${signal.vibration} '
    //   'durationMs=${signal.durationMs} delayMs=${signal.delayMs} '
    //   'payload=${payload.toList()}',
    // );
    await _connectionManager.writePayload(payload);

    if (_stopAfterCurrentSend && _isIdleSignal(signal)) {
      AppLogger().debug('$_tag: idle signal sent once, stopping sender');
      stop();
    }
  }

  bool _isIdleSignal(BleSignal signal) {
    return signal.swing == 0 && signal.vibration == 0 && !signal.usesTimedMode;
  }
}
