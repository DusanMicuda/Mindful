---
name: flutter-feature-creation
description: Create features in Mindful's single offline Flutter app using existing Riverpod providers, Drift persistence, named routes, and localized UI patterns.
---

# Feature Creation

There is no fixed feature-folder template, repository layer, or MVI convention. Trace related files and copy the nearest working pattern instead of scaffolding layers.

## Find Existing Patterns

- Provider state and persistence: `lib/providers/system/mindful_settings_provider.dart` (`StateNotifierProvider`, Drift DAO, local settings).
- Date-scoped database state: `lib/providers/focus/dated_focus_provider.dart` (family provider, notifier, DAO query).
- UI state consumption and commands: `lib/ui/screens/shorts_blocking/shorts_blocking_screen.dart` (`ConsumerWidget`, `ref.watch`, `ref.read`).
- Navigation: `lib/config/navigation/app_routes.dart` and `lib/mindful_app.dart`.
- Model and persistence schema: `lib/core/database/tables/focus_sessions_table.dart` and `lib/core/database/app_database.dart`.

## Implementation

1. Extend the nearest provider or add the smallest provider type that owns the new state. Existing code uses `StateNotifierProvider`, provider families, derived providers, and `FutureProvider`; there is no single mandated provider shape.
2. Read and write durable data through Drift tables and DAOs. Register new tables/DAOs in `lib/core/database/app_database.dart`; follow the migration sequence documented there when schema changes.
3. Keep screen composition in `lib/ui/`. Use `ConsumerWidget` or `ConsumerStatefulWidget` when the widget consumes providers. Read state with `ref.watch`; invoke actions with `ref.read(provider.notifier)`.
4. Add the screen to `AppRoutes` when it needs a named route. Follow existing route argument parsing.
5. Add user-facing text to `lib/l10n/app_en.arb`; generated `AppLocalizations` output is not hand-edited. Run `flutter gen-l10n` after ARB changes.
6. Keep Android platform behavior in `android/` and use the existing `MethodChannelService` where applicable. Do not add network access; Mindful works offline.

No test suite convention exists yet. `flutter_test` is installed, but the repository currently has no tests. Add a focused test for non-trivial new logic when practical; do not invent a test architecture or fake framework.

## Generation And Checks

- Drift table changes: `dart run build_runner build -d`.
- ARB changes: `flutter gen-l10n`.
- Standard checks: `flutter pub get`, `flutter analyze`, `dart format .`.

Consult `README.md` and `docs/CONTRIBUTING.md` for setup and contribution workflow.
