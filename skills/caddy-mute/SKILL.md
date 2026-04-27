---
name: Caddy Mute
description: Suppress Caddy hints for a duration when the principal is in flow on a task and doesn't want suggestions. Respects the principal's right to flow while keeping the framework's discipline of advisory behavior intact. Mute decays automatically — never permanent.
---

# Caddy Mute

Sometimes the principal is in flow on a deep task — debugging a tricky bug, writing a complex doc, reviewing critical code — and doesn't want any suggestions surfacing for a while. Even non-blocking advisory hints can pull attention. `/caddy-mute` suppresses Caddy for a defined duration, then auto-restores.

## When to use

- The principal is in deep focus on a task and doesn't want any tool suggestions
- Recent Caddy hints have been correct but unwanted because the principal is intentionally using a different approach
- The principal is doing something experimental that doesn't fit existing skill patterns
- Triggered by Caddy on prompts like: "/caddy-mute", "mute caddy", "no suggestions", "stop hinting", "in flow", "leave me alone caddy", "quiet mode"

## How to execute

### Step 1 — Parse the duration

Default: 30 minutes if no duration given.

Accepted formats:
- `/caddy-mute` → 30 min
- `/caddy-mute 15m` → 15 min
- `/caddy-mute 2h` → 2 hours
- `/caddy-mute until /close` → until the next `/close` invocation
- `/caddy-mute today` → until end of current local day

Maximum duration: until end of current day. Caddy mute is never permanent — if the principal wants to disable it longer, they should remove the hook entirely (and reckon with that decision).

### Step 2 — Optionally capture a reason

Ask: "Reason? (optional, one line — gets logged for retrospective)"

If the principal provides one, capture it. If not, proceed.

### Step 3 — Write the mute state

Write to `vault/memory/caddy-mute-state.json`:

```json
{
  "muted_until": "2026-04-26T17:30:00Z",
  "reason": "deep debugging session on auth bug",
  "started_at": "2026-04-26T17:00:00Z",
  "originally_requested_duration": "30m"
}
```

### Step 4 — Update the Caddy daemon to respect the mute

The Caddy daemon (`daemons/caddy.sh`) checks for this file at the start of each invocation. If it exists AND `muted_until` is in the future, the daemon exits silently without scoring.

If the file exists AND `muted_until` is in the past, the daemon deletes it (auto-cleanup) and proceeds normally.

### Step 5 — Confirm to the principal

Output:

```
🔇 Caddy muted for {N minutes}.
   Reason: {if provided}
   Auto-restores at: {timestamp}

   Run /caddy-mute again to extend, or /caddy-unmute to restore early.
```

### Step 6 — Log to retrospective

Append a one-line entry to `vault/memory/caddy-mute-log.md`:

```
- 2026-04-26 17:00 — muted for 30m — reason: "deep debugging session on auth bug"
```

This becomes data for `/skill-audit` and quarterly retrospectives. If mute happens often, it's signal that Caddy's signal-to-noise needs tuning.

## Why this skill exists

The framework's discipline is **advisory by default**. The principal's discipline is **flow when flow matters**. These two can collide — even a correct hint can interrupt deep work.

`/caddy-mute` resolves the collision without breaking either discipline:
- Caddy stays advisory by default (no permanent disable)
- The principal gets flow protection for bounded windows
- The mute self-restores so the framework can't accidentally lose its advisory layer permanently

## What this skill should NEVER become

- **Permanent disable.** If the principal wants Caddy off for good, that's a decision they should make consciously by removing the hook configuration.
- **Per-skill mute** in v1. Could be added later if data shows specific skills firing inappropriately. For now: all-or-nothing per session window.
- **Silent failure.** If the mute file is malformed, the daemon should fall back to unmuted (advisory) behavior, not silently break.

## Connects to

- [[Caddy]] — the system this skill mutes
- [[Suggestion Credibility]] — the doctrine this skill respects (the principal's right to flow is part of the suggestion-trust contract)
- `/caddy-explain` — companion skill for inspecting Caddy's decisions
- `/caddy-audit` — companion skill for the index/file drift audit
