
import 'test_spm_plugin_platform_interface.dart';

class TestSpmPlugin {
  Future<String?> getPlatformVersion() {
    return TestSpmPluginPlatform.instance.getPlatformVersion();
  }
}
