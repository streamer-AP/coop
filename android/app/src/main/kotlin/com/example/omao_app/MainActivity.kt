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
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        MediaExtractionHost.detach()
        UnityChannelHost.detach()
        super.cleanUpFlutterEngine(flutterEngine)
    }
}
