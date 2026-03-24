import '../models/waveform.dart';
import '../models/favorite_slot.dart';
import '../models/device_binding.dart';
import '../models/usage_log.dart';

abstract class ControllerRepository {
  // --- 波形 CRUD ---
  Future<List<Waveform>> getAllWaveforms();
  Future<List<Waveform>> getWaveformsByChannel(WaveformChannel channel);
  Future<Waveform?> getWaveformById(int id);
  Future<int> saveWaveform(Waveform waveform);
  Future<void> deleteWaveform(int id);

  // --- 常用波形配置（每通道 12 槽位）---
  Future<List<FavoriteSlot>> getAllFavoriteSlots();
  Future<List<FavoriteSlot>> getFavoriteSlotsByChannel(WaveformChannel channel);
  Future<void> setFavoriteSlot(FavoriteSlot slot);
  Future<void> removeFavoriteSlot({
    required WaveformChannel channel,
    required int page,
    required int index,
  });
  Future<void> reorderFavoriteSlotsOnPage(
    WaveformChannel channel,
    int page,
    List<FavoriteSlot> slots,
  );

  // --- 设备绑定 ---
  Future<DeviceBinding?> getActiveDeviceBinding();
  Future<List<DeviceBinding>> getAllDeviceBindings();
  Future<void> saveDeviceBinding(DeviceBinding binding);
  Future<void> deactivateAllBindings();

  // --- 使用日志 ---
  Future<void> insertUsageLog(UsageLog log);
  Future<List<UsageLog>> getUnsynced();
  Future<void> markSynced(List<int> ids);

  // --- 云同步 ---
  Future<void> syncToCloud();
  Future<void> syncFromCloud();
}
