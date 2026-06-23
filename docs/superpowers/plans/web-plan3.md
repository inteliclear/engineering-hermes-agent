 Here is a concise runbook-style documentation for this module of the Hermes Agent Masterclass. [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)

## 1. Purpose and Scope

- Describe how Hermes Agent handles memory across four layers: built-in markdown, FTS5 session search, external memory providers (Honcho et al.), and the Obsidian skill. [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)
- Provide practical setup and operational guidance for using Honcho as a provider and Obsidian as a long-form knowledge base. [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)

## 2. Architecture Overview

Hermes memory is structured into four additive layers (all can be active simultaneously). [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)

- Layer 1 – Built-in markdown: `memory.md` and `user.md` in `.hermes/memories`, loaded into the system prompt at session start (frozen snapshot pattern). [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)
- Layer 2 – FTS5 session search: SQLite `state.db` full-text index over all CLI/gateway/Telegram/Discord conversations with auto-prune/vacuum on startup (v0.11+). [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)
- Layer 3 – Provider plugins: pluggable memory backends (Mem0, Hindsight, SuperMemory, Honcho, others) via a memory provider ABC; only one provider active at a time; built-in markdown remains on. [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)
- Layer 4 – Obsidian skill: filesystem-based skill (`skills/note-taking/obsidian`) that writes and reads structured, wiki-linked markdown into a local Obsidian vault for project-scale knowledge. [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)

## 3. Layer 1 – Built‑in Markdown Memory

### 3.1 Files and Limits

- Location: `.hermes/memories/memory.md` (projects, environment, decisions, lessons, workflows). [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)
- Location: `.hermes/memories/user.md` (user identity, preferences, communication style). [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)
- Defaults:  
  - `memory.md`: ~2,200 characters (~800 tokens) of system prompt budget. [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)
  - `user.md`: ~1,375 characters (~500 tokens). [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)

Character caps are configured under the `memory` section in the Hermes config (`memory_character_limit`, `user_character_limit`). [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)

### 3.2 Loading and Frozen Snapshot Pattern

- At session start, Hermes reads `memory.md` and `user.md` from disk once and injects them into the system prompt as a snapshot. [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)
- During the session, the agent can call a memory tool to write changes to disk (add/replace/remove), but the system prompt is not updated until the next session. [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)
- Rationale: preserves prompt caching effectiveness; changing the system prompt mid-session would invalidate cache on every write and increase cost. [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)

### 3.3 Memory Tool API (Built‑in)

- Actions: `add`, `replace`, `remove` entries in the markdown files. [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)
- No `read` action: content is automatically injected into the system prompt on session start. [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)
- Entries separated by the section sign `§` character. [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)
- Replace/remove use substring matching via `old_text`; short unique substrings are enough, ambiguous matches return an error requiring more specific text. [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)

### 3.4 Safety and Quality Controls

Four safeguards make the small cap workable. [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)

- Cap-as-feature:  
  - Hard caps enforce curation instead of unbounded accumulation; when exceeding the cap, the tool errors and forces the agent to consolidate/delete. [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)
- Save/skip policy:  
  - Save: preferences, environment, stable facts, corrections, conventions, completed work, explicit save requests. [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)
  - Skip: trivial Q&A, web-searchable facts, raw data dumps, session-specific randomness. [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)
- Silent dedupe:  
  - Adding identical content returns success but does not create a duplicate entry, avoiding LLM retry spam. [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)
- Injection scanning:  
  - Proposed entries are scanned for prompt injection and credential exfiltration patterns (e.g., SSH keys, malicious instructions, invisible Unicode) before write. [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)

### 3.5 Operational Usage

- You can manually inspect and edit `memory.md`/`user.md` to audit, fix contradictions, seed initial facts, and move them between agents. [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)
- Recommended user seeding: short-term goals, current projects, usage intentions for the agent (within the `user.md` cap). [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)

## 4. Layer 2 – FTS5 Session Search

### 4.1 Data Store and Indexing

- All CLI and gateway sessions are stored in `.hermes/state.db` (SQLite). [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)
- Full-text index (FTS5) over all conversations: Telegram, Discord, CLI, gateway, including message text. [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)

### 4.2 Tool Behavior

- Agent has a `session_search` tool to query its own history. [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)
- Results are summarized using a Gemini Flash summarization layer so the agent gets condensed history, not raw transcripts. [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)
- Agent invokes this autonomously when it believes a prior conversation may be relevant (“what were the top 10 name suggestions for the luxury bag and watch app…”). [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)

### 4.3 Maintenance and Cost

- In newer Hermes versions, `state.db` is auto-pruned and vacuumed on startup to avoid unbounded growth. [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)
- Persistent markdown vs session search comparison: [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)
  - Markdown memory: small, always in context, fixed token cost, key facts only.  
  - Session search: unlimited history, on-demand token cost (search + summarization), used for detailed or ephemeral recollection (e.g., brainstorming lists).  

## 5. Layer 3 – Memory Provider Plugins

### 5.1 Provider Framework

- Hermes exposes a pluggable memory provider ABC; third-party backends implement the interface and register via the Hermes plugin loader. [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)
- Only one provider can be active at a time (e.g., Honcho or Mem0, not both), and switching providers does not migrate prior provider data. [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)
- Built-in markdown memory stays active regardless of provider configuration. [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)

### 5.2 Provider Responsibilities (When Active)

With a provider configured, Hermes automatically: [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)

- Injects provider context into the system prompt.  
- Prefetches relevant memories before each turn.  
- Syncs conversation turns to the provider after each response.  
- Extracts memories on session end.  
- Exposes provider-specific tools to the agent (e.g., Honcho tools).  

Core CLI commands: `hermes memory setup`, `hermes memory status`, `hermes memory off`. [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)

### 5.3 Provider Landscape (High-Level)

- Mem0: server-side LLM-based fact extraction from conversations; second LLM pass categorizes writes as insert/update/delete/no-op; embeds extracted facts, not raw text. [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)
- Hindsight: knowledge graph + entity resolution + multi-strategy retrieval, including full conversation turns and tool calls; provides a Reflect synthesis tool. [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)
- SuperMemory: multi-container partitioning (per client/project/team); context fencing to avoid recursive pollution; session graph ingest at session end. [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)
- Honcho: first-party integration for Hermes; dialectic user modeling with its own CLI surface; focus of this module’s detailed walkthrough. [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)

## 6. Honcho – Configuration and Operation

### 6.1 Prerequisites

- Honcho account at `app.honcho.dev`; optional credit card for initial free credits (e.g., 100 credits at the time of recording). [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)
- Honcho API key created in the Honcho UI. [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)

### 6.2 Setup Workflow (Hermes CLI)

1. Run `hermes memory setup`. [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)
2. Select provider: `Honcho`. [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)
3. Choose deployment: `cloud` (or configure local self-hosted). [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)
4. Paste API key when prompted. [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)
5. Enter:  
   - Username (e.g., `TomB`). [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)
   - AI peer name (e.g., `Hermes`). [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)
   - Workspace ID (e.g., `Hermes`). [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)
6. Configure Honcho options interactively: [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)
   - Observational mode (default: directional; each AI peer builds its own view).  
   - Write frequency (e.g., async, per session, per end turns; defaults recommended).  
   - Recall mode (e.g., hybrid, uncapped).  
   - Dialectic cadence (e.g., every other turn = `2`, the recommended option).  
   - Dialectic reasoning level (low/medium/max; defaults to medium/standard).  
   - Session strategy (per session, per directory, per repo; example: per session).  

A `hancho.json` file is written under your Hermes home directory with these settings. [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)

### 6.3 Honcho Data Model

- Workspace → Peers → Sessions → Messages hierarchy. [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)
- Each Hermes profile (e.g., coder, writer) gets its own AI peer in a shared workspace; peers share a user representation while maintaining their own identity. [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)
- Honcho focuses on modeling the user, not just individual facts: it accumulates conclusions about preferences, communication patterns, and goals via dialectic reasoning. [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)

### 6.4 Honcho Tools

Main tools exposed to the agent: [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)

- `honcho_conclude`: triggers server-side dialectic reasoning to update user model with new conclusions.  
- `honcho_context`: retrieves relevant context for the current turn.  
- `honcho_profile`: views/updates user profile information.  
- `honcho_search`: semantic search across stored conclusions and observations.  

Example in the module: agent asks for user’s name; upon being told “Tom B,” it uses `honcho_conclude` and also updates built-in `user.md`. [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)

### 6.5 Supporting Commands

- `hermes honcho status`: inspect observations, peer identities, and confirm connectivity. [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)
- `hermes honcho mode`: change recall/observation modes after initial setup. [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)
- `hermes honcho map`: map current directory to a named session for project-scoped modeling. [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)

## 7. Layer 4 – Obsidian Skill

### 7.1 Nature of the Skill

- Obsidian is implemented as a bundled skill, not a memory plugin; it does not occupy the provider slot. [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)
- Path: `skills/note-taking/obsidian`. [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)
- Operates directly on the filesystem; no MCP server and no Obsidian app required on the agent host (headless Linux compatible). [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)
- Older `obsidian` config option is deprecated and no longer used; rely on environment variables instead. [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)

### 7.2 Setup Steps

1. Install Obsidian desktop on your local machine (for human browsing and editing). [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)
2. Create/open a folder as an Obsidian vault (this will be your Hermes vault). [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)
3. Set the Obsidian vault path via environment variable (e.g., `OBSIDIAN_VAULT_PATH`) to match the directory used by the skill. [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)

Once configured, the Hermes Obsidian skill will read/write markdown files in that vault. [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)

### 7.3 Usage Pattern (HVAC Example)

- Use Hermes to research a topic (e.g., Bay Area HVAC providers and their equipment lines). [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)
- Prompt the agent to:  
  - “Use the Obsidian skill to store information about the providers and the HVAC model companies.” [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)
- The skill will:  
  - Create notes per provider with details (names, links, services). [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)
  - Create higher-level index notes (e.g., equipment models, provider index) using wiki links for cross-referencing. [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)

This yields a project-scale knowledge base suited for long-term reference and future agent queries, beyond the 1,300-token markdown memory cap. [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)

### 7.4 Invocation

- Natural language prompting (“use the Obsidian skill”) works; Hermes will route to the appropriate skill tools. [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)
- Alternatively, use the Obsidian slash command (e.g., `/obsidian`) to read, search, or create notes in the vault. [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)

## 8. Operational Recommendations

- Use Layer 1 for stable, high-signal personal and project facts that should always be in context. [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)
- Rely on Layer 2 for “did we talk about X before?” queries and large historic logs (brainstorms, lists, etc.). [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)
- Choose one Layer 3 provider that matches your needs (fact extraction vs knowledge graph vs multi-tenant partitioning vs dialectic user modeling), and avoid switching without a migration plan. [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)
- Treat Obsidian as a long-form project notebook where Hermes both writes and later reads structured notes for complex domains or multi-step projects. [youtube](https://www.youtube.com/watch?v=ZKZLko9kLm4&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=2)

Would you like a second version of this runbook in YAML or Markdown-ops format that you can check into a repo alongside your Hermes configs? 