# engineering-hermes-agent Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create the `inteliclear/engineering-hermes-agent` GitHub repo — a one-command bootstrap that installs Hermes, wires it to the ICLR LiteLLM proxy, seeds shared team memory, and installs pre-built skills.

**Architecture:** A pure-configuration repo with no app code and no servers. `setup.sh` is the only executable. It installs Hermes via the official curl installer, then maps the repo's team-facing `.env` into Hermes' native config (`~/.hermes/config.yaml` + `~/.hermes/.env`), seeds memory into `~/.hermes/memories/`, and symlinks `skills/` into `~/.hermes/skills/`. Hermes auto-discovers `SKILL.md` files — no index file.

**Tech Stack:** Bash (setup.sh), Markdown + YAML frontmatter (SKILL.md), Markdown (memory/docs), Python `requests` (example), TypeScript native `fetch` (example), `gh` CLI (repo creation)

## Global Constraints

- Hermes install: `curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash` — **not** pip. Only Git is required (installer brings Python 3.11, Node 22, ripgrep, ffmpeg). No version pinning is documented; upgrades via `hermes update`.
- Hermes config file: `~/.hermes/config.yaml` — set `model.provider: custom`, `model.base_url`, `model.default` via `hermes config set`.
- Hermes secret file: `~/.hermes/.env` — `OPENAI_API_KEY=<litellm key>` (written directly, never via sed/regex).
- Hermes memory dir: `~/.hermes/memories/` (plural) — holds `MEMORY.md` + `USER.md`.
- Hermes skills dir: `~/.hermes/skills/` — auto-discovers `SKILL.md` files. We symlink the repo's `skills/` in as `~/.hermes/skills/iclr`. No `INDEX.json`.
- Skill files are `SKILL.md` with YAML frontmatter — required keys `name`, `description`; optional `version`, `metadata.hermes.tags`, `metadata.hermes.category`.
- LiteLLM proxy: `https://litellm.inteliclear.io/v1` — OpenAI-compatible. Request path is `$HERMES_API_BASE/chat/completions` (base already ends in `/v1`).
- Model aliases: `reasoning`, `coding`, `smart`, `fast`, `coder`, `coder_pro`.
- Repo `.env` (team-facing, gitignored) holds `HERMES_API_BASE`, `HERMES_API_KEY`, `HERMES_MODEL_ALIAS`.
- `setup.sh` is idempotent — safe to re-run.
- **turbo-sql-chunk repo path is `/home/tpanchal/iclr/turbo-sql-chunk`** (per global CLAUDE.md Key Repos table).
- Local clone target for this repo: `/home/tpanchal/iclr/engineering-hermes-agent/` (already created and cloned).

> **Note:** The GitHub repo `inteliclear/engineering-hermes-agent` and its local clone already exist, and this plan file is already committed to it. Task 1 below covers only the remaining scaffold file (`.gitignore`).

---

### Task 1: `.gitignore`

**Files:**
- Create: `.gitignore`

**Interfaces:**
- Produces: a repo that ignores `.env`, logs, and language caches.

- [ ] **Step 1: Write .gitignore**

```text
.env
logs/
*.log
__pycache__/
node_modules/
.DS_Store
```

- [ ] **Step 2: Verify**

```bash
cd /home/tpanchal/iclr/engineering-hermes-agent
grep -E '^\.env$|^logs/' .gitignore
```

Expected: both `.env` and `logs/` print.

- [ ] **Step 3: Commit**

```bash
git add .gitignore
git commit -m "chore: add .gitignore"
```

---

### Task 2: `.env.example`

**Files:**
- Create: `.env.example`

**Interfaces:**
- Produces: `HERMES_API_BASE`, `HERMES_API_KEY`, `HERMES_MODEL_ALIAS` — the three team-facing env vars read by setup.sh and the example scripts.

- [ ] **Step 1: Write .env.example**

```bash
# LiteLLM proxy (ICLR shared inference)
HERMES_API_BASE=https://litellm.inteliclear.io/v1
HERMES_API_KEY=<your-litellm-master-key>

# Model routing — change per team member preference
# Options: reasoning, coding, smart, fast, coder, coder_pro
HERMES_MODEL_ALIAS=reasoning
```

- [ ] **Step 2: Verify no real secret is present**

```bash
grep "HERMES_API_KEY" .env.example
```

Expected: `HERMES_API_KEY=<your-litellm-master-key>` — placeholder only.

- [ ] **Step 3: Commit**

```bash
git add .env.example
git commit -m "chore: add .env.example team-facing config"
```

---

### Task 3: Memory Files

**Files:**
- Create: `memory/MEMORY.md`
- Create: `memory/USER.md`

**Interfaces:**
- Produces: two files copied by setup.sh Step 4 into `~/.hermes/memories/`.

- [ ] **Step 1: Create directory**

```bash
mkdir -p memory
```

- [ ] **Step 2: Write memory/MEMORY.md**

```markdown
# ICLR Team Memory

Shared context about the ICLR (Inteliclear) cluster and infrastructure.
Seeded into Hermes agent memory on first setup. Hermes reads this from
~/.hermes/memories/MEMORY.md at session start.

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
| `turbo-sql-chunk` | `/home/tpanchal/iclr/turbo-sql-chunk` | SQL chunking → ChromaDB for RAG |
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

Fill this in after running setup.sh. Hermes reads this from
~/.hermes/memories/USER.md and uses it to personalize responses.

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

### Task 4: Skill Files (`SKILL.md`)

**Files:**
- Create: `skills/README.md`
- Create: `skills/sql-ops/SKILL.md`
- Create: `skills/cluster-ops/SKILL.md`
- Create: `skills/general/SKILL.md`

**Interfaces:**
- Produces: three `SKILL.md` files auto-discovered by Hermes once `skills/` is symlinked into `~/.hermes/skills/` (Task 6 Step 5). No index file.

- [ ] **Step 1: Create directories**

```bash
mkdir -p skills/sql-ops skills/cluster-ops skills/general
```

- [ ] **Step 2: Write skills/README.md**

```markdown
# ICLR Hermes Skills

Pre-built skills for three ICLR use cases. Each skill is a directory with a
`SKILL.md` file (agentskills.io standard). Hermes auto-discovers them from
`~/.hermes/skills/` — there is no index file to maintain.

## Catalog

| Skill | What it does |
|-------|-------------|
| `sql-ops` | SQL chunking, ChromaDB queries, spec generation |
| `cluster-ops` | k3s ops, GitOps workflow, Longhorn, Traefik |
| `general` | Code review, git workflow, structured debugging |

## Adding a New Skill

1. Create `skills/<name>/SKILL.md` with valid frontmatter (see existing skills).
2. `git pull` on each machine — the symlink into `~/.hermes/skills/` means
   Hermes sees it immediately. No `setup.sh` re-run needed.

## SKILL.md Frontmatter

Required: `name`, `description`. Optional: `version`,
`metadata.hermes.tags`, `metadata.hermes.category`.
```

- [ ] **Step 3: Write skills/sql-ops/SKILL.md**

````markdown
---
name: sql-ops
description: Query the ChromaDB SQL vector store and run the turbo-sql-chunk workflow
version: 1.0.0
metadata:
  hermes:
    tags: [sql, chromadb, rag]
    category: data
---

# SQL Ops

## When to Use
- "Search for stored procedures that handle [topic]"
- "What does [procedure name] do?"
- "Run the chunking workflow on [sql folder]"
- "Generate a spec for [stored procedure]"

## Prerequisites
- `turbo-sql-chunk` repo at `/home/tpanchal/iclr/turbo-sql-chunk`
- ChromaDB collection `sql_code` reachable at `https://chroma.inteliclear.io`
- Python venv active: `source venv/bin/activate` (from turbo-sql-chunk root)

## Procedure

### Health check
```bash
cd /home/tpanchal/iclr/turbo-sql-chunk
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
python scripts/generate_spec.py --input path/to/sp.sql --schema post_trade.settlement
```

## Reference
- **Collection:** `sql_code` (384-dim, cosine, 17K+ docs)
- **Auth token:**
  ```bash
  kubectl get secret chromadb-auth-secret -n chromadb -o jsonpath='{.data.token}' | base64 -d
  ```

## Verification
`python src/run_workflow.py --health-check` reports the ChromaDB connection as healthy and the collection document count as non-zero.
````

- [ ] **Step 4: Write skills/cluster-ops/SKILL.md**

````markdown
---
name: cluster-ops
description: Operate the ICLR k3s cluster — health, GitOps, Longhorn, Traefik
version: 1.0.0
metadata:
  hermes:
    tags: [k3s, kubernetes, gitops, devops]
    category: infrastructure
---

# Cluster Ops

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

## Procedure

### Cluster health (GOOD / DEGRADED / CRITICAL)
```bash
cd /home/tpanchal/iclr/glowing-octo-palm-tree
./scripts/health/py/cluster_health_check.py --json
```

### Nodes / Longhorn / LiteLLM / Traefik
```bash
kubectl get nodes -o wide
kubectl get pods -n longhorn-system
kubectl -n litellm rollout status deploy/litellm
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

### SSH to a node / DGX Spark
```bash
ssh -i ~/.ssh/iclr-dg-build icadm@10.5.1.58
ssh -i ~/.ssh/iclr-dgx-spark tpanchal@10.5.1.49
```

## Pitfalls
- Traefik MUST keep 10.5.1.80 (DNS depends on it).
- Never use NodePort/hostPort — ingress via Traefik + MetalLB only.
- git-crypt'd services (Kutt, PrivateBin, Passbolt) need `git-crypt unlock` before apply.

## Verification
`cluster_health_check.py --json` returns `"status": "GOOD"` (0 failures).
````

- [ ] **Step 5: Write skills/general/SKILL.md**

````markdown
---
name: general
description: General engineering — code review, git workflow, debugging, logging
version: 1.0.0
metadata:
  hermes:
    tags: [git, review, debugging, python]
    category: engineering
---

# General Engineering

## When to Use
- "Review this code"
- "Debug this error"
- "Create a PR for [feature]"
- "Add logging to this function"

## Code Review Checklist
1. **Correctness** — does it do what it claims?
2. **Security** — SQL/command injection, plaintext secrets, OWASP top 10?
3. **Error handling** — are external calls wrapped? Is only the happy path tested?
4. **Tests** — does coverage exist for the new path? Are mocks realistic?
5. **Naming** — are functions/variables self-describing?
6. **Scope** — does the PR do more than the ticket describes?

## Git Workflow
```bash
git checkout -b feat/<short-description>
git commit -m "feat: add X"     # feat | fix | chore | docs
gh pr create --title "feat: add X" --body "## Summary\n- ...\n\n## Test plan\n- [ ] ..."
gh pr merge --squash
```

## Structured Debugging
1. **Reproduce** — smallest case that triggers the bug
2. **Isolate** — binary search to the source component
3. **Hypothesize** — one hypothesis at a time
4. **Test** — change one variable, observe
5. **Document** — root cause + fix in the commit message

## Structured Logging (Python)
```python
import logging
log = logging.getLogger(__name__)
log.info("operation started", extra={"item": item_id})
log.error("operation failed", extra={"error": str(e), "item": item_id})
```
Never use `print()` for operational logging.

## Verification
The change has a test that fails before and passes after, and `git log` shows a conventional-commit message describing the root cause.
````

- [ ] **Step 6: Verify structure and frontmatter**

```bash
find skills/ -name SKILL.md | sort
for f in skills/*/SKILL.md; do head -1 "$f" | grep -q '^---$' && echo "OK: $f" || echo "BAD frontmatter: $f"; done
```

Expected: three `SKILL.md` paths listed, each printing `OK:`.

- [ ] **Step 7: Commit**

```bash
git add skills/
git commit -m "feat: add sql-ops, cluster-ops, general SKILL.md files"
```

---

### Task 5: Example Scripts

**Files:**
- Create: `examples/sdk_python.py`
- Create: `examples/sdk_typescript.ts`

**Interfaces:**
- Consumes: `HERMES_API_BASE`, `HERMES_API_KEY`, `HERMES_MODEL_ALIAS` from environment (Task 2).
- Endpoint: `$HERMES_API_BASE/chat/completions` (base already ends in `/v1`).

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
 * Uses native fetch (Node.js 20+ / the Node 22 Hermes installs) — no deps.
 *
 * Usage:
 *   source .env   # sets HERMES_API_BASE, HERMES_API_KEY, HERMES_MODEL_ALIAS
 *   npx tsx examples/sdk_typescript.ts
 */
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
}

const data = (await resp.json()) as ChatResponse;
console.log(data.choices[0].message.content);
```

- [ ] **Step 4: Verify Python syntax**

```bash
python3 -c "import ast; ast.parse(open('examples/sdk_python.py').read()); print('syntax OK')"
```

Expected: `syntax OK`

- [ ] **Step 5: Commit**

```bash
git add examples/
git commit -m "feat: add Python and TypeScript LiteLLM proxy examples"
```

---

### Task 6: setup.sh

**Files:**
- Create: `setup.sh`

**Interfaces:**
- Consumes: `.env.example` (Task 2), `memory/` (Task 3), `skills/` (Task 4).
- Produces: installed `hermes`; `~/.hermes/config.yaml` (model.*); `~/.hermes/.env` (`OPENAI_API_KEY`); `~/.hermes/memories/MEMORY.md` + `USER.md`; `~/.hermes/skills/iclr → <repo>/skills`; `logs/smoke-test.log`.

- [ ] **Step 1: Write setup.sh**

```bash
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
      echo "Get your key: kubectl get secret litellm-master-key -n litellm -o jsonpath='{.data.key}' | base64 -d"
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
  chmod 600 "$HERMES_DOTENV"
else
  echo "[dry-run] hermes config set model.provider custom"
  echo "[dry-run] hermes config set model.base_url \$HERMES_API_BASE"
  echo "[dry-run] hermes config set model.default \$HERMES_MODEL_ALIAS"
  echo "[dry-run] write OPENAI_API_KEY to $HERMES_HOME/.env"
fi

ok "Config wired (model.* in config.yaml, OPENAI_API_KEY in ~/.hermes/.env)"

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
```

- [ ] **Step 2: Make executable and check shebang**

```bash
chmod +x setup.sh
head -1 setup.sh
```

Expected: `#!/usr/bin/env bash`

- [ ] **Step 3: Dry-run test**

```bash
./setup.sh --dry-run --verbose
```

Expected: prints `[dry-run]` lines for each of the 6 steps, exits 0, no files written, no network calls.

- [ ] **Step 4: Lint**

```bash
shellcheck setup.sh
```

Expected: exit 0. Acceptable: SC1090/SC1091 (source not followed). Fix any SC2086 (unquoted vars).

- [ ] **Step 5: Commit and push**

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
- Consumes: all files from Tasks 1–6 (references their paths and commands).

- [ ] **Step 1: Write README.md**

````markdown
# engineering-hermes-agent

Bootstrap repo for the ICLR team Hermes agent. One command to install Hermes,
wire it to the ICLR LiteLLM proxy, seed team memory, and load skills.

## Quickstart

```bash
git clone https://github.com/inteliclear/engineering-hermes-agent ~/iclr/engineering-hermes-agent
cd ~/iclr/engineering-hermes-agent
./setup.sh
```

`setup.sh` will:
1. Verify prerequisites (git, curl; python3 recommended)
2. Install Hermes via the official installer (`curl ... | bash`)
3. Map your `.env` into Hermes config (`~/.hermes/config.yaml` + `~/.hermes/.env`)
4. Seed team memory into `~/.hermes/memories/`
5. Symlink skills into `~/.hermes/skills/`
6. Run a smoke test against the LiteLLM proxy

Then fill in `~/.hermes/memories/USER.md` and run:

```bash
hermes
```

## Model Aliases

| Alias | Model | Use for |
|-------|-------|---------|
| `reasoning` | Qwen3.5-27B (GPU) | Default — balanced reasoning |
| `coding` | Qwen3-Coder-30B (CPU) | Code generation |
| `smart` | GPT-OSS-20B (GPU) | Complex multi-step tasks |
| `fast` | Qwen3-4B (Vulkan) | Quick lookups, low latency |
| `coder_pro` | AEON Qwen3.6-27B (DGX Spark) | Heavy coding, long context |

Change it in `.env` (`HERMES_MODEL_ALIAS=coding`) and re-run `./setup.sh`,
or run `hermes config set model.default coding` directly.

## Skills

| Skill | Covers |
|-------|--------|
| `sql-ops` | ChromaDB queries, SQL chunking workflow |
| `cluster-ops` | k3s health, GitOps, Longhorn, Traefik |
| `general` | Code review, git workflow, debugging |

Hermes auto-discovers these `SKILL.md` files. See [skills/README.md](skills/README.md).

## Getting Your LiteLLM Key

```bash
kubectl get secret litellm-master-key -n litellm -o jsonpath='{.data.key}' | base64 -d
```

## Docs

- [Platform setup guide](docs/SETUP.md) — Windows/WSL, macOS, Linux
- [Design spec](docs/superpowers/specs/2026-06-20-hermes-agent-design.md)
````

- [ ] **Step 2: Create docs dir and write docs/SETUP.md**

````markdown
# Setup Guide

Platform-specific setup for `engineering-hermes-agent`.

## Prerequisites

Only **git** and **curl** are strictly required — the Hermes installer brings
its own Python 3.11, Node 22, ripgrep, and ffmpeg. `python3` (3.10+) on the
host is recommended for the smoke test and the Python example.

| Tool | Required | Install |
|------|----------|---------|
| git | yes | `apt install git` / `brew install git` |
| curl | yes | `apt install curl` / preinstalled on macOS |
| python3 | recommended | `apt install python3` / `brew install python3` |
| jq | optional | `apt install jq` / `brew install jq` |

## Linux / macOS

```bash
git clone https://github.com/inteliclear/engineering-hermes-agent ~/iclr/engineering-hermes-agent
cd ~/iclr/engineering-hermes-agent
./setup.sh
```

## Windows (WSL2 — recommended)

Run inside a WSL2 Ubuntu terminal, cloning into the **Linux** filesystem:

```bash
git clone https://github.com/inteliclear/engineering-hermes-agent ~/iclr/engineering-hermes-agent
cd ~/iclr/engineering-hermes-agent
./setup.sh
```

**WSL2 note:** clone under `~/` — not `/mnt/c/` or `/mnt/d/`. Windows paths
disable symlinks, so skills fall back to a copy and won't auto-update on
`git pull`.

Native Windows (no WSL) uses the PowerShell installer
(`iex (irm https://hermes-agent.nousresearch.com/install.ps1)`); `setup.sh`
is a bash script and expects WSL2/Git Bash.

## How Config Maps to Hermes

`setup.sh` translates the repo's `.env` into Hermes' native files:

| Repo `.env` | Hermes |
|-------------|--------|
| `HERMES_API_BASE` | `~/.hermes/config.yaml` → `model.base_url` |
| `HERMES_MODEL_ALIAS` | `~/.hermes/config.yaml` → `model.default` |
| `HERMES_API_KEY` | `~/.hermes/.env` → `OPENAI_API_KEY` |

## Getting the LiteLLM Key

```bash
kubectl get secret litellm-master-key -n litellm -o jsonpath='{.data.key}' | base64 -d
```

If you lack cluster access, ask a cluster admin for the key.

## Upgrading Hermes

```bash
hermes update
```

## Updating Skills / Memory

```bash
cd ~/iclr/engineering-hermes-agent
git pull
# Skills update automatically via the symlink.
# Re-run ./setup.sh only to refresh seeded memory or re-create the symlink.
```

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| `hermes: command not found` after install | Open a new shell, or add `~/.local/bin` to PATH |
| Smoke test HTTP 401 | Wrong key — re-fetch with `kubectl get secret...` and re-run setup.sh |
| Smoke test HTTP 404 | Confirm `HERMES_API_BASE` ends in `/v1` (path is `/v1/chat/completions`) |
| Smoke test HTTP 502 | Proxy down: `kubectl -n litellm rollout status deploy/litellm` |
| Skills not picked up | Confirm `~/.hermes/skills/iclr` exists and points at the repo |
| Symlink fell back to copy | Clone inside the WSL2 Linux filesystem, not `/mnt/...` |
````

- [ ] **Step 3: Final structure check**

```bash
find . -not -path './.git/*' -not -path './docs/superpowers/*' -type f | sort
```

Expected:
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
./skills/README.md
./skills/cluster-ops/SKILL.md
./skills/general/SKILL.md
./skills/sql-ops/SKILL.md
```

- [ ] **Step 4: Commit and push**

```bash
git add README.md docs/SETUP.md
git commit -m "docs: add README quickstart and platform SETUP guide"
git push
```

- [ ] **Step 5: Verify live on GitHub**

```bash
gh repo view inteliclear/engineering-hermes-agent --web
```

Expected: all files visible.

---

## Self-Review

**Spec coverage check:**

| Spec section | Covered by |
|-------------|-----------|
| §1 One-command install | Task 6 (setup.sh) |
| §2 Hermes config mapping | Task 6 Step 3 (hermes config set + ~/.hermes/.env) |
| §3 Architecture | Task 7 (README) |
| §4 Repo layout | All tasks — verified Task 7 Step 3 |
| §5 .env.example + mapping | Task 2 + Task 6 Step 3 |
| §6 setup.sh 6 steps + flags | Task 6 |
| §7 SKILL.md format + discovery | Task 4 |
| §8 Examples (chat/completions, native fetch) | Task 5 |
| §9 Operational notes | Task 7 (SETUP.md) |
| §10 What it doesn't do | Task 7 (README) |

**Corrections applied vs the prior plan revision:**
- Install is the official curl script, not `pip install hermes-agent`; no version pin (use `hermes update`).
- Skills are `SKILL.md` with frontmatter, not `README.md`; `INDEX.json` removed (Hermes auto-discovers).
- Model config via `hermes config set`; key written directly to `~/.hermes/.env` — **the sed-injection bug is gone** (awk with `ENVIRON`, no regex on the value).
- Memory dir is `~/.hermes/memories/` (plural).
- turbo-sql-chunk path corrected to `/home/tpanchal/iclr/turbo-sql-chunk`.
- TypeScript example uses native `fetch` (no `node-fetch`).
- Endpoint is `$HERMES_API_BASE/chat/completions` (no `/v1/messages` double-prefix).

**No placeholders remain.** Every code/command step contains the actual content.
