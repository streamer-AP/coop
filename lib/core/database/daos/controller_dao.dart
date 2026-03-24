import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/controller_tables.dart';

part 'controller_dao.g.dart';

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
    final waveformRows =
        await (select(waveforms)..orderBy([
          (t) => OrderingTerm.asc(t.channel),
          (t) => OrderingTerm.asc(t.id),
        ])).get();
    if (waveformRows.isEmpty) return const [];

    final ids = waveformRows.map((row) => row.id).toList();
    final keyframeRows =
        await (select(waveformKeyframes)
              ..where((t) => t.waveformId.isIn(ids))
              ..orderBy([
                (t) => OrderingTerm.asc(t.waveformId),
                (t) => OrderingTerm.asc(t.timeMs),
              ]))
            .get();

    final grouped = <int, List<WaveformKeyframe>>{};
    for (final row in keyframeRows) {
      grouped.putIfAbsent(row.waveformId, () => []).add(row);
    }

    return waveformRows
        .map(
          (waveform) => WaveformWithKeyframes(
            waveform: waveform,
            keyframes: grouped[waveform.id] ?? const [],
          ),
        )
        .toList();
  }

  Future<List<WaveformWithKeyframes>> getWaveformsByChannel(
    String channel,
  ) async {
    final channelWaveforms =
        await (select(waveforms)
              ..where((t) => t.channel.equals(channel))
              ..orderBy([(t) => OrderingTerm.asc(t.id)]))
            .get();

    if (channelWaveforms.isEmpty) return const [];

    final ids = channelWaveforms.map((w) => w.id).toList();
    final kfs =
        await (select(waveformKeyframes)
              ..where((t) => t.waveformId.isIn(ids))
              ..orderBy([
                (t) => OrderingTerm.asc(t.waveformId),
                (t) => OrderingTerm.asc(t.timeMs),
              ]))
            .get();

    final grouped = <int, List<WaveformKeyframe>>{};
    for (final kf in kfs) {
      grouped.putIfAbsent(kf.waveformId, () => []).add(kf);
    }

    return channelWaveforms
        .map(
          (w) => WaveformWithKeyframes(
            waveform: w,
            keyframes: grouped[w.id] ?? const [],
          ),
        )
        .toList();
  }

  Future<WaveformWithKeyframes?> getWaveformById(int id) async {
    final waveform =
        await (select(waveforms)
          ..where((t) => t.id.equals(id))).getSingleOrNull();
    if (waveform == null) return null;

    final keyframes =
        await (select(waveformKeyframes)
              ..where((t) => t.waveformId.equals(id))
              ..orderBy([(t) => OrderingTerm.asc(t.timeMs)]))
            .get();

    return WaveformWithKeyframes(waveform: waveform, keyframes: keyframes);
  }

  Future<int> insertWaveform(WaveformsCompanion waveform) =>
      into(waveforms).insert(waveform);

  Future<void> updateWaveform(WaveformsCompanion waveform) async {
    await update(
      waveforms,
    ).replace(waveform.copyWith(updatedAt: Value(DateTime.now())));
  }

  Future<void> deleteWaveform(int id) async {
    await (delete(waveforms)..where((t) => t.id.equals(id))).go();
  }

  Future<void> insertKeyframes(
    List<WaveformKeyframesCompanion> keyframes,
  ) async {
    if (keyframes.isEmpty) return;

    await batch((b) {
      b.insertAll(waveformKeyframes, keyframes);
    });
  }

  Future<void> deleteKeyframesForWaveform(int waveformId) async =>
      (delete(waveformKeyframes)
        ..where((t) => t.waveformId.equals(waveformId))).go();

  // --- 常用槽位 ---

  Future<List<FavoriteSlot>> getAllFavoriteSlots() =>
      (select(favoriteSlots)..orderBy([
        (t) => OrderingTerm.asc(t.channel),
        (t) => OrderingTerm.asc(t.page),
        (t) => OrderingTerm.asc(t.slotIndex),
      ])).get();

  Future<List<FavoriteSlot>> getFavoriteSlotsByChannel(String channel) =>
      (select(favoriteSlots)
            ..where((t) => t.channel.equals(channel))
            ..orderBy([
              (t) => OrderingTerm.asc(t.page),
              (t) => OrderingTerm.asc(t.slotIndex),
            ]))
          .get();

  Future<void> upsertFavoriteSlot(FavoriteSlotsCompanion slot) async {
    await into(favoriteSlots).insert(slot, mode: InsertMode.insertOrReplace);
  }

  Future<void> deleteFavoriteSlot(
    String channel,
    int page,
    int slotIndex,
  ) async {
    await (delete(favoriteSlots)..where(
      (t) =>
          t.channel.equals(channel) &
          t.page.equals(page) &
          t.slotIndex.equals(slotIndex),
    )).go();
  }

  Future<void> deleteFavoriteSlotsForWaveform(int waveformId) async {
    await (delete(favoriteSlots)
      ..where((t) => t.waveformId.equals(waveformId))).go();
  }

  Future<void> updateSlotsOnPage(
    String channel,
    int page,
    List<FavoriteSlotsCompanion> slots,
  ) async {
    await transaction(() async {
      await (delete(favoriteSlots)
        ..where((t) => t.channel.equals(channel) & t.page.equals(page))).go();
      if (slots.isEmpty) return;
      await batch((b) {
        b.insertAll(favoriteSlots, slots);
      });
    });
  }

  // --- 使用日志 ---

  Future<void> insertUsageLog(UsageLogsCompanion log) async =>
      into(usageLogs).insert(log);

  Future<List<UsageLog>> getUnsyncedLogs() =>
      (select(usageLogs)
            ..where((t) => t.isSynced.equals(false))
            ..orderBy([(t) => OrderingTerm.asc(t.startTime)]))
          .get();

  Future<void> markLogsSynced(List<int> ids) async {
    if (ids.isEmpty) return;

    await (update(usageLogs)..where(
      (t) => t.id.isIn(ids),
    )).write(const UsageLogsCompanion(isSynced: Value(true)));
  }
}
