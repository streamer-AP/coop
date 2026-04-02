import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controller_assets.dart';
import '../../application/providers/controller_providers.dart';
import '../../domain/models/waveform.dart';

class NewWaveformDialog extends ConsumerStatefulWidget {
  const NewWaveformDialog({super.key});

  static Future<String?> show(BuildContext context) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const NewWaveformDialog(),
    );
  }

  @override
  ConsumerState<NewWaveformDialog> createState() => _NewWaveformDialogState();
  
}

class _NewWaveformDialogState extends ConsumerState<NewWaveformDialog> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;


  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _controller.addListener(_onNameChanged);
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
    _controller.removeListener(_onNameChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onNameChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = _controller.text.trim().isNotEmpty;
    final waveforms = ref.watch(waveformsProvider).valueOrNull ?? const <Waveform>[];
    final duplicateName = _isDuplicateName(_controller.text.trim(), waveforms);
    final canConfirm = canSubmit && !duplicateName;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      child: Container(
        height: 252,
        decoration: const BoxDecoration(
          // borderRadius: BorderRadius.circular(28),
          image: DecorationImage(
            image: AssetImage(ControllerAssets.waveformBg),
            fit: BoxFit.fill,
          ),
        ),
        padding: const EdgeInsets.fromLTRB(38, 38, 38, 38),
        child: Column(
          children: [
            const Text(
              '新建波形',
              style: TextStyle(
                color: Color(0XFF020202),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 18),
            _NameInputField(
              controller: _controller,
              focusNode: _focusNode,
            ),
            const SizedBox(height: 10),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: duplicateName
                  ? const SizedBox(
                      key: ValueKey('duplicate-name-warning'),
                      height: 18,
                      child: Text(
                        '名称已存在',
                        style: TextStyle(
                          color: Color(0xFFD94B4B),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    )
                  : const SizedBox(key: ValueKey('duplicate-name-empty'), height: 18),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _DialogButton(
                    label: '取消',
                    backgroundColor: const Color(0xFFD9D9DA),
                    textColor: const Color(0xFF797979),
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _DialogButton(
                    label: '确定',
                    backgroundColor: canConfirm
                        ? const Color(0xFF6A53A7)
                        : const Color(0xFF797979),
                    textColor: Colors.white,
                    onTap: canConfirm ? _submit : null,
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
    final waveforms = ref.read(waveformsProvider).valueOrNull ?? const <Waveform>[];
    if (_isDuplicateName(name, waveforms)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('名称已存在，请换一个名字')),
      );
      return;
    }
    Navigator.of(context).pop(name);
  }

  bool _isDuplicateName(String name, List<Waveform> waveforms) {
    if (name.isEmpty) {
      return false;
    }
    return waveforms.any((waveform) => waveform.name.trim() == name);
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
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x2A6F6F76), width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              inputFormatters: [LengthLimitingTextInputFormatter(5)],
              decoration: const InputDecoration(
                hintText: '请输入名称',
                hintStyle: TextStyle(
                  color: Color(0xFF8D8D92),
                  fontSize: 16,
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
                  fontSize: 12,
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
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Opacity(
          opacity: isEnabled ? 1.0 : 0.65,
          child: SizedBox(
            height: 42,
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
