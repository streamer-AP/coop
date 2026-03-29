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
      orderedNames:
          swingDebugWaveforms.map((waveform) => waveform.name).toList(),
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
    final existingByKey = <String, Waveform>{
      for (final waveform in existingWaveforms)
        '${waveform.channel.name}::${waveform.name}': waveform,
    };

    for (final waveform in debugWaveforms) {
      final key = '${waveform.channel.name}::${waveform.name}';
      final existing = existingByKey[key];
      if (existing == null) {
        final waveformId = await saveWaveform(waveform);
        existingByKey[key] = waveform.copyWith(id: waveformId);
        continue;
      }

      if (!_shouldSyncDebugWaveform(existing, waveform)) {
        continue;
      }

      final syncedWaveform = waveform.copyWith(id: existing.id);
      await saveWaveform(syncedWaveform);
      existingByKey[key] = syncedWaveform;
    }
  }

  bool _shouldSyncDebugWaveform(Waveform existing, Waveform desired) {
    if (existing.durationMs != desired.durationMs ||
        existing.signalIntervalMs != desired.signalIntervalMs ||
        existing.signalDelayMs != desired.signalDelayMs ||
        existing.isBuiltIn != desired.isBuiltIn) {
      return true;
    }

    if (existing.keyframes.length != desired.keyframes.length) {
      return true;
    }

    for (var index = 0; index < existing.keyframes.length; index++) {
      final existingKeyframe = existing.keyframes[index];
      final desiredKeyframe = desired.keyframes[index];
      if (existingKeyframe.timeMs != desiredKeyframe.timeMs ||
          existingKeyframe.value != desiredKeyframe.value) {
        return true;
      }
    }

    return false;
  }

  Future<void> _ensureDefaultFavoriteSlots({
    required WaveformChannel channel,
    required List<Waveform> waveforms,
    required List<db.FavoriteSlot> existingSlots,
    required List<String> orderedNames,
  }) async {
    final channelSlots =
        existingSlots.where((slot) => slot.channel == channel.name).toList();
    final occupiedPositions =
        channelSlots.map((slot) => '${slot.page}:${slot.slotIndex}').toSet();
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

    final availableWaveforms =
        orderedWaveforms
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
      _buildDebugWaveformFromSliderValues(
        name: '羽毛轻扫',
        channel: WaveformChannel.swing,
        sliderValues: const [
          [26, 26, 28, 30, 32, 34, 36, 38],
          [40, 38, 36, 34, 32, 30, 28, 26],
          [26, 28, 30, 32, 30, 28, 26, 26],
          [26, 0, 0, 0, 0, 0, 0, 0],
        ],
      ),
      _buildDebugWaveformFromSliderValues(
        name: '深海呼吸',
        channel: WaveformChannel.swing,
        sliderValues: const [
          [26, 28, 30, 32, 34, 36, 38, 40],
          [42, 44, 46, 46, 44, 42, 40, 38],
          [36, 34, 32, 30, 28, 26, 26, 0],
        ],
      ),
      _buildDebugWaveformFromSliderValues(
        name: '午后清风',
        channel: WaveformChannel.swing,
        sliderValues: const [
          [26, 29, 28, 31, 30, 33, 32, 35],
          [34, 37, 36, 34, 32, 33, 30, 31],
          [28, 29, 26, 26, 0, 0, 0, 0],
        ],
      ),
      _buildDebugWaveformFromSliderValues(
        name: '晨露微光',
        channel: WaveformChannel.swing,
        sliderValues: const [
          [26, 26, 28, 28, 30, 30, 32, 34],
          [36, 38, 40, 42, 42, 40, 38, 36],
          [34, 32, 30, 30, 28, 28, 26, 26],
        ],
      ),
      _buildDebugWaveformFromSliderValues(
        name: '溪流潺潺',
        channel: WaveformChannel.swing,
        sliderValues: const [
          [26, 28, 30, 32, 34, 36, 38, 36],
          [38, 40, 38, 36, 34, 32, 30, 28],
          [26, 26, 26, 0, 0, 0, 0, 0],
        ],
      ),
      _buildDebugWaveformFromSliderValues(
        name: '丝绸摩挲',
        channel: WaveformChannel.swing,
        sliderValues: const [
          [26, 28, 30, 32, 34, 36, 38, 40],
          [40, 38, 36, 34, 32, 30, 28, 26],
          [26, 26, 0, 0, 0, 0, 0, 0],
        ],
      ),
      _buildDebugWaveformFromSliderValues(
        name: '深海潜流',
        channel: WaveformChannel.swing,
        sliderValues: const [
          [26, 28, 30, 32, 34, 36, 38, 40],
          [42, 40, 38, 36, 34, 32, 30, 28],
        ],
      ),
      _buildDebugWaveformFromSliderValues(
        name: '耳鬓斯磨',
        channel: WaveformChannel.swing,
        sliderValues: const [
          [26, 28, 30, 34, 38, 40, 42, 42],
          [40, 38, 34, 30, 28, 26, 26, 0],
        ],
      ),
      _buildDebugWaveformFromSliderValues(
        name: '钟摆催眠',
        channel: WaveformChannel.swing,
        sliderValues: const [
          [26, 30, 34, 38, 40, 42, 40, 38],
          [34, 30, 26, 26, 26, 26, 0, 0],
        ],
      ),
      _buildDebugWaveformFromSliderValues(
        name: '琴弦共鸣',
        channel: WaveformChannel.swing,
        sliderValues: const [
          [26, 32, 38, 42, 40, 36, 30, 28],
          [30, 36, 40, 38, 32, 0, 0, 0],
        ],
      ),
      _buildDebugWaveformFromSliderValues(
        name: '惊涛骇浪',
        channel: WaveformChannel.swing,
        sliderValues: const [
          [26, 30, 40, 50, 46, 36, 30, 40],
          [55, 46, 36, 26, 0, 0, 0, 0],
        ],
      ),
      _buildDebugWaveformFromSliderValues(
        name: '陨石坠落',
        channel: WaveformChannel.swing,
        sliderValues: const [
          [26, 30, 34, 40, 46, 52, 46, 34],
          [26, 26, 0, 0, 0, 0, 0, 0],
        ],
      ),
    ];
  }

  List<Waveform> _buildVibrationDebugWaveforms() {
    return [
      _buildDebugWaveformFromSliderValues(
        name: '星夜呢喃',
        channel: WaveformChannel.vibration,
        sliderValues: const [
          [28, 28, 28, 30, 30, 32, 32, 32],
          [30, 30, 28, 28, 28, 28, 30, 30],
          [32, 32, 32, 30, 30, 28, 28, 28],
          [28, 0, 0, 0, 0, 0, 0, 0],
        ],
      ),
      _buildDebugWaveformFromSliderValues(
        name: '绵绵细雨',
        channel: WaveformChannel.vibration,
        sliderValues: const [
          [26, 34, 26, 38, 28, 36, 26, 40],
          [30, 34, 26, 38, 28, 36, 26, 40],
          [30, 34, 26, 38, 28, 36, 26, 34],
        ],
      ),
      _buildDebugWaveformFromSliderValues(
        name: '潮汐呼吸',
        channel: WaveformChannel.vibration,
        sliderValues: const [
          [26, 28, 30, 32, 34, 36, 38, 40],
          [42, 44, 46, 46, 44, 42, 40, 38],
          [36, 34, 32, 30, 28, 26, 26, 0],
        ],
      ),
      _buildDebugWaveformFromSliderValues(
        name: '麦浪起伏',
        channel: WaveformChannel.vibration,
        sliderValues: const [
          [26, 30, 34, 38, 34, 30, 26, 30],
          [34, 38, 34, 30, 26, 30, 34, 38],
          [34, 30, 26, 26, 0, 0, 0, 0],
        ],
      ),
      _buildDebugWaveformFromSliderValues(
        name: '心跳同频',
        channel: WaveformChannel.vibration,
        sliderValues: const [
          [26, 50, 26, 26, 44, 26, 26, 26],
          [50, 26, 26, 44, 26, 26, 26, 26],
          [26, 0, 0, 0, 0, 0, 0, 0],
        ],
      ),
      _buildDebugWaveformFromSliderValues(
        name: '指尖魔法',
        channel: WaveformChannel.vibration,
        sliderValues: const [
          [26, 26, 58, 26, 26, 58, 26, 26],
          [58, 26, 26, 58, 26, 26, 58, 26],
        ],
      ),
      _buildDebugWaveformFromSliderValues(
        name: '极光爆发',
        channel: WaveformChannel.vibration,
        sliderValues: const [
          [26, 30, 34, 38, 42, 46, 52, 58],
          [64, 70, 64, 58, 52, 46, 38, 0],
        ],
      ),
      _buildDebugWaveformFromSliderValues(
        name: '荒原疾驰',
        channel: WaveformChannel.vibration,
        sliderValues: const [
          [26, 46, 42, 50, 44, 52, 46, 50],
          [44, 52, 46, 50, 44, 26, 0, 0],
        ],
      ),
      _buildDebugWaveformFromSliderValues(
        name: '骤雨拍打',
        channel: WaveformChannel.vibration,
        sliderValues: const [
          [26, 70, 26, 58, 26, 78, 26, 50],
          [26, 74, 26, 54, 26, 0, 0, 0],
        ],
      ),
      _buildDebugWaveformFromSliderValues(
        name: '暗潮低鸣',
        channel: WaveformChannel.vibration,
        sliderValues: const [
          [26, 30, 34, 38, 40, 42, 42, 40],
          [38, 34, 30, 26, 0, 0, 0, 0],
        ],
      ),
      _buildDebugWaveformFromSliderValues(
        name: '萤火微光',
        channel: WaveformChannel.vibration,
        sliderValues: const [
          [26, 26, 26, 52, 26, 26, 46, 26],
          [26, 58, 26, 26, 42, 26, 26, 52],
          [26, 26, 26, 0, 0, 0, 0, 0],
        ],
      ),
      _buildDebugWaveformFromSliderValues(
        name: '蜻蜓点水',
        channel: WaveformChannel.vibration,
        sliderValues: const [
          [26, 78, 26, 26, 26, 72, 26, 26],
          [26, 82, 26, 0, 0, 0, 0, 0],
        ],
      ),
    ];
  }

  Waveform _buildDebugWaveformFromSliderValues({
    required String name,
    required WaveformChannel channel,
    required List<List<int>> sliderValues,
  }) {
    final keyframes = <WaveformKeyframe>[];
    var timeMs = 1000;

    for (final sliderRow in sliderValues) {
      for (final value in sliderRow) {
        keyframes.add(WaveformKeyframe(timeMs: timeMs, value: value));
        timeMs += 1000;
      }
    }

    return _buildDebugWaveform(
      name: name,
      channel: channel,
      durationMs: keyframes.length * 1000,
      keyframes: keyframes,
    );
  }

  List<WaveformKeyframe> _normalizeKeyframes(List<WaveformKeyframe> keyframes) {
    if (keyframes.isEmpty) {
      return const [];
    }

    final deduplicatedByTime = <int, WaveformKeyframe>{};
    for (final keyframe in keyframes) {
      deduplicatedByTime[keyframe.timeMs] = keyframe;
    }

    final normalized =
        deduplicatedByTime.values.toList()
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
