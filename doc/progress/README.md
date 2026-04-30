# SDK Development Progress Log

This folder documents the end-to-end development history of the `on_device_ai` Flutter plugin, organized by development phase. Each file captures the objective, technical decisions, implementation details, and lessons learned for that phase.

---

## Phases

| Phase | Document | Status | Description |
|-------|----------|--------|-------------|
| 1 | [phase1_foundation.md](./phase1_foundation.md) | ✅ Complete | Plugin architecture, Dart API, MethodChannel/EventChannel bridge, pub.dev publishing |
| 2 | [phase2_text_inference.md](./phase2_text_inference.md) | ✅ Complete | Real on-device sentiment analysis using MobileBERT (Android) and Apple NaturalLanguage (iOS) |
| 3 | [phase3_image_classification.md](./phase3_image_classification.md) | ✅ Complete | Multimodal image classification using MobileNet V1 (Android) and Apple Vision framework (iOS) |

---

## Planned Phases (Roadmap)

| Phase | Description | Priority |
|-------|-------------|----------|
| 4 | **Hybrid Android Architecture**: AICore (Gemini Nano) with TFLite fallback for full device coverage | High |
| 5 | **Generative AI (LLM Chatbots)**: Run SLMs like Gemma 2B on-device, streaming tokens via EventChannel | High |
| 6 | **Dart FFI Bridge**: Replace MethodChannel with `dart:ffi` for zero-copy memory access, enabling real-time video inference | Medium |
| 7 | **Dynamic Model Downloads**: `ModelDownloadManager` to fetch and cache models on-demand, reducing initial app size | Medium |

---

## SDK Capabilities Matrix

| Feature | Android | iOS | Notes |
|---------|---------|-----|-------|
| Sentiment Analysis (`runText`) | ✅ MobileBERT (TFLite) | ✅ Apple NaturalLanguage | iOS requires real device (not Simulator) |
| Image Classification (`runImage`) | ✅ MobileNet V1 (TFLite) | ✅ Apple Vision Framework | Both work fully offline |
| Token Streaming (`streamText`) | 🚧 Mocked | 🚧 Mocked | Will be real with Phase 5 (LLMs) |
| Generative AI | ❌ Not yet | ❌ Not yet | Planned for Phase 5 |
| Visual Question Answering | ❌ Not yet | ❌ Not yet | Requires gigabyte-scale models |

---

## Tech Stack Summary

### Dart / Flutter
- `MethodChannel` + `EventChannel` for native bridge
- `plugin_platform_interface` pattern for extensibility

### Android (Kotlin)
- `org.tensorflow:tensorflow-lite:2.11.0` — base interpreter
- `org.tensorflow:tensorflow-lite-support:0.4.4` — image/text utilities
- `org.tensorflow:tensorflow-lite-task-text:0.4.4` — NLClassifier for text
- `kotlinx.coroutines` — async background inference

### iOS (Swift)
- `NaturalLanguage` framework — built-in OS sentiment analysis
- `Vision` framework — built-in OS image classification
- Zero additional model downloads required on iOS
