import 'package:flutter/material.dart';

import '../../domain/models/waveform.dart';

class EditWaveformsCommonWaveformsSection extends StatefulWidget {
  const EditWaveformsCommonWaveformsSection({
    required this.pages,
    required this.initialPageIndex,
    required this.onPageChanged,
    required this.onRemoveTap,
    super.key,
  });

  final List<List<Waveform>> pages;
  final int initialPageIndex;
  final ValueChanged<int> onPageChanged;
  final void Function(int pageIndex, int itemIndex, Waveform waveform)
  onRemoveTap;

  @override
  State<EditWaveformsCommonWaveformsSection> createState() =>
      _EditWaveformsCommonWaveformsSectionState();
}

class _EditWaveformsCommonWaveformsSectionState
    extends State<EditWaveformsCommonWaveformsSection> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPageIndex;
    _pageController = PageController(initialPage: widget.initialPageIndex);
  }

  @override
  void didUpdateWidget(covariant EditWaveformsCommonWaveformsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialPageIndex != widget.initialPageIndex &&
        widget.initialPageIndex < widget.pages.length) {
      _currentPage = widget.initialPageIndex;
      _pageController.jumpToPage(widget.initialPageIndex);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.82)),
      ),
      height: 180,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(
            child: Text(
              '常用波形',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 92,
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.pages.length,
              onPageChanged: (value) {
                setState(() {
                  _currentPage = value;
                });
                widget.onPageChanged(value);
              },
              itemBuilder: (context, pageIndex) {
                final items = widget.pages[pageIndex];
                return GridView.builder(
                  clipBehavior: Clip.none,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    mainAxisExtent: 42,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, itemIndex) {
                    return _WaveformPill(
                      items[itemIndex],
                      onRemoveTap:
                          items[itemIndex].name.trim().isEmpty
                              ? null
                              : () => widget.onRemoveTap(
                                pageIndex,
                                itemIndex,
                                items[itemIndex],
                              ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.pages.length, (index) {
              final active = index == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: active ? 24 : 8,
                height: 4,
                decoration: BoxDecoration(
                  color:
                      active
                          ? ControllerWaveformSectionColors.activeDot
                          : ControllerWaveformSectionColors.inactiveDot,
                  borderRadius: BorderRadius.circular(999),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _WaveformPill extends StatelessWidget {
  const _WaveformPill(this.waveform, {this.onRemoveTap});

  final Waveform waveform;
  final VoidCallback? onRemoveTap;

  @override
  Widget build(BuildContext context) {
    final isEmpty = waveform.name.trim().isEmpty;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          clipBehavior: Clip.none,
          height: 42,
          decoration: BoxDecoration(
            color: isEmpty ? Colors.transparent : const Color(0xFF8A73C2),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color:
                  isEmpty
                      ? Colors.white.withValues(alpha: 0.82)
                      : Colors.transparent,
              width: 1.2,
            ),
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            waveform.name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        if (!isEmpty)
          Positioned(
            right: 0,
            top: 0,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onRemoveTap,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF7B61A0), width: 1),
                ),
                child: const Icon(
                  Icons.remove,
                  size: 14,
                  color: Color(0xFF7B61A0),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class ControllerWaveformSectionColors {
  ControllerWaveformSectionColors._();

  static const activeDot = Color(0xFF6B54A7);
  static const inactiveDot = Color(0x80FFFFFF);
}
