#!/bin/bash
# Install agent-builder tools into current directory
# Usage: bash /path/to/plugin/.claude/files-to-install/install.sh

set -e  # Exit on error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$(pwd)"

echo "Installing agent-builder tools..."
echo "Source: $SCRIPT_DIR"
echo "Target: $TARGET_DIR"
echo ""

# Create target directories
mkdir -p "$TARGET_DIR/.claude/commands"
mkdir -p "$TARGET_DIR/.claude/skills"
mkdir -p "$TARGET_DIR/.claude/agents"
mkdir -p "$TARGET_DIR/.claude/knowledge/templates"

# Copy commands
echo "📋 Copying commands..."
cp -r "$SCRIPT_DIR/commands/"* "$TARGET_DIR/.claude/commands/" 2>/dev/null || true

# Copy skills
echo "🧠 Copying skills..."
cp -r "$SCRIPT_DIR/skills/"* "$TARGET_DIR/.claude/skills/" 2>/dev/null || true

# Copy agents
echo "🤖 Copying agents..."
cp -r "$SCRIPT_DIR/agents/"* "$TARGET_DIR/.claude/agents/" 2>/dev/null || true

# Copy templates
echo "📝 Copying templates..."
cp -r "$SCRIPT_DIR/templates/"* "$TARGET_DIR/.claude/knowledge/templates/" 2>/dev/null || true

echo ""
echo "✅ Installation complete!"
echo ""
echo "Installed:"
echo "  - $(ls "$TARGET_DIR/.claude/commands" | wc -l | xargs) commands"
echo "  - $(find "$TARGET_DIR/.claude/skills" -name "SKILL.md" | wc -l | xargs) skills"
echo "  - $(ls "$TARGET_DIR/.claude/agents" 2>/dev/null | wc -l | xargs) agents"
echo "  - $(ls "$TARGET_DIR/.claude/knowledge/templates" 2>/dev/null | wc -l | xargs) templates"
