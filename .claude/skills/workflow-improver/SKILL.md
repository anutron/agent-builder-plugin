---
name: workflow-improver
description: Retrospective on how the workflow performed in actual use. Captures friction points and lessons learned, updates the workflow's own files, and occasionally suggests leveling up. Use after running the built workflow, not just after building it.
allowed-tools: Read, Write, Edit, Bash, Grep, Glob, AskUserQuestion
---

# Workflow Improver Skill

You are helping the user reflect on how their workflow performed in actual use, and improve it based on what was learned.

This is the retrospective step in the loop: **build → use → improve → use again**. Unlike `workflow-reviewer` (which checks code quality, security, and best practices regardless of whether the workflow has been run), this is about capturing what you *learned* from actually using the thing.

## Your Task

### Step 1: Confirm there's something to reflect on

Check for `project-plan/project-design.md`. If it doesn't exist, this workflow hasn't been through `/create-agent` yet — tell the user and stop.

### Step 2: Ask about the most recent run

Ask (one question): "Tell me about the last time you ran this workflow. What worked, what didn't, and did anything surprise you?"

Follow up if useful, one at a time:
- Did you have to explain something to Claude that it should have already known?
- Did you have to fix or redo anything by hand?
- Was there a step that felt slower or clunkier than it should be?
- Did it produce exactly what you needed, or did you have to touch up the output?

### Step 3: Capture the lesson

Append to `project-plan/IMPROVEMENTS.md` under a `## Lessons from using this workflow` section:
- What happened
- What should change (if anything)
- Date

If the user reports no friction at all, that's a valid outcome — log it briefly and move on. Don't manufacture problems.

### Step 4: Offer to make the change

If a concrete improvement was identified, offer to implement it now:
- Update the workflow's command/skill/agent files
- Update `CLAUDE.md` if a pattern or instruction should be remembered project-wide
- Update knowledge files if reference material needs a fix

Ask before changing anything: "Want me to make that change now?"

### Step 5: Occasionally offer a "level up"

If this is at least the 2nd or 3rd time `/improve-workflow` has been run on this project (count existing entries under "Lessons from using this workflow") and things have been running smoothly for a couple of rounds, consider offering ONE contextual "level up" idea — the same kind of offer `/create-agent`'s Phase 5 makes after the first successful build (see `.claude/knowledge/component-decision-guide.md` for the menu: code instead of prose, a local web server, the `/workflows` tool, etc.). Tie it to something concrete the workflow actually does. Keep it low-pressure — this is an offer, not a recommendation to rebuild.

🧭 Guide's note: This mirrors the real habit of running a retrospective after using something you built, not just when you build it.

### Step 6: Offer to save

"Want me to commit these changes with `/save-workflow`?"

## Error Handling

**If no `IMPROVEMENTS.md` exists yet**: create it with the "Lessons from using this workflow" section.

**If the user has nothing to report**: don't push. Log "Ran cleanly, no issues" and move on quickly — the goal is building the habit of checking in, not manufacturing work.
