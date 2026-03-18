import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart' hide PlayerState;
import 'package:path/path.dart' as p;

import '../../../../core/logging/app_logger.dart';
import '../../domain/models/audio_entry.dart';

/// Wraps just_audio AudioPlayer + audio_service AudioHandler for background
/// playback and system media controls.
class AudioPlayerService {
  static const Set<String> _supportedMediaExtensions = {
    'mp3',
    'wav',
    'flac',
    'aac',
    'm4a',
    'ogg',
    'wma',
    'opus',
    'amr',
    'aiff',
    'aif',
    'mp4',
    'mkv',
    'avi',
    'mov',
    'wmv',
    'flv',
    'webm',
    'm4v',
    '3gp',
  };

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

      final file = File(path);
      if (!await file.exists()) {
        throw Exception('音频文件不存在');
      }

      if (await file.length() <= 0) {
        throw Exception('音频文件为空');
      }

      await _validatePlayableFile(path, file);

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
      AppLogger().error('Failed to set source', error: e, stackTrace: st);
      throw Exception(_normalizePlaybackError(e, path));
    }
  }

  Future<void> _validatePlayableFile(String path, File file) async {
    final ext = p.extension(path).toLowerCase().replaceFirst('.', '');
    if (ext.isNotEmpty && !_supportedMediaExtensions.contains(ext)) {
      throw Exception('不支持的媒体格式: .$ext');
    }

    // Detect obvious text/JSON/XML payloads that were imported by mistake.
    final header = await _readHeader(file, length: 128);
    if (header.isEmpty) return;
    if (!_looksLikeText(header)) return;

    final headerText = String.fromCharCodes(header).trimLeft();
    final textMarkers = <String>[
      '{',
      '[',
      '<',
      'WEBVTT',
      '[00:',
      '[01:',
      '[02:',
      '1\n00:',
      '#EXTM3U',
    ];
    if (textMarkers.any(headerText.startsWith)) {
      throw Exception('文件内容不是可播放音频，请重新导入媒体文件');
    }
  }

  Future<List<int>> _readHeader(File file, {required int length}) async {
    final raf = await file.open();
    try {
      final fileLength = await raf.length();
      final safeLength = fileLength < length ? fileLength : length;
      if (safeLength <= 0) return const [];
      return raf.read(safeLength);
    } finally {
      await raf.close();
    }
  }

  bool _looksLikeText(List<int> bytes) {
    if (bytes.isEmpty) return false;
    var printable = 0;
    for (final b in bytes) {
      if (b == 0) return false;
      if (b == 9 || b == 10 || b == 13 || (b >= 32 && b <= 126)) {
        printable++;
      }
    }
    return printable / bytes.length > 0.9;
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
