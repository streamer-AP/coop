import 'package:flutter/material.dart';

import '../../controller_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/waveform.dart';

class EditWaveformsPresetPanel extends StatelessWidget {
  const EditWaveformsPresetPanel({
    required this.officialPresets,
    required this.customPresets,
    required this.configuredWaveformIds,
    required this.onOfficialPresetTap,
    required this.onCustomPresetAddTap,
    required this.onCustomPresetTap,
    required this.onCreateTap,
    super.key,
  });

  final List<Waveform> officialPresets;
  final List<Waveform> customPresets;
  final Set<int> configuredWaveformIds;
  final ValueChanged<Waveform> onOfficialPresetTap;
  final ValueChanged<Waveform> onCustomPresetAddTap;
  final ValueChanged<Waveform> onCustomPresetTap;
  final VoidCallback onCreateTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      padding: const EdgeInsets.fromLTRB(32, 16, 32, 0),
      decoration: const BoxDecoration(
        color: AppColors.listBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(
            child: Text(
              '官方预设',
              style: TextStyle(
                color: Color(0xFF797979),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 14,
            runAlignment: WrapAlignment.center,
            alignment: WrapAlignment.center,
            children:
                officialPresets
                    .map(
                      (waveform) => _PresetChip(
                        label: waveform.name,
                        enabled:
                            waveform.name.trim().isNotEmpty &&
                            !configuredWaveformIds.contains(waveform.id),
                        leadingIconAsset: null,
                        trailingBadge:
                            waveform.name.trim().isEmpty
                                ? _PresetBadge.none
                                : configuredWaveformIds.contains(waveform.id)
                                ? _PresetBadge.none
                                : _PresetBadge.add,
                        backgroundColor: Colors.white,
                        borderColor: const Color(0xFF8C7ABF),
                        textColor: const Color(0xFF8C7ABF),
                        onBadgeTap: null,
                        onLeftTap: null,
                        onTap: () => onOfficialPresetTap(waveform),
                      ),
                    )
                    .toList(),
          ),
          const SizedBox(height: 22),
          const Divider(height: 1, thickness: 1, color: Color(0xFFDFDFDF)),
          const SizedBox(height: 18),
          const Center(
            child: Text(
              '自定义预设',
              style: TextStyle(
                color: Color(0xFF797979),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 14,
            runAlignment: WrapAlignment.center,
            children: [
              ...customPresets.map(
                (waveform) => _PresetChip(
                  label: waveform.name,
                  enabled: waveform.name.trim().isNotEmpty &&
                            !configuredWaveformIds.contains(waveform.id),
                  leadingIconAsset: waveform.name.trim().isNotEmpty &&
                          !configuredWaveformIds.contains(waveform.id)
                      ? ControllerAssets.waveformEdit
                      : ControllerAssets.waveformEditGary,
                  trailingBadge:
                      waveform.name.trim().isEmpty
                          ? _PresetBadge.none
                          : configuredWaveformIds.contains(waveform.id)
                          ? _PresetBadge.none
                          : _PresetBadge.add,
                  backgroundColor: Colors.white,
                  borderColor: const Color(0xFF8C7ABF),
                  textColor: const Color(0xFF8A73C2),
                  onTap: () {},
                  onLeftTap: () => onCustomPresetTap(waveform),
                  onBadgeTap:
                      trailingBadgeIsAdd(waveform, configuredWaveformIds)
                          ? () => onCustomPresetAddTap(waveform)
                          : null,
                ),
              ),
              _PresetActionButton(onTap: onCreateTap),
            ],
          ),
          const SizedBox(height: 18),
        ],
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  const _PresetChip({
    required this.label,
    required this.enabled,
    required this.leadingIconAsset,
    required this.trailingBadge,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    required this.onTap,
    required this.onBadgeTap,
    required this.onLeftTap,
  });

  final String label;
  final bool enabled;
  final String? leadingIconAsset;
  final _PresetBadge trailingBadge;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final VoidCallback onTap;
  final VoidCallback? onBadgeTap;
  final VoidCallback? onLeftTap;

  @override
  Widget build(BuildContext context) {
    final canTap = enabled;
    final effectiveBorderColor = canTap ? borderColor : const Color(0xFFD1D1D6);
    final effectiveTextColor =
        canTap ? textColor : AppColors.textHint.withValues(alpha: 0.55);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: canTap ? onTap : null,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: 104,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: canTap ? backgroundColor : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: effectiveBorderColor),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (leadingIconAsset != null) ...[
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: onLeftTap,
                        child: Image.asset(
                          leadingIconAsset!,
                          width: 15,
                          height: 15,
                          color: effectiveTextColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                    ],
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: effectiveTextColor,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (trailingBadge != _PresetBadge.none)
                Positioned(
                  right: -2,
                  top: -2,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: onBadgeTap,
                    child: Container(
                      width: 20,
                      height: 20,
                      
                      child: Center(
                        child: Image.asset(
                          trailingBadge == _PresetBadge.add
                              ? ControllerAssets.waveformAdd
                              : ControllerAssets.waveformEditGary,
                          width: 18,
                          height: 18,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

bool trailingBadgeIsAdd(Waveform waveform, Set<int> configuredWaveformIds) {
  final nameIsEmpty = waveform.name.trim().isEmpty;
  if (nameIsEmpty) {
    return false;
  }
  return !configuredWaveformIds.contains(waveform.id);
}

enum _PresetBadge { none, add, edit, remove }

class _PresetActionButton extends StatelessWidget {
  const _PresetActionButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: 104,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xFF8C7ABF), width: 1.2),

          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, size: 18, color: Color(0xFF8C7ABF)),
              SizedBox(width: 6),
              Text(
                '新建波形',
                style: TextStyle(color: Color(0xFF8C7ABF), fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
