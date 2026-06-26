# Web Plan Consolidation: Execution Plan

**Date**: 2026-06-25  
**Status**: Draft — pending review

---

## Problem

`docs/superpowers/plans/` contains 4 raw research files that overlap, are unprocessed, and have no actionable output.

| File | ~Lines | Type | Source |
|------|--------|------|--------|
| `web-plan1.md` | 260 | Research article summary | Glukhov.org, Vectorize, Nous docs |
| `web-plan2.md` | 163 | Architecture design doc | YouTube + author notes |
| `web-plan3.md` | 198 | YouTube video transcript/runbook | Hermes Masterclass videos |
| `web-plan4.md` | 57 | YouTube video chapter notes | Hermes Masterclass videos |

Issues:
- Plans 1 + 3 overlap on the 4-layer memory model (different sources, same content)
- Plans 3 + 4 cover adjacent topics (memory → skills) from the same video series
- All end with unanswered questions or dangling citations
- Nothing is distilled into actionable rules or memory

## Proposed Actions

| # | Action | Output | Why |
|---|--------|--------|-----|
| **A** | Merge plans 1 + 3 into a single **Hermes Memory Reference** doc | `docs/superpowers/hermes-memory-reference.md` | Eliminates ~70% overlap between plan1 and plan3; consolidates the 4-layer model, provider ecosystem, and operational recommendations |
| **B** | Distill plan 4 into a **Skills System Reference** | `docs/superpowers/hermes-skills-reference.md` | Clean reference for SKILL.md anatomy, curator, auto-written skills |
| **C** | Extract operational rules from A + B into `CLAUDE.md` additions | Rules for: memory write triggers, when to use session_search vs persistent memory, skill invocation patterns | Makes lessons surface automatically in future sessions |
| **D** | Move `web-plan2.md` to archive (VPS bridge is unacted design doc) | `docs/superpowers/plans/_archive/vps-bridge-design.md` | Keeps the design but signals it's pending, not active |
| **E** | Delete original `web-plan[1-4].md` files | — | Clean up source files after consolidation |

## Expected Outcome

```
docs/superpowers/
├── plans/
│   └── _archive/
│       └── vps-bridge-design.md     # (D) unacted design
├── hermes-memory-reference.md     # (A) consolidated from plans 1+3
├── hermes-skills-reference.md     # (B) distilled from plan 4
└── CLAUDE.md additions            # (C) rules extracted
```

## What Gets Lost (Acceptable)

- YouTube video timestamps and citation markers
- "Would you like a second version..." trailing questions
- Redundant explanations of the same concepts from different videos

## What Gets Kept

- 4-layer memory architecture (prompt memory, session search, providers, Obsidian)
- Honcho/Hindsight/Mem0 provider comparison
- Operational recommendations for when to use each layer
- Skills system anatomy and curator workflow
- The VPS bridge design (archived, not deleted)
