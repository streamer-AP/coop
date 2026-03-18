import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'unity_message.dart';

part 'unity_bridge.g.dart';

/// Handles JSON message communication with Unity.
class UnityBridge {
  static const _channel = MethodChannel('com.omao/unity');

  final _messageController = StreamController<UnityMessage>.broadcast();

  Stream<UnityMessage> get messages => _messageController.stream;

  UnityBridge() {
    _channel.setMethodCallHandler(_handleUnityMessage);
  }

  Future<void> sendToUnity(UnityMessage message) async {
    await _channel.invokeMethod('sendToUnity', message.toJson());
  }

  Future<dynamic> _handleUnityMessage(MethodCall call) async {
    if (call.method == 'onUnityMessage') {
      final json = jsonDecode(call.arguments as String) as Map<String, dynamic>;
      _messageController.add(UnityMessage.fromJson(json));
    }
    return null;
  }

  void dispose() {
    _messageController.close();
  }
}

@Riverpod(keepAlive: true)
UnityBridge unityBridge(Ref ref) {
  final bridge = UnityBridge();
  ref.onDispose(bridge.dispose);
  return bridge;
}
