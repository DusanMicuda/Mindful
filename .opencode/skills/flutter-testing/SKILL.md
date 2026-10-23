---
name: flutter-testing
description: Use when writing or running Flutter unit, Riverpod, Drift, or widget tests for the Mindful app.
---

# Flutter Testing

There are currently no tests. The first test establishes the root `test/`
layout; keep it simple and colocate tests by feature or source file as the suite
grows. Dependencies include `flutter_test`; no test framework or shared test
helpers are configured.

## Choose a test

- Test pure model or utility behavior with a focused Dart test.
- Test providers with `ProviderContainer`, supplying provider overrides for
  dependencies that the test should control. Dispose the container after each
  test. For widget tests, use `ProviderScope(overrides: [...])` around the
  widget under test.
- Test UI with `testWidgets`, `WidgetTester`, and the smallest meaningful widget
  tree. Assert visible behavior and interactions rather than private details.
- Test Drift against an in-memory executor when database behavior is needed:

```dart
final database = AppDatabase(NativeDatabase.memory());
addTearDown(database.close);
```

Import `package:drift/native.dart` and the app database. Keep each test's
database isolated; no production singleton or on-device database should be
used.

Use `ProviderContainer(overrides: [...])` for provider tests, choosing
`overrideWith` or `overrideWithValue` according to the provider's type. Register
`container.dispose` with `addTearDown`. Do not add factories, fakes, or shared
helpers until repeated setup makes them useful.

Run tests with `flutter test`, then run `flutter analyze`. Follow setup guidance
in `README.md` and `docs/CONTRIBUTING.md`.
