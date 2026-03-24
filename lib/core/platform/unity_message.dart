import 'package:freezed_annotation/freezed_annotation.dart';

part 'unity_message.freezed.dart';
part 'unity_message.g.dart';

@freezed
class UnityMessage with _$UnityMessage {
  const factory UnityMessage({
    required String type,
    @Default({}) Map<String, dynamic> data,
  }) = _UnityMessage;

  factory UnityMessage.fromJson(Map<String, dynamic> json) =>
      _$UnityMessageFromJson(json);
}

/// Message types from Flutter to Unity.
class FlutterToUnityMessages {
  FlutterToUnityMessages._();

  static const enterScene = 'enterScene';
  static const exitScene = 'exitScene';
  static const skipToCheckpoint = 'skipToCheckpoint';
  static const userProgress = 'userProgress';
  static const bluetoothState = 'bluetoothState';
  static const bluetoothToggle = 'bluetoothToggle';
  static const pauseStory = 'pauseStory';
  static const skipStory = 'skipStory';
  static const skipCheckpoint = 'skipCheckpoint';
  static const skipToNextCheckpoint = 'skipToNextCheckpoint';
}

/// Message types from Unity to Flutter.
class UnityToFlutterMessages {
  UnityToFlutterMessages._();

  static const bluetoothSignal = 'bluetoothSignal';
  static const sectionComplete = 'sectionComplete';
  static const checkpointReached = 'checkpointReached';
  static const animationState = 'animationState';
  static const requestExit = 'requestExit';
  static const storyComplete = 'storyComplete';
  static const storyStateChanged = 'storyStateChanged';
  static const playCheckpoint = 'playCheckpoint';
  static const stopCheckpoint = 'stopCheckpoint';
  static const playDialogue = 'playDialogue';
  static const stopDialogue = 'stopDialogue';
  static const playMotionSubtitle = 'playMotionSubtitle';
  static const checkpointProgress = 'checkpointProgress';
  static const orientationRequest = 'orientationRequest';
}
