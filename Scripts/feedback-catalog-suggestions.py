#!/usr/bin/env python3
"""Turn Tabletome feedback email text into draft catalog JSON rows.

Paste the email body (from Settings → Suggest something) on stdin or pass a file path.
Outputs JSON objects you can merge into:
  Resources/Catalogs/paint_swatch_catalog.json
  Resources/Catalogs/basing_material_catalog.json

Usage:
  pbpaste | python3 Scripts/feedback-catalog-suggestions.py
  python3 Scripts/feedback-catalog-suggestions.py path/to/email.txt
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

PAINT_TYPES = {
    "base", "layer", "shade", "dry", "technical", "contrast", "medium", "primer",
    "speedpaint", "speedpaint metallic",
}


def read_input() -> str:
    if len(sys.argv) > 1:
        return Path(sys.argv[1]).read_text(encoding="utf-8")
    return sys.stdin.read()


def parse_email(text: str) -> dict[str, str]:
    fields: dict[str, str] = {}
    for line in text.splitlines():
        if ":" not in line:
            continue
        key, _, value = line.partition(":")
        key = key.strip().lower()
        value = value.strip()
        if key in {"category", "summary"} or key.endswith(" name") or key in {
            "paint name", "product name", "army or faction", "game or format",
            "rule, card, or unit", "where in the app", "area of the app", "topic",
        }:
            fields[key] = value
    return fields


def guess_brand(details: str, name: str) -> str:
    blob = f"{details} {name}".lower()
    if "army painter" in blob:
        return "Army Painter"
    if "citadel" in blob or "games workshop" in blob:
        return "Citadel"
    if "vallejo" in blob:
        return "Vallejo"
    if "woodland scenics" in blob:
        return "Woodland Scenics"
    if "geek gaming" in blob:
        return "Geek Gaming"
    if "ak interactive" in blob:
        return "AK Interactive"
    return ""


def guess_hex(details: str) -> str | None:
    match = re.search(r"#([0-9a-fA-F]{3,8})\b", details)
    if not match:
        return None
    hex_val = match.group(0)
    return hex_val if hex_val.startswith("#") else f"#{hex_val}"


def guess_type(category: str, details: str) -> str:
    blob = f"{category} {details}".lower()
    if "basing" in category or "tuft" in blob or "static grass" in blob or "texture paste" in blob:
        return "Basing"
    for paint_type in sorted(PAINT_TYPES, key=len, reverse=True):
        if paint_type in blob:
            return paint_type.title().replace("Speedpaint Metallic", "Speedpaint Metallic")
    if "primer" in blob or "spray" in blob:
        return "Primer"
    if "shade" in blob or "wash" in blob:
        return "Shade"
    if "contrast" in blob:
        return "Contrast"
    return "Base"


def guess_basing_category(details: str) -> str:
    blob = details.lower()
    if "tuft" in blob:
        return "Tuft"
    if "static grass" in blob or "turf" in blob or "flock" in blob:
        return "Static Grass"
    if "snow" in blob:
        return "Snow Flock"
    if "texture gel" in blob:
        return "Texture Gel"
    if "texture" in blob or "paste" in blob:
        return "Texture Paste"
    if "glue" in blob:
        return "Glue"
    if "baseline" in blob:
        return "Baseline Gel"
    return "Basing"


def main() -> None:
    text = read_input()
    fields = parse_email(text)
    category = fields.get("category", "").lower()
    name = next(
        (v for k, v in fields.items() if k.endswith(" name") or k in {"topic"} and v),
        fields.get("summary", "").strip(),
    )
    if not name:
        print("Could not find a paint/product name in the email.", file=sys.stderr)
        sys.exit(1)

    details = ""
    if "details:" in text.lower():
        details = text.split("Details:", 1)[-1].split("---", 1)[0].strip()
    summary = fields.get("summary", "")
    brand = guess_brand(details, name)
    hex_val = guess_hex(details) or "#888888"

    if "basing" in category or "basing material" in category:
        row = {
            "name": name,
            "brand": brand or "Army Painter",
            "category": guess_basing_category(f"{details} {summary}"),
            "hex": hex_val,
        }
        if "battlefield" in details.lower() or "army painter" in details.lower():
            row["line"] = "Battlefields"
        print(json.dumps({"target": "basing_material_catalog.json", "material": row}, indent=2))
    elif "paint" in category or "colour" in category or "color" in category:
        paint_type = guess_type(category, f"{details} {summary}")
        row = {
            "name": name,
            "brand": brand or "Citadel",
            "type": paint_type,
            "hex": hex_val,
        }
        print(json.dumps({"target": "paint_swatch_catalog.json", "paint": row}, indent=2))
    else:
        print(
            json.dumps(
                {
                    "note": "Not a paint/basing category — no catalog row generated.",
                    "category": category,
                    "name": name,
                    "summary": summary,
                },
                indent=2,
            )
        )


if __name__ == "__main__":
    main()
