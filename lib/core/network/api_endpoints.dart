/// Centralized API endpoint definitions.
class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'https://api.omao.com'; // TODO: configure

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String verifyIdentity = '/auth/verify-identity';
  static const String sendCode = '/auth/send-code';

  // Permission
  static const String permissions = '/permissions';
  static const String deviceBinding = '/devices/bind';

  // Resonance
  static const String audioEntries = '/resonance/entries';
  static const String audioCollections = '/resonance/collections';

  // Controller
  static const String waveformSync = '/controller/waveforms/sync';

  // Story
  static const String storyProgress = '/story/progress';

  // Profile
  static const String profile = '/user/profile';
  static const String updateNickname = '/user/nickname';
  static const String updateAvatar = '/user/avatar';
  static const String changePassword = '/user/change-password';
  static const String changePasswordByCode = '/user/change-password-code';
  static const String changePhone = '/user/change-phone';
  static const String feedback = '/user/feedback';
  static const String checkUpdate = '/app/check-update';
  static const String deactivateAccount = '/user/deactivate';

  // Message
  static const String messages = '/messages';
  static const String markMessageRead = '/messages/read';
  static const String markAllMessagesRead = '/messages/read-all';
}
