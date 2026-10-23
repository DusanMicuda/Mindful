---
name: flutter-dart-style
description: Use for Dart and Flutter code style, null safety, formatting, and lint guidance in the Mindful app.
---

# Dart Style

Mindful is one Flutter app. Dart lives in `lib/`; follow nearby code in
`config/`, `core/`, `models/`, `providers/`, and `ui/` rather than assuming
patterns from another project.

## Conventions

- Use Dart naming conventions and keep file names `lowercase_with_underscores`.
- Use non-nullable types when absence is not meaningful. The app does use `!`;
  prefer null-aware access, `??`, or a guard when those express the behavior
  clearly, and use assertions only when the invariant is established.
- Use `final` for values not reassigned and `const` where compile-time values
  permit it.
- Follow existing imports and formatting. `analysis_options.yaml` includes
  `flutter_lints`; do not impose extra lint rules.
- Riverpod state lives in providers under `lib/providers/`. Widgets that watch
  state use `ConsumerWidget`/`ConsumerStatefulWidget`, `ref.watch` for rendering,
  and `ref.read` for actions. See `lib/mindful_app.dart` and
  `lib/ui/screens/app_dashboard/app_dashboard_screen.dart`.
- Access localized strings with `context.locale`, defined in
  `lib/core/extensions/ext_build_context.dart`.
- Use `Theme.of(context)` and its Material 3 `colorScheme` for UI colors;
  theme construction is in `lib/config/app_themes.dart`.
- Keep Drift schema edits in hand-written database files, not generated `.g.dart`
  files. After schema changes, follow `lib/core/database/app_database.dart` and
  regenerate Drift output.
- Log through `CrashLogService` where appropriate; use `debugPrint` for debug
  diagnostics. Do not introduce a logging dependency.

## Validation

Run `dart format .` and `flutter analyze`. For setup and contribution workflow,
see `README.md` and `docs/CONTRIBUTING.md`.
