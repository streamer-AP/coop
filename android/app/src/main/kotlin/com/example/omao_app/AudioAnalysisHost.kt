package com.example.omao_app

import android.media.MediaCodec
import android.media.MediaExtractor
import android.media.MediaFormat
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject
import java.nio.ByteBuffer
import java.nio.ByteOrder
import kotlin.concurrent.thread
import kotlin.math.max
import kotlin.math.min
import kotlin.math.round
import kotlin.math.sqrt

object AudioAnalysisHost {
    private const val CHANNEL_NAME = "com.omao/audio_analysis"
    private const val CHUNK_MS = 200
    private var channel: MethodChannel? = null

    fun attach(messenger: BinaryMessenger) {
        channel = MethodChannel(messenger, CHANNEL_NAME).apply {
            setMethodCallHandler(::handleMethodCall)
        }
    }

    fun detach() {
        channel?.setMethodCallHandler(null)
        channel = null
    }

    private fun handleMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method != "analyzeAudio") {
            result.notImplemented()
            return
        }

        val audioFilePath = call.argument<String>("audioFilePath")
        if (audioFilePath.isNullOrBlank()) {
            result.error("invalid_args", "audioFilePath is required", null)
            return
        }

        thread(name = "audio-analysis") {
            try {
                val json = analyzeAudio(audioFilePath)
                result.success(json)
            } catch (e: Exception) {
                result.error("analysis_failed", e.message, null)
            }
        }
    }

    private fun analyzeAudio(audioFilePath: String): String {
        val extractor = MediaExtractor()
        extractor.setDataSource(audioFilePath)

        val audioTrackIndex = findAudioTrack(extractor)
        if (audioTrackIndex == -1) {
            extractor.release()
            throw IllegalArgumentException("No audio track found")
        }

        extractor.selectTrack(audioTrackIndex)
        val format = extractor.getTrackFormat(audioTrackIndex)
        val mime = format.getString(MediaFormat.KEY_MIME) ?: ""
        val sampleRate = format.getInteger(MediaFormat.KEY_SAMPLE_RATE)
        val channelCount = format.getInteger(MediaFormat.KEY_CHANNEL_COUNT)

        // Set up MediaCodec decoder
        val codec = MediaCodec.createDecoderByType(mime)
        codec.configure(format, null, null, 0)
        codec.start()

        val samplesPerChunk = sampleRate * CHUNK_MS / 1000
        val dsp = AudioEnergyAnalyzer(sampleRate)
        val keyframes = mutableListOf<JSONObject>()

        // Add initial zero keyframe
        keyframes.add(makeKeyframe(0, 0, 0))

        val bufferInfo = MediaCodec.BufferInfo()
        var inputDone = false
        var outputDone = false
        var timestampMs = 0
        val pcmAccumulator = FloatArray(samplesPerChunk * channelCount * 2)
        var accumulatedSamples = 0

        while (!outputDone) {
            // Feed input
            if (!inputDone) {
                val inputIndex = codec.dequeueInputBuffer(10_000)
                if (inputIndex >= 0) {
                    val inputBuffer = codec.getInputBuffer(inputIndex)!!
                    val sampleSize = extractor.readSampleData(inputBuffer, 0)
                    if (sampleSize < 0) {
                        codec.queueInputBuffer(inputIndex, 0, 0, 0,
                            MediaCodec.BUFFER_FLAG_END_OF_STREAM)
                        inputDone = true
                    } else {
                        val pts = extractor.sampleTime
                        codec.queueInputBuffer(inputIndex, 0, sampleSize, pts, 0)
                        extractor.advance()
                    }
                }
            }

            // Read output
            val outputIndex = codec.dequeueOutputBuffer(bufferInfo, 10_000)
            if (outputIndex >= 0) {
                if (bufferInfo.flags and MediaCodec.BUFFER_FLAG_END_OF_STREAM != 0) {
                    outputDone = true
                }

                val outputBuffer = codec.getOutputBuffer(outputIndex)
                if (outputBuffer != null && bufferInfo.size > 0) {
                    outputBuffer.position(bufferInfo.offset)
                    outputBuffer.limit(bufferInfo.offset + bufferInfo.size)
                    outputBuffer.order(ByteOrder.nativeOrder())

                    // Read 16-bit PCM samples as floats
                    val shortCount = bufferInfo.size / 2
                    for (i in 0 until shortCount) {
                        if (accumulatedSamples >= pcmAccumulator.size) break
                        pcmAccumulator[accumulatedSamples++] =
                            outputBuffer.short.toFloat() / 32768f
                    }

                    // Process complete chunks
                    while (accumulatedSamples >= samplesPerChunk * channelCount) {
                        val mono = mixToMono(pcmAccumulator, channelCount, samplesPerChunk)
                        val result = dsp.process(mono)

                        timestampMs += CHUNK_MS
                        keyframes.add(makeKeyframe(timestampMs, result.swing, result.vibration))

                        // Shift remaining samples
                        val consumed = samplesPerChunk * channelCount
                        val remaining = accumulatedSamples - consumed
                        if (remaining > 0) {
                            System.arraycopy(pcmAccumulator, consumed,
                                pcmAccumulator, 0, remaining)
                        }
                        accumulatedSamples = remaining
                    }
                }
                codec.releaseOutputBuffer(outputIndex, false)
            }
        }

        // Process remaining samples
        if (accumulatedSamples > channelCount) {
            val frames = accumulatedSamples / channelCount
            val mono = mixToMono(pcmAccumulator, channelCount, frames)
            val result = dsp.process(mono)
            timestampMs += CHUNK_MS
            keyframes.add(makeKeyframe(timestampMs, result.swing, result.vibration))
        }

        // Add final zero keyframe
        keyframes.add(makeKeyframe(timestampMs + 200, 0, 0))

        codec.stop()
        codec.release()
        extractor.release()

        // Build JSON
        val jsonArray = JSONArray()
        for (kf in keyframes) {
            jsonArray.put(kf)
        }
        val root = JSONObject()
        root.put("keyframes", jsonArray)
        return root.toString()
    }

    private fun findAudioTrack(extractor: MediaExtractor): Int {
        for (i in 0 until extractor.trackCount) {
            val mime = extractor.getTrackFormat(i)
                .getString(MediaFormat.KEY_MIME) ?: ""
            if (mime.startsWith("audio/")) return i
        }
        return -1
    }

    private fun mixToMono(
        interleaved: FloatArray,
        channels: Int,
        frames: Int,
    ): FloatArray {
        if (channels == 1) return interleaved.copyOf(frames)
        val mono = FloatArray(frames)
        for (i in 0 until frames) {
            var sum = 0f
            for (c in 0 until channels) {
                sum += interleaved[i * channels + c]
            }
            mono[i] = sum / channels
        }
        return mono
    }

    private fun makeKeyframe(timestampMs: Int, swing: Int, vibration: Int): JSONObject {
        return JSONObject().apply {
            put("timestampMs", timestampMs)
            put("swing", swing)
            put("vibration", vibration)
        }
    }

    // ──────────────── DSP Classes ────────────────

    private class OnePoleFilter(
        private val type: Type,
        cutoffHz: Float,
        sampleRate: Int,
    ) {
        enum class Type { Lowpass, Highpass }

        private val alpha: Float
        private var y = 0f
        private var xPrev = 0f

        init {
            val rc = 1f / (6.2831855f * max(0.001f, cutoffHz))
            val dt = 1f / max(1, sampleRate)
            alpha = if (type == Type.Lowpass) dt / (rc + dt) else rc / (rc + dt)
        }

        fun reset() { y = 0f; xPrev = 0f }

        fun process(x: Float): Float {
            return if (type == Type.Lowpass) {
                y += alpha * (x - y); y
            } else {
                y = alpha * (y + x - xPrev); xPrev = x; y
            }
        }
    }

    private class BandEnergy(hpHz: Float, lpHz: Float, sampleRate: Int) {
        private val hp = OnePoleFilter(OnePoleFilter.Type.Highpass, hpHz, sampleRate)
        private val lp = OnePoleFilter(OnePoleFilter.Type.Lowpass, lpHz, sampleRate)

        fun reset() { hp.reset(); lp.reset() }

        fun computeRms(mono: FloatArray): Float {
            var sumSq = 0f
            for (s in mono) {
                val y = lp.process(hp.process(s))
                sumSq += y * y
            }
            return sqrt(sumSq / max(1, mono.size).toFloat())
        }
    }

    private class BeatDetector(sampleRate: Int) {
        private val low = OnePoleFilter(OnePoleFilter.Type.Lowpass, 150f, sampleRate)
        private var mean = 0f
        private var meanSq = 0f
        private var lastBeatTime = -10f
        private val k = 1.5f
        private val muAlpha = 0.02f
        private val minInterval = 0.12f

        fun reset() { low.reset(); mean = 0f; meanSq = 0f; lastBeatTime = -10f }

        fun processChunk(mono: FloatArray, timeNow: Float): Boolean {
            var sumSq = 0f
            for (s in mono) { val lp = low.process(s); sumSq += lp * lp }
            val rms = sqrt(sumSq / max(1, mono.size).toFloat())
            mean = (1f - muAlpha) * mean + muAlpha * rms
            meanSq = (1f - muAlpha) * meanSq + muAlpha * rms * rms
            val std = sqrt(max(0f, meanSq - mean * mean))
            val thr = mean + k * std
            val isBeat = rms > thr && timeNow - lastBeatTime > minInterval
            if (isBeat) lastBeatTime = timeNow
            return isBeat
        }
    }

    private class RhythmProcessor(sampleRate: Int) {
        private val band = BandEnergy(100f, 6000f, sampleRate)
        fun reset() = band.reset()
        fun compute(mono: FloatArray) = band.computeRms(mono)
    }

    private class VocalProcessor(sampleRate: Int) {
        private val band = BandEnergy(200f, 5000f, sampleRate)
        private var env = 0f
        private val alpha = 0.15f
        fun reset() { band.reset(); env = 0f }
        fun compute(mono: FloatArray): Float {
            val rms = band.computeRms(mono)
            env += alpha * (rms - env)
            return env
        }
    }

    private data class AnalysisResult(val swing: Int, val vibration: Int)

    private class AudioEnergyAnalyzer(private val sampleRate: Int) {
        private val beat = BeatDetector(sampleRate)
        private val rhythm = RhythmProcessor(sampleRate)
        private val vocal = VocalProcessor(sampleRate)
        private var smoothed = 0f
        private var agcPeak = 0.1f
        private val smooth = 0.2f
        private val agcDecay = 0.9975f
        private val beatBoost = 1.2f
        private val rhythmWeight = 0.5f
        private val vocalWeight = 0.5f
        private var timeSeconds = 0.0

        fun process(mono: FloatArray): AnalysisResult {
            timeSeconds += mono.size.toDouble() / sampleRate
            beat.processChunk(mono, timeSeconds.toFloat())

            val rhythmVal = rhythm.compute(mono)
            val vocalVal = vocal.compute(mono)

            val combined = beatBoost * (rhythmVal * rhythmWeight + vocalVal * vocalWeight)
            smoothed += smooth * (combined - smoothed)
            agcPeak = max(smoothed, agcPeak * agcDecay)

            val normalized = smoothed / max(0.001f, agcPeak)
            val energy = min(1f, max(0f, normalized)) * 100f
            val rhythmNorm = min(1f, max(0f, rhythmVal / max(0.001f, agcPeak))) * 100f

            var swing = clampFloor(round(rhythmNorm).toInt())
            var vibration = clampFloor(round(energy).toInt())

            return AnalysisResult(swing, vibration)
        }

        private fun clampFloor(v: Int): Int {
            val clamped = v.coerceIn(0, 100)
            return if (clamped in 1..14) 15 else clamped
        }
    }
}
