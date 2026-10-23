---
name: flutter-code-generation
description: Generate and validate Mindful's Drift database code and Flutter gen-l10n output; no Freezed, JSON, Injectable, or asset generation convention is used.
---

# Code Generation

Only run generators whose inputs changed. Generated files are outputs: edit their source declarations and regenerate, never hand-edit generated code.

## Drift

Drift tables live in `lib/core/database/tables/`; DAOs live in `lib/core/database/daos/`. The database registers both in `lib/core/database/app_database.dart`. Table and DAO source files declare `part` files, such as `lib/core/database/app_database.dart` and `lib/core/database/daos/unique_records_dao.dart`.

For table or DAO changes, follow the in-file migration steps in `app_database.dart`: update schema version, generate Drift code, dump schema, generate migration steps, and add the migration. The regular build-runner command is:

```sh
dart run build_runner build -d
```

Do not change persisted schema without handling existing installs. Generated Drift files include `*.g.dart`.

## Localization

ARB source files live in `lib/l10n/`; `l10n.yaml` specifies `app_en.arb` as template and `lib/l10n/generated/app_localizations.dart` as generated output. After ARB edits:

```sh
flutter gen-l10n
```

Do not hand-edit generated localization Dart. Crowdin is the project translation workflow; keep source keys in the English template.

## No Other Generator Convention

There is no Freezed, `json_serializable`, Injectable, typed asset, or Pigeon generation pattern in this app. Models are handwritten or Drift-generated. Do not add a generator or generated layer without a concrete requirement.

## Checks

After generation, run `flutter analyze` and `dart format .`. Standard project changes also require `flutter pub get`; see `docs/CONTRIBUTING.md`. No FVM or Melos workflow is configured.
