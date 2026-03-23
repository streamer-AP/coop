import 'package:flutter/material.dart';

import '../../../../core/bluetooth/ble_connection_manager.dart';
import '../../../../core/bluetooth/models/ble_device.dart';
import '../../../../core/theme/app_colors.dart';

class DeviceCard extends StatelessWidget {
  final BleDevice? device;
  final BleConnectionState? connectionState;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;

  const DeviceCard({
    super.key,
    required this.device,
    required this.connectionState,
    required this.onConnect,
    required this.onDisconnect,
  });

  @override
  Widget build(BuildContext context) {
    final isConnected = connectionState == BleConnectionState.connected;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: isConnected ? null : onConnect,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isConnected
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isConnected ? Icons.bluetooth_connected : Icons.bluetooth,
                  color: isConnected ? AppColors.primary : Colors.grey,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device?.name ?? '未连接设备',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _statusText,
                      style: TextStyle(
                        fontSize: 13,
                        color: isConnected
                            ? AppColors.success
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isConnected)
                TextButton(
                  onPressed: onDisconnect,
                  child: const Text('断开'),
                )
              else
                TextButton(
                  onPressed: onConnect,
                  child: const Text('去连接'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String get _statusText {
    switch (connectionState) {
      case BleConnectionState.connected:
        return '已连接';
      case BleConnectionState.connecting:
        return '连接中...';
      case BleConnectionState.disconnecting:
        return '断开中...';
      default:
        return '未连接';
    }
  }
}
