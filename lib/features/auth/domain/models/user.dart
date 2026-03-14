import 'package:freezed_annotation/freezed_annotation.dart';

import 'verification_status.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String phone,
    String? nickname,
    String? token,
    @Default(false) bool isVerified,
    @Default(false) bool needsPasswordSetup,
    @Default(VerificationStatus.unverified)
    VerificationStatus verificationStatus,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
