import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart'
    hide Waveform, WaveformKeyframe, DeviceBinding, FavoriteSlot, UsageLog;
import '../../../core/database/daos/controller_dao.dart';
import '../../../core/database/daos/user_dao.dart';
import '../domain/models/device_binding.dart';
import '../domain/models/favorite_slot.dart';
import '../domain/models/usage_log.dart';
import '../domain/models/waveform.dart';
import '../domain/repositories/controller_repository.dart';

class ControllerRepositoryImpl implements ControllerRepository {
  final ControllerDao _dao;
  final UserDao _userDao;
  Future<void>? _ensureDebugDataFuture;

  ControllerRepositoryImpl(this._dao, this._userDao);

  // --- 波形 CRUD ---

  @override
  Future<List<Waveform>> getAllWaveforms() async {
    await _ensureLocalDebugWaveformData();
    final rows = await _dao.getAllWaveforms();
    return rows.map(_toWaveformDomain).toList();
  }

  @override
  Future<List<Waveform>> getWaveformsByChannel(String channel) async {
    await _ensureLocalDebugWaveformData();
    final rows = await _dao.getWaveformsByChannel(channel);
    return rows.map(_toWaveformDomain).toList();
  }

  @override
  Future<Waveform?> getWaveformById(int id) async {
    await _ensureLocalDebugWaveformData();
    final row = await _dao.getWaveformById(id);
    return row != null ? _toWaveformDomain(row) : null;
  }

  @override
  Future<int> saveWaveform(Waveform waveform) async {
    if (waveform.id == 0) {
      final waveformId = await _dao.insertWaveform(
        WaveformsCompanion.insert(
          name: waveform.name,
          channel: waveform.channel,
          durationMs: Value(waveform.durationMs),
          signalIntervalMs: Value(waveform.signalIntervalMs),
          signalDelayMs: Value(waveform.signalDelayMs),
          isBuiltIn: Value(waveform.isBuiltIn),
        ),
      );
      if (waveform.keyframes.isNotEmpty) {
        await _dao.insertKeyframes(
          waveform.keyframes
              .map(
                (kf) => WaveformKeyframesCompanion.insert(
                  waveformId: waveformId,
                  timeMs: kf.timeMs,
                  value: kf.value,
                ),
              )
              .toList(),
        );
      }
      return waveformId;
    }

    await _dao.updateWaveform(
      WaveformsCompanion(
        id: Value(waveform.id),
        name: Value(waveform.name),
        channel: Value(waveform.channel),
        durationMs: Value(waveform.durationMs),
        signalIntervalMs: Value(waveform.signalIntervalMs),
        signalDelayMs: Value(waveform.signalDelayMs),
        isBuiltIn: Value(waveform.isBuiltIn),
      ),
    );

    await _dao.deleteKeyframesForWaveform(waveform.id);
    if (waveform.keyframes.isNotEmpty) {
      await _dao.insertKeyframes(
        waveform.keyframes
            .map(
              (kf) => WaveformKeyframesCompanion.insert(
                waveformId: waveform.id,
                timeMs: kf.timeMs,
                value: kf.value,
              ),
            )
            .toList(),
      );
    }
    return waveform.id;
  }

  @override
  Future<void> deleteWaveform(int id) => _dao.deleteWaveform(id);

  // --- 常用波形配置 ---

  @override
  Future<List<FavoriteSlot>> getAllFavoriteSlots() async {
    await _ensureLocalDebugWaveformData();
    final rows = await _dao.getAllFavoriteSlots();
    return rows
        .map(
          (r) => FavoriteSlot(
            channel: r.channel,
            page: r.page,
            index: r.slotIndex,
            waveformId: r.waveformId,
          ),
        )
        .toList();
  }

  @override
  Future<List<FavoriteSlot>> getFavoriteSlotsByChannel(String channel) async {
    await _ensureLocalDebugWaveformData();
    final rows = await _dao.getFavoriteSlotsByChannel(channel);
    return rows
        .map(
          (r) => FavoriteSlot(
            channel: r.channel,
            page: r.page,
            index: r.slotIndex,
            waveformId: r.waveformId,
          ),
        )
        .toList();
  }

  @override
  Future<void> setFavoriteSlot(FavoriteSlot slot) => _dao.upsertFavoriteSlot(
    FavoriteSlotsCompanion.insert(
      channel: slot.channel,
      page: slot.page,
      slotIndex: slot.index,
      waveformId: slot.waveformId,
    ),
  );

  @override
  Future<void> removeFavoriteSlot({
    required String channel,
    required int page,
    required int index,
  }) async {
    await _dao.deleteFavoriteSlot(channel, page, index);

    final remaining = await _dao.getFavoriteSlotsByChannel(channel);
    final pageSlots =
        remaining.where((s) => s.page == page).toList()
          ..sort((a, b) => a.slotIndex.compareTo(b.slotIndex));

    final reindexed = <FavoriteSlotsCompanion>[];
    for (var i = 0; i < pageSlots.length; i++) {
      reindexed.add(
        FavoriteSlotsCompanion.insert(
          channel: channel,
          page: page,
          slotIndex: i,
          waveformId: pageSlots[i].waveformId,
        ),
      );
    }
    await _dao.updateSlotsOnPage(channel, page, reindexed);
  }

  @override
  Future<void> reorderFavoriteSlotsOnPage(
    String channel,
    int page,
    List<FavoriteSlot> slots,
  ) => _dao.updateSlotsOnPage(
    channel,
    page,
    slots
        .map(
          (s) => FavoriteSlotsCompanion.insert(
            channel: channel,
            page: page,
            slotIndex: s.index,
            waveformId: s.waveformId,
          ),
        )
        .toList(),
  );

  // --- 设备绑定 ---

  @override
  Future<DeviceBinding?> getActiveDeviceBinding() async {
    final row = await _userDao.getActiveDeviceBinding();
    return row != null ? _toDeviceBindingDomain(row) : null;
  }

  @override
  Future<List<DeviceBinding>> getAllDeviceBindings() async {
    final rows = await _userDao.getAllDeviceBindings();
    return rows.map(_toDeviceBindingDomain).toList();
  }

  @override
  Future<void> saveDeviceBinding(DeviceBinding binding) async {
    await _userDao.deactivateAllBindings();
    await _userDao.saveDeviceBinding(
      DeviceBindingsCompanion.insert(
        deviceId: binding.deviceId,
        deviceName: binding.deviceName,
      ),
    );
  }

  @override
  Future<void> deactivateAllBindings() => _userDao.deactivateAllBindings();

  Future<void> _ensureLocalDebugWaveformData() {
    final inFlight = _ensureDebugDataFuture;
    if (inFlight != null) {
      return inFlight;
    }

    final future = _ensureLocalDebugWaveformDataInternal();
    _ensureDebugDataFuture = future.whenComplete(() {
      if (identical(_ensureDebugDataFuture, future)) {
        _ensureDebugDataFuture = null;
      }
    });
    return _ensureDebugDataFuture!;
  }

  Future<void> _ensureLocalDebugWaveformDataInternal() async {
    var allWaveforms =
        (await _dao.getAllWaveforms()).map(_toWaveformDomain).toList();
    final swingWaveforms =
        allWaveforms.where((waveform) => waveform.channel == 'swing').toList();
    final vibrationWaveforms =
        allWaveforms
            .where((waveform) => waveform.channel == 'vibration')
            .toList();

    if (swingWaveforms.isEmpty) {
      for (final waveform in _buildSwingDebugWaveforms()) {
        await saveWaveform(waveform);
      }
    }

    if (vibrationWaveforms.isEmpty) {
      for (final waveform in _buildVibrationDebugWaveforms()) {
        await saveWaveform(waveform);
      }
    }

    allWaveforms =
        (await _dao.getAllWaveforms()).map(_toWaveformDomain).toList();
    final allSlots = await _dao.getAllFavoriteSlots();
    final hasSwingSlots = allSlots.any((slot) => slot.channel == 'swing');
    final hasVibrationSlots = allSlots.any(
      (slot) => slot.channel == 'vibration',
    );

    if (!hasSwingSlots) {
      await _seedDefaultFavoriteSlots(
        channel: 'swing',
        waveforms: allWaveforms,
      );
    }

    if (!hasVibrationSlots) {
      await _seedDefaultFavoriteSlots(
        channel: 'vibration',
        waveforms: allWaveforms,
      );
    }
  }

  Future<void> _seedDefaultFavoriteSlots({
    required String channel,
    required List<Waveform> waveforms,
  }) async {
    final channelWaveforms =
        waveforms.where((waveform) => waveform.channel == channel).toList()
          ..sort((a, b) => a.id.compareTo(b.id));

    for (var index = 0; index < channelWaveforms.length && index < 4; index++) {
      await setFavoriteSlot(
        FavoriteSlot(
          channel: channel,
          page: 0,
          index: index,
          waveformId: channelWaveforms[index].id,
        ),
      );
    }
  }

  List<Waveform> _buildSwingDebugWaveforms() {
    return [
      _buildDebugWaveform(
        name: '平缓摆动',
        channel: 'swing',
        durationMs: 4000,
        keyframes: const [
          WaveformKeyframe(timeMs: 0, value: 15),
          WaveformKeyframe(timeMs: 1000, value: 42),
          WaveformKeyframe(timeMs: 2000, value: 70),
          WaveformKeyframe(timeMs: 3000, value: 42),
          WaveformKeyframe(timeMs: 4000, value: 15),
        ],
      ),
      _buildDebugWaveform(
        name: '冲刺摆动',
        channel: 'swing',
        durationMs: 2400,
        keyframes: const [
          WaveformKeyframe(timeMs: 0, value: 0),
          WaveformKeyframe(timeMs: 400, value: 100),
          WaveformKeyframe(timeMs: 800, value: 18),
          WaveformKeyframe(timeMs: 1200, value: 100),
          WaveformKeyframe(timeMs: 1600, value: 18),
          WaveformKeyframe(timeMs: 2400, value: 0),
        ],
      ),
      _buildDebugWaveform(
        name: '阶梯摆动',
        channel: 'swing',
        durationMs: 3600,
        keyframes: const [
          WaveformKeyframe(timeMs: 0, value: 20),
          WaveformKeyframe(timeMs: 900, value: 20),
          WaveformKeyframe(timeMs: 1800, value: 55),
          WaveformKeyframe(timeMs: 2700, value: 82),
          WaveformKeyframe(timeMs: 3600, value: 20),
        ],
      ),
      _buildDebugWaveform(
        name: '波浪摆动',
        channel: 'swing',
        durationMs: 3200,
        keyframes: const [
          WaveformKeyframe(timeMs: 0, value: 10),
          WaveformKeyframe(timeMs: 600, value: 76),
          WaveformKeyframe(timeMs: 1200, value: 35),
          WaveformKeyframe(timeMs: 1800, value: 92),
          WaveformKeyframe(timeMs: 2400, value: 28),
          WaveformKeyframe(timeMs: 3200, value: 10),
        ],
      ),
    ];
  }

  List<Waveform> _buildVibrationDebugWaveforms() {
    return [
      _buildDebugWaveform(
        name: '轻柔震动',
        channel: 'vibration',
        durationMs: 3200,
        keyframes: const [
          WaveformKeyframe(timeMs: 0, value: 20),
          WaveformKeyframe(timeMs: 800, value: 36),
          WaveformKeyframe(timeMs: 1600, value: 26),
          WaveformKeyframe(timeMs: 2400, value: 40),
          WaveformKeyframe(timeMs: 3200, value: 20),
        ],
      ),
      _buildDebugWaveform(
        name: '脉冲震动',
        channel: 'vibration',
        durationMs: 1800,
        keyframes: const [
          WaveformKeyframe(timeMs: 0, value: 0),
          WaveformKeyframe(timeMs: 300, value: 92),
          WaveformKeyframe(timeMs: 600, value: 0),
          WaveformKeyframe(timeMs: 900, value: 92),
          WaveformKeyframe(timeMs: 1200, value: 0),
          WaveformKeyframe(timeMs: 1500, value: 92),
          WaveformKeyframe(timeMs: 1800, value: 0),
        ],
      ),
      _buildDebugWaveform(
        name: '递进震动',
        channel: 'vibration',
        durationMs: 3500,
        keyframes: const [
          WaveformKeyframe(timeMs: 0, value: 15),
          WaveformKeyframe(timeMs: 700, value: 30),
          WaveformKeyframe(timeMs: 1400, value: 50),
          WaveformKeyframe(timeMs: 2100, value: 70),
          WaveformKeyframe(timeMs: 2800, value: 90),
          WaveformKeyframe(timeMs: 3500, value: 18),
        ],
      ),
      _buildDebugWaveform(
        name: '波浪震动',
        channel: 'vibration',
        durationMs: 2400,
        keyframes: const [
          WaveformKeyframe(timeMs: 0, value: 30),
          WaveformKeyframe(timeMs: 400, value: 78),
          WaveformKeyframe(timeMs: 800, value: 42),
          WaveformKeyframe(timeMs: 1200, value: 86),
          WaveformKeyframe(timeMs: 1600, value: 36),
          WaveformKeyframe(timeMs: 2400, value: 30),
        ],
      ),
    ];
  }

  Waveform _buildDebugWaveform({
    required String name,
    required String channel,
    required int durationMs,
    required List<WaveformKeyframe> keyframes,
  }) {
    return Waveform(
      id: 0,
      name: name,
      channel: channel,
      durationMs: durationMs,
      signalIntervalMs: 200,
      signalDelayMs: 0,
      isBuiltIn: true,
      keyframes: keyframes,
    );
  }

  // --- 使用日志 ---

  @override
  Future<void> insertUsageLog(UsageLog log) => _dao.insertUsageLog(
    UsageLogsCompanion.insert(
      startTime: log.startTime,
      signalMode: log.signalMode,
      waveformId: log.waveformId,
      intensityLevel: log.intensityLevel,
      durationMs: log.durationMs,
      deviceModel: Value(log.deviceModel),
      deviceSerial: Value(log.deviceSerial),
    ),
  );

  @override
  Future<List<UsageLog>> getUnsynced() async {
    final rows = await _dao.getUnsyncedLogs();
    return rows
        .map(
          (r) => UsageLog(
            id: r.id,
            startTime: r.startTime,
            signalMode: r.signalMode,
            waveformId: r.waveformId,
            intensityLevel: r.intensityLevel,
            durationMs: r.durationMs,
            deviceModel: r.deviceModel,
            deviceSerial: r.deviceSerial,
          ),
        )
        .toList();
  }

  @override
  Future<void> markSynced(List<int> ids) => _dao.markLogsSynced(ids);

  // --- 云同步 ---

  @override
  Future<void> syncToCloud() async {
    // TODO: 依赖后端 API 就绪后实现
  }

  @override
  Future<void> syncFromCloud() async {
    // TODO: 依赖后端 API 就绪后实现
  }

  // --- 转换工具 ---

  Waveform _toWaveformDomain(WaveformWithKeyframes row) {
    return Waveform(
      id: row.waveform.id,
      name: row.waveform.name,
      channel: row.waveform.channel,
      durationMs: row.waveform.durationMs,
      signalIntervalMs: row.waveform.signalIntervalMs,
      signalDelayMs: row.waveform.signalDelayMs,
      isBuiltIn: row.waveform.isBuiltIn,
      keyframes:
          row.keyframes
              .map((kf) => WaveformKeyframe(timeMs: kf.timeMs, value: kf.value))
              .toList(),
    );
  }

  DeviceBinding _toDeviceBindingDomain(dynamic row) {
    return DeviceBinding(
      deviceId: row.deviceId as String,
      deviceName: row.deviceName as String,
      boundAt: row.boundAt as DateTime,
      isActive: row.isActive as bool,
    );
  }
}
