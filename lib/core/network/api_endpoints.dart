/// Centralized API endpoint definitions.
class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'https://api.omao.com'; // TODO: configure

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String verifyIdentity = '/auth/verify-identity';

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
}
