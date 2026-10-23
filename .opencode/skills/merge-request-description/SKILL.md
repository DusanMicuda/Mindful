---
name: merge-request-description
description: Use when preparing a GitHub pull request description from branch history, diff evidence, and validation results.
---

# GitHub Pull Request Description

Write from evidence, not memory. Keep scope concise; separate confirmed changes from assumptions.

## Evidence

1. Identify base branch and comparison range.
2. Read non-merge commits for intent; this repo uses conventional/gitmoji-style commits (for example, `✨ feat(l10n): ...`).
3. Inspect changed paths, diff statistics, and complete diffs, including tests, generated output, dependencies, and configuration.
4. Record validation commands/results and checks not run.
5. Check for unrelated files, secrets, credentials, and destructive artifacts.
6. Run `git diff --check`.

## Sections

Include only useful sections:

- **Changes:** behavior changes, fixes, refactors, or configuration.
- **Adds / Removes:** new or deleted behavior, files, tests, or dependencies.
- **Updates:** SDK, toolchain, package, or generated version changes with old and new values.
- **Validation:** exact commands and outcomes.
- **Not covered:** relevant checks or scenarios not exercised.
- **For Reviewer:** concise reading order derived from the actual diff; omit if no guidance is useful.

Do not present empty headings, formatting-only edits, merge commits, or generated files as standalone changes. Never infer validation from workflow names; `.github/workflows/` currently contains Play Store deployment and Crowdin workflows.

## Template

```markdown
## Changes
- <confirmed behavior or fix>

## Adds
- <new behavior or test>

## Updates
- <component>: <old> -> <new>

## Validation
- `<command>` - <result>

## Not covered
- <untested relevant criterion>

## For Reviewer
1. <path or change> - <what to verify and why>
```
