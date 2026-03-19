import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'auth_chrome.dart';

InputDecoration authUnderlineInputDecoration({
  required String hintText,
  String? prefixText,
  String? suffixText,
  Widget? suffixIcon,
  String? counterText,
}) {
  return InputDecoration(
    isDense: true,
    hintText: hintText,
    hintStyle: const TextStyle(
      fontSize: 15,
      color: AuthPalette.hint,
      fontWeight: FontWeight.w400,
    ),
    prefixText: prefixText,
    prefixStyle: const TextStyle(
      fontSize: 15,
      color: AuthPalette.body,
      fontWeight: FontWeight.w500,
    ),
    suffixText: suffixText,
    suffixStyle: const TextStyle(
      fontSize: 15,
      color: AuthPalette.title,
      fontWeight: FontWeight.w500,
    ),
    suffixIcon: suffixIcon,
    counterText: counterText,
    border: const UnderlineInputBorder(
      borderSide: BorderSide(color: AuthPalette.underline),
    ),
    enabledBorder: const UnderlineInputBorder(
      borderSide: BorderSide(color: AuthPalette.underline),
    ),
    focusedBorder: const UnderlineInputBorder(
      borderSide: BorderSide(color: AuthPalette.action),
    ),
    contentPadding: const EdgeInsets.only(bottom: 10),
  );
}

class AuthFieldLabel extends StatelessWidget {
  const AuthFieldLabel({super.key, required this.label, this.trailing});

  final String label;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AuthPalette.body,
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class ChinesePhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final clipped = digits.substring(0, math.min(11, digits.length));
    final buffer = StringBuffer();

    for (var index = 0; index < clipped.length; index++) {
      if (index == 3 || index == 7) {
        buffer.write(' ');
      }
      buffer.write(clipped[index]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
