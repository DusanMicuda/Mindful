---
name: flutter-dependency-update
description: Use when updating Flutter/Dart packages, the Flutter SDK, Android tooling, Java, Gradle, or generated build inputs for this app.
---

# Flutter Dependency Updates

Treat updates as compatibility changes, not version edits. Record old/new versions, constraints, release notes, generated output, and validation results.

## Workflow

1. Inspect `pubspec.yaml`, `pubspec.lock`, `android/settings.gradle`, Gradle wrapper, and relevant GitHub Actions workflow.
2. Check package changelogs, migration notes, Android API requirements, and tool compatibility.
3. Update one coherent dependency/toolchain set at a time; resolve with `flutter pub get` and review lockfile changes.
4. Regenerate only affected outputs, then analyze, test, build, and inspect the diff.

## Dart and Flutter

No Flutter SDK pin exists. `pubspec.yaml` declares Dart `>=3.1.0 <4.0.0`; the current lockfile requires Dart `>=3.8.0` and Flutter `>=3.31.0-0.0.pre`. CI's Flutter action is not version-pinned. Check these sources before proposing SDK requirements; update constraints only when the code or dependency requires it.

```sh
flutter --version
dart --version
flutter pub outdated
flutter pub get
dart run build_runner build -d
flutter analyze
flutter test
```

Run `build_runner` when Drift or other generated inputs change. ARB changes use `flutter gen-l10n`.

## Android tooling

Current configuration: Java/JVM 17 (`android/app/build.gradle`), AGP 8.10.1 and Kotlin 1.8.22 (`android/settings.gradle`), Gradle 8.14.2 (`android/gradle/wrapper/gradle-wrapper.properties`). Gradle scripts use Groovy DSL. Check official compatibility notes before changing this set; CI deploy workflow uses JDK 17.

```sh
java -version
flutter build apk --debug
```

## Validation and report

- Run `flutter analyze`, `dart format .`, affected `flutter test` targets, and the relevant Android build.
- Run `flutter pub get` after dependency edits and review `pubspec.lock`.
- Record commands, outcomes, untested device behavior, and old/new versions. Do not claim a general CI test gate; workflows currently cover Play Store deployment and Crowdin.
- Never hide incompatibility with `dependency_overrides` or hand-edit generated output.
