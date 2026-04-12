# Titus

**An AI Operating System for Claude Code.**

Titus is a structured framework that turns Claude Code into a persistent, strategic AI operator — not a chatbot. It's 15 markdown documents, a set of Claude Code hooks, and an Obsidian vault architecture that together give your AI agent identity, memory, authority boundaries, delegation protocols, decision frameworks, and session continuity.

Drop the files into a Claude Code project. You have an operating system.

## What This Is

Most people use AI as a question-answer machine. Titus treats AI as a **chief of staff** — a persistent operator that knows your priorities, remembers your decisions, manages sub-agents, and maintains continuity across sessions without you re-explaining context every time.

The framework defines:

- **Identity & Authority** — Who the agent is, what it can decide autonomously, what requires your approval, what it should never touch
- **Memory Architecture** — An Obsidian vault as a living knowledge graph. Wikilinks are the index. Daily notes are session logs. Concept notes are institutional memory. No vector database, no SQLite — just markdown files a human can navigate
- **Session Lifecycle** — `/open` loads context from the vault graph. `/close` commits what changed. Every session picks up where the last one left off
- **Delegation Protocol** — Structured briefs for routing work to sub-agents. Model routing by task type (fast models for reads, capable models for writes, frontier models for strategy)
- **Decision Frameworks** — 12 evaluation lenses for assessing opportunities, plus an authority matrix that defines autonomy levels for every category of decision
- **Hooks & Instrumentation** — Auto-capture of session activity, token cost tracking, semantic search over your vault, session summaries — all running as Claude Code hooks

## Quick Start

### 1. Prerequisites

- [Claude Code](https://claude.ai/code) (CLI, desktop app, or IDE extension)
- [Obsidian](https://obsidian.md/) (free) — for navigating the vault
- Node.js 18+ (for hooks and semantic search)

### 2. Install

```bash
# Clone the repo
git clone https://github.com/YOUR_USERNAME/titus-os.git

# Copy the vault to your working directory (or use in place)
cd titus-os

# Install semantic search dependencies
cd daemons/semantic-search && npm install && cd ../..

# Index the vault for semantic search
node daemons/semantic-search/embed-vault.js
```

### 3. Configure Claude Code

Copy the hooks configuration into your Claude Code settings:

```bash
# Open your Claude Code settings
# Add the hooks from .claude/settings.json in this repo
```

See [Getting Started](docs/getting-started.md) for the full walkthrough.

### 4. Open Obsidian

Point Obsidian at the `vault/` directory. You'll see the full knowledge graph — daily notes, memory files, concept notes, agent profiles. This is your AI's brain, and you can read every part of it.

## Architecture

```
You (Principal)
  └── Titus (Top-layer operator: strategy, prioritization, delegation)
       └── Sub-agents (routed by task type and model)
            ├── Research agents (fast model — reads, context loading)
            ├── Execution agents (mid model — writes, code, drafts)
            └── Strategy (frontier model — main session only)
```

### The 15 System Documents

| # | Document | What It Defines |
|---|----------|----------------|
| 00 | Identity | Who the agent is and what it optimizes for |
| 01 | Ethos | Core values and explicitly rejected behaviors |
| 02 | Operating Standards | 15 principles governing behavior |
| 03 | Roles & Scope | Role definitions and routing rules |
| 04 | Decision Frameworks | 12 evaluation lenses for assessing any opportunity |
| 05 | Delegation Protocol | Structured brief template for all downstream work |
| 06 | Sub-Agent Interface | Rules for communicating with downstream agents |
| 07 | Time Management | Time protection and planning structures |
| 08 | Financial Thinking | How to evaluate financial decisions |
| 09 | Sub-Agent Manifest | Catalog of available agents and when to create new ones |
| 10 | Memory & Learning | How the system improves over time |
| 11 | Session Rhythm | Protocol for starting, conducting, and closing sessions |
| 12 | Master System Prompt | Consolidated synthesis of all above |
| 13 | Memory Operating Layer | Memory architecture, staleness rules, quality standards |
| 14 | Decision Framework | Your personal decision logic — pattern filter, priority stack, asymmetry test |

### Hooks

| Hook | Event | What It Does |
|------|-------|-------------|
| `auto-capture.sh` | PostToolUse | Logs every write/execute action to the daily note |
| `session-capture-summary.sh` | Stop | Appends session stats (actions, tools, files touched) |
| `log-token-usage.sh` | Stop | Logs token spend and estimated cost to vault |
| `suggest-compact.sh` | PostToolUse | Suggests `/clear` after N tool calls |
| `session-end-check.sh` | Stop | Reminds to run `/close` for memory commit |

### Semantic Search

Local embeddings over your vault using `all-MiniLM-L6-v2`. No API calls. No data leaves your machine.

```bash
# Search by meaning
node daemons/semantic-search/search-vault.js "what did we decide about the audio pipeline"

# Re-index after changes
node daemons/semantic-search/embed-vault.js --changed-only
```

## Key Concepts

### Authority Matrix

Not all decisions are equal. The authority matrix defines three levels:

- **Level 1 — Autonomous:** The agent decides and acts without asking. Routine operations, information gathering, standard formatting.
- **Level 2 — Recommend & Confirm:** The agent proposes a decision with reasoning. You approve or redirect. Strategic moves, resource allocation, external communications.
- **Level 3 — Human Only:** The agent never decides. Financial commitments, legal, hiring, anything irreversible and high-stakes.

Every category of decision maps to a level. The agent knows its boundaries before it acts.

### Vault as Brain

The Obsidian vault replaces traditional RAG and vector databases. Why:

- **Human-navigable** — You can open Obsidian and read every memory, every decision, every session log. No hidden database.
- **Graph structure** — Wikilinks create a knowledge graph. Backlinks surface connections. The graph view shows the shape of your AI's knowledge.
- **Session continuity** — `/open` traverses the graph to load relevant context. `/close` commits changes. The vault grows smarter with every session.
- **No infrastructure** — No database to manage, no embeddings to maintain (semantic search is optional), no server to run. Just markdown files in a folder.

### Model Routing

Not every task needs your most expensive model:

| Task Type | Model Tier | Examples |
|-----------|-----------|---------|
| File reads, context loading | Fast | Reading vault notes, pulling data |
| Status checks, monitoring | Fast | Checking inboxes, polling services |
| Code exploration, search | Fast/Mid | Grepping repos, finding files |
| Drafting, writing, execution | Mid | Replies, briefs, code changes |
| Strategy, architecture, complex analysis | Frontier | Decision-making, priority review |
| Deep research, investigation | Mid | Multi-step research, analysis |

**Rule:** If a sub-agent only reads and summarizes, use the fast model. If it reasons and writes, use mid. Only escalate to frontier when the main session's judgment is needed.

## Customization

Titus is opinionated but designed to be forked. The system documents use placeholder names and example businesses. To make it yours:

1. **Edit `system/00_identity.md`** — Define who your agent is and what it optimizes for
2. **Edit `system/14_decision_framework.md`** — Replace with your actual decision logic
3. **Edit `system/03_roles_and_scope.md`** — Define your agent hierarchy
4. **Populate `vault/`** — Add your projects, people, concepts, and priorities
5. **Adjust hooks** — Modify paths in `.claude/settings.json` to point to your installation

The framework works out of the box with the example configuration. Customize as you learn what your operating rhythm needs.

## What This Is NOT

- **Not a chatbot personality** — This is operational infrastructure, not a persona prompt
- **Not a code framework** — No npm install, no Python package, no build step (except optional semantic search). It's markdown files
- **Not a RAG system** — The vault is human-readable by design. Vector search is an optional add-on, not the core
- **Not another LangChain** — This targets principals (founders, operators), not developers building agent pipelines

## License

MIT — use it however you want.

## Contributing

PRs welcome. The most valuable contributions are:
- New decision framework lenses
- Hook scripts for additional Claude Code events
- Vault templates for specific use cases (engineering, consulting, creative)
- Integrations with other tools (Notion, Linear, Slack)

## Credits

Built by [Will Gwyn](https://github.com/YOUR_USERNAME). Battle-tested across multiple ventures over months of daily use. The framework emerged from real operational needs — not theory.
