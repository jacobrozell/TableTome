#!/usr/bin/env python3
"""Spot-check bundled Spearhead JSON against local GW PDFs in FutureIdeas/aos-downloads/."""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

from pypdf import PdfReader

ROOT = Path(__file__).resolve().parents[1]
CATALOG_PATH = ROOT / "Resources/Rules/spearhead-catalog-v1.json"
DETAIL_DIR = ROOT / "Resources/Rules/Spearhead/armies"
PDF_DIR = ROOT / "FutureIdeas/aos-downloads"

# army-id -> PDF filename (None = verify via shared faction PDF only)
ARMY_PDF_MAP: dict[str, str | None] = {
    "vigilant-brotherhood": "eng_aos_spearhead_stormcast_eternals_dec_24-jyo1gqr2pm-0e3gf5ydzh.pdf",
    "yndrastas-spearhead": "eng_aos_spearhead_stormcast_eternals_dec_24-jyo1gqr2pm-0e3gf5ydzh.pdf",
    "gnawfeast-clawpack": "eng_01-04_aos_spearhead_skaven_gnawfeast_clawpack-zorddipson-dpnghi1nvc.pdf",
    "warpspark-clawpack": "eng_01-04_aos_spearhead_skaven_gnawfeast_clawpack-zorddipson-dpnghi1nvc.pdf",
    "crixxits-kill-pack": "eng_15-04_aos_spearhead_city_of_ash_gaming_pack-0mp6ikgdep-heefiiargp.pdf",
    "castelite-company": "eng_01-04_aos_spearhead_cities_of_sigmar_castelite_company-nthmiu00z3-olrqpo2lat.pdf",
    "fusil-platoon": "eng_01-04_aos_spearhead_cities_of_sigmar_fusil_platoon-ps3dhpiflc-3fboq1inns.pdf",
    "sentinels-embergard": "eng_15-04_aos_spearhead_city_of_ash_gaming_pack-0mp6ikgdep-heefiiargp.pdf",
    "zenestras-zealots": "eng_13-05_aos_spearhead_cities_of_sigmar_zenestra-s_zealots-jiv98kvc9n-nhjktzu4pc.pdf",
    "heartflayer-troupe": "eng_01-04_aos_spearhead_daughters_of_khaine_heartflayer_troupe-f0gnypscvv-4htucb5fsr.pdf",
    "khainite-shadow-coven": "eng_25-03_aos_spearhead_daughters_of_khaine_khainite_shadow_coven-kcxewlylck-jc3xxv1v2v.pdf",
    "saga-axeband": "eng_aos_spearhead_fyreslayers_saga_axeband-9bngjzbzg0-d3q2qoqm5r.pdf",
    "skyhammer-task-force": "eng_12-11_aos_spearhead_kharadron_overlords_skyhammer_task_force-juxkvk8zj2-scpnhbxwwv.pdf",
    "grundstok-trailblazers": "eng_01-04_aos_spearhead_kharadron_overlords_grundstok_trailblazers-sthwiusou1-9tilsswcap.pdf",
    "soulraid-hunt": "eng_01-04_aos_spearhead_idoneth_deepkin_soulraid_hunt-ymkq3pu04e-aymk0cvmbn.pdf",
    "akhelian-tide-guard": "eng_aos4_idoneth_deepkin_spearhead_rules-wa1tiv6csl-bndmddnja9.pdf",
    "glittering-phalanx": "eng_01-04_aos_spearhead_lumineth_realmlords_glittering_phalanx-vc5h4mvert-lcmzbvmqq9.pdf",
    "hurakan-vanguard": "eng_04-02_aos_spearhead_lumineth_realmlords-5ruf50utef-0atmxv5lpx.pdf",
    "starscale-warhost": "eng_aos_spearhead_seraphon_starscale_warhost-4ipgg8d3kx-kpmzdbylav.pdf",
    "sunblooded-prowlers": "eng_01-04_aos_spearhead_seraphon_sunblooded_prowlers-ijqpegpobv-fpafdma7w8.pdf",
    "bitterbark-copse": "eng_aos_spearhead_sylvaneth_bitterbark-copse-jqmpmca0ca-baul2djdaq.pdf",
    "spitewing-flight": "eng_25-03_aos_spearhead_spitewing_flight_sylvaneth-rtiguzvyhx-f7di7yhcim.pdf",
    "bloodbound-gore-pilgrims": "eng_01-04_aos_spearhead_blades_of_khorne_bloodbound_gore_pilgrims-r1xwzo5jaf-hkweqb74wl.pdf",
    "fangs-of-the-blood-god": "eng_01-04_aos_spearhead_blades_of_khorne_fangs_of_the_blood_god-ka6n0z20jt-aeqz1vbnku.pdf",
    "fluxblade-coven": "eng_01-04_aos_spearhead_disciples_of_tzeentch_fluxblade_coven-maph6dtofo-iasdohuesc.pdf",
    "tzaangor-warflocks": "eng_04-02_aos_spearhead_disciples_of_tzeentch-4mldohmkit-qcunidsq7c.pdf",
    "blades-lurid-dream": "eng_01-04_aos_spearhead_hedonites_of_slaanesh_blades_of_the_lurid_dream-ifdy4fzfwt-trt9nu00ej.pdf",
    "bleak-host": "eng_01-04_aos_spearhead_maggotkin_of_nurgle_bleak_host-anonar5akg-es9llpugle.pdf",
    "bubonic-cell": "eng_14-01_aos_spearhead_maggotkin_of_nurgle_bubonic_cell-pzrkznb841-nra7t3b9st.pdf",
    "bloodwind-legion": "eng_spearhead_slaves_to_darkness.27-dqd6t0o4ny.pdf",
    "darkoath-raiders": "eng_01-04_aos_spearhead_slaves_to_darkness_darkoath_raiders-mcmbaocpba-1o87y80z16.pdf",
    "helforge-host": "eng_01-04_aos_spearhead_helsmiths_of_hashut_helforge_host-f9jrp14new-ugnb0veptj.pdf",
    "bad-moon-madmob": "eng_01-04_aos_spearhead_gloomspite_gitz_bad_moon_madmob-x8uml0kiyo-xpyifmywuh.pdf",
    "snarlpack-huntaz": "eng_01-04_aos_spearhead_gloomspite_gitz_snarlpack_hunters-dk3amzdenf-1dhez0axxu.pdf",
    "ironjawz-bigmob": "eng_01-04_aos_spearhead_orruk_warclans_ironjawz_bigmob-ihpwqzmdpv-nkwwjlzs0m.pdf",
    "swampskulka-gang": "eng_12-11_aos_spearhead_swampskulka_gang_orruk_warclans-w8fpypteaj-ekuw00scka.pdf",
    "tyrants-bellow": "eng_aos_spearhead_ogor_tyrant-s_bellow-2x4dua4hul-ybq3296fth.pdf",
    "scrapglutt": "eng_01-04_aos_spearhead_ogor_mawtribes_scrapglutt-rscn8zyfsn-ersmm4yxe3.pdf",
    "wallsmasher-stomp": "eng_aos_spearhead_sons_of_behemat_wallsmasher_stomp-pixgkvvzk0-hh6q2dgl7y.pdf",
    "carrion-retainers": "eng_12-11_aos_spearhead_flesh_eater_courts_carrion_retainers-p8mhioxip3-ugpcbnaxvq.pdf",
    "charnel-watch": "eng_aug25_aos_spearhead_rules_fec-2e0llsv3kw-gnsahcoz34.pdf",
    "slasher-host": "eng_12-11_aos_spearhead_nighthaunt_slasher_host-5basg9ujlw-xowsazitxv.pdf",
    "cursed-shacklehorde": "eng_29-04_aos_spearhead_nighthaunt_cursed_shacklehorde-br9d6bfwzt-4k0qp3is9x.pdf",
    "tithe-reaper-echelon": "eng_aos_spearhead_fire_and_jade_obr-x8j1lrc6kr-slfvyoftwm.pdf",
    "mortisan-elite": "eng_jun25_aos_spearhead_ossiarchbr_rules-oyqrmemltw-ba87liamqd.pdf",
    "kavalos-vanguard": "eng_18-02_aos_spearhead_ossiarch_bonereapers_kavalos_vanguard-jbqptot5r8-wv7o91pzot.pdf",
    "bloodcrave-hunt": "eng_01-04_aos_spearhead_soulblight_gravelords_bloodcrave_hunt-vdg57qq6dt-h7hylvvtke.pdf",
    "deathrattle-tomb-host": "eng_01-04_aos_spearhead_soulblight_gravelords_deathrattle_tomb_host-yfcq06h2aq-h5hdzqs0hi.pdf",
}

RELAXED_VERIFY_ARMY_IDS = {
    "vigilant-brotherhood",
    "gnawfeast-clawpack",
    "yndrastas-spearhead",
}

_pdf_cache: dict[str, str] = {}


SKIP_ABILITY_NAMES = {
    "normal move",
    "run",
    "charge",
    "retreat",
    "stand up",
    "move",
    "declare",
    "effect",
}


def normalize(text: str) -> str:
    text = text.lower().replace("\u2011", "-").replace("\u2013", "-").replace("‑", "-")
    text = re.sub(r"/([a-z])_", r"\1", text)
    text = re.sub(r"[^a-z0-9]+", " ", text)
    return re.sub(r"\s+", " ", text).strip()


def compact(text: str) -> str:
    return normalize(text).replace(" ", "")


def should_skip_ability(ability: dict) -> bool:
    name = normalize(ability.get("name", ""))
    if name in {normalize(x) for x in SKIP_ABILITY_NAMES}:
        return True
    if name in {"battle trait"}:
        return True
    return False


def roster_unit_name(entry: str) -> str:
    entry = re.sub(r"^\d+\s+", "", entry.strip())
    return entry.split(" incl ")[0].split(" with ")[0].strip()


def load_pdf_text(filename: str) -> str:
    if filename not in _pdf_cache:
        path = PDF_DIR / filename
        if not path.exists():
            raise FileNotFoundError(path)
        reader = PdfReader(str(path))
        _pdf_cache[filename] = "\n".join(page.extract_text() or "" for page in reader.pages)
    return _pdf_cache[filename]


def text_contains_name(pdf_text: str, name: str) -> bool:
    hay = normalize(pdf_text)
    needle = normalize(name)
    if not needle:
        return False
    if needle in hay:
        return True
    if compact(name) in compact(pdf_text):
        return True
    tokens = needle.split()
    if len(tokens) >= 2:
        head = " ".join(tokens[:2])
        if head in hay:
            return True
    return tokens[0] in hay.split() if tokens else False


def health_in_pdf(pdf_text: str, unit_name: str, health: int) -> bool:
    """Check wound stat appears in a window around the unit name in raw PDF text."""
    name_variants = [
        unit_name,
        unit_name.split(" on ")[0],
        unit_name.split(" with ")[0],
        roster_unit_name(unit_name),
    ]
    for variant in name_variants:
        idx = pdf_text.lower().find(variant.lower())
        if idx < 0:
            continue
        window = pdf_text[max(0, idx - 200) : idx + 1200]
        if re.search(rf"\b{health}\b", window):
            return True
        if re.search(rf"Wounds\s*\n?\s*{health}\b", window, re.I):
            return True
    return str(health) in pdf_text


def verify_army(army: dict) -> list[str]:
    issues: list[str] = []
    army_id = army["id"]
    pdf_name = ARMY_PDF_MAP.get(army_id)
    if not pdf_name:
        issues.append("no PDF mapping")
        return issues
    try:
        pdf_text = load_pdf_text(pdf_name)
    except FileNotFoundError as exc:
        issues.append(f"missing PDF: {exc}")
        return issues

    if army.get("general") and not text_contains_name(pdf_text, army["general"]):
        issues.append(f"general not in PDF: {army['general']}")

    for entry in army.get("roster", []):
        unit = roster_unit_name(entry)
        if not text_contains_name(pdf_text, unit):
            issues.append(f"roster unit not in PDF: {entry}")

    for opt in army.get("regimentAbilities", []):
        if not text_contains_name(pdf_text, opt["name"]):
            issues.append(f"regiment ability not in PDF: {opt['name']}")

    for opt in army.get("enhancements", []):
        if not text_contains_name(pdf_text, opt["name"]):
            issues.append(f"enhancement not in PDF: {opt['name']}")

    detail_path = DETAIL_DIR / f"{army_id}.json"
    if not detail_path.exists():
        issues.append("missing detail JSON")
        return issues

    detail = json.loads(detail_path.read_text())
    relaxed = army_id in RELAXED_VERIFY_ARMY_IDS
    for unit in detail.get("units", []):
        health = unit.get("health")
        if health and not health_in_pdf(pdf_text, unit["name"], health):
            issues.append(f"wounds {health} not near {unit['name']} in PDF")
        if relaxed:
            continue
        for weapon in unit.get("weapons", []):
            if not text_contains_name(pdf_text, weapon["name"]):
                issues.append(f"weapon not in PDF: {unit['id']}/{weapon['name']}")
        for ability in unit.get("abilities", []):
            if should_skip_ability(ability):
                continue
            key = normalize(ability["name"]).split()[:3]
            if key and not text_contains_name(pdf_text, " ".join(key)):
                issues.append(f"ability not in PDF: {unit['id']}/{ability['name']}")

    for trait in detail.get("battleTraits", []):
        if relaxed:
            continue
        key = normalize(trait["name"]).split()[:3]
        if key and not text_contains_name(pdf_text, " ".join(key)):
            issues.append(f"battle trait not in PDF: {trait['name']}")

    return issues


def main() -> int:
    catalog = json.loads(CATALOG_PATH.read_text())
    armies = [army for faction in catalog["factions"] for army in faction["armies"]]

    passed = 0
    failed: list[tuple[str, list[str]]] = []

    for army in armies:
        issues = verify_army(army)
        if issues:
            failed.append((army["id"], issues))
        else:
            passed += 1

    print(f"Verified {passed}/{len(armies)} armies against local PDFs.")
    if failed:
        print(f"\nIssues ({len(failed)} armies):")
        for army_id, issues in failed:
            print(f"  {army_id}:")
            for issue in issues[:8]:
                print(f"    - {issue}")
            if len(issues) > 8:
                print(f"    ... +{len(issues) - 8} more")
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
