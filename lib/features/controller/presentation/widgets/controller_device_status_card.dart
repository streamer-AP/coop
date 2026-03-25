import 'dart:async';

import 'package:flutter/material.dart';

import '../../application/providers/controller_ui_providers.dart';
import '../../controller_assets.dart';

class ControllerDeviceStatusCard extends StatefulWidget {
  const ControllerDeviceStatusCard({
    required this.deviceName,
    required this.batteryLevel,
    required this.connectionStatus,
    required this.onConnectionTap,
    required this.onEditTap,
    super.key,
  });

  final String deviceName;
  final int batteryLevel;
  final DeviceConnectionStatus connectionStatus;
  final VoidCallback onConnectionTap;
  final VoidCallback onEditTap;

  @override
  State<ControllerDeviceStatusCard> createState() =>
      _ControllerDeviceStatusCardState();
}

class _ControllerDeviceStatusCardState extends State<ControllerDeviceStatusCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _syncAnimation();
  }

  @override
  void didUpdateWidget(covariant ControllerDeviceStatusCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.connectionStatus != widget.connectionStatus) {
      _syncAnimation();
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusConfig = _statusConfig(widget.connectionStatus);
    final buttonLabel = _buttonLabel(widget.connectionStatus);

    return Container(
      height: 104,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(ControllerAssets.deviceStatusBackground),
          fit: BoxFit.fill,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 16, 14),
        child: Row(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  ControllerAssets.deviceLogo,
                  width: 40,
                  height: 40,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Image.asset(
                      ControllerAssets.power,
                      width: 14,
                      height: 14,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.batteryLevel}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          widget.deviceName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: widget.onEditTap,
                        child: Padding(
                          padding: const EdgeInsets.all(2),
                          child: Image.asset(
                            ControllerAssets.edit,
                            width: 16,
                            height: 16,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        statusConfig.icon,
                        const SizedBox(width: 6),
                        Text(
                          statusConfig.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap:
                  widget.connectionStatus == DeviceConnectionStatus.connecting
                      ? null
                      : widget.onConnectionTap,
              child: Container(
                width: 92,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(18),
                ),
                alignment: Alignment.center,
                child:
                    widget.connectionStatus == DeviceConnectionStatus.connecting
                        ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            RotationTransition(
                              turns: _rotationController,
                              child: Image.asset(
                                ControllerAssets.connectionLoading,
                                width: 16,
                                height: 16,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              buttonLabel,
                              style: const TextStyle(
                                color: ControllerAssets.accent,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                        : Text(
                          buttonLabel,
                          style: const TextStyle(
                            color: ControllerAssets.accent,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _StatusConfig _statusConfig(DeviceConnectionStatus status) {
    return switch (status) {
      DeviceConnectionStatus.connected => _StatusConfig(
        label: '设备已连接',
        icon: Image.asset(
          ControllerAssets.connectionYes,
          width: 12,
          height: 12,
          fit: BoxFit.contain,
        ),
      ),
      DeviceConnectionStatus.connecting => _StatusConfig(
        label: '设备连接中',
        icon: Image.asset(
          ControllerAssets.connectionNo,
          width: 12,
          height: 12,
          fit: BoxFit.contain,
        ),
      ),
      DeviceConnectionStatus.disconnected => _StatusConfig(
        label: '设备未连接',
        icon: Image.asset(
          ControllerAssets.connectionNo,
          width: 12,
          height: 12,
          fit: BoxFit.contain,
        ),
      ),
    };
  }

  String _buttonLabel(DeviceConnectionStatus status) {
    return switch (status) {
      DeviceConnectionStatus.disconnected => '连接',
      DeviceConnectionStatus.connecting => '连接中',
      DeviceConnectionStatus.connected => '断开连接',
    };
  }

  void _syncAnimation() {
    if (widget.connectionStatus == DeviceConnectionStatus.connecting) {
      unawaited(_rotationController.repeat());
    } else {
      _rotationController
        ..stop()
        ..reset();
    }
  }
}

class _StatusConfig {
  const _StatusConfig({required this.label, required this.icon});

  final String label;
  final Widget icon;
}
