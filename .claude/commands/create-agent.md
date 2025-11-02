# Create Agent - Build a Workflow Agent

Guide the user through creating an MCP-powered workflow agent from scratch.

## Overview

This command:
1. Installs all agent-builder tools into the current directory
2. Walks users through workflow creation:
   - Use case discovery
   - Process interview
   - Architecture design
   - V1 implementation
   - Git initialization

## Instructions

Invoke the `create-agent` skill to orchestrate this workflow:

```
Skill: create-agent
```

The skill will:
1. **Install phase**: Copy agent-builder tools into current directory
   - `.claude/commands/` (review, save, setup)
   - `.claude/skills/` (workflow-reviewer, save-progress, security-checker, software-best-practices)
   - `.claude/agents/` (5 review agents)
   - `.claude/knowledge/` (templates, guides)

2. **Creation phase**: Guide user through workflow design
   - Discovery interview
   - Data source setup
   - Architecture design
   - Implementation
   - Git commit

## After Completion

When the skill completes, the user's project will have:
- A complete workflow (commands, skills, or agents)
- Self-contained tools (`/review`, `/save`, `/setup`)
- Documentation (`CLAUDE.md`, `README.md`)
- Planning docs (`project-plan/`)
- Git repository initialized

Show the user:
1. How to run their new workflow
2. How to iterate with `/review` and `/save`
3. Next steps for V2 features

## User Experience

Be conversational and collaborative. This is a guided session, not just code generation. Ask questions, explain decisions, get buy-in before implementing.
