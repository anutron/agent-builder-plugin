# Agent builder for Claude Code

Build MCP-powered workflow agents through guided planning, iterative development, and continuous improvement loops.

## Quick start

No git, no plugin marketplace, no install step – just download this repo into an empty folder and run one command.

1. Open Claude Code and create (or navigate to) an empty folder for your new project.

2. Ask Claude to fetch this repo, for example:

   > Please download the zip archive of github.com/anutron/agent-builder-plugin (use curl, no need for git) and unzip it directly into this folder – not into a subfolder.

   The first time Claude reaches out to github.com you may see a one-time prompt asking you to approve network access. That's expected – approve it and continue.

3. Run:

   ```
   /create-agent
   ```

That's it – `/create-agent` walks you through a short interview and builds your first workflow.

## What this does

Agent-builder helps you create Claude Code workflow agents that:
- ✅ Gather data from multiple sources in parallel
- ✅ Follow repeatable processes
- ✅ Self-improve through testing and iteration
- ✅ Include security and best practices by default

## A note on the 🧭 icon

Throughout `/create-agent` and the other tools, you'll see notes marked 🧭 **Guide's note**. These aren't Claude thinking out loud – they're commentary built into this teaching tool that calls out real Claude Code features (Plan Mode, Auto mode, Skills, Subagents, and so on) as they come up, so you start recognizing them for your own future projects.

## How it works

### `/create-agent` – one command does it all

Once the files are in your project folder, running `/create-agent` guides you through:

1. **Use case discovery** – two paths:
   - Know what you want? Skip discovery, describe your workflow.
   - Need help? Guided discovery to identify automation opportunities.
2. **Process interview** – understand your current workflow deeply.
3. **Data source setup** – connect to your data before building.
4. **Architecture design** – design with best practices (via Plan Mode, so you review before anything is built).
5. **Implementation** – generate a working V1.
6. **Iteration planning** – define a V2+ roadmap.

### Tools already in this project

Because everything downloads flat into your project folder, these are available immediately – no separate install step:

#### `/review-workflow` – parallel workflow analysis
- Launches 5 agents simultaneously
- Duplication and simplification analysis
- Conflicts and setup drift detection
- Security scanning
- Best practices checking
- Goal drift detection
- Shows findings, you choose what to track

#### `/save-workflow` – smart git commits
- Reads improvements from `IMPROVEMENTS.md`
- Generates detailed commit messages
- Cleans completed items

#### `/improve-workflow` – retrospective after actual use
- Run this after you've *used* your workflow, not just built it
- Captures what worked and what didn't
- Updates the workflow's own files based on what was learned
- The habit this whole loop is meant to build: use it → `/improve-workflow` → use it again

#### Skills (self-contained)
- `workflow-reviewer` – orchestrates the 5 parallel review agents
- `save-progress` – intelligent git commits with context
- `security-checker` – scans for secrets and credentials
- `software-best-practices` – validates tests, linting, prevents goal drift
- `workflow-improver` – the retrospective loop behind `/improve-workflow`

## Key features

### Goal-drift prevention
Added to prevent Claude from losing track of objectives:
- Stop and re-evaluate every 20 minutes or after 3 obstacles
- `GOAL.md` template for complex tasks
- Recovery questions when stuck
- Pivot strategies when an approach isn't working

### Parallel review analysis
- 5 agents run simultaneously (~30-40s vs 2-3min serial)
- You choose which findings to track
- No auto-writing to `IMPROVEMENTS.md`

## Repository structure

```
agent-builder-plugin/            # This repo – download it, it IS your .claude/ layout
├── .claude/
│   ├── commands/
│   │   ├── review-workflow.md
│   │   └── save-workflow.md
│   ├── skills/
│   │   ├── create-agent/         # /create-agent entry point
│   │   ├── workflow-reviewer/
│   │   ├── save-progress/
│   │   ├── security-checker/
│   │   └── software-best-practices/
│   ├── agents/                   # 5 parallel review agents
│   │   ├── review-duplication-simplification.md
│   │   ├── review-conflicts-setup.md
│   │   ├── review-security.md
│   │   ├── review-best-practices.md
│   │   └── review-goal-drift.md
│   └── knowledge/
│       ├── workflow-patterns.md
│       ├── mcp-integration.md
│       ├── component-decision-guide.md
│       ├── setup-command-guide.md
│       ├── security-guidelines.md
│       └── templates/            # File templates used by /create-agent
└── README.md
```

### Generated workflow structure

After `/create-agent` builds your V1, your project also has:

```
your-project/                     # Same folder – agent-builder files above, plus:
├── project-plan/
│   ├── interview-notes.md
│   ├── project-design.md
│   ├── data-source-setup.md
│   └── IMPROVEMENTS.md
├── .claude/
│   ├── commands/
│   │   ├── setup.md              # Generated by /create-agent
│   │   └── [your-workflow].md    # Your workflow's entry point
│   ├── skills/ or agents/
│   │   └── [your-components]     # Your workflow's own components
│   └── knowledge/
│       └── [your-references].md
├── CLAUDE.md
├── README.md
├── .gitignore
└── .env.example
```

## Based on real projects

Analysis of successful Claude Code workflow agents:

### PRD sidekick
- AI-powered collaborative PRD authoring
- Parallel research across Notion and Slack
- ~1 minute total blocking time
- Phase-based workflow with session resumption

### Data-knowledge
- AI-assisted Snowflake query development
- 9 specialized slash commands, 8 reusable skills
- Research-first query generation
- SQL validation against documentation

## Key patterns extracted

10 common patterns across successful projects:
1. Phase-based workflows
2. Parallel execution
3. Specialized components
4. Knowledge files
5. State management
6. Two-mode operation
7. Validation first
8. MCP integration
9. Research before action
10. Permission configuration

See `.claude/knowledge/workflow-patterns.md` for details.

## Example use cases

### PRD assistant
- **Input**: PRD topic, Notion page
- **Research**: Notion docs, Slack discussions (parallel)
- **Output**: Structured PRD in Notion
- **MCPs**: Notion, Slack

### Bug triager
- **Input**: Bug report URLs
- **Research**: Jira history, Slack mentions, related issues
- **Output**: Triage recommendation
- **MCPs**: Jira, Slack, GitHub

### Query builder
- **Input**: Business question
- **Research**: Schema docs, existing queries, business logic
- **Output**: Validated SQL query
- **MCPs**: GitHub, custom schema MCP

## Going further

Once building and iterating on a workflow feels comfortable, there's more of Claude Code worth exploring:

- **Global skills & `CLAUDE.md`** – conventions and skills that apply across every project, not just one
- **`/promote`** – graduate a skill you like from one project to everywhere
- **`/fewer-permission-prompts`** – cut down on repeated permission prompts as you get more comfortable
- **Connectors / MCP** – more data sources to connect your workflows to
- **Aaron's public skill library** – `github.com/anutron/ai`

## Contributing

Contributions welcome! See:
1. Design patterns in `.claude/knowledge/workflow-patterns.md`
2. Component decisions in `.claude/knowledge/component-decision-guide.md`

## License

MIT License

## Acknowledgments

Built from analysis of successful Claude Code workflow agents, extracting patterns and best practices into a reusable toolkit.
