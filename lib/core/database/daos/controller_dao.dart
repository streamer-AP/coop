import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/controller_tables.dart';

part 'controller_dao.g.dart';

@DriftAccessor(tables: [WaveformPresets, CustomWaveforms, WaveformKeyframes])
class ControllerDao extends DatabaseAccessor<AppDatabase>
    with _$ControllerDaoMixin {
  ControllerDao(super.db);

  // TODO: implement CRUD operations
}
