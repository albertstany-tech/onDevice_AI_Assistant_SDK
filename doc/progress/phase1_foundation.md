# Phase 1: Foundation & Architecture

**Status**: ✅ Complete  
**Published Version**: `0.0.1` on pub.dev

---

## Objective
Establish the foundational architecture of the `on_device_ai` Flutter plugin. The goal was to define a clean, unified Dart API that abstracts away all native platform differences, so developers using the SDK never need to write any platform-specific code.

---

## What Was Built

### Dart Layer (`lib/`)
| File | Purpose |
|------|---------|
| `on_device_ai.dart` | Public-facing API class. Exposes `loadModel`, `runText`, `runImage`, `streamText`, `dispose`. |
| `on_device_ai_platform_interface.dart` | Abstract base class (Plugin Platform Interface pattern) ensuring any future implementations conform to the same contract. |
| `on_device_ai_method_channel.dart` | Concrete implementation using `MethodChannel` (`on_device_ai`) and `EventChannel` (`on_device_ai_stream`) to communicate with native code. |
| `models.dart` | Shared data models: `AIResult` (holds `output`, `confidenceScore`, `inferenceTimeMs`) and `ModelConfig` (holds `maxTokens`, `temperature`, `useGPU`). |

### Android Native Layer (`android/`)
- Set up `OnDeviceAiPlugin.kt` to register with the Flutter engine and handle method calls.
- Established `TFLiteRunner.kt` as a dedicated class for all ML inference, keeping the plugin handler clean.

### iOS Native Layer (`ios/`)
- Set up `OnDeviceAiPlugin.swift` to register both `MethodChannel` and `EventChannel` handlers.
- Established `CoreMLRunner.swift` as a dedicated class for all Apple-side inference.

### Example App (`example/`)
- Created a simple interactive UI allowing text input and sentiment result display.

---

## Key Design Decisions

### Plugin Platform Interface Pattern
We used the official Flutter `plugin_platform_interface` pattern. This means the SDK is future-proof: the community can provide alternative implementations (e.g., a web version) without changing the public API.

### MethodChannel for Communication
The bridge between Dart and native is a `MethodChannel`. All data is serialized as standard Dart `Map<String, dynamic>` objects, which ensures maximum compatibility across platforms.

### EventChannel for Streaming
A separate `EventChannel` was established for the `streamText` method. This is critical for future Generative AI support (LLMs), where the model outputs tokens one-by-one instead of waiting for the full response.

---

## Publishing Checklist Completed
- Added `LICENSE` (MIT)
- Added `CHANGELOG.md`
- Added `README.md`
- Renamed `docs/` → `doc/` (pub.dev requirement)
- Passed `flutter pub publish --dry-run`
- Published to **pub.dev** as version `0.0.1`
