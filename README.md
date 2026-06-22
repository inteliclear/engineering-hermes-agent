# ICLR Engineering — Hermes Agent Bootstrap

Minimal, portable, and auditable starter for ICLR's Hermes Agent engineering environment.

## Quick Start

```bash
git clone https://github.com/inteliclear/engineering-hermes-agent
cd engineering-hermes-agent
bash setup.sh
```

## What This Gives You

| Artifact | Purpose |
|----------|---------|
| `.env.example` | Template for LiteLLM proxy + model routing |
| `setup.sh` | Idempotent bootstrap (pip, npm, memory seeding) |
| `memory/` | Cluster & infrastructure memory (Hermes context) |
| `skills/` | Domain skill files (SQL, cluster ops, general) |
| `examples/` | Minimal Python and TypeScript reference scripts |
| `docs/SETUP.md` | Detailed setup walkthrough |

## Architecture

```
┌──────────────────────────────┐
│  Your Machine               │
│  ├── .venv (Python 3.10+)   │
│  ├── node_modules (Node 18+) │
│  ├── .env (config)         │
│  ├── memory/ → ~/.hermes/  │
│  └── skills/               │
│           │                  │
│           ▼                  │
│  ICLR Cluster (k3s)        │
│  └── litellm.inteliclear.io│
```

## Model Aliases

| Alias | Backend | Model |
|-------|---------|-------|
| `reasoning` | GPU LXC 10.5.1.36 | Qwen3.5-27B-UD-IQ3_XXS |
| `coding` | CPU LXC 10.5.1.33 | Qwen3-Coder-30B-A3B-IQ4_XS |
| `smart` | GPU LXC 10.5.1.36 | GPT-OSS-20B |
| `fast` | Vulkan 10.5.1.146 | Qwen3-4B-Instruct-2507 |
| `coder` | 10.5.1.12 + 10.5.1.19 | Qwen2.5-Coder-3B (weighted LB) |
| `coder_pro` | DGX Spark 10.5.1.49 | AEON Qwen3.6-27B NVFP4 |

## Setup

Run `bash setup.sh` (idempotent). Optionally pass `LITE_LLM_KEY` to inject your LiteLLM master key:

```bash
LITE_LLM_KEY=sk-xxxxx bash setup.sh
```

See `docs/SETUP.md` for the full walkthrough.

## License

Proprietary — Inteliclear (Inteliclear.io)
