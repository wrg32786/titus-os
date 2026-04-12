# CLAUDE.md

This file provides guidance to Claude Code when working in this project.

## What This Is

**Titus** is an AI Operating System — a structured framework that defines how an AI agent operates as a strategic advisor and operator. It is a set of 15 markdown documents (00–14) that together form a complete system prompt and operational manual.

## Architecture

```
Principal (You)
  └── Titus (Top-layer operator: strategy, prioritization, delegation)
       └── Sub-agents (routed by task type and model tier)
```

**Key separation:** Titus owns *strategy and clarity*. Sub-agents own *execution*. Titus never does deep implementation work — it converts ambiguous inputs into structured briefs and routes them downstream.

## Model Routing

When spawning sub-agents, route to the cheapest model that can handle the task:

| Task type | Model | Examples |
|-----------|-------|----------|
| File reads, context loading, data fetching | haiku | Reading vault notes, pulling data |
| Code exploration, codebase search | haiku or sonnet | Grep/glob research, finding files |
| Writing, drafting, execution | sonnet | Replies, briefs, code changes |
| Strategy, architecture, complex analysis | opus (main session) | Decision-making, priority review |

## Session Commands

| Command | When to use | What it does |
|---------|-------------|--------------|
| `/open` | Start of every session | Loads memory, surfaces last session, open threads, active priorities |
| `/close` | End of every session | Commits memory updates, writes session log entry, confirms next actions |

## Key Files

- `system/00_identity.md` through `system/14_decision_framework.md` — The 15 system documents
- `system/12_authority_matrix.md` — What the agent may decide autonomously vs. what requires approval
- `system/13_memory_operating_layer.md` — How memory works
- `vault/memory/` — Persistent memory files
- `vault/daily/` — Session notes
- `hooks/` — Claude Code hook scripts

## Vault Structure

The vault at `vault/` is an Obsidian-compatible knowledge graph:
- `daily/` — Date-stamped session notes
- `memory/` — Operational memory (priorities, decisions, delegation, session log)
- `concepts/` — Architecture and domain knowledge
- `projects/` — One note per active project
- `people/` — Key people and their context
- `agents/` — Agent profiles and capabilities
- `templates/` — Note templates for recurring types

## Editing Guidelines

- **Document numbering is intentional** — 00–14 reflects processing order
- **One source of truth** — each file owns a specific domain. No duplicate content.
- **The vault is the brain** — all persistent knowledge lives in `vault/`. If it's not there, it doesn't exist.
