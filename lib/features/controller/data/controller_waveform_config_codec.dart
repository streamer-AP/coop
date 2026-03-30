import '../domain/models/waveform.dart';

class ControllerWaveformConfigCodec {
  static const int totalPages = 3;
  static const int slotsPerPage = 4;
  static const int totalSlots = totalPages * slotsPerPage;
  static const int sliderRowsPerWaveform = 4;
  static const int valuesPerSliderRow = 8;
  static const int sliderStepMs = 1000;
  static const int sliderRowDurationMs = valuesPerSliderRow * sliderStepMs;

  static Map<String, dynamic> buildSavePayload(List<List<Waveform>> pages) {
    final flatWaveforms = <Waveform>[];
    for (var pageIndex = 0; pageIndex < totalPages; pageIndex++) {
      final page =
          pageIndex < pages.length ? pages[pageIndex] : const <Waveform>[];
      for (var itemIndex = 0; itemIndex < slotsPerPage; itemIndex++) {
        if (itemIndex < page.length) {
          flatWaveforms.add(page[itemIndex]);
          continue;
        }
        flatWaveforms.add(
          const Waveform(id: 0, name: '', channel: WaveformChannel.swing),
        );
      }
    }

    final payload = <String, dynamic>{};
    for (var index = 0; index < totalSlots; index++) {
      final waveform = flatWaveforms[index];
      payload['waveform${index + 1}'] = waveform.name.trim();
    }

    payload['optionalWaveformsData'] = List.generate(
      totalSlots,
      (index) => _buildOptionalWaveformData(flatWaveforms[index]),
    );
    return payload;
  }

  static List<DecodedWaveformSlot>? decodeRemoteSlots({
    required WaveformChannel channel,
    required Map<String, dynamic> response,
  }) {
    final code = response['code'] as int?;
    if (code != null && code != 200 && code != 0) {
      return null;
    }

    final data = _asStringMap(response['data']);
    if (data == null) {
      return null;
    }

    final optionalWaveformsData = data['optionalWaveformsData'];
    if (optionalWaveformsData is! List) {
      return null;
    }

    return List.generate(totalSlots, (flatIndex) {
      final page = flatIndex ~/ slotsPerPage;
      final index = flatIndex % slotsPerPage;
      final rawItem =
          flatIndex < optionalWaveformsData.length
              ? _asStringMap(optionalWaveformsData[flatIndex])
              : null;
      final name = (rawItem?['waveformName'] as String? ?? '').trim();
      final sliderValues = _decodeSliderValues(rawItem?['sliderValue']);
      final keyframes = _buildKeyframes(sliderValues);
      final durationMs = keyframes.isEmpty ? 0 : keyframes.last.timeMs;

      return DecodedWaveformSlot(
        page: page,
        index: index,
        waveform: Waveform(
          id: 0,
          name: name,
          channel: channel,
          durationMs: durationMs,
          signalIntervalMs: 200,
          signalDelayMs: 0,
          isBuiltIn: true,
          keyframes: keyframes,
        ),
      );
    });
  }

  static Map<String, dynamic> _buildOptionalWaveformData(Waveform waveform) {
    final name = waveform.name.trim();
    if (name.isEmpty) {
      return {'waveformName': '', 'sliderValue': []};
    }

    final sliderValue =
        List.generate(
          sliderRowsPerWaveform,
          (pageIndex) => _buildSliderPageData(waveform, pageIndex),
        ).where((page) => page.isNotEmpty).toList();

    return {
      'waveformName': name,
      if (sliderValue.isNotEmpty) 'sliderValue': sliderValue,
    };
  }

  static Map<String, dynamic> _buildSliderPageData(
    Waveform waveform,
    int pageIndex,
  ) {
    final enabledPages = ((waveform.durationMs + sliderRowDurationMs - 1) ~/
            sliderRowDurationMs)
        .clamp(1, sliderRowsPerWaveform);
    if (pageIndex >= enabledPages) {
      return {};
    }

    final pageStartMs = pageIndex * sliderRowDurationMs;
    final pageEndMs = pageStartMs + sliderRowDurationMs;
    final values = List<int>.filled(valuesPerSliderRow, 0);
    var hasValue = false;

    final pageKeyframes =
        waveform.keyframes
            .where(
              (keyframe) =>
                  keyframe.timeMs > pageStartMs && keyframe.timeMs <= pageEndMs,
            )
            .toList()
          ..sort((a, b) => a.timeMs.compareTo(b.timeMs));

    for (final keyframe in pageKeyframes) {
      final relativeMs = keyframe.timeMs - pageStartMs;
      final valueIndex = ((relativeMs - 1) ~/ sliderStepMs).clamp(
        0,
        values.length - 1,
      );
      values[valueIndex] = keyframe.value;
      hasValue = true;
    }

    if (!hasValue) {
      return {};
    }

    return {
      'value1': values[0],
      'value2': values[1],
      'value3': values[2],
      'value4': values[3],
      'value5': values[4],
      'value6': values[5],
      'value7': values[6],
      'value8': values[7],
    };
  }

  static List<List<int>> _decodeSliderValues(Object? rawSliderValue) {
    if (rawSliderValue is! List) {
      return const [];
    }

    return rawSliderValue.map((row) {
      final rowMap = _asStringMap(row);
      return List<int>.generate(valuesPerSliderRow, (index) {
        final value = rowMap?['value${index + 1}'];
        if (value is int) {
          return value;
        }
        if (value is num) {
          return value.toInt();
        }
        return 0;
      });
    }).toList();
  }

  static List<WaveformKeyframe> _buildKeyframes(List<List<int>> sliderValues) {
    final keyframes = <WaveformKeyframe>[];
    var timeMs = sliderStepMs;

    for (final row in sliderValues) {
      for (final value in row) {
        keyframes.add(WaveformKeyframe(timeMs: timeMs, value: value));
        timeMs += sliderStepMs;
      }
    }

    return keyframes;
  }

  static Map<String, dynamic>? _asStringMap(Object? value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map((key, mapValue) => MapEntry(key.toString(), mapValue));
    }
    return null;
  }
}

class DecodedWaveformSlot {
  const DecodedWaveformSlot({
    required this.page,
    required this.index,
    required this.waveform,
  });

  final int page;
  final int index;
  final Waveform waveform;

  bool get isEmpty => waveform.name.trim().isEmpty;
}
