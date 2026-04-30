# Phase 3: Multimodal Image Classification

**Status**: ✅ Complete  
**Affected Platforms**: Android, iOS

---

## Objective
Implement the `runImage()` method to enable the SDK to classify objects in images entirely on-device. This upgrades the SDK from a purely text-based NLP tool to a true **Multimodal AI SDK**.

A developer calling `ai.runImage(imageBytes)` should receive a classification result like `"Golden Retriever [confidence: 94%]"` without any internet connection.

---

## Android Implementation

### Initial Approach (Failed)
```gradle
// This library causes a native JNI SIGSEGV crash on Android 10
implementation("org.tensorflow:tensorflow-lite-task-vision:0.4.4")
```
**Root Cause**: `tensorflow-lite-task-vision:0.4.4` has a confirmed bug in its native C++ shared library (`libtask_vision_jni.so`). The `ImageClassifier.createFromFileAndOptions()` JNI call corrupts memory (`je_free` in bionic libc) during initialization on Android 10 devices (confirmed on Redmi Note 7 Pro, Snapdragon 675). This crash occurs regardless of threading.

### Final Approach (Stable)
```gradle
implementation 'org.tensorflow:tensorflow-lite:2.11.0'
implementation 'org.tensorflow:tensorflow-lite-support:0.4.4'
```

### Model: MobileNet V1 (Quantized)
- **File**: `mobilenet_v1_1.0_224_quant.tflite` (~4MB) — the Task-Library-compatible version with embedded metadata, downloaded from Google's official storage.
- **Labels File**: `labels_mobilenet_quant_v1_224.txt` (1001 ImageNet classes)
- **Capability**: Recognizes 1,000 real-world objects (animals, vehicles, household items, food, etc.)

### How the Manual Inference Pipeline Works (Android)
Because we bypassed the high-level Task Library, we manually handle the entire preprocessing pipeline:

```
Raw Image Bytes (from Flutter)
  └─► BitmapFactory.decodeByteArray()          — Decode JPEG/PNG bytes to Bitmap
  └─► Bitmap.createScaledBitmap(224, 224)       — Resize to model input size
  └─► bitmap.getPixels()                        — Extract pixel integer array
  └─► ByteBuffer (uint8, R/G/B channels)        — Pack RGB values into input tensor
  └─► Interpreter.run(inputBuffer, outputBuffer) — Run TFLite inference
  └─► outputBuffer[0]: ByteArray[1001]           — Read probability scores (uint8)
  └─► Sort by score, map index → label string    — Decode top-3 results
  └─► Return Map<String, Any> to Flutter         — Send result via MethodChannel
```

### Threading Fix
All TFLite operations (`loadModel`, `runText`, `runImage`, `dispose`) are executed on `Dispatchers.IO` via Kotlin coroutines. Results are posted back to the main thread via `Handler(Looper.getMainLooper()).post { result.success(...) }`.

---

## iOS Implementation

### Library: Apple Vision Framework (Built-In)
```swift
import Vision
```

### Model: Built-in OS Model (No Download Required)
Apple's `Vision` framework provides a `VNClassifyImageRequest` that uses the iPhone's Neural Engine to classify images. Just like the NaturalLanguage framework for text, this requires zero downloads and works offline.

### How It Works (iOS)
1. `loadModel()` receives `"built_in_vision"` and sets `useBuiltInVision = true`.
2. `runImage()` converts the incoming `FlutterStandardTypedData` bytes to `UIImage` → `CGImage`.
3. A `VNImageRequestHandler` is created with the `CGImage`.
4. `VNClassifyImageRequest` is performed. The closure receives a list of `VNClassificationObservation` objects sorted by confidence.
5. The top 3 results are formatted and returned to Dart.

---

## Build System Change

### Problem
`android/build.gradle.kts` (Kotlin DSL) was throwing `Plugin [id: 'com.android.library'] was not found` because the `plugins { }` block in `.kts` files evaluates *before* the `buildscript { classpath }` block is populated.

### Fix
Converted `android/build.gradle.kts` → `android/build.gradle` (Groovy syntax). Groovy build scripts evaluate the `buildscript` block first, which guarantees the Android Gradle Plugin classpath is available when plugins are applied.

---

## Example App Changes
- Added `image_picker: ^1.1.2` to `example/pubspec.yaml`.
- Added a dedicated **Image Analysis** section to `example/lib/main.dart` with an **"Pick Image & Analyze"** button.
- The app intelligently switches between the text model and vision model when the user changes tabs, avoiding unnecessary reloads.

---

## Issues Encountered & Resolved

| Issue | Root Cause | Fix |
|-------|-----------|-----|
| App crashes on image pick (SIGSEGV) | `tensorflow-lite-task-vision:0.4.4` native JNI bug on Android 10 | Replaced with base `tensorflow-lite:2.11.0` + manual pipeline |
| Stale model in cache causes crash | Old broken model cached from first run; `file.exists()` check skipped re-copy | Changed to always delete and re-copy the model on `loadModel()` |
| Gradle build failure | Kotlin DSL `plugins` block evaluated before `buildscript` classpath on standalone plugin projects | Migrated to Groovy `build.gradle` |
| Unit tests failing after API change | Auto-generated boilerplate tests referenced deleted `getPlatformVersion()` method | Rewrote all 3 test files to test `runText` and `runImage` |
