# Component Decision Guide

Guide for deciding when to use Commands, Skills, Agents, or Knowledge files in workflow architecture.

## Decision Tree

```
Is this a user-facing entry point?
├─ YES → Command (/workflow-name)
└─ NO ↓

Is this logic used by multiple commands/workflows?
├─ YES → Skill (reusable component)
└─ NO ↓

Does this run in parallel with other work?
├─ YES → Agent (parallel worker via Task tool)
└─ NO ↓

Is this reference material/data?
├─ YES → Knowledge file
└─ NO → Inline in command
```

## Commands

**Use when:**
- User types `/command-name` to start workflow
- Entry point for a complete workflow
- Need to orchestrate multiple phases/steps

**Characteristics:**
- Lives in `.claude/commands/[name].md`
- User-facing (appears in slash command menu)
- Contains workflow logic OR orchestrates skills/agents
- Can invoke skills, agents, or use tools directly

**Examples:**
- `/write-prd` - Creates product requirements document
- `/analyze-tickets` - Analyzes support tickets
- `/review-code` - Reviews code changes

**Don't use for:**
- Reusable logic (use Skills instead)
- Parallel workers (use Agents instead)
- Reference data (use Knowledge files instead)

## Skills

**Use when:**
- Logic is reusable across multiple commands
- Component needs composition (skills calling skills)
- Want to enforce tool restrictions
- Building a library of capabilities

**Characteristics:**
- Lives in `.claude/skills/[name]/SKILL.md`
- Has YAML metadata (name, description, allowed-tools)
- Invoked with `Skill` tool
- Can be composed (skills invoke other skills)
- Tool restrictions enforced

**Examples:**
- `query-validator` - Validates queries (used by multiple commands)
- `security-checker` - Scans for secrets (reusable across projects)
- `notion-writer` - Writes to Notion (used in multiple workflows)

**Don't use for:**
- One-off logic in single command (inline instead)
- Parallel execution (use Agents instead)
- User entry points (use Commands instead)

## Agents

**Use when:**
- Work can run in parallel with other work
- Independent task with clear input/output
- Want to minimize blocking time
- Each agent works on separate data source

**Characteristics:**
- Lives in `.claude/agents/[name].md`
- Invoked with `Task` tool + `subagent_type` parameter
- Runs independently (parallel execution)
- No metadata format (just markdown prompt)
- Can't invoke other agents (flat hierarchy)

**Examples:**
- `research-notion` - Searches Notion (parallel with other research)
- `research-slack` - Searches Slack (parallel with other research)
- `write-section-1` - Writes one section (parallel with other sections)

**Pattern: Launch multiple agents in single message**
```markdown
Use Task tool to launch these agents in parallel:
- Agent 1: research-notion (searches Notion)
- Agent 2: research-slack (searches Slack)
- Agent 3: research-github (searches GitHub)

All run simultaneously, results merged after completion.
```

**Don't use for:**
- Sequential work that depends on previous steps
- Reusable logic (use Skills instead)
- User entry points (use Commands instead)

## Knowledge Files

**Use when:**
- Storing reference data
- Templates or examples
- Guidelines or rules
- Data that changes independently of logic

**Characteristics:**
- Lives in `.claude/knowledge/[name].md`
- Pure data/documentation (no executable logic)
- Referenced by commands/skills/agents
- Can be updated without changing code

**Examples:**
- `interview-guide.md` - Questions to ask users
- `validation-rules.md` - Rules for validating output
- `content-templates.json` - Templates for generated content
- `table-schemas.md` - Database schema documentation

**Don't use for:**
- Executable logic (use Skills/Commands instead)
- User workflows (use Commands instead)

## Common Patterns

### Pattern 1: Command → Multiple Parallel Agents
**Use case:** Research from multiple sources simultaneously

```
Command: /write-prd
├─ Agent: research-notion (parallel)
├─ Agent: research-slack (parallel)
└─ Agent: research-github (parallel)
```

**Why:** Minimize blocking time (30s parallel vs 90s serial)

### Pattern 2: Command → Multiple Skills
**Use case:** Reusable validation and execution logic

```
Command: /run-query
├─ Skill: query-validator (validates syntax)
├─ Skill: security-checker (checks for risks)
└─ Skill: query-executor (runs query)
```

**Why:** Each skill reusable by other commands

### Pattern 3: Command → Skill → Agents
**Use case:** Orchestration skill that launches parallel work

```
Command: /generate-report
└─ Skill: report-generator
   ├─ Agent: fetch-data-source-1 (parallel)
   ├─ Agent: fetch-data-source-2 (parallel)
   └─ Agent: fetch-data-source-3 (parallel)
```

**Why:** Skill encapsulates parallel orchestration logic

### Pattern 4: Command → Skill (Manual Access)
**Use case:** Expose reusable skill as user command

```
Command: /save
└─ Skill: save-progress (git commit with context)

Command: /review
└─ Skill: workflow-reviewer (analyze and recommend)
```

**Why:**
- Skill is reusable (other commands can invoke it)
- Command provides manual user access
- Thin wrapper pattern (command just invokes skill)

### Pattern 5: Command → Knowledge Files
**Use case:** Data-driven workflow

```
Command: /interview
└─ Reads: knowledge/interview-questions.md
```

**Why:** Questions can be updated without changing command logic

## Architecture Examples

**Note**: These are architectural patterns from real projects, not recommendations for specific workflows to build. Use these patterns as inspiration for your own use cases.

### Example Pattern: Document Writer (Research → Generate → Publish)

```
Command: /write-document
├─ Phase 1: Research (parallel agents)
│  ├─ Agent: research-source-1
│  └─ Agent: research-source-2
├─ Phase 2: Interview (command inline logic)
├─ Phase 3: Generate (command inline logic)
│  └─ References: knowledge/content-guidelines.md
└─ Phase 4: Publish (parallel agents)
   ├─ Agent: write-section-1
   ├─ Agent: write-section-2
   └─ Agent: write-section-3
```

**Why this architecture:**
- Command: User entry point, orchestrates phases
- Agents: Parallel research and writes (speed optimization)
- Knowledge: Content guidelines separate from logic
- Inline: Interview logic specific to this workflow

**Use this pattern for:** Documents, reports, PRDs, proposals, summaries

### Example Pattern: Data Tool (Explore → Validate → Execute)

```
Command: /build-artifact
└─ Skill: artifact-builder (orchestrator)
   ├─ Skill: source-1-explorer (parallel)
   ├─ Skill: source-2-explorer (parallel)
   ├─ Skill: source-3-explorer (parallel)
   ├─ Skill: artifact-validator
   └─ Skill: artifact-executor

Command: /quick-check
└─ Skill: artifact-validator (reused)
└─ Skill: artifact-executor (reused)
```

**Why this architecture:**
- Commands: Multiple entry points for different use cases
- Skills: Highly reusable across commands (validator used by both)
- Composition: Skills invoke other skills
- Parallel: Exploration skills run simultaneously

**Use this pattern for:** Queries, scripts, configs, code generation

## Decision Guidelines

### Use Commands for:
- ✅ User entry points (`/command-name`)
- ✅ Workflow orchestration
- ✅ Phase management
- ✅ User interaction (questions, progress updates)

### Use Skills for:
- ✅ Reusable logic
- ✅ Composable components
- ✅ Tool restrictions needed
- ✅ Library of capabilities

### Use Agents for:
- ✅ Parallel execution
- ✅ Independent workers
- ✅ Time-critical operations
- ✅ Separate data sources

### Use Knowledge Files for:
- ✅ Reference data
- ✅ Templates
- ✅ Guidelines
- ✅ Data that changes independently

## When in Doubt

**Start simple:**
1. Put logic in Command first
2. If logic becomes reusable → extract to Skill
3. If work can parallelize → extract to Agents
4. If data changes frequently → move to Knowledge file

**Red flags:**
- ❌ Commands with no user-facing value (should be Skill)
- ❌ Duplicated logic across commands (should be Skill)
- ❌ Serial execution when parallel possible (should be Agents)
- ❌ Hardcoded data in logic (should be Knowledge file)

## Common Mistakes

### Mistake 1: Everything as Skills
**Problem:** User has no entry points
**Fix:** Create Commands for user-facing workflows

### Mistake 2: Everything in Commands
**Problem:** No reusability, duplicated logic
**Fix:** Extract reusable logic to Skills

### Mistake 3: No Parallelization
**Problem:** Slow workflows with sequential operations
**Fix:** Use Agents for independent parallel work

### Mistake 4: Logic in Knowledge Files
**Problem:** Knowledge files with executable code
**Fix:** Move logic to Skills, keep data in Knowledge

## Testing Your Architecture

Good architecture should:
- ✅ Have clear user entry points (Commands)
- ✅ Minimize duplication (Skills for reuse)
- ✅ Minimize blocking time (Agents for parallel)
- ✅ Separate data from logic (Knowledge files)
- ✅ Be easy to explain to users
- ✅ Scale as workflow grows

Bad architecture has:
- ❌ No obvious entry point for users
- ❌ Same logic in multiple places
- ❌ Serial execution of independent work
- ❌ Hardcoded data throughout code
- ❌ Confusing file organization
- ❌ Becomes harder to maintain over time
