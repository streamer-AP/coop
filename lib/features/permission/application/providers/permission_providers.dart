import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/repositories/permission_repository.dart';
import '../../data/permission_repository_impl.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/database/app_database.dart';

part 'permission_providers.g.dart';

@Riverpod(keepAlive: true)
PermissionRepository permissionRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return PermissionRepositoryImpl(
    ref.watch(apiClientProvider),
    db.userDao,
  );
}
