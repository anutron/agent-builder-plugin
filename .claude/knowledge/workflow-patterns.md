# Workflow Agent Patterns

Patterns that show up again and again in workflows people actually keep using.

Two running examples are used throughout, both drawn from restaurant operations
because that's the kind of work this toolkit is aimed at. The patterns themselves
are domain-neutral – the same shapes apply to a law office or a warehouse.

- **Close-Out** – a weekly close-out report. Pulls last week's sales export and
  the staff schedule, produces a one-page summary for the GM. One command, several
  research agents, one document out.
- **Vendor Watch** – a vendor price tracker. Reads this week's invoices, compares
  line-item prices against recent weeks, flags what moved and what it does to plate
  cost. Several commands sharing a growing knowledge base of items and prices.

## Common patterns

### 1. Phase-based workflows

Break a complex task into distinct phases:

**Close-Out**:
- Phase 0: Gather context (which week, which location)
- Phase 1: Parallel research (read sales export, read schedule) – 30s
- Phase 2: Interview the manager about anything unusual that week
- Phase 3: Generate the summary sections in order
- Phase 4: Write the finished report
- Phase 5: Clean up working files

**Vendor Watch**:
- Research phase (read invoices, look up known items)
- Comparison phase (this week against history)
- Flagging phase (what moved beyond a threshold)
- Validation phase (are these real changes or a unit mix-up?)
- Save and update the price history

**Key insight**: Clear phases let the user see progress, and let the workflow
resume if it's interrupted.

### 2. Parallel execution for speed

Launch multiple agents simultaneously rather than one at a time:
- Single message with multiple tool calls
- Agents run at the same time
- Results combined after all finish

**Close-Out** reads the sales export and the schedule at once instead of in
sequence. Two 20-second reads become one 20-second wait.

**Critical pattern**: Minimize the time the user sits waiting.

### 3. Specialized components

Rather than one giant command, use focused pieces:

**Close-Out agents**:
- Sales-export reader
- Schedule reader
- Summary writer

**Vendor Watch skills**:
- Invoice parser
- Price comparer
- Plate-cost calculator
- Orchestrator that runs the others

**Key insight**: One job per component. Easier to fix when one part misbehaves.

### 4. Knowledge files as instructions

Keep reference material separate from workflow logic:

**Close-Out**: `.claude/knowledge/` holds the report format the GM expects, what
counts as a notable comp, and which dayparts to break out.

**Vendor Watch**: a knowledge file holds known items, expected units (case vs
each vs pound), and normal price ranges. The comparison logic checks against it.

**Pattern**: Knowledge files are documentation the workflow actually reads. When
the report format changes, you edit a knowledge file, not the logic.

### 5. State management and resumption

Support picking up an interrupted run:

**Close-Out**: a session directory per week preserves the drafts, so a report
interrupted on Monday can be finished Tuesday without redoing the research.

**Vendor Watch**: the price history file accumulates across runs and *is* the
long-term value of the workflow.

**Pattern**: Workflows should survive being interrupted.

### 6. Two-mode operation

Support both a guided and a fast path:

**Close-Out**:
- Guided: asks about the week, unusual events, anything to call out
- One-shot: given the exports, produces the report with no questions

**Vendor Watch**:
- Full: complete comparison with plate-cost impact
- Quick: just tell me what moved this week

**Pattern**: Adapt to how much time the user has right now.

### 7. Validation as a first-class concern

Check the work before finalizing:

**Close-Out**: do the labour hours reconcile against the schedule? Does the sales
total match the export's own total line?

**Vendor Watch**: is this a real price change or did the vendor switch from
case-price to unit-price? A 6x jump usually means units changed, not prices.

**Pattern**: Catch errors before the user acts on the output. A confidently wrong
report is worse than no report.

### 8. Local-first drafting with parallel writes

Generate content locally, then write to external systems in parallel:

**Close-Out pattern**:
- Phase 3: Generate each section as a local `draft-*.md` file, in order
  - Each section can read earlier ones to avoid repeating itself
  - All drafts validated before anything is published
  - Local files are inspectable, recoverable, resumable
- Phase 4: Write all sections to their destination simultaneously
  - Each write agent handles one draft
  - 5 sections in 30s instead of 2.5 minutes serially
  - Verify every write actually succeeded
- Phase 5: Archive drafts; the published document is now the source of truth

**Benefits**: speed from parallel writes, safety from validating before publishing,
recoverability when a write fails, and transparency because the user can read the
drafts first.

**When to use**: writing several related pieces of content where generation is
interdependent but the writes are not.

**Anti-pattern**: Don't generate and publish in the same step. If the write fails,
the content is gone.

### 9. Connectors as the integration layer

Use MCP connectors for external systems rather than hand-rolled scripting:

**Close-Out**: a connector for wherever the report gets published; the sales export
starts as a manual CSV drop and gets connected later.

**Vendor Watch**: invoices start as PDFs in a folder. Connecting the vendor portal
directly is a V2 goal, not a V1 requirement.

**Pattern**: Connectors hide the messy parts of talking to other systems. Starting
manual is legitimate – see `connectors.md`, and never block a V1 on a
connector that doesn't exist yet.

### 10. Research before action

Gather context before generating anything:

**Close-Out**: read the actual numbers before writing a single sentence of summary.

**Vendor Watch**: look up what an item cost historically before calling a change
notable.

**Pattern**: Context gathering prevents confident errors.

### 11. Permissions as configuration

Use `.claude/settings.json` for project permissions, so the user isn't approving
the same action repeatedly:
- Which files may be read and written
- Which shell commands are pre-approved
- Machine-specific overrides go in `.claude/settings.local.json`, which is never
  committed

**Pattern**: Pre-approve the safe and ordinary; keep prompting for the dangerous.

## Architectural choices

### Commands vs. skills

**Close-Out** – single entry point:
- One main command (`/close-out`)
- The workflow lives in the command file
- Research agents in separate `.claude/agents/` files

**Vendor Watch** – modular:
- Multiple commands for different entry points
- Commands invoke skills; skills compose other skills
- Clear split: Commands are the interface, Skills are the logic

**Insight**: Start with the Close-Out shape. Move toward the Vendor Watch shape
when you notice two commands needing the same logic – that's the signal, not a
preference for tidiness.

### File organization

**Close-Out**:
```
.claude/
├── commands/
├── agents/          # Invoked by the Task tool
└── knowledge/

close-out-sessions/  # One directory per week's work
└── [week-of-date]/
```

**Vendor Watch**:
```
.claude/
├── commands/        # User-facing entry points
├── skills/          # Invoked by the Skill tool
└── settings.json

knowledge/           # Item and price reference - the source of truth
reports/             # Persistent output
```

### Skill vs. agent invocation

**Agents** (the Close-Out style): invoked with the `Task` tool and a
`subagent_type`. Markdown files containing a prompt. Good for parallel one-shot
work – "go read this file and report back."

**Skills** (the Vendor Watch style): invoked with the `Skill` tool by name. Have
YAML frontmatter and can declare `allowed-tools`. Good for reusable logic that
more than one command needs.

## Best practices

1. **Minimize user blocking time** – parallelize wherever possible
2. **Make workflows resumable** – persist state as files
3. **Validate before finalizing** – catch errors early
4. **Research first, never assume** – read the real data before generating
5. **Single responsibility components** – each does one thing well
6. **Knowledge files over prompts** – separate the data from the logic
7. **Support both guided and fast modes** – different time budgets
8. **Explicit permissions** – pre-approve the ordinary
9. **Meet the user where they work** – put output where they'll actually read it
10. **Progress visibility** – say what's happening while it happens

## Anti-patterns to avoid

1. **Monolithic workflows** – hard to debug, impossible to resume
2. **Serial when parallel is possible** – wastes the user's time
3. **Assumptions over research** – produces confident errors
4. **Weakening a check to make it pass** – hides the real problem
5. **Blocking V1 on a connector that doesn't exist** – manual input is fine
6. **Embedding reference data in logic** – makes routine updates scary
7. **Claiming success when something failed** – erodes trust fastest of all
8. **Batching status updates** – mark work done as it completes
9. **Hand-rolled shell for file operations** – use the proper tools
10. **Guessing at an integration** – check what's actually connected
