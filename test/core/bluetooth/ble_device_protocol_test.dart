import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:omao_app/core/bluetooth/ble_device_protocol.dart';
import 'package:omao_app/core/bluetooth/models/ble_signal.dart';

void main() {
  group('BleDeviceProtocol', () {
    final protocol = BleDeviceProtocol();

    test('encodes timed signals in little-endian format', () {
      final payload = protocol.encodeTimedSignal(
        swing: 50,
        vibration: 20,
        durationMs: 300,
        delayMs: 10,
      );

      expect(payload, [50, 20, 44, 1, 10]);
    });

    test('encodes BleSignal timed mode when duration or delay is provided', () {
      final payload = protocol.encodeSignal(
        const BleSignal(
          swing: 80,
          vibration: 10,
          source: SignalSource.story,
          durationMs: 500,
          delayMs: 12,
        ),
      );

      expect(payload, [80, 10, 244, 1, 12]);
    });

    test('decodes timed payload back into a story signal', () {
      final signal = protocol.decode(
        Uint8List.fromList(const [60, 70, 255, 255, 8]),
      );

      expect(signal.swing, 60);
      expect(signal.vibration, 70);
      expect(signal.durationMs, 0xFFFF);
      expect(signal.delayMs, 8);
      expect(signal.source, SignalSource.story);
    });
  });
}
