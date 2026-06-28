#!/usr/bin/env bash
#
# Architecture-debt ratchet for the refactor in
# FutureIdeas/ArchitectureRefactorMasterPlan.md.
#
# Counts the anti-patterns the refactor removes and fails if any metric
# EXCEEDS its budget. Budgets are the measured baseline (Phase 0); as each
# phase lands, lower the budget so the debt can never grow back. The goal
# is 0 for every metric by the end of the plan.
#
# Pure ripgrep/grep — no Xcode required, runs in pre-commit and CI.
#
# Usage:
#   Scripts/check_architecture_debt.sh           # enforce budgets (CI)
#   Scripts/check_architecture_debt.sh --report  # print counts, never fail
#
set -uo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

# Prefer ripgrep; fall back to grep -r.
if command -v rg >/dev/null 2>&1; then
  search() { rg -n --no-heading "$1" $2 2>/dev/null; }
else
  search() { grep -rn --include='*.swift' "$1" $2 2>/dev/null; }
fi

SRC="Domain Features DesignSystem Support App"

# metric_name | budget | description | pattern | paths
# Budgets are the Phase 0 baseline. RATCHET THESE DOWN as phases complete.
# Args: name budget desc pattern paths [exclude_path_regex]
# exclude_path_regex drops matching lines (e.g. the sanctioned migration shim
# that legitimately reads the flags it is replacing).
run_metric() {
  local name="$1" budget="$2" desc="$3" pattern="$4" paths="$5" exclude="${6:-}"
  local count
  if [[ -n "$exclude" ]]; then
    count=$(search "$pattern" "$paths" | grep -vE "$exclude" | wc -l | tr -d ' ')
  else
    count=$(search "$pattern" "$paths" | wc -l | tr -d ' ')
  fi
  printf '%-28s %4s / %-4s  %s\n' "$name" "$count" "$budget" "$desc"
  if [[ "$MODE" != "report" && "$count" -gt "$budget" ]]; then
    echo "  ✗ BUDGET EXCEEDED: $name is $count (budget $budget). Do not add new $desc." >&2
    FAILED=1
  fi
}

MODE="enforce"
[[ "${1:-}" == "--report" ]] && MODE="report"
FAILED=0

echo "Architecture-debt ratchet (count / budget):"
echo "-------------------------------------------"

# Phase 1/3 target: branch on engine/capability, never identity.
run_metric "switch_gameSystemId"   21  "raw 'switch gameSystemId' blocks" \
  'switch[[:space:]].*gameSystemId' "$SRC"

# Phase 1/3 target: no raw id string-literal comparisons.
run_metric "raw_id_literals"       46  "raw game-system id string literals" \
  '"(aos-spearhead|sc-tmg|wh40k-11e|wh40k-10e-cp|wh40k-10e)"' "Domain Features DesignSystem"

# Phase 3 target: delete BattleRules god facade + identity probes.
run_metric "battlerules_or_probes" 14 "BattleRules / is<System> identity probes" \
  'BattleRules\.|isSpearhead|isWh40k|isStarCraft|isCombatPatrol' "$SRC"

# Phase 2 target: capability flags grouped, system-named flags removed.
# PlayCapabilities+Grouped.swift is the sanctioned shim that maps these flags
# to closed enums — it is excluded so new *feature* usage is still caught.
run_metric "system_named_caps"      0  "system-named capability flags" \
  'usesWh40k1[01]eCombatRollEngine|shows(Wh40k|ScTmg)DeploymentChecklist|showsCombatPatrolMode' \
  "Domain" \
  'PlayCapabilities\+Grouped\.swift'

echo "-------------------------------------------"
if [[ "$FAILED" -eq 1 ]]; then
  echo "Architecture-debt check FAILED — see budget violations above." >&2
  exit 1
fi
echo "Architecture-debt check OK."
exit 0
