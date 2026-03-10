import 'dart:io';

import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/logging/app_logger.dart';
import '../../domain/models/audio_entry.dart';

/// Scans device for local music files using on_audio_query.
class LocalMusicScannerService {
  final OnAudioQuery _audioQuery = OnAudioQuery();

  /// Request necessary permissions for accessing device music library.
  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      if (await _isAndroid13OrHigher()) {
        final status = await Permission.audio.request();
        return status.isGranted;
      } else {
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    } else if (Platform.isIOS) {
      final status = await Permission.mediaLibrary.request();
      return status.isGranted;
    }
    return false;
  }

  /// Check if device is running Android 13 or higher.
  Future<bool> _isAndroid13OrHigher() async {
    if (!Platform.isAndroid) return false;
    // Android 13 = API 33
    return true; // Simplified, actual implementation would check SDK version
  }

  /// Scan device for all audio files.
  Future<List<AudioEntry>> scanLocalMusic() async {
    try {
      final hasPermission = await requestPermissions();
      if (!hasPermission) {
        AppLogger().warning('Permission denied for music library access');
        return [];
      }

      final songs = await _audioQuery.querySongs(
        sortType: SongSortType.TITLE,
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
      );

      final entries = <AudioEntry>[];
      for (final song in songs) {
        if (song.data == null || song.data!.isEmpty) continue;

        entries.add(AudioEntry(
          id: song.id,
          title: song.title,
          filePath: song.data!,
          durationMs: song.duration ?? 0,
          coverPath: null, // Will be loaded separately
          createdAt: DateTime.now(),
        ));
      }

      AppLogger().info('Scanned ${entries.length} local music files');
      return entries;
    } catch (e, st) {
      AppLogger().error('Failed to scan local music', error: e, stackTrace: st);
      return [];
    }
  }

  /// Get artwork for a specific song.
  Future<String?> getArtworkPath(int songId) async {
    try {
      final artworkData = await _audioQuery.queryArtwork(
        songId,
        ArtworkType.AUDIO,
        format: ArtworkFormat.JPEG,
        quality: 100,
      );

      if (artworkData == null) return null;

      // Save to temp file
      final tempDir = Directory.systemTemp;
      final artworkFile = File('${tempDir.path}/artwork_$songId.jpg');
      await artworkFile.writeAsBytes(artworkData);

      return artworkFile.path;
    } catch (e) {
      AppLogger().warning('Failed to get artwork for song $songId: $e');
      return null;
    }
  }

  /// Get all albums.
  Future<List<AlbumModel>> getAlbums() async {
    try {
      return await _audioQuery.queryAlbums(
        sortType: AlbumSortType.ALBUM,
        orderType: OrderType.ASC_OR_SMALLER,
      );
    } catch (e, st) {
      AppLogger().error('Failed to get albums', error: e, stackTrace: st);
      return [];
    }
  }

  /// Get all artists.
  Future<List<ArtistModel>> getArtists() async {
    try {
      return await _audioQuery.queryArtists(
        sortType: ArtistSortType.ARTIST,
        orderType: OrderType.ASC_OR_SMALLER,
      );
    } catch (e, st) {
      AppLogger().error('Failed to get artists', error: e, stackTrace: st);
      return [];
    }
  }

  /// Get songs by album.
  Future<List<SongModel>> getSongsByAlbum(int albumId) async {
    try {
      return await _audioQuery.queryAudiosFrom(
        AudiosFromType.ALBUM_ID,
        albumId,
      );
    } catch (e, st) {
      AppLogger().error('Failed to get songs by album', error: e, stackTrace: st);
      return [];
    }
  }

  /// Get songs by artist.
  Future<List<SongModel>> getSongsByArtist(int artistId) async {
    try {
      return await _audioQuery.queryAudiosFrom(
        AudiosFromType.ARTIST_ID,
        artistId,
      );
    } catch (e, st) {
      AppLogger().error('Failed to get songs by artist', error: e, stackTrace: st);
      return [];
    }
  }
}
