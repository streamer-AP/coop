package com.erotouch.omao

import android.media.MediaCodec
import android.media.MediaCodecInfo
import android.media.MediaFormat
import android.media.MediaMuxer
import java.io.File
import java.io.RandomAccessFile
import java.nio.ByteBuffer
import java.nio.ByteOrder

/**
 * Pure-Kotlin AVI (RIFF) demuxer that extracts audio without relying on
 * Android's MediaExtractor, which may not support AVI on all devices.
 *
 * PCM audio is written directly as WAV; compressed audio (MP3, AAC, etc.)
 * is decoded via MediaCodec and re-encoded as AAC in an M4A container.
 */
object AviAudioExtractor {

    // RIFF tags (little-endian integers)
    private const val TAG_RIFF = 0x46464952 // "RIFF"
    private const val TAG_AVI  = 0x20495641 // "AVI "
    private const val TAG_LIST = 0x5453494C // "LIST"
    private const val TAG_HDRL = 0x6C726468 // "hdrl"
    private const val TAG_STRL = 0x6C727473 // "strl"
    private const val TAG_STRH = 0x68727473 // "strh"
    private const val TAG_STRF = 0x66727473 // "strf"
    private const val TAG_MOVI = 0x69766F6D // "movi"
    private const val TAG_AUDS = 0x73647561 // "auds"

    private const val FMT_PCM   = 0x0001
    private const val FMT_FLOAT = 0x0003
    private const val FMT_MP3   = 0x0055
    private const val FMT_MP3_2 = 0x0050
    private const val FMT_AAC   = 0x00FF
    private const val FMT_AC3   = 0x2000

    /** Audio stream metadata parsed from the AVI header. */
    private data class AudioInfo(
        val streamIndex: Int,
        val formatTag: Int,
        val channels: Int,
        val sampleRate: Int,
        val avgBytesPerSec: Int,
        val blockAlign: Int,
        val bitsPerSample: Int,
        val extraData: ByteArray?,
    )

    private data class Chunk(val offset: Long, val size: Int)

    // ── Public API ──────────────────────────────────────────────────

    /**
     * Returns `true` if the file starts with a valid RIFF/AVI header.
     * Cheap check – only reads 12 bytes.
     */
    fun isAviFile(path: String): Boolean {
        return try {
            RandomAccessFile(path, "r").use { raf ->
                if (raf.length() < 12) return false
                val riff = raf.readIntLE()
                raf.readIntLE() // skip size
                val avi = raf.readIntLE()
                riff == TAG_RIFF && avi == TAG_AVI
            }
        } catch (_: Exception) { false }
    }

    /**
     * Extract audio from an AVI file.
     * @return absolute path of the output file (WAV or M4A).
     */
    fun extract(inputPath: String, outputPath: String): String {
        RandomAccessFile(inputPath, "r").use { raf ->
            // Verify header
            val riff = raf.readIntLE()
            raf.readIntLE() // file size
            val avi = raf.readIntLE()
            if (riff != TAG_RIFF || avi != TAG_AVI) {
                throw Exception("不是有效的 AVI 文件")
            }

            val info = parseHeaders(raf)
                ?: throw Exception("AVI 文件中未找到音频轨道")

            val chunks = collectAudioChunks(raf, info.streamIndex)
            if (chunks.isEmpty()) {
                throw Exception("AVI 文件中未找到音频数据")
            }

            return when (info.formatTag) {
                FMT_PCM, FMT_FLOAT -> extractPcm(raf, info, chunks, outputPath)
                else -> extractCompressed(raf, info, chunks, outputPath)
            }
        }
    }

    // ── Header parsing ──────────────────────────────────────────────

    private fun parseHeaders(raf: RandomAccessFile): AudioInfo? {
        val endPos = raf.length()
        var streamIndex = 0

        while (raf.filePointer < endPos - 8) {
            val tag = raf.readIntLE()
            val size = raf.readIntLE()

            if (tag == TAG_LIST) {
                val listType = raf.readIntLE()
                when (listType) {
                    TAG_HDRL -> continue          // dive into hdrl
                    TAG_STRL -> {
                        val info = parseStreamList(raf, streamIndex, size - 4)
                        if (info != null) return info
                        streamIndex++
                    }
                    TAG_MOVI -> {
                        // Reached movie data – stop header scan
                        raf.seek(raf.filePointer - 12)
                        return null
                    }
                    else -> raf.skipAligned(size.toLong() - 4)
                }
            } else {
                raf.skipAligned(size.toLong())
            }
        }
        return null
    }

    private fun parseStreamList(raf: RandomAccessFile, streamIndex: Int, maxBytes: Int): AudioInfo? {
        val endPos = raf.filePointer + maxBytes
        var isAudio = false
        var formatTag = 0; var channels = 0; var sampleRate = 0
        var avgBytesPerSec = 0; var blockAlign = 0; var bitsPerSample = 0
        var extraData: ByteArray? = null

        while (raf.filePointer < endPos - 8) {
            val tag = raf.readIntLE()
            val size = raf.readIntLE()
            val chunkStart = raf.filePointer

            when (tag) {
                TAG_STRH -> {
                    isAudio = raf.readIntLE() == TAG_AUDS
                }
                TAG_STRF -> if (isAudio && size >= 14) {
                    formatTag       = raf.readShortLE()
                    channels        = raf.readShortLE()
                    sampleRate      = raf.readIntLE()
                    avgBytesPerSec  = raf.readIntLE()
                    blockAlign      = raf.readShortLE()
                    bitsPerSample   = if (size >= 16) raf.readShortLE() else 16
                    if (size >= 18) {
                        val cbSize = raf.readShortLE()
                        if (cbSize > 0 && size >= 18 + cbSize) {
                            extraData = ByteArray(cbSize).also { raf.readFully(it) }
                        }
                    }
                }
            }
            raf.seek(chunkStart + wordAlign(size.toLong()))
        }

        return if (isAudio) AudioInfo(
            streamIndex, formatTag, channels, sampleRate,
            avgBytesPerSec, blockAlign, bitsPerSample, extraData,
        ) else null
    }

    // ── Chunk collection ────────────────────────────────────────────

    private fun collectAudioChunks(raf: RandomAccessFile, audioStreamIndex: Int): List<Chunk> {
        raf.seek(12) // after RIFF header
        val wbTag = chunkId("%02dwb".format(audioStreamIndex))
        val chunks = mutableListOf<Chunk>()
        val endPos = raf.length()

        while (raf.filePointer < endPos - 8) {
            val tag = raf.readIntLE()
            val size = raf.readIntLE()

            if (tag == TAG_LIST) {
                val listType = raf.readIntLE()
                if (listType == TAG_MOVI) {
                    readMoviChunks(raf, raf.filePointer, size.toLong() - 4, wbTag, chunks)
                    break
                } else {
                    raf.skipAligned(size.toLong() - 4)
                }
            } else {
                raf.skipAligned(size.toLong())
            }
        }
        return chunks
    }

    private fun readMoviChunks(
        raf: RandomAccessFile, start: Long, length: Long,
        wbTag: Int, out: MutableList<Chunk>,
    ) {
        val end = start + length
        while (raf.filePointer < end - 8) {
            val tag = raf.readIntLE()
            val size = raf.readIntLE()

            if (tag == TAG_LIST) {
                // Nested 'rec ' list – recurse into it
                val listType = raf.readIntLE()
                readMoviChunks(raf, raf.filePointer, size.toLong() - 4, wbTag, out)
                continue
            }
            if (tag == wbTag && size > 0) {
                out.add(Chunk(raf.filePointer, size))
            }
            raf.skipAligned(size.toLong())
        }
    }

    // ── PCM extraction (→ WAV) ──────────────────────────────────────

    private fun extractPcm(
        raf: RandomAccessFile, info: AudioInfo,
        chunks: List<Chunk>, outputPath: String,
    ): String {
        val outPath = buildPath(outputPath, ".wav")
        File(outPath).parentFile?.mkdirs()

        val bps = if (info.bitsPerSample > 0) info.bitsPerSample else 16
        val audioFmt: Short = if (info.formatTag == FMT_FLOAT) 3 else 1
        val byteRate = info.sampleRate * info.channels * (bps / 8)
        val blockAlign = info.channels * (bps / 8)
        val dataSize = chunks.sumOf { it.size.toLong() }

        java.io.FileOutputStream(outPath).use { fos ->
            // WAV header (44 bytes)
            val hdr = ByteBuffer.allocate(44).order(ByteOrder.LITTLE_ENDIAN).apply {
                put("RIFF".toByteArray()); putInt((36 + dataSize).toInt())
                put("WAVE".toByteArray())
                put("fmt ".toByteArray()); putInt(16)
                putShort(audioFmt); putShort(info.channels.toShort())
                putInt(info.sampleRate); putInt(byteRate)
                putShort(blockAlign.toShort()); putShort(bps.toShort())
                put("data".toByteArray()); putInt(dataSize.toInt())
            }
            fos.write(hdr.array())

            val buf = ByteArray(65536)
            for (c in chunks) {
                raf.seek(c.offset)
                var rem = c.size
                while (rem > 0) {
                    val n = minOf(rem, buf.size)
                    raf.readFully(buf, 0, n)
                    fos.write(buf, 0, n)
                    rem -= n
                }
            }
        }
        return outPath
    }

    // ── Compressed extraction (decode → AAC → M4A) ──────────────────

    private fun extractCompressed(
        raf: RandomAccessFile, info: AudioInfo,
        chunks: List<Chunk>, outputPath: String,
    ): String {
        val mime = formatTagToMime(info.formatTag)
            ?: throw Exception(
                "暂不支持 AVI 中的音频编码 (0x${"%04X".format(info.formatTag)})"
            )

        val outPath = buildPath(outputPath, ".m4a")
        File(outPath).parentFile?.mkdirs()

        // Decoder
        val decFmt = MediaFormat.createAudioFormat(mime, info.sampleRate, info.channels)
        if (info.extraData != null) {
            decFmt.setByteBuffer("csd-0", ByteBuffer.wrap(info.extraData))
        }
        if (info.avgBytesPerSec > 0) {
            decFmt.setInteger(MediaFormat.KEY_BIT_RATE, info.avgBytesPerSec * 8)
        }
        val decoder = MediaCodec.createDecoderByType(mime)
        decoder.configure(decFmt, null, null, 0)
        decoder.start()

        // Encoder (AAC-LC)
        val encFmt = MediaFormat.createAudioFormat(
            MediaFormat.MIMETYPE_AUDIO_AAC, info.sampleRate, info.channels,
        ).apply {
            setInteger(MediaFormat.KEY_BIT_RATE, 192_000)
            setInteger(MediaFormat.KEY_AAC_PROFILE,
                MediaCodecInfo.CodecProfileLevel.AACObjectLC)
            setInteger(MediaFormat.KEY_MAX_INPUT_SIZE, 1024 * 1024)
        }
        val encoder = MediaCodec.createEncoderByType(MediaFormat.MIMETYPE_AUDIO_AAC)
        encoder.configure(encFmt, null, null, MediaCodec.CONFIGURE_FLAG_ENCODE)
        encoder.start()

        var muxer: MediaMuxer? = null
        var muxTrack = -1
        var muxStarted = false
        val bi = MediaCodec.BufferInfo()

        var ci = 0            // current chunk index
        var inputDone = false
        var decDone = false
        var allDone = false

        try {
            while (!allDone) {
                // ── feed chunks into decoder ──
                if (!inputDone) {
                    val idx = decoder.dequeueInputBuffer(10_000)
                    if (idx >= 0) {
                        val buf = decoder.getInputBuffer(idx)!!
                        buf.clear()
                        if (ci < chunks.size) {
                            val chunk = chunks[ci]
                            val sz = minOf(chunk.size, buf.capacity())
                            raf.seek(chunk.offset)
                            val tmp = ByteArray(sz)
                            raf.readFully(tmp)
                            buf.put(tmp)
                            decoder.queueInputBuffer(idx, 0, sz, 0, 0)
                            ci++
                        } else {
                            decoder.queueInputBuffer(idx, 0, 0, 0,
                                MediaCodec.BUFFER_FLAG_END_OF_STREAM)
                            inputDone = true
                        }
                    }
                }

                // ── decoder output → encoder input ──
                if (!decDone) {
                    val idx = decoder.dequeueOutputBuffer(bi, 10_000)
                    if (idx >= 0) {
                        val pcm = decoder.getOutputBuffer(idx)!!
                        val eos = bi.flags and MediaCodec.BUFFER_FLAG_END_OF_STREAM != 0

                        if (bi.size > 0) {
                            val ei = encoder.dequeueInputBuffer(10_000)
                            if (ei >= 0) {
                                val eb = encoder.getInputBuffer(ei)!!
                                eb.clear()
                                val n = minOf(bi.size, eb.capacity())
                                pcm.limit(bi.offset + n)
                                pcm.position(bi.offset)
                                eb.put(pcm)
                                encoder.queueInputBuffer(ei, 0, n,
                                    bi.presentationTimeUs, 0)
                            }
                        }
                        decoder.releaseOutputBuffer(idx, false)

                        if (eos) {
                            val ei = encoder.dequeueInputBuffer(10_000)
                            if (ei >= 0) {
                                encoder.queueInputBuffer(ei, 0, 0, 0,
                                    MediaCodec.BUFFER_FLAG_END_OF_STREAM)
                            }
                            decDone = true
                        }
                    }
                }

                // ── encoder output → muxer ──
                val oi = encoder.dequeueOutputBuffer(bi, 10_000)
                when {
                    oi == MediaCodec.INFO_OUTPUT_FORMAT_CHANGED -> {
                        muxer = MediaMuxer(outPath,
                            MediaMuxer.OutputFormat.MUXER_OUTPUT_MPEG_4)
                        muxTrack = muxer.addTrack(encoder.outputFormat)
                        muxer.start()
                        muxStarted = true
                    }
                    oi >= 0 -> {
                        val enc = encoder.getOutputBuffer(oi)!!
                        if (bi.size > 0 && muxStarted) {
                            enc.position(bi.offset)
                            enc.limit(bi.offset + bi.size)
                            muxer!!.writeSampleData(muxTrack, enc, bi)
                        }
                        if (bi.flags and MediaCodec.BUFFER_FLAG_END_OF_STREAM != 0) {
                            allDone = true
                        }
                        encoder.releaseOutputBuffer(oi, false)
                    }
                }
            }
        } finally {
            runCatching { decoder.stop(); decoder.release() }
            runCatching { encoder.stop(); encoder.release() }
            if (muxStarted) runCatching { muxer?.stop() }
            runCatching { muxer?.release() }
        }

        if (!File(outPath).exists()) throw Exception("音频转码失败")
        return outPath
    }

    // ── Helpers ──────────────────────────────────────────────────────

    private fun formatTagToMime(tag: Int): String? = when (tag) {
        FMT_MP3, FMT_MP3_2    -> "audio/mpeg"
        FMT_AAC                -> "audio/mp4a-latm"
        FMT_AC3                -> "audio/ac3"
        0x2001                 -> "audio/eac3"
        0x6771                 -> "audio/vorbis"
        else                   -> null
    }

    private fun chunkId(ascii: String): Int {
        val b = ascii.toByteArray(Charsets.US_ASCII)
        return (b[0].toInt() and 0xFF) or
            ((b[1].toInt() and 0xFF) shl 8) or
            ((b[2].toInt() and 0xFF) shl 16) or
            ((b[3].toInt() and 0xFF) shl 24)
    }

    private fun wordAlign(n: Long) = (n + 1) and 0x7FFFFFFE.toLong()

    private fun RandomAccessFile.skipAligned(size: Long) {
        seek(filePointer + wordAlign(size))
    }

    private fun buildPath(suggested: String, ext: String): String {
        val f = File(suggested)
        val parent = f.parentFile ?: File(".")
        val dot = f.name.lastIndexOf('.')
        val base = if (dot > 0) f.name.substring(0, dot) else f.name
        var out = File(parent, "$base$ext")
        var c = 1
        while (out.exists()) { out = File(parent, "$base($c)$ext"); c++ }
        return out.absolutePath
    }

    // Little-endian readers
    private fun RandomAccessFile.readIntLE(): Int {
        val b = ByteArray(4); readFully(b)
        return (b[0].toInt() and 0xFF) or
            ((b[1].toInt() and 0xFF) shl 8) or
            ((b[2].toInt() and 0xFF) shl 16) or
            ((b[3].toInt() and 0xFF) shl 24)
    }

    private fun RandomAccessFile.readShortLE(): Int {
        val b = ByteArray(2); readFully(b)
        return (b[0].toInt() and 0xFF) or ((b[1].toInt() and 0xFF) shl 8)
    }
}
