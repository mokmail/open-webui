#!/usr/bin/env python3
"""
Seed the Open WebUI database with BEV-themed prompt suggestions.

This script reads the branding JSON file and seeds the database directly,
bypassing the API. Run once after deployment or after an update that may
have overwritten config.py.

Usage:
    python scripts/seed_bev_suggestions.py

Requires:
    - python-docx (for reading .docx source)
    - The Open WebUI backend to have been started at least once (so DB exists)
"""

import json
import sys
from pathlib import Path

OPEN_WEBUI_DIR = Path(__file__).resolve().parent.parent
BACKEND_DIR = OPEN_WEBUI_DIR / "backend"
BRANDING_FILE = (
    OPEN_WEBUI_DIR / "branding" / "backend" / "bev_prompt_suggestions.json"
)

sys.path.insert(0, str(BACKEND_DIR))

from open_webui.internal.config import STATE


def load_branding_suggestions():
    if not BRANDING_FILE.exists():
        print(f"Branding file not found: {BRANDING_FILE}")
        return None
    with open(BRANDING_FILE) as f:
        data = json.load(f)
    if not data:
        print("Branding file is empty")
        return None
    return data


def seed():
    suggestions = load_branding_suggestions()
    if suggestions is None:
        print("No suggestions to seed. Exiting.")
        sys.exit(1)

    STATE.load()
    STATE.write("ui.prompt_suggestions", suggestions)
    STATE.persist()
    print(f"Seeded {len(suggestions)} BEV prompt suggestions to database.")
    print(f"Path: ui.prompt_suggestions")


if __name__ == "__main__":
    seed()
