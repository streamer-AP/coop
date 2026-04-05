import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/bluetooth/ble_connection_manager.dart';
import '../../../../core/network/api_client.dart';
import '../../data/permission_repository_impl.dart';
import '../../domain/repositories/permission_repository.dart';

part 'permission_providers.g.dart';

@Riverpod(keepAlive: true)
PermissionRepository permissionRepository(Ref ref) {
  return PermissionRepositoryImpl(
    ref.watch(apiClientProvider),
    bleManager: ref.watch(bleConnectionManagerProvider),
  );
}
