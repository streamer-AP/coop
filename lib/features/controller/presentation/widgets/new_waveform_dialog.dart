import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../controller_assets.dart';

class NewWaveformDialog extends StatefulWidget {
  const NewWaveformDialog({super.key});

  static Future<String?> show(BuildContext context) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const NewWaveformDialog(),
    );
  }

  @override
  State<NewWaveformDialog> createState() => _NewWaveformDialogState();
}

class _NewWaveformDialogState extends State<NewWaveformDialog> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(minHeight: 280),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          image: const DecorationImage(
            image: AssetImage(ControllerAssets.waveformBg),
            fit: BoxFit.fill,
          ),
        ),
        padding: const EdgeInsets.fromLTRB(28, 34, 28, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '新建波形',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 30),
            _NameInputField(
              controller: _controller,
              focusNode: _focusNode,
            ),
            const SizedBox(height: 46),
            Row(
              children: [
                Expanded(
                  child: _DialogButton(
                    label: '取消',
                    backgroundColor: const Color(0xFFE2E2E6),
                    textColor: const Color(0xFF8A8A90),
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _DialogButton(
                    label: '确定',
                    backgroundColor: const Color(0xFF6D6D70),
                    textColor: Colors.white,
                    onTap: _submit,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.isEmpty) {
      return;
    }
    Navigator.of(context).pop(name);
  }
}

class _NameInputField extends StatelessWidget {
  const _NameInputField({
    required this.controller,
    required this.focusNode,
  });

  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 66,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x2A6F6F76), width: 1.2),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              maxLength: 5,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              style: const TextStyle(
                color: Color(0xFF2F2F33),
                fontSize: 24,
                fontWeight: FontWeight.w400,
              ),
              inputFormatters: [LengthLimitingTextInputFormatter(5)],
              decoration: const InputDecoration(
                hintText: '请输入名称',
                hintStyle: TextStyle(
                  color: Color(0xFF8D8D92),
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                counterText: '',
              ),
            ),
          ),
          AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              return Text(
                '${controller.text.length}/5',
                style: const TextStyle(
                  color: Color(0xC2A9A9AE),
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.onTap,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: SizedBox(
          height: 82,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
