---
name: open
description: Boot the session — load context from vault, surface what matters
trigger: /open
---

# Session Open

Run this at the start of every session.

## Protocol

1. **Read the latest daily note** — `vault/daily/` sorted by filename descending. This is last session's context.
2. **Read the session log** — `vault/memory/SESSION_LOG.md`. Get the "Next action" and "Open threads" from the latest entry.
3. **Read active priorities** — `vault/memory/ACTIVE_PRIORITIES.md`. Current mode, Tier 1 blockers.
4. **Follow the graph** — From the daily note's open threads, read the 3-5 most relevant vault notes (projects, concepts, agents referenced).
5. **Check delegation tracker** — `vault/memory/DELEGATION_TRACKER.md`. Anything stale or pending review?

## Output

Brief greeting, then ONLY surface:
- Anything stale or blocked
- Anything dropped from last session's next action
- Open threads that need attention today

If nothing needs flagging, just greet and let the principal drive.

**Do NOT output a full briefing, priority list, or session summary.** Keep it tight. The principal knows their priorities — they need to know what changed, what's stuck, and what fell through.
