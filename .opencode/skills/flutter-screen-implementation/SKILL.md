---
name: flutter-screen-implementation
description: Build or modify Mindful screens with Riverpod, Material 3 theming, named-route integration, localized strings, and accessible responsive Flutter UI.
---

# Flutter Screen Implementation

Follow nearby screen patterns; there is no separate root/screen, Cubit, or screen-state convention. Screens are under `lib/ui/`, and provider-consuming widgets use Riverpod.

## State And Actions

Use `ConsumerWidget` for provider-backed screens without widget-local lifecycle state, or `ConsumerStatefulWidget` when Flutter lifecycle/state is needed. Watch only values needed for rendering and use notifier methods for actions:

```dart
class ShortsBlockingScreen extends ConsumerWidget {
  const ShortsBlockingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allowedTime = ref.watch(
      wellBeingProvider.select((value) => value.allowedShortsTimeSec),
    );
    final hasPermission = ref.watch(
      permissionProvider.select((value) => value.haveAccessibilityPermission),
    );

    return Scaffold(
      body: Text('$allowedTime, $hasPermission'),
    );
  }
}
```

This shortened example follows `lib/ui/screens/shorts_blocking/shorts_blocking_screen.dart`; retain the app's real screen composition and widgets when changing that screen. Keep database access in providers/services, not widget build methods. Existing state owners call Drift DAOs, as in `lib/providers/focus/dated_focus_provider.dart`.

## Routes

For a new named screen, add a path and builder to `lib/config/navigation/app_routes.dart`. `MaterialApp` receives `AppRoutes.routes` in `lib/mindful_app.dart`. Use existing `context.resolveParam<T>()` parsing for route arguments. Do not add GoRouter or route constants to every screen; no such convention exists.

## Theme And Localization

- Use Material widgets and `Theme.of(context)`. `AppTheme` in `lib/config/app_themes.dart` configures Material 3, seeded colors, dynamic color, and dark mode.
- Add user-visible copy to ARB files in `lib/l10n/`; use `context.locale` (`lib/core/extensions/ext_build_context.dart`) or `AppLocalizations.of(context)`. Never hardcode user-facing strings when a localized key is appropriate.
- Respect Flutter constraints, system insets, scroll bounds, text scaling, and semantics. Prefer native Material controls and labels; add custom semantics only when native semantics are insufficient.

## Validation

Check an existing sibling widget before adding a reusable component. Run `flutter analyze` and `dart format .`. After ARB edits, run `flutter gen-l10n`. No screen-specific test convention exists yet; `flutter_test` is available.
