package com.example.omao_app

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
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
