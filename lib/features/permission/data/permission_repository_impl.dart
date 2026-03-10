import '../../../core/network/api_client.dart';
import '../../../core/database/daos/user_dao.dart';
import '../domain/models/permission_code.dart';
import '../domain/repositories/permission_repository.dart';

class PermissionRepositoryImpl implements PermissionRepository {
  final ApiClient _apiClient;
  final UserDao _userDao;

  PermissionRepositoryImpl(this._apiClient, this._userDao);

  @override
  Future<List<PermissionCode>> getPermissions() async {
    // TODO: implement
    throw UnimplementedError();
  }

  @override
  Future<bool> checkPermission(String code) async {
    // TODO: implement
    throw UnimplementedError();
  }

  @override
  Future<void> activatePermission(String code) async {
    // TODO: implement
  }

  @override
  Future<void> bindDevice(String deviceId) async {
    // TODO: implement
  }
}
