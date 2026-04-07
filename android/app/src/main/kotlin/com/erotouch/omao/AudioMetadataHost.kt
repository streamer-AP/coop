package com.erotouch.omao

import android.media.MediaMetadataRetriever
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlin.concurrent.thread

object AudioMetadataHost {
    private const val channelName = "com.omao/audio_metadata"

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
            "extractEmbeddedMetadata" -> extractEmbeddedMetadata(call, result)
            else -> result.notImplemented()
        }
    }

    private fun extractEmbeddedMetadata(call: MethodCall, result: MethodChannel.Result) {
        val inputPath = call.argument<String>("inputPath")
        if (inputPath.isNullOrBlank()) {
            result.error("invalid_arguments", "Missing inputPath", null)
            return
        }

        thread(name = "audio-metadata") {
            val retriever = MediaMetadataRetriever()
            try {
                retriever.setDataSource(inputPath)
                val payload = mapOf(
                    "title" to firstNonBlank(
                        retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_TITLE),
                    ),
                    "artist" to firstNonBlank(
                        retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_ARTIST),
                        retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_ALBUMARTIST),
                        retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_AUTHOR),
                    ),
                    "album" to firstNonBlank(
                        retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_ALBUM),
                    ),
                ).filterValues { value -> !value.isNullOrBlank() }

                result.success(payload)
            } catch (error: Exception) {
                result.error(
                    "extract_metadata_failed",
                    error.message ?: "Failed to extract embedded metadata",
                    null,
                )
            } finally {
                runCatching { retriever.release() }
            }
        }
    }

    private fun firstNonBlank(vararg values: String?): String? {
        return values.firstOrNull { !it.isNullOrBlank() }?.trim()
    }
}
