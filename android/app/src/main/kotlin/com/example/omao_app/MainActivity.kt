package com.example.omao_app

import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : AudioServiceActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        UnityChannelHost.attach(
            messenger = flutterEngine.dartExecutor.binaryMessenger,
        )
        MediaExtractionHost.attach(
            messenger = flutterEngine.dartExecutor.binaryMessenger,
        )
        AudioArtworkHost.attach(
            messenger = flutterEngine.dartExecutor.binaryMessenger,
        )
        AudioMetadataHost.attach(
            messenger = flutterEngine.dartExecutor.binaryMessenger,
        )
        TextTranslationHost.attach(
            messenger = flutterEngine.dartExecutor.binaryMessenger,
        )
        AudioAnalysisHost.attach(
            messenger = flutterEngine.dartExecutor.binaryMessenger,
        )
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        AudioAnalysisHost.detach()
        TextTranslationHost.detach()
        AudioMetadataHost.detach()
        AudioArtworkHost.detach()
        MediaExtractionHost.detach()
        UnityChannelHost.detach()
        super.cleanUpFlutterEngine(flutterEngine)
    }
}
