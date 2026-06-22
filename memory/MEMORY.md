# ICLR Team Memory

Shared context about the ICLR (Inteliclear) cluster and infrastructure.

## Cluster Overview

- **Type:** k3s v1.35.5+k3s1 on Proxmox VE
- **GitOps repo:** `/home/tpanchal/iclr/glowing-octo-palm-tree`
- **VIP:** 10.5.1.60 (kube-vip)

## Nodes

| Node | IP | Role | Notes |
|------|----|------|-------|
| k3s-01 | 10.5.1.55 | control, etcd | NoSchedule |
| k3s-02 | 10.5.1.56 | control, etcd | NoSchedule |
| k3s-03 | 10.5.1.57 | control, etcd | schedulable |
| k3s-04 | 10.5.1.58 | worker | 8c/16g |
| k3s-05 | 10.5.1.59 | worker | 8c/16g |
| lh-01 | 10.5.1.61 | storage | tainted |
| lh-02 | 10.5.1.62 | storage | tainted |
| lh-03 | 10.5.1.63 | storage | tainted |
| lh-04 | 10.5.1.19 | storage | physical; SonarQube, Prometheus, Grafana |
| lh-05 | 10.5.1.18 | storage | physical |
| dgx-spark | 10.5.1.49 | inference | GB10/128G; SSH tpanchal@10.5.1.49, key ~/.ssh/iclr-dgx-spark |

## LLM Endpoints

| Alias | Backend | Model |
|-------|---------|-------|
| reasoning | GPU LXC 10.5.1.36 | Qwen3.5-27B-UD-IQ3_XXS |
| coding | CPU LXC 10.5.1.33 | Qwen3-Coder-30B-A3B-IQ4_XS |
| smart | GPU LXC 10.5.1.36 | GPT-OSS-20B |
| fast | Vulkan 10.5.1.146 | Qwen3-4B-Instruct-2507 |
| coder | 10.5.1.12 + 10.5.1.19 | Qwen2.5-Coder-3B |
| coder_pro | DGX Spark 10.5.1.49 | AEON Qwen3.6-27B NVFP4 |

LiteLLM proxy: `https://litellm.inteliclear.io/v1` (ns: `litellm`)
Health: `kubectl -n litellm rollout status deploy/litellm`

## SSH Access

```bash
# Cluster nodes (user: icadm)
ssh -i ~/.ssh/iclr-dg-build icadm@<ip>
# DGX Spark
ssh -i ~/.ssh/iclr-dgx-spark tpanchal@10.5.1.49
```

## Networking

- MetalLB: 10.5.1.80–100 (L2 mode)
- Traefik: 10.5.1.80 (`*.inteliclear.io`)
- IBM MQ: 10.5.1.81 | SFTPGo: 10.5.1.82/83
- SQL Server 2022: 10.5.1.84 | SQL Server 2025: 10.5.1.85
