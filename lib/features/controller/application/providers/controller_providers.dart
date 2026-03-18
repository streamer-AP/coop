import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/bluetooth/ble_connection_manager.dart';
import '../../../../core/bluetooth/ble_signal_arbitrator.dart';
import '../../data/controller_repository_impl.dart';
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
  return ControllerRepositoryImpl(db.controllerDao, db.userDao);
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

/// Session-scoped controller state (not persisted).
@riverpod
class ControllerStateNotifier extends _$ControllerStateNotifier {
  @override
  ControllerUiState build() {
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
      if (state.selectedWaveform != null) return;
      final slotsAsync = ref.read(favoriteSlotsProvider);
      final waveformsAsync = ref.read(waveformsProvider);
      slotsAsync.whenData((slots) {
        waveformsAsync.whenData((allWaveforms) {
          if (allWaveforms.isEmpty) return;
          final page0Slots = slots.where((s) => s.page == 0).toList()
            ..sort((a, b) => a.index.compareTo(b.index));
          if (page0Slots.isNotEmpty) {
            final firstWaveform = allWaveforms
                .where((w) => w.id == page0Slots.first.waveformId)
                .firstOrNull;
            if (firstWaveform != null && state.selectedWaveform == null) {
              state = state.copyWith(selectedWaveform: firstWaveform);
            }
          } else if (allWaveforms.isNotEmpty) {
            state = state.copyWith(selectedWaveform: allWaveforms.first);
          }
        });
      });
    });
  }

  void selectPage(int page) {
    state = state.copyWith(selectedPage: page);
  }

  void selectWaveform(Waveform waveform) {
    state = state.copyWith(
      selectedWaveform: waveform,
      lastSelectedPage: state.selectedPage,
    );

    final player = ref.read(waveformPlayerServiceProvider);
    player.play(waveform);

    if (state.swingIntensity > 0 || state.vibrationIntensity > 0) {
      player.setSwingIntensity(state.swingIntensity);
      player.setVibrationIntensity(state.vibrationIntensity);
    }
  }

  void setSwingIntensity(int value) {
    state = state.copyWith(swingIntensity: value);
    final player = ref.read(waveformPlayerServiceProvider);
    if (state.selectedWaveform != null && player.currentWaveform == null) {
      player.play(state.selectedWaveform!);
    }
    player.setSwingIntensity(value);
  }

  void setVibrationIntensity(int value) {
    state = state.copyWith(vibrationIntensity: value);
    final player = ref.read(waveformPlayerServiceProvider);
    if (state.selectedWaveform != null && player.currentWaveform == null) {
      player.play(state.selectedWaveform!);
    }
    player.setVibrationIntensity(value);
  }

  void _onDisconnected() {
    state = state.copyWith(swingIntensity: 0, vibrationIntensity: 0);
    ref.read(waveformPlayerServiceProvider).stop();
  }
}

class ControllerUiState {
  final int selectedPage;
  final int? lastSelectedPage;
  final Waveform? selectedWaveform;
  final int swingIntensity;
  final int vibrationIntensity;

  const ControllerUiState({
    this.selectedPage = 0,
    this.lastSelectedPage,
    this.selectedWaveform,
    this.swingIntensity = 0,
    this.vibrationIntensity = 0,
  });

  ControllerUiState copyWith({
    int? selectedPage,
    int? lastSelectedPage,
    Waveform? selectedWaveform,
    int? swingIntensity,
    int? vibrationIntensity,
  }) {
    return ControllerUiState(
      selectedPage: selectedPage ?? this.selectedPage,
      lastSelectedPage: lastSelectedPage ?? this.lastSelectedPage,
      selectedWaveform: selectedWaveform ?? this.selectedWaveform,
      swingIntensity: swingIntensity ?? this.swingIntensity,
      vibrationIntensity: vibrationIntensity ?? this.vibrationIntensity,
    );
  }
}
