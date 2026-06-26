# Review: web-plan-consolidation.md

**Reviewer**: Claude (claude-sonnet-4-6)  
**Date**: 2026-06-25  
**Status**: Pre-execution feedback

---

## Overall Assessment

Directionally correct. The grouping (memory reference, skills reference, archive VPS bridge) is logical and the problem statement is accurate. A few things to sharpen before executing.

---

## Strengths

- The problem statement is accurate — plan1 and plan3 overlap on the 4-layer model, and plan3+4 are the same video series covering adjacent topics.
- Archiving plan2 is the right call; it's a clean unacted design doc that shouldn't be discarded entirely.
- Action C (CLAUDE.md rules) is the highest-value output because the lessons surface automatically in future sessions — good instinct to include it.

---

## Issues

### 1. The ~70% overlap claim between plan1 and plan3 is overstated

Plan1 is a **research synthesis** with depth on: provider ecosystem details (LanceDB, RetainDB, ByteRover, OpenViking, Holographic), Python async integration patterns, and a strengths/limitations analysis. Plan3 is an **operational runbook** with specific Honcho setup steps (CLI wizard walk-through, `hancho.json`, data model, supporting commands) that plan1 doesn't cover. The actual overlap is closer to 40% — both cover the 4-layer model, frozen snapshot, tool API, and providers overview. The unique content in each file is substantial and complementary, not redundant.

### 2. Obsidian skill from plan3 needs explicit routing to the skills reference

Plan3 Section 7 covers the Obsidian skill — it doesn't occupy the provider slot, it operates on the filesystem, and it's a bundled skill. The consolidation plan says "merge plans 1+3 → memory reference," but the Obsidian content from plan3 belongs in the **skills reference**, not the memory reference. This needs an explicit call-out, otherwise whoever executes Action A will either duplicate it or leave it out.

### 3. Action C (CLAUDE.md rules) is the most valuable but least specified

Right now it reads as a vague category list. Before executing, draft the actual rules:

- **When to write memory**: corrections, inferred preferences, env facts, conventions, completed complex workflows, explicit requests — skip trivial Q&A, raw data, session-specific ephemera
- **Session search vs persistent memory**: key facts → memory; "did we talk about X?" → `session_search`
- **Memory consolidation trigger**: >80% usage → consolidate into dense multi-sentence entries before adding
- **Skill invocation patterns**: agent auto-selects by description; explicit `/skill` when forcing

Without a draft, Action C risks being the one thing that doesn't get done.

### 4. Plan4 has content that bleeds into CLAUDE.md, not just a skills reference

Plan4 covers: Curator security posture (avoid untrusted skill sources — prompt injection risk), plugins vs skills boundary (knowledge/workflow → skill; platform capability/interface → plugin), and platform/channel scoping. Some of this is architectural principle that belongs in CLAUDE.md as rules, not in a reference doc. Action B currently treats plan4 as a simple distillation — it needs a split decision.

### 5. Plan3 adds SuperMemory which plan1 misses

Plan3 Section 5.3 covers SuperMemory (multi-container partitioning, context fencing, session graph ingest at session end). Plan1's provider ecosystem section doesn't mention it. The consolidated memory reference needs to pull SuperMemory from plan3, or it'll have an incomplete provider table.

### 6. Footnote/citation handling is unaddressed

Plan1 has 7 inline footnote references (`[^1]`–`[^7]`) throughout. The consolidation plan doesn't say whether the merged doc keeps them, strips them, or moves them to a references section. These are provenance for specific claims (character limits, API behavior, performance properties) — losing them makes the reference harder to update or verify later.

### 7. Expected outcome tree has a type mismatch

`CLAUDE.md additions` is listed as a leaf alongside the two new reference files, but it's an **edit to an existing file**, not a new output artifact. Worth separating in the plan to avoid it being forgotten as "the third new file."

---

## Summary

| Item | Status |
|------|--------|
| Archive plan2 | Correct as written |
| Delete original files after consolidation | Correct |
| Merge plan1+plan3 → memory reference | Correct grouping, but route plan3 §7 (Obsidian) to skills reference instead |
| Distill plan4 → skills reference | Add a split: some plan4 content is CLAUDE.md rules, not reference doc |
| CLAUDE.md rules (Action C) | Needs a draft of the actual rules before executing |
| Provider table completeness | Add SuperMemory from plan3 to merged doc |
| Citations | Decide whether to keep/strip/migrate footnotes |

The plan is ready to execute on A, B, D, E once you clarify the Obsidian routing and flesh out the CLAUDE.md rules draft.
