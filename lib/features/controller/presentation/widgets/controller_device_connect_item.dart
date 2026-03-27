import 'package:flutter/material.dart';

import '../../../../core/bluetooth/models/ble_device.dart';
import '../../controller_assets.dart';

class ControllerDeviceConnectItem extends StatelessWidget {
  const ControllerDeviceConnectItem({
    required this.device,
    required this.onConnect,
    this.isConnecting = false,
    super.key,
  });

  final BleDevice device;
  final VoidCallback onConnect;
  final bool isConnecting;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: ControllerAssets.deviceLogoBackground,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Image.asset(
              ControllerAssets.deviceLogo,
              width: 20,
              height: 20,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              device.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF434343),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: isConnecting ? null : onConnect,
            child: Container(
              width: 72,
              height: 28,
              decoration: BoxDecoration(
                color: ControllerAssets.connectItemButtonBackground,
                borderRadius: BorderRadius.circular(999),
              ),
              alignment: Alignment.center,
              child:
                  isConnecting
                      ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            ControllerAssets.accent,
                          ),
                        ),
                      )
                      : const Text(
                        '连接',
                        style: TextStyle(
                          color: ControllerAssets.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
            ),
          ),
        ],
      ),
    );
  }
}
