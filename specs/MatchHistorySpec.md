# Match History & Match Log Spec

## User Story

As a player who just finished a guided match, I see a **victory screen** that makes the winner obvious, tap **Done**, and the game is saved to **Match History** on this device so I can rematch or review the result later.

## Locked decisions

| Decision | Choice |
|----------|--------|
| History scope | **Single global history** — one list across all game systems; filter by `gameSystemId` |
| Victory presentation | **Full-screen victory screen** — unmistakable winner (or tie) |
| Sync / cloud | **Local only** — history stays on device; `MatchSyncSnapshot` unchanged |

## Concepts

| Term | Meaning |
|------|---------|
| **Active match** | In-progress game in `MatchSetupStore` + `BattleTrackerStore` |
| **Match record** | Immutable summary of a finished or abandoned game |
| **Match log** | Append-only event timeline (v1+) |

## Lifecycle

```
Active match → Victory screen (completed) or abandon/reset prompt
            → Archive MatchRecord + MatchLog
            → Clear active stores
            → Optional rematch (same armies)
```

| Action | Behavior |
|--------|----------|
| Battle complete → **See Results** | Full-screen victory screen |
| Victory **Done** | Archive as `completed`, clear stores |
| Victory **Rematch** | Archive, reset tracker, keep armies |
| **Reset Match** | Confirm; **Save to history** (default on) archives as `abandoned` without victory screen |
| **Adjust score** | Sheet on victory screen; winner updates from VP |

Winner auto-detected from VP; ties use **Draw** layout.

## Data model

- `MatchRecord` — id, `gameSystemId`, `gameSystemName`, dates, status, denormalized players/setup/result
- `MatchLogEvent` + `MatchLogEventPayload` — append-only timeline rows
- Active buffer: `Application Support/MatchHistory/active_{gameSystemId}.json`
- Storage: `Application Support/MatchHistory/index.json` + `{matchId}/log.json`

## Match log (v1)

`MatchLogRecorder` captures phase/VP/damage/setup events during play. Match detail shows `MatchLogTimelineView` grouped by round.

| Source | Events |
|--------|--------|
| Session / archive | `matchStarted`, `matchEnded` |
| Setup | `setupStepCompleted`, `deploymentStepCompleted` |
| Tracker | `phaseChanged`, `roundAdvanced`, `activePlayerChanged`, `victoryPointsChanged`, `abilityUsed`, `damageApplied`, `unitDestroyed` |
| Batch combat resolver | `combatBatchResolved` (v2) |

## UI

### Victory screen (`matchVictory.screen`)

Full-screen cover: game system pill, duration, **VICTORY** or **Draw**, two-column scoreboard (winner crown + accent ring), **Adjust score**, **Rematch**, **Done**.

### Match History (`matchHistory.screen`)

Global list under Play toolbar; filter `matchHistory.filter.{gameSystemId}`; row shows matchup, VP, winner, date; tap → detail with victory header + **match log timeline** + **Share** (plain-text export, v2).

## Non-goals (v1)

- User notes
- CloudKit / cross-device history

## Phased delivery

| Phase | Scope |
|-------|--------|
| **v0** (shipped) | Victory screen, global history, archive |
| **v1** (shipped) | `MatchLogRecorder` + timeline |
| **v2** (shipped) | `combatBatchResolved` on batch Apply Damage; `MatchHistoryExportFormatter` + Share on detail |

## Verification

| Field | Value |
|-------|-------|
| Target release | v0.5 (log + export) |
| Last verified | 2026-06-17 |
| Code paths | `Domain/UseCases/MatchLogRecorder.swift`, `Domain/UseCases/MatchHistoryExportFormatter.swift`, `Domain/Models/CombatBatchLogContext.swift`, `Features/MatchHistory/MatchHistoryDetailView.swift`, `Features/CombatRoll/BatchCombatResolverSection.swift`, `Features/GuidedMatch/BattlePhaseTrackerViewModel+MatchLog.swift` |
| Tests | `Tests/Unit/MatchLogRecorderTests.swift`, `Tests/Unit/MatchLogSummaryFormatterTests.swift`, `Tests/Unit/MatchHistoryExportFormatterTests.swift` |
