import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/bluetooth/ble_connection_manager.dart';
import '../../../../core/router/route_names.dart';
import '../../../permission/application/providers/permission_providers.dart';

/// Figma 1370:21452 - 激活设备弹窗
class DeviceActivationDialog extends ConsumerStatefulWidget {
  const DeviceActivationDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => const DeviceActivationDialog(),
    );
  }

  @override
  ConsumerState<DeviceActivationDialog> createState() =>
      _DeviceActivationDialogState();
}

class _DeviceActivationDialogState
    extends ConsumerState<DeviceActivationDialog> {
  final _controller = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 25),
        padding: const EdgeInsets.fromLTRB(38, 38, 38, 38),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(34),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment(0, 1.2),
            colors: [Color(0xE6EAEAEA), Color(0xCCEAEAEA), Color(0xCC634E83)],
            stops: [0.025, 0.32, 1.0],
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '激活设备',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF020202),
                  letterSpacing: 1.8,
                ),
              ),
              const SizedBox(height: 38),
              // Input row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF797979).withValues(alpha: 0.3),
                        ),
                      ),
                      child: TextField(
                        controller: _controller,
                        enabled: !_loading,
                        style: const TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                          hintText: '请输入设备号',
                          hintStyle: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF797979),
                            letterSpacing: 1.6,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          border: InputBorder.none,
                          suffixIcon:
                              _controller.text.isNotEmpty
                                  ? IconButton(
                                    icon: const Icon(
                                      Icons.cancel,
                                      size: 20,
                                      color: Color(0xFF797979),
                                    ),
                                    onPressed: () {
                                      _controller.clear();
                                      setState(() {});
                                    },
                                  )
                                  : null,
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // QR scan button
                  GestureDetector(
                    onTap: _loading ? null : _openScanner,
                    child: SizedBox(
                      width: 36,
                      height: 36,
                      child: Icon(
                        Icons.qr_code_scanner,
                        size: 32,
                        color:
                            _loading
                                ? const Color(0xFFBDBDBD)
                                : const Color(0xFF333333),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 38),
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: _DialogButton(
                      label: '取消',
                      color: const Color(0xFFD9D9DA),
                      textColor: const Color(0xFF797979),
                      onTap:
                          _loading ? null : () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DialogButton(
                      label: _loading ? '激活中...' : '确定',
                      color: const Color(0xFF797979),
                      textColor: Colors.white,
                      onTap: _loading ? null : _activate,
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

  Future<void> _openScanner() async {
    final result = await context.pushNamed<String>(RouteNames.qrScanner);
    if (result != null && mounted) {
      _controller.text = result;
      setState(() {});
    }
  }

  Future<void> _activate() async {
    final code = _controller.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入设备号')));
      return;
    }

    final bleManager = ref.read(bleConnectionManagerProvider);
    if (!bleManager.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先连接蓝牙设备')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await ref.read(permissionRepositoryProvider).activatePermission(code);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('设备激活成功')));
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      final message = '$e'.replaceFirst('Exception: ', '').trim();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message.isEmpty ? '激活失败' : message)),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({
    required this.label,
    required this.color,
    required this.textColor,
    required this.onTap,
  });

  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Text(label, style: TextStyle(fontSize: 14, color: textColor)),
      ),
    );
  }
}
