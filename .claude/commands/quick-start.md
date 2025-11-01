# Quick Start - Build a Workflow Agent

Guide the user through creating an MCP-powered workflow agent from scratch.

## Overview

This command walks users through:
1. Use case discovery
2. Process interview
3. Improvement plan design
4. V1 implementation
5. Iteration planning

## Instructions

Invoke the `quick-start` skill to orchestrate this workflow:

```
Skill: quick-start
```

The skill will handle all phases and create:
- `/project-plan/` directory with interview notes, design, and improvements backlog
- `.claude/` directory with workflow commands/skills/agents
- `.claude/config.json` with local permissions (reduces permission prompts)
- `/setup` command documenting how to recreate local settings
- `CLAUDE.md` with project-specific instructions
- `README.md` with usage documentation
- `.gitignore` with security patterns
- First git commit with all planning docs

## After Completion

When the skill completes, show the user:
1. How to run their new workflow
2. Where documentation lives
3. How to iterate with `/save` and `/review`
4. Next steps for V2

## User Experience

Be conversational and collaborative. This is a guided session, not just code generation. Ask questions, explain decisions, get buy-in before implementing.
