import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';

class IdentityData {
  final String name;
  final String idNumber;

  const IdentityData({required this.name, required this.idNumber});
}

class IdentityInputDialog extends StatefulWidget {
  const IdentityInputDialog({super.key});

  static Future<IdentityData?> show(BuildContext context) {
    return showDialog<IdentityData>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const IdentityInputDialog(),
    );
  }

  @override
  State<IdentityInputDialog> createState() => _IdentityInputDialogState();
}

class _IdentityInputDialogState extends State<IdentityInputDialog> {
  final _idNumberController = TextEditingController();
  final _nameController = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _idNumberController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _idNumberController.text.length == 18 &&
      _nameController.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary.withValues(alpha: 0.08),
              Colors.white,
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '身份认证',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            _buildInput(
              controller: _idNumberController,
              hint: '请输入身份证号',
              keyboardType: TextInputType.text,
              inputFormatters: [
                LengthLimitingTextInputFormatter(18),
              ],
            ),
            const SizedBox(height: 12),
            _buildInput(
              controller: _nameController,
              hint: '请输入姓名',
            ),
            if (_errorText != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _errorText!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.error,
                  ),
                ),
              ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(null),
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        '取消',
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
                    onTap: _submit,
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: _isValid
                            ? AppColors.purpleButtonGradient
                            : null,
                        color: _isValid ? null : const Color(0xFFBBBBBB),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        '确定',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
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
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.textHint),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.cancel, size: 18),
                  onPressed: () {
                    controller.clear();
                    setState(() => _errorText = null);
                  },
                )
              : null,
        ),
        onChanged: (_) => setState(() => _errorText = null),
      ),
    );
  }

  void _submit() {
    if (!_isValid) {
      setState(() => _errorText = '请检查信息是否正确');
      return;
    }
    Navigator.of(context).pop(
      IdentityData(
        name: _nameController.text.trim(),
        idNumber: _idNumberController.text.trim(),
      ),
    );
  }
}
