import '../../../core/database/daos/controller_dao.dart';
import '../domain/models/waveform.dart';
import '../domain/models/favorite_slot.dart';
import '../domain/models/device_binding.dart';
import '../domain/models/usage_log.dart';
import '../domain/repositories/controller_repository.dart';

class ControllerRepositoryImpl implements ControllerRepository {
  final ControllerDao _dao;

  ControllerRepositoryImpl(this._dao);

  // --- 波形 CRUD ---

  @override
  Future<List<Waveform>> getAllWaveforms() async {
    // TODO: implement — 从 _dao 获取所有波形并转换为 domain 模型
    throw UnimplementedError();
  }

  @override
  Future<Waveform?> getWaveformById(int id) async {
    // TODO: implement
    throw UnimplementedError();
  }

  @override
  Future<int> saveWaveform(Waveform waveform) async {
    // TODO: implement — 保存波形及其 keyframes
    throw UnimplementedError();
  }

  @override
  Future<void> deleteWaveform(int id) async {
    // TODO: implement
    throw UnimplementedError();
  }

  // --- 常用波形配置 ---

  @override
  Future<List<FavoriteSlot>> getAllFavoriteSlots() async {
    // TODO: implement
    throw UnimplementedError();
  }

  @override
  Future<void> setFavoriteSlot(FavoriteSlot slot) async {
    // TODO: implement
    throw UnimplementedError();
  }

  @override
  Future<void> removeFavoriteSlot({
    required int page,
    required int index,
  }) async {
    // TODO: implement
    throw UnimplementedError();
  }

  @override
  Future<void> reorderFavoriteSlotsOnPage(
    int page,
    List<FavoriteSlot> slots,
  ) async {
    // TODO: implement
    throw UnimplementedError();
  }

  // --- 设备绑定 ---

  @override
  Future<DeviceBinding?> getActiveDeviceBinding() async {
    // TODO: implement
    throw UnimplementedError();
  }

  @override
  Future<List<DeviceBinding>> getAllDeviceBindings() async {
    // TODO: implement
    throw UnimplementedError();
  }

  @override
  Future<void> saveDeviceBinding(DeviceBinding binding) async {
    // TODO: implement
    throw UnimplementedError();
  }

  @override
  Future<void> deactivateAllBindings() async {
    // TODO: implement
    throw UnimplementedError();
  }

  // --- 使用日志 ---

  @override
  Future<void> insertUsageLog(UsageLog log) async {
    // TODO: implement
    throw UnimplementedError();
  }

  @override
  Future<List<UsageLog>> getUnsynced() async {
    // TODO: implement
    throw UnimplementedError();
  }

  @override
  Future<void> markSynced(List<int> ids) async {
    // TODO: implement
    throw UnimplementedError();
  }

  // --- 云同步 ---

  @override
  Future<void> syncToCloud() async {
    // TODO: implement
    throw UnimplementedError();
  }

  @override
  Future<void> syncFromCloud() async {
    // TODO: implement
    throw UnimplementedError();
  }
}
