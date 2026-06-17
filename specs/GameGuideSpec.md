# Game Guide Spec — Getting Started Walkthrough

## User Story

As a new Spearhead player, I pick Age of Sigmar Spearhead and follow a step-by-step guide aligned with GW's official getting-started flow so I can set up my first game offline.

## Flow

```
Home (game systems)
  → Spearhead detail
  → Getting Started (ordered steps 1–5)
  → Step detail (title, body, tips)
  → Optional: link to related rule section
```

## Steps (content from GW Spearhead: Fire & Jade)

1. Pick a Spearhead army
2. Choose a realm battlefield
3. Pick regiment ability and enhancement
4. Prepare your warscrolls
5. Fight the battle

## Behavior

- Steps sorted by `order` field in JSON
- Progress: optional checkmarks stored in UserDefaults (`guide_progress_{gameSystemId}_{stepId}`)
- Back navigation preserves scroll position per step
- Empty/error: show `EmptyStateView` with retry if JSON load fails

## Accessibility

- Step list: `accessibilityIdentifier` `guide.stepList`
- Each step row: label = title, hint = summary
- Step detail: heading announced on appear

## Verification

| Field | Value |
|-------|-------|
| Target release | v0.1 |
| Last verified | 2026-06-17 |
| Commit | (initial scaffold) |
| Code paths | `Features/GameGuide/`, `Features/Home/` |
