package com.erotouch.omao

import android.os.Handler
import android.os.Looper
import com.google.android.gms.tasks.Tasks
import com.google.mlkit.common.model.DownloadConditions
import com.google.mlkit.nl.translate.TranslateLanguage
import com.google.mlkit.nl.translate.Translation
import com.google.mlkit.nl.translate.TranslatorOptions
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlin.concurrent.thread

object TextTranslationHost {
    private const val channelName = "com.omao/translation"

    private val mainHandler = Handler(Looper.getMainLooper())
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
            "translateBatch" -> translateBatch(call, result)
            else -> result.notImplemented()
        }
    }

    private fun translateBatch(call: MethodCall, result: MethodChannel.Result) {
        val sourceLanguage = call.argument<String>("sourceLanguage")
        val targetLanguage = call.argument<String>("targetLanguage")
        val texts = call.argument<List<*>>("texts")
            ?.map { it?.toString().orEmpty() }
            ?.toList()
            .orEmpty()

        if (sourceLanguage.isNullOrBlank() || targetLanguage.isNullOrBlank()) {
            result.error("invalid_arguments", "Missing sourceLanguage or targetLanguage", null)
            return
        }

        if (texts.isEmpty()) {
            result.success(emptyList<String>())
            return
        }

        val sourceTag = resolveLanguageTag(sourceLanguage)
        val targetTag = resolveLanguageTag(targetLanguage)
        if (sourceTag == null || targetTag == null) {
            result.error("unsupported_language", "当前仅支持中日互译", null)
            return
        }
        if (sourceTag == targetTag) {
            result.success(texts)
            return
        }

        thread(name = "text-translation") {
            val translator = Translation.getClient(
                TranslatorOptions.Builder()
                    .setSourceLanguage(sourceTag)
                    .setTargetLanguage(targetTag)
                    .build(),
            )

            try {
                Tasks.await(
                    translator.downloadModelIfNeeded(
                        DownloadConditions.Builder().build(),
                    ),
                )

                val translatedTexts = texts.map { text ->
                    if (text.isBlank()) {
                        text
                    } else {
                        Tasks.await(translator.translate(text))
                    }
                }
                mainHandler.post {
                    result.success(translatedTexts)
                }
            } catch (error: Exception) {
                val message = error.message?.takeIf { it.isNotBlank() }
                    ?: "字幕翻译失败，请检查网络或稍后重试"
                mainHandler.post {
                    result.error("translate_failed", message, null)
                }
            } finally {
                translator.close()
            }
        }
    }

    private fun resolveLanguageTag(raw: String): String? {
        return when {
            raw.startsWith("zh", ignoreCase = true) -> TranslateLanguage.CHINESE
            raw.startsWith("ja", ignoreCase = true) -> TranslateLanguage.JAPANESE
            else -> null
        }
    }
}
