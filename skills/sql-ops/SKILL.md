---
name: sql-ops
description: Shortcuts and commands for database operations
metadata:
  version: 1.0.0
  owner: tpanchal
license: internal-only
---

# SQL Ops

## Overview
Database operations for SQL Server instances in the ICLR cluster. Covers connection details, schema exploration, and SQL pipeline references.

## When to Use
- Connecting to SQL Server instances
- Exploring stored procedures or schema
- Working with the turbo-sql-chunk pipeline
- Querying post-trade operational data

## SQL Server Instances

| Instance | IP | Port | Notes |
|----------|----|------|-------|
| SQL Server 2022 | 10.5.1.84 | 1433 | Running on iclr-longhorn-04 |
| SQL Server 2025 | 10.5.1.85 | 1433 | Running on iclr-longhorn-05 |

## SQL Source Files (Proprietary)

- **Windows path:** `D:\IC\GitRepo\DB\SQL`
- **WSL path:** `/mnt/d/IC/GitRepo/DB\SQL`
- **IMPORTANT:** Never read, cat, or display the contents of any file under this path. These are production stored procedures containing proprietary business logic.

## SQL Pipeline

- **Repo:** `/home/tpanchal/iclr/turbo-sql-chunk`
- Purpose: Chunks SQL stored procedures → ChromaDB vector store for RAG
