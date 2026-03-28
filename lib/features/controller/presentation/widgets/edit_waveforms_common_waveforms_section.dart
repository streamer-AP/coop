import 'package:flutter/material.dart';

import '../../domain/models/waveform.dart';

class EditWaveformsCommonWaveformsSection extends StatefulWidget {
  const EditWaveformsCommonWaveformsSection({
    required this.pages,
    super.key,
  });

  final List<List<Waveform>> pages;

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
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
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
          const SizedBox(height: 18),
          SizedBox(
            height: 122,
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.pages.length,
              onPageChanged: (value) {
                setState(() {
                  _currentPage = value;
                });
              },
              itemBuilder: (context, pageIndex) {
                final items = widget.pages[pageIndex];
                return GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 2.1,
                  children: items.map(_WaveformPill.new).toList(),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.pages.length, (index) {
              final active = index == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: active ? 28 : 10,
                height: 4,
                decoration: BoxDecoration(
                  color: active
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
  const _WaveformPill(this.waveform);

  final Waveform waveform;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF8A73C2),
            borderRadius: BorderRadius.circular(999),
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            waveform.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Positioned(
          right: 10,
          top: -6,
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF7B61A0), width: 1.4),
            ),
            child: const Icon(
              Icons.remove,
              size: 14,
              color: Color(0xFF7B61A0),
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
