package com.erotouch.omao

import android.os.Build
import android.media.MediaCodec
import android.media.MediaCodecInfo
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
    private const val transcodeTimeoutUs = 30_000_000L // 30s

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
                val isPcm = mimeType == "audio/raw" ||
                    mimeType.startsWith("audio/pcm") ||
                    mimeType == "audio/l16"

                if (isPcm) {
                    val actualOutputPath = buildOutputPath(outputPath, ".wav")
                    val outputFile = File(actualOutputPath)
                    outputFile.parentFile?.mkdirs()
                    if (outputFile.exists()) {
                        outputFile.delete()
                    }
                    writePcmAsWav(mediaExtractor, inputFormat, actualOutputPath)
                    result.success(actualOutputPath)
                } else {
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
                }
            } catch (error: UnsupportedAudioCodecException) {
                // Direct mux not supported for this codec, try fallbacks
                extractor?.release()
                extractor = null
                if (muxerStarted) { runCatching { muxer?.stop() } }
                runCatching { muxer?.release() }
                muxer = null
                muxerStarted = false

                try {
                    val path = if (AviAudioExtractor.isAviFile(inputPath)) {
                        AviAudioExtractor.extract(inputPath, outputPath)
                    } else {
                        transcodeToAac(inputPath, outputPath)
                    }
                    result.success(path)
                } catch (te: Exception) {
                    result.error("extract_audio_failed", te.message ?: "转码失败", null)
                }
                return@thread
            } catch (error: Exception) {
                val msg = error.message ?: ""
                val isExtractorError = msg.contains("instantiate") ||
                    msg.contains("Failed to") ||
                    msg.contains("setDataSource")

                if (isExtractorError) {
                    // MediaExtractor can't parse the container – try AVI demuxer or transcode
                    extractor?.release()
                    extractor = null
                    if (muxerStarted) { runCatching { muxer?.stop() } }
                    runCatching { muxer?.release() }
                    muxer = null
                    muxerStarted = false

                    try {
                        val path = if (AviAudioExtractor.isAviFile(inputPath)) {
                            AviAudioExtractor.extract(inputPath, outputPath)
                        } else {
                            transcodeToAac(inputPath, outputPath)
                        }
                        result.success(path)
                    } catch (te: Exception) {
                        result.error("extract_audio_failed",
                            te.message ?: "当前设备不支持该视频格式的音频提取", null)
                    }
                    return@thread
                }

                result.error("extract_audio_failed", msg, null)
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

    private fun writePcmAsWav(
        extractor: MediaExtractor,
        format: MediaFormat,
        outputPath: String,
    ) {
        val sampleRate = format.getInteger(MediaFormat.KEY_SAMPLE_RATE)
        val channelCount = format.getInteger(MediaFormat.KEY_CHANNEL_COUNT)
        val bitsPerSample = if (format.containsKey("bits-per-sample")) {
            format.getInteger("bits-per-sample")
        } else {
            16
        }
        val byteRate = sampleRate * channelCount * (bitsPerSample / 8)
        val blockAlign = channelCount * (bitsPerSample / 8)

        val maxInputSize = if (format.containsKey(MediaFormat.KEY_MAX_INPUT_SIZE)) {
            format.getInteger(MediaFormat.KEY_MAX_INPUT_SIZE)
        } else {
            defaultBufferSize
        }
        val buffer = java.nio.ByteBuffer.allocateDirect(maxInputSize.coerceAtLeast(defaultBufferSize))

        // Collect all PCM data first
        val pcmData = java.io.ByteArrayOutputStream()
        while (true) {
            val sampleSize = extractor.readSampleData(buffer, 0)
            if (sampleSize < 0) break
            val bytes = ByteArray(sampleSize)
            buffer.get(bytes, 0, sampleSize)
            pcmData.write(bytes)
            extractor.advance()
            buffer.clear()
        }

        val pcmBytes = pcmData.toByteArray()
        val dataSize = pcmBytes.size

        java.io.FileOutputStream(outputPath).use { fos ->
            val header = java.nio.ByteBuffer.allocate(44).apply {
                order(java.nio.ByteOrder.LITTLE_ENDIAN)
                // RIFF header
                put("RIFF".toByteArray())
                putInt(36 + dataSize)
                put("WAVE".toByteArray())
                // fmt sub-chunk
                put("fmt ".toByteArray())
                putInt(16) // PCM format chunk size
                putShort(1) // Audio format: PCM
                putShort(channelCount.toShort())
                putInt(sampleRate)
                putInt(byteRate)
                putShort(blockAlign.toShort())
                putShort(bitsPerSample.toShort())
                // data sub-chunk
                put("data".toByteArray())
                putInt(dataSize)
            }
            fos.write(header.array())
            fos.write(pcmBytes)
        }
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

    /**
     * Decode audio from any format MediaExtractor can read, then re-encode as
     * AAC and mux into an M4A container. This handles codecs that MediaMuxer
     * cannot directly remux (e.g. FLAC, MP3, WMA inside AVI, etc.).
     */
    private fun transcodeToAac(inputPath: String, outputPath: String): String {
        val actualOutputPath = buildOutputPath(outputPath, ".m4a")
        val outputFile = File(actualOutputPath)
        outputFile.parentFile?.mkdirs()
        if (outputFile.exists()) outputFile.delete()

        val extractor = MediaExtractor().apply { setDataSource(inputPath) }
        try {
            val audioTrackIndex = findAudioTrackIndex(extractor)
            if (audioTrackIndex == -1) {
                throw Exception("视频中不包含音频轨道")
            }

            extractor.selectTrack(audioTrackIndex)
            val inputFormat = extractor.getTrackFormat(audioTrackIndex)
            val sampleRate = inputFormat.getInteger(MediaFormat.KEY_SAMPLE_RATE)
            val channelCount = inputFormat.getInteger(MediaFormat.KEY_CHANNEL_COUNT)
            val inputMime = inputFormat.getString(MediaFormat.KEY_MIME) ?: ""

            // --- Set up decoder ---
            val decoder = MediaCodec.createDecoderByType(inputMime)
            decoder.configure(inputFormat, null, null, 0)
            decoder.start()

            // --- Set up encoder (AAC-LC) ---
            val encoderFormat = MediaFormat.createAudioFormat(
                MediaFormat.MIMETYPE_AUDIO_AAC,
                sampleRate,
                channelCount,
            ).apply {
                setInteger(MediaFormat.KEY_BIT_RATE, 192_000)
                setInteger(MediaFormat.KEY_AAC_PROFILE,
                    MediaCodecInfo.CodecProfileLevel.AACObjectLC)
                setInteger(MediaFormat.KEY_MAX_INPUT_SIZE, defaultBufferSize)
            }
            val encoder = MediaCodec.createEncoderByType(MediaFormat.MIMETYPE_AUDIO_AAC)
            encoder.configure(encoderFormat, null, null, MediaCodec.CONFIGURE_FLAG_ENCODE)
            encoder.start()

            // --- Set up muxer (deferred until encoder output format is available) ---
            var muxer: MediaMuxer? = null
            var muxerTrackIndex = -1
            var muxerStarted = false

            val bufferInfo = MediaCodec.BufferInfo()
            var inputDone = false
            var decoderDone = false
            var allDone = false

            try {
                while (!allDone) {
                    // Feed data into decoder
                    if (!inputDone) {
                        val inIdx = decoder.dequeueInputBuffer(10_000)
                        if (inIdx >= 0) {
                            val buf = decoder.getInputBuffer(inIdx)!!
                            val sampleSize = extractor.readSampleData(buf, 0)
                            if (sampleSize < 0) {
                                decoder.queueInputBuffer(inIdx, 0, 0, 0,
                                    MediaCodec.BUFFER_FLAG_END_OF_STREAM)
                                inputDone = true
                            } else {
                                decoder.queueInputBuffer(inIdx, 0, sampleSize,
                                    extractor.sampleTime, 0)
                                extractor.advance()
                            }
                        }
                    }

                    // Drain decoder output → feed into encoder
                    if (!decoderDone) {
                        val outIdx = decoder.dequeueOutputBuffer(bufferInfo, 10_000)
                        if (outIdx >= 0) {
                            val decoded = decoder.getOutputBuffer(outIdx)!!
                            val isEos = bufferInfo.flags and
                                MediaCodec.BUFFER_FLAG_END_OF_STREAM != 0

                            if (bufferInfo.size > 0) {
                                val encInIdx = encoder.dequeueInputBuffer(10_000)
                                if (encInIdx >= 0) {
                                    val encBuf = encoder.getInputBuffer(encInIdx)!!
                                    encBuf.clear()
                                    val limit = minOf(bufferInfo.size, encBuf.capacity())
                                    decoded.limit(bufferInfo.offset + limit)
                                    decoded.position(bufferInfo.offset)
                                    encBuf.put(decoded)
                                    encoder.queueInputBuffer(encInIdx, 0, limit,
                                        bufferInfo.presentationTimeUs, 0)
                                }
                            }

                            decoder.releaseOutputBuffer(outIdx, false)

                            if (isEos) {
                                val encInIdx = encoder.dequeueInputBuffer(10_000)
                                if (encInIdx >= 0) {
                                    encoder.queueInputBuffer(encInIdx, 0, 0, 0,
                                        MediaCodec.BUFFER_FLAG_END_OF_STREAM)
                                }
                                decoderDone = true
                            }
                        }
                    }

                    // Drain encoder output → write to muxer
                    val encOutIdx = encoder.dequeueOutputBuffer(bufferInfo, 10_000)
                    if (encOutIdx == MediaCodec.INFO_OUTPUT_FORMAT_CHANGED) {
                        val newFormat = encoder.outputFormat
                        muxer = MediaMuxer(actualOutputPath,
                            MediaMuxer.OutputFormat.MUXER_OUTPUT_MPEG_4)
                        muxerTrackIndex = muxer.addTrack(newFormat)
                        muxer.start()
                        muxerStarted = true
                    } else if (encOutIdx >= 0) {
                        val encoded = encoder.getOutputBuffer(encOutIdx)!!
                        if (bufferInfo.size > 0 && muxerStarted) {
                            encoded.position(bufferInfo.offset)
                            encoded.limit(bufferInfo.offset + bufferInfo.size)
                            muxer!!.writeSampleData(muxerTrackIndex, encoded, bufferInfo)
                        }
                        val isEos = bufferInfo.flags and
                            MediaCodec.BUFFER_FLAG_END_OF_STREAM != 0
                        encoder.releaseOutputBuffer(encOutIdx, false)
                        if (isEos) allDone = true
                    }
                }
            } finally {
                runCatching { decoder.stop() }
                runCatching { decoder.release() }
                runCatching { encoder.stop() }
                runCatching { encoder.release() }
                if (muxerStarted) { runCatching { muxer?.stop() } }
                runCatching { muxer?.release() }
            }
        } finally {
            extractor.release()
        }

        if (!File(actualOutputPath).exists()) {
            throw Exception("音频转码失败")
        }
        return actualOutputPath
    }

    private class UnsupportedAudioCodecException(
        val mimeType: String,
        override val message: String,
    ) : IllegalArgumentException(message)
}
