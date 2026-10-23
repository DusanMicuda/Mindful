# Project

Single Flutter app, `mindful`, for Android. Dart code lives in `lib/`;
Android native code uses Kotlin and Groovy Gradle. State uses Riverpod,
persistence uses Drift, navigation uses named `MaterialApp` routes, and
localization uses Flutter gen-l10n with ARB files.

## Non-negotiables

- Keep the app offline; there are no network APIs.
- `README.md` and `docs/CONTRIBUTING.md` are authoritative for project setup
  and contribution workflow.
- Follow existing patterns in `lib/config/`, `core/`, `models/`,
  `providers/`, and `ui/`; keep Android platform changes in `android/`.
- Load the relevant skill before specialized Flutter, Dart, Android,
  localization, code-generation, accessibility, or testing work.

## After every change

```sh
flutter pub get
dart run build_runner build -d  # if Drift tables changed
flutter gen-l10n                # if ARB files changed; pubspec generate: true also runs it during Flutter builds
flutter analyze
dart format .
```

Run conditional generation only when its inputs changed.

## Before opening a pull request

- Confirm analysis and formatting pass.
- Check behavior, error handling, and tests for the changed paths.
- Remove stale comments, unused code, and unrelated changes.
- Review the diff for regressions, privacy impact, and Android-only
  assumptions.

## Skills

Load the matching skill with the `skill` tool for detailed Flutter, Dart,
Android, localization, code-generation, accessibility, testing, theming, and
tooling guidance.
