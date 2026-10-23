# Android Native Integration

## MethodChannel handler pattern

`MainActivity.configureFlutterEngine` creates the foreground `MethodChannel` and registers `FgMethodCallHandler` (`android/app/src/main/java/com/mindful/android/MainActivity.kt:59-72`). The handler switches on `call.method`, reads arguments, performs native work, and completes with `result.success(...)`; unknown methods use `result.notImplemented()` (`android/app/src/main/java/com/mindful/android/FgMethodCallHandler.kt:99-100,433`). Mirror every contract change in `lib/core/services/method_channel_service.dart:32-53,63-76`.

For background Dart execution, `FlutterBgExecutionWorker.kt:58-107` starts a Flutter engine, registers foreground and background channels, and waits for `signalTaskCompleted`; Dart dispatch lives in `lib/core/services/bg_executor_service.dart:25-68`.

## Lifecycle and permissions

- Keep channel callbacks on the platform-required thread. Move blocking work off the main thread and marshal UI or activity-result APIs to the main thread.
- Complete each `MethodChannel.Result` once, including callbacks from services and activity results.
- Release service bindings in the owning handler's `dispose`; avoid retaining `Activity` beyond its lifecycle.
- Check current Android permission/API requirements before sensitive operations. Request interactive permissions from a valid foreground activity and handle denial.
- Close resources and handle cancellation or process interruption on every exit path.

## Build and device checks

- Gradle uses Groovy DSL: `android/settings.gradle`, `android/build.gradle`, and `android/app/build.gradle`.
- Toolchain currently declares Java/JVM 17, Android Gradle Plugin 8.10.1, Kotlin plugin 1.8.22, and Gradle wrapper 8.14.2. Do not copy Kotlin-DSL snippets into these files.
- Run `flutter build apk --debug` after native changes. Use `adb devices` and `flutter devices` to identify an authorized test device; validate permission denial, app background/resume, and the channel result for affected behavior.
