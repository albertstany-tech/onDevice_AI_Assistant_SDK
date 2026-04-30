import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'test_spm_plugin_method_channel.dart';

abstract class TestSpmPluginPlatform extends PlatformInterface {
  /// Constructs a TestSpmPluginPlatform.
  TestSpmPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static TestSpmPluginPlatform _instance = MethodChannelTestSpmPlugin();

  /// The default instance of [TestSpmPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelTestSpmPlugin].
  static TestSpmPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [TestSpmPluginPlatform] when
  /// they register themselves.
  static set instance(TestSpmPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
