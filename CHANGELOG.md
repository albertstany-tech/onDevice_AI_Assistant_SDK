## 0.1.2

### iOS Improvements
* Added **Swift Package Manager (SPM)** support via `ios/Package.swift`. The plugin
  now works in Xcode projects that use SPM instead of CocoaPods, resolving the
  pub.dev platform score warning.
* Updated `on_device_ai.podspec` with correct version number (`0.1.2`), accurate
  description, and explicit declarations for the `NaturalLanguage`, `Vision`, and
  `CoreML` system frameworks.

---

## 0.1.1


### Documentation
* Added full `dartdoc` comments to all public API elements: `AIResult`, `ModelConfig`,
  `OnDeviceAi`, and `OnDeviceAiPlatform`. This satisfies the pub.dev documentation
  score requirement (≥20% of public API elements documented).

---

## 0.1.0


### New Features
* **Image Classification** (`runImage`): Pass an image byte array and receive an on-device classification result (e.g. "Golden Retriever: 94%") with no internet connection.
  * **Android**: Uses a bundled MobileNet V1 quantized TFLite model (~4MB) via the stable base `tensorflow-lite:2.11.0` interpreter.
  * **iOS**: Uses Apple's built-in `Vision` framework (`VNClassifyImageRequest`) — zero model downloads required.
* **Multimodal Example App**: The example app now includes an image picker UI to test both text and image AI pipelines on the same screen.

### Improvements
* **Android threading**: All TFLite operations (`loadModel`, `runText`, `runImage`, `dispose`) now run on a background `Dispatchers.IO` coroutine to prevent UI-thread blocking.
* **iOS sentiment reliability**: Fixed a bug where `NLTagger` always returned "Neutral" by switching from `tag(at:)` to `enumerateTags` and explicitly forcing the `.english` language tag.

### Bug Fixes
* Fixed a native JNI crash (`SIGSEGV` in `libtask_vision_jni.so`) on Android 10 devices caused by `tensorflow-lite-task-vision:0.4.4`. Replaced with a stable manual inference pipeline using `tensorflow-lite:2.11.0`.
* Fixed a Gradle build failure (`Plugin [id: 'com.android.library'] was not found`) by migrating the Android plugin build script from Kotlin DSL (`build.gradle.kts`) to Groovy (`build.gradle`).

---

## 0.0.1

* Initial release.
* Support for on-device Text Inference via Core ML (iOS) and TensorFlow Lite (Android).
* Unified Dart API for model loading, text inference, and streaming.
