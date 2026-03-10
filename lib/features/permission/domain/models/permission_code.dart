import 'package:freezed_annotation/freezed_annotation.dart';

part 'permission_code.freezed.dart';
part 'permission_code.g.dart';

@freezed
class PermissionCode with _$PermissionCode {
  const factory PermissionCode({
    required String code,
    required bool isGranted,
    DateTime? grantedAt,
  }) = _PermissionCode;

  factory PermissionCode.fromJson(Map<String, dynamic> json) =>
      _$PermissionCodeFromJson(json);
}
