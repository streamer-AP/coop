import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart' as db;
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

  ControllerRepositoryImpl(this._dao, this._userDao);

  // --- 波形 CRUD ---

  Waveform _mapWaveform(WaveformWithKeyframes row) {
    return Waveform(
      id: row.waveform.id,
      name: row.waveform.name,
      channel: WaveformChannel.values.byName(row.waveform.channel),
      durationMs: row.waveform.durationMs,
      signalIntervalMs: row.waveform.signalIntervalMs,
      signalDelayMs: row.waveform.signalDelayMs,
      isBuiltIn: row.waveform.isBuiltIn,
      keyframes: row.keyframes.map(_mapKeyframe).toList(),
    );
  }

  WaveformKeyframe _mapKeyframe(db.WaveformKeyframe row) {
    return WaveformKeyframe(timeMs: row.timeMs, value: row.value);
  }

  FavoriteSlot _mapFavoriteSlot(db.FavoriteSlot row) {
    return FavoriteSlot(
      channel: WaveformChannel.values.byName(row.channel),
      page: row.page,
      index: row.slotIndex,
      waveformId: row.waveformId,
    );
  }

  UsageLog _mapUsageLog(db.UsageLog row) {
    return UsageLog(
      id: row.id,
      startTime: row.startTime,
      signalMode: row.signalMode,
      waveformId: row.waveformId,
      intensityLevel: row.intensityLevel,
      durationMs: row.durationMs,
      deviceModel: row.deviceModel,
      deviceSerial: row.deviceSerial,
    );
  }

  db.WaveformsCompanion _toWaveformCompanion(Waveform waveform) {
    return db.WaveformsCompanion(
      id: waveform.id == 0 ? const Value.absent() : Value(waveform.id),
      name: Value(waveform.name),
      channel: Value(waveform.channel.name),
      durationMs: Value(waveform.durationMs),
      signalIntervalMs: Value(waveform.signalIntervalMs),
      signalDelayMs: Value(waveform.signalDelayMs),
      isBuiltIn: Value(waveform.isBuiltIn),
    );
  }

  db.WaveformKeyframesCompanion _toKeyframeCompanion(
    int waveformId,
    WaveformKeyframe keyframe,
  ) {
    return db.WaveformKeyframesCompanion(
      waveformId: Value(waveformId),
      timeMs: Value(keyframe.timeMs),
      value: Value(keyframe.value),
    );
  }

  @override
  Future<List<Waveform>> getAllWaveforms() async {
    final rows = await _dao.getAllWaveforms();
    return rows.map(_mapWaveform).toList();
  }

  @override
  Future<List<Waveform>> getWaveformsByChannel(WaveformChannel channel) async {
    final rows = await _dao.getWaveformsByChannel(channel.name);
    return rows.map(_mapWaveform).toList();
  }

  @override
  Future<Waveform?> getWaveformById(int id) async {
    final row = await _dao.getWaveformById(id);
    return row == null ? null : _mapWaveform(row);
  }

  @override
  Future<int> saveWaveform(Waveform waveform) async {
    return _dao.attachedDatabase.transaction(() async {
      final companion = _toWaveformCompanion(waveform);
      final waveformId =
          waveform.id == 0 ? await _dao.insertWaveform(companion) : waveform.id;

      if (waveform.id != 0) {
        await _dao.updateWaveform(companion);
      }

      await _dao.deleteKeyframesForWaveform(waveformId);
      await _dao.insertKeyframes(
        waveform.keyframes
            .map((keyframe) => _toKeyframeCompanion(waveformId, keyframe))
            .toList(),
      );

      return waveformId;
    });
  }

  @override
  Future<void> deleteWaveform(int id) async {
    await _dao.attachedDatabase.transaction(() async {
      await _dao.deleteFavoriteSlotsForWaveform(id);
      await _dao.deleteKeyframesForWaveform(id);
      await _dao.deleteWaveform(id);
    });
  }

  // --- 常用波形配置 ---

  @override
  Future<List<FavoriteSlot>> getAllFavoriteSlots() async {
    final rows = await _dao.getAllFavoriteSlots();
    return rows.map(_mapFavoriteSlot).toList();
  }

  @override
  Future<List<FavoriteSlot>> getFavoriteSlotsByChannel(
    WaveformChannel channel,
  ) async {
    final rows = await _dao.getFavoriteSlotsByChannel(channel.name);
    return rows.map(_mapFavoriteSlot).toList();
  }

  @override
  Future<void> setFavoriteSlot(FavoriteSlot slot) async {
    await _dao.upsertFavoriteSlot(
      db.FavoriteSlotsCompanion.insert(
        channel: slot.channel.name,
        page: slot.page,
        slotIndex: slot.index,
        waveformId: slot.waveformId,
      ),
    );
  }

  @override
  Future<void> removeFavoriteSlot({
    required WaveformChannel channel,
    required int page,
    required int index,
  }) async {
    await _dao.deleteFavoriteSlot(channel.name, page, index);

    final remaining = await _dao.getFavoriteSlotsByChannel(channel.name);
    final pageSlots =
        remaining.where((s) => s.page == page).toList()
          ..sort((a, b) => a.slotIndex.compareTo(b.slotIndex));

    final reindexed = <db.FavoriteSlotsCompanion>[];
    for (var i = 0; i < pageSlots.length; i++) {
      reindexed.add(
        db.FavoriteSlotsCompanion.insert(
          channel: channel.name,
          page: page,
          slotIndex: i,
          waveformId: pageSlots[i].waveformId,
        ),
      );
    }
    await _dao.updateSlotsOnPage(channel.name, page, reindexed);
  }

  @override
  Future<void> reorderFavoriteSlotsOnPage(
    WaveformChannel channel,
    int page,
    List<FavoriteSlot> slots,
  ) async {
    await _dao.updateSlotsOnPage(
      channel.name,
      page,
      slots
          .map(
            (slot) => db.FavoriteSlotsCompanion.insert(
              channel: channel.name,
              page: slot.page,
              slotIndex: slot.index,
              waveformId: slot.waveformId,
            ),
          )
          .toList(),
    );
  }

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
      db.DeviceBindingsCompanion.insert(
        deviceId: binding.deviceId,
        deviceName: binding.deviceName,
      ),
    );
  }

  @override
  Future<void> deactivateAllBindings() => _userDao.deactivateAllBindings();

  // --- 使用日志 ---

  @override
  Future<void> insertUsageLog(UsageLog log) async {
    await _dao.insertUsageLog(
      db.UsageLogsCompanion.insert(
        startTime: log.startTime,
        signalMode: log.signalMode,
        waveformId: log.waveformId,
        intensityLevel: log.intensityLevel,
        durationMs: log.durationMs,
        deviceModel: Value(log.deviceModel),
        deviceSerial: Value(log.deviceSerial),
      ),
    );
  }

  @override
  Future<List<UsageLog>> getUnsynced() async {
    final rows = await _dao.getUnsyncedLogs();
    return rows.map(_mapUsageLog).toList();
  }

  @override
  Future<void> markSynced(List<int> ids) async {
    await _dao.markLogsSynced(ids);
  }

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

  DeviceBinding _toDeviceBindingDomain(dynamic row) {
    return DeviceBinding(
      deviceId: row.deviceId as String,
      deviceName: row.deviceName as String,
      boundAt: row.boundAt as DateTime,
      isActive: row.isActive as bool,
    );
  }
}
