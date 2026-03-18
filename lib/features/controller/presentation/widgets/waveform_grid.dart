import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/models/favorite_slot.dart';
import '../../domain/models/waveform.dart';

class WaveformGrid extends StatelessWidget {
  final int page;
  final List<FavoriteSlot> slots;
  final List<Waveform> allWaveforms;
  final int? selectedWaveformId;
  final ValueChanged<Waveform> onSelect;

  const WaveformGrid({
    super.key,
    required this.page,
    required this.slots,
    required this.allWaveforms,
    required this.selectedWaveformId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.2,
        ),
        itemCount: 4,
        itemBuilder: (context, index) {
          final slot = slots
              .where((s) => s.index == index)
              .cast<FavoriteSlot?>()
              .firstOrNull;

          if (slot == null) {
            return _EmptySlot(index: index);
          }

          final waveform = allWaveforms
              .where((w) => w.id == slot.waveformId)
              .cast<Waveform?>()
              .firstOrNull;

          if (waveform == null) {
            return _EmptySlot(index: index);
          }

          final isSelected = selectedWaveformId == waveform.id;

          return _WaveformCard(
            waveform: waveform,
            isSelected: isSelected,
            onTap: () => onSelect(waveform),
          );
        },
      ),
    );
  }
}

class _WaveformCard extends StatelessWidget {
  final Waveform waveform;
  final bool isSelected;
  final VoidCallback onTap;

  const _WaveformCard({
    required this.waveform,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? AppColors.primary.withValues(alpha: 0.12)
          : AppColors.cardBg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.grey.shade200,
              width: isSelected ? 2 : 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Icon(
                    waveform.isBuiltIn ? Icons.waves : Icons.edit_note,
                    size: 16,
                    color:
                        isSelected ? AppColors.primary : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      waveform.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${(waveform.durationMs / 1000).toStringAsFixed(0)}s',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptySlot extends StatelessWidget {
  final int index;

  const _EmptySlot({required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
          style: BorderStyle.solid,
        ),
      ),
      child: const Center(
        child: Icon(Icons.add, color: AppColors.textHint, size: 28),
      ),
    );
  }
}
