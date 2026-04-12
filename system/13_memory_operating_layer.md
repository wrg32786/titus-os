# 13 — Memory Operating Layer

How the vault-as-brain actually works. Architecture, rules, and quality standards.

## 4-Layer Memory Hierarchy

### Layer 1 — Core Identity (rarely changes)
- Who the principal is
- How they think and make decisions
- Core values and non-negotiable boundaries
- The agent's own identity and operating standards

### Layer 2 — Operating Context (changes monthly)
- Active priorities and their status
- Current projects and their state
- People and roles
- Tools and systems in use

### Layer 3 — Project Memory (changes weekly)
- Specific project decisions and progress
- Technical architecture notes
- Meeting outcomes and action items
- Delegation status

### Layer 4 — Session Memory (changes daily)
- Daily notes with session work
- Session log with next actions
- Idea queue with parked thoughts
- Decision log with recent choices

## What Gets Stored Where

| Content Type | Location | Format |
|-------------|----------|--------|
| Principal profile | `people/` | Single note, updated rarely |
| Project context | `projects/` | One note per project |
| Agent profiles | `agents/` | One note per agent |
| Concepts & architecture | `concepts/` | One note per concept |
| Session work | `daily/YYYY-MM-DD.md` | One note per day |
| Active priorities | `memory/ACTIVE_PRIORITIES.md` | Rolling file |
| Decisions | `memory/DECISION_LOG.md` | Append-only |
| Delegation status | `memory/DELEGATION_TRACKER.md` | Updated per task |
| Session continuity | `memory/SESSION_LOG.md` | Rolling 5-session window |
| Ideas | `memory/IDEA_QUEUE.md` | Append, review weekly |

## Staleness Rules

Memory goes stale. Stale memory is worse than no memory — it creates false confidence.

| Layer | Staleness Threshold | Action |
|-------|-------------------|--------|
| Core Identity | 90 days | Review, rarely needs change |
| Operating Context | 30 days | Review and update |
| Project Memory | 14 days | Review — if unchanged, verify it's still accurate |
| Session Memory | 7 days | Older daily notes are archive, not active context |

## Memory Quality Standards

Every memory file must have:
- **YAML frontmatter** — title, tags, date created/updated
- **Wikilinks** — connect to related notes. Orphan notes are invisible.
- **Single responsibility** — one concept per note. Don't combine unrelated topics.
- **Current information** — if something changed, update the note. Don't leave stale facts.

## What NOT to Store

- Raw data dumps (put summaries in the vault, link to sources)
- Conversation transcripts (the daily note captures outcomes, not dialogue)
- Temporary task state (use task tracking tools, not vault notes)
- Duplicate information (one source of truth per fact)

## Obsidian-Flavored Markdown

All vault notes use Obsidian syntax:
- `[[Wikilinks]]` for internal references
- YAML frontmatter for metadata
- `> [!callout]` blocks for emphasis
- Tags for categorization
- Aliases for discoverability

This ensures the vault is navigable in Obsidian's graph view, search, and backlink panels.
