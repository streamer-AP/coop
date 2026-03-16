import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

class FirstConnectionScreen extends ConsumerStatefulWidget {
  const FirstConnectionScreen({super.key});

  @override
  ConsumerState<FirstConnectionScreen> createState() =>
      _FirstConnectionScreen();
}

class _FirstConnectionScreen extends ConsumerState<FirstConnectionScreen>
    with SingleTickerProviderStateMixin {
  static const _backgroundAsset = 'assets/images/icon_blue_con_bg.png';
  static const _noDeviceAsset = 'assets/images/icon_no_device.png';
  static const _connectButtonAsset = 'assets/images/icon_go_con_btn.png';
  static const _shopAsset = 'assets/images/icon_go_shop.png';
  static const _searchLoadingAsset = 'assets/images/icon_search_loading.png';
  static const _bluetoothLogoAsset = 'assets/images/icon_blue_logo.png';
  static const _bodyTextColor = Color(0xFF797979);
  static const _accentColor = Color(0xFF6A53A7);

  late final AnimationController _rotationController;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  Future<void> _openBluetoothSettings() async {
    await openAppSettings();
  }

  void _handleConnectTap() {
    if (_isSearching) {
      return;
    }

    setState(() {
      _isSearching = true;
    });
    unawaited(_rotationController.repeat());
  }

  void _handleShopTap() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                        _isSearching
                            ? _buildSearchingContent()
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

  Widget _buildSearchingContent() {
    return Padding(
      key: const ValueKey('searching-content'),
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const SizedBox(height: 92),
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
          const Text(
            '请将手机靠近设备并保持蓝牙打开',
            textAlign: TextAlign.center,
            style: TextStyle(color: _bodyTextColor, fontSize: 13),
          ),
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
