# Agent Builder Plugin for Claude Code

Build MCP-powered workflow agents through guided planning, iterative development, and continuous improvement loops.

## What This Does

This plugin helps you create Claude Code workflow agents that:
- ✅ Gather data from multiple sources in parallel
- ✅ Follow repeatable processes
- ✅ Self-improve through testing and iteration
- ✅ Include security and best practices by default

## Features

### `/quick-start` - Build a Workflow from Scratch
Guided 5-phase process:
1. **Use Case Discovery** - Identify automation opportunities
2. **Process Interview** - Understand current workflow
3. **Data Source Setup** - Connect to your data before building
4. **Improvement Plan** - Design with best practices
5. **Implementation** - Generate working V1
6. **Iteration Planning** - Define V2+ roadmap

### `/save` - Commit with Context
- Reads improvements from IMPROVEMENTS.md
- Generates detailed git commit messages
- Cleans completed items
- Updates documentation automatically

### `/review` - Comprehensive Analysis
- Finds duplication opportunities
- Identifies security issues
- Validates best practices
- Suggests performance improvements
- Writes actionable recommendations

### Self-Improving Workflows
Two improvement loops:
1. **User-initiated**: "Make X better" → Plan → Implement → Save
2. **LLM-initiated**: Struggle → Fix → Offer to improve workflow

## Based on Real Projects

Analysis of two successful Claude Code workflow agents:

### 1. PRD Sidekick (`../prd_sidekick`)
**Purpose**: AI-powered collaborative PRD authoring

**Key Features**:
- Parallel research across Notion and Slack
- Interactive OR one-shot modes
- Specialized sub-agents for research and writing
- ~1 minute total blocking time
- Session resumption capability

**Architecture Patterns**:
- Phase-based workflow (5 phases)
- Parallel agent execution via Task tool
- Knowledge files for templates and guidelines
- State management in execution-plan.json
- Anti-duplication rules for content generation

### 2. Data-Knowledge (`../data-knowledge`)
**Purpose**: AI-assisted Snowflake query development with knowledge base

**Key Features**:
- 9 specialized slash commands
- 8 reusable skills
- Research-first query generation
- SQL validation against documentation
- Multi-repository code exploration
- Optional web dashboard

**Architecture Patterns**:
- Command/Skill separation (UX vs Logic)
- Mandatory knowledge base research before generation
- Parallel skill composition
- Validation as first-class concern
- Skills invoking other skills

## Key Learnings Extracted

I documented 10 common patterns across both projects:

1. **Phase-Based Workflows** - Clear stages with progress tracking
2. **Parallel Execution** - Minimize user blocking time
3. **Specialized Components** - Single responsibility agents/skills
4. **Knowledge Files** - Executable documentation
5. **State Management** - Resumable workflows
6. **Two-Mode Operation** - Interactive and autonomous
7. **Validation First** - Catch errors early
8. **MCP Integration** - Abstract external systems
9. **Research Before Action** - Context gathering prevents errors
10. **Permission Configuration** - Security through explicit allow-lists

See `SYNTHESIS-workflow-patterns.md` for complete analysis.

## What I Designed

### Agent Builder Skill

A guided workflow that helps users build MCP-powered agents through:

**Phase 1: Use Case Discovery**
- Identify repetitive tasks
- Evaluate automation potential
- Select starting point

**Phase 2: Process Interview**
- Map current workflow
- Identify pain points and data sources
- Define quality criteria

**Phase 3: Improvement Plan**
- Identify available MCPs
- Design research phase (parallel)
- Choose Claude Code features (commands/skills/agents)
- Plan validation gates
- Define V1 scope

**Phase 4: Implementation**
- Set up file structure
- Configure permissions
- Implement main command
- Implement research agents/skills
- Test workflow
- Document usage

**Phase 5: Iteration Planning**
- Review limitations
- Define V2+ roadmap


See `SKILL-DESIGN.md` for complete specification.

## Plugin vs Skill Question

**Answer: Yes, a plugin CAN be a skill!**

**Recommended Approach**: Distribute as plugin containing skills

```
@claude-code/agent-builder/
├── package.json              # Plugin metadata
├── .claude/
│   ├── commands/
│   │   └── build-agent.md    # User-facing entry point
│   ├── skills/
│   │   ├── agent-builder/    # Core orchestrator
│   │   ├── use-case-advisor/ # Helps identify use cases
│   │   └── architecture-designer/ # Designs workflow
│   └── knowledge/
│       ├── workflow-patterns.md
│       ├── mcp-integration.md
│       └── file-templates.md
└── examples/
```

**Usage Modes**:
1. User runs `/quick-start` command
2. Claude autonomously suggests agent-builder skill
3. Other tools invoke skill programmatically

See `PLUGIN-VS-SKILL.md` for detailed analysis.

## What Belongs in This Skill

### Core Functionality

1. **Use Case Identification**
   - Interview questions
   - Good/bad characteristic checks
   - Frequency and time cost analysis

2. **Process Understanding**
   - Current workflow mapping
   - Data source identification
   - Pain point discovery
   - Quality criteria definition

3. **Architecture Design**
   - MCP availability checking
   - Parallel research design
   - Command vs Skill decision logic
   - Validation gate planning
   - Iteration strategy

4. **Code Generation**
   - File structure creation
   - Permission configuration
   - Command/skill templates
   - Knowledge file templates
   - Documentation generation

5. **Testing & Validation**
   - Workflow execution testing
   - Error handling verification
   - Resume capability check

### Knowledge Files to Include

From your projects, these patterns should be packaged:

- **workflow-patterns.md** - 10 common patterns
- **prd-sidekick-patterns.md** - Phase-based workflow example
- **data-knowledge-patterns.md** - Command/skill architecture example
- **mcp-integration.md** - How to use MCPs effectively
- **best-practices.md** - Do's and don'ts
- **file-templates.md** - Templates for generated files

### Example Workflows to Include

Show users complete examples:

1. **PRD Assistant** - Document authoring pattern
2. **Bug Triager** - Research and classification pattern
3. **Query Builder** - Validation-first pattern
4. **Doc Updater** - Code-to-docs synchronization pattern

## Installation

### From Claude Code Marketplace

1. **Add the marketplace** (first time only):
```bash
/plugin marketplace add your-org/claude-plugins
```

2. **Install the plugin**:
```bash
/plugin install agent-builder@your-org
```

Or use the interactive installer:
```bash
/plugin
```
Then select "Browse Plugins" and choose "agent-builder".

## Quick Start

```bash
# In Claude Code
/quick-start
```

Claude will guide you through:
1. Identifying a good use case
2. Understanding your current process
3. Connecting to data sources
4. Designing the workflow
5. Building V1
6. Planning V2+

## Commands

### `/quick-start`
Start building a new workflow agent. Interactive guided process.

### `/save`
Commit your changes with detailed context from IMPROVEMENTS.md.

**Use after**: Making improvements to your workflow

### `/review`
Comprehensive workflow analysis with actionable recommendations.

**Use when**: Want to improve existing workflow

### `/setup`
Validate environment configuration (auto-generated by quick-start).

**Use when**: Troubleshooting setup issues

## Skills Included

### `quick-start`
Orchestrates the full workflow creation process. Conducts interviews, designs architecture, generates files, creates git commits.

### `save-progress`
Intelligent git commit with context preservation. Reads IMPROVEMENTS.md, generates detailed messages, cleans backlog.

### `workflow-reviewer`
Analyzes workflows for improvements, security issues, conflicts, best practices. Writes findings to IMPROVEMENTS.md.

### `security-checker`
Scans for hardcoded secrets, validates .gitignore, checks environment variables. Runs automatically when sensitive files created.

### `software-best-practices`
Ensures tests exist, validates linting, creates run scripts, executes code and iterates until success.

## Example Use Cases

### PRD Assistant
- **Input**: PRD topic, Notion page
- **Research**: Notion docs, Slack discussions (parallel)
- **Output**: Structured PRD in Notion
- **MCPs**: Notion, Slack

### Bug Triager
- **Input**: Bug report URLs
- **Research**: Jira history, Slack mentions, related issues
- **Output**: Triage recommendation
- **MCPs**: Jira, Slack, GitHub

### Query Builder
- **Input**: Business question
- **Research**: Schema docs, existing queries, business logic
- **Output**: Validated SQL query
- **MCPs**: GitHub (for code), custom schema MCP

## Architecture Patterns Included

From analysis of successful projects:

1. **Phase-Based Workflows** - Clear stages with progress tracking
2. **Parallel Execution** - Minimize user wait time
3. **Specialized Components** - Single responsibility agents/skills
4. **Knowledge Files** - Executable documentation
5. **State Management** - Resumable workflows
6. **Two-Mode Operation** - Interactive and autonomous
7. **Validation First** - Catch errors early
8. **MCP Integration** - Abstract external systems
9. **Research Before Action** - Context gathering prevents errors
10. **Permission Configuration** - Security through explicit allow-lists

See `.claude/knowledge/workflow-patterns.md` for details.

## What Gets Generated

When you run `/quick-start`, it creates:

```
your-workflow-project/
├── project-plan/
│   ├── interview-notes.md
│   ├── project-design.md
│   ├── data-source-setup.md
│   └── IMPROVEMENTS.md
├── .claude/
│   ├── commands/
│   │   └── [your-workflow].md
│   ├── [agents|skills]/
│   │   └── [components].md
│   └── knowledge/
│       └── [references].md
├── CLAUDE.md
├── README.md
├── .gitignore
├── .env.example
└── (initial git commit)
```

## Knowledge Base Included

### workflow-patterns.md
Common patterns from successful projects. Best practices for phase-based workflows, parallel execution, state management.

### mcp-integration.md
How to use MCPs effectively. Integration patterns, error handling, security, troubleshooting.

### security-guidelines.md
Never commit secrets to git. Environment variables, .gitignore patterns, detecting secrets, cleanup procedures.

### File Templates
- `.gitignore.template` - Security patterns
- `CLAUDE.template` - Project instructions
- `README.template` - Usage documentation
- `command.template` - Workflow command structure

## Development Status

### ✅ Completed (Phase 1-2)
- [x] Core plugin structure
- [x] `/quick-start` command and skill
- [x] `/save` command and skill
- [x] `/review` command and skill
- [x] `security-checker` skill
- [x] `software-best-practices` skill
- [x] `/setup` command
- [x] Knowledge base files
- [x] File templates

### 🚧 In Progress (Phase 3)
- [ ] Testing with real use cases
- [ ] Example workflow projects
- [ ] Documentation refinement

### 📋 Planned (Phase 4)
- [ ] npm package distribution
- [ ] GitHub repository
- [ ] Demo video
- [ ] Community examples

## Implementation Next Steps

1. **Test the plugin** with a real workflow
2. **Create example projects** (PRD assistant, bug triager, query builder)
3. **Refine based on feedback**
4. **Package for distribution**
5. **Publish to npm and GitHub**

## Documentation

All planning, research, and design documents are in the [`docs/`](docs/) directory:
- Research & analysis from successful projects
- Design specifications
- Implementation planning
- Architecture decisions

See [`docs/README.md`](docs/README.md) for a guide to the documentation.

## Contributing

Contributions welcome! Please see:
1. Design patterns in `docs/SYNTHESIS-workflow-patterns.md`
2. Architecture in `docs/PROJECT-PLAN.md`
3. Examples in `examples/` (coming soon)

## License

MIT License - see [LICENSE](LICENSE) file

## Acknowledgments

Built from analysis of successful Claude Code workflow agents, extracting patterns and best practices into a reusable plugin.
