import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'test_spm_plugin_platform_interface.dart';

/// An implementation of [TestSpmPluginPlatform] that uses method channels.
class MethodChannelTestSpmPlugin extends TestSpmPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('test_spm_plugin');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }
}
