---
name: quick-start
description: Guide users through creating MCP-powered workflow agents. Conducts use case interview, designs architecture, generates initial files, and creates project plan documentation.
allowed-tools: Read, Write, Edit, Glob, Bash, AskUserQuestion, TodoWrite
---

# Quick Start Skill

You are guiding a user through building a workflow agent using Claude Code.

**Reference files:**
- `.claude/knowledge/workflow-patterns.md` - Common patterns from successful projects
- `.claude/knowledge/mcp-integration.md` - How to use MCPs effectively
- `.claude/knowledge/setup-command-guide.md` - How to implement /setup commands in user workflows
- `.claude/knowledge/file-templates/` - Templates for generated files

## Your Task

Guide the user through 5 phases to create a working V1 workflow:

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

2. **Check for organizational plugins/MCPs**:
   "Before we build this workflow, let's make sure you have access to the data sources you need.

   You mentioned [list of data sources]. Does your organization provide any shared plugins or MCP servers to connect to these systems? Check with your team or in your organization's internal docs."

3. **For each data source, recommend setup**:

   **If org provides shared MCP/plugin**:
   - "Great! Install your org's [system] MCP: [installation instructions they provide]"
   - Test connection before proceeding

   **If no org plugin, check public MCPs**:
   - Notion: `@modelcontextprotocol/server-notion`
   - Slack: `@modelcontextprotocol/server-slack`
   - GitHub: `@modelcontextprotocol/server-github`
   - Google: `@modelcontextprotocol/server-google-drive`, `@modelcontextprotocol/server-gmail`
   - Jira: Check for Atlassian MCP plugins

   **If no MCP available**:
   - Recommend using APIs directly
   - Check if system has REST API
   - Document API setup requirements
   - Consider if this should be V2 (build simpler V1 first)

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

5. **Verify connections**:
   For each MCP/API:
   - Ask user to install/configure
   - Test basic connectivity
   - Document any credentials needed (in .env.example)

6. **Decision point**:
   - **All sources ready?** → Proceed to Phase 3
   - **Some sources not ready?** → Decide V1 scope
     - Option A: Build V1 without those sources (manual steps)
     - Option B: Wait until sources are connected
     - Option C: Build mock/test version first

**Output**:
- `project-plan/data-source-setup.md` with checklist
- Append status to `project-plan/interview-notes.md`
- Update V1 scope in design if needed

**Why this matters**:
- Prevents building a workflow that can't access its data
- Discovers missing integrations early
- Allows user to get credentials/approvals while we design
- Sets realistic V1 expectations based on what's actually available

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

Use **Commands** for user-facing entry points:
- Example: `/write-prd`, `/analyze-tickets`

Use **Skills** when logic is reusable or composable:
- Example: validator, researcher, executor

Use **Agents** (via Task tool) for parallel workers:
- Example: Research Notion, Slack, Jira simultaneously

Use **Knowledge files** for reference materials:
- Example: Interview guides, templates, validation rules

**Define V1 Scope** (start minimal):
- V1: Research + manual generation (prove research works)
- V2: Add generation (prove quality acceptable)
- V3: Add validation (prevent common errors)
- Document future enhancements

**Show user the plan** and get buy-in before proceeding.

**Output**: Write to `project-plan/project-design.md`

### Phase 4: Implementation

**Goal**: Build the V1 workflow

**Process**:
1. Set up file structure
2. Configure permissions and update /setup
3. Implement main command
4. Implement research phase (agents/skills)
5. Create knowledge files
6. Test workflow
7. Document usage

**4.1 File Structure**

Create directories:
```bash
mkdir -p .claude/commands
mkdir -p .claude/agents  # OR .claude/skills (based on design)
mkdir -p .claude/knowledge
mkdir -p [work-sessions]  # e.g., prd-sessions, query-sessions
```

Add to `.gitignore` (use template from `.claude/knowledge/file-templates/gitignore.template`):
```
[work-sessions]/
.claude/config.json
.env
*.log
```

**4.2 Permissions Configuration**

Create `.claude/config.json` using the template from `.claude/knowledge/file-templates/config.template.json`.
Replace `[PROJECT_PATH]` with the actual absolute path to the project directory.

This configuration reduces permission prompts within the project directory by allowing:
- Read, write, and edit operations on any files in the project (`**` pattern)
- Common safe bash commands (mkdir, mv, cp, ls, cat, tree, echo, find)
- Claude still requires permission for potentially dangerous operations (rm, git push --force, etc.)

**CRITICAL: Update `/setup` command** to capture how to recreate this local configuration:

Add to the `/setup` command instructions:
```markdown
### 6. Local Permissions Configuration

**Required**: Create `.claude/config.json` with project-specific permissions.

Run this command to create the file:
```bash
cat > .claude/config.json << 'EOF'
{
  "permissions": {
    "allow": [
      "Read(/full/path/to/project/**)",
      "Write(/full/path/to/project/**)",
      "Edit(/full/path/to/project/**)",
      "Glob(/full/path/to/project/**)",
      "Grep(/full/path/to/project/**)",
      "Bash(tree:*)",
      "Bash(mkdir:*)",
      "Bash(mv:*)",
      "Bash(cp:*)",
      "Bash(ls:*)",
      "Bash(cat:*)",
      "Bash(echo:*)",
      "Bash(find:*)"
    ]
  }
}
EOF
```

**Replace `/full/path/to/project` with your actual project path** (e.g., `/Users/yourname/projects/my-workflow`).

This file is `.gitignore`d and should NEVER be committed.
```

**Important**: The `.gitignore` template already includes `.claude/config.json` since it's a local configuration file that shouldn't be committed.

**Pattern for future iterations**: Whenever the user creates additional local settings (`.env` files, credentials, etc.), update the `/setup` command to document how to recreate them. Never commit explicit paths or secrets - always document in `/setup` instead.

**4.2.1 Create /setup Command**

Create `.claude/commands/setup.md` in the user's workflow project using:
- Template: `.claude/knowledge/file-templates/setup.template`
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

Create `.claude/commands/[workflow-name].md` using template from `.claude/knowledge/file-templates/command.template`.

Include:
- Brief description
- Usage instructions
- Phase breakdown with timing
- Error handling
- State management

**4.4 Research Implementation**

**If using agents** (prd_sidekick pattern):
- Create `.claude/agents/[agent-name].md` for each research source
- Each agent reads context, searches one source, writes findings

**If using skills** (data-knowledge pattern):
- Create `.claude/skills/[skill-name]/SKILL.md` for each reusable component
- Include YAML metadata: name, description, allowed-tools

**4.5 Knowledge Files**

Create `.claude/knowledge/[reference].md` for:
- Templates (content structure)
- Guidelines (quality criteria)
- Examples (what good looks like)

**4.6 Testing**

Test the workflow:
1. Run command with test data
2. Verify research phase completes
3. Check output format
4. Test error handling
5. Document any issues in `project-plan/IMPROVEMENTS.md`

**4.7 Documentation**

Create `README.md` using template from `.claude/knowledge/file-templates/README.template`:
- Features
- Prerequisites (MCPs needed)
- Installation steps
- Usage instructions
- Architecture overview

Create `CLAUDE.md` using template from `.claude/knowledge/file-templates/CLAUDE.template`:
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

Created by: agent-builder quick-start skill
Workflow: [workflow-name]
Use case: [brief description]

Files created:
- project-plan/ (interview notes, design, improvements)
- .claude/commands/[workflow-name].md
- .claude/[agents|skills]/ (research components)
- .claude/knowledge/ (reference materials)
- README.md (usage documentation)
- CLAUDE.md (project instructions)
- .gitignore (security patterns)

Next steps:
- Run workflow: /[workflow-name]
- Review findings: /review
- Save improvements: /save
"
```

## Final Summary

Show the user:
1. **How to run their workflow**: `/[workflow-name]`
2. **How to iterate**:
   - `/save` - Commit changes with context
   - `/review` - Get comprehensive recommendations
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
