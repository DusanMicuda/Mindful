---
name: flutter-native-integration
description: Use when implementing or validating Flutter-to-Android integrations through this app's MethodChannels and Kotlin handlers.
---

# Flutter Native Integration

This checkout targets Android only. Flutter calls Kotlin through plain `MethodChannel`s.

## Contract and registration

- `lib/core/services/method_channel_service.dart:32-53` defines the foreground channel `com.mindful.android.methodchannel.fg`, invokes native methods, and handles `updateSelfStartStatus`.
- `android/app/src/main/java/com/mindful/android/MainActivity.kt:59-78` registers `FgMethodCallHandler` on that channel, sends self-start status, and disposes the handler on activity destruction.
- `android/app/src/main/java/com/mindful/android/FgMethodCallHandler.kt:99-100,433` dispatches method names in `onMethodCall` and uses `result.notImplemented()` for unknown methods. Keep Dart method names, argument shapes, and result types aligned with this `when` dispatch.
- The background channel `com.mindful.android.methodchannel.bg` is used by `lib/core/services/bg_executor_service.dart:25-68` and `android/app/src/main/java/com/mindful/android/workers/FlutterBgExecutionWorker.kt:72-107` for task dispatch and `signalTaskCompleted`.

## Workflow

1. Trace the Dart caller, channel method, Kotlin branch, and result/error path before editing.
2. Keep OS APIs, permissions, and Android lifecycle work in Kotlin; keep presentation and app policy in Dart.
3. Preserve channel names and method argument/result contracts, or update both ends together.
4. Return each `MethodChannel.Result` exactly once, including asynchronous paths; use `notImplemented()` for unsupported methods.
5. Tie activity-bound work to the activity lifecycle, release service connections, and do not retain an activity beyond its lifetime.
6. Validate with focused Flutter tests and `flutter analyze`; for native changes run `flutter build apk --debug` and test on Android hardware when behavior depends on OS APIs.

See [Android guidance](android.md) for the current handler and lifecycle pattern.
