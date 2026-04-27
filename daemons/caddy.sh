#!/bin/bash
# caddy.sh - Titus's skill caddy
# Non-blocking UserPromptSubmit hook. Reads the prompt from stdin,
# matches against skill-index.json, and surfaces "[CADDY] /X - why" hints
# for skills that fit the task. Silent if no strong match. Never errors.
#
# Metaphor: like a golf caddy, Caddy hands Titus the right club for the shot.
# Non-blocking because suggestions are better than enforcement — avoids the
# error-spam failure mode of strict PreToolUse hooks.
#
# Expects TITUS_ROOT env var to point to the repo root.
# Set this in your shell profile: export TITUS_ROOT="/path/to/titus-os"

ROOT="${TITUS_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
INDEX="$ROOT/.claude/skill-index.json"

[ -f "$INDEX" ] || exit 0

INPUT=$(cat 2>/dev/null)
[ -z "$INPUT" ] && exit 0

# Pass $INPUT and $INDEX via env vars — NOT via raw string interpolation inside
# the heredoc — so that prompts containing quotes or special chars can't break
# the Python code. Single-quoted 'PYEOF' prevents all shell expansion inside.
INPUT="$INPUT" INDEX="$INDEX" python3 <<'PYEOF' 2>/dev/null || exit 0
import os, sys, json, re

raw = os.environ.get("INPUT", "")
index_path = os.environ.get("INDEX", "")

try:
    payload = json.loads(raw) if raw.strip().startswith("{") else {"prompt": raw}
except Exception:
    payload = {"prompt": raw}

prompt = payload.get("prompt") or payload.get("user_prompt") or ""
if not prompt:
    sys.exit(0)

try:
    with open(index_path, "r", encoding="utf-8") as f:
        skills = json.load(f)
except Exception:
    sys.exit(0)

prompt_lower = prompt.lower()

scores = []
for skill in skills:
    name = skill.get("name","")
    triggers = [t.lower() for t in skill.get("triggers", [])]
    score = 0
    matched = []
    for trig in triggers:
        if not trig:
            continue
        if " " in trig:
            if trig in prompt_lower:
                score += 3
                matched.append(trig)
        else:
            if re.search(r"\b" + re.escape(trig) + r"\b", prompt_lower):
                score += 1
                matched.append(trig)
    if score > 0:
        scores.append((score, name, skill.get("why",""), matched))

scores.sort(reverse=True)
top = [s for s in scores if s[0] >= 2][:2]

for score, name, why, matched in top:
    print(f"[CADDY] /{name} - {why}")
PYEOF

exit 0
