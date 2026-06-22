# Setup Walkthrough

## Prerequisites

- **git** and **curl** (required — everything else comes with the Hermes installer)
- **python3** 3.10+ (optional — used for smoke-test JSON parsing and Python examples)
- **OS:** Ubuntu 22.04 / 24.04 (WSL2 or bare metal)

> **WSL2:** Clone this repo under your Linux home (`~`) rather than `/mnt/c` or `/mnt/d`.
> On a Windows-mounted drive, the skills symlink falls back to a plain copy, so skills
> won't auto-update on `git pull`.

## Correct Flow

Hermes installs via the official curl installer. It brings its own Python 3.11, Node 22, ripgrep, and ffmpeg. Only git + curl are host prerequisites.

### 1. Clone and Run Setup

```bash
git clone https://github.com/inteliclear/engineering-hermes-agent
cd engineering-hermes-agent
./setup.sh
```

On Windows (WSL2/Git Bash, or PowerShell):

```bash
# Bash (WSL2 / Git Bash)
curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash

# PowerShell (native Windows)
iex (irm https://hermes-agent.nousresearch.com/install.ps1)
```

### 2. What setup.sh Does

`setup.sh` performs these steps idempotently:

1. **Checks prerequisites** — verifies `git` and `curl` are on PATH; warns if `python3` is missing.
2. **Installs Hermes** — runs the official curl installer. Hermes brings its own Python, Node, ripgrep, and ffmpeg.
3. **Wires config** — maps the repo `.env` to native Hermes config:

   | `.env` variable | Hermes destination |
   |-----------------|-------------------|
   | `HERMES_API_BASE` | `~/.hermes/config.yaml` → `model.base_url` |
   | `HERMES_MODEL_ALIAS` | `~/.hermes/config.yaml` → `model.default` |
   | `HERMES_API_KEY` | `~/.hermes/.env` → `OPENAI_API_KEY` |

4. **Seeds memory** — copies `memory/MEMORY.md` and `memory/USER.md` to `~/.hermes/memories/`. Open `~/.hermes/memories/USER.md` and fill in your name and role.
5. **Installs skills** — symlinks `skills/` to `~/.hermes/skills/iclr` so Hermes auto-discovers `SKILL.md` files. Falls back to a copy if the symlink target crosses filesystem boundaries (e.g., WSL2 `/mnt/c`).
6. **Smoke test** — POSTs to `${HERMES_API_BASE}/chat/completions` to verify connectivity.

### 3. Get Your LiteLLM Key

The setup script will prompt for your LiteLLM master key. To retrieve it:

```bash
kubectl get secret litellm-secret -n litellm -o jsonpath='{.data.LITELLM_MASTER_KEY}' | base64 -d
```

You can also pass it as an environment variable to skip the prompt:

```bash
HERMES_API_KEY=sk-xxxxx ./setup.sh
```

### 4. Verify the Smoke Test

After setup, verify connectivity:

```bash
curl -s -X POST "$HERMES_API_BASE/chat/completions" \
  -H "Authorization: Bearer $HERMES_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model":"reasoning","max_tokens":10,"messages":[{"role":"user","content":"What is the capital of France?"}]}'
```

### 5. Launch

```bash
hermes
```

## Upgrading

```bash
hermes update
```

## Troubleshooting

### Smoke test returns HTTP 401

Your master key is likely wrong. Get the current key:

```bash
kubectl get secret litellm-secret -n litellm -o jsonpath='{.data.LITELLM_MASTER_KEY}' | base64 -d
```

### Smoke test fails — check the proxy

```bash
kubectl -n litellm rollout status deploy/litellm
```

### Skills not auto-updating on git pull

If you see a copy instead of a symlink at `~/.hermes/skills/iclr`, you're likely on WSL2 with the repo under `/mnt/c` or `/mnt/d`. Move the repo to your Linux home:

```bash
mv ~/mnt/c/engineering-hermes-agent ~/engineering-hermes-agent
```

Then re-run `./setup.sh`.

### Memory files not seeded

Check that `HERMES_API_BASE`, `HERMES_API_KEY`, and `HERMES_MODEL_ALIAS` are set in your `.env` file.
