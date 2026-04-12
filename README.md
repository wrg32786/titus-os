<div align="center">

# TITUS

### An AI Operating System for Claude Code

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Claude Code](https://img.shields.io/badge/Claude_Code-Compatible-blueviolet)](https://claude.ai/code)
[![Obsidian](https://img.shields.io/badge/Obsidian-Vault_Native-7C3AED)](https://obsidian.md)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/wrg32786/titus-os/pulls)

**15 markdown files. Zero dependencies. Drop in and run.**

Turn Claude Code from a chatbot into a persistent strategic operator with identity, memory, authority boundaries, delegation protocols, and session continuity.

[Quick Start](#-quick-start) · [Architecture](#-architecture) · [Key Concepts](#-key-concepts) · [Docs](docs/getting-started.md)

</div>

---

## The Problem

Every time you open Claude Code, you start from scratch. No memory of yesterday. No awareness of your priorities. No understanding of what it should and shouldn't decide on its own. You re-explain context, re-establish boundaries, and hope it remembers what matters.

**Titus fixes this.** It's a complete operating system layer that gives your AI agent:

| | Without Titus | With Titus |
|---|---|---|
| **Memory** | Gone every session | Obsidian vault persists everything |
| **Identity** | Generic assistant | Defined role, values, optimization targets |
| **Authority** | Does whatever you ask | Knows what it can decide alone vs. what needs you |
| **Continuity** | "Let me start from scratch..." | `/open` loads full context in seconds |
| **Delegation** | One agent does everything | Routes to sub-agents by task type and model |
| **Cost** | Frontier model for everything | Smart routing saves 60-80% on tokens |

---

## 🚀 Quick Start

### Prerequisites

- [Claude Code](https://claude.ai/code) (CLI, desktop, or IDE extension)
- [Obsidian](https://obsidian.md/) (free)
- Node.js 18+ (for hooks and semantic search)

### Install

```bash
git clone https://github.com/wrg32786/titus-os.git
cd titus-os

# Optional: semantic search (local embeddings, no API calls)
cd daemons/semantic-search && npm install && cd ../..
```

### Configure

1. Copy hooks from `.claude/settings.json.template` into your Claude Code settings
2. Open the `vault/` folder in Obsidian
3. Edit `system/00_identity.md` — tell it who you are
4. Run Claude Code in the titus-os directory — Titus is active

See the full [Getting Started Guide](docs/getting-started.md).

---

## 🏗 Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         YOU (Principal)                       │
│                              │                               │
│                              ▼                               │
│                    ┌──────────────────┐                      │
│                    │      TITUS       │                      │
│                    │  Strategy Layer  │                      │
│                    │  Routes, decides,│                      │
│                    │  delegates, logs │                      │
│                    └────────┬─────────┘                      │
│                             │                                │
│              ┌──────────────┼──────────────┐                │
│              ▼              ▼              ▼                │
│     ┌──────────────┐ ┌───────────┐ ┌────────────┐         │
│     │   Research   │ │ Execution │ │  Creative  │         │
│     │  (fast model)│ │(mid model)│ │(mid model) │         │
│     └──────────────┘ └───────────┘ └────────────┘         │
│                                                             │
│  ┌────────────────────────────────────────────────────────┐ │
│  │                   OBSIDIAN VAULT                       │ │
│  │  daily/ · memory/ · concepts/ · projects/ · agents/    │ │
│  │  Wikilinks │ Graph View │ Session Logs │ Templates     │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌────────────────────────────────────────────────────────┐ │
│  │                   CLAUDE CODE HOOKS                    │ │
│  │  Auto-Capture │ Token Tracking │ Semantic Search       │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

### The 15 System Documents

| # | Document | Purpose |
|:---:|----------|---------|
| `00` | **Identity** | Who the agent is, what it optimizes for |
| `01` | **Ethos** | Core values, rejected behaviors |
| `02` | **Operating Standards** | 15 non-negotiable principles |
| `03` | **Roles & Scope** | Agent hierarchy and routing rules |
| `04` | **Decision Frameworks** | 12 evaluation lenses |
| `05` | **Delegation Protocol** | Structured brief template |
| `06` | **Sub-Agent Interface** | Communication standards |
| `07` | **Time Management** | Calendar protection, daily/weekly rhythm |
| `08` | **Financial Thinking** | Revenue, profit, cash flow, payback evaluation |
| `09` | **Sub-Agent Manifest** | When to create agents (and when not to) |
| `10` | **Memory & Learning** | Pattern tracking, institutional memory |
| `11` | **Session Rhythm** | `/open` → work → `/close` lifecycle |
| `12` | **Authority Matrix** | What AI decides alone vs. needs approval |
| `13` | **Memory Operating Layer** | Vault architecture, staleness rules |
| `14` | **Decision Framework** | YOUR personal decision logic (customize this) |

### Hooks

| Hook | Trigger | What It Does |
|------|---------|-------------|
| `auto-capture.sh` | PostToolUse | Logs actions to daily note automatically |
| `session-capture-summary.sh` | Stop | Session stats: actions, tools, files touched |
| `log-token-usage.sh` | Stop | Token spend + estimated cost per session |
| `suggest-compact.sh` | PostToolUse | Context management reminder |
| `session-end-check.sh` | Stop | Reminds to run `/close` |

### Semantic Search

Local embeddings using `all-MiniLM-L6-v2`. **No API calls. No data leaves your machine.**

```bash
node daemons/semantic-search/search-vault.js "what did we decide about pricing"
```

---

## 🔑 Key Concepts

### Authority Matrix

The most important document in the system. Three levels:

```
┌─────────────────────────────────────────────┐
│  LEVEL 1 — AUTONOMOUS                       │
│  Agent decides and acts. No confirmation.    │
│  Reading, organizing, research, formatting   │
├─────────────────────────────────────────────┤
│  LEVEL 2 — RECOMMEND & CONFIRM              │
│  Agent analyzes and proposes. You approve.   │
│  Strategy, delegation, external comms        │
├─────────────────────────────────────────────┤
│  LEVEL 3 — HUMAN ONLY                       │
│  Agent provides analysis. Never acts.        │
│  Money, legal, hiring, irreversible moves    │
└─────────────────────────────────────────────┘
```

Every task gets classified into one of four routes: **Do** → **Delegate** → **Recommend** → **Escalate**

### Vault as Brain

The Obsidian vault replaces traditional RAG and vector databases:

- **Human-navigable** — Open Obsidian, read everything. No hidden database.
- **Graph structure** — Wikilinks create a knowledge graph. Backlinks surface connections.
- **Session continuity** — `/open` loads context. `/close` commits changes. Nothing is lost.
- **Zero infrastructure** — No database, no server. Just markdown files in a folder.

### Model Routing

Not every task needs your most expensive model:

```
Fast (haiku)     → Reads, context loading, status checks
Mid (sonnet)     → Writing, execution, research
Frontier (opus)  → Strategy, architecture, complex judgment
```

**Result:** 60-80% token cost reduction without quality loss.

---

## 🎨 Customize

Titus is opinionated but designed to be forked:

1. `system/00_identity.md` — Define who your agent is
2. `system/14_decision_framework.md` — Your personal decision logic
3. `system/12_authority_matrix.md` — Set your authority boundaries
4. `vault/` — Add your projects, people, and context
5. `.claude/settings.json.template` — Wire the hooks

Works out of the box with examples. Customize as you learn your rhythm.

---

## ❌ What This Is NOT

| | |
|---|---|
| **Not a chatbot personality** | Operational infrastructure, not a persona prompt |
| **Not a code framework** | No build step. Markdown files. Drop and run. |
| **Not a RAG system** | Vault is human-readable. Vector search is optional. |
| **Not another LangChain** | For principals (founders, operators), not developers building pipelines |

---

## 🤝 Contributing

PRs welcome. Highest-value contributions:

- New decision framework lenses for `system/04`
- Hook scripts for additional Claude Code events
- Vault templates for specific domains (engineering, consulting, creative, legal)
- Integration guides for other tools (Notion, Linear, Slack, n8n)

---

## 📄 License

[MIT](LICENSE) — use it however you want.

---

<div align="center">

Built by [Will Gwyn](https://github.com/wrg32786). Battle-tested across multiple ventures over months of daily use.

**The framework emerged from real operational needs — not theory.**

</div>
