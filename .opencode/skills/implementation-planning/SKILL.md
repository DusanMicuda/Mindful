---
name: implementation-planning
description: Plan implementation work for Mindful's single offline Flutter app using verified Riverpod, Drift, named-route, localization, and Android patterns.
---

# Implementation Planning

Use for requests to plan a feature or substantial change. Plans must be grounded in the current repository, not copied architecture templates.

## Before Planning

- Read `README.md` and `docs/CONTRIBUTING.md` for project workflow.
- Trace existing implementation from route/screen through provider and any Drift DAO or Android method channel it uses.
- Inspect relevant table, model, provider, and screen files before specifying a pattern.
- Check `lib/config/navigation/app_routes.dart`, `lib/core/database/app_database.dart`, and `lib/mindful_app.dart` when routes, persistence, or app wiring change.
- No ADR or fixed feature-folder convention exists. State that when it matters; do not invent architectural decisions as project rules.
- Ask the user only for product or behavior decisions that cannot be resolved from their request or current code.

## Plan Contents

Keep the plan proportional to the change. Include:

1. Goal and observable acceptance criteria.
2. Scope and explicit exclusions.
3. Exact files to add or modify, with nearby real files to copy as patterns.
4. State and data flow: identify Riverpod provider ownership, Drift tables/DAOs or existing services, and UI consumers. Add no repository/use-case layer unless current requirements justify it.
5. Route and localization changes when applicable: `AppRoutes` in `lib/config/navigation/app_routes.dart`, ARB source in `lib/l10n/`, and generated localization output via `flutter gen-l10n`.
6. Drift migration and generation steps when schema changes. Table or DAO edits require `dart run build_runner build -d` and the migration sequence documented in `lib/core/database/app_database.dart`.
7. Focused tests where useful. `flutter_test` is installed, but there are currently no tests or established test conventions; avoid prescribing absent factories, fakes, or test packages.
8. Verification: `flutter pub get`, conditional generation, `flutter analyze`, and `dart format .`.

## Constraints

- App is offline; do not plan network APIs.
- Flutter UI and native platform are Android-only in this checkout; platform implementation belongs in `android/`, with Dart calls following `lib/core/services/method_channel_service.dart`.
- State uses Riverpod. Navigation uses `MaterialApp` named routes. Persistence uses Drift. Localization uses gen-l10n ARB files.
- No FVM, Melos, Cubit, GetIt, Freezed, GoRouter, Pigeon, or custom test framework convention exists.

Name actual files and commands. Do not impose a cycle template or agent role absent from the requested workflow; keep simple changes as a short file list.
