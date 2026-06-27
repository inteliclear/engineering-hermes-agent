#!/usr/bin/env bash
# Smoke-test all LiteLLM model aliases used by Hermes.
# Usage: ./scripts/test-aliases.sh [--verbose]
#
# Reads HERMES_API_BASE and HERMES_API_KEY from .env or shell environment.
set -euo pipefail

VERBOSE=false
for arg in "$@"; do
  case "$arg" in
    --verbose) VERBOSE=true ;;
  esac
done

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Source .env if available
if [[ -f "$REPO_DIR/.env" ]]; then
  # shellcheck disable=SC1090
  source "$REPO_DIR/.env"
fi

: "${HERMES_API_BASE:?HERMES_API_BASE missing (set in .env or shell)}"
: "${HERMES_API_KEY:?HERMES_API_KEY missing (set in .env or shell)}"

OK_COUNT=0
FAIL_COUNT=0
TOTAL=0

test_alias() {
  local model_name="$1"
  local tmp
  tmp=$(mktemp)
  TOTAL=$((TOTAL + 1))

  local start end ms
  start=$(date +%s%N 2>/dev/null || echo 0)
  local status
  status=$(curl -s -o "$tmp" -w "%{http_code}" \
    -X POST "${HERMES_API_BASE}/chat/completions" \
    -H "Authorization: Bearer ${HERMES_API_KEY}" \
    -H "Content-Type: application/json" \
    -d "{\"model\":\"${model_name}\",\"max_tokens\":5,\"messages\":[{\"role\":\"user\",\"content\":\"Hello\"}]}")
  end=$(date +%s%N 2>/dev/null || echo 0)
  ms=$(( (end - start) / 1000000 ))

  local resolved="unknown"
  if command -v python3 &>/dev/null; then
    resolved=$(python3 -c "import json; print(json.load(open('$tmp')).get('model','unknown'))" 2>/dev/null || echo "unknown")
  fi
  rm -f "$tmp"

  if [[ "$status" == "200" ]]; then
    OK_COUNT=$((OK_COUNT + 1))
    printf "  OK    %s  (HTTP %s, %sms, resolved: %s)\n" "$model_name" "$status" "$ms" "$resolved"
  else
    FAIL_COUNT=$((FAIL_COUNT + 1))
    printf "  FAIL  %s  (HTTP %s, %sms, resolved: %s)\n" "$model_name" "$status" "$ms" "$resolved"
  fi

  if "$VERBOSE"; then
    printf "    base_url: %s\n" "${HERMES_API_BASE}"
    printf "    model: %s\n" "$model_name"
  fi
}

echo "Testing all model aliases against ${HERMES_API_BASE}"
echo "===================================================="

for model_name in reasoning coding smart fast coder coder_pro; do
  test_alias "$model_name"
done

echo "===================================================="
printf "Results: %d passed, %d failed (of %d)\n" "$OK_COUNT" "$FAIL_COUNT" "$TOTAL"

if [[ $FAIL_COUNT -gt 0 ]]; then
  exit 1
fi
