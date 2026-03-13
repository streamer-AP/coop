import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/controller_tables.dart';

part 'controller_dao.g.dart';

/// 波形 + keyframes 的聚合查询结果
class WaveformWithKeyframes {
  final Waveform waveform;
  final List<WaveformKeyframe> keyframes;

  WaveformWithKeyframes({required this.waveform, required this.keyframes});
}

@DriftAccessor(tables: [Waveforms, WaveformKeyframes, FavoriteSlots, UsageLogs])
class ControllerDao extends DatabaseAccessor<AppDatabase>
    with _$ControllerDaoMixin {
  ControllerDao(super.db);

  // --- 波形 ---

  Future<List<WaveformWithKeyframes>> getAllWaveforms() async {
    // TODO: implement — JOIN waveforms + keyframes
    throw UnimplementedError();
  }

  Future<WaveformWithKeyframes?> getWaveformById(int id) async {
    // TODO: implement
    throw UnimplementedError();
  }

  Future<int> insertWaveform(WaveformsCompanion waveform) async {
    // TODO: implement
    throw UnimplementedError();
  }

  Future<void> updateWaveform(WaveformsCompanion waveform) async {
    // TODO: implement
    throw UnimplementedError();
  }

  Future<void> deleteWaveform(int id) async {
    // TODO: implement — 同时删除关联 keyframes
    throw UnimplementedError();
  }

  Future<void> insertKeyframes(
    List<WaveformKeyframesCompanion> keyframes,
  ) async {
    // TODO: implement — batch insert
    throw UnimplementedError();
  }

  Future<void> deleteKeyframesForWaveform(int waveformId) async {
    // TODO: implement
    throw UnimplementedError();
  }

  // --- 常用槽位 ---

  Future<List<FavoriteSlot>> getAllFavoriteSlots() async {
    // TODO: implement
    throw UnimplementedError();
  }

  Future<void> upsertFavoriteSlot(FavoriteSlotsCompanion slot) async {
    // TODO: implement — INSERT OR REPLACE on (page, slotIndex)
    throw UnimplementedError();
  }

  Future<void> deleteFavoriteSlot(int page, int slotIndex) async {
    // TODO: implement
    throw UnimplementedError();
  }

  Future<void> updateSlotsOnPage(
    int page,
    List<FavoriteSlotsCompanion> slots,
  ) async {
    // TODO: implement — 事务内删除旧的 + 批量插入新的
    throw UnimplementedError();
  }

  // --- 使用日志 ---

  Future<void> insertUsageLog(UsageLogsCompanion log) async {
    // TODO: implement
    throw UnimplementedError();
  }

  Future<List<UsageLog>> getUnsyncedLogs() async {
    // TODO: implement — WHERE isSynced = false
    throw UnimplementedError();
  }

  Future<void> markLogsSynced(List<int> ids) async {
    // TODO: implement — UPDATE isSynced = true WHERE id IN (ids)
    throw UnimplementedError();
  }
}
