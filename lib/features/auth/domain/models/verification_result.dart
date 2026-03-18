import 'package:freezed_annotation/freezed_annotation.dart';

import 'verification_status.dart';

part 'verification_result.freezed.dart';
part 'verification_result.g.dart';

@freezed
class VerificationResult with _$VerificationResult {
  const factory VerificationResult({
    required VerificationStatus status,
    String? message,
  }) = _VerificationResult;

  factory VerificationResult.fromJson(Map<String, dynamic> json) =>
      _$VerificationResultFromJson(json);
}
