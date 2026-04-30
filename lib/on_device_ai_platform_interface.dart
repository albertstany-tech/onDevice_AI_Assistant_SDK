import 'dart:typed_data';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'models.dart';
import 'on_device_ai_method_channel.dart';

/// The platform interface for the `on_device_ai` plugin.
///
/// Platform-specific implementations of this plugin must extend this class
/// rather than implement it directly, as new methods may be added over time
/// and extending ensures backward compatibility.
///
/// The default implementation is [MethodChannelOnDeviceAi].
abstract class OnDeviceAiPlatform extends PlatformInterface {
  /// Constructs an [OnDeviceAiPlatform].
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

  /// Loads the specified model and prepares it for inference.
  ///
  /// See [OnDeviceAi.loadModel] for full documentation.
  Future<void> loadModel(String modelName, {ModelConfig? config}) {
    throw UnimplementedError('loadModel() has not been implemented.');
  }

  /// Runs text inference on the loaded model and returns the result.
  ///
  /// See [OnDeviceAi.runText] for full documentation.
  Future<AIResult> runText(String prompt) {
    throw UnimplementedError('runText() has not been implemented.');
  }

  /// Runs image classification on the loaded model and returns the result.
  ///
  /// See [OnDeviceAi.runImage] for full documentation.
  Future<AIResult> runImage(Uint8List imageBytes) {
    throw UnimplementedError('runImage() has not been implemented.');
  }

  /// Streams generated text tokens from a generative model.
  ///
  /// See [OnDeviceAi.streamText] for full documentation.
  Stream<String> streamText(String prompt) {
    throw UnimplementedError('streamText() has not been implemented.');
  }

  /// Releases native resources held by the currently loaded model.
  ///
  /// See [OnDeviceAi.dispose] for full documentation.
  Future<void> dispose() {
    throw UnimplementedError('dispose() has not been implemented.');
  }
}
