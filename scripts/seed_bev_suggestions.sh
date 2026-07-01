#!/bin/bash
# Seed BEV prompt suggestions into the Open WebUI database.
#
# Uses the admin API to set default prompt suggestions from the branding file.
# Run after deployment or after an update that may have overwritten config.py.
#
# Usage:
#   export OWUI_URL=http://localhost:3000
#   export OWUI_API_KEY=sk-...           # optional, if auth is enabled
#   bash scripts/seed_bev_suggestions.sh
#
# Without OWUI_URL, defaults to http://localhost:3000

set -euo pipefail

BASE_URL="${OWUI_URL:-http://localhost:3000}"
API_KEY="${OWUI_API_KEY:-}"
SUGGESTIONS_FILE="$(dirname "$0")/../branding/backend/bev_prompt_suggestions.json"

if [ ! -f "$SUGGESTIONS_FILE" ]; then
    echo "ERROR: Branding file not found: $SUGGESTIONS_FILE"
    echo "Make sure you're running this from the project root."
    exit 1
fi

AUTH_HEADER=""
if [ -n "$API_KEY" ]; then
    AUTH_HEADER="-H \"Authorization: Bearer $API_KEY\""
fi

echo "Seeding prompt suggestions from $SUGGESTIONS_FILE"
echo "Target: $BASE_URL/api/v1/configs/suggestions"

curl -s -X POST "$BASE_URL/api/v1/configs/suggestions" \
    -H "Content-Type: application/json" \
    $AUTH_HEADER \
    -d "$(cat "$SUGGESTIONS_FILE")"

echo ""
echo "Done."
