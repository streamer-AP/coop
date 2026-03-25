import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../shared/widgets/top_banner_toast.dart';
import '../../application/providers/controller_connection_flow.dart';
import '../../controller_assets.dart';
import '../widgets/controller_device_connect_item.dart';

class FirstConnectionScreen extends ConsumerStatefulWidget {
  const FirstConnectionScreen({super.key});

  @override
  ConsumerState<FirstConnectionScreen> createState() =>
      _FirstConnectionScreen();
}

class _FirstConnectionScreen extends ConsumerState<FirstConnectionScreen>
    with SingleTickerProviderStateMixin {
  static const _backgroundAsset = ControllerAssets.blueConnectionBackground;
  static const _noDeviceAsset = ControllerAssets.noDevice;
  static const _connectButtonAsset = ControllerAssets.connectButton;
  static const _shopAsset = ControllerAssets.shopEntry;
  static const _searchLoadingAsset = ControllerAssets.searchLoading;
  static const _bluetoothLogoAsset = ControllerAssets.bluetoothLogo;
  static const _bodyTextColor = ControllerAssets.bodyText;
  static const _accentColor = ControllerAssets.accent;

  late final AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    ref.listenManual<ControllerConnectionFlowState>(
      controllerConnectionFlowProvider,
      (previous, next) {
        if (next.isSearching && !_rotationController.isAnimating) {
          unawaited(_rotationController.repeat());
        }

        if (!next.isSearching && _rotationController.isAnimating) {
          _rotationController.stop();
        }

        if (next.didTimeout && previous?.didTimeout != true && mounted) {
          TopBannerToast.show(context, message: '未搜索到设备', isError: false);
          ref
              .read(controllerConnectionFlowProvider.notifier)
              .clearTimeoutFlag();
        }

        final errorMessage = next.errorMessage;
        if (errorMessage != null &&
            errorMessage != previous?.errorMessage &&
            mounted) {
          TopBannerToast.show(context, message: errorMessage);
          ref.read(controllerConnectionFlowProvider.notifier).clearError();
        }

        final infoMessage = next.infoMessage;
        if (infoMessage != null &&
            infoMessage != previous?.infoMessage &&
            mounted) {
          TopBannerToast.show(context, message: infoMessage, isError: false);
          ref.read(controllerConnectionFlowProvider.notifier).clearInfo();
        }
      },
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    unawaited(ref.read(controllerConnectionFlowProvider.notifier).stopScan());
    super.dispose();
  }

  Future<void> _openBluetoothSettings() async {
    await openAppSettings();
  }

  void _handleConnectTap() {
    final notifier = ref.read(controllerConnectionFlowProvider.notifier);
    final connectionFlow = ref.read(controllerConnectionFlowProvider);
    if (connectionFlow.isConnecting) {
      return;
    }
    unawaited(notifier.startScan());
  }

  void _handleShopTap() {}

  @override
  Widget build(BuildContext context) {
    final connectionFlow = ref.watch(controllerConnectionFlowProvider);

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
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child:
                        connectionFlow.shouldKeepSearchContent
                            ? _buildSearchingContent(connectionFlow)
                            : _buildInitialContent(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                  child: _buildShopEntry(),
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

  Widget _buildInitialContent() {
    return Padding(
      key: const ValueKey('initial-content'),
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 52),
          Image.asset(_noDeviceAsset, width: 150, fit: BoxFit.contain),
          const SizedBox(height: 12),
          const Text(
            '暂无已配对设备，快快添加吧～',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _bodyTextColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 92),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '为了更好的体验产品，请确保您的设备您满足以下要求：',
              style: TextStyle(
                color: _bodyTextColor,
                fontSize: 12,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildRequirementList(),
          const Spacer(),
          GestureDetector(
            onTap: _handleConnectTap,
            child: AspectRatio(
              aspectRatio: 960 / 156,
              child: Image.asset(_connectButtonAsset, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildRequirementList() {
    const textStyle = TextStyle(
      color: _bodyTextColor,
      fontSize: 13,
      height: 1.6,
      fontWeight: FontWeight.w500,
    );

    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('1. 请将手机靠近已开机的玩具，请勿遮挡信号；', style: textStyle),
          const SizedBox(height: 6),
          const Text('2. 确认玩具已开机，指示灯呼吸闪烁；', style: textStyle),
          const SizedBox(height: 6),
          const Text('3. 让玩具尽量靠近手机，切勿遮挡；', style: textStyle),
          const SizedBox(height: 6),
          Wrap(
            children: [
              const Text('4. 请开启手机蓝牙和Wi-Fi开关，并授予蓝牙权限，', style: textStyle),
              GestureDetector(
                onTap: _openBluetoothSettings,
                child: const Text(
                  '打开系统蓝牙设置>',
                  style: TextStyle(
                    color: _bodyTextColor,
                    fontSize: 13,
                    height: 1.6,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                    decorationColor: _bodyTextColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchingContent(ControllerConnectionFlowState connectionFlow) {
    return Padding(
      key: const ValueKey('searching-content'),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 72),
          SizedBox(
            width: 180,
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                RotationTransition(
                  turns: _rotationController,
                  child: Image.asset(
                    _searchLoadingAsset,
                    width: 180,
                    height: 180,
                    fit: BoxFit.contain,
                  ),
                ),
                Image.asset(
                  _bluetoothLogoAsset,
                  height: 56,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '设备搜索中...',
            style: TextStyle(
              color: _accentColor,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            connectionFlow.isConnecting
                ? '请保持设备靠近手机并稍候'
                : connectionFlow.hasMultipleDevices
                ? '请选择要连接的设备'
                : '请将手机靠近设备并保持蓝牙打开',
            textAlign: TextAlign.center,
            style: const TextStyle(color: _bodyTextColor, fontSize: 13),
          ),
          const SizedBox(height: 28),
          if (connectionFlow.hasMultipleDevices)
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      itemCount: connectionFlow.devices.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final device = connectionFlow.devices[index];
                        return ControllerDeviceConnectItem(
                          device: device,
                          isConnecting:
                              connectionFlow.connectingDeviceId == device.id,
                          onConnect:
                              () => ref
                                  .read(
                                    controllerConnectionFlowProvider.notifier,
                                  )
                                  .connectDevice(device),
                        );
                      },
                    ),
                  ),
                  if (connectionFlow.isSearching) ...[
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _accentColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '发现更多设备...',
                          style: TextStyle(
                            color: _accentColor.withValues(alpha: 0.88),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ],
              ),
            )
          else
            const Spacer(),
        ],
      ),
    );
  }

  Widget _buildShopEntry() {
    return GestureDetector(
      onTap: _handleShopTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text.rich(
            TextSpan(
              text: '还没拥有OMAO？',
              style: TextStyle(
                color: _accentColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              children: [
                TextSpan(
                  text: '前往购买',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    decorationColor: _accentColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          Image.asset(_shopAsset, width: 14, height: 14, fit: BoxFit.contain),
        ],
      ),
    );
  }
}
