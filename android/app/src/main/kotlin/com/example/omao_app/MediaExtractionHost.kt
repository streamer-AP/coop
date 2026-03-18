package com.example.omao_app

import android.media.MediaCodec
import android.media.MediaExtractor
import android.media.MediaFormat
import android.media.MediaMuxer
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.nio.ByteBuffer
import kotlin.concurrent.thread

object MediaExtractionHost {
    private const val channelName = "com.omao/media_extraction"
    private const val defaultBufferSize = 1024 * 1024

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
            "extractAudio" -> extractAudio(call, result)
            else -> result.notImplemented()
        }
    }

    private fun extractAudio(call: MethodCall, result: MethodChannel.Result) {
        val inputPath = call.argument<String>("inputPath")
        val outputPath = call.argument<String>("outputPath")

        if (inputPath.isNullOrBlank() || outputPath.isNullOrBlank()) {
            result.error("invalid_arguments", "Missing inputPath or outputPath", null)
            return
        }

        thread(name = "media-extraction") {
            var extractor: MediaExtractor? = null
            var muxer: MediaMuxer? = null
            var muxerStarted = false

            try {
                val outputFile = File(outputPath)
                outputFile.parentFile?.mkdirs()
                if (outputFile.exists()) {
                    outputFile.delete()
                }

                val mediaExtractor = MediaExtractor().apply {
                    setDataSource(inputPath)
                }
                extractor = mediaExtractor

                val audioTrackIndex = findAudioTrackIndex(mediaExtractor)
                if (audioTrackIndex == -1) {
                    result.error("missing_audio_track", "Video does not contain an audio track", null)
                    return@thread
                }

                mediaExtractor.selectTrack(audioTrackIndex)
                val inputFormat = mediaExtractor.getTrackFormat(audioTrackIndex)
                muxer = MediaMuxer(outputPath, MediaMuxer.OutputFormat.MUXER_OUTPUT_MPEG_4)
                val outputTrackIndex = muxer.addTrack(inputFormat)

                val maxInputSize = if (inputFormat.containsKey(MediaFormat.KEY_MAX_INPUT_SIZE)) {
                    inputFormat.getInteger(MediaFormat.KEY_MAX_INPUT_SIZE)
                } else {
                    defaultBufferSize
                }
                val buffer = ByteBuffer.allocateDirect(maxInputSize.coerceAtLeast(defaultBufferSize))
                val bufferInfo = MediaCodec.BufferInfo()

                muxer.start()
                muxerStarted = true
                while (true) {
                    val sampleSize = mediaExtractor.readSampleData(buffer, 0)
                    if (sampleSize < 0) {
                        break
                    }

                    bufferInfo.offset = 0
                    bufferInfo.size = sampleSize
                    bufferInfo.presentationTimeUs = mediaExtractor.sampleTime
                    bufferInfo.flags = mediaExtractor.sampleFlags

                    muxer.writeSampleData(outputTrackIndex, buffer, bufferInfo)
                    mediaExtractor.advance()
                    buffer.clear()
                }

                result.success(outputPath)
            } catch (error: Exception) {
                result.error("extract_audio_failed", error.message, null)
            } finally {
                if (muxerStarted) {
                    runCatching { muxer?.stop() }
                }
                runCatching { muxer?.release() }
                runCatching { extractor?.release() }
            }
        }
    }

    private fun findAudioTrackIndex(extractor: MediaExtractor): Int {
        for (index in 0 until extractor.trackCount) {
            val format = extractor.getTrackFormat(index)
            val mimeType = format.getString(MediaFormat.KEY_MIME)
            if (mimeType?.startsWith("audio/") == true) {
                return index
            }
        }
        return -1
    }
}
