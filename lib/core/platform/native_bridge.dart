import 'package:flutter/services.dart';

/// MethodChannel bridge for native platform communication.
class NativeBridge {
  static const _channel = MethodChannel('com.omao/native');

  Future<void> switchToUnity() async {
    await _channel.invokeMethod('switchToUnity');
  }

  Future<void> switchToFlutter() async {
    await _channel.invokeMethod('switchToFlutter');
  }

  Future<void> initUnityEngine() async {
    await _channel.invokeMethod('initUnityEngine');
  }

  Future<void> destroyUnityEngine() async {
    await _channel.invokeMethod('destroyUnityEngine');
  }
}
