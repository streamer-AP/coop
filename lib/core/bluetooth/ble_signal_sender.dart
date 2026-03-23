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
    AppLogger().debug('$_tag: stopped');
  }

  void updateSignal(BleSignal signal) {
    _currentSignal = signal;
    if (_timer == null) {
      start();
    }
  }

  Future<void> _sendSignal() async {
    if (_currentSignal == null) return;
    if (!_connectionManager.isConnected) return;

    final payload = _protocol.encodeSignal(_currentSignal!);
    _lastPayload = payload;
    await _connectionManager.writePayload(payload);
  }
}
