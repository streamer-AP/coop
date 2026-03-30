import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/bluetooth/ble_connection_manager.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/bluetooth/ble_signal_arbitrator.dart';
import '../../data/controller_repository_impl.dart' as controller_data;
import '../../domain/models/device_binding.dart' as domain;
import '../../domain/models/favorite_slot.dart' as domain;
import '../../domain/models/waveform.dart';
import '../../domain/repositories/controller_repository.dart';
import '../services/waveform_player_service.dart';
import '../services/waveform_usage_log_service.dart';
import '../../../../core/database/app_database.dart'
    hide Waveform, DeviceBinding, FavoriteSlot;

part 'controller_providers.g.dart';

@riverpod
ControllerRepository controllerRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return controller_data.ControllerRepositoryImpl(db.controllerDao, db.userDao);
}

final waveformUsageLogServiceProvider = Provider<WaveformUsageLogService>((
  ref,
) {
  return WaveformUsageLogService(
    repository: ref.watch(controllerRepositoryProvider),
    apiClient: ref.watch(apiClientProvider),
    bleConnectionManager: ref.watch(bleConnectionManagerProvider),
  );
});

@riverpod
Future<List<Waveform>> waveforms(Ref ref) {
  return ref.watch(controllerRepositoryProvider).getAllWaveforms();
}

@riverpod
Future<List<domain.FavoriteSlot>> favoriteSlots(Ref ref) {
  return ref.watch(controllerRepositoryProvider).getAllFavoriteSlots();
}

@riverpod
Future<List<domain.FavoriteSlot>> favoriteSlotsByChannel(
  Ref ref,
  WaveformChannel channel,
) {
  return ref
      .watch(controllerRepositoryProvider)
      .getFavoriteSlotsByChannel(channel);
}

@riverpod
Future<domain.DeviceBinding?> activeDeviceBinding(Ref ref) {
  return ref.watch(controllerRepositoryProvider).getActiveDeviceBinding();
}

@riverpod
Stream<BleConnectionState> connectionState(Ref ref) {
  final manager = ref.watch(bleConnectionManagerProvider);
  return manager.connectionStateStream;
}

@riverpod
WaveformPlayerService waveformPlayerService(Ref ref) {
  ref.keepAlive();

  final arbitrator = ref.watch(bleSignalArbitratorProvider);
  final service = WaveformPlayerService(arbitrator);
  ref.onDispose(service.dispose);
  return service;
}

@riverpod
class ControllerStateNotifier extends _$ControllerStateNotifier {
  @override
  ControllerUiState build() {
    ref.keepAlive();
    ref.watch(waveformPlayerServiceProvider);

    ref.listen(connectionStateProvider, (prev, next) {
      next.whenData((connState) {
        if (connState == BleConnectionState.disconnected) {
          _onDisconnected();
        }
      });
    });

    ref.listen<AsyncValue<List<domain.FavoriteSlot>>>(
      favoriteSlotsProvider,
      (_, __) => _syncDefaultSelections(),
    );
    ref.listen<AsyncValue<List<Waveform>>>(
      waveformsProvider,
      (_, __) => _syncDefaultSelections(),
    );

    Future.microtask(_syncDefaultSelections);

    return const ControllerUiState();
  }

  void _syncDefaultSelections() {
    final slots = ref.read(favoriteSlotsProvider).valueOrNull;
    final allWaveforms = ref.read(waveformsProvider).valueOrNull;
    if (slots == null || allWaveforms == null) {
      return;
    }

    final nextSwingWaveform = _resolveCurrentOrDefaultWaveform(
      channel: WaveformChannel.swing,
      currentWaveform: state.selectedSwingWaveform,
      slots: slots,
      waveforms: allWaveforms,
    );
    final nextVibrationWaveform = _resolveCurrentOrDefaultWaveform(
      channel: WaveformChannel.vibration,
      currentWaveform: state.selectedVibrationWaveform,
      slots: slots,
      waveforms: allWaveforms,
    );

    final didChange =
        nextSwingWaveform?.id != state.selectedSwingWaveform?.id ||
        nextVibrationWaveform?.id != state.selectedVibrationWaveform?.id;
    if (!didChange) {
      return;
    }

    AppLogger().debug(
      'ControllerStateNotifier: sync defaults '
      'swing=${nextSwingWaveform?.name} '
      'vibration=${nextVibrationWaveform?.name}',
    );

    state = ControllerUiState(
      selectedPage: state.selectedPage,
      lastSelectedPage: state.lastSelectedPage,
      selectedSwingWaveform: nextSwingWaveform,
      selectedVibrationWaveform: nextVibrationWaveform,
      swingIntensity: state.swingIntensity,
      vibrationIntensity: state.vibrationIntensity,
    );
    _updatePlayer();
  }

  Waveform? _resolveCurrentOrDefaultWaveform({
    required WaveformChannel channel,
    required Waveform? currentWaveform,
    required List<domain.FavoriteSlot> slots,
    required List<Waveform> waveforms,
  }) {
    if (currentWaveform != null) {
      final stillExists = slots.any(
        (slot) =>
            slot.channel == channel && slot.waveformId == currentWaveform.id,
      );
      if (stillExists && currentWaveform.name.trim().isNotEmpty) {
        return waveforms
                .where((waveform) => waveform.id == currentWaveform.id)
                .firstOrNull ??
            currentWaveform;
      }
    }

    return _findDefaultWaveform(
      channel: channel,
      slots: slots,
      waveforms: waveforms,
    );
  }

  Waveform? _findDefaultWaveform({
    required WaveformChannel channel,
    required List<domain.FavoriteSlot> slots,
    required List<Waveform> waveforms,
  }) {
    final pageZeroSlots =
        slots
            .where((slot) => slot.channel == channel && slot.page == 0)
            .toList()
          ..sort((a, b) => a.index.compareTo(b.index));
    if (pageZeroSlots.isEmpty) {
      return null;
    }

    return waveforms
        .where((waveform) => waveform.id == pageZeroSlots.first.waveformId)
        .firstOrNull;
  }

  void selectPage(int page) {
    state = state.copyWith(selectedPage: page);
  }

  void selectSwingWaveform(Waveform waveform) {
    AppLogger().debug(
      'ControllerStateNotifier: select swing waveform '
      'id=${waveform.id} name=${waveform.name}',
    );
    state = state.copyWith(
      selectedSwingWaveform: waveform,
      lastSelectedPage: state.selectedPage,
    );
    _updatePlayer();
  }

  void selectVibrationWaveform(Waveform waveform) {
    AppLogger().debug(
      'ControllerStateNotifier: select vibration waveform '
      'id=${waveform.id} name=${waveform.name}',
    );
    state = state.copyWith(
      selectedVibrationWaveform: waveform,
      lastSelectedPage: state.selectedPage,
    );
    _updatePlayer();
  }

  void setSwingIntensity(int value) {
    AppLogger().debug('ControllerStateNotifier: set swing intensity=$value');
    state = state.copyWith(swingIntensity: value);
    _updatePlayer();
  }

  void setVibrationIntensity(int value) {
    AppLogger().debug(
      'ControllerStateNotifier: set vibration intensity=$value',
    );
    state = state.copyWith(vibrationIntensity: value);
    _updatePlayer();
  }

  void resetIntensities() {
    state = state.copyWith(swingIntensity: 0, vibrationIntensity: 0);
    ref.read(waveformPlayerServiceProvider).stop();
    unawaited(
      ref
          .read(waveformUsageLogServiceProvider)
          .syncState(
            swingWaveform: state.selectedSwingWaveform,
            swingIntensity: state.swingIntensity,
            vibrationWaveform: state.selectedVibrationWaveform,
            vibrationIntensity: state.vibrationIntensity,
          ),
    );
  }

  void _updatePlayer() {
    AppLogger().debug(
      'ControllerStateNotifier: update player '
      'swingWaveform=${state.selectedSwingWaveform?.name} '
      'vibrationWaveform=${state.selectedVibrationWaveform?.name} '
      'swingIntensity=${state.swingIntensity} '
      'vibrationIntensity=${state.vibrationIntensity}',
    );
    final player = ref.read(waveformPlayerServiceProvider);
    player.update(
      swingWaveform: state.selectedSwingWaveform,
      vibrationWaveform: state.selectedVibrationWaveform,
      swingIntensity: state.swingIntensity,
      vibrationIntensity: state.vibrationIntensity,
    );
    unawaited(
      ref
          .read(waveformUsageLogServiceProvider)
          .syncState(
            swingWaveform: state.selectedSwingWaveform,
            swingIntensity: state.swingIntensity,
            vibrationWaveform: state.selectedVibrationWaveform,
            vibrationIntensity: state.vibrationIntensity,
          ),
    );
  }

  void _onDisconnected() {
    state = state.copyWith(swingIntensity: 0, vibrationIntensity: 0);
    ref.read(waveformPlayerServiceProvider).stop();
    unawaited(
      ref
          .read(waveformUsageLogServiceProvider)
          .syncState(
            swingWaveform: state.selectedSwingWaveform,
            swingIntensity: state.swingIntensity,
            vibrationWaveform: state.selectedVibrationWaveform,
            vibrationIntensity: state.vibrationIntensity,
          ),
    );
  }
}

class ControllerUiState {
  final int selectedPage;
  final int? lastSelectedPage;
  final Waveform? selectedSwingWaveform;
  final Waveform? selectedVibrationWaveform;
  final int swingIntensity;
  final int vibrationIntensity;

  const ControllerUiState({
    this.selectedPage = 0,
    this.lastSelectedPage,
    this.selectedSwingWaveform,
    this.selectedVibrationWaveform,
    this.swingIntensity = 0,
    this.vibrationIntensity = 0,
  });

  ControllerUiState copyWith({
    int? selectedPage,
    int? lastSelectedPage,
    Waveform? selectedSwingWaveform,
    Waveform? selectedVibrationWaveform,
    int? swingIntensity,
    int? vibrationIntensity,
  }) {
    return ControllerUiState(
      selectedPage: selectedPage ?? this.selectedPage,
      lastSelectedPage: lastSelectedPage ?? this.lastSelectedPage,
      selectedSwingWaveform:
          selectedSwingWaveform ?? this.selectedSwingWaveform,
      selectedVibrationWaveform:
          selectedVibrationWaveform ?? this.selectedVibrationWaveform,
      swingIntensity: swingIntensity ?? this.swingIntensity,
      vibrationIntensity: vibrationIntensity ?? this.vibrationIntensity,
    );
  }
}
