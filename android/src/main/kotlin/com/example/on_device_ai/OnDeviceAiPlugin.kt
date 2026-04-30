package com.example.on_device_ai

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.*
import android.os.Handler
import android.os.Looper

/** OnDeviceAiPlugin */
class OnDeviceAiPlugin : FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler {
    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private var eventSink: EventChannel.EventSink? = null

    private var runner: TFLiteRunner? = null
    private val mainHandler = Handler(Looper.getMainLooper())
    // Dedicated single-threaded executor so TFLite always runs on the same background thread
    private val ioScope = CoroutineScope(Dispatchers.IO + SupervisorJob())

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        runner = TFLiteRunner(flutterPluginBinding.applicationContext)

        methodChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "on_device_ai")
        methodChannel.setMethodCallHandler(this)

        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "on_device_ai_stream")
        eventChannel.setStreamHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "loadModel" -> {
                val modelName = call.argument<String>("modelName")
                    ?: return result.error("INVALID_ARGUMENT", "modelName is required", null)
                val config = call.argument<Map<String, Any>>("config")
                val useGPU = config?.get("useGPU") as? Boolean ?: true

                // Run on background thread - TFLite native init MUST NOT run on main thread
                ioScope.launch {
                    try {
                        runner?.loadModel(modelName, useGPU)
                        mainHandler.post { result.success(null) }
                    } catch (e: Exception) {
                        mainHandler.post { result.error("LOAD_FAILED", "Failed to load model: ${e.message}", null) }
                    }
                }
            }
            "runText" -> {
                val prompt = call.argument<String>("prompt")
                    ?: return result.error("INVALID_ARGUMENT", "prompt is required", null)

                ioScope.launch {
                    try {
                        val output = runner?.runText(prompt)
                        mainHandler.post { result.success(output) }
                    } catch (e: Exception) {
                        mainHandler.post { result.error("INFERENCE_FAILED", "Text inference failed: ${e.message}", null) }
                    }
                }
            }
            "runImage" -> {
                val imageBytes = call.argument<ByteArray>("imageBytes")
                    ?: return result.error("INVALID_ARGUMENT", "imageBytes is required", null)

                ioScope.launch {
                    try {
                        val output = runner?.runImage(imageBytes)
                        mainHandler.post { result.success(output) }
                    } catch (e: Exception) {
                        mainHandler.post { result.error("INFERENCE_FAILED", "Image inference failed: ${e.message}", null) }
                    }
                }
            }
            "startStreamText" -> {
                val prompt = call.argument<String>("prompt")
                    ?: return result.error("INVALID_ARGUMENT", "prompt is required", null)

                ioScope.launch {
                    val words = listOf("This", "is", "a", "mocked", "Android", "stream", "response")
                    words.forEach { word ->
                        delay(200)
                        mainHandler.post { eventSink?.success(word) }
                    }
                    mainHandler.post { eventSink?.endOfStream() }
                }
                result.success(null)
            }
            "dispose" -> {
                ioScope.launch {
                    runner?.dispose()
                    mainHandler.post { result.success(null) }
                }
            }
            else -> result.notImplemented()
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        runner?.dispose()
        runner = null
        ioScope.cancel()
    }
}
