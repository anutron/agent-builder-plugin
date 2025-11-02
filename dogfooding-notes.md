# Dogfooding Notes - Agent Builder Plugin

Date: 2025-11-02

## Issues Found

### 1. Multiple Questions Presented at Once

**Problem:** The workflow asks 4 discovery questions all at once in a single message, which overwhelms users.

**Current Behavior:**
The agent presents:
1. What problem are you trying to solve?
2. What's your use case?
3. What data sources or tools do you need?
4. What should the output be?

**Expected Behavior:**
Questions should be asked one at a time. Users respond better to sequential, focused questions in LLM conversations rather than a multi-question barrage.

**Location:** Likely in `./.claude/commands/create-agent.md` or related workflow files

---

### 2. Command Documentation Mismatch

**Problem:** The `/review` command that gets installed doesn't match the documentation.

**Current Behavior:**
- Command description shows: "Review a pull request"
- Documentation in `create-agent.md` says it's for reviewing the workflow

**Question:** Is this the wrong command being copied, or is the documentation misleading? Should `/review` be for workflow review or PR review?

**Location:** `./.claude/commands/create-agent.md` (line 42 mentions workflow review), but the actual copied command appears to be a PR review tool

---

### 3. Commands Not Being Copied to Working Directory

**Problem:** The `/create-agent` workflow is supposed to copy commands into the user's working directory, but they're not appearing.

**Expected Behavior:**
According to `create-agent.md` line 26, should copy:
- `.claude/commands/` (review, save, setup)

**Actual Behavior:**
None of these commands (`/save`, `/review`, `/setup`) are available in the working directory after running `/create-agent`.

**Impact:** Users don't get the promised iteration tools for their workflow development.

**Location:** The copy logic in the create-agent skill/workflow

---

### 4. **CRITICAL**: create-agent Skill Not Found

**Problem:** The `/create-agent` command tries to invoke a `create-agent` skill that doesn't exist.

**Error Message:**
```
<error><tool_use_error>Unknown skill: create-agent</tool_use_error></error>
```

**Root Cause:**
The command file `./.claude/commands/create-agent.md` contains:
```
Skill: create-agent
```

But there is NO `create-agent` skill in the plugin! The `./.claude/skills/` directory contains:
- create-agent/ (directory with SKILL.md)
- save-progress/
- security-checker/
- software-best-practices/
- workflow-reviewer/

**The Problem:**
The command is trying to invoke a skill, but skills aren't being loaded by the plugin (we removed the "agents" field from plugin.json in the previous fix).

**Impact:** The entire workflow is broken. Without the skill, none of the installation/setup happens, and Claude just wings it without the proper tools and templates.

**Root Cause Analysis:**
The command is just a thin wrapper that says "invoke the create-agent skill". It doesn't contain any actual copy logic.

**What Should Happen:**
The command should directly copy files from `.claude/files-to-install/` (which exists and has all the files) into the user's working directory:
- files-to-install/commands/ → .claude/commands/
- files-to-install/skills/ → .claude/skills/
- files-to-install/agents/ → .claude/agents/
- files-to-install/knowledge/ → .claude/knowledge/
- files-to-install/templates/ → templates/

**Solution:**
Rewrite the command to directly handle the file copying and workflow orchestration instead of delegating to a skill that isn't loaded.

---

## RESOLVED

### ✅ Issue #4 - Command now has complete implementation
- **Resolution**: Merged entire 572-line skill into command file
- **Changes**: Command now contains all orchestration logic inline
- **Benefit**: No dependency on skill loading, everything in one place
- **Location**: `.claude/commands/create-agent.md` now 589 lines

### ✅ Issue #1 - Questions asked one at a time
- **Resolution**: Added "ONE QUESTION AT A TIME" instructions in Phase 1 and Phase 2
- **Changes**: Lines 74, 79, 115 explicitly state to ask questions sequentially
- **Location**: `.claude/commands/create-agent.md`

### ✅ Issue #3 - Idempotent file installation
- **Resolution**: Added checks in Phase 0 step 1 to detect existing installations
- **Behavior**:
  - If all files exist: skip installation
  - If some exist: ask user about reinstall
  - If none exist: proceed with installation
- **Location**: `.claude/commands/create-agent.md` lines 22-28

### ✅ Issue #2 - Command Documentation Mismatch
- **Resolution**: The `/review` command in `files-to-install/commands/review.md` is correct
- **Root cause**: Files weren't being copied, so user saw a different `/review` from elsewhere
- **Verification**: Checked `.claude/files-to-install/commands/review.md` - it's for workflow analysis, not PR reviews
- **Status**: Will be resolved when installation works (Issues #3/#4 fixed)

## Remaining Issues

None! All dogfooding issues have been resolved.

## Future Issues
(Add more as you discover them)

