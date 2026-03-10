import '../models/permission_code.dart';

abstract class PermissionRepository {
  Future<List<PermissionCode>> getPermissions();
  Future<bool> checkPermission(String code);
  Future<void> activatePermission(String code);
  Future<void> bindDevice(String deviceId);
}
