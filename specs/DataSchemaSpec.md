# Data Schema Spec

## Overview

All reference content ships as versioned JSON in `Resources/Rules/`. Loaded at launch via `BundledRulesRepository`.

## Top-Level Envelope

```json
{
  "schemaVersion": 1,
  "gameSystems": [ GameSystem ]
}
```

## Types

### GameSystem

| Field | Type | Required |
|-------|------|----------|
| id | string | yes — e.g. `aos-spearhead` |
| name | string | yes |
| tagline | string | yes |
| edition | string | yes |
| availability | enum | `available` \| `comingSoon` |
| gettingStartedSteps | [GuideStep] | yes |
| ruleSections | [RuleSection] | yes |
| externalLinks | [ExternalLink] | no |

### GuideStep

| Field | Type |
|-------|------|
| id | string |
| order | int |
| title | string |
| summary | string |
| body | string (markdown-lite: paragraphs only in v1) |
| tips | [string] |

### RuleSection

| Field | Type |
|-------|------|
| id | string |
| title | string |
| category | `core` \| `spearhead` \| `glossary` |
| order | int |
| content | string |
| relatedSectionIds | [string] |

## Migration Policy

1. Bump `schemaVersion` on breaking changes.
2. Document in this file; add decoder migration in `Data/JSON/RulesDecoder.swift`.
3. CI test: decode bundled `rules-v1.json` fixture.

## Content Files

| File | Purpose |
|------|---------|
| `Resources/Rules/rules-v1.json` | Production bundle |
| `Tests/Unit/Fixtures/rules-v1-minimal.json` | Test fixture |

## Verification

| Field | Value |
|-------|-------|
| Target release | v0.1 |
| Last verified | 2026-06-17 |
| Commit | (initial scaffold) |
| Code paths | `Domain/Models/RulesContent.swift`, `Data/JSON/BundledRulesRepository.swift` |
