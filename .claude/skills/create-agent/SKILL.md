---
name: create-agent
description: Guide someone through building their first workflow assistant - a custom command that automates a repetitive task in their job. Interviews them about the task, designs it together in Plan Mode, builds a working version, and sets up the use-and-improve loop. Written for people who have never coded.
allowed-tools: Read, Write, Edit, Glob, Bash, AskUserQuestion, TodoWrite, EnterPlanMode, ExitPlanMode
---

# Create Agent Skill

You are guiding a user through building a workflow agent using Claude Code.

**Reference files:**
- `.claude/knowledge/workflow-patterns.md` - Common patterns from successful projects
- `.claude/knowledge/component-decision-guide.md` - When to use Commands, Skills, Agents, Knowledge
- `.claude/knowledge/connectors.md` - Connecting to real data sources (MCP), and when not to bother
- `.claude/knowledge/setup-command-guide.md` - How to implement /setup commands in user workflows
- `.claude/knowledge/templates/` - File templates used during Phase 4

## Running toolkit commands

**Never write raw shell in this flow.** Every shell operation is a verb on a
helper script that ships with the toolkit. There are two copies with identical
verbs and identical output, so pick by platform – you already know which OS you're
on, so just choose; don't run a command to detect it.

**macOS / Linux**:
```bash
bash .claude/scripts/toolkit.sh <verb> [args]
```

**Windows**:
```
powershell -ExecutionPolicy Bypass -File .claude\scripts\toolkit.ps1 <verb> [args]
```

Both are pre-approved in `.claude/settings.json`, so neither prompts. Invoke the
`.sh` via `bash` rather than `./` – zip archives don't reliably preserve the
executable bit. `-ExecutionPolicy Bypass` is required on Windows because files
extracted from a downloaded zip are blocked by default.

Verbs: `git-probe`, `git-setup`, `checkpoint`, `final-commit`, `scaffold`,
`settings-init`, `copy-toolkit`.

Below, verbs are written bare (`checkpoint "..."`) – expand to the right platform
form. If a verb ever fails, tell the user plainly what broke instead of
improvising raw shell around it.

## Saving progress as you go

Once git is set up in Phase 0, **take a snapshot at the end of each phase** rather
than saving everything once at the end. Where a phase says **📌 Checkpoint**, run:

```
checkpoint "[short description of what this phase produced]"
```

It prints `result=committed`, `result=nothing-to-commit`, or
`result=skipped-no-git`. Only the first is worth mentioning to the user.

Then tell the user in one line what you saved – "Saved your interview notes" – and
move on. Don't ask permission each time; don't make a production of it.

**If the user declined git in Phase 0, or it couldn't be installed, skip every
checkpoint silently.** Don't announce the skip, don't re-offer, don't hint. They
already answered.

Why this matters: it's the habit that makes AI-assisted work safe to experiment
with. If a later step goes wrong, there's a known-good point to return to. Say
this out loud the first time you checkpoint, then stop narrating it.

## Your Task

Guide the user through these phases to create a working V1 workflow (0 through 6,
including a 2.5 for data sources):

### Phase 0: Confirm Environment

**Goal**: Confirm the agent-builder toolkit is present, detect whether a workflow was already built here, and set expectations for the guided experience.

Since you're running this skill, the toolkit downloaded into this folder correctly – there's nothing left to install. Do a couple of quick checks, set the ground rules, then welcome the user.

**Process**:

1. **Check the toolkit is present**: Use Glob to confirm `.claude/commands/review-workflow.md` and `.claude/skills/workflow-reviewer/SKILL.md` exist.

   - **If found**: continue to step 2.
   - **If missing**: something went wrong with the download/unzip. Show:
     ```
     ⚠️  I can't find the agent-builder toolkit in this folder (.claude/commands/review-workflow.md is missing).

     Double-check that you downloaded and unzipped the repo into this exact folder, then run /create-agent again.
     ```
     **STOP** – do not continue until this is resolved.

2. **Check for an existing workflow**: Use Glob to check if `project-plan/project-design.md` already exists in this folder.

   - **If it doesn't exist**: this is a first run. Continue to step 3.
   - **If it exists**: a workflow was already built here. Read the file's title to get its name, then ask (`AskUserQuestion`):

     "It looks like you already built **[workflow name]** in this folder. What would you like to do?"
     - **Build something different** – a second, unrelated workflow is cleaner in its own folder. Ask for a name/path for the new folder, then run:
       ```
       copy-toolkit "[new-folder]"
       ```
       This copies only the toolkit (commands, skills, agents, knowledge, scripts,
       `.gitignore`) and deliberately leaves behind `project-plan/`, the existing
       custom workflow command, `CLAUDE.md` and `README.md`. Expect `result=copied`.

       Then tell the user: "I've copied the toolkit into `[new-folder]`. Open a new Claude Code session there (new tab, or quit and reopen in that folder) and run `/create-agent` again to start fresh."
       **STOP** – do not continue in this folder.
     - **Improve the existing workflow** – this isn't the right tool. Tell the user: "For evolving a workflow you already built, `/improve-workflow` is the better fit – want me to switch to that instead?" If yes, follow the `workflow-improver` skill's instructions instead of continuing here. **STOP** these instructions.

3. **Set the ground rules** (first run only):
   ```
   🧭 Guide's note: Throughout this walkthrough you'll see notes marked like this one.
   These aren't Claude thinking out loud – they're commentary built into this teaching
   tool that calls out real Claude Code features as they come up, so you start
   recognizing them for your own future projects.
   ```

   **Only if you are actually in Auto mode**, add this. Don't assert it blindly –
   the user may be in a mode where you stop and ask far more often, and claiming
   otherwise will confuse them when it doesn't match what they see:
   ```
   🧭 Guide's note: You're in Auto mode right now – that's the setting where I make
   more calls on my own instead of stopping to ask at every step. It's why this will
   feel fast. You can change it any time; it's your call how much rope I get.
   ```

4. **Welcome message**:
   ```
   ✅ Agent-builder tools are ready:

   📋 Commands: /review-workflow, /save-workflow, /improve-workflow
   🧠 Skills: workflow-reviewer, save-progress, security-checker, software-best-practices, workflow-improver
   🤖 Agents: 5 parallel review agents

   Let's build your workflow!
   ```

5. **Offer to set up version control** (first run only)

   Do this at the START, not the end – if it's worth doing at all, it's worth doing
   before there's an hour of unsaved work to lose.

   **This is an offer, not a requirement. Never block the flow on it.** A user who
   declines still gets a complete, working workflow; they just don't get automatic
   snapshots.

   **a. Probe what's already there**

   Run the `git-probe` verb (see "Running toolkit commands" above):

   ```
   git-probe
   ```

   It prints three lines, for example:
   ```
   git=ready
   identity=missing
   repo=no
   ```

   The script deliberately avoids running `git` itself when checking whether git
   exists – on macOS that would trigger the Command Line Tools installer popup
   before the user has been asked whether they want it. Don't work around this by
   running `git --version` yourself.

   **b. Pick the right path based on what you found**

   - **`git=ready` AND `identity=set`** → they're already set up. Ask
     nothing, say nothing about it. Go straight to c.

   - **`git=ready` but `identity=missing`** → small ask:

     "One quick thing: git can save a snapshot of your work after each step, so
     nothing gets lost and we can undo anything. It just needs a name and email to
     label the saves with – takes about a minute. Want to set that up?"

   - **`git=missing`** → the honest, bigger ask. Use `AskUserQuestion`.

     **On macOS**:

     "I'd like to set up git – it saves a snapshot of your work after each step so
     nothing gets lost and we can always go back. Your Mac doesn't have it yet, so
     macOS will pop up asking to install its developer tools (about a 1 GB
     download from Apple).

     **Usually 5–10 minutes, though it can take longer on a slow connection.** You
     only ever do this once, and it's the same tooling every developer on a Mac
     has.

     Want to set it up now, or skip it and just build?"

     **On Windows**: the install is Git for Windows, a much smaller download and
     typically **2–3 minutes**. Worth saying that it also improves how Claude Code
     works on Windows generally, since it brings a proper shell with it. Point them
     at https://git-scm.com/download/win and wait while they install.

     Either way, offer two options:
     - **Set it up** – snapshots after each step, and you can undo mistakes
     - **Skip it** – we build normally, files save to this folder as usual, no snapshots

   **If they decline (either ask)**: accept it immediately and cheerfully. Say:
   "No problem – we'll build without it. Your files still save to this folder
   normally." Then set a mental flag: **skip every 📌 Checkpoint and all of Phase 6
   for the rest of this flow, and do not bring git up again.** Nagging a user who
   already said no is worse than not offering. Mention once, in the Final Summary
   only, that they can add it later if they change their mind.

   **If they accept the install**: tell them what to click, wait for them to say
   it's finished, then re-run `git-probe`. If it still reports `git=missing`, don't
   fight it – fall back to the declined path above.

   **c. Start tracking this folder** (only if they accepted)

   ```
   🧭 Guide's note: I'm setting up git – it saves a snapshot of your work each time
   we finish a step, so we can always go back if something breaks. You don't need to
   learn any git commands; I'll handle it and tell you what I'm saving.
   ```

   If `identity=missing`, pass the name and email they gave you. If identity was
   already set, pass no arguments:

   ```
   git-setup "[their name]" "[their email]"
   ```

   Their name and email are just labels on their own local snapshots – say so, so
   nobody worries about what their email is being used for.

   Expect `result=committed`. Then tell the user: "Saved a starting snapshot. From
   here I'll save after each big step, so nothing gets lost."

Continue to Phase 1.

### Phase 1: Use Case Discovery

**Goal**: Identify a repetitive workflow that could benefit from automation

**Step 1: Determine user's starting point**

Ask this question FIRST:

```
Do you already know what workflow you want to automate?

1. Yes - I have a specific use case in mind
2. No - Help me discover automation opportunities
```

**If user selects Option 1 (knows what they want)**:
- Skip the discovery questions below
- Jump directly to: "Describe the workflow you want to automate"
- Continue to Phase 2 (Process Interview) with targeted questions about their specific use case

**If user selects Option 2 (needs help discovering)**:
- Continue with the discovery process below

**Step 2: Discovery Process** (only if user selected Option 2)

1. Ask about their work context (ONE QUESTION AT A TIME)
2. Identify repetitive tasks
3. Evaluate automation potential
4. Select one use case to start

**Questions to ask** (ONE AT A TIME - adapt based on responses):
- What kind of work do you do regularly?
- What tasks take up most of your time?
- Which tasks feel repetitive or mechanical?
- What tasks require gathering information from multiple sources?
- What tasks involve writing similar documents repeatedly?

**Good use case characteristics**:
- ✅ Requires gathering information from 2+ sources
- ✅ Involves writing/generating content
- ✅ Follows a repeatable process
- ✅ Takes 30+ minutes currently
- ✅ Done weekly or more frequently
- ✅ Quality depends on completeness/consistency
- ❌ Requires real-time human judgment calls
- ❌ Highly creative/novel each time
- ❌ No clear success criteria

**If use case is poor fit**:
- Explain why (doesn't match good characteristics)
- Help identify better alternatives
- Don't force implementation of bad use case

**Output**: Document to `project-plan/interview-notes.md`

**📌 Checkpoint**: `"Capture use case: [workflow name]"` – this is the first
checkpoint, so briefly explain what saving means (see "Saving progress as you go").

### Phase 2: Process Interview

**Goal**: Deeply understand current process and pain points

**Process**:
1. Walk through a recent example
2. Identify data sources and tools used
3. Map decision points and bottlenecks
4. Understand quality criteria
5. Identify improvement opportunities

**Questions to ask** (ONE AT A TIME):
- Walk me through a recent time you did this task
- **What information sources do you consult?** (IMPORTANT: Ask this proactively)
- **Where does this data live?** (CRMs, wikis like Notion/Confluence, Jira, GitHub, Google Sheets, Gmail, Slack, databases, APIs, etc.)
- What tools/systems do you use?
- Where do you get stuck or slowed down?
- What mistakes happen sometimes?
- What would make this task easier?
- What does "done well" look like?
- What's the minimum viable outcome?

**When user mentions systems of record** (Notion, Jira, Slack, GitHub, Salesforce, Google Workspace, etc.):
- Note each data source they mention
- Keep track for Phase 2.5 (Data Source Setup)

**Output**: Append to `project-plan/interview-notes.md`

**Step: Ideas or known plan** (after the interview, before data source setup)

Ask the user directly:

"Now that I understand your process – would you like me to suggest a few ideas for how this could work, or do you already know what you want built?"

- **If they want ideas**: Propose 2-3 distinct, concrete automation angles based on everything gathered so far – don't just restate what they already told you. Let them react, mix and match, or pick one. This is deliberately unprompted: form your own view before they tell you theirs.
- **If they already know**: Confirm their approach briefly and move on.

🧭 Guide's note: This is a habit worth building on your own projects – ask your AI what it thinks before you tell it what to do. You get ideas you wouldn't have thought of, and you can always ignore them.

**Output**: Append the chosen direction to `project-plan/interview-notes.md`

**📌 Checkpoint**: `"Document current process and chosen direction"`

### Phase 2.5: Data Source Setup

**Goal**: Ensure user can connect to data sources BEFORE building the workflow

**IMPORTANT**: If the user's workflow requires accessing external data sources (systems of record), handle setup NOW before implementation.

**Keep this short.** The user hasn't built anything yet and this is not the
interesting part. The only question that matters per data source is: *can we reach
it automatically, or does the user paste it in for now?* Both answers are fine.

**Talk about connectors, not MCP servers.** Say "connector" – that's the word in
the interface and the thing they'd click. Mention MCP once, only so the acronym
isn't a mystery later:

```
🧭 Guide's note: A "connector" lets Claude read from a system directly – your
Notion, your email, a shared drive – instead of you copying and pasting. You add
them in Claude Desktop under Settings → Connectors: pick the tool, sign in, done.
Nothing to install. (You'll sometimes see them called MCP servers – same thing.)

Two nice things about it: you're never handing over a password, and you can switch
Claude's access off from the other tool's own settings whenever you want.
```

**Process**:

1. **List the data sources** they mentioned in the interview, and ask which they
   already have connected:

   "You mentioned [list]. Are any of these already connected to Claude for you?
   If you're not sure, that's fine – we'll find out."

   To see what's already connected, use `ListMcpResourcesTool`.

   If they want to add one, walk them to the UI – don't send them to a config file
   or an install command:
   - **Claude Desktop**: Settings → Connectors. Ready-made connectors for common
     tools are listed there; pick one and sign in. Not listed? "Add custom
     connector" takes a URL from the vendor.
   - **Claude Code**: `/mcp`

   Two caveats worth raising before they go hunting: custom connectors need a Pro,
   Max, Team or Enterprise plan, and on Team/Enterprise an Organization Owner adds
   them centrally – so it may be a request to their admin rather than something
   they can do themselves.

   Don't recite package names. See `.claude/knowledge/connectors.md`.

2. **For each source, pick one of two paths** – and bias hard toward the second:

   **Connected already** → use it. Note it in the checklist and move on.

   **Not connected** → do it manually for V1. Say so plainly and without
   apology:

   "There's no connection set up for [system], so for the first version you'll
   paste that part in yourself. That's a completely normal way to start – we get
   the workflow working end to end, and connecting it properly is a good V2."

   Then add to `project-plan/IMPROVEMENTS.md`: "V2: connect [system] directly",
   and document the manual step in the workflow itself.

**Do not offer to build a custom MCP server here.** It's a genuine project of its
own, it requires an authentication decision the user isn't equipped to make yet,
and it guarantees they never reach a working V1 today. If they explicitly ask for
one, point them at `.claude/knowledge/connectors.md` and treat it as a
separate piece of work after V1 ships.

3. **Create setup checklist** in `project-plan/data-source-setup.md`:

```markdown
# Data Source Setup Checklist

## Required Data Sources
- [ ] [System 1] - [Status: Not started | In progress | Connected]
  - Method: [MCP | API | Manual]
  - Setup: [Instructions or link]
  - Test: [How to verify connection]

- [ ] [System 2] - [Status]
  - Method: [MCP | API | Manual]
  - Setup: [Instructions]
  - Test: [How to verify]

## Optional Data Sources (V2+)
- [ ] [System 3] - [Deferred to V2]
  - Reason: [Why not in V1]

## Setup Status
- Total sources: [X]
- Ready: [X]
- In progress: [X]
- Blocked: [X]

## Next Steps
[What user needs to do before continuing]
```

   Example, for a workflow that pulls together a weekly close-out report:
   ```markdown
   # Data Source Setup Checklist

   ## Required Data Sources
   - [x] Toast sales export - Connected
     - Method: Manual (CSV export)
     - Setup: Download "Weekly Sales Summary" from Toast, save to inbox/
   - [ ] Staff schedule (Google Sheets) - Not started
     - Method: Manual for V1
     - Setup: Paste the week's schedule when asked

   ## Deferred to V2
   - [ ] Connect Google Sheets directly
     - Reason: manual paste works fine for V1; connect once the format settles

   ## Next Steps
   Export the Toast weekly summary before running the workflow.
   ```

4. **Never block on this.** Manual input is always an acceptable answer. A
   workflow that works today with one paste-in step beats a fully automated one
   the user never finishes.

**Output**:
- `project-plan/data-source-setup.md` with checklist
- Append status to `project-plan/interview-notes.md`
- Update V1 scope in design if needed

**📌 Checkpoint**: `"Record data source setup plan"`

**Why this matters**:
- Prevents building a workflow that can't access its data
- Discovers missing integrations early
- Allows user to get credentials/approvals while we design
- Sets realistic V1 expectations based on what's actually available

---

**IMPORTANT: Enter Plan Mode**

Before designing the implementation plan, enter plan mode to enable collaborative review:

1. Call `EnterPlanMode` tool
2. Explain to user: "I'm entering plan mode to design your workflow architecture. You'll be able to review and request changes to the plan before we start implementation."

   🧭 Guide's note: Plan Mode is a real Claude Code feature – it lets you review a proposed plan and request changes before any files get touched. Reach for it any time you want to see the approach before committing to it.
3. Continue to Phase 3 (now in plan mode)

---

### Phase 3: Improvement Plan Design

**Goal**: Design a workflow using Claude Code features

**Step 0: Confirm goal and constraints**

The interview already surfaced most of this – don't make the user re-derive it from scratch. Draft it back to them:

"Here's what I think we're building:
- **Goal**: [one sentence, drafted from the interview]
- **Constraints**: [one or two sentences – time, data access, tools, anything that limits the approach]

Did I get that right?"

Adjust based on their response. This becomes part of the plan document's Use Case Summary.

Read `.claude/knowledge/workflow-patterns.md` and `.claude/knowledge/connectors.md` for guidance.

**Process**:
1. Identify available integrations (MCPs)
2. Design research phase (parallel data gathering)
3. Design generation/action phase
4. Define validation/quality checks
5. Plan incremental improvements (V1 → V2+)

**Key Design Decisions**:

**MCPs Available?**
- Check what MCP servers user has installed
- Suggest alternatives if needed
- Document missing MCPs as V2 requirement

**Research Phase**:
- What information needs gathering?
- Can research run in parallel?
- Design research agents/skills (one per source)

**Generation Phase**:
- What needs to be created/updated?
- Serial vs parallel generation?
- What validation is needed?

**Choose Claude Code Features**:

Read `.claude/knowledge/component-decision-guide.md` for detailed guidance. Quick summary:

Use **Commands** for user-facing entry points:
- Example: `/close-out`, `/vendor-watch`
- User types this to start the workflow

Use **Skills** when logic is reusable or composable:
- Example: validator, researcher, executor
- Multiple commands can use the same skill

Use **Agents** (via Task tool) for parallel workers:
- Example: Research Notion, Slack, Jira simultaneously
- Minimize blocking time with parallel execution

Use **Knowledge files** for reference materials:
- Example: Interview guides, templates, validation rules
- Data that changes independently of logic

As you pick each piece, name the concept out loud to the user rather than silently
choosing – "I'm making this a Skill because you'll want to reuse it." Then show
them this note once, when you make the first such choice:

```
🧭 Guide's note: Commands, Skills, Agents and Knowledge files are the four
building blocks of Claude Code – not something special to this toolkit. A Command
is what you type. A Skill is reusable know-how. Agents run in parallel. Knowledge
files are reference material. You'll see all four everywhere once you know the
names.
```

**Define V1 Scope** (start minimal):
- V1: Research + manual generation (prove research works)
- V2: Add generation (prove quality acceptable)
- V3: Add validation (prevent common errors)
- Document future enhancements

**Format and write the plan**:

1. **Structure the plan** using these markdown conventions:
   - Use proper headings (## for sections)
   - Use bullet lists for related items
   - Use blank lines between sections
   - Include code blocks for code examples

2. **Plan structure**:
   ```markdown
   # [Workflow Name] Implementation Plan

   ## Context
   [Why this workflow is needed, what problem it solves]

   ## Use Case Summary
   - **Goal**: [One sentence – confirmed with the user in Step 0]
   - **Constraints**: [Key limits – confirmed with the user in Step 0]
   - **Current process**: [Description]
   - **Time currently**: [Duration]
   - **Pain points**: [Key issues]
   - **Desired outcome**: [What success looks like]

   ## Data Sources
   [List from data-source-setup.md with MCP availability]

   ## Architecture Design

   ### Commands
   [List user-facing commands with descriptions]

   ### Agents/Skills
   [List parallel workers or reusable components]

   ### Knowledge Files
   [List reference materials needed]

   ## V1 Scope
   [What will be built in initial version]

   ## Implementation Steps
   [High-level phases for execution]

   ## V2+ Roadmap
   [Future enhancements from IMPROVEMENTS.md]

   ## Verification
   [How to test the workflow end-to-end]
   ```

3. **Submit the plan for approval**: Call `ExitPlanMode`, passing the full plan
   content as the plan text.

   **Do NOT try to write the plan to a file here.** Plan mode intentionally blocks
   file writes – that's the whole point of it, and attempting a Write will fail.
   Hold the plan content and persist it in Phase 4, after it's approved.

4. **If the user requests changes**: revise and call `ExitPlanMode` again. Stay in
   plan mode until they approve.

**Output**: Plan submitted for user review. Nothing written to disk yet.

### Phase 4: Implementation

**Goal**: Build the V1 workflow

**Note**: This phase begins after plan approval. The plan has been reviewed and approved by the user.

**First step - Persist the approved plan**:

Plan mode has now exited, so writes work again.

1. Write the plan you just got approved – the same content you passed to
   `ExitPlanMode` – to `project-plan/project-design.md`.
2. Inform user: "I've saved the approved plan to `project-plan/project-design.md` for your reference."

**📌 Checkpoint**: `"Save approved design for [workflow name]"`

This ensures the design document is:
- Easy for new users to find in the project directory
- Available for Claude to reference in future sessions
- Part of the project's documentation alongside interview notes and data source setup
- The marker Phase 0 uses to detect that a workflow was already built here, so
  don't skip it

**Then proceed with implementation as normal**:

**Process**:
1. Set up file structure
2. Configure permissions and create /setup command
3. Implement main command
4. Implement research phase (agents/skills)
5. Create knowledge files
6. Run /setup to validate environment
7. Test workflow
8. Document usage

**4.1 File Structure**

Create directories – pass the workflow's session directory name (e.g.
`close-out-sessions`, `report-sessions`), or omit the argument if it doesn't need one:

```
scaffold "[work-sessions]"
```

This creates `.claude/commands`, `.claude/agents`, `.claude/skills`,
`.claude/knowledge`, `project-plan` and the session directory. Expect
`result=scaffolded`.

Merge the `.gitignore` template (`.claude/knowledge/templates/gitignore.template`)
into the existing root `.gitignore` – don't overwrite it, it already has the
security patterns. Add the workflow's session directory:
```
[work-sessions]/
```

Do **not** add `project-plan/` to `.gitignore`. Those notes are the record of why
this workflow exists and should be committed.

If the workflow uses a `.env` file, also create a committed `.env.example`
alongside it listing every required variable with placeholder values:
```
# Copy to .env and fill in real values. Never commit .env itself.
NOTION_API_KEY=your-key-here
```
`/review-workflow` checks for this, and it's how the next person knows what the
workflow needs.

**4.2 Permissions Configuration**

`.claude/settings.json` already exists – it ships with the toolkit, which is why
you haven't been prompted for permission on every file write so far. There's
normally nothing to do here.

Only if it's somehow missing, reinstall it:
```
settings-init
```

There is nothing to fill in – it uses project-relative patterns (`Read(**)`), not
absolute paths, so it works on any machine and gets committed with the project.

This reduces permission prompts within the project by pre-approving:
- Read, write, and edit operations on files in the project (`**` pattern)
- Common safe bash commands (mkdir, mv, cp, ls, cat, tree, echo, find)
- Ordinary git commands (status, diff, log, add, commit)

Genuinely risky operations (rm, force-push) still prompt every time.

🧭 Guide's note: Claude Code reads project permissions from `.claude/settings.json`.
If you ever find yourself approving the same action over and over in a project,
that file is where to fix it – and `.claude/settings.local.json` is the gitignored
version for machine-specific overrides you don't want to share.

**Note**: `/setup` verifies this file exists and can re-copy it from the template
if it's ever missing.

**4.2.1 Create /setup Command**

Create `.claude/commands/setup.md` in the user's workflow project using:
- Template: `.claude/knowledge/templates/setup.template`
- Implementation guide: `.claude/knowledge/setup-command-guide.md`

Fill in the placeholders:
- `[WORKFLOW_NAME]` - The name of the workflow
- `[MCP_LIST]` - Extract from `project-plan/data-source-setup.md` "Required Data Sources" section. Format as:
  ```markdown
  - **notion** - For accessing workspace pages and databases
  - **slack** - For searching message history
  - **github** - For repository and PR information
  ```
  Only include MCPs (not APIs or manual sources). If no MCPs needed, state: "This workflow doesn't require any MCP servers."
- `[WORKFLOW_SESSIONS_DIR]` - Session directory name (e.g., close-out-sessions)
- `[ENV_VARS_SECTION]` - If using .env, document required variables
- `[ADDITIONAL_LOCAL_SETTINGS]` - Any other local config beyond permissions
- `[TROUBLESHOOTING_TIPS]` - Common setup issues specific to this workflow

The `/setup` command must capture ALL local configuration that isn't committed to git.

**4.3 Main Command**

Create `.claude/commands/[workflow-name].md` using template from `.claude/knowledge/templates/command.template`.

Include:
- Brief description
- Usage instructions
- Phase breakdown with timing
- Error handling
- State management

**4.4 Research Implementation**

**If using agents** (the single-entry-point pattern – see `workflow-patterns.md`):
- Create `.claude/agents/[agent-name].md` for each research source
- Each agent reads context, searches one source, writes findings

**If using skills** (the modular pattern – see `workflow-patterns.md`):
- Create `.claude/skills/[skill-name]/SKILL.md` for each reusable component
- Include YAML metadata: name, description, allowed-tools

**4.5 Knowledge Files**

Create `.claude/knowledge/[reference].md` for:
- Templates (content structure)
- Guidelines (quality criteria)
- Examples (what good looks like)

**4.6 Validate Setup**

`/setup` has to be run by the user – Claude cannot invoke its own slash commands,
so don't try. Ask them to type it:

```
Type /setup and paste me what it says – that runs the setup command we just
built and tells us whether it actually works.
```

Wait for their output, then act on it. If they'd rather not, walk the `/setup`
file's checks yourself by reading it and verifying each one, and say that's what
you're doing.

**What this validates**:
1. Git is installed and accessible
2. Required MCPs are available (uses `ListMcpResourcesTool`)
3. File structure is correct
4. Permissions are configured (if applicable)
5. Environment variables documented (if applicable)

**If setup finds issues**:
- Missing connector: make sure `/setup` says how to add it (Settings → Connectors,
  or `/mcp`) and what the manual alternative is
- Incorrect paths: Fix in `/setup` documentation
- Missing files: Check file structure creation
- Update `/setup` command based on findings

**Why this matters**:
- Catches errors in the `/setup` command itself
- Validates that setup instructions are complete and correct
- Ensures environment is ready before testing workflow
- Better user experience (setup catches issues, not workflow execution)

**4.7 Testing**

Test the workflow:
1. Run command with test data
2. Verify research phase completes
3. Check output format
4. Test error handling
5. Document any issues in `project-plan/IMPROVEMENTS.md`

**If workflow fails due to environment**:
- Update `/setup` command to catch that issue
- Re-run `/setup` to verify the fix

**4.8 Documentation**

Write `README.md` using template from `.claude/knowledge/templates/README.template`:
- Features
- Prerequisites (MCPs needed)
- Usage instructions
- Architecture overview

**Heads up – this replaces a file the user has been reading.** Right now the root
`README.md` is agent-builder's own guide (it came out of the zip). From here on
this folder is *their* workflow project, so its README should describe their
workflow. Before writing, tell them plainly:

```
I'm about to replace README.md – right now it's the agent-builder guide that came
with the download, and from here it should describe YOUR workflow instead.

The toolkit's own reference docs stay in .claude/knowledge/, and the original
guide is always available at github.com/anutron/agent-builder-plugin.
```

The previous version is also recoverable from the Phase 0 snapshot, which is one
more reason that checkpoint happens first.

Create `CLAUDE.md` using template from `.claude/knowledge/templates/CLAUDE.template`:
- Project-specific instructions for Claude
- File organization rules
- Common patterns
- Error handling

**📌 Checkpoint**: `"Build V1 of [workflow name]"`

**Output**: Working V1 implementation

### Phase 5: Iteration Planning

**Goal**: Define next improvements

**Step 0: Offer a "level up" idea** (only after Phase 4 testing succeeds and V1 actually works)

Now that the user has something working, look for ONE well-matched opportunity to make it more capable – tied to something concrete they just built, not a generic list. Examples of the kind of offer to make:

- "Your workflow now produces [concrete output]. Want to try turning [the part that's currently prose] into an actual script? It'll be more consistent than having me reason through it each time."
- "This now generates [concrete artifact, e.g. a CSV]. Want a small local web page that visualizes it?"
- "This workflow does [substantial multi-step thing]. If it keeps growing, the `/workflows` tool can orchestrate the parallel pieces more deterministically than manually launching agents – see `.claude/knowledge/component-decision-guide.md` for when that's worth it."

🧭 Guide's note: This is deliberately offered *after* something works, not during design – prove the simple version first, then decide if leveling up is worth it.

Keep it to one offer, framed as optional: "No pressure – just flagging it's possible if you want to push further." If they decline or seem uninterested, drop it and move on.

**Process**:
1. Review V1 limitations
2. Prioritize improvements
3. Define V2 scope
4. Document enhancement roadmap

**V2+ improvements to consider**:
- Add generation phase
- Add validation gates
- Add one-shot autonomous mode
- Add resume capability
- Add batch processing
- Improve error handling
- Add progress visibility
- Optimize parallel execution

**IMPORTANT: Update /setup when requirements change**:
- Added new MCP? → Update [MCP_LIST] in `.claude/commands/setup.md`
- Added .env variables? → Update [ENV_VARS_SECTION] in `/setup`
- Added new local config? → Update [ADDITIONAL_LOCAL_SETTINGS] in `/setup`
- Changed directory structure? → Update file structure checks in `/setup`

**Output**: Write to `project-plan/IMPROVEMENTS.md`

### Phase 6: Final Save

Git was set up back in Phase 0 and you've been checkpointing along the way, so
this is just the closing snapshot – not a first-time setup.

If the user declined git in Phase 0, or it couldn't be installed, skip this phase
entirely – jump to the Final Summary.

1. Take the closing snapshot:

```
final-commit "Complete V1 of [workflow-name] - [brief use case description]"
```

This commits and then prints the full history under `--- history ---`.

2. Show that history to the user, so the habit is concrete rather than abstract.
   Then say: "That's every step we took, saved. If anything ever breaks, we can
   look at what changed or go back to any of these points."

4. **Mention pushing, but don't do it.** If they want an off-machine backup:
   "Right now these snapshots only exist on this computer. If you want a backup
   you can reach from anywhere, GitHub is the usual next step – say the word and I
   can walk you through it." Don't create accounts or push anything on their behalf.

## Final Summary

Show the user, in this order:

1. **The habit to build** (the most important thing to land):
   ```
   ✅ Your workflow is ready: /[workflow-name]

   The loop from here: use it → run /improve-workflow → use it again.
   That's how this gets better over time instead of staying frozen at V1.
   ```

2. **The other tools available**:
   - `/save-workflow` - Commit changes with context
   - `/review-workflow` - Check code quality, security, best practices
   - `/improve-workflow` - Retrospective after actually using it (the habit above)

3. **Where to find documentation**:
   - `README.md` - Usage guide
   - `CLAUDE.md` - Project instructions
   - `project-plan/` - Design decisions and backlog

4. **If they declined git in Phase 0** – and only then – mention it exactly once,
   without pressure, then never again:
   ```
   One thing you skipped earlier: git, which saves snapshots of your work so you
   can undo changes. If you ever want it, just say "set up git" and I'll walk you
   through it – takes a few minutes.
   ```

5. **Going further** (optional, mention briefly): once this feels comfortable, there
   are more Claude Code features worth knowing – `/fewer-permission-prompts` to trim
   repeated approvals, `/mcp` to connect more data sources, global `CLAUDE.md`
   conventions that apply across every project, and `/workflows` if this one ever
   outgrows a single command. Aaron's public skill library at
   `github.com/anutron/ai` has more, including `/promote` for graduating a skill you
   like from one project to everywhere.

   Only name things that exist in the user's environment. `/fewer-permission-prompts`,
   `/mcp` and `/workflows` are built into Claude Code; `/promote` is not – it comes
   from that library, so don't present it as something they can already type.

**Offer to help**:
"Want to try running the workflow now? I can help debug if anything doesn't work as expected."

## Error Handling

**If scope too large**:
- Break into phases
- Build smallest useful increment
- Show how to extend later

**If user stuck on design**:
- Offer 2-3 concrete options
- Explain tradeoffs
- Make recommendation based on similar patterns from `.claude/knowledge/workflow-patterns.md`

**If MCP not available**:
- Suggest alternatives or manual steps
- Document as V2 improvement when MCP available

## Key Principles

1. **Ask, don't assume**: Use AskUserQuestion for choices
2. **Show progress**: Use TodoWrite to track phases
3. **Explain decisions**: Why this architecture?
4. **Get buy-in**: Review plan before implementing
5. **Start small**: V1 is intentionally limited
6. **Plan iterations**: Clear path to improvement
