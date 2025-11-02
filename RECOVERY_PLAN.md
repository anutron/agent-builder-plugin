# Recovery Plan: Fix Agent Builder Plugin Architecture

## Current Problem

The plugin is broken because:
1. **Command delegates to skill that isn't loaded**: `/create-agent` command just says "invoke create-agent skill"
2. **Skills were removed from plugin.json**: We removed `"agents"` field to fix validation error
3. **No actual copy logic in command**: The command is just a spec, not implementation
4. **Files ready but never copied**: `.claude/files-to-install/` has everything, but nothing uses it

## What We Have (Preserved Work)

### ✅ Complete Skill Implementation
- `.claude/skills/create-agent/SKILL.md` - **572 lines** of detailed workflow orchestration
- Contains all 6 phases with detailed instructions
- Has file copying logic in Phase 0 (lines 22-65)
- Has interview process, architecture design, implementation guide
- **This is the crown jewel - must preserve**

### ✅ Files Ready to Install
- `.claude/files-to-install/` - Complete directory structure:
  - `commands/` - review.md, save.md
  - `skills/` - 4 skill directories with SKILL.md files
  - `agents/` - 5 review agent markdown files
  - `knowledge/` - templates directory
  - `templates/` - File templates (CLAUDE, README, config, etc.)

### ✅ Supporting Knowledge
- `.claude/knowledge/` - Reference docs:
  - workflow-patterns.md
  - component-decision-guide.md
  - mcp-integration.md
  - setup-command-guide.md

### ✅ Plugin Infrastructure
- `.claude-plugin/plugin.json` - Plugin manifest (needs fixing)
- `README.md`, `LICENSE`, docs/ - Documentation

## Architecture Decision (Original Intent)

**Plugin Distribution Model:**
- **Plugin itself**: Minimal - only provides `/create-agent` command
- **Command's job**: Copy tools from plugin into user's working directory
- **Why**: Avoid polluting non-workflow projects with agent-builder tools
- **Benefit**: Users can customize tools per-project after installation

## The Fix: Two Valid Approaches

### Option A: Inline Everything into Command (Simpler)
**Merge skill content into command file**

**Pros:**
- Single file, easier to maintain
- No plugin.json "agents" field needed
- Command is self-contained
- Clearer for users reading the command

**Cons:**
- Large command file (~600 lines)
- Loses separation of command (interface) vs skill (implementation)
- Can't reuse skill elsewhere

**Implementation:**
1. Copy entire `.claude/skills/create-agent/SKILL.md` content into `.claude/commands/create-agent.md`
2. Remove "invoke skill" wrapper language
3. Make it direct instructions to Claude
4. Keep plugin.json as-is (commands only, no agents)

### Option B: Fix Plugin to Load Skills (Architecturally Cleaner)
**Keep command/skill separation, fix plugin.json**

**Pros:**
- Maintains separation of concerns
- Command stays simple (entry point)
- Skill contains complex orchestration
- Follows "wrapper pattern" for commands
- More modular/reusable

**Cons:**
- Need to fix plugin.json to load skills correctly
- More files to maintain
- Plugin.json validation was failing (but we can fix)

**Implementation:**
1. Fix `.claude-plugin/plugin.json` to correctly reference skills
2. According to docs, we need the skills as individual .md files or in proper directory structure
3. Current structure: `.claude/skills/create-agent/SKILL.md`
4. Need to verify this matches plugin schema requirements

## Recommended Approach: **Option B** (Fix Plugin)

**Reasoning:**
1. **Preserves original architecture**: Command as entry point, skill as implementation
2. **Already built this way**: Both files exist and work together
3. **Better separation**: Interface vs implementation
4. **Original intent**: You built it this way for a reason
5. **Minimal changes**: Just fix plugin.json schema

## Implementation Plan

### Step 1: Understand Plugin Schema Requirements
- [ ] Read Claude Code plugin docs on `agents` field
- [ ] Understand what structure is required for skills
- [ ] Current structure: `.claude/skills/create-agent/SKILL.md` (subdirectory with SKILL.md)
- [ ] Determine if this matches schema or needs flattening

### Step 2: Fix Plugin.json
Based on schema understanding, either:
- **Option 2a**: Add `agents` field pointing to skills correctly
  ```json
  "agents": "./.claude/skills/"
  ```
  Problem: Schema said "must end with .md" - maybe needs to point to SKILL.md files directly?

- **Option 2b**: Flatten skills to root-level .md files
  - Move `.claude/skills/create-agent/SKILL.md` → `.claude/skills/create-agent.md`
  - Update plugin.json: `"agents": ["./.claude/skills/create-agent.md"]`

- **Option 2c**: Use different field name
  - Check if plugin.json supports "skills" vs "agents"
  - May be semantic difference in Claude Code

### Step 3: Verify Plugin Loads
- [ ] Test plugin installation from GitHub
- [ ] Verify skill is available when `/create-agent` is invoked
- [ ] Ensure no validation errors

### Step 4: Test End-to-End
- [ ] Run `/create-agent` in fresh directory
- [ ] Verify Phase 0 copies files from `.claude/files-to-install/`
- [ ] Verify interview questions come one at a time (fix Issue #1)
- [ ] Complete workflow and verify all files created

### Step 5: Fix Known Issues from Dogfooding
From `dogfooding-notes.md`:
- [ ] **Issue #1**: Questions one at a time (update skill instructions)
- [ ] **Issue #2**: `/review` command purpose mismatch (check what's in files-to-install)
- [ ] **Issue #3**: Commands not copied (should be fixed by Step 4)
- [ ] **Issue #4**: Skill not found (should be fixed by Steps 2-3)

## Rollback Plan

If Option B fails (can't get plugin.json to validate with skills):
- **Fallback to Option A**: Inline skill into command
- Delete `.claude/skills/` directory
- Merge skill content into command
- Simple, works, just larger file

## Files to Modify

### Primary Changes
- `.claude-plugin/plugin.json` - Add agents/skills field correctly
- Possibly `.claude/skills/create-agent/SKILL.md` - Flatten if needed

### Secondary Changes (Dogfooding Fixes)
- `.claude/skills/create-agent/SKILL.md` (lines 67-83) - Change to one question at a time
- Verify `.claude/files-to-install/commands/review.md` - Check if it's workflow review or PR review

### No Changes Needed
- ✅ `.claude/files-to-install/` - Already complete
- ✅ `.claude/knowledge/` - Already complete
- ✅ Templates - Already complete
- ✅ Documentation - Already complete

## Success Criteria

1. ✅ User installs plugin from GitHub (no validation errors)
2. ✅ User runs `/create-agent` in fresh directory
3. ✅ Files copy from plugin's `files-to-install/` to user's `.claude/`
4. ✅ Interview asks questions one at a time
5. ✅ Workflow completes all 6 phases
6. ✅ User has working commands: `/review`, `/save`, custom workflow command
7. ✅ User can customize installed tools per-project

## Time Estimate

- **Option B** (Fix plugin): 30-60 minutes
  - Research schema: 15 min
  - Fix plugin.json: 5 min
  - Test installation: 10 min
  - Fix dogfooding issues: 20 min
  - End-to-end test: 10 min

- **Option A** (Inline skill): 20-30 minutes
  - Merge files: 10 min
  - Fix dogfooding issues: 10 min
  - Test: 10 min

## Questions to Answer

1. What is the correct plugin.json schema for including skills?
2. Do skills need to be at `.claude/skills/*.md` (flat) or `.claude/skills/*/SKILL.md` (nested)?
3. Is there a difference between "agents" and "skills" fields in plugin.json?
4. Should the command copy the create-agent skill itself, or should it stay plugin-only?

## Next Steps

**Ready for your decision:**
- Do you want to proceed with Option B (fix plugin.json for skills)?
- Or fallback to Option A (inline everything into command)?

Once decided, I'll execute the plan and get this working.
