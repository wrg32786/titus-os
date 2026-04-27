---
name: System Check
description: Audit a Titus install for completeness and correctness. Verifies all required files are present, hooks are wired, semantic search is indexed, the identity file is populated, and there are no orphaned wikilinks. Reports green/yellow/red. Run after /setup and on demand.
---

# System Check

Hardens the "5 minutes to running" claim by giving you a single command to verify a Titus install is healthy.

## When to use

- Right after `/setup` finishes — verify nothing was missed
- When something feels off in a session ("Caddy isn't surfacing skills", "/open isn't loading context", "wikilinks aren't resolving")
- Periodically — once a month or so as a hygiene pass
- After a `git pull` from upstream — verify the upgrade landed cleanly

## What it checks

### Tier 1 — Kernel (must all be green)
- All 15 numbered system docs exist (`system/00_identity.md` through `system/14_decision_framework.md`)
- `system/00_identity.md` has been customized (no longer contains "Replace this section…")
- `CLAUDE.md` exists at root
- `.claude/skill-index.json` exists and is valid JSON

### Tier 2 — Skills (yellow if missing, red if broken)
- Every entry in `.claude/skill-index.json` has a corresponding `skills/<name>/SKILL.md`
- Every `skills/<name>/SKILL.md` has matching frontmatter (`name`, `description`)
- No orphaned skill folders (folder exists, no index entry)

### Tier 3 — Hooks (yellow if missing, green if wired)
- `.claude/settings.json` exists OR `.claude/settings.local.json` exists
- If hooks/ files exist, they are referenced by settings.json
- `hooks/` scripts are executable (or invocable per platform)

### Tier 4 — Vault (informational)
- `vault/` directory exists with at least: `concepts/`, `daily/`, `memory/`, `people/`, `projects/`
- `vault/memory/MEMORY.md` exists OR is unused (either is fine)
- Wikilink scan: count broken `[[note name]]` references — report top 10

### Tier 5 — Semantic search (informational)
- If `daemons/semantic-search/` exists, check whether `embeddings.json` was indexed within the last 30 days
- If stale: nudge user to re-index

## How to execute

1. Walk each tier in order. Stop at first Tier-1 red.
2. For each check, output `✅` / `⚠️` / `❌` with a one-line description.
3. After all tiers, output an overall verdict:
   - **GREEN** — kernel is intact, skills wired, hooks active. Ready to use.
   - **YELLOW** — kernel intact but some skills/hooks missing. Functional but degraded.
   - **RED** — kernel incomplete. Re-run `/setup` or check git status for missing files.
4. List the top 3 actions to take if not green. Concrete commands, not advice.

## Output format

```
🔍 Titus System Check

TIER 1 — KERNEL
✅ All 15 system docs present
✅ Identity customized
✅ CLAUDE.md present
✅ skill-index.json valid

TIER 2 — SKILLS
✅ 11 skills indexed, 11 SKILL.md files present
⚠️ 1 orphan folder: skills/old-test/ (no index entry)

TIER 3 — HOOKS
⚠️ settings.json present, no hooks wired (running without auto-capture)

TIER 4 — VAULT
✅ Vault structure complete
⚠️ 4 broken wikilinks in vault/concepts/ — top: [[Legacy Project]], [[Old Person]]

TIER 5 — SEMANTIC SEARCH
✅ Indexed 3 days ago

OVERALL: 🟡 YELLOW — functional but some hygiene needed.

Top actions:
1. Add hooks: see docs/getting-started.md "Hooks" section
2. Remove orphan: rm -rf skills/old-test/
3. Fix broken wikilinks: search vault for [[Legacy Project]]
```

## Why this skill exists

Without it, a user with a broken install has no way to know what's wrong. The "5 minutes to running" promise breaks the moment something is silently misconfigured.

## Anti-patterns this prevents

- "Caddy isn't working" → user can't tell whether it's a hook issue, a skill-index issue, or a permissions issue
- Stale embeddings producing irrelevant semantic search results
- Orphan skill folders accumulating after experimentation
- Broken wikilinks rotting silently for months
