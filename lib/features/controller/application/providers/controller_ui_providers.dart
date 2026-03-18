import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum DeviceConnectionStatus { disconnected, connecting, connected }

enum ControllerMotorType { swing, vibration }

enum StrengthLevel {
  off('关'),
  weak('弱'),
  medium('中'),
  strong('强');

  const StrengthLevel(this.label);

  final String label;
}

@immutable
class MotorControlState {
  const MotorControlState({
    this.selectedPageIndex = 0,
    this.selectedItemIndex = 0,
    this.strength = StrengthLevel.off,
  });

  final int selectedPageIndex;
  final int selectedItemIndex;
  final StrengthLevel strength;

  MotorControlState copyWith({
    int? selectedPageIndex,
    int? selectedItemIndex,
    StrengthLevel? strength,
  }) {
    return MotorControlState(
      selectedPageIndex: selectedPageIndex ?? this.selectedPageIndex,
      selectedItemIndex: selectedItemIndex ?? this.selectedItemIndex,
      strength: strength ?? this.strength,
    );
  }
}

@immutable
class ControllerUiState {
  const ControllerUiState({
    this.deviceName = 'Omao-001',
    this.batteryLevel = 57,
    this.connectionStatus = DeviceConnectionStatus.disconnected,
    this.swing = const MotorControlState(
      selectedPageIndex: 0,
      selectedItemIndex: 0,
      strength: StrengthLevel.weak,
    ),
    this.vibration = const MotorControlState(
      selectedPageIndex: 0,
      selectedItemIndex: 0,
      strength: StrengthLevel.off,
    ),
  });

  final String deviceName;
  final int batteryLevel;
  final DeviceConnectionStatus connectionStatus;
  final MotorControlState swing;
  final MotorControlState vibration;

  ControllerUiState copyWith({
    String? deviceName,
    int? batteryLevel,
    DeviceConnectionStatus? connectionStatus,
    MotorControlState? swing,
    MotorControlState? vibration,
  }) {
    return ControllerUiState(
      deviceName: deviceName ?? this.deviceName,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      swing: swing ?? this.swing,
      vibration: vibration ?? this.vibration,
    );
  }
}

final controllerUiProvider =
    NotifierProvider<ControllerUiNotifier, ControllerUiState>(
      ControllerUiNotifier.new,
    );

class ControllerUiNotifier extends Notifier<ControllerUiState> {
  @override
  ControllerUiState build() {
    return const ControllerUiState();
  }

  Future<void> toggleConnection() async {
    switch (state.connectionStatus) {
      case DeviceConnectionStatus.disconnected:
        state = state.copyWith(
          connectionStatus: DeviceConnectionStatus.connecting,
        );
        await Future<void>.delayed(const Duration(milliseconds: 1200));
        if (state.connectionStatus == DeviceConnectionStatus.connecting) {
          state = state.copyWith(
            connectionStatus: DeviceConnectionStatus.connected,
          );
        }
        return;
      case DeviceConnectionStatus.connecting:
        return;
      case DeviceConnectionStatus.connected:
        state = state.copyWith(
          connectionStatus: DeviceConnectionStatus.disconnected,
        );
        return;
    }
  }

  void updateDeviceName(String name) {
    final nextName = name.trim();
    if (nextName.isEmpty) {
      return;
    }
    state = state.copyWith(deviceName: nextName);
  }

  void selectWaveform(
    ControllerMotorType type, {
    required int pageIndex,
    required int itemIndex,
  }) {
    final nextMotorState = _readMotor(
      type,
    ).copyWith(selectedPageIndex: pageIndex, selectedItemIndex: itemIndex);
    _writeMotor(type, nextMotorState);
  }

  void setStrength(ControllerMotorType type, StrengthLevel strength) {
    final nextMotorState = _readMotor(type).copyWith(strength: strength);
    _writeMotor(type, nextMotorState);
  }

  MotorControlState _readMotor(ControllerMotorType type) {
    return switch (type) {
      ControllerMotorType.swing => state.swing,
      ControllerMotorType.vibration => state.vibration,
    };
  }

  void _writeMotor(ControllerMotorType type, MotorControlState nextState) {
    state = switch (type) {
      ControllerMotorType.swing => state.copyWith(swing: nextState),
      ControllerMotorType.vibration => state.copyWith(vibration: nextState),
    };
  }
}
