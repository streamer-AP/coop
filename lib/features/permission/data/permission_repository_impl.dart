import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../domain/models/permission_code.dart';
import '../domain/repositories/permission_repository.dart';

class PermissionRepositoryImpl implements PermissionRepository {
  final ApiClient _apiClient;

  PermissionRepositoryImpl(this._apiClient);

  @override
  Future<List<PermissionCode>> getPermissions() async {
    final json = await _apiClient.get(ApiEndpoints.permissions);
    final code = json['code'] as int?;
    final data = json['data'] as List<dynamic>?;
    if (code != 200 || data == null) return [];
    return data
        .map((e) => PermissionCode.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<bool> checkPermission(String code) async {
    final permissions = await getPermissions();
    return permissions.any((p) => p.code == code && p.isGranted);
  }

  @override
  Future<void> activatePermission(String code) async {
    final json = await _apiClient.post(
      ApiEndpoints.redeemCode,
      data: {'redeemCode': code},
    );
    final respCode = json['code'] as int?;
    if (respCode != 200) {
      final message = json['message'] as String? ?? '激活失败';
      throw Exception(message);
    }
  }

  @override
  Future<void> bindDevice(String deviceId) async {
    final json = await _apiClient.post(
      ApiEndpoints.userDevices,
      data: {'deviceId': deviceId},
    );
    final respCode = json['code'] as int?;
    if (respCode != 200) {
      final message = json['message'] as String? ?? '绑定失败';
      throw Exception(message);
    }
  }
}
