import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../data/profile_repository_impl.dart';
import '../../../../core/network/api_client.dart';

part 'profile_providers.g.dart';

@riverpod
ProfileRepository profileRepository(Ref ref) {
  return ProfileRepositoryImpl(ref.watch(apiClientProvider));
}

@riverpod
Future<Profile> profile(Ref ref) async {
  return ref.watch(profileRepositoryProvider).getProfile();
}
