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
