---
name: general
description: ICLR development environment reference — repo map, LiteLLM proxy, and SSH access shortcuts
version: 1.0.0
metadata:
  hermes.tags: [liteLLM, repos, environment]
  hermes.category: reference
---

# General Engineering

## Overview
General development shortcuts, repository references, and common tooling commands used across the ICLR engineering ecosystem.

## When to Use
- Navigating between ICLR projects and repos
- Accessing the LiteLLM proxy or inference endpoints
- Setting up development environments
- Quick references for repo locations and purposes

## Repository Map

| Repo | Purpose |
|------|---------|
| `glowing-octo-palm-tree` | GitOps source of truth — all k3s manifests, scripts, runbooks |
| `post-trade-wiki` | Knowledge graph (Obsidian vault) for DTCC Equities Clearing & Settlement |
| `turbo-sql-chunk` | Production pipeline: chunks SQL stored procedures → ChromaDB vector store |
| `post-trade-sql-spec` | Evaluation playground for OpenSpec vs Spec Kit on post-trade SQL |
| `microgpt` | Lightweight character-level GPT trained on post-trade operational data |
| `IC-ML` | ML experiments and strategies for ICLR workloads |
| `InteliclearPy` | Python SDK/client library for Inteliclear internal APIs |
| `iclr-inference` | Inference runner management — vLLM/llama.cpp configs, DGX Spark bring-up |
| `opencode` | OpenCode CLI — testing LiteLLM model aliases against the ICLR inference stack |

## LiteLLM Proxy

```bash
# In-cluster endpoint
http://litellm.litellm.svc.cluster.local:4000/v1

# Public endpoint (via Traefik)
https://litellm.inteliclear.io/v1

# Verify
kubectl -n litellm rollout status deploy/litellm
curl -s https://litellm.inteliclear.io/v1/models -H "Authorization: Bearer <master-key>"
```

## Development Environment

- **OS:** WSL2 with SSH tunnel to Proxmox
- **SSH key:** `~/.ssh/iclr-dg-build`
- **SSH user:** `icadm` for cluster nodes
- **Proxmox:** `root@10.5.1.46` (GPU), `root@10.5.1.35` (CPU LXC)
- **DGX Spark:** `tpanchal@10.5.1.49`, key `~/.ssh/iclr-dgx-spark`
