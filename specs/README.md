# Specs Index

Authoritative behavior contracts. Brainstorm (`docs/brainstorm.md`) is **not** authoritative.

| Spec | Scope |
|------|-------|
| [ArchitectureSpec.md](ArchitectureSpec.md) | Layers, modules, dependency rules |
| [TechStackSpec.md](TechStackSpec.md) | Frameworks, min OS, tooling |
| [DataSchemaSpec.md](DataSchemaSpec.md) | Bundled JSON schema & migrations |
| [DesignSystemSpec.md](DesignSystemSpec.md) | Tokens, typography, components |
| [AccessibilitySpec.md](AccessibilitySpec.md) | WCAG targets, orientations |
| [LocalizationSpec.md](LocalizationSpec.md) | String policy, locales |
| [TestPlanSpec.md](TestPlanSpec.md) | CI gates, test matrix |
| [ReleaseSurfaceSpec.md](ReleaseSurfaceSpec.md) | Feature gating |
| [GameGuideSpec.md](GameGuideSpec.md) | Getting Started walkthrough |
| [GuidedMatchSpec.md](GuidedMatchSpec.md) | Spearhead army selection & match setup |
| [GuidedMatchUXPolishPlan.md](GuidedMatchUXPolishPlan.md) | iPad, landscape, accessibility polish for Guided Match |
| [SpearheadContentSpec.md](SpearheadContentSpec.md) | Scalable Spearhead army content pipeline |
| [CombatRollEvaluatorSpec.md](CombatRollEvaluatorSpec.md) | Hit/wound/save attack roll wizard |
| [RulesReferenceSpec.md](RulesReferenceSpec.md) | Offline rules browser |

## Governance

On conflict: **ArchitectureSpec** → system specs → feature specs → `docs/feature-inventory.md` → brainstorm.

Every feature spec ends with a **Verification** block (release, date, commit, code paths).

## Promotion Pipeline

`FutureIdeas/` or `docs/brainstorm.md` → feature spec (behavior locked) → implementation → inventory update.
