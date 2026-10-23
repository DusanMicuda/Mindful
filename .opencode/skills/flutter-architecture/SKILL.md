---
name: flutter-architecture
description: Use for architecture and dependency-flow changes in Mindful's single Flutter Android app, using Riverpod, Drift, named routes, and existing lib/ boundaries.
---

# Flutter Architecture

Mindful is one offline Flutter app. Follow current code in `lib/config/`, `lib/core/`, `lib/models/`, `lib/providers/`, and `lib/ui/`. There is no architecture document or feature-layer convention; do not introduce one without a concrete need.

## Existing Boundaries

- `lib/config/` holds app-wide configuration, themes, and navigation. Named routes live in `lib/config/navigation/app_routes.dart`; `MindfulApp` wires them into `MaterialApp` (`lib/mindful_app.dart`).
- `lib/providers/` owns app state with Riverpod providers and notifiers. UI reads state with `ref.watch` and invokes commands with `ref.read(provider.notifier)`.
- `lib/core/database/` defines Drift tables, DAOs, migrations, and the database. `DriftDbService.instance` initializes and exposes the app database (`lib/core/services/drift_db_service.dart`).
- `lib/models/` holds app-specific models. Drift row types are generated from table declarations; other models are handwritten unless a concrete existing generator pattern applies.
- `lib/ui/` contains screens and reusable widgets. Screens may consume Riverpod state; use the existing `ConsumerWidget`/`ConsumerStatefulWidget` patterns.
- `lib/core/services/method_channel_service.dart` is the existing Flutter-to-Android boundary. Keep platform-specific changes in `android/` and preserve offline behavior.

## State And Data Flow

Use Riverpod as the state-management system. Follow nearby provider patterns rather than imposing MVI, Cubit, repository, or use-case layers. Example: `lib/providers/system/mindful_settings_provider.dart` uses a `StateNotifierProvider`, loads and persists settings with a Drift DAO, and handles a platform update. `lib/providers/focus/dated_focus_provider.dart` watches related state and loads records from a DAO.

Add a new abstraction only when it removes real duplication or establishes a necessary test seam. No repository or dependency-injection convention exists. The database and method-channel services currently use singleton instances; do not expand that pattern by default.

Keep durable local data in Drift tables and access it through the database's DAOs (`lib/core/database/app_database.dart`, `lib/core/database/daos/unique_records_dao.dart`). Consider migration and existing-user data whenever changing a table. Do not add network APIs; the app is offline.

## UI, Navigation, And Localization

- Add screens under the existing `lib/ui/` organization. Check sibling screens before introducing a new folder shape.
- Register routes in `AppRoutes.routes` and route constants in `lib/config/navigation/app_routes.dart`. Use `context.resolveParam<T>()` for arguments where that matches existing routes.
- Use `AppLocalizations` ARB strings for user-facing text. `BuildContext` exposes `context.locale` through `lib/core/extensions/ext_build_context.dart`.
- Use `Theme.of(context)` and `AppTheme` (`lib/config/app_themes.dart`); theme is Material 3 with dynamic color support.

## Validation

Read `README.md` and `docs/CONTRIBUTING.md` for setup. After code changes, run `flutter pub get`, `flutter analyze`, and `dart format .`. If Drift table declarations changed, also run `dart run build_runner build -d`; if ARB files changed, run `flutter gen-l10n`. No ADR convention exists.
