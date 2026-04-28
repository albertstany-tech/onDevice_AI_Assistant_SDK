import 'dart:typed_data';
import 'models.dart';
export 'models.dart';
import 'on_device_ai_platform_interface.dart';

class OnDeviceAi {
  Future<void> loadModel(String modelName, {ModelConfig? config}) {
    return OnDeviceAiPlatform.instance.loadModel(modelName, config: config);
  }

  Future<AIResult> runText(String prompt) {
    return OnDeviceAiPlatform.instance.runText(prompt);
  }

  Future<AIResult> runImage(Uint8List imageBytes) {
    return OnDeviceAiPlatform.instance.runImage(imageBytes);
  }

  Stream<String> streamText(String prompt) {
    return OnDeviceAiPlatform.instance.streamText(prompt);
  }

  Future<void> dispose() {
    return OnDeviceAiPlatform.instance.dispose();
  }
}
