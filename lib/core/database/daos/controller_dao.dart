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
    final allWaveforms = await select(waveforms).get();
    final allKeyframes = await select(waveformKeyframes).get();

    final keyframesByWaveform = <int, List<WaveformKeyframe>>{};
    for (final kf in allKeyframes) {
      keyframesByWaveform.putIfAbsent(kf.waveformId, () => []).add(kf);
    }

    return allWaveforms
        .map(
          (w) => WaveformWithKeyframes(
            waveform: w,
            keyframes: keyframesByWaveform[w.id] ?? [],
          ),
        )
        .toList();
  }

  Future<List<WaveformWithKeyframes>> getWaveformsByChannel(
    String channel,
  ) async {
    final channelWaveforms =
        await (select(waveforms)..where((t) => t.channel.equals(channel)))
            .get();

    if (channelWaveforms.isEmpty) return [];

    final ids = channelWaveforms.map((w) => w.id).toList();
    final kfs =
        await (select(waveformKeyframes)
              ..where((t) => t.waveformId.isIn(ids))
              ..orderBy([(t) => OrderingTerm.asc(t.timeMs)]))
            .get();

    final keyframesByWaveform = <int, List<WaveformKeyframe>>{};
    for (final kf in kfs) {
      keyframesByWaveform.putIfAbsent(kf.waveformId, () => []).add(kf);
    }

    return channelWaveforms
        .map(
          (w) => WaveformWithKeyframes(
            waveform: w,
            keyframes: keyframesByWaveform[w.id] ?? [],
          ),
        )
        .toList();
  }

  Future<WaveformWithKeyframes?> getWaveformById(int id) async {
    final waveform =
        await (select(waveforms)..where((t) => t.id.equals(id)))
            .getSingleOrNull();
    if (waveform == null) return null;

    final kfs =
        await (select(waveformKeyframes)
              ..where((t) => t.waveformId.equals(id))
              ..orderBy([(t) => OrderingTerm.asc(t.timeMs)]))
            .get();

    return WaveformWithKeyframes(waveform: waveform, keyframes: kfs);
  }

  Future<int> insertWaveform(WaveformsCompanion waveform) =>
      into(waveforms).insert(waveform);

  Future<void> updateWaveform(WaveformsCompanion waveform) async {
    final withTimestamp = waveform.copyWith(
      updatedAt: Value(DateTime.now()),
    );
    await update(waveforms).replace(withTimestamp);
  }

  Future<void> deleteWaveform(int id) async {
    await transaction(() async {
      await (delete(waveformKeyframes)
            ..where((t) => t.waveformId.equals(id)))
          .go();
      await (delete(waveforms)..where((t) => t.id.equals(id))).go();
    });
  }

  Future<void> insertKeyframes(
    List<WaveformKeyframesCompanion> kfs,
  ) async {
    await batch((b) => b.insertAll(waveformKeyframes, kfs));
  }

  Future<void> deleteKeyframesForWaveform(int waveformId) =>
      (delete(waveformKeyframes)
            ..where((t) => t.waveformId.equals(waveformId)))
          .go();

  // --- 常用槽位 ---

  Future<List<FavoriteSlot>> getAllFavoriteSlots() =>
      (select(favoriteSlots)
            ..orderBy([
              (t) => OrderingTerm.asc(t.channel),
              (t) => OrderingTerm.asc(t.page),
              (t) => OrderingTerm.asc(t.slotIndex),
            ]))
          .get();

  Future<List<FavoriteSlot>> getFavoriteSlotsByChannel(String channel) =>
      (select(favoriteSlots)
            ..where((t) => t.channel.equals(channel))
            ..orderBy([
              (t) => OrderingTerm.asc(t.page),
              (t) => OrderingTerm.asc(t.slotIndex),
            ]))
          .get();

  Future<void> upsertFavoriteSlot(FavoriteSlotsCompanion slot) =>
      into(favoriteSlots).insertOnConflictUpdate(slot);

  Future<void> deleteFavoriteSlot(
    String channel,
    int page,
    int slotIndex,
  ) =>
      (delete(favoriteSlots)
            ..where(
              (t) =>
                  t.channel.equals(channel) &
                  t.page.equals(page) &
                  t.slotIndex.equals(slotIndex),
            ))
          .go();

  Future<void> updateSlotsOnPage(
    String channel,
    int page,
    List<FavoriteSlotsCompanion> slots,
  ) async {
    await transaction(() async {
      await (delete(favoriteSlots)
            ..where(
              (t) => t.channel.equals(channel) & t.page.equals(page),
            ))
          .go();
      await batch((b) => b.insertAll(favoriteSlots, slots));
    });
  }

  // --- 使用日志 ---

  Future<void> insertUsageLog(UsageLogsCompanion log) =>
      into(usageLogs).insert(log);

  Future<List<UsageLog>> getUnsyncedLogs() =>
      (select(usageLogs)..where((t) => t.isSynced.equals(false))).get();

  Future<void> markLogsSynced(List<int> ids) async {
    await (update(usageLogs)..where((t) => t.id.isIn(ids))).write(
      const UsageLogsCompanion(isSynced: Value(true)),
    );
  }
}
