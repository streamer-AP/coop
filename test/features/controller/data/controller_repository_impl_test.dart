import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omao_app/core/database/app_database.dart' as db;
import 'package:omao_app/features/controller/data/controller_repository_impl.dart';
import 'package:omao_app/features/controller/domain/models/favorite_slot.dart';
import 'package:omao_app/features/controller/domain/models/waveform.dart';

void main() {
  late db.AppDatabase database;
  late ControllerRepositoryImpl repository;

  setUp(() {
    database = db.AppDatabase(NativeDatabase.memory());
    repository = ControllerRepositoryImpl(database.controllerDao, database.userDao);
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'persists a single-channel waveform with waveform-level timing',
    () async {
    const waveform = Waveform(
      id: 0,
      name: '羽毛轻扫',
      channel: WaveformChannel.swing,
        durationMs: 16000,
        signalIntervalMs: 250,
        signalDelayMs: 20,
        isBuiltIn: false,
        keyframes: const [
          WaveformKeyframe(timeMs: 0, value: 15),
          WaveformKeyframe(timeMs: 1000, value: 48),
          WaveformKeyframe(timeMs: 2000, value: 72),
        ],
      );

      final id = await repository.saveWaveform(waveform);
      final saved = await repository.getWaveformById(id);

      expect(saved, isNotNull);
      expect(saved!.channel, WaveformChannel.swing);
      expect(saved.signalIntervalMs, 250);
      expect(saved.signalDelayMs, 20);
      expect(saved.keyframes.map((frame) => frame.value), [15, 48, 72]);
    },
  );

  test('stores favorite slots independently for swing and vibration', () async {
    final swingId = await repository.saveWaveform(
      const Waveform(
        id: 0,
        name: '钟摆催眠',
        channel: WaveformChannel.swing,
        keyframes: [WaveformKeyframe(timeMs: 0, value: 30)],
      ),
    );
    final vibrationId = await repository.saveWaveform(
      const Waveform(
        id: 0,
        name: '丝绒摩挲',
        channel: WaveformChannel.vibration,
        keyframes: [WaveformKeyframe(timeMs: 0, value: 40)],
      ),
    );

    await repository.setFavoriteSlot(
      FavoriteSlot(
        channel: WaveformChannel.swing,
        page: 0,
        index: 0,
        waveformId: swingId,
      ),
    );
    await repository.setFavoriteSlot(
      FavoriteSlot(
        channel: WaveformChannel.vibration,
        page: 0,
        index: 0,
        waveformId: vibrationId,
      ),
    );

    final slots = await repository.getAllFavoriteSlots();
    final swingSlot = slots.singleWhere(
      (slot) => slot.channel == WaveformChannel.swing,
    );
    final vibrationSlot = slots.singleWhere(
      (slot) => slot.channel == WaveformChannel.vibration,
    );

    expect(slots, hasLength(2));
    expect(swingSlot.waveformId, swingId);
    expect(vibrationSlot.waveformId, vibrationId);
  });
}
