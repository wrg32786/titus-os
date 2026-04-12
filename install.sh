#!/bin/bash
# Titus OS Installer
# Clone, set up semantic search, and print clear next steps.

set -e

INSTALL_DIR="${1:-$HOME/titus-os}"

echo ""
echo "  ╔════════════════════════════════════╗"
echo "  ║       TITUS · AI Operating System  ║"
echo "  ╚════════════════════════════════════╝"
echo ""

# Clone if not already in a titus-os directory
if [ ! -f "CLAUDE.md" ] || ! grep -q "Titus" "CLAUDE.md" 2>/dev/null; then
  echo "  Cloning titus-os to $INSTALL_DIR..."
  git clone https://github.com/wrg32786/titus-os.git "$INSTALL_DIR" 2>/dev/null
  cd "$INSTALL_DIR"
  echo "  ✓ Cloned"
else
  INSTALL_DIR=$(pwd)
  echo "  Already in titus-os directory."
fi

# Install semantic search
if [ -f "daemons/semantic-search/package.json" ]; then
  echo "  Installing semantic search (local embeddings)..."
  cd daemons/semantic-search && npm install --silent 2>/dev/null && cd ../..
  echo "  ✓ Semantic search ready"
fi

echo ""
echo "  ════════════════════════════════════════"
echo "  Installation complete!"
echo "  ════════════════════════════════════════"
echo ""
echo "  NEXT STEP:"
echo ""
echo "  Open Claude Code in the titus-os directory:"
echo ""
echo "    cd $INSTALL_DIR && claude"
echo ""
echo "  Titus will detect the fresh install and walk you"
echo "  through setup automatically. Just start talking."
echo ""
echo "  Optional: Open the vault/ folder in Obsidian"
echo "  to see your AI's knowledge graph."
echo ""
