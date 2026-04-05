import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_icons.dart';

class AuthPalette {
  AuthPalette._();

  static const title = Color(0xFF252036);
  static const body = Color(0xFF5E5870);
  static const hint = Color(0xFFA7A1BD);
  static const line = Color(0xFFC6C1D7);
  static const underline = line;
  static const link = Color(0xFF7761C8);
  static const action = link;
  static const actionDark = Color(0xFF5737B7);
  static const buttonTop = Color(0xFF8B6ED6);
  static const buttonBottom = Color(0xFF5D3ABC);
  static const buttonDisabledTop = Color(0xFFD7CCEA);
  static const buttonDisabledBottom = Color(0xFFC7BBDD);
  static const pageTop = Color(0xFFE2E0EE);
  static const pageBottom = Color(0xFFF2F0FA);
  static const heroTop = Color(0xFF7E7AA4);
  static const heroMid = Color(0xFFC3BEDD);
  static const heroBottom = Color(0xFFF3F1FA);
}

class AuthFonts {
  AuthFonts._();

  static String get chinese =>
      defaultTargetPlatform == TargetPlatform.iOS
          ? 'PingFang SC'
          : 'SourceHanSansCN';
  static const english = 'Alegreya Sans';

  static const _chineseFallback = [
    'PingFang HK',
    'PingFang TC',
    'SourceHanSansCN',
    'Source Han Sans SC',
    'Noto Sans SC',
    'sans-serif',
  ];

  static const _englishFallback = [
    'AlegreyaSans',
    'Avenir Next',
    'Avenir',
    'Helvetica Neue',
    'sans-serif',
  ];

  static TextStyle chineseTextStyle({
    double? fontSize,
    double? height,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    FontStyle? fontStyle,
    List<Shadow>? shadows,
  }) {
    return TextStyle(
      fontFamily: chinese,
      fontFamilyFallback: _chineseFallback,
      fontSize: fontSize,
      height: height,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      fontStyle: fontStyle,
      shadows: shadows,
    );
  }

  static TextStyle englishTextStyle({
    double? fontSize,
    double? height,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    FontStyle? fontStyle,
    List<Shadow>? shadows,
  }) {
    return TextStyle(
      fontFamily: english,
      fontFamilyFallback: [..._englishFallback, ..._chineseFallback],
      fontSize: fontSize,
      height: height,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      fontStyle: fontStyle,
      shadows: shadows,
    );
  }

  static TextStyle styleForText(
    String text, {
    double? fontSize,
    double? height,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    FontStyle? fontStyle,
    List<Shadow>? shadows,
  }) {
    final hasLatin = RegExp(r'[A-Za-z]').hasMatch(text);
    final hasChinese = RegExp(r'[\u3400-\u9FFF]').hasMatch(text);

    if (hasLatin && !hasChinese) {
      return englishTextStyle(
        fontSize: fontSize,
        height: height,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        fontStyle: fontStyle,
        shadows: shadows,
      );
    }

    return chineseTextStyle(
      fontSize: fontSize,
      height: height,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      fontStyle: fontStyle,
      shadows: shadows,
    );
  }
}

class AuthBackground extends StatelessWidget {
  const AuthBackground({
    super.key,
    required this.child,
    this.heroMode = false,
    this.showWatermark = false,
  });

  final Widget child;
  final bool heroMode;
  final bool showWatermark;

  static const _backgroundAsset = 'assets/figma/home/home_bg.png';

  @override
  Widget build(BuildContext context) {
    if (!heroMode) {
      return DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AuthPalette.pageTop, AuthPalette.pageBottom],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const Positioned(
              left: -88,
              right: -88,
              bottom: 14,
              height: 208,
              child: IgnorePointer(child: _WaveGlow(opacity: 0.2)),
            ),
            child,
          ],
        ),
      );
    }

    return ColoredBox(
      color: AuthPalette.pageBottom,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(
            child: Image(
              image: AssetImage(_backgroundAsset),
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              filterQuality: FilterQuality.high,
            ),
          ),
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x332A327A),
                    Color(0x14515DA6),
                    Color(0x0CEEF2FF),
                  ],
                  stops: [0, 0.46, 1],
                ),
              ),
            ),
          ),
          Positioned(
            top: heroMode ? -42 : -24,
            left: -36,
            right: -36,
            height: heroMode ? 240 : 180,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topCenter,
                    radius: 1.12,
                    colors: [
                      Colors.white.withValues(alpha: 0.18),
                      Colors.white.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const Positioned(
            left: -80,
            right: -80,
            bottom: -6,
            height: 250,
            child: IgnorePointer(child: _WaveGlow(opacity: 0.3)),
          ),
          if (showWatermark)
            Positioned(
              right: -16,
              top: 122,
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.21,
                  child: Image.asset(
                    'assets/figma/auth/omao_watermark.png',
                    width: 64,
                    height: 169,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          child,
        ],
      ),
    );
  }
}

class AuthBackButton extends StatelessWidget {
  const AuthBackButton({
    super.key,
    this.iconColor = Colors.white,
    this.backgroundColor,
    this.onTap,
  });

  final Color iconColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap!();
          return;
        }
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else if (context.canPop()) {
          context.pop();
        }
      },
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white.withValues(alpha: 0.28),
          shape: BoxShape.circle,
        ),
        child: AppIcons.icon(
          AppIcons.arrowLeft,
          size: 16,
          color: iconColor,
        ),
      ),
    );
  }
}

class AuthPageTitle extends StatelessWidget {
  const AuthPageTitle({
    super.key,
    required this.title,
    required this.subtitle,
    this.titleColor = AuthPalette.title,
    this.subtitleColor = AuthPalette.hint,
  });

  final String title;
  final String subtitle;
  final Color titleColor;
  final Color subtitleColor;

  @override
  Widget build(BuildContext context) {
    return AuthTitleBlock(
      title: title,
      subtitle: subtitle,
      titleColor: titleColor,
      subtitleColor: subtitleColor,
    );
  }
}

class AuthFrostedCard extends StatelessWidget {
  const AuthFrostedCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(28, 34, 28, 28),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(34),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.52),
            borderRadius: BorderRadius.circular(34),
            border: Border.all(color: Colors.white.withValues(alpha: 0.42)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7A6AAE).withValues(alpha: 0.12),
                blurRadius: 36,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

class AuthTitleBlock extends StatelessWidget {
  const AuthTitleBlock({
    super.key,
    required this.title,
    required this.subtitle,
    this.titleColor = AuthPalette.title,
    this.subtitleColor = AuthPalette.hint,
  });

  final String title;
  final String subtitle;
  final Color titleColor;
  final Color subtitleColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AuthFonts.chineseTextStyle(
            fontSize: 24,
            height: 1.1,
            fontWeight: FontWeight.w700,
            color: titleColor,
          ),
        ),
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: AuthFonts.englishTextStyle(
              fontSize: 13,
              height: 1.05,
              color: subtitleColor.withValues(alpha: 0.62),
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.24,
            ),
          ),
        ],
      ],
    );
  }
}

class AuthUnderlineField extends StatelessWidget {
  const AuthUnderlineField({
    super.key,
    this.label,
    required this.controller,
    required this.hintText,
    this.leadingText,
    this.trailing,
    this.keyboardType,
    this.inputFormatters,
    this.obscureText = false,
    this.onChanged,
    this.textStyle,
  });

  final String? label;
  final TextEditingController controller;
  final String hintText;
  final String? leadingText;
  final Widget? trailing;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: AuthFonts.chineseTextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AuthPalette.body,
            ),
          ),
          const SizedBox(height: 12),
        ],
        Container(
          padding: const EdgeInsets.only(bottom: 10),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AuthPalette.line)),
          ),
          child: Row(
            children: [
              if (leadingText != null)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Text(
                    leadingText!,
                    style: AuthFonts.styleForText(
                      leadingText!,
                      fontSize: 16,
                      color: AuthPalette.title,
                    ),
                  ),
                ),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  inputFormatters: inputFormatters,
                  obscureText: obscureText,
                  cursorColor: AuthPalette.link,
                  style:
                      textStyle ??
                      AuthFonts.englishTextStyle(
                        fontSize: 16,
                        color: AuthPalette.title,
                      ),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: hintText,
                    hintStyle: AuthFonts.chineseTextStyle(
                      fontSize: 16,
                      color: AuthPalette.hint,
                    ),
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                  ),
                  onChanged: onChanged,
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 8), trailing!],
            ],
          ),
        ),
      ],
    );
  }
}

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.enabled = true,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onTap;
  final bool enabled;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final canTap = enabled && !loading && onTap != null;

    return GestureDetector(
      onTap: canTap ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 52,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: const Alignment(-0.05, -1.0),
            end: const Alignment(0.05, 1.0),
            colors:
                canTap
                    ? const [Color(0xFF8B6ED6), Color(0xFF543A99)]
                    : const [
                      AuthPalette.buttonDisabledTop,
                      AuthPalette.buttonDisabledBottom,
                    ],
          ),
          borderRadius: BorderRadius.circular(35),
          boxShadow:
              canTap
                  ? [
                    BoxShadow(
                      color: const Color(0xFF7B5EDB).withValues(alpha: 0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ]
                  : null,
        ),
        alignment: Alignment.center,
        child:
            loading
                ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: Colors.white,
                  ),
                )
                : Text(
                  label,
                  style: AuthFonts.chineseTextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
      ),
    );
  }
}

class AuthClearButton extends StatelessWidget {
  const AuthClearButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          color: const Color(0xFF9893A6).withValues(alpha: 0.9),
          shape: BoxShape.circle,
        ),
        child: AppIcons.icon(AppIcons.close2, size: 12, color: Colors.white),
      ),
    );
  }
}

class AuthAgreementRow extends StatelessWidget {
  const AuthAgreementRow({
    super.key,
    required this.agreed,
    required this.onToggle,
    required this.onUserAgreementTap,
    required this.onPrivacyTap,
  });

  final bool agreed;
  final VoidCallback onToggle;
  final VoidCallback onUserAgreementTap;
  final VoidCallback onPrivacyTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onToggle,
          child: Container(
            width: 14,
            height: 14,
            margin: const EdgeInsets.only(top: 1.5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: agreed ? AuthPalette.link : AuthPalette.hint,
                width: 1,
              ),
              color: agreed ? AuthPalette.link : Colors.transparent,
            ),
            child:
                agreed
                    ? const Center(
                      child: Icon(
                        Icons.check_rounded,
                        size: 11,
                        color: Colors.white,
                      ),
                    )
                    : null,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Wrap(
            spacing: 2,
            runSpacing: 2,
            children: [
              Text(
                '我已阅读并同意',
                style: TextStyle(
                  fontSize: 12,
                  color: AuthPalette.body,
                  fontFamily: AuthFonts.chinese,
                  fontFamilyFallback: AuthFonts._chineseFallback,
                ),
              ),
              GestureDetector(
                onTap: onUserAgreementTap,
                child: Text(
                  '《用户协议》',
                  style: AuthFonts.chineseTextStyle(
                    fontSize: 12,
                    color: AuthPalette.link,
                  ),
                ),
              ),
              Text(
                '和',
                style: TextStyle(
                  fontSize: 12,
                  color: AuthPalette.body,
                  fontFamily: AuthFonts.chinese,
                  fontFamilyFallback: AuthFonts._chineseFallback,
                ),
              ),
              GestureDetector(
                onTap: onPrivacyTap,
                child: Text(
                  '《隐私政策》',
                  style: AuthFonts.chineseTextStyle(
                    fontSize: 12,
                    color: AuthPalette.link,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class AuthGhostLink extends StatelessWidget {
  const AuthGhostLink({
    super.key,
    required this.label,
    required this.onTap,
    this.trailingIcon,
  });

  final String label;
  final VoidCallback onTap;
  final Widget? trailingIcon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AuthFonts.styleForText(
              label,
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AuthPalette.link,
            ),
          ),
          if (trailingIcon != null) ...[
            const SizedBox(width: 4),
            trailingIcon!,
          ],
        ],
      ),
    );
  }
}

class _WaveGlow extends StatelessWidget {
  const _WaveGlow({required this.opacity});

  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(200),
        gradient: RadialGradient(
          center: const Alignment(0, 0.3),
          radius: 1.2,
          colors: [
            Colors.white.withValues(alpha: opacity),
            Colors.white.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}
