# Improve Workflow - Retrospective on Actual Use

Reflect on how the workflow performed the last time you used it, capture lessons learned, and improve it.

## Overview

This command:
1. Asks what happened the last time you ran your workflow
2. Captures friction points and lessons in `IMPROVEMENTS.md`
3. Offers to fix what didn't work
4. Occasionally offers a "level up" idea once the workflow is stable
5. Offers to commit changes with `/save-workflow`

## Instructions

Invoke the `workflow-improver` skill:

```
Skill: workflow-improver
```

## When to Run This

**Best moment: right at the end of a session where you just ran the workflow.** Everything that went wrong is still in the conversation – the bits you had to clarify, the output you asked to be redone, the step that took three tries. Run it then and Claude can point those out to you, instead of asking you to remember them.

Running it later still works; you'll just be going from memory.

Either way, run it after you've actually *used* the workflow – not right after building it. The habit worth building is: build it, use it, run `/improve-workflow`, use it again.

This is different from `/review-workflow`, which checks code quality, security, and best practices regardless of whether you've run the workflow yet.

## User Experience

This is a short, low-pressure check-in. It's fine if the answer is "nothing to report" – the goal is the habit of checking in, not finding problems that aren't there.
