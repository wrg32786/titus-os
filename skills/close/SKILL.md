---
name: close
description: End the session — commit memory, write daily note, update session log
trigger: /close
---

# Session Close

Run this at the end of every working session. No sub-agents — do all updates inline.

## Protocol

1. **Write/update the daily note** — `vault/daily/YYYY-MM-DD.md`
   - Session Work: what was accomplished
   - Decisions: any decisions made (also append to DECISION_LOG)
   - Open Threads: what's still in progress
   - Links: previous daily note

2. **Update the session log** — `vault/memory/SESSION_LOG.md`
   - Add new entry at the top
   - Include: objective, completed items, decisions, open threads, next action
   - Keep only the last 5 entries (archive older ones)

3. **Update active priorities** — `vault/memory/ACTIVE_PRIORITIES.md`
   - Did any priority status change?
   - Any new blockers?
   - Update "Last reviewed" date

4. **Update delegation tracker** — `vault/memory/DELEGATION_TRACKER.md`
   - Mark completed items as closed
   - Update status on in-progress items
   - Flag anything stale

5. **Update any vault notes that changed** — If a concept, project, or person note has new information from this session, update it now. Don't defer.

6. **Regenerate the memory heat index** (silent) — `node daemons/memory-heat/compute-heat.js > /dev/null 2>&1`. This refreshes `vault/memory/HEAT_INDEX.json` so the next `/open` has a fresh prioritization signal. Runs in ~2 seconds on a 300-note vault. See `vault/concepts/Memory Decay Doctrine.md`.

7. **Confirm with the principal:**
   - "Here's what I committed. Next session starts with: [next action]. Anything to add?"

## Rules
- Do this INLINE — no sub-agents. The main session has the full context.
- Don't skip steps. Skipping /close means the next /open starts blind.
- Keep daily notes factual — what happened, not what was discussed.
