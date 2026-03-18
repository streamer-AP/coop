import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/user_tables.dart';

part 'user_dao.g.dart';

@DriftAccessor(tables: [UserPreferences, DeviceBindings, CachedPermissions])
class UserDao extends DatabaseAccessor<AppDatabase> with _$UserDaoMixin {
  UserDao(super.db);

  // --- 设备绑定 ---

  Future<DeviceBinding?> getActiveDeviceBinding() =>
      (select(deviceBindings)..where((t) => t.isActive.equals(true)))
          .getSingleOrNull();

  Future<List<DeviceBinding>> getAllDeviceBindings() =>
      (select(deviceBindings)
            ..orderBy([(t) => OrderingTerm.desc(t.boundAt)]))
          .get();

  Future<void> saveDeviceBinding(DeviceBindingsCompanion binding) async {
    await into(deviceBindings).insertOnConflictUpdate(binding);
  }

  Future<void> deactivateAllBindings() async {
    await update(deviceBindings).write(
      const DeviceBindingsCompanion(isActive: Value(false)),
    );
  }

  // --- 用户偏好 ---

  Future<String?> getPreference(String key) async {
    final row =
        await (select(userPreferences)..where((t) => t.key.equals(key)))
            .getSingleOrNull();
    return row?.value;
  }

  Future<void> setPreference(String key, String value) =>
      into(userPreferences).insertOnConflictUpdate(
        UserPreferencesCompanion.insert(key: key, value: value),
      );
}
