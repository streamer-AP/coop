package com.example.omao_app

import android.os.Build
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

    private data class ExtractionTarget(
        val muxerOutputFormat: Int,
        val extension: String,
    )

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
                val mimeType = inputFormat.getString(MediaFormat.KEY_MIME)
                    ?.lowercase()
                    ?.trim()
                    .orEmpty()
                val extractionTarget = resolveExtractionTarget(mimeType)
                val actualOutputPath = buildOutputPath(outputPath, extractionTarget.extension)
                val outputFile = File(actualOutputPath)
                outputFile.parentFile?.mkdirs()
                if (outputFile.exists()) {
                    outputFile.delete()
                }

                muxer = MediaMuxer(actualOutputPath, extractionTarget.muxerOutputFormat)
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

                result.success(actualOutputPath)
            } catch (error: UnsupportedAudioCodecException) {
                result.error("unsupported_audio_codec", error.message, error.mimeType)
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

    private fun resolveExtractionTarget(mimeType: String): ExtractionTarget {
        return when {
            mimeType == "audio/mp4a-latm" || mimeType == "audio/aac" ->
                ExtractionTarget(
                    muxerOutputFormat = MediaMuxer.OutputFormat.MUXER_OUTPUT_MPEG_4,
                    extension = ".m4a",
                )

            mimeType == "audio/vorbis" ->
                ExtractionTarget(
                    muxerOutputFormat = MediaMuxer.OutputFormat.MUXER_OUTPUT_WEBM,
                    extension = ".webm",
                )

            mimeType == "audio/opus" && Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q ->
                ExtractionTarget(
                    muxerOutputFormat = MediaMuxer.OutputFormat.MUXER_OUTPUT_OGG,
                    extension = ".ogg",
                )

            mimeType == "audio/opus" ->
                ExtractionTarget(
                    muxerOutputFormat = MediaMuxer.OutputFormat.MUXER_OUTPUT_WEBM,
                    extension = ".webm",
                )

            mimeType == "audio/amr-wb" ||
                mimeType == "audio/3gpp" ||
                mimeType == "audio/amr" ||
                mimeType == "audio/amr-nb" -> {
                if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
                    throw UnsupportedAudioCodecException(
                        mimeType = mimeType,
                        message = "当前设备系统版本过低，暂不支持导出 AMR 音轨",
                    )
                }
                ExtractionTarget(
                    muxerOutputFormat = MediaMuxer.OutputFormat.MUXER_OUTPUT_3GPP,
                    extension = ".3gp",
                )
            }

            mimeType.isBlank() -> throw UnsupportedAudioCodecException(
                mimeType = mimeType,
                message = "无法识别视频中的音频编码，暂时无法提取",
            )

            else -> throw UnsupportedAudioCodecException(
                mimeType = mimeType,
                message = "暂不支持提取该音频编码：${describeMimeType(mimeType)}",
            )
        }
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

    private fun describeMimeType(mimeType: String): String {
        return when (mimeType) {
            "audio/flac" -> "FLAC"
            "audio/mpeg" -> "MP3"
            "audio/opus" -> "Opus"
            "audio/vorbis" -> "Vorbis"
            "audio/mp4a-latm", "audio/aac" -> "AAC"
            "audio/amr", "audio/amr-nb", "audio/amr-wb", "audio/3gpp" -> "AMR"
            else -> mimeType
        }
    }

    private class UnsupportedAudioCodecException(
        val mimeType: String,
        override val message: String,
    ) : IllegalArgumentException(message)
}
