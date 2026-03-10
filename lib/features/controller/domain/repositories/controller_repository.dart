import '../models/waveform_preset.dart';
import '../models/custom_waveform.dart';

abstract class ControllerRepository {
  Future<List<WaveformPreset>> getAllPresets();
  Future<List<CustomWaveform>> getAllCustomWaveforms();
  Future<int> saveCustomWaveform(CustomWaveform waveform);
  Future<void> deleteCustomWaveform(int id);
  Future<void> syncToCloud();
}
