#!/bin/bash
# Hook: Stop — log session token usage to vault
# Parses current session JSONL, computes tokens + estimated cost, appends to usage log

VAULT="${TITUS_ROOT:-.}"
USAGE_LOG="$VAULT/memory/usage_log.md"
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$HOME/.claude/projects}"
TODAY=$(date +%Y-%m-%d)
TIME=$(date +%H:%M:%S)

LATEST=$(ls -t "$PROJECT_DIR"/*.jsonl 2>/dev/null | head -1)
[ -z "$LATEST" ] && exit 0

# Parse JSONL and compute usage + cost in one node call
ENTRY=$(node -e "
const fs = require('fs');
const lines = fs.readFileSync(process.argv[1], 'utf8').split('\n').filter(Boolean);
let input = 0, output = 0, cacheCreate = 0, cacheRead = 0, calls = 0;
let firstTs = null, lastTs = null;

for (const line of lines) {
  try {
    const j = JSON.parse(line);
    if (j.type === 'assistant' && j.message?.usage) {
      const u = j.message.usage;
      input += (u.input_tokens || 0);
      output += (u.output_tokens || 0);
      cacheCreate += (u.cache_creation_input_tokens || 0);
      cacheRead += (u.cache_read_input_tokens || 0);
      calls++;
    }
    if (j.type === 'assistant') {
      const ts = j.timestamp || j.message?.timestamp;
      if (ts) {
        const d = new Date(ts).getTime();
        if (!isNaN(d)) {
          if (!firstTs) firstTs = d;
          lastTs = d;
        }
      }
    }
  } catch(e) {}
}

if (input === 0 && output === 0) process.exit(0);

// Opus pricing per million tokens
const inputCost = (input / 1e6) * 15;
const outputCost = (output / 1e6) * 75;
const cacheCreateCost = (cacheCreate / 1e6) * 18.75;
const cacheReadCost = (cacheRead / 1e6) * 1.50;
const totalCost = inputCost + outputCost + cacheCreateCost + cacheReadCost;

const durationMin = (firstTs && lastTs) ? Math.round((lastTs - firstTs) / 60000) : 0;
const dur = durationMin > 0 ? durationMin + 'min' : '<1min';

const fmt = (n) => n >= 1000 ? Math.round(n/1000) + 'K' : String(n);

console.log('| ' + process.argv[2] + ' ' + process.argv[3] + ' | ' + dur + ' | ' + fmt(input) + ' | ' + fmt(output) + ' | ' + fmt(cacheRead) + ' | ' + calls + ' | \$' + totalCost.toFixed(2) + ' |');
" "$LATEST" "$TODAY" "$TIME" 2>/dev/null)

[ -z "$ENTRY" ] && exit 0

# Create usage log if it doesn't exist
if [ ! -f "$USAGE_LOG" ]; then
  cat > "$USAGE_LOG" << 'EOF'
---
title: Token Usage Log
tags:
  - memory
  - operations
aliases:
  - usage log
---

# Token Usage Log

Running log of per-session token spend for [[Titus]]. Updated automatically on session end.

| Date | Duration | Input | Output | Cache Read | Calls | Est. Cost |
|------|----------|-------|--------|------------|-------|-----------|
EOF
fi

echo "$ENTRY" >> "$USAGE_LOG"
