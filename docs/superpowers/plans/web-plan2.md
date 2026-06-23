# VPS-on-Prem Hermes Bridge Architecture Notes

Adapted from [YouTube video](https://www.youtube.com/watch?v=dcXmUUZvDLE). Treat the VPS as the "public edge" Hermes and a local/on‑prem backend as the "deep access" Hermes, then route between them instead of trying to expose on‑prem directly.

***

## Target Architecture

- **VPS Hermes gateway + agent**  
  - Always‑on, Internet‑facing.  
  - Hosts Telegram/Discord adapters and your "external" Hermes agent.

- **On‑prem Hermes agent(s)**  
  - Run on a Docker backend or bare metal inside the secure network.  
  - Have full access to SQL Server, file shares, internal HTTP services, etc.

- **Bridge between them**  
  - Treat the VPS agent as an orchestrator that delegates "on‑prem" tasks to a second agent via:
    - A secure API endpoint reachable from VPS to on‑prem (preferred), or  
    - A message queue/bus where both sides can see a queue (e.g., cloud MQ), or  
    - Periodic pull model from on‑prem to VPS if there is no inbound path.

The video's pattern of "one gateway, multiple surfaces, one agent" stays on the VPS; your on‑prem agent is an extra backend that the VPS agent calls for privileged work.

***

## Runbook Layer 1: Surfaces and External Agent (VPS)

This part is basically the video, unchanged, but explicitly scoped to **external‑safe tasks**.

1. **VPS terminal backend**  
   - Install Hermes on the VPS using the same installer you used locally.
   - Configure terminal backend as `local` on the VPS (no on‑prem access by design).

2. **Gateway + adapters**  
   - On the VPS, configure:
     - Telegram bot (BotFather token, restricted user IDs).  
     - Discord bot (token, intents, permissions).
   - Install gateway as a `systemd` user service and enable linger as in the video.

3. **Agent policies**  
   - Define a policy for the VPS agent like:
     - "Do not access internal systems; treat all data as Internet‑only plus what users send explicitly."  
   - Keep this agent focused on:
     - Planning, summarization, conversational workflows.  
     - Producing "task tickets" for on‑prem execution, not running SQL directly.

***

## Runbook Layer 2: On‑Prem "Execution" Hermes

Here you mirror the Hermes install from the video, but keep it entirely inside your network.

1. **Backend choice**  
   - Use Docker backend on an on‑prem Linux host so the agent's shell is sandboxed but still has network access to SQL Server and internal HTTP/SMB as needed.
   - Configure `hermes setup terminal` with:
     - Backend: Docker.  
     - Mounts: only what it needs (code, tools, client libs).  
     - No direct `.ssh` or file shares unless required and documented.

2. **Skill and tool layer**  
   - Add Hermes skills that correspond to your on‑prem operations:
     - SQL execution against specific databases (with parameterization and logging).  
     - File ingestion from known paths.  
     - Internal REST/GraphQL calls.

3. **Interface for the VPS agent**  
   - Expose a low‑surface‑area interface that the VPS agent can call:
     - **If inbound to on‑prem is allowed**: an HTTPS API on your DMZ or via VPN (e.g., Tailscale, point‑to‑point WireGuard).  
     - **If only outbound from on‑prem is allowed**: a queue‑based pattern where:
       - VPS writes tasks to a cloud queue.  
       - On‑prem worker (Hermes + script) polls the queue, executes, writes results back.

The important distinction from the video is that the "terminal backend" used by your execution agent is never the same environment as the Internet‑reachable VPS; they collaborate but remain separated.

***

## Runbook Layer 3: Task Delegation Pattern Between Agents

To keep this concrete, here are two patterns you can document.

### Pattern A: Direct API Bridge (Preferred if you can open a path)

**On‑prem side**

- Run a small HTTP service (could be FastAPI, ASP.NET, or even a simple Flask app) that:
  - Accepts a signed request from VPS (JWT/API key).  
  - Invokes Hermes tools locally to perform the task.  
  - Returns compact results: JSON, CSV snippets, or signed URLs for larger artifacts.

**VPS side**

- Add a "tool" in the VPS Hermes agent config for "Call OnPrem Executor" that:
  - Takes structured input: system name, query type, parameters.  
  - Calls the on‑prem API endpoint.  
  - Receives structured output and converts to natural language for Telegram/Discord.

Your Telegram request flow then becomes:

1. User → Telegram bot on VPS.
2. VPS Hermes agent:
   - Plans: "I need the on‑prem executor."  
   - Calls the "OnPrem Executor" tool (HTTP call).  
3. On‑prem Hermes executes the privileged work in its Docker backend.  
4. Response flows back to VPS → Telegram.

### Pattern B: Queue Bridge (when on‑prem cannot be reached directly)

**Shared resource**

- A cloud queue (SQS, Pub/Sub, Azure Queue, Kafka topic) reachable from both VPS and on‑prem.

**On‑prem worker**

- A long‑running process that:
  - Polls the queue for tasks.  
  - For each task:
    - Calls local Hermes tools/skills in the on‑prem backend.  
    - Writes results to a result queue or cloud storage.  
  - Optionally, logs everything to an internal audit DB.

**VPS Hermes tool**

- A tool in the VPS agent that:
  - Writes tasks to the queue and awaits completion (polling a result queue or storage location).  
  - Enforces timeouts and user‑friendly error messages if the on‑prem worker is offline.

***

## Where the Video Runbook Still Applies Unchanged

From the original video you can keep the following **almost verbatim**, just adjusting "the agent" to "the VPS agent":

- Telegram bot creation via BotFather and token management.
- Discord bot creation, intents, permissions, and server invitation flow.
- Gateway as a `systemd` user service plus `loginctl enable-linger` so it survives SSH logout.
- Health checks: send message on Telegram/Discord, verify gateway and agent state.

The **only conceptual difference** is that "doing something with production data" always becomes "create a task for the on‑prem executor," not "run direct shell/SQL commands in the VPS backend."

***

## Suggested Documentation Structure for Your Environment

Given you already have "all options," I'd write three separate runbooks:

1. **RB‑EXT‑HERMES‑GATEWAY**  
   - VPS provisioning (from the video).  
   - Hermes install + gateway + Telegram + Discord.  
   - Operational procedures (restart, upgrade, rotate tokens, check logs).

2. **RB‑ONPREM‑HERMES‑EXECUTOR**  
   - On‑prem Hermes install and Docker backend configuration.  
   - Allowed networks/resources.  
   - Skills/tools for SQL, file, and internal API access.  
   - Guardrails (which DBs, which paths, allowed operations).

3. **RB‑BRIDGE‑HERMES‑VPS‑ONPREM**  
   - Chosen pattern: API bridge or queue bridge.  
   - Auth, network, endpoints/queues.  
   - Sequence diagrams for:
     - "Telegram → VPS → On‑prem → result."  
   - Failure modes and recovery playbooks.
