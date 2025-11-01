# Save - Commit Progress with Context

Commit changes to git with detailed context from IMPROVEMENTS.md

## Overview

This command:
1. Checks git status
2. Reads IMPROVEMENTS.md for context
3. Stages all changes
4. Generates detailed commit message
5. Commits with full history
6. Cleans completed items from IMPROVEMENTS.md
7. Updates documentation if needed
8. Shows summary to user

## Instructions

Invoke the `save-progress` skill:

```
Skill: save-progress
```

## After Save

Offer to run `/review` for comprehensive recommendations:

"Changes committed successfully. Would you like me to run `/review` to analyze the workflow and suggest improvements?"

## User Experience

This is a manual trigger when the user wants to save their work. The skill can also be invoked autonomously by Claude when appropriate.
