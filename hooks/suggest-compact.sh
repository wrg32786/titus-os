#!/bin/bash
# Track tool calls per session and suggest /clear at threshold
COUNTER_FILE="/tmp/claude-tool-counter-$$"
if [ ! -f "$COUNTER_FILE" ]; then
  echo "0" > "$COUNTER_FILE"
fi

COUNT=$(cat "$COUNTER_FILE")
COUNT=$((COUNT + 1))
echo "$COUNT" > "$COUNTER_FILE"

THRESHOLD=${COMPACT_THRESHOLD:-50}
if [ "$COUNT" -eq "$THRESHOLD" ]; then
  echo "[EFFICIENCY] $COUNT tool calls this session. Consider /clear if switching topics to free context."
fi
