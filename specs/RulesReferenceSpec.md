# Rules Reference Spec

## User Story

As a player at the table, I browse offline rule sections for Spearhead and core combat without network access.

## IA

- Filter by category: All | Core | Spearhead | Glossary
- Search: case-insensitive title + content match (client-side)
- Detail: scrollable section with related links

## v0.1 Content Scope

| Section ID | Category |
|------------|----------|
| combat-sequence | core |
| attack-modifiers | core |
| damage-sequence | core |
| spearhead-overview | spearhead |
| spearhead-scoring | spearhead |
| spearhead-battle-round | spearhead |
| glossary-contest | glossary |

## Future

- Deep link to section by ID
- Roll evaluator prefill from combat-sequence

## Verification

| Field | Value |
|-------|-------|
| Target release | v0.1 |
| Last verified | 2026-06-17 |
| Commit | (rules reference complete) |
| Code paths | `Features/RulesReference/`, `Tests/Unit/RulesReferenceViewModelTests.swift` |
