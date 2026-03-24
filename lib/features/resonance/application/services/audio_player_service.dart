import 'dart:async';
import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart' hide PlayerState;
import 'package:path/path.dart' as p;

import '../../../../core/logging/app_logger.dart';
import '../../domain/models/audio_entry.dart';
import 'media_support.dart';

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

  Future<Duration?> setSource(AudioEntry entry) async {
    String path = '';
    try {
      path = entry.filePath.trim();
      if (path.isEmpty) {
        throw Exception('音频路径为空');
      }

      AppLogger().info(
        'Loading media entry id=${entry.id}, title=${entry.title}, ext=${p.extension(path)}, path=$path',
      );

      await ResonanceMediaSupport.ensureLikelyPlayableMediaFile(
        path,
        label: '音频文件',
      );

      final duration = await _player.setFilePath(path);
      _audioHandler.mediaItem.add(
        MediaItem(
          id: entry.id.toString(),
          title: entry.title,
          artist: entry.artist,
          duration:
              duration ??
              (entry.durationMs > 0
                  ? Duration(milliseconds: entry.durationMs)
                  : null),
          artUri: entry.coverPath != null ? Uri.file(entry.coverPath!) : null,
        ),
      );
      return duration;
    } catch (e, st) {
      AppLogger().error(
        'Failed to set source, path=$path',
        error: e,
        stackTrace: st,
      );
      throw Exception(_normalizePlaybackError(e, path));
    }
  }

  String _normalizePlaybackError(Object error, String path) {
    final raw = '$error'.trim();
    if (raw.startsWith('Exception: ')) {
      return raw.substring('Exception: '.length);
    }

    final lower = raw.toLowerCase();
    if (lower.contains('line') &&
        (lower.contains('pos') ||
            lower.contains('column') ||
            lower.contains('character'))) {
      final name = path.isEmpty ? '当前文件' : p.basename(path);
      return '媒体文件解析失败，可能导入了非音频文件：$name';
    }

    if (error is PlayerException) {
      final name = path.isEmpty ? '当前文件' : p.basename(path);
      return '音频加载失败，请检查文件格式或重新导入：$name';
    }

    return '当前音频无法播放，请检查文件格式后重试';
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
    if (!_initialized) return;

    _audioHandler.mediaItem.add(
      MediaItem(
        id: entry.id.toString(),
        title: entry.title,
        artist: entry.artist,
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
