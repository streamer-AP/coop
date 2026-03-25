import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';

class CreateCollectionDialog extends StatefulWidget {
  const CreateCollectionDialog({
    super.key,
    this.initialValue = '',
    this.title = '新建合集',
    this.hintText = '请输入合集名称',
  });

  final String initialValue;
  final String title;
  final String hintText;

  static Future<String?> show(
    BuildContext context, {
    String initialValue = '',
    String title = '新建合集',
    String hintText = '请输入合集名称',
  }) {
    return showDialog<String>(
      context: context,
      builder:
          (_) => CreateCollectionDialog(
            initialValue: initialValue,
            title: title,
            hintText: hintText,
          ),
    );
  }

  @override
  State<CreateCollectionDialog> createState() => _CreateCollectionDialogState();
}

class _CreateCollectionDialogState extends State<CreateCollectionDialog> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  bool get _canConfirm => _controller.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue)
      ..addListener(_onTextChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onTextChanged)
      ..dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withValues(alpha: 0.98),
              const Color(0xFFE2D5F3),
            ],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 24,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1C1B1F),
                ),
              ),
              const SizedBox(height: 18),
              _buildTextField(),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: _DialogActionButton(
                      label: '取消',
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DialogActionButton(
                      label: '确定',
                      enabled: _canConfirm,
                      isPrimary: true,
                      onTap:
                          _canConfirm
                              ? () => Navigator.of(
                                context,
                              ).pop(_controller.text.trim())
                              : null,
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

  Widget _buildTextField() {
    const inputTextStyle = TextStyle(
      fontSize: 14,
      height: 1.2,
      color: AppColors.textPrimary,
    );

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        constraints: const BoxConstraints(minHeight: 46),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFD9D9DD)),
        ),
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          autofocus: true,
          maxLines: 1,
          cursorColor: AppColors.primary,
          cursorHeight: 18,
          style: inputTextStyle,
          textAlignVertical: TextAlignVertical.center,
          strutStyle: const StrutStyle(
            fontSize: 14,
            height: 1.2,
            forceStrutHeight: true,
          ),
          textInputAction: TextInputAction.done,
          onSubmitted:
              (_) =>
                  _canConfirm
                      ? Navigator.of(context).pop(_controller.text.trim())
                      : null,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: inputTextStyle.copyWith(color: AppColors.textHint),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            suffixIcon:
                _controller.text.isEmpty
                    ? null
                    : IconButton(
                      onPressed: _controller.clear,
                      splashRadius: 18,
                      padding: const EdgeInsets.all(8),
                      icon: AppIcons.asset(
                        AppIcons.close2,
                        width: 18,
                        height: 18,
                      ),
                    ),
            suffixIconConstraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
          ),
        ),
      ),
    );
  }
}

class _DialogActionButton extends StatelessWidget {
  const _DialogActionButton({
    required this.label,
    required this.onTap,
    this.isPrimary = false,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onTap;
  final bool isPrimary;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final gradient =
        isPrimary && enabled ? AppColors.purpleButtonGradient : null;
    final backgroundColor =
        isPrimary
            ? (enabled ? null : const Color(0xFF9F9F9F))
            : Colors.white.withValues(alpha: 0.96);

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: backgroundColor,
          gradient: gradient,
          borderRadius: BorderRadius.circular(22),
          border: isPrimary ? null : Border.all(color: const Color(0x14FFFFFF)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isPrimary ? FontWeight.w500 : FontWeight.w400,
            color: isPrimary ? Colors.white : const Color(0xFF79747E),
          ),
        ),
      ),
    );
  }
}
