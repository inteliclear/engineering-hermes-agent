---
name: sql-ops
description: Turbo SQL Chunk pipeline operations — workflow commands, ChromaDB vector store, and SQL RAG markers
version: 1.0.0
metadata:
  hermes:
    tags: [turbo-sql-chunk, chromadb, sql-rag]
    category: pipeline
---

# SQL Ops (Turbo SQL Chunk Pipeline)

## Overview
Operations for the `turbo-sql-chunk` pipeline that chunks SQL stored procedures into a ChromaDB vector store for RAG. Covers workflow commands, collection management, and pipeline markers.

## When to Use
- Running or diagnosing the turbo-sql-chunk workflow
- Managing ChromaDB collections or vector store state
- Regenerating specs or checking pipeline health
- Working with SQL RAG markers: `run_workflow`, `generate_spec`, `sql_code`, `chroma`

## Repository

- **Path:** `/home/tpanchal/workarea/git_repo/turbo-sql-chunk`

## Pipeline Markers

| Marker | Purpose |
|--------|---------|
| `run_workflow` | Triggers the end-to-end pipeline |
| `generate_spec` | Regenerates OpenSpec files from stored procedures |
| `sql_code` | Identifies SQL code chunks in the vector store |
| `chroma` | ChromaDB collection and connection references |

## Workflow Commands

```bash
# Health check the pipeline
python3 src/run_workflow.py --health-check

# Generate specs from stored procedures
python3 scripts/generate_spec.py

# Full workflow run
python3 src/run_workflow.py
```

## ChromaDB

- **Collection:** `sql_code`
- **Endpoint:** `https://chroma.inteliclear.io`
- **Auth secret:** `kubectl get secret chromadb-auth-secret -n chromadb -o jsonpath='{.data.token}' | base64 -d`

## Critical Rules
- SQL source files at `/mnt/d/IC/GitRepo/DB/SQL` are **proprietary** — never cat or display contents
- ChromaDB collection `sql_code` is the ground truth for RAG chunks
- Always run `--health-check` before a full workflow to catch upstream drift
