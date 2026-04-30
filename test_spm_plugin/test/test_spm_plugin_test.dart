import 'package:flutter_test/flutter_test.dart';
import 'package:test_spm_plugin/test_spm_plugin.dart';
import 'package:test_spm_plugin/test_spm_plugin_platform_interface.dart';
import 'package:test_spm_plugin/test_spm_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockTestSpmPluginPlatform
    with MockPlatformInterfaceMixin
    implements TestSpmPluginPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final TestSpmPluginPlatform initialPlatform = TestSpmPluginPlatform.instance;

  test('$MethodChannelTestSpmPlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelTestSpmPlugin>());
  });

  test('getPlatformVersion', () async {
    TestSpmPlugin testSpmPlugin = TestSpmPlugin();
    MockTestSpmPluginPlatform fakePlatform = MockTestSpmPluginPlatform();
    TestSpmPluginPlatform.instance = fakePlatform;

    expect(await testSpmPlugin.getPlatformVersion(), '42');
  });
}
