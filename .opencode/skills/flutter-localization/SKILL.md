---
name: flutter-localization
description: Use when adding or changing localized Flutter text, ARB messages, locale selection, or translation validation in Mindful.
---

# Flutter Localization

Mindful uses Flutter gen-l10n. Source translations are ARB files in
`lib/l10n/`; generated `AppLocalizations` files are in
`lib/l10n/generated/`. Configuration is in `l10n.yaml`.

## Use translations

`BuildContext.locale` is the app's convenience accessor for
`AppLocalizations.of(context)`. Its extension is in
`lib/core/extensions/ext_build_context.dart`.

```dart
Text(context.locale.settings_title)
```

Use generated localization getters, including parameterized getters defined by
ARB messages.

## Add or change a message

- Add the source message and metadata to `lib/l10n/app_en.arb`.
- Update translations in other `app_*.arb` files as appropriate for Crowdin.
- Use generated `context.locale` getters in UI; don't edit generated Dart.
- Keep domain data, database values, route names, and diagnostic logs
  independent of the current locale.
- For dates and numbers, use existing helpers in `lib/core/extensions/` or
  locale-aware `intl` formatting. See `lib/core/extensions/ext_date_time.dart`.

Locale selection is backed by `mindfulSettingsProvider` and applied to
`MaterialApp` in `lib/mindful_app.dart`. Keep supported locales sourced from
`AppLocalizations.supportedLocales`.

After editing ARB files, run:

```sh
flutter gen-l10n
flutter analyze
```

`pubspec.yaml` has `flutter.generate: true`, so Flutter builds also generate
localizations. Keep Android XML translations in sync when a change affects
strings consumed by native Android code; Crowdin configuration is in
`crowdin.yml`.
