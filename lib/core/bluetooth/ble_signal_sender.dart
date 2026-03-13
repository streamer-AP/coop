import 'dart:async';
import 'ble_connection_manager.dart';
import 'ble_device_protocol.dart';
import 'models/ble_signal.dart';

/// Sends BLE signals at 200ms intervals via a timed queue.
class BleSignalSender {
  final BleConnectionManager _connectionManager;
  final BleDeviceProtocol _protocol;

  Timer? _timer;
  BleSignal? _currentSignal;

  static const sendInterval = Duration(milliseconds: 200);

  BleSignalSender(this._connectionManager, this._protocol);

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

  void _sendSignal() {
    if (_currentSignal == null) return;
    if (!_connectionManager.isConnected) return;
    // TODO: encode via _protocol.encodeSignal() + write to BLE characteristic
  }
}
