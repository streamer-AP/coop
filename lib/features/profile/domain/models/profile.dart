import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile.freezed.dart';
part 'profile.g.dart';

@freezed
class Profile with _$Profile {
  const factory Profile({
    required String userId,
    String? nickname,
    String? avatarUrl,
    String? phone,
    String? avatarPreset,
    @Default(false) bool isVerified,
    @Default([]) List<String> boundDeviceIds,
  }) = _Profile;

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);
}
