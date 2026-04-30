package com.example.on_device_ai

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import org.tensorflow.lite.Interpreter
import org.tensorflow.lite.task.text.nlclassifier.NLClassifier
import org.tensorflow.lite.task.core.BaseOptions
import io.flutter.FlutterInjector
import java.io.BufferedReader
import java.io.File
import java.io.FileOutputStream
import java.io.InputStreamReader
import java.nio.ByteBuffer
import java.nio.ByteOrder

class TFLiteRunner(private val context: Context) {
    private var nlClassifier: NLClassifier? = null
    private var imageInterpreter: Interpreter? = null
    private var imageLabels: List<String> = emptyList()

    // MobileNet V1 quantized model expects 224x224 RGB uint8 input
    private val IMAGE_SIZE = 224
    private val PIXEL_SIZE = 3
    private val BATCH_SIZE = 1

    fun loadModel(modelName: String, useGPU: Boolean) {
        val loader = FlutterInjector.instance().flutterLoader()
        val assetPath = if (modelName.contains("assets/")) modelName else "assets/$modelName"
        val assetKey = loader.getLookupKeyForAsset(assetPath)

        val file = File(context.cacheDir, modelName.substringAfterLast("/"))
        if (file.exists()) file.delete()

        context.assets.open(assetKey).use { inputStream ->
            FileOutputStream(file).use { outputStream ->
                inputStream.copyTo(outputStream)
            }
        }

        if (modelName.contains("sentiment")) {
            val options = NLClassifier.NLClassifierOptions.builder()
                .setBaseOptions(BaseOptions.builder().build())
                .build()
            nlClassifier = NLClassifier.createFromFileAndOptions(file, options)

        } else if (modelName.contains("mobilenet")) {
            // Use stable base Interpreter instead of crashed Task Vision library
            val options = Interpreter.Options().apply {
                setNumThreads(2)
            }
            imageInterpreter = Interpreter(file, options)

            // Load labels from bundled labels text file
            val labelsAssetKey = loader.getLookupKeyForAsset("assets/labels_mobilenet_quant_v1_224.txt")
            imageLabels = context.assets.open(labelsAssetKey).use { stream ->
                BufferedReader(InputStreamReader(stream)).readLines()
            }
        }
    }

    fun runText(prompt: String): Map<String, Any> {
        val currentClassifier = nlClassifier ?: throw Exception("Text Model not loaded")

        val startTime = System.currentTimeMillis()
        val results = currentClassifier.classify(prompt)
        val endTime = System.currentTimeMillis()

        var bestCategory = "Unknown"
        var bestScore = -1.0f
        for (category in results) {
            if (category.score > bestScore) {
                bestScore = category.score
                bestCategory = category.label
            }
        }

        val rawDetails = results.joinToString(", ") { "${it.label}=${it.score}" }
        return mapOf(
            "output" to "$bestCategory [$rawDetails]",
            "confidenceScore" to bestScore.toDouble(),
            "inferenceTimeMs" to (endTime - startTime).toInt()
        )
    }

    fun runImage(imageBytes: ByteArray): Map<String, Any> {
        val interpreter = imageInterpreter ?: throw Exception("Image Model not loaded")
        if (imageLabels.isEmpty()) throw Exception("Labels not loaded")

        val startTime = System.currentTimeMillis()

        // Decode and resize to 224x224
        val rawBitmap = BitmapFactory.decodeByteArray(imageBytes, 0, imageBytes.size)
            ?: throw Exception("Failed to decode image bytes")
        val bitmap = Bitmap.createScaledBitmap(rawBitmap, IMAGE_SIZE, IMAGE_SIZE, true)

        // Fill ByteBuffer with raw RGB uint8 pixel values
        val inputBuffer = ByteBuffer.allocateDirect(BATCH_SIZE * IMAGE_SIZE * IMAGE_SIZE * PIXEL_SIZE)
        inputBuffer.order(ByteOrder.nativeOrder())
        inputBuffer.rewind()

        val pixels = IntArray(IMAGE_SIZE * IMAGE_SIZE)
        bitmap.getPixels(pixels, 0, IMAGE_SIZE, 0, 0, IMAGE_SIZE, IMAGE_SIZE)
        for (pixel in pixels) {
            inputBuffer.put(((pixel shr 16) and 0xFF).toByte()) // R
            inputBuffer.put(((pixel shr 8) and 0xFF).toByte())  // G
            inputBuffer.put((pixel and 0xFF).toByte())           // B
        }

        // Output: [1, 1001] uint8 probabilities
        val outputBuffer = Array(1) { ByteArray(1001) }
        interpreter.run(inputBuffer, outputBuffer)

        val endTime = System.currentTimeMillis()

        // Find top-3 results
        val probs = outputBuffer[0]
        val indexed = probs.mapIndexed { i, b -> i to (b.toInt() and 0xFF) }
        val topResults = indexed.sortedByDescending { it.second }.take(3)

        val bestIdx = topResults[0].first
        val bestLabel = if (bestIdx < imageLabels.size) imageLabels[bestIdx] else "unknown"
        val bestScore = topResults[0].second / 255.0

        val rawDetails = topResults.joinToString(", ") { (idx, score) ->
            val label = if (idx < imageLabels.size) imageLabels[idx] else "unknown"
            "$label=${score / 255.0f}"
        }

        return mapOf(
            "output" to "$bestLabel [$rawDetails]",
            "confidenceScore" to bestScore,
            "inferenceTimeMs" to (endTime - startTime).toInt()
        )
    }

    fun dispose() {
        nlClassifier?.close()
        nlClassifier = null
        imageInterpreter?.close()
        imageInterpreter = null
        imageLabels = emptyList()
    }
}
