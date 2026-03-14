/// Centralized API endpoint definitions.
class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'https://api.omao.com'; // TODO: configure

  // Auth
  static const String loginByCode = '/auth/loginByCode';
  static const String loginByPassword = '/auth/loginByPassword';
  static const String register = '/auth/register';
  static const String setupPassword = '/auth/setupPassword';
  static const String resetPassword = '/auth/resetPassword';
  static const String changePassword = '/auth/changePassword';
  static const String sendCode = '/auth/sendCode';
  static const String logout = '/auth/logout';
  static const String deactivateAccount = '/auth/deactivate';
  static const String getCurrentUserInfo = '/auth/getCurrentUserInfo';

  // Identity verification
  static const String realNameVerify = '/userAccounts/realNameVerify';

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
  static const String changePhone = '/user/change-phone';
  static const String feedback = '/user/feedback';
  static const String checkUpdate = '/app/check-update';

  // Message
  static const String messages = '/messages';
  static const String markMessageRead = '/messages/read';
  static const String markAllMessagesRead = '/messages/read-all';

  // Resource
  static const String downloadUrl = '/encrypted/downloadUrl';
}
