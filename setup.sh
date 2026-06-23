#!/usr/bin/env bash
# Bootstrap: install Hermes agent wired to the ICLR LiteLLM proxy.
# Usage: ./setup.sh [--dry-run] [--verbose]
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HERMES_HOME="${HERMES_HOME:-$HOME/.hermes}"

DRY_RUN=false
VERBOSE=false
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    --verbose) VERBOSE=true ;;
  esac
done

log()  { echo "[setup] $*"; }
ok()   { echo "[setup] OK $*"; }
warn() { echo "[setup] WARNING: $*" >&2; }
die()  { echo "[setup] ERROR: $*" >&2; exit 1; }

run() {
  if "$DRY_RUN"; then
    echo "[dry-run] $*"
  elif "$VERBOSE"; then
    "$@"
  else
    "$@" > /dev/null 2>&1
  fi
}

# --- Step 1: Prerequisites ---------------------------------------------------
log "Step 1/6: Checking prerequisites..."

for cmd in git curl; do
  command -v "$cmd" &>/dev/null || die "'$cmd' not found. Install it and re-run setup.sh."
done

if command -v python3 &>/dev/null; then
  PYV=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
  PMAJ=$(echo "$PYV" | cut -d. -f1); PMIN=$(echo "$PYV" | cut -d. -f2)
  if [[ "$PMAJ" -lt 3 || ( "$PMAJ" -eq 3 && "$PMIN" -lt 10 ) ]]; then
    warn "python3 $PYV found; 3.10+ recommended for the smoke test and Python example"
  fi
else
  warn "python3 not found — smoke-test JSON parsing and the Python example will be unavailable"
fi

command -v jq &>/dev/null || warn "'jq' not found — non-fatal"

ok "Prerequisites satisfied"

# --- Step 2: Hermes install --------------------------------------------------
log "Step 2/6: Installing Hermes..."

if command -v hermes &>/dev/null; then
  ok "Hermes already installed ($(hermes --version 2>/dev/null || echo 'version unknown')) — run 'hermes update' to upgrade"
else
  if "$DRY_RUN"; then
    echo "[dry-run] curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash"
  else
    log "Running official Hermes installer (brings its own Python, Node, ripgrep, ffmpeg)..."
    curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash
    command -v hermes &>/dev/null || die "Hermes install finished but 'hermes' is not on PATH. Open a new shell (or add ~/.local/bin to PATH) and re-run setup.sh."
  fi
fi

if ! "$DRY_RUN"; then
  ok "Hermes ready: $(hermes --version 2>/dev/null || echo 'installed')"
fi

# --- Step 3: Config wiring ---------------------------------------------------
log "Step 3/6: Wiring config..."

ENV_FILE="$REPO_DIR/.env"
[[ -f "$ENV_FILE" ]] || run cp "$REPO_DIR/.env.example" "$ENV_FILE"

# Resolve HERMES_API_KEY: shell env > repo .env > prompt
if [[ -z "${HERMES_API_KEY:-}" ]]; then
  if grep -q "^HERMES_API_KEY=<" "$ENV_FILE" 2>/dev/null; then
    if "$DRY_RUN"; then
      echo "[dry-run] Would prompt for HERMES_API_KEY"
    else
      echo "Get your key: kubectl get secret litellm-secret -n litellm -o jsonpath='{.data.LITELLM_MASTER_KEY}' | base64 -d"
      read -rsp "Enter LiteLLM master key: " ENTERED; echo
      # Rewrite the line safely without regex interpretation of the value.
      ENTERED="$ENTERED" awk '
        /^HERMES_API_KEY=/ { print "HERMES_API_KEY=" ENVIRON["ENTERED"]; next }
        { print }
      ' "$ENV_FILE" > "$ENV_FILE.tmp" && mv "$ENV_FILE.tmp" "$ENV_FILE"
    fi
  fi
fi

if ! "$DRY_RUN"; then
  chmod 600 "$ENV_FILE"
  # shellcheck source=/dev/null
  source "$ENV_FILE"
  : "${HERMES_API_BASE:?HERMES_API_BASE missing from .env}"
  : "${HERMES_API_KEY:?HERMES_API_KEY missing from .env}"
  HERMES_MODEL_ALIAS="${HERMES_MODEL_ALIAS:-reasoning}"

  mkdir -p "$HERMES_HOME"

  # Model config via the official CLI (writes ~/.hermes/config.yaml).
  hermes config set model.provider custom
  hermes config set model.base_url "$HERMES_API_BASE"
  hermes config set model.default "$HERMES_MODEL_ALIAS"

  # Secret goes in ~/.hermes/.env — direct write, no regex.
  HERMES_DOTENV="$HERMES_HOME/.env"
  if [[ -f "$HERMES_DOTENV" ]] && grep -q "^OPENAI_API_KEY=" "$HERMES_DOTENV"; then
    OPENAI_API_KEY="$HERMES_API_KEY" awk '
      /^OPENAI_API_KEY=/ { print "OPENAI_API_KEY=" ENVIRON["OPENAI_API_KEY"]; next }
      { print }
    ' "$HERMES_DOTENV" > "$HERMES_DOTENV.tmp" && mv "$HERMES_DOTENV.tmp" "$HERMES_DOTENV"
  else
    printf 'OPENAI_API_KEY=%s\n' "$HERMES_API_KEY" >> "$HERMES_DOTENV"
  fi

  # web_extract backend (issue #13): self-hosted Firecrawl (LAN-only, no key).
  # SearXNG covers web_search but cannot fetch page content; Firecrawl does.
  # The instance is unauthenticated and internal, so only a URL is needed.
  HERMES_FIRECRAWL_URL="${HERMES_FIRECRAWL_URL:-https://firecrawl.inteliclear.io}"
  hermes config set web.extract_backend firecrawl
  if grep -q "^FIRECRAWL_API_URL=" "$HERMES_DOTENV"; then
    FIRECRAWL_API_URL="$HERMES_FIRECRAWL_URL" awk '
      /^FIRECRAWL_API_URL=/ { print "FIRECRAWL_API_URL=" ENVIRON["FIRECRAWL_API_URL"]; next }
      { print }
    ' "$HERMES_DOTENV" > "$HERMES_DOTENV.tmp" && mv "$HERMES_DOTENV.tmp" "$HERMES_DOTENV"
  else
    printf 'FIRECRAWL_API_URL=%s\n' "$HERMES_FIRECRAWL_URL" >> "$HERMES_DOTENV"
  fi
  chmod 600 "$HERMES_DOTENV"
else
  echo "[dry-run] hermes config set model.provider custom"
  echo "[dry-run] hermes config set model.base_url \$HERMES_API_BASE"
  echo "[dry-run] hermes config set model.default \$HERMES_MODEL_ALIAS"
  echo "[dry-run] write OPENAI_API_KEY to $HERMES_HOME/.env"
  echo "[dry-run] hermes config set web.extract_backend firecrawl"
  echo "[dry-run] write FIRECRAWL_API_URL to $HERMES_HOME/.env"
fi

ok "Config wired (model.* in config.yaml, OPENAI_API_KEY in ~/.hermes/.env)"
ok "web_extract backend: firecrawl (${HERMES_FIRECRAWL_URL:-https://firecrawl.inteliclear.io})"

# --- Step 4: Memory seeding --------------------------------------------------
log "Step 4/6: Seeding memory..."

MEM="$HERMES_HOME/memories"
run mkdir -p "$MEM"
run cp "$REPO_DIR/memory/MEMORY.md" "$MEM/MEMORY.md"
run cp "$REPO_DIR/memory/USER.md"   "$MEM/USER.md"

ok "Memory seeded to $MEM"
log "  -> Open $MEM/USER.md and fill in your name and role"

# --- Step 5: Skills install --------------------------------------------------
log "Step 5/6: Installing skills..."

SKILLS_DIR="$HERMES_HOME/skills"
run mkdir -p "$SKILLS_DIR"
LINK="$SKILLS_DIR/iclr"

if "$DRY_RUN"; then
  echo "[dry-run] ln -sfn $REPO_DIR/skills $LINK"
else
  [[ -L "$LINK" || -e "$LINK" ]] && rm -rf "$LINK"
  if ln -s "$REPO_DIR/skills" "$LINK" 2>/dev/null; then
    ok "Skills symlinked: $LINK -> $REPO_DIR/skills"
  else
    warn "Symlink failed — copying instead (skills won't auto-update on git pull)"
    cp -r "$REPO_DIR/skills" "$LINK"
    ok "Skills copied to $LINK"
  fi
fi

# --- Step 6: Smoke test ------------------------------------------------------
log "Step 6/6: Running smoke test..."

if "$DRY_RUN"; then
  echo "[dry-run] POST \$HERMES_API_BASE/chat/completions with Bearer token"
else
  mkdir -p "$REPO_DIR/logs"
  LOG="$REPO_DIR/logs/smoke-test.log"
  TMP=$(mktemp)

  START=$(date +%s%N 2>/dev/null || echo 0)
  STATUS=$(curl -s -o "$TMP" -w "%{http_code}" \
    -X POST "$HERMES_API_BASE/chat/completions" \
    -H "Authorization: Bearer $HERMES_API_KEY" \
    -H "Content-Type: application/json" \
    -d "{\"model\":\"$HERMES_MODEL_ALIAS\",\"max_tokens\":10,\"messages\":[{\"role\":\"user\",\"content\":\"What is the capital of France?\"}]}" )
  END=$(date +%s%N 2>/dev/null || echo 0)
  MS=$(( (END - START) / 1000000 ))

  if command -v python3 &>/dev/null; then
    RESOLVED=$(python3 -c "import json; print(json.load(open('$TMP')).get('model','unknown'))" 2>/dev/null || echo "unknown")
  else
    RESOLVED="unknown (python3 not available)"
  fi
  rm -f "$TMP"

  {
    echo "=== Smoke test $(date -Iseconds) ==="
    echo "HTTP status:    $STATUS"
    echo "Latency:        ${MS}ms"
    echo "Resolved model: $RESOLVED"
    echo "Alias used:     $HERMES_MODEL_ALIAS"
  } | tee -a "$LOG"

  [[ "$STATUS" == "200" ]] || die "Smoke test failed (HTTP $STATUS). Check the key and proxy: kubectl -n litellm rollout status deploy/litellm"
  ok "Smoke test passed (HTTP $STATUS, ${MS}ms, model: $RESOLVED)"
fi

echo
log "Setup complete. Next steps:"
log "  1. Fill in $HERMES_HOME/memories/USER.md"
log "  2. Run: hermes"
