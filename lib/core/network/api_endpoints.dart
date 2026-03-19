/// Centralized API endpoint definitions.
class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'https://app.erotouch.cn/api';

  // Auth (all auth endpoints use query parameters, not JSON body)
  static const String loginByCode = '/auth/loginByCode';
  static const String loginByPassword = '/auth/login';
  static const String register = '/auth/registerApp';
  static const String setupPassword = '/auth/setPassword';
  static const String resetPassword = '/auth/resetPassword';
  static const String changePassword = '/auth/changePassword';
  static const String sendLoginCode = '/auth/sendLoginCode';
  static const String sendRegisterCode = '/auth/sendRegisterCode';
  static const String logout = '/auth/logout';
  static const String deactivateAccount = '/auth/cancel';
  static const String getCurrentUserInfo = '/auth/getCurrentUserInfo';

  // Identity verification
  static const String realNameVerify = '/userAccounts/realNameVerify';

  // Permission
  static const String permissions = '/permissions';

  // Device
  static const String userDevices = '/userDevices';

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
  static const String messages = '/messageBatch/app/planSendTime';
  static const String markMessageRead = '/messages/read';
  static const String markAllMessagesRead = '/messages/read-all';

  // Resource
  static const String downloadUrl = '/encrypted/downloadUrl';
}
