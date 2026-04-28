# On-Device AI Assistant SDK

A powerful, cross-platform Flutter plugin that gives developers a single, clean Dart API to run AI/ML inference **entirely on-device**. No internet, no API keys, no server costs.

Under the hood, it seamlessly bridges your Dart code to **Core ML (NaturalLanguage)** on iOS and **TensorFlow Lite (Task Library)** on Android.

---

## 🚀 Features

* **100% On-Device**: Absolute privacy and zero latency. Your data never leaves the device.
* **Unified Dart API**: Write your ML logic once. The plugin handles the complex native bridging.
* **Hardware Acceleration**: Automatically leverages Apple's Neural Engine and Android's NNAPI/GPU delegates where available.
* **Text & Sentiment Analysis**: Built-in integration with Google's MobileBERT (Android) and Apple's NaturalLanguage framework (iOS).

---

## 🛠 Installation

Add `on_device_ai` to your `pubspec.yaml`:

```yaml
dependencies:
  on_device_ai:
    path: path/to/on_device_ai
```

### Android Setup
Ensure your Android project supports a minimum SDK version of 24. Place your `.tflite` models inside your app's `assets/` directory and declare them in your `pubspec.yaml`.

### iOS Setup
No additional configuration is required for basic Sentiment Analysis (which uses Apple's built-in NLP). If you wish to use custom `.mlmodelc` files, ensure they are added to your Xcode project's `Copy Bundle Resources` phase.

---

## 💻 Usage

### 1. Initialize the Plugin & Load a Model

```dart
import 'package:on_device_ai/on_device_ai.dart';

final ai = OnDeviceAi();

// Load the model. 
// On iOS: use 'built_in_sentiment' to utilize the native NLTagger.
// On Android: pass the name of the TFLite asset.
await ai.loadModel(
  Platform.isIOS ? 'built_in_sentiment' : 'sentiment_analysis.tflite', 
  config: ModelConfig(useGPU: true)
);
```

### 2. Run Text Inference (Sentiment Analysis)

Pass a string to the model and receive a categorized result instantly.

```dart
final result = await ai.runText('This SDK is incredibly fast and easy to use!');

print('Output: ${result.output}'); // e.g., "Positive"
print('Confidence: ${result.confidenceScore}'); // e.g., 0.98
print('Inference Time: ${result.inferenceTimeMs}ms'); // e.g., 15ms
```

### 3. Stream Text (Useful for LLMs)

If you are running Generative AI models, you can stream the output tokens.

```dart
ai.streamText('Tell me a story...').listen((token) {
  print(token);
});
```

### 4. Clean Up

Always dispose of the model when finished to free up memory.

```dart
await ai.dispose();
```

---

## 🏗 Architecture

The plugin is composed of three layers:
1. **Dart API**: Provides the clean `OnDeviceAi` interface.
2. **Platform Channels**: Safely passes input configurations and tensor buffers.
3. **Native Runners**: 
   * `TFLiteRunner.kt` (Android): Uses `NLClassifier` from the TensorFlow Lite Task Library to automatically tokenize text and execute `.tflite` binaries.
   * `CoreMLRunner.swift` (iOS): Utilizes Apple's `NaturalLanguage` and `CoreML` frameworks for instantaneous on-device NLP.

---

## 📝 Roadmap
- [ ] Implement FFI (Foreign Function Interface) for ultra-low latency image/tensor byte passing.
- [ ] Add generic `Interpreter` support for custom TFLite models on Android.
- [ ] Support LLM streaming generation (`.mlpackage` / LiteRT).
