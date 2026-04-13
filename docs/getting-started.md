# Getting Started with Titus

## Prerequisites

1. **Claude Code** — The CLI, desktop app, or IDE extension. [Get it here](https://claude.ai/code)
2. **Obsidian** — Free knowledge base app. [Download](https://obsidian.md/)
3. **Node.js 18+** — Required for hooks and semantic search
4. **Git** — For cloning the repo

## Installation

### 1. Clone the repo

```bash
git clone https://github.com/YOUR_USERNAME/titus-os.git
cd titus-os
```

### 2. Set your vault root

Add to your shell profile (`.bashrc`, `.zshrc`, or similar):

```bash
export TITUS_ROOT="/path/to/titus-os"
```

### 3. Install semantic search

```bash
cd daemons/semantic-search
npm install
node embed-vault.js  # Initial index
cd ../..
```

### 4. Configure Claude Code hooks

Copy the hooks from `.claude/settings.json.template` into your Claude Code settings file (`~/.claude/settings.json`). Replace `TITUS_ROOT` with your actual path:

```bash
# Find your settings file
# Mac/Linux: ~/.claude/settings.json
# Windows: %USERPROFILE%\.claude\settings.json
```

### 5. Open the vault in Obsidian

1. Open Obsidian
2. "Open folder as vault" → select the `vault/` directory
3. You should see the knowledge graph with memory files, templates, and starter notes

## First Session

1. **Customize your identity** — Edit `system/00_identity.md` and fill in the "Your Principal" section
2. **Set your priorities** — Edit `vault/memory/ACTIVE_PRIORITIES.md`
3. **Define your authority matrix** — Edit `system/12_authority_matrix.md` to match your boundaries
4. **Run Claude Code** in the titus-os directory
5. The CLAUDE.md file will be loaded automatically — Titus is active

## Session Flow

Every session:

1. **Start:** Say `/open` or "let's start" — Titus loads context from the vault
2. **Work:** Titus routes tasks, manages sub-agents, tracks decisions
3. **End:** Say `/close` — Titus commits memory, writes the daily note, sets up next session

## Customization Guide

### Essential (do first)
- `system/00_identity.md` — Who you are, what you need
- `system/14_decision_framework.md` — Your personal decision logic
- `system/12_authority_matrix.md` — What the AI can decide alone

### Important (do soon)
- `system/03_roles_and_scope.md` — Your agent hierarchy
- `vault/memory/ACTIVE_PRIORITIES.md` — Current priorities
- Add your people to `vault/people/`
- Add your projects to `vault/projects/`

### Optional (customize over time)
- `system/04_decision_frameworks.md` — Add or remove evaluation lenses
- `system/08_financial_thinking.md` — Adjust financial thresholds
- `vault/templates/` — Modify note templates to match your style

## Self-Improvement Loop

The framework is designed to learn from mistakes. When Titus makes a mistake, after correcting it, trigger the learning cycle with one sentence:

> **"Reflect on this mistake. Abstract and generalize the learning. Write it to CLAUDE.md."**

The AI will analyze the failure, extract the general pattern, and write a rule following the META format in `CLAUDE.md`. Over time, the framework gets smarter — basic mistakes disappear, conversations elevate to higher-level concerns.

**Where rules go:**
- Operational mistakes → root `CLAUDE.md`
- Domain knowledge → new concept note in `vault/concepts/`
- Behavioral patterns → `system/02_operating_standards.md`

See [[vault/concepts/Self-Improving CLAUDE.md]] for the full rationale.

## Advanced Skills

- **`/open`** and **`/close`** — daily session bookends (included)
- **`/brief`** — generate structured briefs for delegation (included)
- **`/decide`** — run a decision through your decision framework (included)
- **`/deep-recon`** — extended multi-agent reconnaissance for complex research questions (included)
- **`/semantic-search`** — vector search across the vault (included, requires npm install)

---

## Troubleshooting

**Hooks not firing:** Make sure the paths in `~/.claude/settings.json` point to your actual titus-os location.

**Semantic search not working:** Run `node daemons/semantic-search/embed-vault.js` to rebuild the index.

**Vault feels empty:** That's expected — the vault grows with use. Every `/close` adds to the knowledge graph. After a week of daily use, it becomes genuinely useful.
