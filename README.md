# Agent builder for Claude Code

Build your own workflow assistant – something that does one repetitive part of your
job the same careful way every time. You describe the task in plain language;
Claude interviews you, designs it with you, and builds it.

You do not need to know how to code.

## Quick start

No git, no plugin marketplace, no install step – just download this repo into an
empty folder and run one command.

**Before you start**, you need Claude Code installed. If you don't have it yet, see
[claude.com/code](https://claude.com/code). Everything below happens inside Claude
Code – you'll be typing to Claude, not typing shell commands yourself.

1. **Make an empty folder for your project** and open it in Claude Code.

   If you're not sure how, you can just ask Claude: *"Make a new folder called
   weekly-report in my Documents and open it."* Naming it after the task you want
   to automate is a good habit.

2. **Ask Claude to fetch this toolkit.** Copy this in:

   > Please download the zip archive of github.com/anutron/agent-builder-plugin
   > (use curl, no need for git) and unzip it directly into this folder – not into
   > a subfolder. GitHub's zip unpacks into a folder called
   > `agent-builder-plugin-main`, so move the contents up into this folder and
   > remove the empty wrapper.

   You'll likely see a one-time prompt asking you to approve network access, and
   another to approve running the download. Both are expected – approve them.

3. **Start building:**

   ```
   /create-agent
   ```

   The first time you use a skill, Claude may ask permission for that too. Approve
   it and you're off.

   **If `/create-agent` doesn't appear** when you type `/`, it usually means the
   files landed in a subfolder instead of this one. You can also just ask in plain
   English: *"Use the create-agent skill."* If that doesn't work either, ask Claude
   to check that `.claude/skills/create-agent/SKILL.md` exists where you are.

That's it. `/create-agent` walks you through a short interview and builds your
first workflow. Expect roughly 30–60 minutes for a first one, most of it you
talking about how you already do the task.

**On Windows?** Everything works, but if you don't have git installed you'll be
offered it during setup – it's a small download and it also gives Claude Code a
better shell on Windows. Taking the offer is worth it.

## What this does

Agent-builder helps you create Claude Code workflows that:

- ✅ Gather information from several places at once
- ✅ Follow the same repeatable process every time
- ✅ Get better through use, rather than staying frozen at version one
- ✅ Include security and good practice by default

## Two icons you'll see

**🧭 Guide's note** – commentary built into this teaching tool, not Claude thinking
out loud. It calls out real Claude Code features (Plan Mode, Auto mode, Skills,
Subagents) as they come up, so you start recognizing them in your own projects.

**⌨️ Your turn** – a moment where Claude hands *you* the prompt to type instead of
doing it silently. There are only a few, at the points where the technique is worth
keeping: asking for a plan before anything gets built, getting a fresh-eyes review
from a subagent, and making your first change yourself.

They're always optional – say "just do it" and Claude will. But prompting is the
actual skill here, and you don't learn it by watching. The goal is that you leave
able to do this without the walkthrough.

## How it works

### `/create-agent` – one command does it all

Running `/create-agent` guides you through:

0. **Setup** – checks the toolkit is present and offers to set up saving (git) so
   your work is snapshotted as you go. You can decline; nothing else depends on it.
1. **Use case discovery** – two paths: know what you want, or get help finding it.
2. **Process interview** – understanding how you do the task today, one question at
   a time. Then Claude offers its own ideas before you commit to an approach.
3. **Data sources** – what information the workflow needs, and whether it can reach
   it automatically or you'll paste it in for now. Pasting is fine.
4. **Architecture design** – designed *with* you in Plan Mode, so you review and
   change the plan before a single file is written.
5. **Implementation** – a working version one.
6. **Iteration planning** – what version two should be.
7. **Final save** – everything committed, with a history you can walk back through.

### Tools already in this project

Everything downloads flat into your project folder, so these work immediately:

#### `/review-workflow` – parallel workflow analysis
- Launches 5 agents simultaneously (~30–40s, vs 2–3 min one at a time)
- Duplication, simplification, conflicts, security, best practices, goal drift
- Shows findings; you choose what to track

#### `/improve-workflow` – retrospective after actual use
- Run this after you've *used* your workflow, not just built it
- Captures what worked and what got in the way
- Updates the workflow's own files based on what was learned
- The habit this whole toolkit is built around: use it → `/improve-workflow` → use it again

#### `/save-workflow` – smart git commits
- Reads improvements from `IMPROVEMENTS.md`
- Generates detailed commit messages
- Cleans up completed items

#### Skills (self-contained)
- `create-agent` – the guided build, the `/create-agent` entry point
- `workflow-reviewer` – orchestrates the 5 parallel review agents
- `workflow-improver` – the retrospective loop behind `/improve-workflow`
- `save-progress` – git commits with real context
- `security-checker` – scans for secrets and credentials
- `software-best-practices` – validates tests and linting, prevents goal drift

## Key features

### Goal-drift prevention

Stops Claude wandering away from what you actually asked for:

- Stop and re-evaluate every 20 minutes, or after 3 obstacles
- `GOAL.template` for complex tasks, kept visible while working
- Recovery questions when stuck, and pivot strategies when an approach isn't working

### Saving as you go

Work is snapshotted after each phase rather than once at the end, so there's always
a known-good point to return to. Setting this up is offered at the very start and
is entirely optional.

## Repository structure

```
agent-builder-plugin/              # This repo – download it, it IS your .claude/ layout
├── .claude/
│   ├── settings.json              # Project permissions, so you aren't prompted constantly
│   ├── commands/
│   │   ├── review-workflow.md
│   │   ├── save-workflow.md
│   │   └── improve-workflow.md
│   ├── skills/
│   │   ├── create-agent/          # /create-agent entry point
│   │   ├── workflow-reviewer/
│   │   ├── workflow-improver/
│   │   ├── save-progress/
│   │   ├── security-checker/
│   │   └── software-best-practices/
│   ├── agents/                    # 5 parallel review agents
│   │   ├── review-duplication-simplification.md
│   │   ├── review-conflicts-setup.md
│   │   ├── review-security.md
│   │   ├── review-best-practices.md
│   │   └── review-goal-drift.md
│   ├── scripts/                   # All shell lives here, not scattered in prose
│   │   ├── toolkit.sh             # macOS / Linux
│   │   └── toolkit.ps1            # Windows
│   └── knowledge/
│       ├── workflow-patterns.md
│       ├── connectors.md
│       ├── component-decision-guide.md
│       ├── setup-command-guide.md
│       ├── security-guidelines.md
│       └── templates/             # File templates used by /create-agent
├── .gitignore
├── CHANGELOG.md
├── LICENSE
└── README.md
```

### Generated workflow structure

After `/create-agent` builds your V1, your project also has:

```
your-project/                      # Same folder – agent-builder files above, plus:
├── project-plan/
│   ├── interview-notes.md
│   ├── project-design.md
│   ├── data-source-setup.md
│   └── IMPROVEMENTS.md
├── .claude/
│   ├── commands/
│   │   ├── setup.md               # Generated by /create-agent
│   │   └── [your-workflow].md     # Your workflow's entry point
│   ├── skills/ or agents/
│   │   └── [your-components]      # Your workflow's own components
│   └── knowledge/
│       └── [your-references].md
├── CLAUDE.md
├── README.md                      # Replaces this one – it describes YOUR workflow
└── .env.example                   # Only if your workflow needs credentials
```

## Example use cases

These are the shape of thing this is good at – a task you do on a schedule, that
pulls from a couple of places, and where being thorough matters more than being
clever.

### Weekly close-out report
- **Input**: last week's sales export, the staff schedule
- **Gathers**: sales by daypart, labour hours, notable comps and voids
- **Output**: a one-page summary in the format your GM actually reads
- **Replaces**: 90 minutes of spreadsheet wrangling every Monday

### Vendor price-change tracker
- **Input**: this week's invoices
- **Gathers**: line-item prices, compares against the last few weeks
- **Output**: what moved, by how much, and what it does to plate cost
- **Replaces**: noticing the cheese got expensive two months late

### New-hire onboarding packet
- **Input**: role, start date, location
- **Gathers**: the right handbook sections, checklists, training schedule
- **Output**: a personalized first-week packet, consistent every time
- **Replaces**: rebuilding it from the last person's copy and forgetting a step

### Shift-handoff summary
- **Input**: the day's notes, open tickets, 86'd items
- **Gathers**: what's unresolved, what the next shift needs to know first
- **Output**: a short handoff the closing manager can skim in two minutes
- **Replaces**: a verbal handoff that half-survives

## Key patterns

10 patterns common to workflows that actually get used:

1. Phase-based workflows
2. Parallel execution
3. Specialized components
4. Knowledge files
5. State management
6. Two-mode operation (guided and one-shot)
7. Validation first
8. Connecting to real data sources
9. Research before action
10. Permission configuration

See `.claude/knowledge/workflow-patterns.md` for details.

## Going further

Once building and iterating on a workflow feels comfortable, there's more of Claude
Code worth exploring:

- **Global skills & `CLAUDE.md`** – conventions that apply across every project
- **`/fewer-permission-prompts`** – trim repeated permission prompts as you get more comfortable
- **Connectors** – link Claude directly to Notion, Google Drive, Slack and the rest, so a workflow reads your real data instead of you pasting it. In Claude Desktop that's **Settings → Connectors**: pick a tool, sign in, done – nothing to install, and no API key stored anywhere. `/mcp` does the same job in Claude Code
- **`/workflows`** – orchestrate bigger multi-step jobs once one workflow outgrows a single command
- **Aaron's public skill library** – `github.com/anutron/ai`, which includes `/promote` for graduating a skill you like from one project to everywhere

## Contributing

Contributions welcome. See:

1. Design patterns in `.claude/knowledge/workflow-patterns.md`
2. Component decisions in `.claude/knowledge/component-decision-guide.md`

## License

MIT License
