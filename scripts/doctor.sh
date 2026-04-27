#!/bin/bash
# Titus OS Doctor
# Diagnoses install health. Exit 0 = no FAILs. Exit 1 = at least one FAIL.
# Usage: bash scripts/doctor.sh [titus-root-path]
#
# Checks:
#   - Titus root detected
#   - system kernel present
#   - vault present
#   - CLAUDE.md present
#   - skills present
#   - hooks present
#   - .claude/settings.json present and TITUS_ROOT placeholder resolved
#   - Node.js available (optional)
#   - semantic search node_modules present (if Node available)
#   - all shell scripts pass bash -n syntax check
#   - all JSON files parse cleanly

set -euo pipefail

# ── Resolve root ──────────────────────────────────────────────────────────────
ROOT="${1:-}"
if [ -z "$ROOT" ]; then
  # Try env var, then try to find markers in cwd / parent
  if [ -n "${TITUS_ROOT:-}" ] && [ -d "$TITUS_ROOT" ]; then
    ROOT="$TITUS_ROOT"
  elif [ -f "$(pwd)/system/00_identity.md" ]; then
    ROOT="$(pwd)"
  elif [ -f "$(pwd)/../system/00_identity.md" ]; then
    ROOT="$(cd "$(pwd)/.." && pwd)"
  fi
fi

# ── Counters ──────────────────────────────────────────────────────────────────
PASS=0
WARN=0
FAIL=0

pass()  { echo "  ✓ $1"; PASS=$((PASS + 1)); }
warn()  { echo "  ⚠ $1"; WARN=$((WARN + 1)); }
fail()  { echo "  ✗ $1"; FAIL=$((FAIL + 1)); }

echo ""
echo "  Titus OS Doctor"
echo "  ────────────────────────────────────────"

# ── 1. Root detection ─────────────────────────────────────────────────────────
if [ -z "$ROOT" ]; then
  fail "Titus root not found — run from install dir, pass path as arg, or set TITUS_ROOT"
  echo ""
  echo "  Summary: ${PASS} PASS, ${WARN} WARN, ${FAIL} FAIL"
  exit 1
fi

pass "Titus root: $ROOT"

# ── 2. System kernel ──────────────────────────────────────────────────────────
if [ -f "$ROOT/system/00_identity.md" ]; then
  pass "system kernel found (system/00_identity.md)"
else
  fail "system/00_identity.md missing — kernel not installed"
fi

# ── 3. Vault ──────────────────────────────────────────────────────────────────
if [ -d "$ROOT/vault" ]; then
  pass "vault found"
else
  warn "vault/ directory missing — memory layer not installed (may be intentional for fresh setup)"
fi

if [ -f "$ROOT/vault/memory/ACTIVE_PRIORITIES.md" ]; then
  pass "vault/memory/ACTIVE_PRIORITIES.md found"
else
  warn "vault/memory/ACTIVE_PRIORITIES.md missing — expected after first /close (per-user, may be empty on fresh install)"
fi

# ── 4. CLAUDE.md ──────────────────────────────────────────────────────────────
if [ -f "$ROOT/CLAUDE.md" ]; then
  pass "CLAUDE.md found"
else
  fail "CLAUDE.md missing — Titus will not load without it"
fi

# ── 5. Skills ─────────────────────────────────────────────────────────────────
if [ -d "$ROOT/skills" ]; then
  pass "skills/ source templates found"
else
  warn "skills/ missing — slash commands not available"
fi

if [ -d "$ROOT/.claude/skills" ]; then
  pass ".claude/skills/ runtime directory found"
else
  warn ".claude/skills/ missing — Claude Code cannot resolve slash commands (run installer or copy skills/ manually)"
fi

# ── 6. Hooks ──────────────────────────────────────────────────────────────────
if [ -d "$ROOT/hooks" ]; then
  pass "hooks/ found"
else
  warn "hooks/ missing — background automation not installed"
fi

# ── 7. .claude/settings.json + TITUS_ROOT placeholder check ──────────────────
SETTINGS="$ROOT/.claude/settings.json"
SETTINGS_TEMPLATE="$ROOT/.claude/settings.json.template"
if [ -f "$SETTINGS" ]; then
  if grep -q "TITUS_ROOT" "$SETTINGS" 2>/dev/null; then
    fail ".claude/settings.json contains literal TITUS_ROOT — placeholder not substituted. Run: sed -i \"s|TITUS_ROOT|\$(pwd)|g\" .claude/settings.json"
  else
    pass ".claude/settings.json — paths resolved (no TITUS_ROOT literal)"
  fi
elif [ -f "$SETTINGS_TEMPLATE" ]; then
  warn ".claude/settings.json missing but template found — run installer to generate it, or: sed \"s|TITUS_ROOT|\$(pwd)|g\" .claude/settings.json.template > .claude/settings.json"
else
  fail ".claude/settings.json and settings.json.template both missing — hooks will not fire"
fi

# ── 8. Node.js ────────────────────────────────────────────────────────────────
NODE_OK=0
if command -v node >/dev/null 2>&1; then
  NODE_VER=$(node --version 2>/dev/null | sed 's/v//')
  NODE_MAJOR=$(echo "$NODE_VER" | cut -d. -f1)
  if [ "$NODE_MAJOR" -ge 18 ] 2>/dev/null; then
    pass "Node.js $NODE_VER found (≥18 — semantic search supported)"
    NODE_OK=1
  else
    warn "Node.js $NODE_VER found but <18 — semantic search requires Node 18+. Upgrade: nvm install 18"
  fi
else
  warn "Node.js not found — semantic search and hook automation will be skipped (optional)"
fi

# ── 9. Semantic search node_modules ──────────────────────────────────────────
if [ "$NODE_OK" -eq 1 ]; then
  if [ -d "$ROOT/daemons/semantic-search/node_modules" ]; then
    pass "daemons/semantic-search/node_modules found — semantic search ready"
  else
    warn "daemons/semantic-search/node_modules missing — run: cd daemons/semantic-search && npm install"
  fi
else
  warn "semantic search install check skipped (Node not available)"
fi

# ── 10. Shell script syntax check ────────────────────────────────────────────
SH_FAIL=0
SH_COUNT=0
while IFS= read -r -d '' script; do
  SH_COUNT=$((SH_COUNT + 1))
  if ! bash -n "$script" 2>/dev/null; then
    fail "shell syntax error: $script"
    SH_FAIL=$((SH_FAIL + 1))
  fi
done < <(find "$ROOT" -name "*.sh" -not -path "*/node_modules/*" -print0 2>/dev/null)

if [ "$SH_FAIL" -eq 0 ] && [ "$SH_COUNT" -gt 0 ]; then
  pass "all ${SH_COUNT} shell scripts pass bash -n syntax check"
elif [ "$SH_COUNT" -eq 0 ]; then
  warn "no .sh files found to check"
fi

# ── 11. JSON syntax check ─────────────────────────────────────────────────────
JSON_FAIL=0
JSON_COUNT=0
if command -v python3 >/dev/null 2>&1; then
  while IFS= read -r -d '' jfile; do
    JSON_COUNT=$((JSON_COUNT + 1))
    if ! python3 -m json.tool "$jfile" >/dev/null 2>&1; then
      fail "JSON parse error: $jfile"
      JSON_FAIL=$((JSON_FAIL + 1))
    fi
  done < <(find "$ROOT" -name "*.json" -not -path "*/node_modules/*" -print0 2>/dev/null)

  if [ "$JSON_FAIL" -eq 0 ] && [ "$JSON_COUNT" -gt 0 ]; then
    pass "all ${JSON_COUNT} JSON files parse cleanly"
  elif [ "$JSON_COUNT" -eq 0 ]; then
    warn "no .json files found to check"
  fi
else
  warn "python3 not found — JSON syntax check skipped"
fi

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo "  ────────────────────────────────────────"
echo "  Summary: ${PASS} PASS, ${WARN} WARN, ${FAIL} FAIL"

if [ "$FAIL" -eq 0 ]; then
  echo "  Titus is operational."
  echo ""
  exit 0
else
  echo "  Fix the above FAILs before using Titus."
  echo ""
  exit 1
fi
