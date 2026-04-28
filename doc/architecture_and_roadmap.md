# Architecture & Roadmap: On-Device AI SDK

This document explains the inner workings of the On-Device AI Assistant SDK, the contents of the bundled machine learning models, and the roadmap for future improvements.

## 1. How the Current SDK Works

The SDK bridges Flutter's Dart environment with highly optimized, native Machine Learning frameworks. When a developer calls `ai.runText("This SDK is amazing!")`, the following sequence occurs:

1. **The Bridge (MethodChannel)**: The Dart code serializes the string input and configuration options, passing them across the Flutter `MethodChannel` to the native platform.
2. **On iOS (Apple NaturalLanguage)**: 
   - The Swift code receives the string and passes it into Apple's `NaturalLanguage` (`NLTagger`) framework. 
   - This framework utilizes a proprietary, highly-optimized ML model deeply embedded in the iOS operating system itself.
   - It calculates the sentiment score using the iPhone's Neural Engine hardware without needing to download or load a heavy `.mlmodel` file, returning the score to Dart instantly.
3. **On Android (TensorFlow Lite)**: 
   - The Kotlin code receives the string and passes it to the `NLClassifier` (part of the TFLite Task Library).
   - The classifier opens the bundled `.tflite` file from the `assets/` directory.
   - It automatically *tokenizes* the text (converts words into integer IDs), pushes those tensors through the neural network layers, grabs the highest probability result (e.g., "Positive"), and sends it back to Dart.

---

## 2. What is inside `sentiment_analysis.tflite`?

A `.tflite` (TensorFlow Lite) file is a highly compressed binary file designed specifically for edge computing on mobile devices. Our bundled file contains two critical components:

* **The Neural Network (Weights & Graph)**: It contains the actual mathematical layers of a miniaturized version of **BERT** (MobileBERT). This network has been trained on millions of sentences to understand and classify human sentiment.
* **The Metadata**: Embedded inside the binary is a **Vocabulary Dictionary** (a mapping of thousands of words to unique ID numbers, e.g., "amazing" = `4051`) and the **Output Labels** (e.g., `0 = Negative`, `1 = Positive`). Because this metadata is bundled securely inside the file, the TFLite Task Library automatically knows exactly how to convert the user's raw text string into the specific numbers the math layers require.

---

## 3. Roadmap: Improving the SDK Further

While the current classification pipeline is robust, the following features represent the next major leaps for the SDK:

### A. Computer Vision (`runImage`)
We can implement the `runImage()` method to process visual data. By taking an image payload from the Flutter Camera, we can pass the byte array to native code, convert it to a `CVPixelBuffer` (iOS) or `Bitmap` (Android), and run it through models like **MobileNet** (image classification) or **YOLO** (object detection).

### B. Generative AI (LLM Chatbots)
The current SDK performs *Classification* (picking categories). The next massive leap is *Generation* (like ChatGPT). We can integrate quantization frameworks to run Small Language Models (SLMs) like **Gemma 2B**, **Llama 3 8B**, or **Phi-3** directly on the phone, streaming the response tokens back through the `EventChannel` we have already set up.

### C. Dart FFI (Foreign Function Interface)
Currently, we rely on `MethodChannels`. If we want to process 60 frames per second of live video for AI, `MethodChannels` are too slow due to serialization overhead. We can upgrade the bridge to **Dart FFI**, which allows Dart to share raw memory pointers directly with Native C/C++, resulting in zero-copy, ultra-low latency inference.

### D. Dynamic Model Downloads
Currently, the `.tflite` file is bundled directly in the `pubspec.yaml`, which increases the initial App Store download size. We can build a `ModelDownloadManager` in Dart that fetches large models from a cloud bucket on-demand after the user installs the app, caching them to the local file system.
