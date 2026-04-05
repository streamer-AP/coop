import '../../../core/bluetooth/ble_connection_manager.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../domain/models/permission_code.dart';
import '../domain/repositories/permission_repository.dart';

class PermissionRepositoryImpl implements PermissionRepository {
  final ApiClient _apiClient;
  final BleConnectionManager? _bleConnectionManager;

  PermissionRepositoryImpl(this._apiClient, {BleConnectionManager? bleManager})
      : _bleConnectionManager = bleManager;

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
    // 获取当前用户 omaoId，服务端创建设备关联时需要该字段。
    String? omaoId;
    try {
      final userJson = await _apiClient.get(ApiEndpoints.getCurrentUserInfo);
      final userData = userJson['data'] as Map<String, dynamic>?;
      if (userData != null) {
        omaoId = userData['omaoId'] as String?;
      }
    } catch (_) {}

    final data = <String, dynamic>{'redeemCode': code};
    if (omaoId != null && omaoId.isNotEmpty) {
      data['omaoId'] = omaoId;
    }
    // 服务端需要 deviceSn 字段，从已连接蓝牙设备读取序列号
    final deviceSn = _bleConnectionManager?.deviceSerialNumber;
    if (deviceSn != null && deviceSn.isNotEmpty) {
      data['deviceSn'] = deviceSn;
    }

    final json = await _apiClient.post(
      ApiEndpoints.redeemCode,
      data: data,
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
