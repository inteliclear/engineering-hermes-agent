Here’s a runbook-style outline for this video, aligned to the actual chapters and flow of the talk. [youtube](https://www.youtube.com/watch?v=L3WdVeMaYZM&list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX&index=4)

- **Intro: Memory vs. Skills**  
Explains that in Hermes, memory is what the agent knows (state, vaults, search), while skills are what it does (procedures, workflows, tool orchestration). Frames the module as a deep dive into the SKILL.md format, bundled skills, optional/community skills, auto-written skills, and the Curator, ending with a live skill build.[1, {ts:0}]

- **SKILL.md Anatomy & Progressive Disclosure**  
Covers the structure of a skill: one directory, one required `skill.md` with front matter (name, description) plus optional `reference`, `templates`, `scripts`, and `assets` folders. Emphasizes that description is the “picker hint” that decides if the skill ever fires, while body sections like “when to use”, “procedure”, “pitfalls”, and “verification” are only read after selection. Introduces progressive disclosure: Hermes loads only titles and descriptions into the skills list, then loads the full body for the chosen skill to avoid token bloat.[1, {ts:110}]

- **Bundled Skills Overview (24 Categories / ~80 Skills)**  
Shows the bundled skills tree under `Hermes/skills`, organized into roughly two dozen categories such as research, GitHub, MLOps, productivity, and creative. Notes that many categories you will never touch, but Hermes ships lean, with high‑value skills that cover common workflows while keeping context small through progressive disclosure.[1, {ts:360}]

- **Research Skills: Archive, LLM Wiki, Blog Watcher, Polymarket, Paper Writing**  
Walks through the research category: `archive` for arXiv papers, LLM Wiki as an Obsidian vault, blog watcher for RSS monitoring and summaries, Polymarket for prediction market data, and research paper drafting with citations. Demonstrates a live workflow: “research recent papers on recursive reasoning models,” where Hermes picks `archive` and a `paper summary` skill, then uses the local Hermes web dashboard to inspect which research skills fired.[1, {ts:404}]

- **GitHub & Dev Skills: PR Workflow, Code Review, Repo Management, Debugging**  
Shows GitHub and software-development skills such as GitHub PR workflow (branch‑to‑merge lifecycle), GitHub code review, GitHub issues/repo management, systematic debugging (hypothesis‑driven diagnostics), writing plans (emit plan before code), and sub‑agent‑driven development. Runs an example against a Turbo Quant PyTorch repo, asking Hermes to check issues; Hermes uses GitHub issue and code‑inspection skills, then returns an action list based on the repo state.[1, {ts:570}]

- **MLOps Skills: Local Models, Training, Inference, Vector DBs**  
Describes MLOps skills as mostly optional due to the variety of stacks: evaluation, Hugging Face hub, inference models, research helpers, training, and vector database skills organized under an `mlops` directory. Demonstrates asking Hermes for “three model options to run locally on an RTX 3060 with llama.cpp”; Hermes invokes the `llama.cpp` inference skill to recommend appropriate quantized models and shows command examples (e.g., 3‑ or 8‑bit quant with flash‑attention) for local deployment.[1, {ts:726}]

- **Productivity Skills: Google Workspace, Notion, Linear, PDF/Docs/PowerPoint**  
Covers skills aimed at day‑to‑day business work: Google Workspace (Gmail, Calendar, Drive, Docs, Sheets via CLI or Python), Notion (read/write pages and databases using the new dev platform), Linear (issues and project cycles via GraphQL), `nano-pdf`, PowerPoint, OCR, and document skills. Demonstrates the PowerPoint skill taking a markdown concept document (for the “Infinite Humans Among AI” game) and generating a slide deck, leveraging helper Python scripts in the `scripts` directory for slide add/cleanup and design tweaks.[1, {ts:885}]

- **Creative Skills: Manim, Excalidraw, P5.js, ComfyUI, TouchDesigner, Humanizer, Pixel Art**  
Introduces creative skills for animation and visual content: Manim video for explainer animations from text, Excalidraw for hand‑drawn‑style diagrams, P5.js for generative art and thumbnails, ComfyUI as a Stable Diffusion front‑end, TouchDesigner for advanced video effects, and Humanizer for stripping AI‑isms from text. Runs a new example with the `pixel-art` skill to convert the creator’s profile image into retro pixel art, showing how references (e.g., palette definitions) and Python scripts collaborate to produce SNES‑style output.[1, {ts:1094}]

- **Optional Skills and Categories (Finance, Blockchain, etc.)**  
Explains that beyond bundled skills there are 17 optional categories (e.g., blockchain, finance, health, security) that can be installed as needed. Notes that optional skills are installed by fetching the skill directory and dropping it under `Hermes/skills`, but recommends a conservative security posture and preference for official or self‑authored skills due to prompt‑injection and malicious‑skill concerns.[1, {ts:1347}]

- **Skill Sources & Hubs: Bundled, Official Optional, Skills.sh, GitHub Taps, Hugging Face Index, Marketplaces**  
Maps the full skill‑sourcing picture: bundled skills maintained in the Hermes repo, official optional skills also maintained by Hermes, Vercel’s `skills.sh` library, GitHub taps (including the `huggingface/skills` community index surfaced automatically in `hermes skill browse`), plus provider‑specific taps (OpenAI, Anthropic, etc.). Adds “well‑known marketplaces” like Claw Hub and Lobe Hub, plus the ability to install skills by direct URL or by copying a folder, with a reminder to rely on the built‑in security scan and to avoid untrusted sources.[1, {ts:1380}]

- **Agent‑Written Skills as Procedural Memory**  
Describes Hermes’ ability to write its own skills via a `skill_manage` tool that can create, patch, edit, delete, and manage multi‑file skills. After complex or error‑recovery turns, Hermes spawns a rubric‑graded background fork (using the same model/provider) that asks whether the last workflow is reusable; if so, it writes a new `skill.md` into `Hermes/skills` and marks it `agent_created` so the Curator can prune it more aggressively than user‑written skills. Clarifies when this triggers: multi‑tool complex tasks, successful recovery from errors, user‑corrected flows, or novel workflows the agent judges worth saving.[1, {ts:1546}]

- **Example Agent‑Created Skill: Hermes Dashboard Plugin Development**  
Shows a concrete auto‑generated skill: `hermes-dashboard-plugin-development`, created while building a Hermes web dashboard plugin in a previous video. The description targets building and verifying plugins including frontend tab bundles, FastAPI plugin APIs, MCP backends, read‑only data sources, and smoke tests; the body includes “when to use,” step‑by‑step procedures, recommended workflows, and an open‑source release checklist. Highlights the benefit: repeated plugin work reuses the skill instead of re‑prompting, saving time and tokens.[1, {ts:1691}]

- **Plugins vs Skills: Conceptual Difference**  
Clarifies that plugins and skills are separate subsystems: plugins are executable surfaces that add new software, UI, APIs, or backends (memory providers, context engines for image/video gen, model providers, platforms) configured in the Hermes config. Skills, by contrast, are primarily instructions plus light helper scripts. Provides a rule of thumb: if it changes the agent’s knowledge or workflow, model it as a skill; if it changes Hermes’ platform capabilities or interfaces, implement it as a plugin.[1, {ts:1796}]

- **Curator: Autonomous Skill Maintenance**  
Introduces the Curator (v12, enhanced in v13) as an autonomous process that grades, prunes, and consolidates skills on a 7‑day cron schedule. It scores each skill, prunes unused/unpinned ones, and consolidates similar skills that are drifting into duplication, with per‑run reports logged under a `curator` path and configuration under `auxiliary.curator`, including its own model selection. v13 improvements include synchronous `hermes curator run` and CLI operators such as `archive`, `prune`, `list-archive`, `status`, and `pin`.[1, {ts:1916}]

- **Pinning & Safety Around Skills**  
Explains that bundled and hub‑installed skills are gated so the Curator cannot modify them, serving as a safety mechanism. Custom and agent‑created skills can be explicitly pinned with `hermes curator pin <category/skill>` so they are immune from pruning or consolidation; a `curator status` call shows histories of runs and any modifications. Demonstrates pinning the newly built `business/unit-lookup` skill so it remains stable as part of the HVAC quoting workflow.[1, {ts:2016}]

- **Live Build: Unit Lookup Skill for HVAC Quotes**  
Defines a spec for a business skill `unit-lookup` that takes an HVAC model number, contractor name, and quoted price, then searches an Obsidian vault of units; if not found, it does web lookup, writes a new note to the vault (including image search), and produces a markdown “unit card” with specs, brand notes, price, and photo. Prompts Hermes (using its `hermes-agent-skill-authoring` skill) to author `unit-lookup` as a new `skill.md` under a `business` category, then tests it by asking for a specific Carrier model and verifying that Hermes creates the vault entry and markdown card.[1, {ts:2075}]

- **Platform & Channel Scoping for Skills**  
Notes that each skill can be scoped by operating system or channel, so incompatible skills are hidden on certain OSes and heavy skills (e.g., MLOps) can be disabled for lighter frontends like Telegram while remaining active on CLI. Mentions the `hermes skill` interactive UI as the control surface for per‑channel enable/disable, and that Hermes’ skill format is compatible with the agentskills.io standard, making skills portable to other agent harnesses such as Claude Code, Cursor, or Codex.[1, {ts:2311}]

- **Closing & Next Module Teaser (Models & Providers)**  
Recaps the module: anatomy of `skill.md`, bundled and optional skills, creative/productivity/dev/MLOps examples, agent‑written skills, the Curator, and the unit‑lookup build. Previews Module 5 on models and providers: 20‑plus model providers, smart routing, cost‑tiered fallback chains, SuperGrok OAuth with 1M‑token context, Grok 4, OpenAI‑compatible local proxies that expose Claude/ChatGPT Pro subscriptions as Codex endpoints, and auxiliary‑model usage.[1, {ts:2414}]

Would you like this turned into a literal markdown `RUNBOOK.md` template (with sections, commands, and checklists) that you can drop into your own Hermes ops repo?