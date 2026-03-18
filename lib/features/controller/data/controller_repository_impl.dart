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

  ControllerRepositoryImpl(this._dao, this._userDao);

  // --- 波形 CRUD ---

  @override
  Future<List<Waveform>> getAllWaveforms() async {
    final rows = await _dao.getAllWaveforms();
    return rows.map(_toWaveformDomain).toList();
  }

  @override
  Future<List<Waveform>> getWaveformsByChannel(String channel) async {
    final rows = await _dao.getWaveformsByChannel(channel);
    return rows.map(_toWaveformDomain).toList();
  }

  @override
  Future<Waveform?> getWaveformById(int id) async {
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
  ) =>
      _dao.updateSlotsOnPage(
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
      keyframes: row.keyframes
          .map(
            (kf) => WaveformKeyframe(
              timeMs: kf.timeMs,
              value: kf.value,
            ),
          )
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
