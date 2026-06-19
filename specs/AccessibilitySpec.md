# Accessibility Spec

## Target

WCAG 2.1 AA engineering baseline. Manual VoiceOver pass required before App Store.

## Requirements

| Criterion | Implementation |
|-----------|----------------|
| 1.4.3 Contrast | Semantic system colors; audit in Phase 11 |
| 1.4.4 Resize | Dynamic Type on all text |
| 2.5.5 Target size | 44×44pt minimum |
| 4.1.2 Name, Role | Labels + hints on controls |

## Orientations

- **iPhone:** Portrait + landscape (`project.yml`)
- **iPad:** Portrait + landscape

## Reduce Motion

Respect `@Environment(\.accessibilityReduceMotion)` for step transition animations.

## Screen Tracker

Per-screen audits: `accessibility/audits/` (empty until Phase 11).

## Verification

| Field | Value |
|-------|-------|
| Target release | v0.1 |
| Last verified | 2026-06-19 |
| Commit | (initial scaffold) |
| Code paths | Feature views, `DesignSystem/` |
