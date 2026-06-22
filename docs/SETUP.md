# Setup Walkthrough

## Prerequisites

- **OS:** Ubuntu 22.04 / 24.04 (WSL2 or bare metal)
- **Python:** 3.10+
- **Node.js:** 18+
- **Git:** 2.30+
- **Curl:** 7.68+

## Step-by-Step

### 1. Clone the Repo

```bash
git clone https://github.com/inteliclear/engineering-hermes-agent
cd engineering-hermes-agent
```

### 2. Run the Bootstrap Script

```bash
bash setup.sh
```

The script will:
- Create a Python virtual environment (`.venv`)
- Install `hermes-agent`, `openai`, `pyyaml`
- Install Node dependencies (`npm install`)
- Copy `.env.example` → `.env`
- Seed memory and skill files to `~/.hermes/`
- Run a smoke test against the LiteLLM proxy

### 3. Pass Your LiteLLM Key (Optional)

```bash
LITE_LLM_KEY=sk-xxxxx bash setup.sh
```

If not passed, the `.env` file will contain the placeholder value and you'll need to edit it manually.

### 4. Verify the Smoke Test

After setup, check the proxy:

```bash
curl -s https://litellm.inteliclear.io/v1/models \
  -H "Authorization: Bearer <your-master-key>" | jq '.data[].id'
```

### 5. Configure Model Alias

Edit `.env` and set your preferred model:

```bash
HERMES_MODEL_ALIAS=coding
```

### 6. Initialize Hermes

```bash
source .venv/bin/activate
python3 -m hermes init
```

## Troubleshooting

### Smoke test returns HTTP 401

Your master key is likely wrong. Get the current key:

```bash
kubectl -n litellm get secret litellm-secret -o jsonpath='{.data.LITELLM__MASTER_KEY}' | base64 -d
```

### `hermes-agent` package not found

The pip package name is `hermes-agent` (subject to change). If the package is temporarily unavailable, you can also install from source or use the direct import path.

### Memory files not seeded

Check that `HERMES_API_BASE`, `HERMES_API_KEY`, and `HERMES_MODEL_ALIAS` are set in your `.env` file.
