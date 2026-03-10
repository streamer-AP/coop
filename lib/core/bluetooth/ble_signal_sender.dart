import 'dart:async';
import 'models/ble_signal.dart';

/// Sends BLE signals at 200ms intervals via a timed queue.
class BleSignalSender {
  Timer? _timer;
  BleSignal? _currentSignal;

  static const sendInterval = Duration(milliseconds: 200);

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
    // TODO: send via BLE characteristic
  }
}
