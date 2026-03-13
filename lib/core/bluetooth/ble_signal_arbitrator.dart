import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'models/ble_signal.dart';
import 'ble_connection_manager.dart';
import 'ble_device_protocol.dart';
import 'ble_signal_sender.dart';

part 'ble_signal_arbitrator.g.dart';

/// Arbitrates signal conflicts between preset, resonance, and story sources.
/// Priority: story > resonance > preset
class BleSignalArbitrator {
  final BleSignalSender _sender;

  BleSignalArbitrator(this._sender);

  SignalSource? _activeSource;

  SignalSource? get activeSource => _activeSource;

  void submitSignal(BleSignal signal) {
    if (_shouldAccept(signal.source)) {
      _activeSource = signal.source;
      _sender.updateSignal(signal);
    }
  }

  void releaseSource(SignalSource source) {
    if (_activeSource == source) {
      _activeSource = null;
      _sender.updateSignal(
        const BleSignal(swing: 0, vibration: 0, source: SignalSource.preset),
      );
    }
  }

  bool _shouldAccept(SignalSource source) {
    if (_activeSource == null) return true;
    return source.index >= _activeSource!.index;
  }
}

@Riverpod(keepAlive: true)
BleSignalArbitrator bleSignalArbitrator(Ref ref) {
  final connectionManager = ref.watch(bleConnectionManagerProvider);
  final protocol = BleDeviceProtocol();
  final sender = BleSignalSender(connectionManager, protocol);
  return BleSignalArbitrator(sender);
}
