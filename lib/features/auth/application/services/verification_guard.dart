import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/verification_status.dart';
import '../providers/auth_providers.dart';
import '../../presentation/widgets/identity_input_dialog.dart';
import '../../presentation/widgets/verification_prompt_dialog.dart';
import '../../presentation/widgets/verification_result_dialog.dart';

class VerificationGuard {
  static Future<bool> check(BuildContext context, WidgetRef ref) async {
    final user = ref.read(authNotifierProvider).valueOrNull;

    if (user == null) return false;

    if (user.verificationStatus == VerificationStatus.verified) {
      return true;
    }

    if (user.verificationStatus == VerificationStatus.underage) {
      if (!context.mounted) return false;
      await VerificationResultDialog.showUnderage(context);
      return false;
    }

    // Show prompt dialog
    if (!context.mounted) return false;
    final shouldVerify = await VerificationPromptDialog.show(context);
    if (shouldVerify != true) return false;

    // Show identity input dialog
    if (!context.mounted) return false;
    final identityData = await IdentityInputDialog.show(context);
    if (identityData == null) return false;

    // Perform verification
    final result = await ref.read(authNotifierProvider.notifier).verifyIdentity(
          name: identityData.name,
          idNumber: identityData.idNumber,
        );

    if (!context.mounted) return false;

    switch (result.status) {
      case VerificationStatus.verified:
        await VerificationResultDialog.showSuccess(context);
        return true;
      case VerificationStatus.underage:
        await VerificationResultDialog.showUnderage(context);
        return false;
      case VerificationStatus.failed:
        await VerificationResultDialog.showFailed(context);
        return false;
      case VerificationStatus.unverified:
        return false;
    }
  }
}
