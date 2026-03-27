import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/repositories/permission_repository.dart';
import '../../data/permission_repository_impl.dart';
import '../../../../core/network/api_client.dart';

part 'permission_providers.g.dart';

@Riverpod(keepAlive: true)
PermissionRepository permissionRepository(Ref ref) {
  return PermissionRepositoryImpl(
    ref.watch(apiClientProvider),
  );
}
