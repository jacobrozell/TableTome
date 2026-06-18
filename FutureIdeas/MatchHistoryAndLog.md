# Match History & Match Log

Non-authoritative backlog. Promote to `specs/` when behavior locks.

**Status:** Draft spec (2026-06-17) — decisions locked below

---

## Locked decisions

| Decision | Choice |
|----------|--------|
| History scope | **Single global history** — one list across all game systems; filter by `gameSystemId` |
| Victory presentation | **Full-screen victory screen** — unmistakable winner (or tie); not a small inline card |
| Sync / cloud | **Local only** — history and logs stay on device; `MatchSyncSnapshot` unchanged (live play only) |
| iCloud / export | Defer to v2+; system backup is sufficient for v1 |

---

## Problem

Tabletome persists exactly **one live match per `gameSystemId`** in UserDefaults (`GuidedMatchState` + `BattleTrackerState`). **Reset Match** wipes everything with no trace.

After a long game (see playtest in `specs/BattleTableFlowSpec.md`), players want to:

- Remember **who played what**, final score, and when
- Revisit **what happened** (VP swings, key damage, abilities spent) for disputes or learning
- Start a **new match** without losing the last one

Nearby sync (`MatchSyncSnapshot`) shares live state between phones but does not archive completed games.

---

## Concepts

| Term | Meaning | Analogy |
|------|---------|---------|
| **Active match** | The in-progress game loaded from `MatchSetupStore` + `BattleTrackerStore` | Current document |
| **Match record** | Immutable summary of a finished or abandoned game | Row in history list |
| **Match log** | Append-only chronological events for one match | Activity feed / game transcript |

**Match history** is the list of match records. **Match log** is the drill-down timeline inside one record.

---

## Goals

1. **Survive reset** — ending or resetting a match can preserve a durable record.
2. **Table-useful summaries** — final VP, armies, battlefield, winner, duration at a glance.
3. **Explainable timeline** — enough events to answer "when did we score that?" without re-reading every dice roll.
4. **Game-system aware** — Spearhead rounds/VP, SC TMG activations, 40k CP missions use the same envelope with mode-specific event payloads.
5. **Local-first** — no account, cloud, or cross-device history in v1.

## Non-goals (v1)

- Full combat dice transcript (every hit/wound/save die)
- Licensed card text storage (twist names user-entered only — same as `BoardStateTracking.md`)
- Cross-device history merge or CloudKit sync
- Global leaderboard / sharing to social
- Replacing physical battle notes

---

## User stories

### End & remember

> As a player who just finished round 4, I see a **victory screen** that makes the winner obvious, tap **Done**, and the game appears in **Match History** so I can start a rematch without losing the result.

### Settle a dispute

> As a player arguing about VP, I open last week's match, scroll the log to **Victory points +2 (objective)** entries, and see which round they were recorded in.

### Learn from a loss

> As a new player, I review a completed match log to see when I forgot battle tactics scoring at end of turn.

### Abandon gracefully

> As a player who had to pack up early, I **Abandon Match** and still keep partial history (status = abandoned, last round recorded).

---

## Lifecycle

```
[New match] ──► Active match (existing stores)
                    │
        ┌───────────┼───────────┐
        ▼           ▼           ▼
  Battle ends   Abandon     Reset Match
  (last round)  Match       (with prompt)
        │           │           │
        ▼           │           │
  Victory Screen    │           │
  (celebration)     │           │
        │           │           │
        └───────────┴───────────┘
                    ▼
            Archive → MatchRecord + MatchLog
                    ▼
            Clear active stores (same as today)
                    ▼
            Optional: Rematch (pre-fill armies)
```

### Triggers

| Action | Default behavior |
|--------|------------------|
| **Victory screen** (new) | Presented when battle-complete guide is acknowledged or final round ends. Archives as `completed` on **Done**. |
| **Abandon Match** (new) | Muted end sheet (no celebration). Archives as `abandoned` with `endedAt` and last known round/VP. |
| **Reset Match** (existing) | Confirmation sheet: **Save to history** (default on) vs **Discard**. If saved mid-game, skip victory screen — archive as `abandoned`. |
| App background / crash | No auto-archive; active match remains resumable. |

### Winner resolution

- **Auto-detect** from final VP when victory screen appears (`playerOneVictoryPoints` vs `playerTwoVictoryPoints`).
- **Tie** — dedicated tie layout (see Victory screen); `winner: .tie`.
- **Adjust score** — secondary action on victory screen opens VP editor; winner updates live.
- User can override winner only via VP edit (no separate winner picker unless VP tied and user picks concession).
- SC TMG / modes without VP: show **Match Complete** headline; winner optional; duration + rounds still shown.

---

## Data model (Domain)

All types in `Domain/Models/`, `Codable` + `Sendable`, no SwiftUI.

### `MatchRecord` (summary — what history list shows)

```swift
public struct MatchRecord: Codable, Sendable, Identifiable, Equatable {
    public let id: UUID
    public let gameSystemId: String
    public let createdAt: Date
    public let endedAt: Date
    public let status: MatchArchiveStatus // completed | abandoned
    public let players: MatchPlayerSummary // names, factionIds, armyIds, labels denormalized at archive time
    public let setup: MatchSetupSummary // attacker, first turn, missionId, battlefield/realm id if known
    public let result: MatchResultSummary // final VP, suggested/confirmed winner, totalRoundsPlayed
    public let schemaVersion: Int // log event decoding
}

public enum MatchArchiveStatus: String, Codable, Sendable {
    case completed
    case abandoned
}

public enum MatchWinner: String, Codable, Sendable {
    case playerOne
    case playerTwo
    case tie
    case undecided
}
```

Denormalize display strings at archive time (`"Skaven — Gnawfeast Clawpack"`) so history survives catalog edits.

### `MatchLogEvent` (timeline row)

```swift
public struct MatchLogEvent: Codable, Sendable, Identifiable, Equatable {
    public let id: UUID
    public let matchId: UUID
    public let timestamp: Date
    public let kind: MatchLogEventKind
    public let payload: MatchLogEventPayload // enum with associated values
}

public enum MatchLogEventKind: String, Codable, Sendable {
    case matchStarted
    case setupStepCompleted
    case deploymentStepCompleted
    case phaseChanged
    case roundAdvanced
    case activePlayerChanged
    case victoryPointsChanged
    case abilityUsed
    case damageApplied
    case combatBatchResolved // summary only, not per-die
    case unitDestroyed
    case userNote
    case matchEnded
    case scActivation // SC TMG: unit activation start/end
    case scSupplyChanged
}
```

### Payload examples (Spearhead)

| Event | Payload fields |
|-------|----------------|
| `phaseChanged` | `round`, `phaseId`, `playerIsOne` |
| `victoryPointsChanged` | `playerIsOne`, `delta`, `newTotal`, `reason` (objective \| tactic \| manual \| other) |
| `damageApplied` | `unitId`, `unitName`, `playerIsOne`, `woundsRemoved`, `remaining`, `source` (combat \| manual) |
| `combatBatchResolved` | `attackerUnit`, `defenderUnit`, `weaponName`, `hits`, `wounds`, `failedSaves`, `damageDealt` |
| `abilityUsed` | `abilityId`, `abilityName`, `unitName`, `timing` |

Mode-specific kinds stay in the enum; decode unknown kinds gracefully for forward compatibility.

### Active match logging buffer

While a match is live, append events to an in-memory + lightweight persisted buffer keyed by `gameSystemId`:

```swift
public struct ActiveMatchLog: Codable, Sendable {
    public var matchId: UUID // stable for this active session
    public var startedAt: Date
    public var events: [MatchLogEvent]
}
```

On archive, copy `events` into the record's log file and clear the buffer.

---

## Storage

Follow **user data plane** from `FutureIdeas/UnifiedAppPlan.md` (not bundled JSON).

### v1 — JSON in Application Support

| Artifact | Path pattern |
|----------|----------------|
| History index | `Application Support/MatchHistory/index.json` — `[MatchRecord]` sorted `endedAt` desc |
| Per-match log | `Application Support/MatchHistory/{matchId}/log.json` |
| Active log buffer | `Application Support/MatchHistory/active_{gameSystemId}.json` |

**Why not UserDefaults:** history grows unbounded; UserDefaults is wrong for large blobs.

**Why not SwiftData yet:** Play layer still on iOS 17 + UserDefaults; defer SwiftData until hobby port raises min OS to 18.

### Repository (Data layer)

```swift
public protocol MatchHistoryRepository: Sendable {
    func fetchRecords(limit: Int?, gameSystemId: String?) async throws -> [MatchRecord]
    func fetchRecord(id: UUID) async throws -> MatchRecord?
    func fetchLog(matchId: UUID) async throws -> [MatchLogEvent]
    func archive(record: MatchRecord, log: [MatchLogEvent]) async throws
    func deleteRecord(id: UUID) async throws
}
```

`MatchLogWriter` (Domain UseCase) — single entry point for append + redaction rules.

### Retention

- Default: keep all matches locally.
- Settings (future): "Keep last N matches" or manual delete swipe.
- No auto-prune in v1.

---

## Event capture (what to log automatically)

### Always (v1)

| Source | Events |
|--------|--------|
| Match start / archive | `matchStarted`, `matchEnded` |
| `BattleTrackerState` mutations | `phaseChanged`, `roundAdvanced`, `activePlayerChanged`, `victoryPointsChanged` |
| Deployment / setup checklists | `deploymentStepCompleted`, `setupStepCompleted` |
| Once-per-battle abilities toggled | `abilityUsed` |
| Army Health wound changes | `damageApplied`; `unitDestroyed` when remaining hits 0 |
| Guided match setup | Attacker/defender, mission pick (on change) |

### Opt-in / v2

| Source | Events |
|--------|--------|
| Batch combat resolver | `combatBatchResolved` when user taps Apply Damage |
| Board state (future) | Objective control changes → VP suggestions logged when accepted |
| User | `userNote` via "Add note" on log screen |

### Never (unless explicit setting)

- Individual dice from `CombatRollEngine` / dice tray
- Full warscroll text snapshots

### Implementation hook

Introduce `MatchLogRecorder` called from:

- `BattlePhaseTrackerViewModel` (phase, VP, wounds, abilities)
- `GuidedMatchViewModel` (setup changes)
- `BatchCombatEvaluatorViewModel` (on apply damage)
- New `MatchArchiveCoordinator` (start/end)

Recorder no-ops when `ReleaseSurface.showsMatchHistory == false`.

---

## UI

### Entry points

| Location | Action |
|----------|--------|
| Play tab toolbar or Guided Match menu | **Match History** (global list) |
| Battle complete guide → **See Results** | Victory screen |
| Victory screen → **Done** | Archive + dismiss |
| Reset Match confirmation | Save to history toggle |
| Settings → Play (future) | History management, export |

### Victory screen (v0 — ships with history)

Full-screen cover (`.fullScreenCover`) — the table moment when the game ends. Replaces the small `BattleGuideCard` "Got it" as the final beat for completed games.

**Layout (winner decided):**

```
┌─────────────────────────────────────┐
│  [game system pill]    [duration]   │
│                                     │
│         🏆  VICTORY                 │  ← largeTitle, accent
│                                     │
│   ┌─────────────┐ ┌─────────────┐   │
│   │  PLAYER 1   │ │  Player 2   │   │  ← loser column: secondary, no crown
│   │  Army name  │ │  Army name  │   │
│   │             │ │             │   │
│   │     14      │ │      8      │   │  ← winner VP: .largeTitle.bold + accent ring
│   │   ★ WINNER  │ │             │   │
│   └─────────────┘ └─────────────┘   │
│                                     │
│  [ Adjust score ]                   │  ← text button / secondary
│                                     │
│  [ Rematch ]     [ Done ]           │  ← primary row
└─────────────────────────────────────┘
```

**Winner column treatment:**

- Crown SF Symbol (`crown.fill`) + **WINNER** badge on winning player only
- Winner VP numeral at `.largeTitle.bold()`; loser at `.title2` with `.secondary` foreground
- Winner card: `accentColor` stroke (2pt) + subtle accent fill (`opacity(0.12)`)
- Loser card: `secondarySystemBackground`, no stroke

**Tie layout:**

- Headline: **Draw** (not "Victory")
- Both columns equal weight — matching accent rings, no crown
- Copy: "Tied on victory points"

**Motion (respect `accessibilityReduceMotion`):**

- Cover presents with `.transition(.opacity.combined(with: .scale(scale: 0.96)))`
- Winner crown + VP count: light scale pulse once (0.3s) on appear
- No confetti in v1 — keep readable at the table in bright light; revisit haptics (`UIImpactFeedbackGenerator`) in v1.1

**Actions:**

| Button | Behavior |
|--------|----------|
| **Done** | Archive match + log, clear active stores, dismiss to Guided Match |
| **Rematch** | Archive, reset tracker, keep army selections, start fresh battle |
| **Adjust score** | Sheet with `VictoryPointsCard` steppers; live-updates winner highlight on dismiss |

**Abandoned / mid-game save:** No victory screen — use a plain confirmation sheet ("Save incomplete match?").

**Accessibility:**

- Screen: `matchVictory.screen`
- Winner column: `matchVictory.winner.playerOne` / `.playerTwo`
- VoiceOver: "{Player name} wins with {N} victory points over {other} with {M}" (or draw copy)
- Minimum 44pt on all actions; Dynamic Type stacks columns vertically (same pattern as `VictoryPointsCard`)

**Component:** `DesignSystem/MatchVictoryScreen.swift` — reusable for history detail "replay" header (read-only, no actions) in v1.

### Match History list (global)

- **One list** for all game systems under Play → Match History (or Guided Match toolbar)
- Default: all systems; **filter** via segmented control or menu (`All` | `Spearhead` | `Combat Patrol` | `SC TMG` | …)
- Grouped by month or "Recent"
- Row: game system badge, army matchup (`P1 vs P2`), final VP, winner chip, date, status pill if abandoned
- Tap → Match Detail

### Match Detail

**Summary card** — players, armies, battlefield/mission, duration, final score, winner.

**Log timeline** — reverse chronological or chronological toggle; sections by battle round.

Row format: time (relative optional), icon by `kind`, one-line summary ("Round 3 · Player 2 · +2 VP · objective").

**Actions:** Add note, Delete match, Share summary (v2 — plain text export).

**Detail header:** Reuse victory layout in read-only mode (winner highlight, final VP) above the log timeline.

### Accessibility

- Screen: `matchHistory.screen`, `matchHistory.detail.{matchId}`, `matchVictory.screen`
- Rows: `matchHistory.row.{matchId}`, `matchLog.event.{eventId}`
- Filter: `matchHistory.filter.{gameSystemId}`

---

## Multi-device sync

**Locked:** History does not sync. `MatchSyncSnapshot` remains live-state only for two-phone play. Each device keeps its own archive. Cross-device history is a future idea, not v1–v2.

---

## Relationship to other work

| Feature | Interaction |
|---------|-------------|
| `BoardStateTracking.md` | Objective/tactic changes become log events when VP is applied |
| `BattleTableFlowSpec.md` | Combat batch apply → `combatBatchResolved` |
| `UnifiedAppPlan.md` | Future link `MatchRecord` → `rosterId` when Muster ships |
| Hobby / SwiftData | Migrate `MatchHistoryRepository` to SwiftData entity + JSON payload column |

---

## Phased delivery

| Phase | Scope | Exit criteria |
|-------|--------|---------------|
| **v0 — Victory + history** | `MatchRecord`; global history list + filter; **victory screen**; archive on Done / reset-with-save | Winner obvious at table; completed game in history; rematch works |
| **v1 — Auto log** | `MatchLogRecorder` + timeline UI; VP/phase/damage/ability events | Dispute-friendly round/VP trace |
| **v1.1 — Notes & abandon** | User notes; abandon flow; victory haptics | Partial games saved |
| **v2 — Combat & export** | Batch combat summaries; share text summary | Post-game review useful for learning |
| **v3 — Insights** | Win rate by army, avg duration | Optional; subscription gate TBD |

Gate behind `ReleaseSurface.showsMatchHistory` until v1 ships.

---

## Open questions

1. **In-progress matches in history?** Recommend no — only active slot + archived. Optional "Resume" if we later support multiple drafts.
2. **Log live buffer when user never ends match?** Keep buffer on disk; offer "Recover unsaved log" if active stores exist but buffer >24h old (edge case).
3. **Combat Patrol confusion** — log should not imply CP cohesion rules; events are mode-agnostic facts only.
4. **Victory haptics** — light success feedback on appear when not reduceMotion? (v1.1)

---

## Verification (when promoted to `specs/`)

| Field | Value |
|-------|-------|
| Target release | v0.4 (history), v0.5 (log) |
| Code paths | `Domain/Models/MatchRecord.swift`, `Domain/UseCases/MatchLogRecorder.swift`, `Data/MatchHistory/`, `Features/MatchHistory/`, `DesignSystem/MatchVictoryScreen.swift` |
| Tests | Archive round-trip, event append order, reset-with-save, winner detection, victory screen tie layout, global filter, denormalized labels survive missing catalog army |

---

## Test plan (sketch)

- Archive produces index + log file; active stores cleared
- Reset with save off deletes active only
- VP change emits one event with correct delta
- Unknown `MatchLogEventKind` decodes without crashing list
- History row shows correct winner for tie / undecided
- `gameSystemId` filter returns subset
- Recorder disabled when feature flag off
- Victory screen highlights correct player for VP 14–8, tie at 10–10, and SC TMG no-VP mode
- Global history filter returns correct subset per `gameSystemId`
