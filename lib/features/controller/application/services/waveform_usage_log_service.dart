import 'dart:async';

import 'package:intl/intl.dart';

import '../../../../core/bluetooth/ble_connection_manager.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/models/usage_log.dart';
import '../../domain/models/waveform.dart';
import '../../domain/repositories/controller_repository.dart';

class WaveformUsageLogService {
  WaveformUsageLogService({
    required ControllerRepository repository,
    required ApiClient apiClient,
    required BleConnectionManager bleConnectionManager,
  }) : _repository = repository,
       _apiClient = apiClient,
       _bleConnectionManager = bleConnectionManager;

  static final DateFormat _timestampFormatter = DateFormat(
    'yyyy-MM-dd HH:mm:ss',
  );

  final ControllerRepository _repository;
  final ApiClient _apiClient;
  final BleConnectionManager _bleConnectionManager;

  Future<void> _operationChain = Future<void>.value();
  _UsageLogTracker? _swingTracker;
  _UsageLogTracker? _vibrationTracker;

  Future<void> syncState({
    required Waveform? swingWaveform,
    required int swingIntensity,
    required Waveform? vibrationWaveform,
    required int vibrationIntensity,
  }) {
    return _enqueue(() async {
      final now = DateTime.now();
      await _syncChannel(
        signalMode: 'swing',
        waveform: swingWaveform,
        intensity: swingIntensity,
        now: now,
      );
      await _syncChannel(
        signalMode: 'vibration',
        waveform: vibrationWaveform,
        intensity: vibrationIntensity,
        now: now,
      );
    });
  }

  Future<void> flushPendingLogs() {
    return _enqueue(_flushPendingLogsInternal);
  }

  Future<void> _syncChannel({
    required String signalMode,
    required Waveform? waveform,
    required int intensity,
    required DateTime now,
  }) async {
    final tracker = _trackerFor(signalMode);
    final snapshot = _buildSnapshot(
      signalMode: signalMode,
      waveform: waveform,
      intensity: intensity,
    );

    if (tracker != null && (snapshot == null || !tracker.matches(snapshot))) {
      await _finalizeTracker(tracker, endedAt: now);
      _setTracker(signalMode, null);
    }

    if (snapshot != null && _trackerFor(signalMode) == null) {
      _setTracker(
        signalMode,
        _UsageLogTracker(
          signalMode: snapshot.signalMode,
          waveformId: snapshot.waveformId,
          intensityLevel: snapshot.intensityLevel,
          startedAt: now,
        ),
      );
    }
  }

  Future<void> _finalizeTracker(
    _UsageLogTracker tracker, {
    required DateTime endedAt,
  }) async {
    final durationMs = endedAt.difference(tracker.startedAt).inMilliseconds;
    if (durationMs <= 0) {
      return;
    }

    final deviceContext = await _resolveDeviceContext();
    final log = UsageLog(
      id: 0,
      startTime: tracker.startedAt,
      signalMode: tracker.signalMode,
      waveformId: tracker.waveformId,
      intensityLevel: tracker.intensityLevel,
      durationMs: durationMs,
      deviceModel: deviceContext.deviceModel,
      deviceSerial: deviceContext.deviceSerial,
    );

    await _uploadOrStore(log);
  }

  Future<void> _uploadOrStore(UsageLog log) async {
    try {
      await _uploadSingle(log);
      AppLogger().debug(
        'WaveformUsageLogService: uploaded ${log.signalMode} '
        'waveform=${log.waveformId} gear=${log.intensityLevel} '
        'durationMs=${log.durationMs}',
      );
    } catch (error, stackTrace) {
      AppLogger().warning(
        'WaveformUsageLogService: upload failed, saving locally',
      );
      AppLogger().error(
        'WaveformUsageLogService: upload single log failed',
        error: error,
        stackTrace: stackTrace,
      );
      await _repository.insertUsageLog(log);
    }
  }

  Future<void> _uploadSingle(UsageLog log) async {
    final response = await _apiClient.post(
      ApiEndpoints.waveformUsageLogs,
      data: _buildPayload(log),
    );
    _ensureSuccess(response, fallbackMessage: '上传波形日志失败');
  }

  Future<void> _flushPendingLogsInternal() async {
    final logs = await _repository.getUnsynced();
    if (logs.isEmpty) {
      return;
    }

    final response = await _apiClient.post(
      ApiEndpoints.waveformUsageLogsBatch,
      data: {'logs': logs.map(_buildPayload).toList()},
    );
    _ensureSuccess(response, fallbackMessage: '批量上传波形日志失败');

    final ids = logs.map((log) => log.id).whereType<int>().toList();
    await _repository.deleteUsageLogs(ids);
    AppLogger().debug(
      'WaveformUsageLogService: flushed ${ids.length} local usage logs',
    );
  }

  Map<String, dynamic> _buildPayload(UsageLog log) {
    final payload = <String, dynamic>{
      'operationTimestamp': _timestampFormatter.format(log.startTime),
      'durationSeconds': (log.durationMs / 1000).ceil(),
      'vibrationMode': _mapSignalMode(log.signalMode),
      'waveformId': log.waveformId,
      'gearLevel': log.intensityLevel,
    };

    if ((log.deviceModel ?? '').trim().isNotEmpty) {
      payload['deviceModel'] = log.deviceModel;
    }
    if ((log.deviceSerial ?? '').trim().isNotEmpty) {
      payload['deviceSn'] = log.deviceSerial;
    }
    return payload;
  }

  _UsageLogSnapshot? _buildSnapshot({
    required String signalMode,
    required Waveform? waveform,
    required int intensity,
  }) {
    final waveformName = waveform?.name.trim() ?? '';
    final gearLevel = _mapGearLevel(intensity);
    if (waveformName.isEmpty || gearLevel <= 0) {
      return null;
    }

    return _UsageLogSnapshot(
      signalMode: signalMode,
      waveformId: waveformName,
      intensityLevel: gearLevel,
    );
  }

  int _mapGearLevel(int intensity) {
    if (intensity <= 0) {
      return 0;
    }
    if (intensity <= 33) {
      return 1;
    }
    if (intensity <= 66) {
      return 2;
    }
    return 3;
  }

  String _mapSignalMode(String signalMode) {
    switch (signalMode) {
      case 'swing':
        return '摇摆模式';
      case 'vibration':
        return '震动模式';
      default:
        return signalMode;
    }
  }

  _UsageLogTracker? _trackerFor(String signalMode) {
    return signalMode == 'swing' ? _swingTracker : _vibrationTracker;
  }

  void _setTracker(String signalMode, _UsageLogTracker? tracker) {
    if (signalMode == 'swing') {
      _swingTracker = tracker;
      return;
    }
    _vibrationTracker = tracker;
  }

  Future<_DeviceContext> _resolveDeviceContext() async {
    final connectedDevice = _bleConnectionManager.connectedDevice;
    final activeBinding = await _repository.getActiveDeviceBinding();
    return _DeviceContext(
      deviceModel:
          connectedDevice?.name.trim().isNotEmpty == true
              ? connectedDevice?.name
              : activeBinding?.deviceName,
      deviceSerial:
          connectedDevice?.id.trim().isNotEmpty == true
              ? connectedDevice?.id
              : activeBinding?.deviceId,
    );
  }

  void _ensureSuccess(
    Map<String, dynamic> response, {
    required String fallbackMessage,
  }) {
    final code = response['code'] as int?;
    if (code == null || code == 0 || code == 200) {
      return;
    }

    final message =
        response['message'] as String? ??
        response['msg'] as String? ??
        fallbackMessage;
    throw Exception(message);
  }

  Future<void> _enqueue(Future<void> Function() action) {
    _operationChain = _operationChain.then((_) => action()).catchError((
      Object error,
      StackTrace stackTrace,
    ) {
      AppLogger().error(
        'WaveformUsageLogService: queued operation failed',
        error: error,
        stackTrace: stackTrace,
      );
    });
    return _operationChain;
  }
}

class _UsageLogSnapshot {
  const _UsageLogSnapshot({
    required this.signalMode,
    required this.waveformId,
    required this.intensityLevel,
  });

  final String signalMode;
  final String waveformId;
  final int intensityLevel;
}

class _UsageLogTracker {
  const _UsageLogTracker({
    required this.signalMode,
    required this.waveformId,
    required this.intensityLevel,
    required this.startedAt,
  });

  final String signalMode;
  final String waveformId;
  final int intensityLevel;
  final DateTime startedAt;

  bool matches(_UsageLogSnapshot snapshot) {
    return signalMode == snapshot.signalMode &&
        waveformId == snapshot.waveformId &&
        intensityLevel == snapshot.intensityLevel;
  }
}

class _DeviceContext {
  const _DeviceContext({this.deviceModel, this.deviceSerial});

  final String? deviceModel;
  final String? deviceSerial;
}
