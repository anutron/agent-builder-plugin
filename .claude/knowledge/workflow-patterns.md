# Workflow Agent Patterns - Synthesis

## Common Patterns Across Both Projects

### 1. **Phase-Based Workflows**
Both projects break complex tasks into distinct phases:

**PRD Sidekick**:
- Phase 0: Context gathering
- Phase 1: Parallel research (30s)
- Phase 2: Interactive interview OR one-shot
- Phase 3: Serial content generation
- Phase 4: Parallel writes
- Phase 5: Cleanup

**Data-Knowledge**:
- Research phase (parallel exploration)
- Requirements gathering
- Query generation
- Validation phase
- Save & copy
- Optional execution

**Key insight**: Clear phases help users understand progress and enable resumption

### 2. **Parallel Execution for Speed**
Both use Task/Skill tool to launch multiple agents simultaneously:
- Single message with multiple tool calls
- Agents run in parallel, not serial
- Results synthesized after all complete

**Critical pattern**: User blocking time minimized by parallelization

### 3. **Specialized Sub-Agents/Skills**
Rather than monolithic commands, both use specialized components:

**PRD Sidekick Agents**:
- Research agents (Notion, Slack)
- Section writers
- Requirements writer

**Data-Knowledge Skills**:
- Explorer skills (Looker, DBT, App)
- Validator skills
- Executor skills
- Orchestrator skills

**Key insight**: Single responsibility principle for each agent/skill

### 4. **Knowledge Files as Instructions**
Both store reference materials separately from workflow logic:

**PRD Sidekick**:
- `.claude/knowledge/` - Interview guides, content guidelines, templates
- Agents reference knowledge files for technical details

**Data-Knowledge**:
- `knowledge/` - Table schemas, business logic, relationships
- Skills validate against knowledge base

**Pattern**: Knowledge files are executable documentation

### 5. **State Management & Resumption**
Both support interrupted workflow resumption:

**PRD Sidekick**:
- `execution-plan.json` tracks progress
- Session directories preserve all work
- Can resume from any phase

**Data-Knowledge**:
- Query files persist work
- Knowledge base accumulates discoveries
- Setup state tracking

**Pattern**: Workflows survive session boundaries

### 6. **Two-Mode Operation**
Both support interactive and autonomous modes:

**PRD Sidekick**:
- Interactive: Step-by-step interview
- One-shot: Autonomous from initial context

**Data-Knowledge**:
- Business queries: Full workflow with headers
- Diagnostic queries: Quick, clipboard-only

**Pattern**: Adapt workflow to user's time constraints

### 7. **Validation as First-Class Concern**
Both validate work before finalizing:

**PRD Sidekick**:
- Anti-duplication rules for content
- Contradiction detection in research
- Write verification

**Data-Knowledge**:
- query-validator skill before save
- Knowledge base consistency checks
- Field name verification

**Pattern**: Catch errors early, not in production

### 8. **MCP as Integration Layer**
Both heavily use MCP servers for external systems:

**PRD Sidekick**:
- Notion MCP for document operations
- Slack MCP for customer feedback

**Data-Knowledge**:
- GitHub MCP for cross-repo access
- Looker MCP for LookML operations
- Snowflake (via query-executor)

**Pattern**: MCPs abstract external system complexity

### 9. **Research Before Action**
Both mandate research phase before generation:

**PRD Sidekick**:
- Research related Notion docs
- Gather customer quotes
- Identify contradictions

**Data-Knowledge**:
- Search knowledge base for schemas
- Explore multiple codebases
- Verify table/field names

**Pattern**: Context gathering prevents errors

### 10. **Permissions as Configuration**
Both use `.claude/settings.local.json` for fine-grained permissions:
- MCP tool permissions
- Bash command patterns
- File path restrictions
- Skill invocation rights

**Pattern**: Security through explicit allow-lists

## Architectural Differences

### Commands vs. Agents

**PRD Sidekick**:
- Single main command (`/prd`)
- Workflow embedded in command file
- Agents in separate `.claude/agents/` files

**Data-Knowledge**:
- Multiple commands for different entry points
- Commands invoke skills
- Skills compose other skills
- Clear separation: Commands (UX) vs Skills (logic)

**Insight**: Data-knowledge architecture is more modular

### File Organization

**PRD Sidekick**:
```
.claude/
├── commands/
├── agents/      # Invoked by Task tool
└── knowledge/

prd-sessions/    # Stateful work
└── [page-id]/
```

**Data-Knowledge**:
```
.claude/
├── commands/    # User-facing
├── skills/      # Invoked by Skill tool
└── settings.local.json

knowledge/       # Source of truth
queries/         # Persistent output
```

### Skill vs Agent Invocation

**PRD Sidekick**:
- Uses `Task` tool with `subagent_type` parameter
- Agents are markdown files with prompts
- No metadata format

**Data-Knowledge**:
- Uses `Skill` tool with skill name
- Skills have YAML frontmatter metadata
- Defined `allowed-tools` constraints

## Best Practices Extracted

1. **Minimize user blocking time** - Parallelize wherever possible
2. **Make workflows resumable** - Persist state in JSON/markdown
3. **Validate before finalizing** - Catch errors early
4. **Research first, never assume** - Query docs before generating
5. **Single responsibility agents** - Each does one thing well
6. **Knowledge files over prompts** - Separate data from logic
7. **Support both interactive and autonomous** - Different time budgets
8. **Explicit permissions** - Security through allow-lists
9. **Copy to clipboard** - Seamless workflow integration (pbcopy)
10. **Progress visibility** - Show users what's happening when

## Anti-Patterns to Avoid

1. **Monolithic workflows** - Hard to debug and resume
2. **Serial when parallel possible** - Wastes user time
3. **Assumptions over research** - Leads to errors
4. **Weakening tests** - Hides bugs
5. **Mixing data sources** - Analytics + Application tables
6. **Embedding knowledge in code** - Hard to update
7. **Claiming success when failed** - Erodes trust
8. **Batch status updates** - Mark complete immediately
9. **Using bash for file operations** - Use specialized tools
10. **Guessing at integrations** - Use MCPs properly
