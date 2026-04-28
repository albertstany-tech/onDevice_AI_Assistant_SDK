# Publishing Guide: On-Device AI SDK

This document outlines the required steps to publish the `on_device_ai` plugin to `pub.dev`. 
A script or developer must manually follow these steps to ensure a high Pub Points score.

## 1. Prerequisites Checklist

Before publishing, ensure the following files exist and are correctly configured:
- `pubspec.yaml`: Must have a valid `description` (60-180 chars) and `homepage` / `repository` link. The `publish_to: none` restriction MUST be removed.
- `LICENSE`: Must be an OSI-approved open-source license (e.g., MIT).
- `CHANGELOG.md`: Must document the current release version.
- `README.md`: Must be comprehensive and well-formatted.

## 2. Formatting and Analysis

Pub.dev will deduct points if the code is not formatted according to Dart conventions or if there are analyzer warnings.
Run these from the root directory:
```bash
dart format .
flutter analyze
```
Ensure the output of `flutter analyze` shows `No issues found!`.

## 3. Dry Run Validation

Always run a dry-run before publishing. This command simulates the upload process and checks pub.dev's strict requirements without actually pushing the code.
```bash
flutter pub publish --dry-run
```
Review the output. Ensure the package size is reasonable and it reports `Package has 0 warnings`.

## 4. Publish to pub.dev

If the dry run succeeds, execute the publish command:
```bash
flutter pub publish
```
**Authentication**: The terminal will display a Google account authorization link. 
1. Open the link in a browser.
2. Sign in with the Google Account that will own the package.
3. Grant permissions to Dart pub.

Once authorized, the upload will complete automatically. Within a few minutes, the package will be searchable and live on [pub.dev](https://pub.dev).
