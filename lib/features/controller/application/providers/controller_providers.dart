import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/bluetooth/ble_connection_manager.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/bluetooth/ble_signal_arbitrator.dart';
import '../../data/controller_repository_impl.dart' as controller_data;
import '../../domain/models/device_binding.dart' as domain;
import '../../domain/models/favorite_slot.dart' as domain;
import '../../domain/models/waveform.dart';
import '../../domain/repositories/controller_repository.dart';
import '../services/waveform_player_service.dart';
import '../../../../core/database/app_database.dart'
    hide Waveform, DeviceBinding, FavoriteSlot;

part 'controller_providers.g.dart';

@riverpod
ControllerRepository controllerRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return controller_data.ControllerRepositoryImpl(db.controllerDao, db.userDao);
}

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
  String channel,
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
  final arbitrator = ref.watch(bleSignalArbitratorProvider);
  final service = WaveformPlayerService(arbitrator);
  ref.onDispose(service.dispose);
  return service;
}

@riverpod
class ControllerStateNotifier extends _$ControllerStateNotifier {
  @override
  ControllerUiState build() {
    ref.watch(waveformPlayerServiceProvider);

    ref.listen(connectionStateProvider, (prev, next) {
      next.whenData((connState) {
        if (connState == BleConnectionState.disconnected) {
          _onDisconnected();
        }
      });
    });

    _autoSelectDefault();

    return const ControllerUiState();
  }

  void _autoSelectDefault() {
    Future.microtask(() {
      if (state.selectedSwingWaveform != null) return;
      final slotsAsync = ref.read(favoriteSlotsProvider);
      final waveformsAsync = ref.read(waveformsProvider);
      slotsAsync.whenData((slots) {
        waveformsAsync.whenData((allWaveforms) {
          if (allWaveforms.isEmpty) return;

          final swingSlots =
              slots.where((s) => s.channel == 'swing' && s.page == 0).toList()
                ..sort((a, b) => a.index.compareTo(b.index));
          if (swingSlots.isNotEmpty) {
            final firstWaveform =
                allWaveforms
                    .where((w) => w.id == swingSlots.first.waveformId)
                    .firstOrNull;
            if (firstWaveform != null && state.selectedSwingWaveform == null) {
              state = state.copyWith(selectedSwingWaveform: firstWaveform);
            }
          }

          final vibSlots =
              slots
                  .where((s) => s.channel == 'vibration' && s.page == 0)
                  .toList()
                ..sort((a, b) => a.index.compareTo(b.index));
          if (vibSlots.isNotEmpty) {
            final firstWaveform =
                allWaveforms
                    .where((w) => w.id == vibSlots.first.waveformId)
                    .firstOrNull;
            if (firstWaveform != null &&
                state.selectedVibrationWaveform == null) {
              state = state.copyWith(selectedVibrationWaveform: firstWaveform);
            }
          }
        });
      });
    });
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
  }

  void _onDisconnected() {
    state = state.copyWith(swingIntensity: 0, vibrationIntensity: 0);
    ref.read(waveformPlayerServiceProvider).stop();
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
