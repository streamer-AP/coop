import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/controller_ui_providers.dart';
import '../../controller_assets.dart';
import '../widgets/controller_device_status_card.dart';
import '../widgets/controller_setting_card.dart';

class ControllerScreen extends ConsumerWidget {
  const ControllerScreen({super.key});

  static const _backgroundAsset = ControllerAssets.blueConnectionBackground;
  static const _gradientAsset = ControllerAssets.gradientSliding;

  static const List<List<ControllerWaveformItemData>> _swingWaveformPages = [
    [
      ControllerWaveformItemData(name: '羽毛轻扫'),
      ControllerWaveformItemData(name: '深海呼吸'),
      ControllerWaveformItemData(name: '午后清风'),
      ControllerWaveformItemData(name: '晨露微光'),
    ],
    [
      ControllerWaveformItemData(name: '云端漫游'),
      ControllerWaveformItemData(name: '湖畔回响'),
      ControllerWaveformItemData(name: '流星摇曳'),
    ],
    [],
  ];

  static const List<List<ControllerWaveformItemData>> _vibrationWaveformPages =
      [
        [
          ControllerWaveformItemData(name: '星夜呢喃'),
          ControllerWaveformItemData(name: '绵绵细雨'),
          ControllerWaveformItemData(name: '潮汐呼吸'),
          ControllerWaveformItemData(name: '麦浪起伏'),
        ],
        [
          ControllerWaveformItemData(name: '轻语回荡'),
          ControllerWaveformItemData(name: '脉冲星河'),
          ControllerWaveformItemData(name: '月光涟漪'),
        ],
        [],
      ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uiState = ref.watch(controllerUiProvider);
    final notifier = ref.read(controllerUiProvider.notifier);

    return Scaffold(
      backgroundColor: ControllerAssets.background,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Image.asset(
                _backgroundAsset,
                height: 360,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(context),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                  child: ControllerDeviceStatusCard(
                    deviceName: uiState.deviceName,
                    batteryLevel: uiState.batteryLevel,
                    connectionStatus: uiState.connectionStatus,
                    onConnectionTap: notifier.toggleConnection,
                    onEditTap: () {},
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                        child: Column(
                          children: [
                            ControllerSettingCard(
                              title: '摆动设置',
                              headerIconAsset: ControllerAssets.swingTag,
                              waveformIconAsset: ControllerAssets.swingItemTag,
                              waveformPages: _swingWaveformPages,
                              selectedPageIndex:
                                  uiState.swing.selectedPageIndex,
                              selectedItemIndex:
                                  uiState.swing.selectedItemIndex,
                              strengthIndex: uiState.swing.strength.index,
                              onWaveformSelected: (pageIndex, itemIndex) {
                                notifier.selectWaveform(
                                  ControllerMotorType.swing,
                                  pageIndex: pageIndex,
                                  itemIndex: itemIndex,
                                );
                              },
                              onStrengthChanged: (index) {
                                notifier.setStrength(
                                  ControllerMotorType.swing,
                                  StrengthLevel.values[index],
                                );
                              },
                              onSettingsTap: () {},
                            ),
                            const SizedBox(height: 18),
                            ControllerSettingCard(
                              title: '震动设置',
                              headerIconAsset: ControllerAssets.vibratingTag,
                              waveformIconAsset:
                                  ControllerAssets.vibratingItemTag,
                              waveformPages: _vibrationWaveformPages,
                              selectedPageIndex:
                                  uiState.vibration.selectedPageIndex,
                              selectedItemIndex:
                                  uiState.vibration.selectedItemIndex,
                              strengthIndex: uiState.vibration.strength.index,
                              onWaveformSelected: (pageIndex, itemIndex) {
                                notifier.selectWaveform(
                                  ControllerMotorType.vibration,
                                  pageIndex: pageIndex,
                                  itemIndex: itemIndex,
                                );
                              },
                              onStrengthChanged: (index) {
                                notifier.setStrength(
                                  ControllerMotorType.vibration,
                                  StrengthLevel.values[index],
                                );
                              },
                              onSettingsTap: () {},
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: -20,
                        left: 0,
                        right: 0,
                        child: IgnorePointer(
                          child: Image.asset(
                            _gradientAsset,
                            height: 40,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: SizedBox(
        height: 44,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.24),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chevron_left_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
            const Text(
              '控制',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
