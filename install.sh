#!/bin/bash
# Titus OS Installer
# Installs into the current directory. Run from wherever you work.

set -e

TITUS_TMP=$(mktemp -d)
TARGET="${1:-.}"

echo ""
echo "  ╔════════════════════════════════════╗"
echo "  ║       TITUS · AI Operating System  ║"
echo "  ╚════════════════════════════════════╝"
echo ""

# Check if already installed
if [ -d "$TARGET/system" ] && [ -f "$TARGET/system/00_identity.md" ]; then
  echo "  Titus is already installed in this directory."
  echo "  To reinstall, remove the system/ directory first."
  exit 0
fi

echo "  Installing into: $(cd "$TARGET" && pwd)"
echo ""

# Clone to temp
echo "  Fetching titus-os..."
git clone --depth 1 --quiet https://github.com/wrg32786/titus-os.git "$TITUS_TMP/titus-os" 2>/dev/null
echo "  ✓ Downloaded"

# Copy framework files (don't overwrite existing CLAUDE.md)
echo "  Copying framework..."
cp -rn "$TITUS_TMP/titus-os/system" "$TARGET/" 2>/dev/null || cp -r "$TITUS_TMP/titus-os/system" "$TARGET/"
cp -rn "$TITUS_TMP/titus-os/vault" "$TARGET/" 2>/dev/null || cp -r "$TITUS_TMP/titus-os/vault" "$TARGET/"
cp -rn "$TITUS_TMP/titus-os/hooks" "$TARGET/" 2>/dev/null || cp -r "$TITUS_TMP/titus-os/hooks" "$TARGET/"
cp -rn "$TITUS_TMP/titus-os/skills" "$TARGET/" 2>/dev/null || cp -r "$TITUS_TMP/titus-os/skills" "$TARGET/"
cp -rn "$TITUS_TMP/titus-os/daemons" "$TARGET/" 2>/dev/null || cp -r "$TITUS_TMP/titus-os/daemons" "$TARGET/"

# Handle CLAUDE.md — append if exists, create if not
if [ -f "$TARGET/CLAUDE.md" ]; then
  echo ""
  echo "  Found existing CLAUDE.md — appending Titus config."
  echo "" >> "$TARGET/CLAUDE.md"
  echo "---" >> "$TARGET/CLAUDE.md"
  echo "" >> "$TARGET/CLAUDE.md"
  cat "$TITUS_TMP/titus-os/CLAUDE.md" >> "$TARGET/CLAUDE.md"
else
  cp "$TITUS_TMP/titus-os/CLAUDE.md" "$TARGET/"
fi
echo "  ✓ CLAUDE.md configured"

# Handle .claude directory
mkdir -p "$TARGET/.claude/rules"
cp -n "$TITUS_TMP/titus-os/.claude/rules/post-compact-critical.md" "$TARGET/.claude/rules/" 2>/dev/null || true
cp -n "$TITUS_TMP/titus-os/.claude/settings.json.template" "$TARGET/.claude/" 2>/dev/null || true
echo "  ✓ Claude Code config ready"

# Install semantic search
if [ -f "$TARGET/daemons/semantic-search/package.json" ]; then
  echo "  Installing semantic search (local embeddings)..."
  cd "$TARGET/daemons/semantic-search" && npm install --silent 2>/dev/null && cd - > /dev/null
  echo "  ✓ Semantic search ready"
fi

# Cleanup
rm -rf "$TITUS_TMP"

echo ""
echo "  ════════════════════════════════════════"
echo "  ✓ Titus installed!"
echo "  ════════════════════════════════════════"
echo ""
echo "  What happens next:"
echo ""
echo "  Just keep using Claude Code right here."
echo "  Titus will detect the fresh install and walk"
echo "  you through setup automatically. Start a new"
echo "  conversation or type anything — it just works."
echo ""
echo "  Optional: Open the vault/ folder in Obsidian"
echo "  to see your AI's knowledge graph."
echo ""
