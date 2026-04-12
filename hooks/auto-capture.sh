#!/bin/bash
# Hook: PostToolUse — auto-capture meaningful tool actions to daily note
# Reads JSON from stdin, filters to write/execute actions, appends to daily note
# Must be FAST — runs on every tool call

VAULT="${TITUS_ROOT:-.}"
TODAY=$(date +%Y-%m-%d)
DAILY="$VAULT/daily/$TODAY.md"

# Read stdin (Claude Code sends JSON)
INPUT=$(cat)

# Parse and filter in one node call — skip read-only tools, emit one-line capture
CAPTURE=$(node -e "
try {
  const d = JSON.parse(process.argv[1] || '{}');
  const tool = d.tool_name || '';
  const input = d.tool_input || {};
  const now = new Date();
  const TIME = now.toTimeString().slice(0,8);

  // Skip read-only tools — only capture actions
  const SKIP = ['Read','Grep','Glob','LS','WebFetch','WebSearch','ToolSearch','TaskGet','TaskList','NotebookRead','ListMcpResourcesTool','ReadMcpResourceTool'];
  if (SKIP.includes(tool)) process.exit(0);

  // Extract brief description based on tool type
  let desc = '';
  if (tool === 'Edit' || tool === 'Write') {
    const fp = input.file_path || '';
    // Shorten path: strip vault prefix (forward or backslash)
    const vaultRoot = process.env.TITUS_ROOT || '.';
    desc = fp.replace(new RegExp('^' + vaultRoot.replace(/[.*+?^${}()|[\\]\\\\]/g, '\\\\$&') + '[/\\\\\\\\]?'), '').replace(/\\\\/g, '/');
  } else if (tool === 'Bash') {
    // First 80 chars of command
    desc = (input.command || '').substring(0, 80).replace(/\n/g, ' ');
  } else if (tool === 'Agent') {
    desc = input.description || (input.prompt || '').substring(0, 60);
  } else if (tool.startsWith('mcp__')) {
    // MCP tool — extract the meaningful part
    const parts = tool.split('__');
    const server = parts[1] || '';
    const action = parts[2] || '';
    desc = server + '/' + action;
    // Add key param if available
    if (input.query) desc += ': ' + String(input.query).substring(0, 40);
    else if (input.channel_id) desc += ' ch:' + input.channel_id;
  } else if (tool === 'TaskCreate' || tool === 'TaskUpdate') {
    desc = input.subject || input.taskId || '';
  } else if (tool === 'Skill') {
    desc = input.skill || '';
  } else {
    // Generic fallback — tool name only
    desc = JSON.stringify(input).substring(0, 60);
  }

  if (desc) console.log('- ' + TIME + ' | ' + tool + ' | ' + desc);
} catch(e) { process.exit(0); }
" "$INPUT" 2>/dev/null)

# If nothing to capture, exit silently
[ -z "$CAPTURE" ] && exit 0

# Append to daily note — create Session Captures section if needed
if [ ! -f "$DAILY" ]; then
  # Create minimal daily note
  cat > "$DAILY" << EOF
---
title: "$TODAY"
tags:
  - daily
date: $TODAY
---

# $TODAY

## Session Captures
$CAPTURE
EOF
else
  # Check if Session Captures section exists
  if grep -q "## Session Captures" "$DAILY" 2>/dev/null; then
    # Append under existing section (before next ## or end of file)
    echo "$CAPTURE" >> "$DAILY"
  else
    # Add section at end of file
    printf "\n## Session Captures\n%s\n" "$CAPTURE" >> "$DAILY"
  fi
fi
