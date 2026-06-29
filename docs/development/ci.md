# CI pipeline

**Last updated:** 2026-06-29 · Workflow: [`.github/workflows/ci.yml`](../../.github/workflows/ci.yml)

---

## Jobs

### Guardrails (ubuntu-latest, no Xcode)

Fast gates on every push/PR:

| Step | Script | Purpose |
|------|--------|---------|
| Content lint | `python3 Scripts/validate_content.py` | Validates bundled rules/army JSON (jsonschema) |
| Firebase secret scan | shell | Fails if real `GoogleService-Info.plist` is tracked |
| Architecture ratchet | `Scripts/check_architecture_debt.sh` | Prevents re-introduced layer violations |

### Build & test (macos-15)

| Step | Action |
|------|--------|
| Install XcodeGen | `brew install xcodegen` |
| Firebase stub | `cp Resources/GoogleService-Info.plist.example Resources/GoogleService-Info.plist` |
| Generate project | `xcodegen generate` |
| Test | `xcodebuild test -scheme TabletomeCI -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' CODE_SIGNING_ALLOWED=NO` |

Analytics and Crashlytics stay **off** in CI (placeholder plist + Debug-equivalent flags).

---

## Local parity

Reproduce CI locally:

```bash
cp Resources/GoogleService-Info.plist.example Resources/GoogleService-Info.plist
xcodegen generate
python3 Scripts/validate_content.py
Scripts/check_architecture_debt.sh
xcodebuild test -scheme TabletomeCI \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  CODE_SIGNING_ALLOWED=NO
```

---

## Pre-commit hook

`Scripts/pre-commit` scans staged files for secret patterns (Firebase plist, etc.). Install via your git hooks path if desired.

---

## What CI does not run (yet)

- UI test matrix (nightly)
- TestFlight archive (manual / future Xcode Cloud)
- Documentation drift report (see Dart Buddy `documentation-summary.sh` as a future addition)

---

## Fixing common CI failures

| Failure | Fix |
|---------|-----|
| JSON schema validation | Fix content under `Resources/`; see `DataSchemaSpec.md` |
| Architecture debt | Remove forbidden imports / patterns flagged by script |
| Tracked Firebase plist | `git rm --cached Resources/GoogleService-Info.plist` |
| xcodebuild simulator | CI uses `iPhone 16`; match locally or update workflow |
