---
name: create-agent
description: Install agent-builder tools and guide users through creating MCP-powered workflow agents. Conducts use case interview, designs architecture, generates initial files, and creates project plan documentation.
allowed-tools: Read, Write, Edit, Glob, Bash, AskUserQuestion, TodoWrite, EnterPlanMode, ExitPlanMode
---

# Create Agent Skill

You are guiding a user through building a workflow agent using Claude Code.

**Reference files:**
- `.claude/knowledge/workflow-patterns.md` - Common patterns from successful projects
- `.claude/knowledge/component-decision-guide.md` - When to use Commands, Skills, Agents, Knowledge
- `.claude/knowledge/mcp-integration.md` - How to use MCPs effectively
- `.claude/knowledge/setup-command-guide.md` - How to implement /setup commands in user workflows
- `.claude/files-to-install/` - Tools to copy into user's project

## Your Task

Guide the user through 6 phases to create a working V1 workflow:

### Phase 0: Install Agent-Builder Tools

**Goal**: Copy all agent-builder tools into the user's current directory

**Process**:

1. **Verify we're in a good location**:
   - Check if current directory looks like a project root
   - If empty directory: perfect
   - If has files: ask user if they want to install here

2. **Copy all tools from `.claude/files-to-install/` to current directory**:

   **Commands to copy**:
   - `.claude/files-to-install/commands/review-workflow.md` → `.claude/commands/review-workflow.md`
   - `.claude/files-to-install/commands/save-workflow.md` → `.claude/commands/save-workflow.md`

   **Skills to copy**:
   - `.claude/files-to-install/skills/security-checker/SKILL.md` → `.claude/skills/security-checker/SKILL.md`
   - `.claude/files-to-install/skills/software-best-practices/SKILL.md` → `.claude/skills/software-best-practices/SKILL.md`
   - `.claude/files-to-install/skills/improve/SKILL.md` → `.claude/skills/improve/SKILL.md`

   **Knowledge templates to copy**:
   - All `.claude/files-to-install/templates/*` → `.claude/knowledge/templates/*`

3. **Confirm installation**:
   - List what was installed
   - Explain that these tools are now part of their project
   - They can customize them as needed

**Output**:
```
Installed agent-builder tools:
- /review-workflow command (holistic workflow analysis)
- /save-workflow command (commit with context)
- security-checker, software-best-practices, improve skills
- File templates for workflow generation

These tools are now part of your project. Let's build your workflow!
```

### Phase 1: Use Case Discovery

**Goal**: Identify a repetitive workflow that could benefit from automation

**Process**:
1. Ask about their work context
2. Identify repetitive tasks
3. Evaluate automation potential
4. Select one use case to start

**Questions to ask** (adapt based on responses):
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

### Phase 2: Process Interview

**Goal**: Deeply understand current process and pain points

**Process**:
1. Walk through a recent example
2. Identify data sources and tools used
3. Map decision points and bottlenecks
4. Understand quality criteria
5. Identify improvement opportunities

**Questions to ask**:
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

### Phase 2.5: Data Source Setup

**Goal**: Ensure user can connect to data sources BEFORE building the workflow

**IMPORTANT**: If the user's workflow requires accessing external data sources (systems of record), handle setup NOW before implementation.

**Process**:

1. **List all data sources identified** in the interview:
   - Notion, Confluence, Jira, GitHub, Slack, Gmail, Google Sheets
   - Internal APIs, databases, CRMs (Salesforce, HubSpot)
   - Any other systems they mentioned

2. **Check for available plugins/MCPs**:
   "Before we build this workflow, let's make sure you have access to the data sources you need.

   You mentioned [list of data sources]. Do you have any shared plugins or MCP servers configured for these systems?

   If not, you can find official MCPs at:
   - Claude Code Plugin Marketplace (in your Claude Code settings)
   - Model Context Protocol Registry: https://github.com/modelcontextprotocol/servers"

3. **For each data source, recommend setup**:

   **If MCP/plugin is available**:
   - "Great! Install the [system] MCP: [installation instructions from marketplace]"
   - Test connection before proceeding

   **If no org plugin, check public MCPs**:
   - Notion: `@modelcontextprotocol/server-notion`
   - Slack: `@modelcontextprotocol/server-slack`
   - GitHub: `@modelcontextprotocol/server-github`
   - Google: `@modelcontextprotocol/server-google-drive`, `@modelcontextprotocol/server-gmail`
   - Jira: Check for Atlassian MCP plugins

   **If no MCP available**:
   - Follow guidance in `.claude/knowledge/mcp-integration.md` "When no MCP exists"
   - **Recommended**: Create a local MCP server in the workflow project
     - Inform user: this takes extra time but provides better maintainability
     - Generate `mcp-servers/[system-name]/` directory
     - Implement MCP using system's APIs
     - **Check authentication options**: Prefer SSO/OAuth > Service accounts > API keys
       - Ask user: "Does [system] support SSO or OAuth? That's more secure than API keys."
       - If SSO available: implement OAuth flow, no stored credentials needed
       - If not: document API key setup in .env (never hardcode)
     - Update `/setup` to document local MCP installation
     - Run `software-best-practices` and `security-checker` before commit
   - **Alternative**: Use APIs directly only for simple one-off operations
   - **Fallback**: Consider deferring to V2 (build simpler V1 first without this source)

4. **Create setup checklist** in `project-plan/data-source-setup.md`:

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

5. **Handle missing MCPs** (IMPORTANT):
   For each data source, check MCP availability:

   **If MCP exists** (official or org-provided):
   - Proceed with MCP-based workflow
   - Document MCP requirements in data-source-setup.md
   - User will verify MCP setup when running `/setup` later
   - No manual option needed

   **If NO MCP exists**:
   - Warn user: "No MCP exists for [system]. We can create a custom MCP server, but this is tedious and takes extra time."
   - Offer choice:
     - **Option A**: "We can build a custom MCP server now" (follow guidance in mcp-integration.md)
     - **Option B**: "We can defer this and do it manually for now"
   - If user chooses Option B (defer):
     - Add to `project-plan/IMPROVEMENTS.md`: "V2: Create custom MCP for [system]"
     - Document in workflow: "Manual step: User provides [system] data via [copy-paste/file/etc.]"
     - Instruct user how to gather/provide data manually
     - Workflow processes data from manual input
   - **Don't block workflow creation** - manual is always an option

   Example dialogue:
   ```
   "You mentioned Airtable. There's no official Airtable MCP. We have two options:

   1. Build a custom Airtable MCP server now - this is tedious but makes the workflow fully automated
   2. Handle Airtable data manually for V1 - you export data or copy-paste it, we'll automate in V2

   Which would you prefer?"
   ```

6. **Decision point**:
   Based on availability and user choice:
   - **All sources have MCPs?** → Proceed to Phase 3 with automated workflow
   - **User chose to build custom MCP?** → Create local MCP, then proceed to Phase 3
   - **User chose manual for missing MCPs?** → Add to IMPROVEMENTS.md, document manual steps, proceed to Phase 3

**Output**:
- `project-plan/data-source-setup.md` with checklist
- Append status to `project-plan/interview-notes.md`
- Update V1 scope in design if needed

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
3. Continue to Phase 3 (now in plan mode)

---

### Phase 3: Improvement Plan Design

**Goal**: Design a workflow using Claude Code features

Read `.claude/knowledge/workflow-patterns.md` and `.claude/knowledge/mcp-integration.md` for guidance.

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
- Example: `/write-prd`, `/analyze-tickets`
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

**Define V1 Scope** (start minimal):
- V1: Research + manual generation (prove research works)
- V2: Add generation (prove quality acceptable)
- V3: Add validation (prevent common errors)
- Document future enhancements

**Format and write the plan**:

1. **Structure the plan** following markdown formatting guidelines from CLAUDE.md:
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

3. **Write to plan file**: Use Write tool to create the plan at the path provided in system instructions

4. **Exit plan mode**: Call `ExitPlanMode` tool to request user approval

**Output**: Plan file written and submitted for user review

### Phase 4: Implementation

**Goal**: Build the V1 workflow

**Note**: This phase begins after plan approval. The plan has been reviewed and approved by the user.

**First step - Copy plan to project**:

1. Read the approved plan from the plan file location (check system instructions for path)
2. Write to `project-plan/project-design.md` in the user's project directory
3. Inform user: "I've saved the approved plan to `project-plan/project-design.md` for your reference."

This ensures the design document is:
- Easy for new users to find in the project directory
- Available for Claude to reference in future sessions
- Part of the project's documentation alongside interview notes and data source setup

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

Create directories:
```bash
mkdir -p .claude/commands
mkdir -p .claude/skills  # Reusable components
mkdir -p .claude/knowledge
mkdir -p [work-sessions]  # e.g., prd-sessions, query-sessions
```

Add to `.gitignore` (use template from `.claude/files-to-install/templates/gitignore.template`):
```
[work-sessions]/
.claude/config.json
.env
*.log
```

**4.2 Permissions Configuration**

Create `.claude/config.json` automatically using the template from `.claude/files-to-install/templates/config.template.json`.

**Process**:
1. Read the template file
2. Replace `[PROJECT_PATH]` with the actual absolute path to the project directory (use `pwd` to get it)
3. Write to `.claude/config.json` in the user's new workflow project

This configuration reduces permission prompts within the project directory by allowing:
- Read, write, and edit operations on any files in the project (`**` pattern)
- Common safe bash commands (mkdir, mv, cp, ls, cat, tree, echo, find)
- Claude still requires permission for potentially dangerous operations (rm, git push --force, etc.)

**Important**: The `.gitignore` template already includes `.claude/config.json` since it's a local configuration file that shouldn't be committed.

**Note**: This file is local to each user's machine. The `/setup` command will verify it exists but won't try to recreate it (since paths are machine-specific).

**4.2.1 Create /setup Command**

Create `.claude/commands/setup.md` in the user's workflow project using:
- Template: `.claude/files-to-install/templates/setup.template`
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
- `[WORKFLOW_SESSIONS_DIR]` - Session directory name (e.g., prd-sessions)
- `[ENV_VARS_SECTION]` - If using .env, document required variables
- `[ADDITIONAL_LOCAL_SETTINGS]` - Any other local config beyond permissions
- `[TROUBLESHOOTING_TIPS]` - Common setup issues specific to this workflow

The `/setup` command must capture ALL local configuration that isn't committed to git.

**4.3 Main Command**

Create `.claude/commands/[workflow-name].md` using template from `.claude/files-to-install/templates/command.template`.

Include:
- Brief description
- Usage instructions
- Phase breakdown with timing
- Error handling
- State management

**4.4 Research Implementation**

Create `.claude/skills/[skill-name]/SKILL.md` for each reusable component:
- Include YAML metadata: name, description, allowed-tools
- One skill per data source or reusable operation
- Use the Agent tool to run research skills in parallel when appropriate

**4.5 Knowledge Files**

Create `.claude/knowledge/[reference].md` for:
- Templates (content structure)
- Guidelines (quality criteria)
- Examples (what good looks like)

**4.6 Validate Setup**

Run the `/setup` command to validate the environment:

```bash
# In the user's workflow project
/setup
```

**What this validates**:
1. Git is installed and accessible
2. Required MCPs are available (uses `ListMcpResourcesTool`)
3. File structure is correct
4. Permissions are configured (if applicable)
5. Environment variables documented (if applicable)

**If setup finds issues**:
- Missing MCPs: Add installation instructions to `/setup` command
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

Create `README.md` using template from `.claude/files-to-install/templates/README.template`:
- Features
- Prerequisites (MCPs needed)
- Installation steps
- Usage instructions
- Architecture overview

Create `CLAUDE.md` using template from `.claude/files-to-install/templates/CLAUDE.template`:
- Project-specific instructions for Claude
- File organization rules
- Common patterns
- Error handling

**Output**: Working V1 implementation

### Phase 5: Iteration Planning

**Goal**: Define next improvements

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

### Phase 6: Git Initialization

**Initialize git and make first commit**:

1. Check if git is initialized: `git status`
2. If not: `git init`
3. Stage all files: `git add .`
4. Create initial commit:

```bash
git commit -m "Initial workflow setup via agent-builder

Created by: agent-builder create-agent skill
Workflow: [workflow-name]
Use case: [brief description]

Files created:
- project-plan/ (interview notes, design, improvements)
- .claude/commands/[workflow-name].md
- .claude/skills/ (reusable components)
- .claude/knowledge/ (reference materials)
- README.md (usage documentation)
- CLAUDE.md (project instructions)
- .gitignore (security patterns)

Next steps:
- Run workflow: /[workflow-name]
- Review: /review-workflow
- Save: /save-workflow
- Improve: /improve
"
```

## Final Summary

Show the user:
1. **How to run their workflow**: `/[workflow-name]`
2. **How to iterate**:
   - `/save-workflow` - Commit changes with context
   - `/review-workflow` - Analyze for improvements
   - `/improve` - End-of-session retrospective to upgrade skills and capture learnings
3. **Where to find documentation**:
   - `README.md` - Usage guide
   - `CLAUDE.md` - Project instructions
   - `project-plan/` - Design decisions and backlog
4. **V2+ roadmap**: What's in `IMPROVEMENTS.md`

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
