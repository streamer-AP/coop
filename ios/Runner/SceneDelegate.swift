import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)

    if let controller = window?.rootViewController as? FlutterViewController {
      UnityChannelBridge.shared.attach(to: controller.binaryMessenger)
      MediaExtractionBridge.shared.attach(to: controller.binaryMessenger)
      // AudioArtworkBridge.shared.attach(to: controller.binaryMessenger)
      // AudioMetadataBridge.shared.attach(to: controller.binaryMessenger)
      // TextTranslationBridge.shared.attach(to: controller)
    }
  }

  override func sceneDidDisconnect(_ scene: UIScene) {
    // TextTranslationBridge.shared.detach()
    // AudioMetadataBridge.shared.detach()
    // AudioArtworkBridge.shared.detach()
    MediaExtractionBridge.shared.detach()
    UnityChannelBridge.shared.detach()
    super.sceneDidDisconnect(scene)
  }
}
