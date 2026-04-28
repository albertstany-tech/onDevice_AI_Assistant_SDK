package com.example.on_device_ai

import android.content.Context
import org.tensorflow.lite.task.text.nlclassifier.NLClassifier
import org.tensorflow.lite.task.core.BaseOptions
import io.flutter.FlutterInjector
import java.io.File
import java.io.FileOutputStream

class TFLiteRunner(private val context: Context) {
    private var classifier: NLClassifier? = null

    fun loadModel(modelName: String, useGPU: Boolean) {
        val loader = FlutterInjector.instance().flutterLoader()
        // If passing "sentiment_analysis.tflite", asset path is "assets/sentiment_analysis.tflite"
        // Wait, Flutter packages it as flutter_assets/assets/... We use flutter loader to get the key.
        val assetPath = if (modelName.contains("assets/")) modelName else "assets/$modelName"
        val assetKey = loader.getLookupKeyForAsset(assetPath)
        
        // Copy to temp file because NLClassifier sometimes struggles with compressed flutter assets
        val file = File(context.cacheDir, modelName.substringAfterLast("/"))
        if (!file.exists()) {
            context.assets.open(assetKey).use { inputStream ->
                FileOutputStream(file).use { outputStream ->
                    inputStream.copyTo(outputStream)
                }
            }
        }

        val baseOptionsBuilder = BaseOptions.builder()
        val options = NLClassifier.NLClassifierOptions.builder()
            .setBaseOptions(baseOptionsBuilder.build())
            .build()
            
        classifier = NLClassifier.createFromFileAndOptions(file, options)
    }

    fun runText(prompt: String): Map<String, Any> {
        val currentClassifier = classifier ?: throw Exception("Model not loaded")
        
        val startTime = System.currentTimeMillis()
        
        val results = currentClassifier.classify(prompt)
        
        val endTime = System.currentTimeMillis()
        val inferenceTimeMs = (endTime - startTime).toInt()
        
        // Results is a List<Category>
        var bestCategory = "Unknown"
        var bestScore = 0.0f
        
        for (category in results) {
            if (category.score > bestScore) {
                bestScore = category.score
                bestCategory = category.label
            }
        }
        
        return mapOf(
            "output" to bestCategory,
            "confidenceScore" to bestScore.toDouble(),
            "inferenceTimeMs" to inferenceTimeMs
        )
    }

    fun runImage(imageBytes: ByteArray): Map<String, Any> {
        throw Exception("Image inference not implemented for this demo")
    }

    fun dispose() {
        classifier?.close()
        classifier = null
    }
}
