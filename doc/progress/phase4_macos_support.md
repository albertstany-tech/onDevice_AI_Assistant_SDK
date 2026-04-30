# Phase 4: macOS Platform Support

## Overview
This phase focuses on expanding the `on_device_ai` cross-platform Flutter plugin to support macOS. Having achieved a stable release for iOS and Android (up to v0.1.2) with a 100/100 pub.dev score, this phase aims to implement the macOS desktop equivalent using Apple's Core ML and Vision frameworks.

## Current Progress (Pre-Phase 4)
*   **Version Release**: Published versions `0.1.0`, `0.1.1`, and `0.1.2` to `pub.dev`.
*   **Documentation Improvements**: Added full `dartdoc` comments (`///`) to all public API elements (`AIResult`, `ModelConfig`, `OnDeviceAi`, `OnDeviceAiPlatform`), satisfying pub.dev’s documentation requirement.
*   **iOS SPM Support**: Added `ios/Package.swift` to enable Swift Package Manager integration, resolving the pub.dev platform score warning regarding native dependency management.
*   **Podspec Maintenance**: Updated `on_device_ai.podspec` with correct metadata, explicit system framework declarations (`NaturalLanguage`, `Vision`, `CoreML`), and corrected the iOS platform target to `14.0`.

## Implementation Plan for macOS
To bring macOS support to the SDK, we will adapt the existing iOS implementations for the macOS environment. The core task is to swap `UIKit` components (`UIImage`) for their `AppKit` counterparts (`NSImage`) where image processing occurs, while reusing the majority of the `NaturalLanguage` and `Vision` code.

### 1. `pubspec.yaml`
- Add `macos` to the `plugin.platforms` section, mirroring the setup for `ios`.
- Keep dependencies updated.

### 2. Native Plugin Architecture (`macos/`)
- Create `macos/on_device_ai.podspec` (targeting macOS 11.0).
- Create `macos/Package.swift` to ensure Swift Package Manager compatibility right out of the gate.
- Create `macos/Classes/OnDeviceAiPlugin.swift` using `FlutterMacOS` instead of `Flutter`.
- Create `macos/Classes/CoreMLRunner.swift` logic.
  - For image classification, use `NSImage` from `AppKit` to extract the `cgImage` before feeding it into the `VNImageRequestHandler`.

### 3. Example App Updates (`example/`)
- Generate the macOS application runner by running `flutter create --platforms=macos .` inside the `example` directory.
- Ensure the `image_picker` handles macOS selection appropriately via file system dialogs (`NSOpenPanel` under the hood via the flutter plugin).

### 4. Verification
- Verify the `pub.dev` score logic via a dry run to ensure the platform score ticks up to 3/6 without errors.
- Test both Text inference and Image classification on the generated macOS example application.
