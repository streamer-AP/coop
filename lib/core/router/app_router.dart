import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/application/providers/auth_providers.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/password_login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/setup_password_screen.dart';
import '../../features/auth/presentation/screens/startup_screen.dart';
import '../../features/controller/domain/models/waveform.dart';
import '../../features/controller/presentation/screens/controller_screen.dart';
import '../../features/controller/presentation/screens/waveform_editor_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/message/presentation/screens/message_detail_screen.dart';
import '../../features/profile/presentation/screens/account_security_screen.dart';
import '../../features/profile/presentation/screens/app_info_screen.dart';
import '../../features/profile/presentation/screens/change_password_code_screen.dart';
import '../../features/profile/presentation/screens/change_password_screen.dart';
import '../../features/profile/presentation/screens/change_phone_screen.dart';
import '../../features/profile/presentation/screens/contact_screen.dart';
import '../../features/profile/presentation/screens/deactivate_account_screen.dart';
import '../../features/profile/presentation/screens/feedback_screen.dart';
import '../../features/profile/presentation/screens/privacy_policy_screen.dart';
import '../../features/profile/presentation/screens/profile_edit_screen.dart';
import '../../features/profile/presentation/screens/user_agreement_screen.dart';
import '../../features/resonance/presentation/screens/collection_detail_screen.dart';
import '../../features/resonance/presentation/screens/import_screen.dart';
import '../../features/resonance/presentation/screens/player_screen.dart';
import '../../features/resonance/presentation/screens/resonance_screen.dart';
import '../../features/story/presentation/screens/story_screen.dart';
import 'route_names.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(Ref ref) {
  final notifier = _AuthChangeNotifier(ref);

  return GoRouter(
    initialLocation: '/startup',
    refreshListenable: notifier,
    routes: [
      GoRoute(
        path: '/startup',
        name: RouteNames.startup,
        builder: (context, state) => const StartupScreen(),
      ),
      GoRoute(
        path: '/',
        name: RouteNames.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/login',
        name: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/password-login',
        name: RouteNames.passwordLogin,
        builder: (context, state) => const PasswordLoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: RouteNames.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/setup-password',
        name: RouteNames.setupPassword,
        builder: (context, state) => const SetupPasswordScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: RouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Resonance
      GoRoute(
        path: '/resonance',
        name: RouteNames.resonance,
        builder: (context, state) => const ResonanceScreen(),
      ),
      GoRoute(
        path: '/player',
        name: RouteNames.resonancePlayer,
        builder: (context, state) => const PlayerScreen(),
      ),
      GoRoute(
        path: '/collection/:id',
        name: RouteNames.collectionDetail,
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return CollectionDetailScreen(collectionId: id);
        },
      ),
      GoRoute(
        path: '/import',
        name: RouteNames.importScreen,
        builder: (context, state) => const ImportScreen(),
      ),

      // Message
      GoRoute(
        path: '/message/:id',
        name: RouteNames.messageDetail,
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return MessageDetailScreen(messageId: id);
        },
      ),

      // Controller
      GoRoute(
        path: '/controller',
        name: RouteNames.controller,
        builder: (context, state) => const ControllerScreen(),
      ),
      GoRoute(
        path: '/waveform-editor',
        name: RouteNames.waveformEditor,
        builder: (context, state) {
          final waveform = state.extra as Waveform?;
          return WaveformEditorScreen(existingWaveform: waveform);
        },
      ),

      // Story
      GoRoute(
        path: '/story',
        name: RouteNames.story,
        builder: (context, state) => const StoryScreen(),
      ),

      // Profile sub-pages
      GoRoute(
        path: '/profile/edit',
        name: RouteNames.profileEdit,
        builder: (context, state) => const ProfileEditScreen(),
      ),
      GoRoute(
        path: '/profile/account-security',
        name: RouteNames.accountSecurity,
        builder: (context, state) => const AccountSecurityScreen(),
      ),
      GoRoute(
        path: '/profile/change-password',
        name: RouteNames.changePassword,
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: '/profile/change-password-code',
        name: RouteNames.changePasswordCode,
        builder: (context, state) => const ChangePasswordCodeScreen(),
      ),
      GoRoute(
        path: '/profile/change-phone',
        name: RouteNames.changePhone,
        builder: (context, state) => const ChangePhoneScreen(),
      ),
      GoRoute(
        path: '/profile/feedback',
        name: RouteNames.feedback,
        builder: (context, state) => const FeedbackScreen(),
      ),
      GoRoute(
        path: '/profile/contact',
        name: RouteNames.contact,
        builder: (context, state) => const ContactScreen(),
      ),
      GoRoute(
        path: '/profile/user-agreement',
        name: RouteNames.userAgreement,
        builder: (context, state) => const UserAgreementScreen(),
      ),
      GoRoute(
        path: '/profile/privacy-policy',
        name: RouteNames.privacyPolicy,
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: '/profile/app-info',
        name: RouteNames.appInfo,
        builder: (context, state) => const AppInfoScreen(),
      ),
      GoRoute(
        path: '/profile/deactivate',
        name: RouteNames.deactivateAccount,
        builder: (context, state) => const DeactivateAccountScreen(),
      ),
    ],
    redirect: (context, state) {
      final authState = ref.read(authNotifierProvider);

      // Don't redirect while auth state is still loading
      if (authState.isLoading) return null;

      final isLoggedIn = authState.valueOrNull != null;
      final location = state.matchedLocation;
      const publicRoutes = [
        '/startup',
        '/login',
        '/password-login',
        '/register',
        '/setup-password',
        '/forgot-password',
        '/profile/user-agreement',
        '/profile/privacy-policy',
      ];
      final isPublicRoute = publicRoutes.contains(location);

      if (!isLoggedIn && !isPublicRoute) {
        return '/login';
      }

      if (isLoggedIn && location == '/login') {
        return '/';
      }

      return null;
    },
  );
}

class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(this._ref) {
    _sub = _ref.listen(authNotifierProvider, (_, __) {
      notifyListeners();
    });
  }

  final Ref _ref;
  late final ProviderSubscription _sub;

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }
}
