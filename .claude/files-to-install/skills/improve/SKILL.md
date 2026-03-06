---
name: improve
description: End-of-session retrospective that upgrades skills, fixes codebase gaps, and captures learnings for future sessions.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion
---

# Improve - Session Retrospective

Analyze the current conversation to improve the workflow, fix gaps, and capture durable knowledge.

## When to Use

Run `/improve` at the end of any session where:
- The workflow was run and required manual fixes or workarounds
- You discovered better patterns or approaches mid-conversation
- Something took multiple iterations to get right
- Technical assumptions turned out to be wrong
- You learned something that would make the workflow work better next time

## Instructions

### Step 1: Identify What Happened

Scan the conversation for:
- Workflow commands that were run (`/[workflow-name]`, `/review`, `/save`)
- Manual steps the user had to do that could be automated
- Errors that were encountered and how they were resolved
- Patterns that emerged from the work

List each with a brief note on what happened.

### Step 2: Extract Learnings

For each item identified, analyze:
1. **What worked well** - smooth execution, no issues
2. **Friction points** - where did the user need to iterate or correct?
3. **Technical discoveries** - new knowledge about how tools/APIs/MCPs work
4. **Incorrect assumptions** - anything in the workflow files that turned out wrong
5. **Missing capabilities** - things the user asked for that the workflow didn't cover

### Step 3: Propose Improvements

Draft specific changes for each learning:
- **Fix errors** in workflow files (wrong API patterns, outdated references)
- **Add learned patterns** (e.g., "when querying this API, always paginate")
- **Add missing instructions** for gaps discovered during the session
- **Suggest new commands or skills** if a recurring pattern doesn't have one yet

Present each proposed change as a before/after diff for user review.

### Step 4: Apply Approved Changes

1. Ask which changes to apply (default: all)
2. Edit the files with approved changes
3. Summarize what was updated

### Step 5: Fix Codebase Gaps

Review the session for project issues that were discovered but not fixed:
- Missing or outdated documentation (README, CLAUDE.md)
- Missing tests for code paths exercised manually
- Missing error handling that caused failures
- Configuration gaps (env vars, MCP setup)

For each gap: describe it, propose a fix, apply after user approval.

Only fix gaps actually encountered during the session — don't speculatively audit.

### Step 6: Check for New Skill Opportunities

Look for patterns not covered by any existing command or skill:
- Multi-step workflows done manually
- Recurring command sequences
- Integration patterns with MCP tools

If found, propose a new skill with a description of what it would do. Write it to `.claude/skills/<name>/SKILL.md` in this project.

### Step 7: Update IMPROVEMENTS.md

Add any deferred items or V2+ ideas to `project-plan/IMPROVEMENTS.md`.

### Step 8: Summary

Present a final report:

```
# Session Improvement Report

## What Happened
1. /command -- what it did

## Improvements Applied
1. File: description of change

## Codebase Gaps Fixed
1. File: what was fixed

## New Skills Proposed
- /name -- what it would do

## Deferred to IMPROVEMENTS.md
- Item description
```

## What NOT to Improve

- Don't add session-specific details (specific file paths, query results) to skills
- Don't bloat skills with edge cases that won't recur
- Don't change the fundamental purpose of a skill
- Don't add improvements based on speculation — only from actual session experience

## Philosophy

Each `/improve` run should leave the workflow measurably better than it found it. Small, targeted changes applied often compound into a system that gets better every session.
