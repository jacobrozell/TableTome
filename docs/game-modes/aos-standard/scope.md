# Age of Sigmar — Standard Play Scope

**Status:** Not supported  
**Supported today:** Spearhead only (`GameSystemId.aosSpearhead`)  
**Last updated:** 2026-06-19

---

## What Tabletome ships for AoS

| Capability | Spearhead | Standard AoS |
|------------|-----------|--------------|
| Guided Match (fixed rosters) | Yes | No |
| Regiment abilities + enhancements | Yes | N/A |
| Battle tracker / wound tracking | Yes (48 armies) | No |
| Full warscroll + weapon profiles | Partial (2 featured armies) | No |
| Army builder / points | No | No |
| Battletome rules / subfactions | No | No |
| Manifestation / endless spells tracking | No | No |
| Pitched battle / Matched Play missions | No | No |

Default game system in onboarding remains **AoS Spearhead**. Users picking Tabletome for “full Age of Sigmar” should be directed to official GW materials until a future `GameSystemId` exists.

---

## Downloaded PDFs that are *not* Spearhead scope

These live in `FutureIdeas/aos-downloads/` for future reference only. **Do not import into the Spearhead catalog** without a deliberate product decision.

### Faction packs & battletome supplements

Used for standard list-building and faction rules — outside current app engines:

- `ageofsigmar_factionpacks_supplementstormcasteternals_eng_24.09-…pdf`
- `eng_24-09_aos_faction_pack_fyreslayers-…pdf`
- `eng_17-12_aos_factionpack_seraphon-…pdf`
- `eng_17-12_aos_factionpack_hedonites_of_slaanesh-…pdf`
- `eng_aos_faction_pack_ogor_mawtribes_feb_25-…pdf`
- `eng_aos_faction_pack_sons_of_behemat_feb25-…pdf`
- `eng_aos_faction_cities_of_sigmar_jul_25-…pdf`
- `eng_30-07_aos_faction_pack_blades_of_khorne_supplement-…pdf`
- `eng_25-03_aos_otherrules_daughters_of_khaine_supplement-…pdf`
- `eng_aos4_disciples-of-tzeentch_supplement-…pdf`
- `eng_sept25_aos_nighthaunt_supplement-…pdf`
- `battletome_beasts_of_chaos_nov_24_eng_27-…pdf`
- `battletome_bonesplitterz_nov_24_eng_27-…pdf`
- `eng_aos_cities_of_sigmar_battletome_supplement-…pdf`
- `eng_17-06_aos_battletome_supplement_hedonites_of_slaanesh-…pdf`
- `eng_27-05_aos_battletome_supplement_skaven_eshin-…pdf`

Some of these PDFs also contain **Spearhead army pages** (e.g. Skaven Eshin supplement for Warpspark / Crixxit). Use only the Spearhead sections when working on [../aos-spearhead/content-verification.md](../aos-spearhead/content-verification.md).

---

## Future standard AoS (if we build it)

Would likely require:

1. **New game system id** — e.g. `aos-standard` — separate from `aos-spearhead` in `GameSystemId`, `PlayCapabilities`, combat/dice engines (if any).
2. **Rules bundle** — core rules + glossary, not Spearhead turn/scoring copy.
3. **Army data model** — points, battle formations, lores, artefacts (beyond fixed Spearhead rosters).
4. **Roster builder** — integration with hobby bench or new muster flow.
5. **Release gating** — `ReleaseSurface` until content + engines are verified.

Until then, UI copy should say **Spearhead** explicitly (see `GameSystemRulesLabels`, onboarding, home cards).

---

## Related docs

- [../aos-spearhead/content-verification.md](../aos-spearhead/content-verification.md) — active verification checklist
- [specs/SpearheadContentSpec.md](../../../specs/SpearheadContentSpec.md) — bundled Spearhead JSON schema
- [Warhammer Community AoS downloads](https://www.warhammer-community.com/en-gb/downloads/warhammer-age-of-sigmar/)
