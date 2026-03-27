import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'new_waveform_vertical_slider.dart';

class NewWaveformEditorCard extends StatelessWidget {
  const NewWaveformEditorCard({
    required this.pageIndex,
    required this.isEnabled,
    required this.values,
    required this.onToggleEnabled,
    required this.onReset,
    required this.onPreviousPage,
    required this.onNextPage,
    required this.onValueChanged,
    super.key,
  });

  final int pageIndex;
  final bool isEnabled;
  final List<int> values;
  final VoidCallback onToggleEnabled;
  final VoidCallback onReset;
  final VoidCallback onPreviousPage;
  final VoidCallback onNextPage;
  final void Function(int index, int value) onValueChanged;

  bool get _showToggleButton => pageIndex > 0;
  bool get _canGoNext => pageIndex < 3 && isEnabled;
  bool get _canGoPrevious => pageIndex > 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 16, 14),
              child: Row(
                children: [
                  SizedBox(
                    width: 74,
                    child: _showToggleButton
                        ? _ToggleButton(
                            enabled: isEnabled,
                            onTap: onToggleEnabled,
                          )
                        : const SizedBox.shrink(),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        '波形编辑',
                        style: TextStyle(
                          color: Color(0xFF7B7B84),
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  _ResetButton(onTap: onReset),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
              child: SizedBox(
                height: 320,
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: List.generate(values.length, (index) {
                          return Expanded(
                            child: NewWaveformVerticalSlider(
                              index: index,
                              value: values[index],
                              enabled: isEnabled,
                              onChanged: (nextValue) => onValueChanged(
                                index,
                                nextValue,
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    if (!isEnabled)
                      Positioned.fill(
                        child: Container(
                          color: const Color(0x66C9BDE5),
                          child: Center(
                            child: _EnableButton(onTap: onToggleEnabled),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              child: Row(
                children: [
                  _ArrowButton(
                    icon: Icons.chevron_left_rounded,
                    enabled: _canGoPrevious,
                    onTap: onPreviousPage,
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFE8FD),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${pageIndex * 8 + 1}s~${pageIndex * 8 + 8}s',
                      style: const TextStyle(
                        color: Color(0xFF8B77C8),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  _ArrowButton(
                    icon: Icons.chevron_right_rounded,
                    enabled: _canGoNext,
                    onTap: onNextPage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final activeColor = const Color(0xFF8B77C8);
    final inactiveColor = AppColors.textHint;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.remove_circle_outline_rounded,
            size: 16,
            color: enabled ? activeColor : const Color(0xFFBFBFC7),
          ),
          const SizedBox(width: 4),
          Text(
            '停用',
            style: TextStyle(
              color: enabled ? activeColor : inactiveColor,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResetButton extends StatelessWidget {
  const _ResetButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(
            Icons.restart_alt_rounded,
            size: 18,
            color: Color(0xFF8B77C8),
          ),
          SizedBox(width: 4),
          Text(
            '重置',
            style: TextStyle(
              color: Color(0xFF8B77C8),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _EnableButton extends StatelessWidget {
  const _EnableButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xFFE7DDFB)),
          ),
          child: const Text(
            '启用',
            style: TextStyle(
              color: Color(0xFF8B77C8),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = enabled ? const Color(0xFF8B77C8) : const Color(0xFFD1CFE3);
    return GestureDetector(
      onTap: enabled ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: Icon(
        icon,
        size: 30,
        color: color,
      ),
    );
  }
}
