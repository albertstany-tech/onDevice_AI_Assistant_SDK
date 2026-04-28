import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'models.dart';
import 'on_device_ai_platform_interface.dart';

/// An implementation of [OnDeviceAiPlatform] that uses method channels.
class MethodChannelOnDeviceAi extends OnDeviceAiPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('on_device_ai');

  @visibleForTesting
  final eventChannel = const EventChannel('on_device_ai_stream');

  @override
  Future<void> loadModel(String modelName, {ModelConfig? config}) async {
    await methodChannel.invokeMethod<void>('loadModel', {
      'modelName': modelName,
      'config': config?.toMap(),
    });
  }

  @override
  Future<AIResult> runText(String prompt) async {
    final result = await methodChannel.invokeMapMethod<String, dynamic>(
      'runText',
      {'prompt': prompt},
    );

    return AIResult(
      output: result?['output'] as String? ?? '',
      confidenceScore: (result?['confidenceScore'] as num?)?.toDouble() ?? 0.0,
      inferenceTimeMs: (result?['inferenceTimeMs'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  Future<AIResult> runImage(Uint8List imageBytes) async {
    final result = await methodChannel.invokeMapMethod<String, dynamic>(
      'runImage',
      {'imageBytes': imageBytes},
    );

    return AIResult(
      output: result?['output'] as String? ?? '',
      confidenceScore: (result?['confidenceScore'] as num?)?.toDouble() ?? 0.0,
      inferenceTimeMs: (result?['inferenceTimeMs'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  Stream<String> streamText(String prompt) {
    methodChannel.invokeMethod<void>('startStreamText', {'prompt': prompt});
    return eventChannel.receiveBroadcastStream().map(
      (dynamic event) => event.toString(),
    );
  }

  @override
  Future<void> dispose() async {
    await methodChannel.invokeMethod<void>('dispose');
  }
}
