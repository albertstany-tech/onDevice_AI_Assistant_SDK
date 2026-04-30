import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:on_device_ai/on_device_ai_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelOnDeviceAi platform = MethodChannelOnDeviceAi();
  const MethodChannel channel = MethodChannel('on_device_ai');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          if (methodCall.method == 'runText') {
            return {
              'output': 'Positive',
              'confidenceScore': 0.9,
              'inferenceTimeMs': 10
            };
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('runText', () async {
    final result = await platform.runText('test');
    expect(result.output, 'Positive');
  });
}
