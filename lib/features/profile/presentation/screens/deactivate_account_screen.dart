import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/purple_gradient_button.dart';
import '../../../../shared/widgets/verification_code_input.dart';
import '../../../auth/application/providers/auth_providers.dart';
import '../../../resonance/application/providers/resonance_providers.dart';
import '../../../resonance/application/services/export_service.dart';
import '../../application/providers/profile_providers.dart';

class DeactivateAccountScreen extends ConsumerStatefulWidget {
  const DeactivateAccountScreen({super.key});

  @override
  ConsumerState<DeactivateAccountScreen> createState() =>
      _DeactivateAccountScreenState();
}

class _DeactivateAccountScreenState
    extends ConsumerState<DeactivateAccountScreen> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.profileBackgroundGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('注销账号'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              VerificationCodeInput(
                phoneController: _phoneController,
                codeController: _codeController,
                onSendCode:
                    () => ref
                        .read(profileRepositoryProvider)
                        .sendDeactivateCode(_phoneController.text),
              ),
              const SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: PurpleGradientButton(
                      text: '取消',
                      onPressed:
                          _isSubmitting
                              ? null
                              : () => Navigator.of(context).pop(),
                      enabled: !_isSubmitting,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap:
                          _isSubmitting ? null : () => _showExportDialog(context),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color:
                              _isSubmitting
                                  ? const Color(0xFFE2E2E2)
                                  : const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _isSubmitting ? '注销中...' : '确定注销',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (ctx) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '提示',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '是否要一键导出目前资源',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(ctx).pop();
                            _runDeactivationFlow(exportBeforeDeactivate: false);
                          },
                          child: Container(
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F0F0),
                              borderRadius: BorderRadius.circular(22),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              '直接注销',
                              style: TextStyle(
                                fontSize: 15,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(ctx).pop();
                            _runDeactivationFlow(exportBeforeDeactivate: true);
                          },
                          child: Container(
                            height: 44,
                            decoration: BoxDecoration(
                              gradient: AppColors.purpleButtonGradient,
                              borderRadius: BorderRadius.circular(22),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              '一键导出',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Future<void> _runDeactivationFlow({
    required bool exportBeforeDeactivate,
  }) async {
    if (_isSubmitting) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      if (exportBeforeDeactivate) {
        final exportPath = await _exportAllResources();
        if (!mounted) return;
        if (exportPath == null) {
          return;
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('导出成功')));
      }

      await ref
          .read(profileRepositoryProvider)
          .deactivateAccount(
            phone: _phoneController.text,
            code: _codeController.text,
          );
      if (!mounted) return;
      await ref
          .read(authNotifierProvider.notifier)
          .logout(purgeLocalData: true);
    } catch (e) {
      if (!mounted) return;
      final message = '$e'.replaceFirst('Exception: ', '').trim();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(content: Text(message.isEmpty ? '注销失败，请重试' : message)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<String?> _exportAllResources() async {
    final repo = ref.read(resonanceRepositoryProvider);
    final exportService = ExportService(repo);

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => const Center(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('正在打包导出...'),
                  ],
                ),
              ),
            ),
          ),
    );

    try {
      return await exportService.exportAll();
    } finally {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }
  }
}
