import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../shared/widgets/omao_page_background.dart';
import '../../../auth/application/providers/auth_providers.dart';
import '../../../resonance/application/providers/resonance_providers.dart';
import '../../../resonance/application/services/export_service.dart';
import '../../domain/models/cancellation_session.dart';
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
  Timer? _countdownTimer;
  int _remainingSeconds = 0;
  bool _isSendingCode = false;
  bool _isSubmitting = false;
  CancellationSession? _cancellationSession;

  bool get _hasPhone => _phoneDigits.length == 11;
  bool get _hasCode => _codeController.text.trim().isNotEmpty;
  bool get _canSendCode =>
      !_isSubmitting && !_isSendingCode && _remainingSeconds == 0 && _hasPhone;
  bool get _canConfirm => !_isSubmitting && _hasPhone && _hasCode;

  String get _phoneDigits =>
      _phoneController.text.replaceAll(RegExp(r'\D'), '');

  void _clearCancellationSession({bool resetCountdown = false}) {
    _cancellationSession = null;
    if (resetCountdown) {
      _countdownTimer?.cancel();
      _remainingSeconds = 0;
    }
  }

  void _handlePhoneChanged(String _) {
    final session = _cancellationSession;
    setState(() {
      if (session != null && session.mobile != _phoneDigits) {
        _clearCancellationSession(resetCountdown: true);
      }
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OmaoPageBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: const Text(
            '注销账号',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Color(0xFF262333),
            ),
          ),
          leadingWidth: 68,
          leading: Padding(
            padding: const EdgeInsets.only(left: 18, top: 6, bottom: 6),
            child: Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.36),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: AppIcons.icon(
                    AppIcons.arrowLeft,
                    size: 16,
                    color: const Color(0xFF37324A),
                  ),
                ),
              ),
            ),
          ),
        ),
        body: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 36, 28, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _FieldLabel('输入手机号码'),
                const SizedBox(height: 14),
                _buildPhoneField(),
                const SizedBox(height: 24),
                const _FieldLabel('输入验证码'),
                const SizedBox(height: 14),
                _buildCodeField(),
                const SizedBox(height: 28),
                Center(
                  child: SizedBox(
                    width: 228,
                    child: _PrimaryActionButton(
                      text: '取消',
                      onTap:
                          _isSubmitting
                              ? null
                              : () => Navigator.of(context).pop(),
                      gradient: AppColors.purpleButtonGradient,
                      textColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: SizedBox(
                    width: 228,
                    child: _PrimaryActionButton(
                      text: _isSubmitting ? '注销中...' : '确定注销',
                      onTap: _canConfirm ? _handleDeactivatePressed : null,
                      backgroundColor: Colors.white.withValues(
                        alpha: _canConfirm ? 0.96 : 0.86,
                      ),
                      textColor: const Color(0xFFAAA6B6),
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              '+86',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Color(0xFF575466),
              ),
            ),
            const SizedBox(width: 7),
            Container(width: 1, height: 15, color: const Color(0xFF9F9AAC)),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                ],
                decoration: const InputDecoration(
                  isCollapsed: true,
                  hintText: '请输入手机号',
                  hintStyle: TextStyle(fontSize: 16, color: Color(0xFFB5B1C1)),
                  border: InputBorder.none,
                ),
                style: const TextStyle(fontSize: 16, color: Color(0xFF575466)),
                onChanged: _handlePhoneChanged,
              ),
            ),
            if (_phoneController.text.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _phoneController.clear();
                  setState(() {
                    _clearCancellationSession(resetCountdown: true);
                  });
                },
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: Color(0xFF918C9F),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.close, size: 13, color: Colors.white),
                ),
              ),
          ],
        ),
        const SizedBox(height: 11),
        Container(height: 1, color: const Color(0xFFC2BDD2)),
      ],
    );
  }

  Widget _buildCodeField() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                decoration: const InputDecoration(
                  isCollapsed: true,
                  hintText: '请输入验证码',
                  hintStyle: TextStyle(fontSize: 16, color: Color(0xFFB5B1C1)),
                  border: InputBorder.none,
                ),
                style: const TextStyle(fontSize: 16, color: Color(0xFF575466)),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _canSendCode ? _sendCode : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 100,
                height: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors:
                        _canSendCode
                            ? const [Color(0xFFC5B2EF), Color(0xFFAF98E4)]
                            : const [Color(0xFFD2C6EE), Color(0xFFC7BADF)],
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  _isSendingCode
                      ? '发送中...'
                      : _remainingSeconds > 0
                      ? '已发送(${_remainingSeconds}s)'
                      : '获取验证码',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFF7F2FF),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 11),
        Container(height: 1, color: const Color(0xFFC2BDD2)),
      ],
    );
  }

  Future<void> _sendCode() async {
    if (!_canSendCode) {
      return;
    }

    setState(() {
      _isSendingCode = true;
    });

    try {
      final session = await ref
          .read(profileRepositoryProvider)
          .sendDeactivateCode(_phoneController.text);
      if (!mounted) return;
      setState(() {
        _cancellationSession = session;
      });
      _startCountdown();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _clearCancellationSession();
      });
      final message = '$e'.replaceFirst('Exception: ', '').trim();
      _showMessage(message.isEmpty ? '验证码发送失败' : message);
    } finally {
      if (mounted) {
        setState(() {
          _isSendingCode = false;
        });
      }
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() {
      _remainingSeconds = 45;
    });
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _remainingSeconds -= 1;
        if (_remainingSeconds <= 0) {
          _remainingSeconds = 0;
          timer.cancel();
        }
      });
    });
  }

  Future<void> _handleDeactivatePressed() async {
    final session = _cancellationSession;
    if (session == null) {
      _showMessage('请先获取验证码');
      return;
    }
    if (session.mobile != _phoneDigits) {
      setState(() {
        _clearCancellationSession(resetCountdown: true);
      });
      _showMessage('手机号已变更，请重新获取验证码');
      return;
    }

    final exportChoice = await _showExportDecisionDialog();
    if (exportChoice == null || !mounted) {
      return;
    }

    if (!exportChoice) {
      final confirmed = await _showWarningDialog();
      if (confirmed != true || !mounted) {
        return;
      }
    }

    await _runDeactivationFlow(exportBeforeDeactivate: exportChoice);
  }

  Future<void> _runDeactivationFlow({
    required bool exportBeforeDeactivate,
  }) async {
    final session = _cancellationSession;
    if (session == null) {
      _showMessage('请先获取验证码');
      return;
    }

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

        final confirmed = await _showWarningDialog();
        if (confirmed != true || !mounted) {
          return;
        }
      }

      await ref
          .read(profileRepositoryProvider)
          .deactivateAccount(session: session, code: _codeController.text);
      if (!mounted) return;
      await ref
          .read(authNotifierProvider.notifier)
          .logout(purgeLocalData: true);
    } catch (e) {
      if (!mounted) return;
      final message = '$e'.replaceFirst('Exception: ', '').trim();
      _showMessage(message.isEmpty ? '注销失败，请重试' : message);
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<bool?> _showExportDecisionDialog() {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      builder:
          (ctx) => _PromptDialog(
            title: '提示',
            message: '是否要一键导出目前资源',
            leftLabel: '直接注销',
            rightLabel: '一键导出',
            onLeft: () => Navigator.of(ctx).pop(false),
            onRight: () => Navigator.of(ctx).pop(true),
          ),
    );
  }

  Future<bool?> _showWarningDialog() {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      builder:
          (ctx) => _PromptDialog(
            title: '提示',
            message: '注销之后，账号信息将无法恢复，\n请谨慎操作',
            leftLabel: '确定',
            rightLabel: '取消',
            leftFilled: false,
            rightFilled: true,
            onLeft: () => Navigator.of(ctx).pop(true),
            onRight: () => Navigator.of(ctx).pop(false),
          ),
    );
  }

  Future<String?> _exportAllResources() async {
    final repo = ref.read(resonanceRepositoryProvider);
    final exportService = ExportService(repo);

    final progressNotifier = ValueNotifier<(int, int)>((0, 0));

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      builder:
          (_) => Center(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: ValueListenableBuilder<(int, int)>(
                  valueListenable: progressNotifier,
                  builder: (_, progress, __) {
                    final current = progress.$1;
                    final total = progress.$2;
                    final ratio = total > 0 ? current / total : 0.0;
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '正在打包导出...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        LinearProgressIndicator(
                          value: total > 0 ? ratio : null,
                          backgroundColor: const Color(0xFFE0E0E0),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF6A53A7),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          total > 0
                              ? '$current / $total'
                              : '准备中...',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF797979),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
    );

    try {
      return await exportService.exportAll(
        onProgress: (current, total) {
          progressNotifier.value = (current, total);
        },
      );
    } finally {
      progressNotifier.dispose();
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Color(0xFF605C6E),
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({
    required this.text,
    required this.onTap,
    this.gradient,
    this.backgroundColor,
    required this.textColor,
  });

  final String text;
  final VoidCallback? onTap;
  final Gradient? gradient;
  final Color? backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 160),
        opacity: onTap == null ? 0.78 : 1,
        child: Container(
          height: 37,
          decoration: BoxDecoration(
            gradient: gradient,
            color: gradient == null ? backgroundColor : null,
            borderRadius: BorderRadius.circular(18.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7D66C9).withValues(alpha: 0.14),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}

class _PromptDialog extends StatelessWidget {
  const _PromptDialog({
    required this.title,
    required this.message,
    required this.leftLabel,
    required this.rightLabel,
    required this.onLeft,
    required this.onRight,
    this.leftFilled = false,
    this.rightFilled = true,
  });

  final String title;
  final String message;
  final String leftLabel;
  final String rightLabel;
  final VoidCallback onLeft;
  final VoidCallback onRight;
  final bool leftFilled;
  final bool rightFilled;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 8,
            right: 8,
            top: 10,
            height: 52,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.92),
                    Colors.white.withValues(alpha: 0.12),
                  ],
                ),
              ),
            ),
          ),
          Container(
            constraints: const BoxConstraints(maxWidth: 286),
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFF9F8FD), Color(0xFFCCB7E6)],
                stops: [0.0, 1.0],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.72),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4F4761).withValues(alpha: 0.28),
                  blurRadius: 26,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF9E84E8),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C2934),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _DialogActionButton(
                        label: leftLabel,
                        onTap: onLeft,
                        filled: leftFilled,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DialogActionButton(
                        label: rightLabel,
                        onTap: onRight,
                        filled: rightFilled,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DialogActionButton extends StatelessWidget {
  const _DialogActionButton({
    required this.label,
    required this.onTap,
    required this.filled,
  });

  final String label;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: filled ? AppColors.purpleButtonGradient : null,
          color: filled ? null : Colors.white.withValues(alpha: 0.96),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: filled ? Colors.white : const Color(0xFFACA5B7),
          ),
        ),
      ),
    );
  }
}
