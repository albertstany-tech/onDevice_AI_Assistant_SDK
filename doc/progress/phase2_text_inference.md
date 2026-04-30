# Phase 2: Real On-Device Text Inference (Sentiment Analysis)

**Status**: ✅ Complete  
**Affected Platforms**: Android, iOS

---

## Objective
Replace the Phase 1 mocked AI responses with real, functional, on-device machine learning inference. The showcase task was **Sentiment Analysis**: given a sentence, the SDK returns whether it is Positive, Negative, or Neutral, along with a confidence score, without any internet connection.

---

## Android Implementation

### Library: TensorFlow Lite Task Library (Text)
```gradle
implementation("org.tensorflow:tensorflow-lite-task-text:0.4.4")
```

### Model: MobileBERT (Sentiment Analysis)
- **File**: `sentiment_analysis.tflite` (~40MB) bundled in `example/assets/`
- **Architecture**: A miniaturized version of Google's BERT transformer model, compressed via quantization to run efficiently on mobile hardware.
- **Why MobileBERT**: It contains embedded metadata (vocabulary dictionary + output labels) inside the `.tflite` binary itself. The TFLite Task Library reads this metadata and automatically handles tokenization — converting raw text to integer token IDs — without any extra code.

### How It Works (Android)
1. `loadModel()` copies the `.tflite` file from the Flutter asset bundle to the app's internal cache directory (required because TFLite needs a file path, not a stream).
2. `NLClassifier.createFromFileAndOptions()` loads the model and reads its metadata.
3. `classifier.classify(prompt)` tokenizes the input text, runs it through the neural network layers, and returns a list of `Category` objects (label + score).
4. The Kotlin code picks the category with the highest score and sends the result back to Dart.

---

## iOS Implementation

### Library: Apple NaturalLanguage Framework
```swift
import NaturalLanguage
```

### Model: Built-in OS Model (No Download Required)
Apple embeds a proprietary, highly-optimized sentiment model directly into the iOS operating system. It runs on the Neural Engine hardware.

### How It Works (iOS)
1. `loadModel()` receives `"built_in_sentiment"` as the model name and sets a flag (`useBuiltInNLP = true`).
2. `runText()` creates an `NLTagger` with the `.sentimentScore` scheme.
3. The language is explicitly forced to `.english` to prevent failures on short inputs.
4. `enumerateTags()` is used to scan the full paragraph (more reliable than `tag(at:)`).
5. The raw score (a `Double` from -1.0 to +1.0) is thresholded: `> 0.2 → Positive`, `< -0.2 → Negative`, otherwise `Neutral`.

### Known Limitation
Apple's NaturalLanguage sentiment model is **not available on iOS Simulators** and requires a real physical device running iOS 13+. Testing on a real iPhone is required to validate this feature.

---

## Debugging & Diagnostics Added
- The `output` field in `AIResult` was extended to include raw debug information: `"Positive [Raw: 0.87, Avail: true]"` so developers can calibrate thresholds.
- Added `NLTagger.availableTagSchemes` check on iOS to detect unsupported devices at runtime.

---

## Issues Encountered & Resolved

| Issue | Root Cause | Fix |
|-------|-----------|-----|
| iOS always returns Neutral | `tag(at:)` fails on short strings when language is auto-detected | Switched to `enumerateTags` and forced `.english` language |
| iOS NLP unavailable on Simulator | Apple does not ship NLP models to Simulators | Must test on a real physical iPhone |
| Android asset loading crash | TFLite requires a file path, not a stream | Added cache-copy mechanism in `TFLiteRunner.kt` |
