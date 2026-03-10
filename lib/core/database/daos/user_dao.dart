import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/user_tables.dart';

part 'user_dao.g.dart';

@DriftAccessor(tables: [UserPreferences, DeviceBindings, CachedPermissions])
class UserDao extends DatabaseAccessor<AppDatabase> with _$UserDaoMixin {
  UserDao(super.db);

  // TODO: implement CRUD operations
}
