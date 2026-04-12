<div align="center">

<img src="assets/banner.png" alt="TITUS — AI Operating System" width="100%"/>

<br/>

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=flat-square)](LICENSE)
[![Claude Code](https://img.shields.io/badge/Claude_Code-Compatible-blueviolet?style=flat-square)](https://claude.ai/code)
[![Obsidian](https://img.shields.io/badge/Obsidian-Vault_Native-7C3AED?style=flat-square)](https://obsidian.md)
[![Zero Dependencies](https://img.shields.io/badge/Dependencies-Zero-00d4aa?style=flat-square)](#-quick-start)
[![PRs Welcome](https://img.shields.io/badge/PRs-Welcome-brightgreen?style=flat-square)](https://github.com/wrg32786/titus-os/pulls)

**Your AI doesn't just answer questions. It operates.**

[Quick Start](#-quick-start) · [Architecture](#-architecture) · [Key Concepts](#-key-concepts) · [Customize](#-make-it-yours) · [Docs](docs/getting-started.md)

</div>

---

## What if your AI remembered everything?

Every priority. Every decision. Every conversation thread left open from last week. What if it knew exactly what it was allowed to decide on its own — and what to bring to you? What if it could delegate to faster, cheaper agents for grunt work while it stayed focused on strategy?

That's Titus. **15 markdown files that turn Claude Code into a persistent operating system.**

No database. No server. No build step. Drop the files in, open a session, and your AI boots up knowing who it is, what it's working on, and what matters today.

```
You: /open
Titus: 3 open threads from yesterday. Delegation tracker has 2 items pending review.
       Priority 1 is blocked — surfacing now. What do you want to hit?
```

---

## ⚡ Quick Start

### One-line install:

```bash
bash <(curl -s https://raw.githubusercontent.com/wrg32786/titus-os/main/install.sh)
```

### Or manually:

```bash
git clone https://github.com/wrg32786/titus-os.git
cd titus-os
```

### Then open Claude Code in the titus-os directory:

```bash
cd ~/titus-os && claude
```

**That's it.** Titus detects the fresh install, greets you, and walks you through setup. You don't need to read any docs — just start talking. The AI configures itself through conversation in about 5 minutes.

After setup, every session works like this:
- **Start:** `/open` — Titus boots with full context from last session
- **Work:** Just talk. Titus handles routing, memory, delegation.
- **End:** `/close` — Saves everything. Next session picks up exactly where you left off.

**Optional:** Open the `vault/` folder in [Obsidian](https://obsidian.md) to see and navigate your AI's knowledge graph visually. Full walkthrough in [Getting Started](docs/getting-started.md).

---

## 🏗 Architecture

<div align="center">
<img src="assets/architecture.png" alt="Titus OS Architecture — Principal to Titus to Sub-agents to Vault to Hooks" width="100%"/>
</div>

### 15 System Documents — The Operating Kernel

These aren't prompts. They're a **complete operating manual** that tells the AI how to think, decide, delegate, remember, and manage your time.

| | Document | What It Gives Your AI |
|:---:|----------|----------------------|
| `00` | **Identity** | Knows who it is and what it optimizes for |
| `01` | **Ethos** | Won't sugarcoat, won't hedge, won't waste your time |
| `02` | **Operating Standards** | 15 rules it follows without being told |
| `03` | **Roles & Scope** | Routes work to the right agent automatically |
| `04` | **Decision Frameworks** | 12 lenses for evaluating any opportunity |
| `05` | **Delegation Protocol** | Structured briefs — no sloppy handoffs |
| `06` | **Sub-Agent Interface** | Clean communication up and down the chain |
| `07` | **Time Management** | Protects your calendar like a chief of staff should |
| `08` | **Financial Thinking** | Revenue, profit, cash flow — not vibes |
| `09` | **Sub-Agent Manifest** | Creates specialists only when it creates leverage |
| `10` | **Memory & Learning** | Gets smarter every session. Tracks patterns. Learns from mistakes. |
| `11` | **Session Rhythm** | `/open` → work → `/close` — nothing falls through cracks |
| `12` | **Authority Matrix** | Knows its lane. Asks when it should. Acts when it can. |
| `13` | **Memory Layer** | 4-tier vault architecture with staleness rules |
| `14` | **Your Decision Logic** | YOUR brain encoded — customize this completely |

### Hooks — The Nervous System

Runs silently in the background. You don't think about it.

| Hook | What It Does |
|------|-------------|
| **Auto-Capture** | Every action logged to your daily note. Automatic. |
| **Session Summary** | Actions, tools, files touched — stats at session end |
| **Token Tracker** | Cost per session, cumulative spend, logged to vault |
| **Compact Suggest** | Nudges context management before you hit limits |
| **Close Reminder** | Never forgets to commit memory |

### Semantic Search — The Recall System

Your vault, searchable by meaning. Not keywords — meaning.

```bash
$ node daemons/semantic-search/search-vault.js "what did we decide about pricing"

  1. [0.89] concepts/Pricing Strategy.md — "Freemium with usage-based upgrade..."
  2. [0.76] memory/DECISION_LOG.md — "2026-03-15: Set launch price at $49/mo..."
  3. [0.71] projects/SaaS Launch.md — "Pricing must clear $40 to cover CAC..."
```

Runs locally. `all-MiniLM-L6-v2` on your machine. **No API calls. No data leaves your device.**

---

## 🔑 Key Concepts

### The Authority Matrix

Your AI shouldn't need permission for everything. But it shouldn't decide everything either.

```
╔══════════════════════════════════════════════════════╗
║  LEVEL 1 · AUTONOMOUS                               ║
║  Research. Organize. Format. Route.                  ║
║  → It just handles it.                               ║
╠══════════════════════════════════════════════════════╣
║  LEVEL 2 · RECOMMEND & CONFIRM                      ║
║  Strategy. Delegation. External comms.               ║
║  → It proposes. You approve.                         ║
╠══════════════════════════════════════════════════════╣
║  LEVEL 3 · HUMAN ONLY                               ║
║  Money. Legal. Hiring. Irreversible moves.           ║
║  → It briefs you. You decide.                        ║
╚══════════════════════════════════════════════════════╝
```

Every incoming task → **Do** · **Delegate** · **Recommend** · **Escalate**

The AI classifies in milliseconds. No ambiguity. No overreach.

### Vault as Brain

Forget vector databases. Your AI's memory is an **Obsidian vault** — the same tool you can open, read, search, and navigate yourself.

- **Wikilinks** create a knowledge graph. `[[Project Alpha]]` connects to `[[People/Jane]]` connects to `[[Decision Log]]`. The graph IS the intelligence.
- **Session continuity** without magic. `/open` reads the vault. `/close` writes to it. Everything persists. Everything is auditable.
- **Human-first.** You can read every thought your AI has ever had. No hidden embeddings. No opaque database. Markdown files in a folder.

### Model Routing — Smart Spend

Why burn frontier tokens on reading a file?

| Task | Model | Cost |
|------|-------|------|
| Read files, load context | ⚡ Fast | ~$0.001 |
| Write code, draft content | 🔧 Mid | ~$0.01 |
| Strategy, complex judgment | 🧠 Frontier | ~$0.10 |

**Titus routes automatically.** Same quality output. 60-80% lower cost.

---

## 🎨 Make It Yours

Titus is opinionated but built to be forked.

**Start here (10 minutes):**
1. `system/00_identity.md` — Tell it who you are
2. `system/14_decision_framework.md` — Encode how YOU make decisions
3. `system/12_authority_matrix.md` — Set boundaries that match YOUR risk tolerance

**Then build over time:**
- Add your projects to `vault/projects/`
- Add your people to `vault/people/`
- Drop concepts into `vault/concepts/`
- The vault grows with every session. It compounds.

---

## ❌ What This Isn't

**Not a chatbot skin.** No personality prompts. No "you are a helpful assistant." This is operational infrastructure.

**Not a code framework.** No `npm install`. No Python environment. No build step. It's 15 markdown files.

**Not a RAG system.** The vault is human-readable by design. You don't need an AI to search your AI's memory — just open Obsidian.

**Not another agent framework.** LangChain and CrewAI are for developers building pipelines. Titus is for **principals** — founders, executives, operators — who want an AI that actually operates.

---

## 🤝 Contributing

PRs welcome. The highest-value contributions:

- Decision framework lenses for new domains
- Hook scripts for additional Claude Code events
- Vault templates (engineering, legal, consulting, creative)
- Integration guides (Notion, Linear, Slack, n8n, Make)

---

<div align="center">

### 📄 [MIT License](LICENSE) — Use it however you want.

<br/>

Built by **[Will Gwyn](https://github.com/wrg32786)**

*Battle-tested across multiple ventures. Months of daily use.*
*This framework emerged from real operational needs — not theory.*

<br/>

**If this saves you time, star the repo. That's all the thanks needed.**

</div>
