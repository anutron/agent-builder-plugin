---
name: software-best-practices
description: Validate that the project runs, has basic tests, clear errors, and reasonable organization. Personal project standard, not enterprise.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

# Software Best Practices

Ensure the project meets a "personal project" quality bar: it runs, it's testable, and errors are clear.

## What to Check

### 1. Code Runs
Find the entry point (run script, `main.py`, `npm start`, etc.) and execute it. Fix issues until it works or you hit a blocker that needs user input.

### 2. Tests Exist and Pass
Look for test files. Run them. If none exist, recommend adding basic happy-path tests for core logic.

### 3. Clear Error Messages
Spot-check error handling. Flag silent failures (`except: pass`, empty catch blocks) and unclear error messages.

### 4. Reasonable Organization
Flag single files over ~500 lines, functions doing too many things, or no clear structure. Don't over-engineer — suggest splits only when it helps readability.

### 5. Run Script
There should be a one-command way to run the project. If missing, suggest creating one.

## Execution Loop

Don't just read — run the code. Fix issues one at a time. Re-run after each fix. Only involve the user when you need input or hit a real blocker.

## Goal Drift Check

If you've spent 20+ minutes on tooling/infrastructure or hit 3+ obstacles, stop and ask:
- Is this obstacle blocking the goal or just my approach?
- What's the simplest way to achieve the original goal?
- Should this be deferred to IMPROVEMENTS.md?

## What NOT to Require

This is personal-project quality, not production:
- No need for 100% test coverage, CI/CD, type hints everywhere, or extensive docs
- Focus on: runs, testable, clear errors, findable code

## Output

Write findings to `project-plan/IMPROVEMENTS.md` under a Code Quality section.
