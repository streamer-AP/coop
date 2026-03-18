package com.example.omao_app

import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject

/**
 * Native channel skeleton for Flutter <-> native <-> Unity relay.
 *
 * Current behavior is intentionally safe/no-op:
 * - native page switching and Unity engine lifecycle are tracked in memory only
 * - outbound Flutter -> Unity messages are cached and optionally forwarded to a
 *   future Unity plugin callback
 * - inbound Unity -> Flutter messages can already be dispatched through
 *   [dispatchUnityMessage]
 */
object UnityChannelHost {
    private const val tag = "UnityChannelHost"
    private const val nativeChannelName = "com.omao/native"
    private const val unityChannelName = "com.omao/unity"

    private val mainHandler = Handler(Looper.getMainLooper())

    private var nativeChannel: MethodChannel? = null
    private var unityChannel: MethodChannel? = null

    private var unityInitialized = false
    private var unityVisible = false
    private var lastFlutterMessageJson: String? = null

    private var flutterToUnityRelay: ((String) -> Unit)? = null

    fun attach(messenger: BinaryMessenger) {
        nativeChannel = MethodChannel(messenger, nativeChannelName).apply {
            setMethodCallHandler(::handleNativeMethodCall)
        }
        unityChannel = MethodChannel(messenger, unityChannelName).apply {
            setMethodCallHandler(::handleUnityMethodCall)
        }
    }

    fun detach() {
        nativeChannel?.setMethodCallHandler(null)
        unityChannel?.setMethodCallHandler(null)
        nativeChannel = null
        unityChannel = null
    }

    /**
     * Future Unity plugin hook:
     * register a relay that receives JSON messages from Flutter.
     */
    fun setFlutterToUnityRelay(relay: ((String) -> Unit)?) {
        flutterToUnityRelay = relay
    }

    /**
     * Future Unity plugin entrypoint:
     * forward JSON messages from Unity/native into Flutter.
     */
    fun dispatchUnityMessage(json: String) {
        mainHandler.post {
            val channel = unityChannel
            if (channel == null) {
                Log.w(tag, "Dropped Unity message because Flutter channel is not attached")
                return@post
            }
            channel.invokeMethod("onUnityMessage", json)
        }
    }

    fun getLastFlutterMessageJson(): String? = lastFlutterMessageJson

    private fun handleNativeMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "switchToUnity" -> {
                unityVisible = true
                result.success(null)
            }
            "switchToFlutter" -> {
                unityVisible = false
                result.success(null)
            }
            "initUnityEngine" -> {
                unityInitialized = true
                result.success(null)
            }
            "destroyUnityEngine" -> {
                unityInitialized = false
                unityVisible = false
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    private fun handleUnityMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "sendToUnity" -> {
                val json = call.arguments.toJsonString()
                if (json == null) {
                    result.error(
                        "invalid_arguments",
                        "sendToUnity expects a JSON string or JSON-compatible map/list",
                        null,
                    )
                    return
                }

                lastFlutterMessageJson = json
                flutterToUnityRelay?.invoke(json)
                    ?: Log.d(
                        tag,
                        "Cached Flutter -> Unity message while no Unity relay is registered",
                    )

                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    private fun Any?.toJsonString(): String? {
        return when (this) {
            null -> null
            is String -> this
            is Map<*, *> -> mapToJson(this).toString()
            is List<*> -> listToJson(this).toString()
            else -> null
        }
    }

    private fun mapToJson(map: Map<*, *>): JSONObject {
        val json = JSONObject()
        for ((key, value) in map) {
            json.put(key?.toString() ?: continue, wrapJsonValue(value))
        }
        return json
    }

    private fun listToJson(list: List<*>): JSONArray {
        val json = JSONArray()
        list.forEach { value -> json.put(wrapJsonValue(value)) }
        return json
    }

    private fun wrapJsonValue(value: Any?): Any? {
        return when (value) {
            null,
            is Boolean,
            is Int,
            is Long,
            is Double,
            is String -> value
            is Float -> value.toDouble()
            is Map<*, *> -> mapToJson(value)
            is List<*> -> listToJson(value)
            else -> value.toString()
        }
    }
}
