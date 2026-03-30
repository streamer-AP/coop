import 'dart:async';

import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../logging/app_logger.dart';
import 'ble_connection_manager.dart';
import 'ble_device_protocol.dart';
import 'ble_signal_sender.dart';
import 'models/ble_signal.dart';

part 'ble_signal_arbitrator.g.dart';

/// Arbitrates signal conflicts between preset, resonance, and story sources.
/// Priority: story > resonance > preset
class BleSignalArbitrator {
  static const _tag = 'BleSignalArbitrator';

  final BleSignalSender _sender;
  final BleConnectionManager _connectionManager;

  StreamSubscription<BleConnectionState>? _connectionSub;
  SignalSource? _activeSource;

  BleSignalArbitrator(this._sender, this._connectionManager) {
    _connectionSub = _connectionManager.connectionStateStream.listen((state) {
      if (state == BleConnectionState.disconnected) {
        _onDisconnected();
      } else if (state == BleConnectionState.connected) {
        _sender.start();
      }
    });
  }

  SignalSource? get activeSource => _activeSource;

  BleSignalSender get sender => _sender;

  void submitSignal(BleSignal signal) {
    if (_shouldAccept(signal.source)) {
      _activeSource = signal.source;
      _sender.updateSignal(signal);
      // AppLogger().debug(
      //   '$_tag: accepted ${signal.source.name} '
      //   'swing=${signal.swing} vibration=${signal.vibration}',
      // );
    }
  }

  void releaseSource(SignalSource source) {
    if (_activeSource == source) {
      AppLogger().debug('$_tag: released ${source.name}');
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

  void _onDisconnected() {
    _activeSource = null;
    _sender.stop();
  }

  void dispose() {
    _connectionSub?.cancel();
    _sender.stop();
  }
}

@Riverpod(keepAlive: true)
BleSignalArbitrator bleSignalArbitrator(Ref ref) {
  final connectionManager = ref.watch(bleConnectionManagerProvider);
  final protocol = BleDeviceProtocol();
  final sender = BleSignalSender(connectionManager, protocol);
  final arbitrator = BleSignalArbitrator(sender, connectionManager);
  ref.onDispose(arbitrator.dispose);
  return arbitrator;
}
