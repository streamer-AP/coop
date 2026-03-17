import 'dart:async';
import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart' hide PlayerState;

import '../../../../core/logging/app_logger.dart';
import '../../domain/models/audio_entry.dart';

/// Wraps just_audio AudioPlayer + audio_service AudioHandler for background
/// playback and system media controls.
class AudioPlayerService {
  final AudioPlayer _player = AudioPlayer();
  late final OmaoAudioHandler _audioHandler;
  bool _initialized = false;
  VoidCallback? _onSkipToNext;
  VoidCallback? _onSkipToPrevious;

  AudioPlayer get player => _player;

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<bool> get playingStream => _player.playingStream;
  Stream<ProcessingState> get processingStateStream =>
      _player.processingStateStream;

  /// Stream that emits when a track completes naturally.
  Stream<void> get completionStream => _player.processingStateStream.where(
    (state) => state == ProcessingState.completed,
  );

  Future<void> initialize() async {
    if (_initialized) return;

    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());

    _audioHandler = await AudioService.init(
      builder: () => OmaoAudioHandler(_player),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.omao.audio',
        androidNotificationChannelName: 'OMAO Playback',
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
      ),
    );
    _audioHandler.onSkipToNext = _onSkipToNext;
    _audioHandler.onSkipToPrevious = _onSkipToPrevious;

    _initialized = true;
    AppLogger().info('AudioPlayerService initialized');
  }

  void setSkipHandlers({
    VoidCallback? onSkipToNext,
    VoidCallback? onSkipToPrevious,
  }) {
    _onSkipToNext = onSkipToNext;
    _onSkipToPrevious = onSkipToPrevious;
    if (_initialized) {
      _audioHandler.onSkipToNext = onSkipToNext;
      _audioHandler.onSkipToPrevious = onSkipToPrevious;
    }
  }

  Future<void> setSource(AudioEntry entry) async {
    try {
      await _player.setFilePath(entry.filePath);
      _audioHandler.mediaItem.add(
        MediaItem(
          id: entry.id.toString(),
          title: entry.title,
          duration: Duration(milliseconds: entry.durationMs),
          artUri: entry.coverPath != null ? Uri.file(entry.coverPath!) : null,
        ),
      );
    } catch (e, st) {
      AppLogger().error('Failed to set source', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<void> play() async {
    await _player.play();
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> seekTo(Duration position) async {
    await _player.seek(position);
  }

  Future<void> stop() async {
    await _player.stop();
  }

  void updateMediaItem(AudioEntry entry) {
    _audioHandler.mediaItem.add(
      MediaItem(
        id: entry.id.toString(),
        title: entry.title,
        duration: Duration(milliseconds: entry.durationMs),
        artUri: entry.coverPath != null ? Uri.file(entry.coverPath!) : null,
      ),
    );
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}

/// Bridges system media controls (lock screen, notification) to the app.
class OmaoAudioHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _player;

  OmaoAudioHandler(this._player) {
    _player.playbackEventStream.listen(_broadcastState);
  }

  VoidCallback? onSkipToNext;
  VoidCallback? onSkipToPrevious;

  void _broadcastState(PlaybackEvent event) {
    playbackState.add(
      playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          if (_player.playing) MediaControl.pause else MediaControl.play,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: switch (_player.processingState) {
          ProcessingState.idle => AudioProcessingState.idle,
          ProcessingState.loading => AudioProcessingState.loading,
          ProcessingState.buffering => AudioProcessingState.buffering,
          ProcessingState.ready => AudioProcessingState.ready,
          ProcessingState.completed => AudioProcessingState.completed,
        },
        playing: _player.playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: event.currentIndex,
      ),
    );
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> stop() async {
    await _player.stop();
    return super.stop();
  }

  @override
  Future<void> skipToNext() async {
    onSkipToNext?.call();
  }

  @override
  Future<void> skipToPrevious() async {
    onSkipToPrevious?.call();
  }
}
