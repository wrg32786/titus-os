---
title: Caddy
tags:
  - concept
  - skills
  - meta
  - framework
aliases:
  - Skill Router
  - Skill Catalog
  - Tool Discovery
created: 2026-04-13
---

# Caddy

> [!abstract] A non-blocking UserPromptSubmit hook that matches the user's prompt against a catalog of skills and surfaces `[CADDY] /X - why` hints for the tools that fit the task. Like a golf caddy — hands Titus the right club for the shot, never blocks the swing.

## The Problem It Solves

Over time, a Titus install accumulates dozens of skills. Most sit unused because the AI pattern-matches on basic tools (Read, Grep, Bash, WebFetch) when tasks come up — not on the specialized skill that would do it better. The toolbox is visible but not **routed by intent**.

Caddy closes that gap.

## How It Works

```
User prompt → Claude Code → UserPromptSubmit hook
                                    ↓
                              caddy.sh (<200ms)
                                    ↓
                  Match prompt against skill-index.json triggers
                                    ↓
                  Score: multi-word = 3pts, word-boundary = 1pt
                                    ↓
                  If top score >= 2: emit "[CADDY] /name - why"
                                    ↓
                  Claude sees the hint as a system reminder
```

Informational, not enforcement. Two matched skills? Both get surfaced. Zero matches? Silent.

## Architecture

Three components:

### 1. The Index — `.claude/skill-index.json`

Flat JSON. One entry per skill:
```json
{
  "name": "open",
  "triggers": ["start session", "load context", "what did we leave off"],
  "why": "Start session, load vault context, surface open threads"
}
```

### 2. The Hook — `daemons/caddy.sh`

Triggered by `UserPromptSubmit`. Reads the prompt JSON from stdin, scores each skill against the prompt, emits hints for top matches. Completes in <200ms. Never errors — always exits 0.

### 3. The Reindexer — `daemons/caddy-reindex.sh`

Reads `vault/concepts/skills/*.md` frontmatter and rebuilds `skill-index.json`. Run manually after adding or editing catalog notes.

## Matching Algorithm

Simple, fast, deterministic. No embeddings.

| Match type | Weight | Example |
|------------|--------|---------|
| Multi-word phrase (substring) | 3 points | "load context" matches "please load context for me" |
| Single word (boundary match) | 1 point | "brief" in "write a brief" |

**Threshold:** top score >= 2. Requires either one multi-word match or two single-word matches.
**Max suggestions:** 2 hints per prompt. Prevents spam.

## Auto-Enrollment — The Golf Bag Stays Complete

When a new skill is added, it joins the index automatically:

1. **Inline via `/skills-builder`** — when a skill is created via that protocol, it calls `/caddy-enroll <path>` as the final step.
2. **Detection hook for drop-ins** — `daemons/caddy-detect-new-skill.sh` runs on every Write/Edit. When it sees a new skill `.md` not yet in the index, it emits a nudge to run `/caddy-enroll`.
3. **Manual `/caddy-enroll <path>`** — the user-invocable skill that reads the SKILL.md, extracts triggers + use cases, and appends to the index.

Result: every skill — existing, new, or copied from another source — ends up enrolled so Caddy can hand it to the AI when the matching task arrives.

## Why Non-Blocking Beats Enforcement

Enforcement hooks (PreToolUse blocks) generate error spam that trains users to ignore hook output. Caddy avoids this trap:

- **No errors.** The hint is text, not a block.
- **No false-positive cost.** Wrong suggestion = ignored, not frustrating.
- **Composable.** Two skills match? Both surface.
- **Discoverable.** The AI learns about skills it forgot existed.

## Installation

1. Copy `daemons/caddy.sh`, `daemons/caddy-detect-new-skill.sh`, `daemons/caddy-reindex.sh` into your Titus install
2. Set `TITUS_ROOT` env var to your repo root: `export TITUS_ROOT="/path/to/titus-os"`
3. Add to `~/.claude/settings.json` hooks:

```json
{
  "UserPromptSubmit": [
    {
      "matcher": "",
      "hooks": [
        {"type": "command", "command": "bash $TITUS_ROOT/daemons/caddy.sh", "timeout": 2000}
      ]
    }
  ],
  "PostToolUse": [
    {
      "matcher": "Write|Edit",
      "hooks": [
        {"type": "command", "command": "bash $TITUS_ROOT/daemons/caddy-detect-new-skill.sh", "timeout": 2000}
      ]
    }
  ]
}
```

4. Seed `.claude/skill-index.json` with your skills, or run `/caddy-enroll` on each one

## Future Enhancements

- **Semantic matching** via embeddings if keyword approach proves brittle
- **Usage tracking** — which hints get followed vs ignored? Iterate triggers based on hit rate.
- **Cross-skill suggestions** — "you ran /graphify, consider /pipeline-audit next"
- **Session memory** — don't re-suggest a skill already used this session

## Links
- `.claude/skill-index.json` — the catalog
- `daemons/caddy.sh` — the hook
- `skills/caddy-enroll/` — the enrollment skill
- [[Self-Improving CLAUDE.md]] — related pattern: meta-rules for generating new entries
