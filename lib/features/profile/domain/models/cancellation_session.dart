class CancellationSession {
  const CancellationSession({
    required this.id,
    required this.logId,
    required this.userId,
    required this.mobile,
    required this.accountStatus,
    required this.accountDeletedTimestamp,
    required this.operator,
    required this.verifiedStatus,
    required this.ipAddress,
    required this.ipInfo,
    required this.deviceModel,
    required this.deviceOs,
    required this.deviceType,
    required this.deviceInfo,
    required this.appInfo,
    required this.createdAt,
    this.success = 0,
    this.operationDetail = '',
  });

  factory CancellationSession.fromJson(Map<String, dynamic> json) {
    return CancellationSession(
      id: _toInt(json['id']),
      logId: _toInt(json['logId']),
      userId: _toInt(json['userId']),
      mobile: _toString(json['mobile']),
      accountStatus: _toInt(json['accountStatus']),
      accountDeletedTimestamp: _toString(json['accountDeletedTimestamp']),
      operator: _toString(json['operator']),
      verifiedStatus: _toInt(json['verifiedStatus']),
      ipAddress: _toString(json['ipAddress']),
      ipInfo: _toString(json['ipInfo']),
      deviceModel: _toString(json['deviceModel']),
      deviceOs: _toString(json['deviceOs']),
      deviceType: _toString(json['deviceType']),
      deviceInfo: _toString(json['deviceInfo']),
      appInfo: _toString(json['appInfo']),
      createdAt: _toString(json['createdAt']),
      success: _toInt(json['success']),
      operationDetail: _toString(json['operationDetail']),
    );
  }

  final int id;
  final int logId;
  final int userId;
  final String mobile;
  final int accountStatus;
  final String accountDeletedTimestamp;
  final String operator;
  final int verifiedStatus;
  final String ipAddress;
  final String ipInfo;
  final String deviceModel;
  final String deviceOs;
  final String deviceType;
  final String deviceInfo;
  final String appInfo;
  final String createdAt;
  final int success;
  final String operationDetail;

  Map<String, dynamic> toBasePayload() {
    return {
      'id': id,
      'logId': logId,
      'userId': userId,
      'mobile': mobile,
      'accountStatus': accountStatus,
      'accountDeletedTimestamp': accountDeletedTimestamp,
      'operator': operator,
      'verifiedStatus': verifiedStatus,
      'ipAddress': ipAddress,
      'ipInfo': ipInfo,
      'deviceModel': deviceModel,
      'deviceOs': deviceOs,
      'deviceType': deviceType,
      'deviceInfo': deviceInfo,
      'appInfo': appInfo,
      'createdAt': createdAt,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      ...toBasePayload(),
      'success': success,
      'operationDetail': operationDetail,
    };
  }

  Map<String, dynamic> toSendCodePayload() => toJson();

  Map<String, dynamic> toCancelPayload({
    required String verificationCode,
    required String timestamp,
  }) {
    return {
      'id': id,
      'logId': logId,
      'userId': userId,
      'mobile': mobile,
      'accountStatus': accountStatus,
      'verificationCode': verificationCode,
      'accountDeletedTimestamp': timestamp,
      'operator': operator,
      'ipAddress': ipAddress,
      'ipInfo': ipInfo,
      'deviceModel': deviceModel,
      'deviceOs': deviceOs,
      'deviceType': deviceType,
      'deviceInfo': deviceInfo,
      'appInfo': appInfo,
      'createdAt': createdAt,
      'updatedAt': timestamp,
      'deletedAt': timestamp,
      'deletedReason': 'user_requested',
    };
  }

  static int _toInt(Object? value) {
    if (value is int) {
      return value;
    }
    return int.tryParse(_toString(value)) ?? 0;
  }

  static String _toString(Object? value) {
    if (value == null) {
      return '';
    }
    final normalized = '$value'.trim();
    if (normalized.isEmpty || normalized == 'null') {
      return '';
    }
    return normalized;
  }
}
