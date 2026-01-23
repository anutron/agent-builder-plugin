# Agent Builder Plugin for Claude Code

Build MCP-powered workflow agents through guided planning, iterative development, and continuous improvement loops.

## What This Does

This plugin helps you create Claude Code workflow agents that:
- ✅ Gather data from multiple sources in parallel
- ✅ Follow repeatable processes
- ✅ Self-improve through testing and iteration
- ✅ Include security and best practices by default

## Installation

### Via Claude Code Marketplace

This plugin is available via Claude Code marketplace under the namespace: `anutron-agent-builder`

1. Open Claude Code settings
2. Navigate to Plugins → Marketplace
3. Search for "agent-builder"
4. Click Install

### Manual Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/anutron/agent-builder-plugin.git
   ```
2. Follow the manual plugin installation instructions in the [Claude Code documentation](https://github.com/anthropics/claude-code)

## Quick Start

```bash
# In your project directory
/agent-builder:create-agent
```

This will:
1. **Install agent-builder tools** into your project
   - `/review-workflow` command (5 parallel analysis agents)
   - `/save-workflow` command (smart git commits)
   - Skills for reviewing, security checking, best practices
2. **Guide you through workflow creation**
   - Use case discovery
   - Process interview
   - Data source setup
   - Architecture design
   - V1 implementation

## How It Works

### Single Command: `/agent-builder:create-agent`

When you run `/agent-builder:create-agent`, it:

**Phase 0: Install Tools**
- Copies review/save commands into your project
- Adds workflow-reviewer, save-progress, security-checker, software-best-practices skills
- Includes 5 review agents for parallel analysis
- Creates `.claude/config.json` with permissions for smooth workflow
- All tools become part of YOUR project (customize as needed)

**Phase 1: Use Case Discovery** - Two paths:
- Option 1: Know what you want? Skip discovery, describe your workflow
- Option 2: Need help? Guided discovery to identify automation opportunities

**Phase 2-6: Build and Iterate**
2. **Process Interview** - Understand current workflow deeply
3. **Data Source Setup** - Connect to your data before building
4. **Architecture Design** - Design with best practices
5. **Implementation** - Generate working V1
6. **Iteration Planning** - Define V2+ roadmap

## Features

### `/agent-builder:create-agent` - One Command Does It All
Installs tools + guided workflow creation in one step.

### Tools Installed in Your Project

After running `/agent-builder:create-agent`, your project will have:

#### `/review-workflow` - Parallel Workflow Analysis
- Launches 5 agents simultaneously
- Duplication & simplification analysis
- Conflicts & setup drift detection
- Security scanning
- Best practices checking
- Goal drift detection
- Shows findings, you choose what to track

#### `/save-workflow` - Smart Git Commits
- Reads improvements from IMPROVEMENTS.md
- Generates detailed commit messages
- Cleans completed items
- Simplified format (no type prefixes)

#### Skills (Self-Contained)
- `workflow-reviewer` - Orchestrates 5 parallel review agents
- `save-progress` - Intelligent git commits with context
- `security-checker` - Scans for secrets and credentials
- `software-best-practices` - Validates tests, linting, prevents goal drift

## Key Features

### Goal-Drift Prevention
Added to prevent Claude from losing track of objectives:
- STOP and re-evaluate every 20min or after 3 obstacles
- GOAL.md template for complex tasks
- Recovery questions when stuck
- Pivot strategies when approach isn't working

### Parallel Review Analysis
- 5 agents run simultaneously (~30-40s vs 2-3min serial)
- User chooses which findings to track
- No auto-writing to IMPROVEMENTS.md

### Self-Contained Workflows
- Tools copied into your project
- Customize per-project without affecting plugin
- No pollution of other projects

## Architecture

### Plugin Structure
```
agent-builder-skill/           # The plugin
├── .claude/commands/
│   └── create-agent.md        # Single entry point (inlined logic)
├── .claude/knowledge/         # Guides (stay in plugin)
│   ├── workflow-patterns.md
│   ├── mcp-integration.md
│   ├── component-decision-guide.md
│   └── setup-command-guide.md
└── .claude/files-to-install/  # Tools copied to user projects
    ├── commands/
    │   ├── review-workflow.md
    │   └── save-workflow.md
    ├── skills/
    │   ├── workflow-reviewer/
    │   ├── save-progress/
    │   ├── security-checker/
    │   └── software-best-practices/
    ├── agents/
    │   ├── review-duplication-simplification.md
    │   ├── review-conflicts-setup.md
    │   ├── review-security.md
    │   ├── review-best-practices.md
    │   └── review-goal-drift.md
    └── templates/
        ├── CLAUDE.template
        ├── GOAL.template
        ├── setup.template
        └── gitignore.template
```

### Generated Project Structure
```
your-workflow/                  # Your new project
├── project-plan/
│   ├── interview-notes.md
│   ├── project-design.md
│   ├── data-source-setup.md
│   └── IMPROVEMENTS.md
├── .claude/
│   ├── commands/
│   │   ├── review-workflow.md # Installed from plugin
│   │   ├── save-workflow.md   # Installed from plugin
│   │   ├── setup.md           # Generated by create-agent
│   │   └── [your-workflow].md # Your workflow command
│   ├── skills/ or agents/
│   │   ├── workflow-reviewer/ # Installed from plugin
│   │   ├── save-progress/     # Installed from plugin
│   │   ├── security-checker/  # Installed from plugin
│   │   ├── software-best-practices/ # Installed from plugin
│   │   └── [your-components]  # Your workflow components
│   └── knowledge/
│       └── [your-references].md
├── CLAUDE.md
├── README.md
├── .gitignore
└── .env.example
```

## Based on Real Projects

Analysis of successful Claude Code workflow agents:

### PRD Sidekick
- AI-powered collaborative PRD authoring
- Parallel research across Notion and Slack
- ~1 minute total blocking time
- Phase-based workflow with session resumption

### Data-Knowledge
- AI-assisted Snowflake query development
- 9 specialized slash commands, 8 reusable skills
- Research-first query generation
- SQL validation against documentation

## Key Patterns Extracted

10 common patterns across successful projects:
1. Phase-Based Workflows
2. Parallel Execution
3. Specialized Components
4. Knowledge Files
5. State Management
6. Two-Mode Operation
7. Validation First
8. MCP Integration
9. Research Before Action
10. Permission Configuration

See `.claude/knowledge/workflow-patterns.md` in the plugin for details.

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
- **MCPs**: GitHub, custom schema MCP

## Installation

### From GitHub

```bash
# Add the agent-builder marketplace
/plugin marketplace add anutron/agent-builder-plugin

# Install the agent-builder plugin
/plugin install agent-builder@anutron-agent-builder
```

### Local Development

```bash
# Add the plugin directory as a marketplace
/plugin marketplace add /path/to/agent-builder-skill

# Install the plugin
/plugin install agent-builder@agent-builder-skill
```

### Usage

Once installed, navigate to your project directory and run:

```bash
cd your-project-directory
/agent-builder:create-agent
```

The command will:
1. Install agent-builder tools (first run only)
2. Prompt you to restart Claude Code
3. Guide you through workflow creation (second run)

Choose between:
- **Fast path**: Know what you want? Skip discovery and jump to implementation
- **Guided path**: Need help? Get assistance identifying automation opportunities

## Documentation

See `docs/` directory for:
- Research & analysis from successful projects
- Design specifications
- Architecture decisions

## Contributing

Contributions welcome! See:
1. Design patterns in `.claude/knowledge/workflow-patterns.md`
2. Component decisions in `.claude/knowledge/component-decision-guide.md`

## License

MIT License

## Acknowledgments

Built from analysis of successful Claude Code workflow agents, extracting patterns and best practices into a reusable plugin.
