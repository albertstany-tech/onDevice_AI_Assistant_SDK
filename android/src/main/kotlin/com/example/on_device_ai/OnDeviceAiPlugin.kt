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
    private val scope = CoroutineScope(Dispatchers.IO)

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
                val modelName = call.argument<String>("modelName") ?: return result.error("INVALID_ARGUMENT", "modelName is required", null)
                val config = call.argument<Map<String, Any>>("config")
                val useGPU = config?.get("useGPU") as? Boolean ?: true
                
                try {
                    runner?.loadModel(modelName, useGPU)
                    result.success(null)
                } catch (e: Exception) {
                    result.error("LOAD_FAILED", "Failed to load model", e.message)
                }
            }
            "runText" -> {
                val prompt = call.argument<String>("prompt") ?: return result.error("INVALID_ARGUMENT", "prompt is required", null)
                try {
                    val output = runner?.runText(prompt)
                    result.success(output)
                } catch (e: Exception) {
                    result.error("INFERENCE_FAILED", "Text inference failed", e.message)
                }
            }
            "runImage" -> {
                val imageBytes = call.argument<ByteArray>("imageBytes") ?: return result.error("INVALID_ARGUMENT", "imageBytes is required", null)
                try {
                    val output = runner?.runImage(imageBytes)
                    result.success(output)
                } catch (e: Exception) {
                    result.error("INFERENCE_FAILED", "Image inference failed", e.message)
                }
            }
            "startStreamText" -> {
                val prompt = call.argument<String>("prompt") ?: return result.error("INVALID_ARGUMENT", "prompt is required", null)
                scope.launch {
                    val words = listOf("This", "is", "a", "mocked", "Android", "stream", "response")
                    val handler = Handler(Looper.getMainLooper())
                    words.forEach { word ->
                        delay(200)
                        handler.post { eventSink?.success(word) }
                    }
                    handler.post { eventSink?.endOfStream() }
                }
                result.success(null)
            }
            "dispose" -> {
                runner?.dispose()
                result.success(null)
            }
            else -> {
                result.notImplemented()
            }
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
        scope.cancel()
    }
}
