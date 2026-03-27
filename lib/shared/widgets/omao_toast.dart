import 'package:flutter/material.dart';

import 'top_banner_toast.dart';

class OmaoToast {
  OmaoToast._();

  static void show(
    BuildContext context,
    String message, {
    bool isSuccess = true,
    Duration duration = TopBannerToast.defaultDuration,
  }) {
    TopBannerToast.show(
      context,
      message: message,
      isError: !isSuccess,
      duration: duration,
    );
  }

  static void showSnackBar(BuildContext context, SnackBar snackBar) {
    final text = snackBar.content;
    String message = '';
    if (text is Text) {
      message = text.data ?? '';
    }
    show(context, message, isSuccess: snackBar.backgroundColor != Colors.red);
  }
}
