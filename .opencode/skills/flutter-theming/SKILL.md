---
name: flutter-theming
description: Use when styling Mindful Flutter UI, working with Material 3 themes, dynamic colors, or theme settings.
---

# Flutter Theming

Theme creation is centralized in `lib/config/app_themes.dart` as
`AppTheme.lightTheme` and `AppTheme.darkTheme`. The app applies them in
`lib/mindful_app.dart`, using Android dynamic colors and settings from
`mindfulSettingsProvider`.

## UI styling

- Use `Theme.of(context).colorScheme`, `textTheme`, and component themes for
  screen styling. This app uses Material 3 and `ColorScheme.fromSeed`.
- Keep light/dark and AMOLED behavior in `AppTheme`; do not create unrelated
  per-screen `ThemeData` instances.
- Dynamic accent selection and AMOLED settings are already wired through
  `mindfulSettingsProvider`. Reuse that flow instead of adding another theme
  state mechanism.
- Use `Colors.*` when semantically appropriate or for fixed drawing/decoration.
- Resolve context-dependent theme values inside `build()` so updates take
  effect. Prefer theme text styles and avoid fixed-height text layouts.
- App-specific theme extensions, such as `SkeletonizerConfigData`, are defined
  in `lib/config/app_themes.dart`.

Example from the app composition:

```dart
final color = Theme.of(context).colorScheme.primary;
```

When changing theme behavior, verify light, dark, AMOLED, dynamic-color fallback,
and accessibility text scaling where relevant. Run `flutter analyze`.
