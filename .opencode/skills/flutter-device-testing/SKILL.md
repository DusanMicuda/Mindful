---
name: flutter-device-testing
description: Use when manually validating Android device behavior, permissions, MethodChannels, files, notifications, lifecycle, or deep links in this Android-only app.
---

# Flutter Device Testing

Use an Android device or emulator when behavior depends on Android APIs, permissions, native MethodChannel handlers, files, notifications, lifecycle, or device rendering. Pure Dart and widget behavior belongs in automated tests.

## Before launch

Record Android version/model, device ID and authorization, app/build version, relevant permission state, and existing data affected by the test. Ensure device is awake and unlocked; do not handle credentials or PINs.

```sh
flutter devices
adb devices
```

This checkout is Android-only. Use the default app entry point and configured build types.

## Launch and interaction

```sh
flutter run --device-id <DEVICE_ID>
```

Use accessibility semantics or Android UI inspection before relying on coordinates. Re-inspect after navigation, keyboard appearance, or rotation.

```sh
adb -s <DEVICE_ID> exec-out screencap -p > /tmp/screen.png
adb -s <DEVICE_ID> shell uiautomator dump /sdcard/ui.xml
adb -s <DEVICE_ID> pull /sdcard/ui.xml /tmp/ui.xml
```

For documented deep links, see `docs/API.md`; test using the documented ADB command, substituting the link under test:

```sh
adb shell am start -a android.intent.action.VIEW -d "com.mindful.android://open/home?tab=1"
```

## Verify behavior

- Capture baseline, perform one action, verify resulting state/data, then repeat for duplicate/idempotency behavior where relevant.
- For MethodChannel changes, verify the Dart method, Kotlin handler branch, returned result, and error/unsupported path. Contract locations: `lib/core/services/method_channel_service.dart`, `android/app/src/main/java/com/mindful/android/MainActivity.kt`, and `android/app/src/main/java/com/mindful/android/FgMethodCallHandler.kt`.
- Check permission denial/revocation and supported Android API-level behavior.
- Verify files by type, size, content, and destination; screenshots or filenames alone do not prove correctness.
- Check app background/resume and native/Dart logs for affected lifecycle paths.
- For release artifact authenticity, follow `docs/VERIFICATION.md` and verify signatures with `apksigner`.

## Report

Record scenario, Android device/version, preconditions, action, expected and observed result, evidence, and pass/fail. List untested criteria and distinguish device/environment blockers from app defects.
