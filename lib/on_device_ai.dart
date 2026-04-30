import 'dart:typed_data';
import 'models.dart';
export 'models.dart';
import 'on_device_ai_platform_interface.dart';

/// The main entry point for the `on_device_ai` SDK.
///
/// Provides a simple, unified API for running on-device AI inference across
/// iOS (using Apple's built-in frameworks) and Android (using TensorFlow Lite),
/// with no internet connection required.
///
/// ## Quick Start
///
/// ```dart
/// import 'package:on_device_ai/on_device_ai.dart';
///
/// final ai = OnDeviceAi();
///
/// // Load a model first
/// await ai.loadModel('sentiment_analysis.tflite');
///
/// // Run text inference
/// final result = await ai.runText('This SDK is amazing!');
/// print(result.output);          // "Positive"
/// print(result.confidenceScore); // 0.98
///
/// // Clean up when done
/// await ai.dispose();
/// ```
class OnDeviceAi {
  /// Loads the specified model and prepares it for inference.
  ///
  /// Must be called before [runText], [runImage], or [streamText].
  ///
  /// On **Android**, [modelName] should be the filename of a `.tflite` asset
  /// bundled in your app (e.g. `'sentiment_analysis.tflite'`).
  ///
  /// On **iOS**, special model names are supported to use built-in frameworks:
  /// - `'built_in_sentiment'` — uses Apple's `NaturalLanguage` framework.
  /// - `'built_in_vision'` — uses Apple's `Vision` framework.
  ///
  /// Optionally pass a [ModelConfig] to configure hardware acceleration and
  /// other inference settings.
  ///
  /// Throws a [PlatformException] if the model cannot be found or loaded.
  Future<void> loadModel(String modelName, {ModelConfig? config}) {
    return OnDeviceAiPlatform.instance.loadModel(modelName, config: config);
  }

  /// Runs text inference on the loaded model and returns the result.
  ///
  /// Typically used for **sentiment analysis** or other text classification
  /// tasks. The [prompt] is the raw text string to analyze.
  ///
  /// Returns an [AIResult] with the top prediction label, confidence score,
  /// and inference latency in milliseconds.
  ///
  /// [loadModel] must be called before this method.
  ///
  /// Example:
  /// ```dart
  /// final result = await ai.runText('I love this product!');
  /// print(result.output); // "Positive"
  /// ```
  Future<AIResult> runText(String prompt) {
    return OnDeviceAiPlatform.instance.runText(prompt);
  }

  /// Runs image classification on the loaded model and returns the result.
  ///
  /// Accepts raw image bytes ([Uint8List]) in JPEG or PNG format. The bytes
  /// are decoded, resized, and fed through the on-device model natively.
  ///
  /// Returns an [AIResult] with the top predicted object label, confidence
  /// score, and inference latency in milliseconds.
  ///
  /// [loadModel] must be called before this method.
  ///
  /// Example:
  /// ```dart
  /// final bytes = await File('photo.jpg').readAsBytes();
  /// final result = await ai.runImage(bytes);
  /// print(result.output); // "Golden Retriever"
  /// ```
  Future<AIResult> runImage(Uint8List imageBytes) {
    return OnDeviceAiPlatform.instance.runImage(imageBytes);
  }

  /// Streams generated text tokens from a generative model.
  ///
  /// Designed for Large Language Model (LLM) inference where the model
  /// produces tokens one-by-one. Each event in the returned [Stream] is a
  /// single token string. The stream completes when the model finishes.
  ///
  /// > **Note**: In the current version (`0.1.0`), this method returns a
  /// > mocked stream. Real LLM support is planned for a future release.
  ///
  /// [loadModel] must be called before this method.
  Stream<String> streamText(String prompt) {
    return OnDeviceAiPlatform.instance.streamText(prompt);
  }

  /// Releases native resources held by the currently loaded model.
  ///
  /// Call this when the AI features are no longer needed (e.g. in a widget's
  /// `dispose` method) to free memory and GPU/NPU allocations.
  ///
  /// After calling [dispose], you must call [loadModel] again before running
  /// any further inference.
  Future<void> dispose() {
    return OnDeviceAiPlatform.instance.dispose();
  }
}
