import 'package:flutter_test/flutter_test.dart';
import 'package:on_device_ai/on_device_ai.dart';
import 'package:on_device_ai/on_device_ai_platform_interface.dart';
import 'package:on_device_ai/on_device_ai_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockOnDeviceAiPlatform
    with MockPlatformInterfaceMixin
    implements OnDeviceAiPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final OnDeviceAiPlatform initialPlatform = OnDeviceAiPlatform.instance;

  test('$MethodChannelOnDeviceAi is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelOnDeviceAi>());
  });

  test('getPlatformVersion', () async {
    OnDeviceAi onDeviceAiPlugin = OnDeviceAi();
    MockOnDeviceAiPlatform fakePlatform = MockOnDeviceAiPlatform();
    OnDeviceAiPlatform.instance = fakePlatform;

    expect(await onDeviceAiPlugin.getPlatformVersion(), '42');
  });
}
