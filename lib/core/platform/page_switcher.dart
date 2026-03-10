import 'native_bridge.dart';

/// Manages switching between Flutter and Unity containers.
class PageSwitcher {
  final NativeBridge _nativeBridge;

  PageSwitcher(this._nativeBridge);

  Future<void> showUnity() async {
    await _nativeBridge.switchToUnity();
  }

  Future<void> showFlutter() async {
    await _nativeBridge.switchToFlutter();
  }
}
