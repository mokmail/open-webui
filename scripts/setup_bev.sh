#!/bin/bash
# BEV Open WebUI Setup Script
# 
# Hardens the deployment so BEV customizations survive:
#   - git pull (updates)
#   - DB deletion / reset
#   - container rebuilds
#
# Usage:
#   bash scripts/setup_bev.sh
#
# What it does:
#   1. Creates .env with DEFAULT_PROMPT_SUGGESTIONS (belt-and-suspenders)
#   2. Marks config.py as "assume-unchanged" so git pull won't overwrite it
#   3. Installs a post-merge git hook to re-apply config.py patch after pulls

set -euo pipefail
cd "$(git rev-parse --show-toplevel 2>/dev/null || echo "$(dirname "$0")/..")"

echo "=== BEV Open WebUI Setup ==="

# ── 1. Create .env with DEFAULT_PROMPT_SUGGESTIONS ──────────────────────────
ENV_FILE=".env"
JSON_FILE="branding/backend/bev_prompt_suggestions.json"

if [ ! -f "$JSON_FILE" ]; then
    echo "ERROR: $JSON_FILE not found. Run from project root."
    exit 1
fi

# Load existing .env or create new one
if [ -f "$ENV_FILE" ] && grep -q '^DEFAULT_PROMPT_SUGGESTIONS=' "$ENV_FILE"; then
    echo "[SKIP] $ENV_FILE already has DEFAULT_PROMPT_SUGGESTIONS"
else
    echo "Writing DEFAULT_PROMPT_SUGGESTIONS to $ENV_FILE ..."
    # Build the env var value from the JSON file (single line for dotenv compat)
    SUGGESTIONS=$(python3 -c "
import json
with open('$JSON_FILE') as f:
    print(json.dumps(json.load(f), ensure_ascii=False))
")
    echo "DEFAULT_PROMPT_SUGGESTIONS=$SUGGESTIONS" >> "$ENV_FILE"
    echo "[OK]   $ENV_FILE updated"
fi

# ── 2. Protect config.py from git pull overwrites ────────────────────────────
CONFIG_PY="backend/open_webui/config.py"
if git ls-files --error-unmatch "$CONFIG_PY" &>/dev/null; then
    if git diff --quiet "$CONFIG_PY"; then
        echo "[SKIP] config.py has no local changes (nothing to protect)"
    else
        git update-index --assume-unchanged "$CONFIG_PY"
        echo "[OK]   config.py marked --assume-unchanged (git pull won't touch it)"
    fi
else
    echo "[SKIP] config.py not tracked by git"
fi

# ── 3. Install post-merge hook to re-apply branding patch after pulls ────────
HOOK=".git/hooks/post-merge"
if [ -f "$HOOK" ]; then
    echo "[SKIP] post-merge hook already exists at $HOOK"
else
    cat > "$HOOK" << 'HOOKEOF'
#!/bin/bash
# Auto-re-apply BEV branding patch after git pull
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

BRANDING_FILE="branding/backend/bev_prompt_suggestions.json"
CONFIG_PY="backend/open_webui/config.py"

# Only act if the branding file exists (BEV deployment)
if [ ! -f "$BRANDING_FILE" ]; then
    exit 0
fi

# Re-mark config.py as assume-unchanged (git pull may have reset it)
if git ls-files --error-unmatch "$CONFIG_PY" &>/dev/null; then
    git update-index --assume-unchanged "$CONFIG_PY" 2>/dev/null || true
fi

# If .env was reset, re-add DEFAULT_PROMPT_SUGGESTIONS
ENV_FILE=".env"
if [ -f "$ENV_FILE" ] && ! grep -q '^DEFAULT_PROMPT_SUGGESTIONS=' "$ENV_FILE" 2>/dev/null; then
    SUGGESTIONS=$(python3 -c "
import json
with open('$BRANDING_FILE') as f:
    print(json.dumps(json.load(f), ensure_ascii=False))
" 2>/dev/null)
    if [ -n "$SUGGESTIONS" ]; then
        echo "DEFAULT_PROMPT_SUGGESTIONS=$SUGGESTIONS" >> "$ENV_FILE"
    fi
fi
HOOKEOF
    chmod +x "$HOOK"
    echo "[OK]   post-merge git hook installed at $HOOK"
fi

echo ""
echo "=== Setup complete ==="
echo ""
echo "Summary of protection layers:"
echo "  1. config.py     ← --assume-unchanged + post-merge hook"
echo "  2. .env          ← DEFAULT_PROMPT_SUGGESTIONS env var"
echo "  3. DB            ← PersistentConfig (auto-seeded on first start)"
echo ""
echo "All 3 layers must fail before the default English suggestions appear."
