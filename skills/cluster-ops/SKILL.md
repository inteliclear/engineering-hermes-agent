---
name: cluster-ops
description: ICLR k3s cluster maintenance — health checks, rolling updates, drift detection, and GitOps manifest deployment
version: 1.0.0
metadata:
  hermes.tags: [k3s, gitops, maintenance]
  hermes.category: infrastructure
---

# Cluster Ops

## Overview
Operational procedures for the ICLR k3s cluster. Covers health checks, updates, drift detection, and common maintenance tasks.

## When to Use
- Running cluster health checks or post-upgrade verification
- Performing rolling node updates
- Detecting GitOps drift between manifests and live state
- Troubleshooting node, pod, or service issues
- Managing kube-vip, Longhorn, or MetalLB configurations

## Quick Reference

| Task | Command |
|------|---------|
| GitOps repo | `/home/tpanchal/iclr/glowing-octo-palm-tree` |
| Cluster update | `./scripts/maintenance/cluster_update.py` |
| Drift detection | `python3 scripts/maintenance/detect-drift.py --dry-run` |
| Health check | `./scripts/health/py/cluster_health_check.py --json` |
| Access Grafana | `./scripts/health/access_grafana.sh` |

## Cluster Health Check

```bash
# 3-tier check: GOOD (0 failures), DEGRADED (1-2), CRITICAL (3+)
./scripts/health/py/cluster_health_check.py --json
```

## Rolling Node Updates

```bash
# Full cluster update (checkpoint/resume, Longhorn health-wait, APT lock)
./scripts/maintenance/cluster_update.py --reset \
  --ssh-user icadm \
  --ssh-key ~/.ssh/iclr-dg-build

# Skip a known-offline node
./scripts/maintenance/cluster_update.py --reset \
  --ssh-user icadm \
  --ssh-key ~/.ssh/iclr-dg-build \
  --no-run-precheck

# Known PDB drain blockers:
# - cert-manager PDBs use wrong selector after Helm upgrades
# - Prometheus PDB (minAvailable=1, single replica)
```

## Post-Upgrade Drift Check

After any k3s upgrade or cluster maintenance, **always** verify manifests match live state:

```bash
python3 scripts/maintenance/detect-drift.py --dry-run
```

## Manifest Deployment

```bash
# Dry-run before applying
kubectl apply -f manifests/<service>/ --dry-run=server

# Apply to live cluster
kubectl apply -f manifests/<service>/

# git-crypt prerequisite for encrypted services (Kutt, PrivateBin, Passbolt)
git-crypt unlock
```

## Critical Rules
- All changes via GitOps manifests, verified by `detect-drift.py`
- Traefik MUST use 10.5.1.80 (DNS depends on it)
- No NodePort/hostPort — ingress via Traefik + MetalLB only
- No hostPath for persistent data — Longhorn PVCs only
- Traefik runs in `traefik` namespace, NEVER `kube-system`
