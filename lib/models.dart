import 'dart:typed_data';

class AIResult {
  final String output;
  final double confidenceScore;
  final int inferenceTimeMs;

  AIResult({
    required this.output,
    required this.confidenceScore,
    required this.inferenceTimeMs,
  });
}

class ModelConfig {
  final int maxTokens;
  final double temperature;
  final bool useGPU;

  ModelConfig({
    this.maxTokens = 256,
    this.temperature = 0.7,
    this.useGPU = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'maxTokens': maxTokens,
      'temperature': temperature,
      'useGPU': useGPU,
    };
  }
}
