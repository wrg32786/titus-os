---
name: open
description: Boot the session — load context from vault, surface what matters
trigger: /open
---

# Session Open

Run this at the start of every session.

## First-Run Detection

Before running the normal protocol, check `system/00_identity.md`. If it still contains "Replace this section with context about yourself" — the system is unconfigured. Say:

> "Looks like this is your first session. Run `/setup` and I'll configure Titus to know who you are, what you're working on, and how you like to operate. Takes about 5 minutes."

Do NOT run the normal /open protocol on an unconfigured system — there's nothing in the vault yet.

## Protocol

1. **Load the heat index** — `vault/memory/HEAT_INDEX.json` if it exists. Use the `hot_top_20` array as your prioritized reading list. These are the notes most live in the vault right now (weighted by session reads, backlinks, mtime, with 60-day decay). **Skip cold notes entirely** unless the current session explicitly references them. See `vault/concepts/Memory Decay Doctrine.md`. If the file is missing, fall back to reading everything in steps 2–6.
2. **Read the latest daily note** — `vault/daily/` sorted by filename descending. This is last session's context.
3. **Read the session log** — `vault/memory/SESSION_LOG.md`. Get the "Next action" and "Open threads" from the latest entry.
4. **Read active priorities** — `vault/memory/ACTIVE_PRIORITIES.md`. Current mode, Tier 1 blockers.
5. **Follow the graph** — From the daily note's open threads, read the 3-5 most relevant vault notes (projects, concepts, agents referenced). Use the heat index from step 1 to tie-break when multiple notes look equally relevant.
6. **Check delegation tracker** — `vault/memory/DELEGATION_TRACKER.md`. Anything stale or pending review?

## Protocol (additional steps, v0.2.2+)

7. **Decision aging check** — Read `vault/memory/DECISION_OUTCOMES.md` and `vault/memory/DECISION_LOG.md`. For each decision in DECISION_LOG with a date 30, 60, or 90 (±3) days ago that does NOT yet have a corresponding outcome entry in DECISION_OUTCOMES.md at that aging interval, surface it as a one-line prompt. Maximum 3 entries per session — show the 3 oldest if more are due. See [[Cost of Confidence]] for why this matters.

8. **Attention reconciliation** — Read `vault/memory/ACTIVE_PRIORITIES.md` for intended focus (Tier 1 projects). Walk the last 7 days of `vault/daily/` and count weighted project mentions per project. Compare actual attention share vs intended. If any Tier 1 project has <40% of its intended share OR any non-Tier-1 project has >20% of total attention, flag drift. See [[Attention Reconciliation]] for the doctrine.

## Output

Brief greeting, then ONLY surface:

- **Decision aging (if any due):**
  ```
  📋 Decision aged Nd: "{summary}" — HELD / DRIFTED / REVERSED / STILL UNCLEAR?
  ```
  Principal answers in one word; the answer goes to `DECISION_OUTCOMES.md` on the next turn.

- **Attention drift (if detected):**
  ```
  🎯 Attention drift (7-day window):
     {project A} — actual {N}% / intended {M}% — drift detected
     Reconcile: update ACTIVE_PRIORITIES, refocus this session, or log a legitimate reason.
  ```

- Anything stale or blocked
- Anything dropped from last session's next action
- Open threads that need attention today

If nothing needs flagging, just greet and let the principal drive.

**Do NOT output a full briefing, priority list, or session summary.** Keep it tight. The principal knows their priorities — they need to know what changed, what's stuck, and what fell through.
