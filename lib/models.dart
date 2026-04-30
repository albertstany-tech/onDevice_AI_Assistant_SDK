/// Data models shared across the `on_device_ai` SDK.
///
/// Import this library to access [AIResult] and [ModelConfig].
library models;

/// The result returned by an on-device AI inference call.
///
/// All inference methods ([OnDeviceAi.runText], [OnDeviceAi.runImage]) return
/// an [AIResult] containing the model's top prediction, its confidence score,
/// and how long the inference took to run on the device.
///
/// Example:
/// ```dart
/// final result = await ai.runText("This SDK is amazing!");
/// print(result.output);          // "Positive [Negative=0.02, Positive=0.98]"
/// print(result.confidenceScore); // 0.98
/// print(result.inferenceTimeMs); // 12
/// ```
class AIResult {
  /// The human-readable label of the top prediction returned by the model.
  ///
  /// For sentiment analysis this will be `"Positive"`, `"Negative"`, or
  /// `"Neutral"`. For image classification it will be the object name (e.g.
  /// `"Golden Retriever"`). Raw per-category scores are appended in brackets
  /// for debugging purposes.
  final String output;

  /// The confidence score of the top prediction, in the range `[0.0, 1.0]`.
  ///
  /// A value of `1.0` means the model is completely certain. A value closer to
  /// `0.5` indicates low confidence. For sentiment analysis on iOS this is the
  /// magnitude of the raw sentiment score (i.e. `abs(score)`).
  final double confidenceScore;

  /// The wall-clock time taken to run inference on the native side, in milliseconds.
  ///
  /// This does not include Flutter-to-native serialization overhead — it
  /// measures only the time spent inside the model's forward pass.
  final int inferenceTimeMs;

  /// Creates an [AIResult] with the given [output], [confidenceScore], and
  /// [inferenceTimeMs].
  const AIResult({
    required this.output,
    required this.confidenceScore,
    required this.inferenceTimeMs,
  });
}

/// Configuration options passed to [OnDeviceAi.loadModel].
///
/// All fields have sensible defaults and can be omitted for most use cases.
///
/// Example:
/// ```dart
/// await ai.loadModel(
///   'sentiment_analysis.tflite',
///   config: ModelConfig(useGPU: false),
/// );
/// ```
class ModelConfig {
  /// The maximum number of output tokens to generate.
  ///
  /// Only relevant for generative (LLM) models. Ignored by classification
  /// models such as sentiment analysis and image classification.
  /// Defaults to `256`.
  final int maxTokens;

  /// The sampling temperature for generative models.
  ///
  /// Higher values (e.g. `1.0`) produce more creative, varied output. Lower
  /// values (e.g. `0.2`) produce more deterministic output. Only relevant for
  /// generative models. Defaults to `0.7`.
  final double temperature;

  /// Whether to attempt to delegate inference to the GPU or Neural Engine.
  ///
  /// When `true`, the SDK will try to use hardware acceleration (e.g. Metal
  /// on iOS, NNAPI delegate on Android). Falls back to CPU automatically if
  /// the hardware delegate is not available. Defaults to `true`.
  final bool useGPU;

  /// Creates a [ModelConfig] with the given options.
  ///
  /// All parameters are optional and have sensible defaults.
  const ModelConfig({
    this.maxTokens = 256,
    this.temperature = 0.7,
    this.useGPU = true,
  });

  /// Serializes this configuration to a [Map] for passing over the platform channel.
  Map<String, dynamic> toMap() {
    return {
      'maxTokens': maxTokens,
      'temperature': temperature,
      'useGPU': useGPU,
    };
  }
}
