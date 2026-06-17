# Design System Spec

## Tokens

Defined in `DesignSystem/DesignTokens.swift`:

- **Spacing:** xs=4, sm=8, md=16, lg=24, xl=32
- **Corner radius:** sm=8, md=12, lg=16
- **Min touch target:** 44pt

## Colors

Semantic names backed by asset catalog + system colors:

| Token | Light | Dark |
|-------|-------|------|
| background | systemBackground | systemBackground |
| surface | secondarySystemBackground | secondarySystemBackground |
| primaryText | label | label |
| secondaryText | secondaryLabel | secondaryLabel |
| accent | AccentColor asset | AccentColor asset |
| destructive | systemRed | systemRed |

Brand palette (Warhammer-adjacent, original): deep bronze accent — not GW trademark colors.

## Typography

SwiftUI semantic styles only: `.largeTitle`, `.title2`, `.headline`, `.body`, `.callout`, `.caption`.

Use `@ScaledMetric` for icon sizes tied to text scale.

## Components

| Component | File |
|-----------|------|
| GuideStepCard | `DesignSystem/GuideStepCard.swift` |
| RuleSectionRow | `DesignSystem/RuleSectionRow.swift` |
| PrimaryButton | `DesignSystem/PrimaryButton.swift` |
| EmptyStateView | `DesignSystem/EmptyStateView.swift` |

All ship with accessibility labels and identifiers.

## Verification

| Field | Value |
|-------|-------|
| Target release | v0.1 |
| Last verified | 2026-06-17 |
| Commit | (initial scaffold) |
| Code paths | `DesignSystem/` |
