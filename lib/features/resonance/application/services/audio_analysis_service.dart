import 'dart:convert';
import 'dart:io';

import '../../../../core/platform/audio_analysis_bridge.dart';
import '../../domain/models/signal_timeline.dart';

/// Service that analyzes audio files and generates SignalTimeline JSON files.
class AudioAnalysisService {
  final AudioAnalysisBridge _bridge;

  AudioAnalysisService({AudioAnalysisBridge? bridge})
      : _bridge = bridge ?? AudioAnalysisBridge();

  /// Analyzes the audio at [audioFilePath], validates the result, saves it
  /// as a JSON file, and returns the file path.
  Future<String> analyzeAndSave({
    required String audioFilePath,
    required int entryId,
    required String importDir,
  }) async {
    final jsonString = await _bridge.analyzeAudio(
      audioFilePath: audioFilePath,
    );

    // Validate by parsing
    final data = json.decode(jsonString) as Map<String, dynamic>;
    final timeline = SignalTimeline.fromJson(data);
    if (timeline.keyframes.isEmpty) {
      throw Exception('音频分析未生成任何关键帧');
    }

    // Save to file
    final outputPath = '$importDir/signal_$entryId.json';
    final file = File(outputPath);
    await file.parent.create(recursive: true);
    await file.writeAsString(jsonString);

    return outputPath;
  }
}
