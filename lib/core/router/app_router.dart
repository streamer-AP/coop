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
import '../../features/auth/presentation/screens/verification_code_screen.dart';
import '../../features/controller/domain/models/waveform.dart';
import '../../features/controller/presentation/screens/controller_entry_screen.dart';
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
import '../../features/profile/presentation/screens/qr_scanner_screen.dart';
import '../../features/profile/presentation/screens/user_agreement_screen.dart';
import '../../features/resonance/presentation/screens/add_to_collection_screen.dart';
import '../../features/resonance/presentation/screens/collection_detail_screen.dart';
import '../../features/resonance/presentation/screens/import_screen.dart';
import '../../features/resonance/presentation/screens/player_screen.dart';
import '../../features/resonance/presentation/screens/resonance_screen.dart';
import '../../features/story/presentation/screens/story_screen.dart';
import 'route_names.dart';

part 'app_router.g.dart';

const _debugRouteDefine = String.fromEnvironment('OMAO_DEBUG_ROUTE');
const _debugBypassAuthDefine = bool.fromEnvironment('OMAO_DEBUG_BYPASS_AUTH');

@riverpod
GoRouter appRouter(Ref ref) {
  final notifier = _AuthChangeNotifier(ref);
  final debugBypassAuth = _isDebugAuthBypassEnabled;
  final debugInitialLocation = _debugInitialLocation;

  return GoRouter(
    initialLocation: debugInitialLocation ?? '/startup',
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
        path: '/verification-code',
        name: RouteNames.verificationCode,
        builder: (context, state) {
          final query = state.uri.queryParameters;
          final phone = query['phone'] ?? '';
          final title = query['title'] ?? '';
          final flow = VerificationCodeFlow.fromRouteValue(query['flow']);

          return VerificationCodeScreen(phone: phone, title: title, flow: flow);
        },
      ),
      GoRoute(
        path: '/setup-password',
        name: RouteNames.setupPassword,
        builder: (context, state) {
          final extra = state.extra as Map<String, String>? ?? {};
          return SetupPasswordScreen(
            phone: extra['phone'] ?? '',
            code: extra['code'] ?? '',
          );
        },
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
        path: '/collection/:id/add-audio',
        name: RouteNames.addToCollection,
        builder: (context, state) {
          final collectionId =
              int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          final extra = state.extra;
          final existingEntryIds =
              extra is List
                  ? extra.whereType<int>().toList(growable: false)
                  : const <int>[];

          return AddToCollectionScreen(
            collectionId: collectionId,
            existingEntryIds: existingEntryIds,
          );
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
        builder: (context, state) => const ControllerEntryScreen(),
      ),
      GoRoute(
        path: '/waveform-editor',
        name: RouteNames.waveformEditor,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final waveform = extra?['waveform'] as Waveform?;
          final channel =
              extra?['channel'] as WaveformChannel? ?? WaveformChannel.swing;
          return WaveformEditorScreen(
            existingWaveform: waveform,
            channel: channel,
          );
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
        path: '/profile/change-password/original',
        name: RouteNames.originalPasswordChange,
        builder: (context, state) => const OriginalPasswordScreen(),
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
        path: '/profile/qr-scanner',
        name: RouteNames.qrScanner,
        builder: (context, state) => const QrScannerScreen(),
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
      if (debugBypassAuth) {
        return null;
      }

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
        '/verification-code',
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

bool get _isDebugAuthBypassEnabled =>
    kDebugMode && (_debugBypassAuthDefine || _debugRouteDefine.isNotEmpty);

String? get _debugInitialLocation {
  if (!_isDebugAuthBypassEnabled) return null;
  return _resolveDebugLocation(_debugRouteDefine) ?? '/';
}

String? _resolveDebugLocation(String value) {
  final normalized = value.trim().toLowerCase();
  if (normalized.isEmpty) return null;

  return switch (normalized) {
    '/' || '/home' || 'home' => '/',
    '/startup' || 'startup' => '/startup',
    '/resonance' || 'resonance' => '/resonance',
    '/player' || 'player' => '/player',
    '/controller' || 'controller' => '/controller',
    '/story' || 'story' => '/story',
    '/import' || 'import' => '/import',
    '/login' || 'login' => '/login',
    _ when normalized.startsWith('/') => normalized,
    _ => null,
  };
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
