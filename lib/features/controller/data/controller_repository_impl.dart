import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart' as db;
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

  FavoriteSlot _mapFavoriteSlot(db.FavoriteSlot row) {
    return FavoriteSlot(
      channel: WaveformChannel.values.byName(row.channel),
      page: row.page,
      index: row.slotIndex,
      waveformId: row.waveformId,
    );
  }

  // --- 波形 CRUD ---

  @override
  Future<List<Waveform>> getAllWaveforms() async {
    await _ensureLocalDebugWaveformData();
    final rows = await _dao.getAllWaveforms();
    return rows.map(_toWaveformDomain).toList();
  }

  @override
  Future<List<Waveform>> getWaveformsByChannel(WaveformChannel channel) async {
    await _ensureLocalDebugWaveformData();
    final rows = await _dao.getWaveformsByChannel(channel.name);
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
    final normalizedKeyframes = _normalizeKeyframes(waveform.keyframes);

    if (waveform.id == 0) {
      final waveformId = await _dao.insertWaveform(
        WaveformsCompanion.insert(
          name: waveform.name,
          channel: waveform.channel.name,
          durationMs: Value(waveform.durationMs),
          signalIntervalMs: Value(waveform.signalIntervalMs),
          signalDelayMs: Value(waveform.signalDelayMs),
          isBuiltIn: Value(waveform.isBuiltIn),
        ),
      );
      if (normalizedKeyframes.isNotEmpty) {
        await _dao.insertKeyframes(
          normalizedKeyframes
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
        channel: Value(waveform.channel.name),
        durationMs: Value(waveform.durationMs),
        signalIntervalMs: Value(waveform.signalIntervalMs),
        signalDelayMs: Value(waveform.signalDelayMs),
        isBuiltIn: Value(waveform.isBuiltIn),
      ),
    );

    await _dao.deleteKeyframesForWaveform(waveform.id);
    if (normalizedKeyframes.isNotEmpty) {
      await _dao.insertKeyframes(
        normalizedKeyframes
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
  Future<void> deleteWaveform(int id) async {
    await _dao.deleteFavoriteSlotsForWaveform(id);
    await _dao.deleteWaveform(id);
  }

  // --- 常用波形配置 ---

  @override
  Future<List<FavoriteSlot>> getAllFavoriteSlots() async {
    await _ensureLocalDebugWaveformData();
    // final rows = await _dao.getAllFavoriteSlots();
    // return rows
    //     .map(
    //       (r) => FavoriteSlot(
    //         channel: r.channel,
    //         page: r.page,
    //         index: r.slotIndex,
    //         waveformId: r.waveformId,
    //       ),
    //     )
    //     .toList();
    final rows = await _dao.getAllFavoriteSlots();
    return rows.map(_mapFavoriteSlot).toList();
  }

  @override
  Future<List<FavoriteSlot>> getFavoriteSlotsByChannel(
      WaveformChannel channel,
      ) async {
    await _ensureLocalDebugWaveformData();
    // final rows = await _dao.getFavoriteSlotsByChannel(channel.name);
    // return rows
    //     .map(
    //       (r) => FavoriteSlot(
    //         channel: r.channel,
    //         page: r.page,
    //         index: r.slotIndex,
    //         waveformId: r.waveformId,
    //       ),
    //     )
    //     .toList();
    final rows = await _dao.getFavoriteSlotsByChannel(channel.name);
    return rows.map(_mapFavoriteSlot).toList();
  }

  @override
  Future<void> setFavoriteSlot(FavoriteSlot slot) => _dao.upsertFavoriteSlot(
    FavoriteSlotsCompanion.insert(
      channel: slot.channel.name,
      page: slot.page,
      slotIndex: slot.index,
      waveformId: slot.waveformId,
    ),
  );

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

    final reindexed = <FavoriteSlotsCompanion>[];
    for (var i = 0; i < pageSlots.length; i++) {
      reindexed.add(
        FavoriteSlotsCompanion.insert(
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
      ) => _dao.updateSlotsOnPage(
    channel.name,
    page,
    slots
        .map(
          (s) => FavoriteSlotsCompanion.insert(
        channel: channel.name,
        page: page,
        slotIndex: s.index,
        waveformId: s.waveformId,
      ),
    )
        .toList(),
  );

  @override
  Future<void> replaceFavoriteSlotsForChannel(
    WaveformChannel channel,
    List<FavoriteSlot> slots,
  ) => _dao.replaceFavoriteSlotsForChannel(
    channel.name,
    slots
        .map(
          (slot) => FavoriteSlotsCompanion.insert(
            channel: channel.name,
            page: slot.page,
            slotIndex: slot.index,
            waveformId: slot.waveformId,
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
    final swingDebugWaveforms = _buildSwingDebugWaveforms();
    final vibrationDebugWaveforms = _buildVibrationDebugWaveforms();

    var allWaveforms =
        (await _dao.getAllWaveforms()).map(_toWaveformDomain).toList();

    await _ensureDebugWaveformsExist(
      existingWaveforms: allWaveforms,
      debugWaveforms: swingDebugWaveforms,
    );
    await _ensureDebugWaveformsExist(
      existingWaveforms: allWaveforms,
      debugWaveforms: vibrationDebugWaveforms,
    );

    allWaveforms =
        (await _dao.getAllWaveforms()).map(_toWaveformDomain).toList();
    final allSlots = await _dao.getAllFavoriteSlots();

    await _ensureDefaultFavoriteSlots(
      channel: WaveformChannel.swing,
      waveforms: allWaveforms,
      existingSlots: allSlots,
      orderedNames: swingDebugWaveforms.map((waveform) => waveform.name).toList(),
    );
    await _ensureDefaultFavoriteSlots(
      channel: WaveformChannel.vibration,
      waveforms: allWaveforms,
      existingSlots: allSlots,
      orderedNames:
          vibrationDebugWaveforms.map((waveform) => waveform.name).toList(),
    );
  }

  Future<void> _ensureDebugWaveformsExist({
    required List<Waveform> existingWaveforms,
    required List<Waveform> debugWaveforms,
  }) async {
    final existingKeys = existingWaveforms
        .map((waveform) => '${waveform.channel.name}::${waveform.name}')
        .toSet();

    for (final waveform in debugWaveforms) {
      final key = '${waveform.channel.name}::${waveform.name}';
      if (existingKeys.contains(key)) {
        continue;
      }
      await saveWaveform(waveform);
      existingKeys.add(key);
    }
  }

  Future<void> _ensureDefaultFavoriteSlots({
    required WaveformChannel channel,
    required List<Waveform> waveforms,
    required List<db.FavoriteSlot> existingSlots,
    required List<String> orderedNames,
  }) async {
    final channelSlots =
        existingSlots.where((slot) => slot.channel == channel.name).toList();
    final occupiedPositions = channelSlots
        .map((slot) => '${slot.page}:${slot.slotIndex}')
        .toSet();
    final usedWaveformIds = channelSlots.map((slot) => slot.waveformId).toSet();

    final orderedWaveforms = <Waveform>[];
    for (final name in orderedNames) {
      for (final waveform in waveforms) {
        if (waveform.channel == channel && waveform.name == name) {
          orderedWaveforms.add(waveform);
          break;
        }
      }
    }

    final availableWaveforms = orderedWaveforms
        .where((waveform) => !usedWaveformIds.contains(waveform.id))
        .toList();
    var nextWaveformIndex = 0;

    for (var page = 0; page < 3; page++) {
      for (var index = 0; index < 4; index++) {
        final positionKey = '$page:$index';
        if (occupiedPositions.contains(positionKey)) {
          continue;
        }
        if (nextWaveformIndex >= availableWaveforms.length) {
          return;
        }

        final waveform = availableWaveforms[nextWaveformIndex++];
        await setFavoriteSlot(
          FavoriteSlot(
            channel: channel,
            page: page,
            index: index,
            waveformId: waveform.id,
          ),
        );
      }
    }
  }

  List<Waveform> _buildSwingDebugWaveforms() {
    return [
      _buildDebugWaveform(
        name: '羽毛轻扫',
        channel: WaveformChannel.swing,
        durationMs: 4000,
        keyframes: const [
          WaveformKeyframe(timeMs: 0, value: 15),
          WaveformKeyframe(timeMs: 1000, value: 42),
          WaveformKeyframe(timeMs: 2000, value: 70),
          WaveformKeyframe(timeMs: 2000, value: 70),
          WaveformKeyframe(timeMs: 2000, value: 70),
          WaveformKeyframe(timeMs: 2000, value: 70),
          WaveformKeyframe(timeMs: 2000, value: 70),
          WaveformKeyframe(timeMs: 2000, value: 70),
          WaveformKeyframe(timeMs: 2000, value: 70),
          WaveformKeyframe(timeMs: 2000, value: 70),
          WaveformKeyframe(timeMs: 3000, value: 42),
          WaveformKeyframe(timeMs: 4000, value: 15),
        ],
      ),
      _buildDebugWaveform(
        name: '深海呼吸',
        channel: WaveformChannel.swing,
        durationMs: 2400,
        keyframes: const [
          WaveformKeyframe(timeMs: 0, value: 0),
          WaveformKeyframe(timeMs: 400, value: 100),
          WaveformKeyframe(timeMs: 800, value: 18),
          WaveformKeyframe(timeMs: 1200, value: 100),
          WaveformKeyframe(timeMs: 1600, value: 18),
          WaveformKeyframe(timeMs: 2400, value: 0),
          WaveformKeyframe(timeMs: 2400, value: 0),
          WaveformKeyframe(timeMs: 2400, value: 0),
          WaveformKeyframe(timeMs: 2400, value: 0),
          WaveformKeyframe(timeMs: 2400, value: 0),
          WaveformKeyframe(timeMs: 2400, value: 0),
          WaveformKeyframe(timeMs: 2400, value: 0),
          WaveformKeyframe(timeMs: 2400, value: 0),
          WaveformKeyframe(timeMs: 2400, value: 0),
        ],
      ),
      _buildDebugWaveform(
        name: '午后清风',
        channel: WaveformChannel.swing,
        durationMs: 3600,
        keyframes: const [
          WaveformKeyframe(timeMs: 0, value: 20),
          WaveformKeyframe(timeMs: 900, value: 20),
          WaveformKeyframe(timeMs: 1800, value: 55),
          WaveformKeyframe(timeMs: 2700, value: 82),
          WaveformKeyframe(timeMs: 3600, value: 20),
          WaveformKeyframe(timeMs: 3600, value: 20),
          WaveformKeyframe(timeMs: 3600, value: 20),
          WaveformKeyframe(timeMs: 3600, value: 20),
        ],
      ),
      _buildDebugWaveform(
        name: '晨露微光',
        channel: WaveformChannel.swing,
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
      _buildDebugWaveform(
        name: '溪流潺潺',
        channel: WaveformChannel.swing,
        durationMs: 2200,
        keyframes: const [
          WaveformKeyframe(timeMs: 0, value: 0),
          WaveformKeyframe(timeMs: 350, value: 88),
          WaveformKeyframe(timeMs: 700, value: 0),
          WaveformKeyframe(timeMs: 1050, value: 88),
          WaveformKeyframe(timeMs: 1400, value: 0),
          WaveformKeyframe(timeMs: 1750, value: 88),
          WaveformKeyframe(timeMs: 2200, value: 0),
        ],
      ),
      _buildDebugWaveform(
        name: '丝绸摩挲',
        channel: WaveformChannel.swing,
        durationMs: 2800,
        keyframes: const [
          WaveformKeyframe(timeMs: 0, value: 22),
          WaveformKeyframe(timeMs: 700, value: 68),
          WaveformKeyframe(timeMs: 1400, value: 22),
          WaveformKeyframe(timeMs: 2100, value: 68),
          WaveformKeyframe(timeMs: 2800, value: 22),
        ],
      ),
      _buildDebugWaveform(
        name: '深海潜流',
        channel: WaveformChannel.swing,
        durationMs: 3000,
        keyframes: const [
          WaveformKeyframe(timeMs: 0, value: 10),
          WaveformKeyframe(timeMs: 600, value: 22),
          WaveformKeyframe(timeMs: 1200, value: 40),
          WaveformKeyframe(timeMs: 1800, value: 62),
          WaveformKeyframe(timeMs: 2400, value: 88),
          WaveformKeyframe(timeMs: 3000, value: 18),
        ],
      ),
      _buildDebugWaveform(
        name: '耳鬓斯磨',
        channel: WaveformChannel.swing,
        durationMs: 3000,
        keyframes: const [
          WaveformKeyframe(timeMs: 0, value: 90),
          WaveformKeyframe(timeMs: 600, value: 72),
          WaveformKeyframe(timeMs: 1200, value: 54),
          WaveformKeyframe(timeMs: 1800, value: 36),
          WaveformKeyframe(timeMs: 2400, value: 24),
          WaveformKeyframe(timeMs: 3000, value: 12),
        ],
      ),
      _buildDebugWaveform(
        name: '钟摆催眠',
        channel: WaveformChannel.swing,
        durationMs: 2400,
        keyframes: const [
          WaveformKeyframe(timeMs: 0, value: 0),
          WaveformKeyframe(timeMs: 300, value: 82),
          WaveformKeyframe(timeMs: 600, value: 30),
          WaveformKeyframe(timeMs: 900, value: 100),
          WaveformKeyframe(timeMs: 1200, value: 20),
          WaveformKeyframe(timeMs: 2400, value: 0),
        ],
      ),
      _buildDebugWaveform(
        name: '琴弦共鸣',
        channel: WaveformChannel.swing,
        durationMs: 3600,
        keyframes: const [
          WaveformKeyframe(timeMs: 0, value: 18),
          WaveformKeyframe(timeMs: 600, value: 64),
          WaveformKeyframe(timeMs: 1200, value: 26),
          WaveformKeyframe(timeMs: 1800, value: 78),
          WaveformKeyframe(timeMs: 2400, value: 30),
          WaveformKeyframe(timeMs: 3000, value: 92),
          WaveformKeyframe(timeMs: 3600, value: 18),
        ],
      ),
      _buildDebugWaveform(
        name: '惊涛骇浪',
        channel: WaveformChannel.swing,
        durationMs: 2600,
        keyframes: const [
          WaveformKeyframe(timeMs: 0, value: 18),
          WaveformKeyframe(timeMs: 450, value: 86),
          WaveformKeyframe(timeMs: 900, value: 28),
          WaveformKeyframe(timeMs: 1350, value: 72),
          WaveformKeyframe(timeMs: 1800, value: 24),
          WaveformKeyframe(timeMs: 2250, value: 92),
          WaveformKeyframe(timeMs: 2600, value: 18),
        ],
      ),
      _buildDebugWaveform(
        name: '陨石坠落',
        channel: WaveformChannel.swing,
        durationMs: 3400,
        keyframes: const [
          WaveformKeyframe(timeMs: 0, value: 12),
          WaveformKeyframe(timeMs: 680, value: 58),
          WaveformKeyframe(timeMs: 1360, value: 88),
          WaveformKeyframe(timeMs: 2040, value: 52),
          WaveformKeyframe(timeMs: 2720, value: 76),
          WaveformKeyframe(timeMs: 3400, value: 12),
        ],
      ),
    ];
  }

  List<Waveform> _buildVibrationDebugWaveforms() {
    return [
      _buildDebugWaveform(
        name: '星夜呢喃',
        channel: WaveformChannel.vibration,
        durationMs: 3200,
        keyframes: const [
          WaveformKeyframe(timeMs: 0, value: 20),
          WaveformKeyframe(timeMs: 800, value: 36),
          WaveformKeyframe(timeMs: 1600, value: 26),
          WaveformKeyframe(timeMs: 2400, value: 40),
          WaveformKeyframe(timeMs: 2400, value: 40),
          WaveformKeyframe(timeMs: 2400, value: 40),
          WaveformKeyframe(timeMs: 2400, value: 40),
          WaveformKeyframe(timeMs: 2400, value: 40),
          WaveformKeyframe(timeMs: 3200, value: 20),
        ],
      ),
      _buildDebugWaveform(
        name: '绵绵细雨',
        channel: WaveformChannel.vibration,
        durationMs: 1800,
        keyframes: const [
          WaveformKeyframe(timeMs: 0, value: 0),
          WaveformKeyframe(timeMs: 300, value: 92),
          WaveformKeyframe(timeMs: 600, value: 0),
          WaveformKeyframe(timeMs: 900, value: 92),
          WaveformKeyframe(timeMs: 1200, value: 0),
          WaveformKeyframe(timeMs: 1500, value: 92),
          WaveformKeyframe(timeMs: 1800, value: 0),
          WaveformKeyframe(timeMs: 1800, value: 0),
          WaveformKeyframe(timeMs: 1800, value: 100),
          WaveformKeyframe(timeMs: 1800, value: 100),
          WaveformKeyframe(timeMs: 1800, value: 100),
        ],
      ),
      _buildDebugWaveform(
        name: '潮汐呼吸',
        channel: WaveformChannel.vibration,
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
        name: '麦浪起伏',
        channel: WaveformChannel.vibration,
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
      _buildDebugWaveform(
        name: '心跳同频',
        channel: WaveformChannel.vibration,
        durationMs: 1600,
        keyframes: const [
          WaveformKeyframe(timeMs: 0, value: 35),
          WaveformKeyframe(timeMs: 200, value: 85),
          WaveformKeyframe(timeMs: 400, value: 30),
          WaveformKeyframe(timeMs: 600, value: 90),
          WaveformKeyframe(timeMs: 800, value: 32),
          WaveformKeyframe(timeMs: 1000, value: 92),
          WaveformKeyframe(timeMs: 1200, value: 34),
          WaveformKeyframe(timeMs: 1600, value: 35),
        ],
      ),
      _buildDebugWaveform(
        name: '指尖魔法',
        channel: WaveformChannel.vibration,
        durationMs: 2400,
        keyframes: const [
          WaveformKeyframe(timeMs: 0, value: 18),
          WaveformKeyframe(timeMs: 400, value: 62),
          WaveformKeyframe(timeMs: 800, value: 18),
          WaveformKeyframe(timeMs: 1200, value: 78),
          WaveformKeyframe(timeMs: 1600, value: 18),
          WaveformKeyframe(timeMs: 2000, value: 92),
          WaveformKeyframe(timeMs: 2400, value: 18),
        ],
      ),
      _buildDebugWaveform(
        name: '极光爆发',
        channel: WaveformChannel.vibration,
        durationMs: 2600,
        keyframes: const [
          WaveformKeyframe(timeMs: 0, value: 0),
          WaveformKeyframe(timeMs: 500, value: 72),
          WaveformKeyframe(timeMs: 900, value: 0),
          WaveformKeyframe(timeMs: 1400, value: 72),
          WaveformKeyframe(timeMs: 1800, value: 0),
          WaveformKeyframe(timeMs: 2300, value: 72),
          WaveformKeyframe(timeMs: 2600, value: 0),
        ],
      ),
      _buildDebugWaveform(
        name: '荒原疾驰',
        channel: WaveformChannel.vibration,
        durationMs: 1400,
        keyframes: const [
          WaveformKeyframe(timeMs: 0, value: 42),
          WaveformKeyframe(timeMs: 175, value: 88),
          WaveformKeyframe(timeMs: 350, value: 44),
          WaveformKeyframe(timeMs: 525, value: 90),
          WaveformKeyframe(timeMs: 700, value: 46),
          WaveformKeyframe(timeMs: 875, value: 92),
          WaveformKeyframe(timeMs: 1050, value: 48),
          WaveformKeyframe(timeMs: 1400, value: 42),
        ],
      ),
      _buildDebugWaveform(
        name: '骤雨拍打',
        channel: WaveformChannel.vibration,
        durationMs: 3000,
        keyframes: const [
          WaveformKeyframe(timeMs: 0, value: 16),
          WaveformKeyframe(timeMs: 600, value: 48),
          WaveformKeyframe(timeMs: 1200, value: 82),
          WaveformKeyframe(timeMs: 1800, value: 38),
          WaveformKeyframe(timeMs: 2400, value: 70),
          WaveformKeyframe(timeMs: 3000, value: 16),
        ],
      ),
      _buildDebugWaveform(
        name: '暗潮低鸣',
        channel: WaveformChannel.vibration,
        durationMs: 2000,
        keyframes: const [
          WaveformKeyframe(timeMs: 0, value: 12),
          WaveformKeyframe(timeMs: 300, value: 100),
          WaveformKeyframe(timeMs: 700, value: 20),
          WaveformKeyframe(timeMs: 1100, value: 100),
          WaveformKeyframe(timeMs: 1500, value: 28),
          WaveformKeyframe(timeMs: 2000, value: 12),
        ],
      ),
      _buildDebugWaveform(
        name: '萤火微光',
        channel: WaveformChannel.vibration,
        durationMs: 3600,
        keyframes: const [
          WaveformKeyframe(timeMs: 0, value: 10),
          WaveformKeyframe(timeMs: 900, value: 35),
          WaveformKeyframe(timeMs: 1800, value: 68),
          WaveformKeyframe(timeMs: 2700, value: 35),
          WaveformKeyframe(timeMs: 3600, value: 10),
        ],
      ),
      _buildDebugWaveform(
        name: '蜻蜓点水',
        channel: WaveformChannel.vibration,
        durationMs: 3200,
        keyframes: const [
          WaveformKeyframe(timeMs: 0, value: 24),
          WaveformKeyframe(timeMs: 500, value: 76),
          WaveformKeyframe(timeMs: 1000, value: 28),
          WaveformKeyframe(timeMs: 1500, value: 84),
          WaveformKeyframe(timeMs: 2000, value: 32),
          WaveformKeyframe(timeMs: 2600, value: 92),
          WaveformKeyframe(timeMs: 3200, value: 24),
        ],
      ),
    ];
  }

  List<WaveformKeyframe> _normalizeKeyframes(List<WaveformKeyframe> keyframes) {
    if (keyframes.isEmpty) {
      return const [];
    }

    final deduplicatedByTime = <int, WaveformKeyframe>{};
    for (final keyframe in keyframes) {
      deduplicatedByTime[keyframe.timeMs] = keyframe;
    }

    final normalized = deduplicatedByTime.values.toList()
      ..sort((a, b) => a.timeMs.compareTo(b.timeMs));
    return normalized;
  }

  Waveform _buildDebugWaveform({
    required String name,
    required WaveformChannel channel,
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
      channel: WaveformChannel.values.byName(row.waveform.channel),
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
