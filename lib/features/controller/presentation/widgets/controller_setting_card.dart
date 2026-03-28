import 'package:flutter/material.dart';

import '../../controller_assets.dart';
import 'controller_strength_slider.dart';

class ControllerWaveformItemData {
  const ControllerWaveformItemData({required this.name});

  final String name;
}

class ControllerSettingCard extends StatefulWidget {
  const ControllerSettingCard({
    required this.title,
    required this.headerIconAsset,
    required this.waveformIconAsset,
    required this.waveformPages,
    required this.selectedPageIndex,
    required this.selectedItemIndex,
    required this.strengthIndex,
    required this.onWaveformSelected,
    required this.onStrengthChanged,
    required this.onSettingsTap,
    super.key,
  });

  final String title;
  final String headerIconAsset;
  final String waveformIconAsset;
  final List<List<ControllerWaveformItemData>> waveformPages;
  final int selectedPageIndex;
  final int selectedItemIndex;
  final int strengthIndex;
  final ValueChanged<int> onStrengthChanged;
  final VoidCallback onSettingsTap;
  final void Function(int pageIndex, int itemIndex) onWaveformSelected;

  @override
  State<ControllerSettingCard> createState() => _ControllerSettingCardState();
}

class _ControllerSettingCardState extends State<ControllerSettingCard> {
  late final PageController _pageController;
  late int _currentPageIndex;

  @override
  void initState() {
    super.initState();
    _currentPageIndex = widget.selectedPageIndex;
    _pageController = PageController(initialPage: widget.selectedPageIndex);
  }

  @override
  void didUpdateWidget(covariant ControllerSettingCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedPageIndex != widget.selectedPageIndex) {
      _currentPageIndex = widget.selectedPageIndex;
      _pageController.jumpToPage(widget.selectedPageIndex);
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
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(ControllerAssets.settingBackground),
          fit: BoxFit.fill,
          opacity: 0.74,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
        child: Column(
          children: [
            Row(
              children: [
                const SizedBox(width: 26,height: 10,),
                const Spacer(),
                Image.asset(
                  widget.headerIconAsset,
                  width: 22,
                  height: 22,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: widget.onSettingsTap,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Image.asset(
                      ControllerAssets.cardSetting,
                      width: 18,
                      height: 18,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Image.asset(
              ControllerAssets.settingLineTop,
              height: 1,
              width: double.infinity,
              fit: BoxFit.fill,
            ),
            const SizedBox(height: 10),
            const Text(
              '波形',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 112,
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.waveformPages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPageIndex = index;
                  });
                },
                itemBuilder: (context, pageIndex) {
                  final items = widget.waveformPages[pageIndex];
                  if (items.isEmpty) {
                    return const Center(
                      child: Text(
                        '暂无波形',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final itemWidth = (constraints.maxWidth - 12) / 2;

                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: List.generate(items.length, (itemIndex) {
                          final item = items[itemIndex];
                          final isSelected =
                              widget.selectedPageIndex == pageIndex &&
                              widget.selectedItemIndex == itemIndex;

                          return GestureDetector(
                            onTap:
                                () => widget.onWaveformSelected(
                                  pageIndex,
                                  itemIndex,
                                ),
                            child: Container(
                              width: itemWidth,
                              height: 44,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(
                                    isSelected
                                        ? ControllerAssets.settingItemSelected
                                        : ControllerAssets.settingItem,
                                  ),
                                  fit: BoxFit.fill,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Row(
                                children: [
                                  Image.asset(
                                    widget.waveformIconAsset,
                                    width: 20,
                                    height: 20,
                                    fit: BoxFit.contain,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      item.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.waveformPages.length, (index) {
                final isActive = index == _currentPageIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: isActive ? 18 : 7,
                  height: 4,
                  decoration: BoxDecoration(
                    color:
                        isActive
                            ? ControllerAssets.accent
                            : ControllerAssets.indicatorInactive,
                    borderRadius: BorderRadius.circular(999),
                  ),
                );
              }),
            ),
            const SizedBox(height: 14),
            Image.asset(
              ControllerAssets.settingLineBottom,
              height: 1,
              width: double.infinity,
              fit: BoxFit.fill,
            ),
            const SizedBox(height: 10),
            const Text(
              '强度',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            ControllerStrengthSlider(
              selectedIndex: widget.strengthIndex,
              labels: const ['关', '弱', '中', '强'],
              onChanged: widget.onStrengthChanged,
            ),
          ],
        ),
      ),
    );
  }
}
