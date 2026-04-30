import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:on_device_ai/on_device_ai.dart';
import 'package:on_device_ai/models.dart';
import 'package:on_device_ai/on_device_ai_platform_interface.dart';
import 'package:on_device_ai/on_device_ai_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockOnDeviceAiPlatform
    with MockPlatformInterfaceMixin
    implements OnDeviceAiPlatform {

  @override
  Future<void> loadModel(String modelName, {ModelConfig? config}) async {}

  @override
  Future<AIResult> runText(String prompt) async {
    return AIResult(output: 'Positive', confidenceScore: 0.9, inferenceTimeMs: 10);
  }

  @override
  Future<AIResult> runImage(Uint8List imageBytes) async {
    return AIResult(output: 'Dog', confidenceScore: 0.8, inferenceTimeMs: 15);
  }

  @override
  Stream<String> streamText(String prompt) {
    return Stream.value('Streaming');
  }

  @override
  Future<void> dispose() async {}
}

void main() {
  final OnDeviceAiPlatform initialPlatform = OnDeviceAiPlatform.instance;

  test('$MethodChannelOnDeviceAi is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelOnDeviceAi>());
  });

  test('runText', () async {
    OnDeviceAi onDeviceAiPlugin = OnDeviceAi();
    MockOnDeviceAiPlatform fakePlatform = MockOnDeviceAiPlatform();
    OnDeviceAiPlatform.instance = fakePlatform;

    final result = await onDeviceAiPlugin.runText('test');
    expect(result.output, 'Positive');
  });
}
