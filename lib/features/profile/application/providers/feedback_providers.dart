import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'profile_providers.dart';

part 'feedback_providers.g.dart';

@riverpod
class FeedbackNotifier extends _$FeedbackNotifier {
  @override
  FutureOr<void> build() {}

  Future<bool> submitFeedback(String content) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(profileRepositoryProvider).submitFeedback(content);
    });
    return !state.hasError;
  }
}
