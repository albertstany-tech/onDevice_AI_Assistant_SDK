# On-Device AI Assistant SDK Implementation Plan

## Goal Description
Build a cross-platform Flutter plugin (`on_device_ai`) that provides a unified, simple Dart API to run AI/ML inference entirely on-device using Core ML on iOS and TensorFlow Lite (LiteRT) on Android. The plugin abstracts the platform-specific complexities into an easy-to-use API for text, image, and streaming inference.

## Architecture & Layers
1. **Dart API Layer**: A clean, unified interface for Flutter developers to load models, configure execution, and run inference.
2. **Flutter ↔ Native Bridge**: Platform Channels for basic textual inference and control flows. FFI may be explored later for high-throughput data.
3. **Native ML Runners**:
   - **iOS (Swift)**: `CoreML` framework for `.mlmodelc` files.
   - **Android (Kotlin)**: `TensorFlow Lite` (LiteRT) with delegates for `.tflite` models.

## Achievable Capabilities
- **Fast, Local Inference**: Offline execution.
- **Text & Vision Models**: Standard classification, NLP, and vision models.
- **Hardware Acceleration**: Neural Engine / NPUs.

## Blockers & Challenges
- Large model distribution sizes.
- Memory and thermal limits on mobile.
- Core ML on-device compilation limitations.
- Android NNAPI delegate fragmentation.

## Phased Plan

### Phase 1 — Foundation (Weeks 1–3)
- Create the Flutter plugin scaffolding (`on_device_ai`).
- Define the public Dart API (`OnDeviceAI`, `AIResult`, `ModelConfig`).
- Set up iOS `CoreMLRunner` and Android `TFLiteRunner`.
- Validate with a lightweight model (MobileNet).

### Phase 2 — Text Inference (Weeks 4–7)
- Integrate a text-based model (e.g., DistilBERT).
- Handle tokenization/detokenization.
- Connect Dart `runText`.

### Phase 3 — Performance & Advanced (Weeks 8–11)
- Implement hardware delegate configurations.
- Benchmark Platform Channels vs FFI.
- Streaming text responses.

### Phase 4 — Polish & Publish (Weeks 12–16)
- Example App.
- pub.dev documentation.
