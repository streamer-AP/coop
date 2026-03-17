import 'dart:async';
import 'dart:typed_data';

import 'ble_connection_manager.dart';
import 'ble_device_protocol.dart';
import 'models/ble_signal.dart';

/// Sends BLE signals at 200ms intervals via a timed queue.
class BleSignalSender {
  final BleConnectionManager _connectionManager;
  final BleDeviceProtocol _protocol;

  Timer? _timer;
  BleSignal? _currentSignal;
  Uint8List? _lastPayload;

  static const sendInterval = Duration(milliseconds: 200);

  BleSignalSender(this._connectionManager, this._protocol);

  Uint8List? get lastPayload => _lastPayload;

  void start() {
    _timer = Timer.periodic(sendInterval, (_) => _sendSignal());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _currentSignal = null;
  }

  void updateSignal(BleSignal signal) {
    _currentSignal = signal;
  }

  Future<void> _sendSignal() async {
    if (_currentSignal == null) return;
    if (!_connectionManager.isConnected) return;
    final payload = _protocol.encodeSignal(_currentSignal!);
    _lastPayload = payload;
    await _connectionManager.writePayload(payload);
  }
}
