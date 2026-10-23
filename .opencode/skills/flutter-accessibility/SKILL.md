---
name: flutter-accessibility
description: Use when building or reviewing Mindful Flutter UI for semantics, focus, text scaling, contrast, motion, and responsive layouts.
---

# Flutter Accessibility

Use Flutter's built-in semantics and Material controls. Mindful uses
Material 3, generated localization, and `context.locale` from
`lib/core/extensions/ext_build_context.dart`.

- Give actionable controls a clear localized label. Prefer Material control
  labels and tooltips; add `Semantics` only when the widget tree does not expose
  the intended meaning or state.
- Use `context.locale` for user-visible accessibility labels and hints.
- Keep focus order logical. Own and dispose `FocusNode` and
  `TextEditingController` in the associated `State` when creating them.
- Avoid fixed heights and forced single-line text where localization or text
  scaling can cause clipping. Prefer wrapping, flexible constraints, and
  scrolling.
- Do not communicate status by color alone. Use `Theme.of(context).colorScheme`
  so UI follows light and dark themes.
- Provide a non-gesture-only way to perform important actions. Respect reduced
  motion when adding animations.

For tests, use Flutter's `testWidgets` and `tester.ensureSemantics()` to inspect
important labels or states. Verify focus, large text, narrow layouts, and
TalkBack behavior on representative Android screens when relevant.
