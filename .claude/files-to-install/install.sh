#!/bin/bash
# Install agent-builder tools into current directory
# Usage: bash /path/to/plugin/.claude/files-to-install/install.sh [--backup]

set -e  # Exit on error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$(pwd)"
BACKUP_MODE=false

# Parse arguments
if [[ "$1" == "--backup" ]]; then
    BACKUP_MODE=true
fi

echo "Installing agent-builder tools..."
echo "Source: $SCRIPT_DIR"
echo "Target: $TARGET_DIR"
echo ""

# Create backup if requested
if [ "$BACKUP_MODE" = true ]; then
    TIMESTAMP=$(date +%Y%m%d-%H%M%S)
    OLD_VERSION="unknown"
    if [ -f "$TARGET_DIR/.agent-builder-version" ]; then
        OLD_VERSION=$(cat "$TARGET_DIR/.agent-builder-version")
    fi
    BACKUP_DIR="$TARGET_DIR/.claude/backups/agent-builder-$OLD_VERSION-$TIMESTAMP"

    echo "📦 Creating backup..."
    mkdir -p "$BACKUP_DIR/commands"
    mkdir -p "$BACKUP_DIR/skills"
    mkdir -p "$BACKUP_DIR/agents"
    mkdir -p "$BACKUP_DIR/knowledge/templates"

    # Backup existing files
    cp -r "$TARGET_DIR/.claude/commands/review.md" "$BACKUP_DIR/commands/" 2>/dev/null || true
    cp -r "$TARGET_DIR/.claude/commands/save.md" "$BACKUP_DIR/commands/" 2>/dev/null || true
    cp -r "$TARGET_DIR/.claude/skills/"* "$BACKUP_DIR/skills/" 2>/dev/null || true
    cp -r "$TARGET_DIR/.claude/agents/"* "$BACKUP_DIR/agents/" 2>/dev/null || true
    cp -r "$TARGET_DIR/.claude/knowledge/templates/"* "$BACKUP_DIR/knowledge/templates/" 2>/dev/null || true

    echo "   Backed up to: $BACKUP_DIR"
    echo ""
fi

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
