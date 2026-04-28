import 'dart:typed_data';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'models.dart';
import 'on_device_ai_method_channel.dart';

abstract class OnDeviceAiPlatform extends PlatformInterface {
  /// Constructs a OnDeviceAiPlatform.
  OnDeviceAiPlatform() : super(token: _token);

  static final Object _token = Object();

  static OnDeviceAiPlatform _instance = MethodChannelOnDeviceAi();

  /// The default instance of [OnDeviceAiPlatform] to use.
  ///
  /// Defaults to [MethodChannelOnDeviceAi].
  static OnDeviceAiPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [OnDeviceAiPlatform] when
  /// they register themselves.
  static set instance(OnDeviceAiPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> loadModel(String modelName, {ModelConfig? config}) {
    throw UnimplementedError('loadModel() has not been implemented.');
  }

  Future<AIResult> runText(String prompt) {
    throw UnimplementedError('runText() has not been implemented.');
  }

  Future<AIResult> runImage(Uint8List imageBytes) {
    throw UnimplementedError('runImage() has not been implemented.');
  }

  Stream<String> streamText(String prompt) {
    throw UnimplementedError('streamText() has not been implemented.');
  }

  Future<void> dispose() {
    throw UnimplementedError('dispose() has not been implemented.');
  }
}
