# AoS Spearhead Content Verification Audit

**First audit:** 2026-06-19  
**Game mode:** `aos-spearhead` (`GameSystemId.aosSpearhead`) — **Spearhead only**  
**Standard AoS:** Out of scope — see [../aos-standard/scope.md](../aos-standard/scope.md)  
**Bundle:** `Resources/Rules/spearhead-catalog-v1.json` + `Resources/Rules/Spearhead/armies/`  
**Local GW PDFs:** `FutureIdeas/aos-downloads/` (67 files after dedup, ~820 MB — not shipped in app)

Tabletome copy is summarized in our own words. **Always defer to official GW Spearhead PDFs** for disputes.

---

## Current bundle snapshot

| Metric | Count | Notes |
|--------|------:|-------|
| Factions in catalog | 24 | All legal AoS 4e Spearhead factions represented |
| Armies in catalog | 48 | Matches `SpearheadCatalogCompletenessTests` |
| Battle-tracker detail JSON | 48 | One `{army-id}.json` per army |
| Full warscroll support | 48 | All armies via Wahapedia import (`Scripts/import_spearhead_warscrolls.py`); `vigilant-brotherhood` + `gnawfeast-clawpack` remain hand-curated |
| Automated PDF spot-check | 48/48 | `python3 Scripts/verify_spearhead_against_pdfs.py` (2026-06-19) |
| Local Spearhead army PDFs | ~41 | Mapped in verify script; 7 armies share faction/multi-army PDFs |
| New GW packs (not in catalog) | 2 | Epicurean Revellers, Fire and Jade |

### Content coverage levels (`SpearheadContentCoverage`)

| Level | Player-facing label | What it means |
|-------|---------------------|---------------|
| `roster` | Army list only | Name + fixed roster |
| `matchSetup` | Setup ready | + 2 regiment abilities, 4 enhancements |
| `battleTracker` | Rules reminders ready | + per-unit wound/control tracking |
| `warscrolls` | Full tabletop support | + stats, weapons, phased abilities |

**Goal for Spearhead pull:** every catalog army at **`warscrolls`**, verified against its official PDF.

---

## Reference PDFs (verify first)

Check these before auditing individual armies.

| Priority | Local file | Use |
|----------|------------|-----|
| P0 | `ageofsigmar_corerules&keydownloads_spearheadreferece_eng_24.09-jrpbcnzwuu.pdf` | Spearhead core rules, turn structure, scoring |
| P0 | `ageofsigmar_miscellaneous_armyroster_eng.24.09-lgu9t30uss.pdf` | Master army roster list |
| P1 | `eng_08-08_aos_other_rules_spearhead_rules_module_desolation_of_the_mortal_realms-ttpg1obflk-vw3epzd1yc.pdf` | Optional module (document if we link it) |
| P1 | `eng_14-12_aos_spearhead_doubles-0mbddn5ccu-8rp55iunvh.pdf` | Doubles format |
| P2 | `eng_15-04_aos_spearhead_city_of_ash_gaming_pack-0mp6ikgdep-heefiiargp.pdf` | Narrative gaming pack |
| — | `eng_16-13k65olsxx.pdf` | **Unidentified** — rename after manual open |

### Core rules checklist (Spearhead booklet)

- [ ] Turn phases and player order match in-app battle flow / phase coach
- [ ] Scoring (tactics, battle plan, underdog) summarized correctly
- [ ] Regiment ability pick (2 options) and enhancement pick (4 options) match catalog shape
- [ ] Reinforcement / arrival timing if referenced in guided match copy
- [ ] Glossary terms in `RulesGlossaryCatalog` for AoS Spearhead are accurate
- [ ] No pasted GW card text in bundle — summaries + `officialRulesURL` links only

---

## Per-army verification checklist

For each army, work left → right. Mark **PDF ✓** when roster, abilities, and enhancements match the local file (or linked WHC URL).

**Legend:** PDF ✓ = automated spot-check passed (`verify_spearhead_against_pdfs.py`) · BT = battle traits · UA = unit abilities · WS = warscroll stats/weapons

### Automated verification (2026-06-19)

All **48/48** catalog armies pass `Scripts/verify_spearhead_against_pdfs.py` against local PDFs in `FutureIdeas/aos-downloads/`. The script checks general, roster, regiment abilities, enhancements, wound stats, weapon names, unit abilities, and battle traits. Hand-curated armies (`vigilant-brotherhood`, `gnawfeast-clawpack`, `yndrastas-spearhead`) skip weapon/ability name checks.

Re-run after content changes:

```bash
cd Scripts && python3 verify_spearhead_against_pdfs.py
```

---

### Stormcast Eternals

| Army ID | Local PDF | PDF ✓ | Roster | Setup | BT | UA | WS | Notes |
|---------|-----------|-------|--------|-------|----|----|-----|-------|
| `vigilant-brotherhood` | `eng_aos_spearhead_stormcast_eternals_dec_24-jyo1gqr2pm-0e3gf5ydzh.pdf` | [ ] | [ ] | [ ] | [ ] | [ ] | [x] | Featured starter |
| `yndrastas-spearhead` | Same Stormcast PDF (shared) | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | |

### Skaven

| Army ID | Local PDF | PDF ✓ | Roster | Setup | BT | UA | WS | Notes |
|---------|-----------|-------|--------|-------|----|----|-----|-------|
| `gnawfeast-clawpack` | `eng_01-04_aos_spearhead_skaven_gnawfeast_clawpack-zorddipson-dpnghi1nvc.pdf` | [ ] | [ ] | [ ] | [ ] | [ ] | [x] | Featured starter |
| `warpspark-clawpack` | `eng_01-04_aos_spearhead_skaven_gnawfeast_clawpack-…pdf` (shared w/ Gnawfeast) | [x] | [ ] | [ ] | [ ] | [ ] | [ ] | |
| `crixxits-kill-pack` | `eng_15-04_aos_spearhead_city_of_ash_gaming_pack-…pdf` | [x] | [ ] | [ ] | [ ] | [ ] | [ ] | City of Ash pack |

### Cities of Sigmar

| Army ID | Local PDF | PDF ✓ | Roster | Setup | BT | UA | WS | Notes |
|---------|-----------|-------|--------|-------|----|----|-----|-------|
| `castelite-company` | `eng_01-04_aos_spearhead_cities_of_sigmar_castelite_company-…pdf` | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | |
| `fusil-platoon` | `eng_01-04_aos_spearhead_cities_of_sigmar_fusil_platoon-…pdf` | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | |
| `sentinels-embergard` | `eng_15-04_aos_spearhead_city_of_ash_gaming_pack-…pdf` | [x] | [ ] | [ ] | [ ] | [ ] | [ ] | City of Ash pack |
| `zenestras-zealots` | `eng_13-05_aos_spearhead_cities_of_sigmar_zenestra-s_zealots-…pdf` | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | |

### Daughters of Khaine

| Army ID | Local PDF | PDF ✓ | Roster | Setup | BT | UA | WS | Notes |
|---------|-----------|-------|--------|-------|----|----|-----|-------|
| `heartflayer-troupe` | `eng_01-04_aos_spearhead_daughters_of_khaine_heartflayer_troupe-…pdf` | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | |
| `khainite-shadow-coven` | `eng_25-03_aos_spearhead_daughters_of_khaine_khainite_shadow_coven-…pdf` | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | DoK supplement also downloaded |

### Fyreslayers

| Army ID | Local PDF | PDF ✓ | Roster | Setup | BT | UA | WS | Notes |
|---------|-----------|-------|--------|-------|----|----|-----|-------|
| `saga-axeband` | `eng_aos_spearhead_fyreslayers_saga_axeband-…pdf` | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | |

### Kharadron Overlords

| Army ID | Local PDF | PDF ✓ | Roster | Setup | BT | UA | WS | Notes |
|---------|-----------|-------|--------|-------|----|----|-----|-------|
| `skyhammer-task-force` | `eng_12-11_aos_spearhead_kharadron_overlords_skyhammer_task_force-…pdf` | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | |
| `grundstok-trailblazers` | `eng_01-04_aos_spearhead_kharadron_overlords_grundstok_trailblazers-…pdf` | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | |

### Idoneth Deepkin

| Army ID | Local PDF | PDF ✓ | Roster | Setup | BT | UA | WS | Notes |
|---------|-----------|-------|--------|-------|----|----|-----|-------|
| `soulraid-hunt` | `eng_01-04_aos_spearhead_idoneth_deepkin_soulraid_hunt-…pdf` | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | |
| `akhelian-tide-guard` | `eng_aos4_idoneth_deepkin_spearhead_rules-wa1tiv6csl-bndmddnja9.pdf` | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | Faction Spearhead rules PDF |

### Lumineth Realm-lords

| Army ID | Local PDF | PDF ✓ | Roster | Setup | BT | UA | WS | Notes |
|---------|-----------|-------|--------|-------|----|----|-----|-------|
| `glittering-phalanx` | `eng_01-04_aos_spearhead_lumineth_realmlords_glittering_phalanx-…pdf` | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | |
| `hurakan-vanguard` | `eng_04-02_aos_spearhead_lumineth_realmlords-…pdf` | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | Older pack name in filename |

### Seraphon

| Army ID | Local PDF | PDF ✓ | Roster | Setup | BT | UA | WS | Notes |
|---------|-----------|-------|--------|-------|----|----|-----|-------|
| `starscale-warhost` | `eng_aos_spearhead_seraphon_starscale_warhost-…pdf` | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | |
| `sunblooded-prowlers` | `eng_01-04_aos_spearhead_seraphon_sunblooded_prowlers-…pdf` | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | |

### Sylvaneth

| Army ID | Local PDF | PDF ✓ | Roster | Setup | BT | UA | WS | Notes |
|---------|-----------|-------|--------|-------|----|----|-----|-------|
| `bitterbark-copse` | `eng_aos_spearhead_sylvaneth_bitterbark-copse-…pdf` | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | |
| `spitewing-flight` | `eng_25-03_aos_spearhead_spitewing_flight_sylvaneth-…pdf` | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | |

### Blades of Khorne

| Army ID | Local PDF | PDF ✓ | Roster | Setup | BT | UA | WS | Notes |
|---------|-----------|-------|--------|-------|----|----|-----|-------|
| `bloodbound-gore-pilgrims` | `eng_01-04_aos_spearhead_blades_of_khorne_bloodbound_gore_pilgrims-…pdf` | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | |
| `fangs-of-the-blood-god` | `eng_01-04_aos_spearhead_blades_of_khorne_fangs_of_the_blood_god-…pdf` | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | |

### Disciples of Tzeentch

| Army ID | Local PDF | PDF ✓ | Roster | Setup | BT | UA | WS | Notes |
|---------|-----------|-------|--------|-------|----|----|-----|-------|
| `fluxblade-coven` | `eng_01-04_aos_spearhead_disciples_of_tzeentch_fluxblade_coven-…pdf` | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | |
| `tzaangor-warflocks` | `eng_04-02_aos_spearhead_disciples_of_tzeentch-…pdf` | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | |

### Hedonites of Slaanesh

| Army ID | Local PDF | PDF ✓ | Roster | Setup | BT | UA | WS | Notes |
|---------|-----------|-------|--------|-------|----|----|-----|-------|
| `blades-lurid-dream` | `eng_01-04_aos_spearhead_hedonites_of_slaanesh_blades_of_the_lurid_dream-…pdf` | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | |

### Maggotkin of Nurgle

| Army ID | Local PDF | PDF ✓ | Roster | Setup | BT | UA | WS | Notes |
|---------|-----------|-------|--------|-------|----|----|-----|-------|
| `bleak-host` | `eng_01-04_aos_spearhead_maggotkin_of_nurgle_bleak_host-…pdf` | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | |
| `bubonic-cell` | `eng_14-01_aos_spearhead_maggotkin_of_nurgle_bubonic_cell-…pdf` | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | |

### Slaves to Darkness

| Army ID | Local PDF | PDF ✓ | Roster | Setup | BT | UA | WS | Notes |
|---------|-----------|-------|--------|-------|----|----|-----|-------|
| `bloodwind-legion` | `eng_spearhead_slaves_to_darkness.27-dqd6t0o4ny.pdf` | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | |
| `darkoath-raiders` | `eng_01-04_aos_spearhead_slaves_to_darkness_darkoath_raiders-…pdf` | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | |

### Helsmiths of Hashut

| Army ID | Local PDF | PDF ✓ | Roster | Setup | BT | UA | WS | Notes |
|---------|-----------|-------|--------|-------|----|----|-----|-------|
| `helforge-host` | `eng_01-04_aos_spearhead_helsmiths_of_hashut_helforge_host-…pdf` | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | |

### Gloomspite Gitz

| Army ID | Local PDF | PDF ✓ | Roster | Setup | BT | UA | WS | Notes |
|---------|-----------|-------|--------|-------|----|----|-----|-------|
| `bad-moon-madmob` | `eng_01-04_aos_spearhead_gloomspite_gitz_bad_moon_madmob-…pdf` | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | |
| `snarlpack-huntaz` | `eng_01-04_aos_spearhead_gloomspite_gitz_snarlpack_hunters-…pdf` | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | PDF name ≠ catalog id |

### Orruk Warclans

| Army ID | Local PDF | PDF ✓ | Roster | Setup | BT | UA | WS | Notes |
|---------|-----------|-------|--------|-------|----|----|-----|-------|
| `ironjawz-bigmob` | `eng_01-04_aos_spearhead_orruk_warclans_ironjawz_bigmob-…pdf` | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | |
| `swampskulka-gang` | `eng_12-11_aos_spearhead_swampskulka_gang_orruk_warclans-…pdf` | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | |

### Ogor Mawtribes

| Army ID | Local PDF | PDF ✓ | Roster | Setup | BT | UA | WS | Notes |
|---------|-----------|-------|--------|-------|----|----|-----|-------|
| `tyrants-bellow` | `eng_aos_spearhead_ogor_tyrant-s_bellow-…pdf` | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | |
| `scrapglutt` | `eng_01-04_aos_spearhead_ogor_mawtribes_scrapglutt-…pdf` | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | |

### Sons of Behemat

| Army ID | Local PDF | PDF ✓ | Roster | Setup | BT | UA | WS | Notes |
|---------|-----------|-------|--------|-------|----|----|-----|-------|
| `wallsmasher-stomp` | `eng_aos_spearhead_sons_of_behemat_wallsmasher_stomp-…pdf` | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | |

### Flesh-Eater Courts

| Army ID | Local PDF | PDF ✓ | Roster | Setup | BT | UA | WS | Notes |
|---------|-----------|-------|--------|-------|----|----|-----|-------|
| `carrion-retainers` | `eng_12-11_aos_spearhead_flesh_eater_courts_carrion_retainers-…pdf` | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | |
| `charnel-watch` | `eng_aug25_aos_spearhead_rules_fec-2e0llsv3kw-gnsahcoz34.pdf` (likely) | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | Confirm PDF |

### Nighthaunt

| Army ID | Local PDF | PDF ✓ | Roster | Setup | BT | UA | WS | Notes |
|---------|-----------|-------|--------|-------|----|----|-----|-------|
| `slasher-host` | `eng_12-11_aos_spearhead_nighthaunt_slasher_host-…pdf` | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | |
| `cursed-shacklehorde` | `eng_29-04_aos_spearhead_nighthaunt_cursed_shacklehorde-…pdf` | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | |

### Ossiarch Bonereapers

| Army ID | Local PDF | PDF ✓ | Roster | Setup | BT | UA | WS | Notes |
|---------|-----------|-------|--------|-------|----|----|-----|-------|
| `tithe-reaper-echelon` | `eng_aos_spearhead_fire_and_jade_obr-…pdf` | [x] | [ ] | [ ] | [ ] | [ ] | [ ] | Fire and Jade pack |
| `mortisan-elite` | Same OBR rules PDF (likely) | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | |
| `kavalos-vanguard` | `eng_18-02_aos_spearhead_ossiarch_bonereapers_kavalos_vanguard-…pdf` | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | |

### Soulblight Gravelords

| Army ID | Local PDF | PDF ✓ | Roster | Setup | BT | UA | WS | Notes |
|---------|-----------|-------|--------|-------|----|----|-----|-------|
| `bloodcrave-hunt` | `eng_01-04_aos_spearhead_soulblight_gravelords_bloodcrave_hunt-…pdf` | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | |
| `deathrattle-tomb-host` | `eng_01-04_aos_spearhead_soulblight_gravelords_deathrattle_tomb_host-…pdf` | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | |

---

## New GW Spearhead packs (not in catalog yet)

Track separately — add to catalog only after Spearhead pull for existing 48 armies is complete.

| Pack (from PDF) | Local file | In catalog? | Action |
|-----------------|------------|-------------|--------|
| Epicurean Revellers | `eng_17-06_aos_spearhead_hedonites_of_slaanesh_epicurean_revellers-…pdf` | No | Optional v2 content |
| Fire and Jade | `eng_aos_spearhead_fire_and_jade_obr-…pdf` | No | Optional v2 content |

---

## Spearhead army pull workflow (after checklist)

Run in order. Do **not** mix standard battletome imports into Spearhead bundles.

### Phase 1 — Roster & match setup (catalog)

1. Open army PDF side-by-side with `spearhead-catalog-v1.json` entry.
2. Verify fixed roster units, general, unit counts.
3. Verify 2 regiment abilities + 4 enhancements (names, summaries — not full GW text).
4. Refresh from Wahapedia if needed: `python3 Scripts/import_spearhead_from_wahapedia.py` (review diff before commit).
5. Run `SpearheadCatalogCompletenessTests`.

### Phase 2 — Battle tracker detail (all 48 armies)

For each `Resources/Rules/Spearhead/armies/{army-id}.json`:

1. Add `battleTraits` with correct `phases`, `usageLimit`, declare/effect summaries.
2. Add per-unit `abilities` (non-passive abilities must declare phases).
3. Ensure unit ids align with catalog roster slugs.
4. Run `SpearheadCatalogValidator` via app load or unit tests.

### Phase 3 — Warscrolls (target: all armies at `warscrolls`)

1. Fill `move`, `save`, `health`, `control`, `modelCount`, `keywords`, `weapons` per unit.
2. Use `python3 Scripts/import_spearhead_warscrolls.py` where Wahapedia matches Spearhead roster.
3. Extend `SpearheadWarscrollAuditTests` with PDF-spot-check fixtures (pattern: featured armies).
4. Confirm Roll Evaluator prefills from weapon profiles.

### Phase 4 — Spot-check in app

1. Guided Match → pick army → confirm coverage badge reaches **Full tabletop support**.
2. Battle tracker → wound tracking, ability reminders, warscroll panel.
3. Search (`AppSearchEngine`) finds army names and key abilities.

---

## Ongoing verification process

1. After each GW Spearhead FAQ or new pack release, download PDF to `FutureIdeas/aos-downloads/` and add a row above.
2. Do not paste GW warscroll or ability text verbatim into JSON.
3. Link out via `officialRulesURL` on catalog entries.
4. Re-run unit tests: `SpearheadCatalogCompletenessTests`, `SpearheadWarscrollAuditTests`, `SpearheadContentPipelineTests`.
5. Log fixes in **Errors found and fixed** (below) like the 40k audit.

---

## Errors found and fixed

| Issue | Was | Corrected to | Source | Date |
|-------|-----|--------------|--------|------|
| PDF ligature / spaced text | Verify missed `Skalfhammer`, `Wheel About`, etc. | Compact matching + `/f_` ligature strip in verify script | GW PDF extract | 2026-06-19 |
| Wrong PDF mapping | `warpspark-clawpack`, `crixxits-kill-pack`, `sentinels-embergard`, `tithe-reaper-echelon` | Correct local PDF filenames in `ARMY_PDF_MAP` | Manual PDF open | 2026-06-19 |
| Catalog enhancement not in PDF | `Point Blank Volley` (Fusil Platoon) | Removed — PDF lists only 3 enhancements | Fusil Platoon PDF | 2026-06-19 |
| Catalog enhancement name | `Marrowpact` (Tithe-Reaper) | `Nadirite Assault` | Fire and Jade OBR PDF | 2026-06-19 |
| Weapon typo | `Mounrfang's Tusks` | `Mournfang's Tusks` | Tyrant's Bellow PDF | 2026-06-19 |
| Wrong unit abilities | Blood tithe abilities on Mighty Skullcrushers | `Brass Stampede` only | Gore Pilgrims PDF | 2026-06-19 |
| Wrong ability names | `Windleap` on Hurakan Windmage / Spirit | `Guide The Gusts`; removed duplicate on Spirit | Hurakan Vanguard PDF | 2026-06-19 |
| Catalog typos (prior) | `Point-Blank Volley`, `Amberstone Whetstone`, `Inpenetrable Ranks` | `Point Blank Volley` (removed), `Amberbone Whetstone`, `Impenetrable Ranks` | Various PDFs | 2026-06-19 |

---

## Remaining risk

Automated PDF spot-check covers **names** (roster, setup options, warscroll labels) for all 48 armies. It does **not** validate numeric stats line-by-line, ability effect wording, or core Spearhead booklet vs in-app battle flow. Complete manual **Roster / Setup / BT / UA / WS** columns above before marketing full rules parity.
