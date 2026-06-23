Here’s a runbook-style document for this module of the Hermes Agent Masterclass. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)

***

## Runbook Name

Hermes Agent – Providers, Models, Local Backends, and Proxy Configuration [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)

***

## Purpose

- Standardize how Hermes Agent is configured for cloud and local models. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)
- Provide cost-tiering, fallback, and auxiliary-model practices to optimize spend and resilience. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)
- Document how to expose Hermes as an OpenAI-compatible proxy for other tools. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)

***

## Scope

Covers Hermes Agent model and provider configuration including:

- API key vs OAuth providers. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)
- Default and fallback models, auxiliary slots, and credential pools. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)
- Local backends (llama.cpp, vLLM, Ollama, LM Studio). [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)
- Hermes Proxy usage to serve subscriptions to external tools. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)

***

## Prerequisites

- Hermes Agent installed and working (TUI/CLI). [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)
- Access to at least one provider:
  - API-key based (e.g., OpenRouter, OpenAI, Groq, etc.). [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)
  - Or OAuth-based subscription via Codex or similar. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)
- For local models:
  - GPU machine (example in video: RTX 3060, 12 GB VRAM). [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)
  - Installed local inference stack: llama.cpp and/or Ollama (or vLLM/LM Studio for similar patterns). [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)

***

## Key Concepts

### Providers vs Models

- Provider: Endpoint Hermes talks to (OpenRouter, Codex, X.ai, Ollama, LM Studio, etc.). It owns auth, billing, and transport. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)
- Model: Specific model name served by a provider (e.g., GPT 5.5, Grok 4.3). It owns capability, context window, and cost. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)
- Providers and models are independent; a single provider can expose many models. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)

### Provider Landscape in Hermes

- ~28 first-class provider plugins at time of recording; providers are pluggable since v3. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)
- v0.14 added SuperRAG + OAuth support and bumped Grok 4.3 to 1M-token context. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)
- v0.15 promoted OpenAI’s API to first-class provider, separate from Codex. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)

***

## Provider Configuration

### Option 1 – API Key Providers

**Use when** you have pay-per-use API access through a provider like OpenRouter. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)

**Steps**

1. Obtain API key from provider (e.g., OpenRouter SK-… style key). [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)
2. In Hermes model configuration:
   - Choose the provider entry (e.g., OpenRouter #2). [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)
   - Paste the API key into the Hermes provider config. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)
3. Set usage limits at provider side (e.g., 10–20 USD caps) to guard against runaway spend. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)

**Notes**

- API keys are the only credential needed to bill your account; treat as secret. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)
- Recommended to keep strict provider-side spend limits when integrating agents. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)

### Option 2 – OAuth / Subscription Providers

**Use when** you have a monthly subscription with bundled usage (e.g., Codex subscription for GPT 5.5). [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)

**Steps**

1. In Hermes provider setup, select subscription/OAuth provider (e.g., Codex for OpenAI). [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)
2. Hermes opens an authorization flow:
   - Follow provider’s browser auth link. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)
   - Log in with the account that owns the subscription. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)
   - Copy/paste verification code back into Hermes if required. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)
3. Select the desired model from the subscription (e.g., GPT 5.5 under Codex). [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)

**Notes**

- Subscriptions are often cheaper for frontier models than pure per-token API usage. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)

***

## Cost Tiering and Fallback Models

### Default Model

- Defined in `config.yaml` or via CLI (`hermes config`). [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)
- Used for most tasks and sessions unless overridden (auxiliary models or explicit switches). [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)

### Fallback Model

**Purpose:** Resilience only – not intelligent routing. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)

- Triggered when the primary model errors (e.g., rate limit, quota exceeded). [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)
- Does not do dynamic routing based on complexity or token count. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)

**CLI Workflow**

- Add fallback:  
  `hermes fallback add` → select provider/model (e.g., Grok 4.3 via OAuth). [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)
- List fallback:  
  `hermes fallback list`. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)
- Remove fallback:  
  `hermes fallback remove`. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)

***

## Auxiliary Models and Per-Task Overrides

**Goal:** Use cheaper or specialized models for non-critical tasks, keep expensive models focused on core reasoning. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)

### Auxiliary Model Slots

Configured in `config.yaml` under auxiliary models. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)

Examples of slots: [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)

- vision – image analysis tasks.  
- web_extract – web page extraction.  
- title_generation – naming sessions.  
- skills_hub, MCP_approval, curator.  
- on_board, decomposer, profile_describer, session_search, flush_memories, etc. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)

**Usage Patterns**

- Assign cheaper models to background / utility tasks (title generation, session search, compression). [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)
- Optionally assign a stronger model to critical gatekeeper roles (e.g., curator that decides which skills to keep/remove). [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)

### Compression Settings

- Top-level compression block: defines compression threshold and how the agent compresses context globally. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)
- Auxiliary compression: same shape as other auxiliary tasks; sets model and provider used for compression. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)

***

## Credential Pools

**Purpose:** Rotate multiple API keys to avoid hitting provider-level rate limits. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)

- Defined in `config.yaml` under credential pool strategies (e.g., `openrouter_fill_first`, `anthropic_fill_first`). [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)
- Fill-first strategy:
  - Drain one API key until its quota is exhausted. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)
  - Automatically rotate to the next key. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)

**Inheritance**

- Cron jobs and sub-agents automatically inherit the credential pool configuration. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)
- Provides rate-limit resilience for background and scheduled tasks without extra work. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)

***

## Tool-Level Model Configuration

Some Hermes tools allow specifying dedicated providers/models. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)

**Example**

- `hermes tools` → select `reconfigure`. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)
- For image generation, choose between providers such as Grok Imagine vs GPT image models. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)

**Limitations**

- Only certain tools support per-tool provider config. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)
- No universal “per tool model routing” beyond the explicitly supported list. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)

***

## What Hermes Does Not Route Automatically

- No per-tool model routing other than the small set of tools with specific config. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)
- No per-skill model routing (you cannot assign a model per skill). [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)
- No complexity rules such as:
  - “If context > 100k, use Grok.”  
  - “If user mentions X, use provider Y.” [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)

Routing is:

- Default model + optional fallback. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)
- Auxiliary slots for specific task types. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)
- Manual, explicit model switches in-session. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)

***

## In-Session Model and Reasoning Control

### Switching Models Mid-Session

**Behavior:** Switches model without restarting the session. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)

- Command: `/model` (slash command in Hermes TUI). [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)
- Example: In a session using GPT 4.5, run `/model` → choose Grok to migrate ongoing conversation to Grok. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)

### Adjusting Reasoning Effort

- Many modern models support a `reasoning` effort parameter (e.g., low/medium/high). [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)
- Default example: Grok set to medium. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)

**Commands**

- Increase reasoning: e.g., `reasoning high`. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)
- Setting persists in config; you can later lower it for lighter workloads. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)

***

## Local Model Setup – llama.cpp

### Overview

Hermes supports local backends and treats them as OpenAI-compatible endpoints. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)

Example: llama.cpp serving a 9B-parameter model with 64k context on 12 GB RTX 3060 using quantized KV cache and flash attention. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)

### Install llama.cpp

- Install via Brew, Nix, or Winget depending on OS. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)
- Download a compatible model (e.g., quantized 9B model). [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)

### Serve Model with llama.cpp

Example pattern (paraphrased from video; adapt flags to your environment): [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)

- Run `llama-server` with:
  - `--model` pointing to model file path.  
  - `--port` for HTTP server.  
  - `--ctx-size` for context length.  
  - Quantized KV cache flag to fit model into VRAM.  
  - Flash attention for memory savings.  
  - Offload layers to GPU.  
  - Jinja template config for tool-calling format expected by Hermes. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)

Once started, server listens on chosen port. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)

### Register Local Endpoint in Hermes

1. Run `hermes model`. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)
2. Select “Custom OpenAI-compatible endpoint.” [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)
3. Set base URL to `http://localhost:<port>`. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)
4. If running locally without auth, no API key is required. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)
5. Run auto-detection; Hermes discovers the local model (e.g., “quant 3.5 9B”). [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)
6. Set it as default if desired. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)

**Verification**

- Open Hermes chat, ensure local model is active, send a simple prompt (e.g., “hello”) and confirm response from local backend. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)

***

## Local Models – vLLM, LM Studio, and Ollama

### vLLM

- Used for serving larger models on “serious” hardware. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)
- From Hermes’s perspective, same pattern as llama.cpp:
  - Run vLLM server as OpenAI-compatible endpoint.  
  - Register as custom endpoint in Hermes. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)

### LM Studio

- First-class provider as of Hermes v0.12. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)
- Use `hermes setup providers lm_studio` to integrate. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)

### Ollama

Simpler local path than llama.cpp with fewer flags but less low-level control. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)

**Steps**

1. Install Ollama from `ollama.com` (single install command). [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)
2. Pull model, for example:  
   `ollama pull qwen:3.5` (model size around 6.6 GB as in demo). [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)
3. Ensure Ollama is serving:
   - Fresh pulls usually start the server automatically. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)
   - Otherwise, use `ollama serve`. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)

**Context Length Caveat**

- Ollama defaults to ~4k tokens context, which is insufficient for Hermes. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)
- Set environment variable (example from video):  
  - `OLLAMA_CONTEXT_LENGTH=65000` (exact value depends on model). [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)

**Register in Hermes**

1. `hermes model`. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)
2. Custom endpoint: `http://localhost:11434` (default Ollama port). [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)
3. Auto-detect models; select the pulled model (e.g., Qwen 3.5). [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)
4. Set as default or optional model. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)

**Verification**

- Hermes chat should respond with a greeting from the Ollama-served model. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)

***

## Hermes Proxy – Serving Hermes as an OpenAI-Compatible Endpoint

### Concept

- Hermes can act as a proxy: your configured provider (e.g., Grok via OAuth) becomes accessible as an OpenAI-compatible endpoint on localhost. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)
- Any tool that can talk to OpenAI API can be pointed at Hermes’s proxy URL using a dummy key. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)

### Start Hermes Proxy

**Command**

- `hermes proxy start <port> <provider>` [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)

Example:

- `hermes proxy start 8765 grok_oauth` (not exact string, but pattern from video). [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)

Behavior:

- Hermes listens on specified port. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)
- Forwards calls to the configured provider using your real credentials. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)

### Inspect Models Endpoint

- In browser, open `http://localhost:<port>/v1/models`. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)
- You should see the model list for the underlying provider (e.g., all Grok models). [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)

### Configure External Tools

Any OpenAI-compatible client can hit Hermes:

- Example in video: a “Chatbot” OSS client. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)
- Set:
  - Base URL / API host: `http://localhost:<port>`. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)
  - API key: any dummy value, the proxy ignores it and attaches your real credentials. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)
- Choose model (e.g., Grok 4.3) from list, set as default, and chat. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)

Other supported patterns:

- Codex CLI. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)
- Coding agents / editors like Cline, Continue for VS Code, Cursor, aider, or your own scripts. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)

**Compatibility Notes**

- Example issue: some Groq integration needed extra glue for full compatibility in the author’s testing. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)

***

## Operational Considerations and Best Practices

- Use API keys with strict spend caps; use OAuth subs for heavy frontier-model usage. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)
- Default to a strong-but-reasonable model; use cheaper auxiliaries for:
  - Title generation.  
  - Web extraction.  
  - Compression and session search. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)
- Always define a fallback provider to survive transient errors and rate limits. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)
- For local models:
  - Carefully tune context size and KV-cache quantization to fit GPU VRAM. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)
  - Use Jinja templates for tool calling compatibility in llama.cpp deployments. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)
  - For Ollama, always override default 4k context if running with Hermes. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)
- Use credential pools when managing multiple API keys; let cron jobs inherit pools for unattended automations. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)

***

## Validation Checklist

After applying configuration changes:

- [ ] Default provider and model set in `config.yaml` or via `hermes config`. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)
- [ ] Fallback provider configured and verified with `hermes fallback list`. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)
- [ ] Auxiliary slots mapped to appropriate cheap/specialized models. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)
- [ ] Credential pool strategies configured if using multiple keys. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)
- [ ] Local model reachable at `localhost:<port>` and auto-detected by Hermes. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)
- [ ] Hermes proxy started, `/v1/models` loads provider’s models, and at least one external tool can successfully call it. [youtube](https://www.youtube.com/watch?v=1oaaOWy7wSI&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=6)

***

Would you like a second version of this runbook tailored specifically for infra-as-code (e.g., “what to put in `config.yaml` vs what to do via CLI”), with concrete YAML stubs and command snippets you can drop into your own Hermes setup?  