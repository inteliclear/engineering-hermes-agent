# ICLR Engineering — Hermes Agent Bootstrap

Minimal, portable, and auditable starter for ICLR's Hermes Agent engineering environment.

## Quick Start

```bash
git clone https://github.com/inteliclear/engineering-hermes-agent
cd engineering-hermes-agent
./setup.sh
```

Then open `~/.hermes/memories/USER.md` and fill in your name and role, then launch:

```bash
hermes
```

## What This Gives You

| Artifact | Purpose |
|----------|---------|
| `.env.example` | Template for LiteLLM proxy + model routing |
| `setup.sh` | Idempotent bootstrap (Hermes install, config wiring, memory/skills seeding, smoke test) |
| `memory/` | Cluster & infrastructure memory (Hermes context) |
| `skills/` | Domain skill files (SQL, cluster ops, general) |
| `examples/` | Minimal Python and TypeScript reference scripts |
| `docs/SETUP.md` | Detailed setup walkthrough |

## Prerequisites

Only **git** and **curl** are required. The official Hermes installer brings its own Python 3.11, Node 22, ripgrep, and ffmpeg.

**Optional:** `python3` 3.10+ is recommended for the smoke-test JSON parsing and Python examples.

## WSL2 Caveat

Clone this repo under your Linux home (`~`) rather than `/mnt/c` or `/mnt/d`. If the repo lives on a Windows-mounted drive, the skills symlink falls back to a plain copy, meaning skills won't auto-update on `git pull`.

## Config Mapping

`setup.sh` maps your repo `.env` to the native Hermes config:

| `.env` variable | Hermes destination |
|-----------------|-------------------|
| `HERMES_API_BASE` | `~/.hermes/config.yaml` → `model.base_url` |
| `HERMES_MODEL_ALIAS` | `~/.hermes/config.yaml` → `model.default` |
| `HERMES_API_KEY` | `~/.hermes/.env` → `OPENAI_API_KEY` |

## Skills

`setup.sh` symlinks the repo `skills/` directory to `~/.hermes/skills/iclr`. Hermes auto-discovers `SKILL.md` files there. If you're on WSL2 and the repo lives under `/mnt/c` or `/mnt/d`, the symlink falls back to a copy — see `docs/SETUP.md` for the fix.

## Model Aliases

| Alias | Backend | Model |
|-------|---------|-------|
| `reasoning` | GPU LXC 10.5.1.36 | Qwen3.5-27B-UD-IQ3_XXS |
| `coding` | CPU LXC 10.5.1.33 | Qwen3-Coder-30B-A3B-IQ4_XS |
| `smart` | GPU LXC 10.5.1.36 | GPT-OSS-20B |
| `fast` | Vulkan 10.5.1.146 | Qwen3-4B-Instruct-2507 |
| `coder` | 10.5.1.12 + 10.5.1.19 | Qwen2.5-Coder-3B (weighted LB) |
| `coder_pro` | DGX Spark 10.5.1.49 | AEON Qwen3.6-27B NVFP4 |

## Upgrading

```bash
hermes update
```

## License

Proprietary — Inteliclear (Inteliclear.io)
