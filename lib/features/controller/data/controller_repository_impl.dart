import '../../../core/database/daos/controller_dao.dart';
import '../domain/models/waveform_preset.dart';
import '../domain/models/custom_waveform.dart';
import '../domain/repositories/controller_repository.dart';

class ControllerRepositoryImpl implements ControllerRepository {
  final ControllerDao _dao;

  ControllerRepositoryImpl(this._dao);

  @override
  Future<List<WaveformPreset>> getAllPresets() async {
    // TODO: implement
    throw UnimplementedError();
  }

  @override
  Future<List<CustomWaveform>> getAllCustomWaveforms() async {
    // TODO: implement
    throw UnimplementedError();
  }

  @override
  Future<int> saveCustomWaveform(CustomWaveform waveform) async {
    // TODO: implement
    throw UnimplementedError();
  }

  @override
  Future<void> deleteCustomWaveform(int id) async {
    // TODO: implement
  }

  @override
  Future<void> syncToCloud() async {
    // TODO: implement
  }
}
