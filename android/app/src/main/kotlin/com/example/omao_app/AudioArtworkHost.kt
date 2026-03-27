package com.example.omao_app

import android.media.MediaMetadataRetriever
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import kotlin.concurrent.thread

object AudioArtworkHost {
    private const val channelName = "com.omao/audio_artwork"

    private var channel: MethodChannel? = null

    fun attach(messenger: BinaryMessenger) {
        channel = MethodChannel(messenger, channelName).apply {
            setMethodCallHandler(::handleMethodCall)
        }
    }

    fun detach() {
        channel?.setMethodCallHandler(null)
        channel = null
    }

    private fun handleMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "extractEmbeddedArtwork" -> extractEmbeddedArtwork(call, result)
            else -> result.notImplemented()
        }
    }

    private fun extractEmbeddedArtwork(call: MethodCall, result: MethodChannel.Result) {
        val inputPath = call.argument<String>("inputPath")
        val outputPath = call.argument<String>("outputPath")

        if (inputPath.isNullOrBlank() || outputPath.isNullOrBlank()) {
            result.error("invalid_arguments", "Missing inputPath or outputPath", null)
            return
        }

        thread(name = "audio-artwork") {
            val retriever = MediaMetadataRetriever()
            try {
                retriever.setDataSource(inputPath)
                val artworkBytes = retriever.embeddedPicture
                if (artworkBytes == null || artworkBytes.isEmpty()) {
                    result.success(null)
                    return@thread
                }

                val actualOutputPath = buildOutputPath(
                    suggestedOutputPath = outputPath,
                    extension = detectArtworkExtension(artworkBytes),
                )
                val outputFile = File(actualOutputPath)
                outputFile.parentFile?.mkdirs()
                if (outputFile.exists()) {
                    outputFile.delete()
                }
                outputFile.writeBytes(artworkBytes)
                result.success(actualOutputPath)
            } catch (error: Exception) {
                result.error(
                    "extract_artwork_failed",
                    error.message ?: "Failed to extract embedded artwork",
                    null,
                )
            } finally {
                runCatching { retriever.release() }
            }
        }
    }

    private fun detectArtworkExtension(bytes: ByteArray): String {
        if (bytes.size >= 3 &&
            bytes[0] == 0xFF.toByte() &&
            bytes[1] == 0xD8.toByte() &&
            bytes[2] == 0xFF.toByte()
        ) {
            return ".jpg"
        }

        if (bytes.size >= 8 &&
            bytes[0] == 0x89.toByte() &&
            bytes[1] == 0x50.toByte() &&
            bytes[2] == 0x4E.toByte() &&
            bytes[3] == 0x47.toByte()
        ) {
            return ".png"
        }

        if (bytes.size >= 6) {
            val header = bytes.copyOfRange(0, 6).toString(Charsets.US_ASCII)
            if (header == "GIF87a" || header == "GIF89a") {
                return ".gif"
            }
        }

        if (bytes.size >= 12) {
            val riff = bytes.copyOfRange(0, 4).toString(Charsets.US_ASCII)
            val webp = bytes.copyOfRange(8, 12).toString(Charsets.US_ASCII)
            if (riff == "RIFF" && webp == "WEBP") {
                return ".webp"
            }
        }

        if (bytes.size >= 2 &&
            bytes[0] == 0x42.toByte() &&
            bytes[1] == 0x4D.toByte()
        ) {
            return ".bmp"
        }

        return ".jpg"
    }

    private fun buildOutputPath(suggestedOutputPath: String, extension: String): String {
        val normalizedExtension = if (extension.startsWith(".")) extension else ".$extension"
        val suggestedFile = File(suggestedOutputPath)
        val parent = suggestedFile.parentFile ?: File(".")
        val suggestedName = suggestedFile.name
        val dotIndex = suggestedName.lastIndexOf('.')
        val baseName = if (dotIndex > 0) suggestedName.substring(0, dotIndex) else suggestedName

        var candidate = File(parent, "$baseName$normalizedExtension")
        var counter = 1
        while (candidate.exists()) {
            candidate = File(parent, "$baseName($counter)$normalizedExtension")
            counter++
        }

        return candidate.absolutePath
    }
}
