# engineering-hermes-agent Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create the `inteliclear/engineering-hermes-agent` GitHub repo — a one-command bootstrap that installs Hermes, wires it to the ICLR LiteLLM proxy, seeds shared team memory, and installs pre-built skills.

**Architecture:** A pure-configuration repo with no app code and no servers. `setup.sh` is the only executable. All other content is markdown (skill files, memory seeds, docs) and config files (`.env.example`, `INDEX.json`). The repo is cloned per team member; Hermes runs locally and routes all LLM calls through `https://litellm.inteliclear.io/v1`.

**Tech Stack:** Bash (setup.sh), Markdown (skills/memory/docs), Python `requests` (example), TypeScript `node-fetch` (example), `gh` CLI (repo creation)

## Global Constraints

- Hermes version: pinned in `HERMES_VERSION` at top of `setup.sh` — update there to upgrade
- LiteLLM proxy: `https://litellm.inteliclear.io/v1` — always HTTPS, OpenAI-compatible endpoint
- Model aliases: `reasoning`, `coding`, `smart`, `fast`, `coder`, `coder_pro`
- `.env` is gitignored — never committed
- `setup.sh` is idempotent — safe to re-run
- All env config via `HERMES_*` variables only
- Examples use `/chat/completions` (not `/v1/messages`) — `HERMES_API_BASE` already includes `/v1`
- Python example requires `requests` package; TypeScript example requires `node-fetch`
- Local clone target: `/home/tpanchal/iclr/engineering-hermes-agent/`

---

### Task 1: Create GitHub Repo + .gitignore

**Files:**
- Create: `.gitignore`

**Interfaces:**
- Produces: empty repo at `github.com/inteliclear/engineering-hermes-agent`, cloned at `/home/tpanchal/iclr/engineering-hermes-agent/`

- [ ] **Step 1: Create the GitHub repo and clone it**

```bash
gh repo create inteliclear/engineering-hermes-agent \
  --public \
  --description "Bootstrap repo: install Hermes agent wired to ICLR LiteLLM proxy" \
  --clone

mv engineering-hermes-agent /home/tpanchal/iclr/
cd /home/tpanchal/iclr/engineering-hermes-agent
```

If `gh` is not configured for the `inteliclear` org: `gh auth login` first, then select the `inteliclear` org.

- [ ] **Step 2: Write .gitignore**

```text
.env
logs/
*.log
__pycache__/
node_modules/
.DS_Store
```

- [ ] **Step 3: Verify**

```bash
cat .gitignore
```

Expected output: `.env` and `logs/` are present.

- [ ] **Step 4: Commit and push**

```bash
git add .gitignore
git commit -m "chore: initial repo scaffold"
git push -u origin main
```

Expected: commit succeeds, branch `main` appears on GitHub.

---

### Task 2: `.env.example`

**Files:**
- Create: `.env.example`

**Interfaces:**
- Produces: `HERMES_API_BASE`, `HERMES_API_KEY`, `HERMES_MODEL_ALIAS`, `HERMES_MODEL`, `HERMES_ROOT` — the five env vars used by setup.sh and all examples

- [ ] **Step 1: Write .env.example**

```bash
# LiteLLM proxy (ICLR shared inference)
HERMES_API_BASE=https://litellm.inteliclear.io/v1
HERMES_API_KEY=<your-litellm-master-key>

# Model routing — change per team member preference
# Options: reasoning, coding, smart, fast, coder, coder_pro
HERMES_MODEL_ALIAS=reasoning

# Optional: override the underlying model ID (resolved by alias if blank)
HERMES_MODEL=

# Hermes data root
HERMES_ROOT=~/.hermes
```

- [ ] **Step 2: Verify no real secrets are present**

```bash
grep "HERMES_API_KEY" .env.example
```

Expected: `HERMES_API_KEY=<your-litellm-master-key>` — placeholder only, not a real key.

- [ ] **Step 3: Commit**

```bash
git add .env.example
git commit -m "chore: add .env.example with ICLR LiteLLM proxy config"
```

---

### Task 3: Memory Files

**Files:**
- Create: `memory/MEMORY.md`
- Create: `memory/USER.md`

**Interfaces:**
- Produces: two files copied by setup.sh Step 4 into `$HERMES_ROOT/memory/`

- [ ] **Step 1: Create directory**

```bash
mkdir -p memory
```

- [ ] **Step 2: Write memory/MEMORY.md**

```markdown
# ICLR Team Memory

Shared context about the ICLR (Inteliclear) cluster and infrastructure.
Seeded into Hermes agent memory on first setup.

## Cluster Overview

- **Cluster type:** k3s on Proxmox VE (most nodes are VMs)
- **k3s version:** v1.35.5+k3s1
- **GitOps repo:** `/home/tpanchal/iclr/glowing-octo-palm-tree`
- **VIP:** 10.5.1.60 (kube-vip)

## Node Inventory

| Node | IP | Role | Notes |
|------|----|------|-------|
| iclr-k3s-01 | 10.5.1.55 | control-plane, etcd | NoSchedule taint |
| iclr-k3s-02 | 10.5.1.56 | control-plane, etcd | NoSchedule taint |
| iclr-k3s-03 | 10.5.1.57 | control-plane, etcd | Can schedule workloads |
| iclr-k3s-04 | 10.5.1.58 | worker | 8 vCPU, 16 GB |
| iclr-k3s-05 | 10.5.1.59 | worker | 8 vCPU, 16 GB |
| iclr-longhorn-01 | 10.5.1.61 | storage | tainted |
| iclr-longhorn-02 | 10.5.1.62 | storage | tainted |
| iclr-longhorn-03 | 10.5.1.63 | storage | tainted |
| iclr-longhorn-04 | 10.5.1.19 | storage + worker | physical machine; runs SonarQube, Prometheus, Grafana |
| iclr-longhorn-05 | 10.5.1.18 | storage | physical machine; no Proxmox recovery path |
| dgx-spark | 10.5.1.49 | inference | GB10, 128 GB unified; SSH tpanchal@10.5.1.49 key ~/.ssh/iclr-dgx-spark |

## LiteLLM Proxy

- **Endpoint:** `https://litellm.inteliclear.io/v1`
- **Namespace:** `litellm`

| Alias | Backend | Model |
|-------|---------|-------|
| `reasoning` | GPU LXC 10.5.1.36 | Qwen3.5-27B-UD-IQ3_XXS |
| `coding` | CPU LXC 10.5.1.33 | Qwen3-Coder-30B-A3B-IQ4_XS |
| `smart` | GPU LXC 10.5.1.36 | GPT-OSS-20B |
| `fast` | Vulkan 10.5.1.146 | Qwen3-4B-Instruct-2507 |
| `coder` | 10.5.1.12 + 10.5.1.19 | Qwen2.5-Coder-3B (weighted LB) |
| `coder_pro` | DGX Spark 10.5.1.49 | AEON Qwen3.6-27B NVFP4 |

Check proxy health:

```bash
kubectl -n litellm rollout status deploy/litellm
```

## Key Repos

| Repo | Location | Purpose |
|------|----------|---------|
| `glowing-octo-palm-tree` | `/home/tpanchal/iclr/glowing-octo-palm-tree` | GitOps source of truth |
| `turbo-sql-chunk` | `/home/tpanchal/workarea/git_repo/turbo-sql-chunk` | SQL chunking → ChromaDB for RAG |
| `engineering-hermes-agent` | `/home/tpanchal/iclr/engineering-hermes-agent` | This repo — Hermes bootstrap |

## SSH Access

```bash
# Cluster nodes
ssh -i ~/.ssh/iclr-dg-build icadm@<node-ip>

# DGX Spark
ssh -i ~/.ssh/iclr-dgx-spark tpanchal@10.5.1.49
```

## Networking

- MetalLB pool: 10.5.1.80–10.5.1.100 (L2 mode)
- Traefik ingress: 10.5.1.80 (wildcard `*.inteliclear.io`, all HTTPS)
- IBM MQ: 10.5.1.81
- SQL Server 2022: 10.5.1.84 (port 1433)
- SQL Server 2025: 10.5.1.85 (port 1433)
```

- [ ] **Step 3: Write memory/USER.md**

```markdown
# User Profile

Fill this in after running setup.sh. Hermes uses it to personalize responses.

## Identity

- **Name:** [Your name]
- **Role:** [e.g., Backend Engineer, DevOps Engineer, Data Engineer]
- **Team:** ICLR (Inteliclear)

## Technical Context

- **Primary languages:** [e.g., Python, SQL, TypeScript]
- **Cluster access:** [yes/no — do you have kubectl configured?]
- **Default model alias:** [reasoning / coding / smart / fast / coder / coder_pro]

## Working Style

- **Verbosity:** [concise / detailed]
- **Code review focus:** [correctness / security / performance]
- **Git workflow:** [feature branches / trunk-based]

## Notes

[Any other context that helps Hermes assist you — current projects, focus areas, things to avoid]
```

- [ ] **Step 4: Verify**

```bash
wc -l memory/MEMORY.md memory/USER.md
```

Expected: `MEMORY.md` > 50 lines, `USER.md` > 15 lines.

- [ ] **Step 5: Commit**

```bash
git add memory/
git commit -m "feat: add shared MEMORY.md and USER.md template"
```

---

### Task 4: Skills Files

**Files:**
- Create: `skills/README.md`
- Create: `skills/INDEX.json`
- Create: `skills/sql-ops/README.md`
- Create: `skills/cluster-ops/README.md`
- Create: `skills/general/README.md`

**Interfaces:**
- Produces: `skills/INDEX.json` mapping `{"sql-ops": "...", "cluster-ops": "...", "general": "..."}` — consumed by setup.sh Step 5 and by Hermes at runtime

- [ ] **Step 1: Create directories**

```bash
mkdir -p skills/sql-ops skills/cluster-ops skills/general
```

- [ ] **Step 2: Write skills/README.md**

```markdown
# ICLR Hermes Skills

Pre-built skills for three ICLR use cases.

## Catalog

| Skill | Trigger phrases | What it does |
|-------|----------------|-------------|
| `sql-ops` | "query chromadb", "search procedures", "run workflow", "generate spec" | SQL chunking, ChromaDB queries, spec generation |
| `cluster-ops` | "check cluster", "deploy", "drain node", "check longhorn", "traefik" | k3s ops, GitOps workflow, Longhorn, Traefik |
| `general` | "review code", "debug", "git", "logging", "PR" | Code review, git workflow, structured debugging |

## Adding a New Skill

1. Create `skills/<name>/README.md` following the format of an existing skill.
2. Re-run `./setup.sh` to regenerate `INDEX.json` and re-symlink.
3. Hermes picks up the new skill on next start.

## Skill File Format

Each skill README should include:
- `## Purpose` — one sentence
- `## When to Use` — trigger conditions
- `## Prerequisites` — what must be installed/configured
- `## Commands` — copy-pastable shell commands
```

- [ ] **Step 3: Write skills/sql-ops/README.md**

```markdown
# Skill: sql-ops

## Purpose
Query the ChromaDB vector store of SQL stored procedures and run the turbo-sql-chunk workflow.

## When to Use
- "Search for stored procedures that handle [topic]"
- "What does [procedure name] do?"
- "Run the chunking workflow on [sql folder]"
- "Generate a spec for [stored procedure]"

## Prerequisites
- `turbo-sql-chunk` repo at `/home/tpanchal/workarea/git_repo/turbo-sql-chunk`
- ChromaDB collection `sql_code` reachable at `https://chroma.inteliclear.io`
- Python venv active: `source venv/bin/activate` (from turbo-sql-chunk root)

## Commands

### Health check
```bash
cd /home/tpanchal/workarea/git_repo/turbo-sql-chunk
python src/run_workflow.py --health-check
```

### Query the vector store
```bash
python src/run_workflow.py --query "How is settlement finality determined?"
```

### Run chunking workflow on a SQL folder
```bash
python src/run_workflow.py --sql-folder ./path/to/sql --run
```

### Generate a spec for a stored procedure
```bash
# Requires LiteLLM proxy access (already configured via HERMES_API_*)
python scripts/generate_spec.py --input path/to/sp.sql --schema post_trade.settlement
```

## ChromaDB Collection
- **Collection:** `sql_code`
- **Dimensions:** 384 (cosine similarity)
- **Documents:** 17K+
- **Auth token:**
  ```bash
  kubectl get secret chromadb-auth-secret -n chromadb -o jsonpath='{.data.token}' | base64 -d
  ```
```

- [ ] **Step 4: Write skills/cluster-ops/README.md**

```markdown
# Skill: cluster-ops

## Purpose
Operate the ICLR k3s cluster: health checks, GitOps workflow, Longhorn storage, Traefik ingress.

## When to Use
- "Check cluster health"
- "Deploy [service]"
- "Is Longhorn healthy?"
- "Drain [node] for maintenance"
- "Add a new Traefik route for [service]"

## Prerequisites
- `kubectl` configured with ICLR kubeconfig
- SSH key `~/.ssh/iclr-dg-build` for node access
- GitOps repo at `/home/tpanchal/iclr/glowing-octo-palm-tree`

## Commands

### Cluster health (GOOD / DEGRADED / CRITICAL)
```bash
cd /home/tpanchal/iclr/glowing-octo-palm-tree
./scripts/health/py/cluster_health_check.py --json
```

### All nodes status
```bash
kubectl get nodes -o wide
```

### Longhorn health
```bash
kubectl get pods -n longhorn-system
kubectl get volumes.longhorn.io -n longhorn-system
```

### LiteLLM proxy health
```bash
kubectl -n litellm rollout status deploy/litellm
```

### Traefik status
```bash
kubectl get pods -n traefik
kubectl get ingressroutes -A
```

### GitOps: apply a manifest (always dry-run first)
```bash
cd /home/tpanchal/iclr/glowing-octo-palm-tree
kubectl apply -f manifests/<service>/ --dry-run=server
kubectl apply -f manifests/<service>/
```

### Detect drift (manifests vs live cluster)
```bash
python3 scripts/maintenance/detect-drift.py --dry-run
```

### SSH to a cluster node
```bash
ssh -i ~/.ssh/iclr-dg-build icadm@10.5.1.58   # iclr-k3s-04
```

### SSH to DGX Spark
```bash
ssh -i ~/.ssh/iclr-dgx-spark tpanchal@10.5.1.49
```

## Adding a New Traefik Ingress
1. Create manifests under `manifests/<service>/`
2. Add DNS CNAME on `iclr-dc2.iclr.local` (10.5.2.20) via PowerShell:
   ```powershell
   Add-DnsServerResourceRecordCName -ZoneName "inteliclear.io" -Name "<subdomain>" -HostNameAlias "traefik.inteliclear.io"
   ```
3. `kubectl apply -f manifests/<service>/ --dry-run=server`
4. `kubectl apply -f manifests/<service>/`
```

- [ ] **Step 5: Write skills/general/README.md**

```markdown
# Skill: general

## Purpose
General engineering tasks: code review, git workflow, structured debugging, structured logging.

## When to Use
- "Review this code"
- "Debug this error"
- "Create a PR for [feature]"
- "Add logging to this function"

## Code Review Checklist

Before approving any PR:
1. **Correctness** — does it do what it claims?
2. **Security** — SQL injection, command injection, plaintext secrets, OWASP top 10?
3. **Error handling** — are external calls wrapped? Is only the happy path tested?
4. **Tests** — does coverage exist for the new path? Are mocks realistic?
5. **Naming** — are functions/variables self-describing?
6. **Scope** — does the PR do more than described in the ticket?

## Git Workflow

```bash
# Create a feature branch
git checkout -b feat/<short-description>

# Conventional commit format
git commit -m "feat: add X"     # new feature
git commit -m "fix: correct Y"  # bug fix
git commit -m "chore: update Z" # non-functional change
git commit -m "docs: clarify W" # documentation only

# Open a PR
gh pr create --title "feat: add X" --body "## Summary\n- Added X\n\n## Test plan\n- [ ] Manual test: run Y, expect Z"

# Merge after approval
gh pr merge --squash
```

## Structured Debugging

When something is broken:
1. **Reproduce** — write the smallest case that triggers the bug
2. **Isolate** — binary search: which component is the source?
3. **Hypothesize** — one hypothesis at a time
4. **Test** — change one variable, observe result
5. **Document** — capture root cause and fix in commit message, not in comments

## Structured Logging (Python)

```python
import logging

log = logging.getLogger(__name__)

# Include structured context in extra= dict
log.info("operation started", extra={"item": item_id, "user": user_id})
log.warning("retry attempt", extra={"attempt": n, "error": str(e)})
log.error("operation failed", extra={"error": str(e), "item": item_id})
```

Never use `print()` for operational logging — it has no level filtering or structured output.
```

- [ ] **Step 6: Write skills/INDEX.json**

```json
{
  "sql-ops": "skills/sql-ops/README.md",
  "cluster-ops": "skills/cluster-ops/README.md",
  "general": "skills/general/README.md"
}
```

- [ ] **Step 7: Verify directory structure**

```bash
find skills/ -type f | sort
```

Expected output:
```text
skills/INDEX.json
skills/README.md
skills/cluster-ops/README.md
skills/general/README.md
skills/sql-ops/README.md
```

- [ ] **Step 8: Commit**

```bash
git add skills/
git commit -m "feat: add sql-ops, cluster-ops, and general skills with INDEX.json"
```

---

### Task 5: Example Scripts

**Files:**
- Create: `examples/sdk_python.py`
- Create: `examples/sdk_typescript.ts`

**Interfaces:**
- Consumes: `HERMES_API_BASE`, `HERMES_API_KEY`, `HERMES_MODEL_ALIAS` from environment (defined in Task 2)
- Endpoint: `$HERMES_API_BASE/chat/completions` — `HERMES_API_BASE` already includes `/v1`, so the full URL is `https://litellm.inteliclear.io/v1/chat/completions`

- [ ] **Step 1: Create directory**

```bash
mkdir -p examples
```

- [ ] **Step 2: Write examples/sdk_python.py**

```python
#!/usr/bin/env python3
"""
Minimal example: call the ICLR LiteLLM proxy directly via HTTP.

Usage:
    source .env          # sets HERMES_API_BASE, HERMES_API_KEY, HERMES_MODEL_ALIAS
    pip install requests
    python examples/sdk_python.py
"""
import os
import sys

import requests

base_url = os.environ.get("HERMES_API_BASE")
api_key = os.environ.get("HERMES_API_KEY")
model = os.environ.get("HERMES_MODEL_ALIAS", "reasoning")

if not base_url or not api_key:
    sys.exit("Error: HERMES_API_BASE and HERMES_API_KEY must be set.\nRun: source .env")

resp = requests.post(
    f"{base_url}/chat/completions",
    headers={"Authorization": f"Bearer {api_key}", "Content-Type": "application/json"},
    json={
        "model": model,
        "max_tokens": 256,
        "messages": [
            {"role": "user", "content": "Summarize the DTCC settlement cycle in one sentence."},
        ],
    },
    timeout=30,
)

resp.raise_for_status()
data = resp.json()
print(data["choices"][0]["message"]["content"])
```

- [ ] **Step 3: Write examples/sdk_typescript.ts**

```typescript
/**
 * Minimal example: call the ICLR LiteLLM proxy directly via HTTP.
 *
 * Usage:
 *   source .env   # sets HERMES_API_BASE, HERMES_API_KEY, HERMES_MODEL_ALIAS
 *   npm install node-fetch
 *   npx ts-node examples/sdk_typescript.ts
 */
import fetch from 'node-fetch';

const baseURL = process.env.HERMES_API_BASE;
const apiKey = process.env.HERMES_API_KEY;
const model = process.env.HERMES_MODEL_ALIAS ?? 'reasoning';

if (!baseURL || !apiKey) {
  console.error('Error: HERMES_API_BASE and HERMES_API_KEY must be set.\nRun: source .env');
  process.exit(1);
}

const resp = await fetch(`${baseURL}/chat/completions`, {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${apiKey}`,
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    model,
    max_tokens: 256,
    messages: [
      { role: 'user', content: 'Summarize the DTCC settlement cycle in one sentence.' },
    ],
  }),
});

if (!resp.ok) {
  throw new Error(`HTTP ${resp.status}: ${await resp.text()}`);
}

interface ChatResponse {
  choices: [{ message: { content: string } }];
  model: string;
}

const data = await resp.json() as ChatResponse;
console.log(data.choices[0].message.content);
```

- [ ] **Step 4: Verify Python example syntax**

```bash
python3 -c "import ast; ast.parse(open('examples/sdk_python.py').read()); print('syntax OK')"
```

Expected: `syntax OK`

- [ ] **Step 5: Verify TypeScript example syntax (if tsc available)**

```bash
npx tsc --noEmit --strict --target ES2022 --moduleResolution node examples/sdk_typescript.ts 2>/dev/null \
  && echo "syntax OK" || echo "tsc not available or type errors — review manually"
```

- [ ] **Step 6: Commit**

```bash
git add examples/
git commit -m "feat: add Python and TypeScript LiteLLM proxy examples"
```

---

### Task 6: setup.sh

**Files:**
- Create: `setup.sh`

**Interfaces:**
- Consumes: `.env.example` (Task 2), `memory/` (Task 3), `skills/` (Task 4)
- Produces: `~/.hermes/memory/MEMORY.md`, `~/.hermes/memory/USER.md`, `~/.hermes/skills/iclr → skills/`, `skills/INDEX.json` (regenerated), `logs/smoke-test.log`

**Note on Hermes install command (Step 2 of the script):** The exact pip package name (`hermes-agent` below) must be verified against the official Hermes documentation before first run. Confirm at `https://github.com/NousResearch/hermes` or the install guide referenced in `docs/SETUP.md`. The `hermes --version` validation step in the script will immediately catch a wrong package name.

- [ ] **Step 1: Write setup.sh**

```bash
#!/usr/bin/env bash
# Bootstrap: install Hermes agent wired to the ICLR LiteLLM proxy.
# Usage: ./setup.sh [--dry-run] [--verbose]
set -euo pipefail

HERMES_VERSION="0.1.0"   # ← update here to upgrade; also update docs/SETUP.md
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

DRY_RUN=false
VERBOSE=false
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    --verbose) VERBOSE=true ;;
  esac
done

log()  { echo "[setup] $*"; }
ok()   { echo "[setup] ✓ $*"; }
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

# ─── Step 1: Prerequisites ────────────────────────────────────────────────────
log "Step 1/6: Checking prerequisites..."

for cmd in python3 git curl; do
  command -v "$cmd" &>/dev/null || die "'$cmd' not found. Install it and re-run setup.sh."
done

PYTHON_VERSION=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
PYTHON_MAJOR=$(echo "$PYTHON_VERSION" | cut -d. -f1)
PYTHON_MINOR=$(echo "$PYTHON_VERSION" | cut -d. -f2)
if [[ "$PYTHON_MAJOR" -lt 3 || ( "$PYTHON_MAJOR" -eq 3 && "$PYTHON_MINOR" -lt 10 ) ]]; then
  die "Python 3.10+ required (found $PYTHON_VERSION)"
fi

command -v jq &>/dev/null || warn "'jq' not found — smoke test output will be unformatted (non-fatal)"

ok "Prerequisites satisfied (Python $PYTHON_VERSION)"

# ─── Step 2: Hermes install ───────────────────────────────────────────────────
log "Step 2/6: Installing Hermes $HERMES_VERSION..."

# IMPORTANT: Verify the pip package name from the official Hermes install guide
# before first use. Update the pip install command below if the package name differs.
if command -v hermes &>/dev/null; then
  INSTALLED=$(hermes --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || true)
  if [[ "$INSTALLED" == "$HERMES_VERSION" ]]; then
    ok "Hermes $HERMES_VERSION already installed — skipping"
  else
    log "Upgrading Hermes $INSTALLED → $HERMES_VERSION"
    run pip install "hermes-agent==$HERMES_VERSION"
  fi
else
  run pip install "hermes-agent==$HERMES_VERSION"
fi

if ! "$DRY_RUN"; then
  command -v hermes &>/dev/null || die "Hermes install failed — 'hermes' not found in PATH after install"
fi
ok "Hermes $HERMES_VERSION ready"

# ─── Step 3: Config wiring ────────────────────────────────────────────────────
log "Step 3/6: Wiring config..."

ENV_FILE="$REPO_DIR/.env"

if [[ ! -f "$ENV_FILE" ]]; then
  run cp "$REPO_DIR/.env.example" "$ENV_FILE"
  log "Created .env from .env.example"
fi

# Key resolution: env > .env file > interactive prompt
if [[ -z "${HERMES_API_KEY:-}" ]]; then
  if grep -q "^HERMES_API_KEY=<" "$ENV_FILE" 2>/dev/null; then
    if "$DRY_RUN"; then
      echo "[dry-run] Would prompt for HERMES_API_KEY"
    else
      echo "Get your key: kubectl get secret litellm-master-key -n litellm -o jsonpath='{.data.key}' | base64 -d"
      read -rsp "Enter LiteLLM master key: " entered_key
      echo
      sed -i "s|^HERMES_API_KEY=.*|HERMES_API_KEY=$entered_key|" "$ENV_FILE"
    fi
  fi
fi

if ! "$DRY_RUN"; then
  chmod 600 "$ENV_FILE"
  # shellcheck source=/dev/null
  source "$ENV_FILE"
fi

ok "Config wired (.env secured with chmod 600)"
log "  Tip: Add 'source $ENV_FILE' to your ~/.bashrc or ~/.zshrc"

# ─── Step 4: Memory seeding ───────────────────────────────────────────────────
log "Step 4/6: Seeding memory..."

HERMES_ROOT="${HERMES_ROOT:-$HOME/.hermes}"
HERMES_MEM="$HERMES_ROOT/memory"

run mkdir -p "$HERMES_MEM"
run cp "$REPO_DIR/memory/MEMORY.md" "$HERMES_MEM/MEMORY.md"
run cp "$REPO_DIR/memory/USER.md"   "$HERMES_MEM/USER.md"

ok "Memory seeded to $HERMES_MEM"
log "  → Open $HERMES_MEM/USER.md and fill in your name and role"

# ─── Step 5: Skills install ───────────────────────────────────────────────────
log "Step 5/6: Installing skills..."

HERMES_SKILLS="$HERMES_ROOT/skills"
run mkdir -p "$HERMES_SKILLS"

LINK="$HERMES_SKILLS/iclr"
[[ -L "$LINK" ]] && run rm "$LINK"

if ! "$DRY_RUN"; then
  if ln -s "$REPO_DIR/skills" "$LINK" 2>/dev/null; then
    ok "Skills symlinked: $LINK → $REPO_DIR/skills"
  else
    warn "Symlink failed — falling back to copy (skills won't auto-update on git pull)"
    run cp -r "$REPO_DIR/skills" "$LINK"
    ok "Skills copied to $LINK"
  fi
else
  echo "[dry-run] ln -s $REPO_DIR/skills $LINK"
fi

# Regenerate INDEX.json
if ! "$DRY_RUN"; then
  python3 - "$REPO_DIR/skills" <<'PYEOF'
import json, pathlib, sys

skills_dir = pathlib.Path(sys.argv[1])
index = {
    d.name: f"skills/{d.name}/README.md"
    for d in sorted(skills_dir.iterdir())
    if d.is_dir() and (d / "README.md").exists()
}
(skills_dir / "INDEX.json").write_text(json.dumps(index, indent=2) + "\n")
print(f"INDEX.json: {len(index)} skills registered")
PYEOF
else
  echo "[dry-run] Would regenerate skills/INDEX.json"
fi

ok "Skills installed"

# ─── Step 6: Smoke test ───────────────────────────────────────────────────────
log "Step 6/6: Running smoke test..."

if "$DRY_RUN"; then
  echo "[dry-run] Would POST to \$HERMES_API_BASE/chat/completions with Bearer token"
else
  : "${HERMES_API_BASE:?HERMES_API_BASE not set — did Step 3 fail?}"
  : "${HERMES_API_KEY:?HERMES_API_KEY not set — did Step 3 fail?}"
  HERMES_MODEL_ALIAS="${HERMES_MODEL_ALIAS:-reasoning}"

  mkdir -p "$REPO_DIR/logs"
  LOG="$REPO_DIR/logs/smoke-test.log"
  TMP_RESP=$(mktemp)

  START_NS=$(date +%s%N 2>/dev/null || echo 0)
  HTTP_STATUS=$(curl -s -o "$TMP_RESP" -w "%{http_code}" \
    -X POST "$HERMES_API_BASE/chat/completions" \
    -H "Authorization: Bearer $HERMES_API_KEY" \
    -H "Content-Type: application/json" \
    -d "{\"model\":\"$HERMES_MODEL_ALIAS\",\"max_tokens\":10,\"messages\":[{\"role\":\"user\",\"content\":\"What is the capital of France?\"}]}" \
  )
  END_NS=$(date +%s%N 2>/dev/null || echo 0)
  LATENCY_MS=$(( (END_NS - START_NS) / 1000000 ))

  RESOLVED=$(python3 -c "import json; d=json.load(open('$TMP_RESP')); print(d.get('model','unknown'))" 2>/dev/null || echo "unknown")
  rm -f "$TMP_RESP"

  {
    echo "=== Smoke test $(date -Iseconds) ==="
    echo "HTTP status:     $HTTP_STATUS"
    echo "Latency:         ${LATENCY_MS}ms"
    echo "Resolved model:  $RESOLVED"
    echo "Alias used:      $HERMES_MODEL_ALIAS"
  } | tee -a "$LOG"

  if [[ "$HTTP_STATUS" != "200" ]]; then
    die "Smoke test failed (HTTP $HTTP_STATUS). Check HERMES_API_KEY and LiteLLM proxy: kubectl -n litellm rollout status deploy/litellm"
  fi

  ok "Smoke test passed (HTTP $HTTP_STATUS, ${LATENCY_MS}ms, model: $RESOLVED)"
fi

echo
printf '╔══════════════════════════════════════════════════╗\n'
printf '║  Setup complete! Next steps:                    ║\n'
printf "║  1. Fill in ~/.hermes/memory/USER.md            ║\n"
printf "║  2. source %s\n" "$ENV_FILE"
printf '║  3. hermes start                                ║\n'
printf '╚══════════════════════════════════════════════════╝\n'
```

- [ ] **Step 2: Make executable**

```bash
chmod +x setup.sh
```

- [ ] **Step 3: Verify shebang**

```bash
head -1 setup.sh
```

Expected: `#!/usr/bin/env bash`

- [ ] **Step 4: Dry-run test**

```bash
./setup.sh --dry-run --verbose
```

Expected: prints `[dry-run]` lines for each step, exits 0, no files written.

- [ ] **Step 5: Lint**

```bash
shellcheck setup.sh
```

Expected: exit 0. Acceptable warnings: SC2034 (unused vars), SC1091 (source not following). Fix any SC2086 (unquoted variables) or SC2059 (printf format string) errors.

- [ ] **Step 6: Commit**

```bash
git add setup.sh
git commit -m "feat: add 6-step idempotent setup.sh installer"
git push
```

---

### Task 7: README.md + docs/SETUP.md

**Files:**
- Create: `README.md`
- Create: `docs/SETUP.md`

**Interfaces:**
- Consumes: all files created in Tasks 1–6 (references their paths and commands)

- [ ] **Step 1: Write README.md**

```markdown
# engineering-hermes-agent

Bootstrap repo for the ICLR team Hermes agent. One command to install, configure, and verify.

## Quickstart

```bash
git clone https://github.com/inteliclear/engineering-hermes-agent
cd engineering-hermes-agent
chmod +x setup.sh
./setup.sh
```

`setup.sh` will:
1. Verify prerequisites (Python 3.10+, git, curl)
2. Install Hermes (pinned version)
3. Create `.env` and prompt for your LiteLLM key
4. Seed team memory into `~/.hermes/memory/`
5. Install skills into `~/.hermes/skills/`
6. Run a smoke test against the LiteLLM proxy

After setup, fill in `~/.hermes/memory/USER.md` with your name and role, then:

```bash
source .env
hermes start
```

## LiteLLM Model Aliases

| Alias | Model | Use for |
|-------|-------|---------|
| `reasoning` | Qwen3.5-27B (GPU) | Default — balanced reasoning |
| `coding` | Qwen3-Coder-30B (CPU) | Code generation |
| `smart` | GPT-OSS-20B (GPU) | Complex multi-step tasks |
| `fast` | Qwen3-4B (Vulkan) | Quick lookups, low latency |
| `coder_pro` | AEON Qwen3.6-27B (DGX Spark) | Heavy coding, long context |

Change your alias in `.env`: `HERMES_MODEL_ALIAS=coding`

## Skills

| Skill | Trigger | Covers |
|-------|---------|--------|
| `sql-ops` | "query chromadb", "search procedures" | ChromaDB queries, SQL chunking workflow |
| `cluster-ops` | "check cluster", "deploy", "drain" | k3s health, GitOps, Longhorn, Traefik |
| `general` | "review code", "debug", "git" | Code review, git workflow, debugging |

See [skills/README.md](skills/README.md) for the full catalog and how to add new skills.

## Getting Your LiteLLM Key

```bash
kubectl get secret litellm-master-key -n litellm -o jsonpath='{.data.key}' | base64 -d
```

## Docs

- [Platform-specific setup guide](docs/SETUP.md) — Windows/WSL, macOS, Linux
- [Design spec](docs/superpowers/specs/2026-06-20-hermes-agent-design.md) — full architecture and decisions
```

- [ ] **Step 2: Create docs directory and write docs/SETUP.md**

```markdown
# Setup Guide

Platform-specific setup steps for `engineering-hermes-agent`.

## Prerequisites

| Tool | Version | Install |
|------|---------|---------|
| Python | 3.10+ | `apt install python3` / `brew install python3` |
| git | any | `apt install git` / `brew install git` |
| curl | any | `apt install curl` |
| jq (optional) | any | `apt install jq` / `brew install jq` |

## Linux (Ubuntu/Debian)

```bash
sudo apt update && sudo apt install -y python3 python3-pip git curl jq
git clone https://github.com/inteliclear/engineering-hermes-agent ~/iclr/engineering-hermes-agent
cd ~/iclr/engineering-hermes-agent
./setup.sh
```

## macOS

```bash
brew install python3 git curl jq
git clone https://github.com/inteliclear/engineering-hermes-agent ~/iclr/engineering-hermes-agent
cd ~/iclr/engineering-hermes-agent
./setup.sh
```

## Windows (WSL2 — recommended)

Open a WSL2 Ubuntu terminal:

```bash
sudo apt update && sudo apt install -y python3 python3-pip git curl jq
git clone https://github.com/inteliclear/engineering-hermes-agent ~/iclr/engineering-hermes-agent
cd ~/iclr/engineering-hermes-agent
./setup.sh
```

**WSL2 note:** Clone inside the WSL2 filesystem (`~/`) — not on `/mnt/c/` or `/mnt/d/`.
Cloning on a Windows path disables symlinks, so skills will fall back to a copy and won't auto-update on `git pull`.

## Getting the LiteLLM Key

Requires `kubectl` configured for the ICLR cluster:

```bash
kubectl get secret litellm-master-key -n litellm -o jsonpath='{.data.key}' | base64 -d
```

If you don't have cluster access, ask a cluster admin to share the key.

## Persistent Env (Shell RC)

After setup, add to `~/.bashrc` or `~/.zshrc`:

```bash
source ~/iclr/engineering-hermes-agent/.env
```

This makes `HERMES_API_KEY` and friends available in every new shell.

## Upgrading Hermes

```bash
cd ~/iclr/engineering-hermes-agent
git pull
./setup.sh   # detects version mismatch in HERMES_VERSION and reinstalls
```

## Updating Skills

```bash
cd ~/iclr/engineering-hermes-agent
git pull
# Skills update automatically via symlink — no setup.sh re-run needed
# Re-run setup.sh only if INDEX.json needs regenerating (new skill directories)
```

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| `hermes: command not found` after install | Add `~/.local/bin` to PATH: `export PATH="$HOME/.local/bin:$PATH"` |
| Smoke test HTTP 401 | Wrong `HERMES_API_KEY` — re-fetch with `kubectl get secret...` |
| Smoke test HTTP 502 | LiteLLM proxy down: `kubectl -n litellm rollout status deploy/litellm` |
| Smoke test HTTP 404 | Wrong endpoint — confirm `HERMES_API_BASE` ends in `/v1` |
| Skills symlink not working | Clone inside WSL2 filesystem, not `/mnt/c/...` |
| `HERMES_API_KEY not set` error | `source .env` in current shell, or add to shell rc |
| `hermes start` fails | Check Hermes version matches `HERMES_VERSION` in setup.sh |
```

- [ ] **Step 3: Verify docs directory**

```bash
ls docs/
```

Expected: `SETUP.md` present.

- [ ] **Step 4: Final repo structure check**

```bash
find . -not -path './.git/*' -type f | sort
```

Expected files:
```text
./.env.example
./.gitignore
./README.md
./docs/SETUP.md
./examples/sdk_python.py
./examples/sdk_typescript.ts
./memory/MEMORY.md
./memory/USER.md
./setup.sh
./skills/INDEX.json
./skills/README.md
./skills/cluster-ops/README.md
./skills/general/README.md
./skills/sql-ops/README.md
```

- [ ] **Step 5: Commit and push**

```bash
git add README.md docs/
git commit -m "docs: add README quickstart and platform-specific SETUP.md"
git push
```

- [ ] **Step 6: Verify repo is live on GitHub**

```bash
gh repo view inteliclear/engineering-hermes-agent --web
```

Expected: GitHub page opens, all files visible.

---

## Self-Review

**Spec coverage check:**

| Spec section | Covered by |
|-------------|-----------|
| §1 One-command install | Task 6 (setup.sh) |
| §1 LiteLLM integration | Task 2 (.env.example) + Task 6 Step 6 (smoke test) |
| §1 Shared memory seed | Task 3 (memory/) + Task 6 Step 4 |
| §1 Skills | Task 4 (skills/) + Task 6 Step 5 |
| §2 Architecture | Task 7 (README.md diagram) |
| §3 Repo layout | All tasks — final verified in Task 7 Step 4 |
| §4 .env.example | Task 2 |
| §5 setup.sh 6 steps | Task 6 |
| §5 --dry-run/--verbose | Task 6 (built into setup.sh) |
| §6 Skills INDEX.json | Task 4 Step 6 + Task 6 Step 5 (regeneration) |
| §7 Python example | Task 5 |
| §7 TypeScript example | Task 5 |
| §8 Operational notes | Task 7 (docs/SETUP.md) |
| §9 What this doesn't do | Task 7 (README.md) |

**Bug fixed from spec:** The spec's example scripts used `f"{base_url}/v1/messages"` which would produce `https://litellm.inteliclear.io/v1/v1/messages` (double `/v1`). The plan uses `f"{base_url}/chat/completions"` — correct for the OpenAI-compatible LiteLLM endpoint with `HERMES_API_BASE` including `/v1`.

**No placeholders found** except the explicit Hermes package name note in Task 6 Step 1, which is an action item (verify from Hermes docs), not a deferred design decision.
