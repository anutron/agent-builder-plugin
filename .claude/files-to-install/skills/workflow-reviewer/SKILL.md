---
name: workflow-reviewer
description: Comprehensive workflow analysis to identify improvements, security issues, conflicts, and simplification opportunities. Shows recommendations to user for selection.
allowed-tools: Task, Read, Write, Edit, Glob, Grep
---

# Workflow Reviewer Skill

You are analyzing a workflow project to find improvement opportunities.

**Reference files (from plugin):**

The agent-builder plugin lives under `~/.claude/plugins/marketplaces/`, but the marketplace directory name depends on how the user added the marketplace. Resolve the plugin's knowledge directory dynamically rather than assuming a fixed name:

```bash
KNOWLEDGE_DIR=$(ls -d ~/.claude/plugins/marketplaces/*agent-builder*/.claude/knowledge 2>/dev/null | head -1)
```

Then read these files from `$KNOWLEDGE_DIR`:
- `workflow-patterns.md` - Best practices from successful projects
- `security-guidelines.md` - Security patterns to check
- `component-decision-guide.md` - Architecture guidance

## Your Task

Analyze the workflow comprehensively using parallel agents, show findings to user, and write selected recommendations to `project-plan/IMPROVEMENTS.md`.

## Process

### Step 0: Check for Previously Ignored Findings and Define Exclusions

Before launching agents:

**1. Load ignored findings**:
1. **Try to read** `project-plan/REVIEW-IGNORED.md`
2. **If file exists**: Parse the ignored items and remember them
   - Each ignored item has: description snippet, location, category
   - Create a list of identifiers to filter out later
3. **If file doesn't exist**: No ignored items yet, proceed normally

**2. Define excluded paths** (files installed by agent-builder plugin):
Agents should NOT review these files as they're maintained by the plugin:
- `.claude/commands/review-workflow.md`
- `.claude/commands/save-workflow.md`
- `.claude/skills/workflow-reviewer/*`
- `.claude/skills/save-progress/*`
- `.claude/skills/security-checker/*`
- `.claude/skills/software-best-practices/*`
- `.claude/agents/review-*.md` (all 5 review agents)
- `.claude/knowledge/templates/*` (templates from plugin)

**Everything else SHOULD be reviewed** - this is just a blacklist, not a whitelist. Review all other files in the project.

Pass these exclusions to all review agents.

### Step 1: Launch Parallel Review Agents

Launch these 5 agents simultaneously using the Task tool. **Include the excluded paths in each agent's prompt** so they know which files to skip.

**Agent 1: Duplication and Simplification**
- Subagent: `review-duplication-simplification`
- Analyzes: Repeated logic, over-engineering, unnecessary complexity
- Exclude: Agent-builder plugin files (listed in Step 0)

**Agent 2: Conflicts and Setup Drift**
- Subagent: `review-conflicts-setup`
- Analyzes: Documentation conflicts, setup command accuracy
- Exclude: Agent-builder plugin files (listed in Step 0)

**Agent 3: Security Analysis**
- Subagent: `review-security`
- Invokes: `security-checker` skill
- Analyzes: Credentials, secrets, .gitignore patterns
- Exclude: Agent-builder plugin files (listed in Step 0)

**Agent 4: Best Practices**
- Subagent: `review-best-practices`
- Invokes: `software-best-practices` skill if code exists
- Analyzes: Code quality, workflow architecture, parallelization opportunities
- Exclude: Agent-builder plugin files (listed in Step 0)

**Agent 5: Goal Drift Detection**
- Subagent: `review-goal-drift`
- Analyzes: Over-engineered solutions, scope creep
- Exclude: Agent-builder plugin files (listed in Step 0)

**IMPORTANT**:
- Launch all 5 agents in a single message using multiple Task tool calls
- Pass the exclusion list to each agent in their prompt

### Step 2: Aggregate and Filter Findings

Once all agents complete:

1. **Collect all findings** from agent reports
2. **Filter out ignored items**: Remove any findings that match items in REVIEW-IGNORED.md
   - Match by location (file:line) OR description similarity
   - If unsure, keep the finding (better to show than hide)
3. **Organize by priority**:
   - **Critical**: Security issues, blocking bugs
   - **High**: Significant time savings, setup drift, major improvements
   - **Medium**: Nice-to-haves, polish, minor simplifications
   - **Low**: Future considerations

4. **Deduplicate**: If multiple agents found same issue, merge into one finding

5. **Number the findings**: Assign each finding a unique number for easy reference

6. **Format for user review**:
```markdown
# Workflow Review Findings - [Date]

## Critical Priority
### [Finding 1 Title]
- **Issue**: [Description]
- **Location**: [file:line]
- **Recommendation**: [What to do]
- **Impact**: [Why it matters]
- **Source**: [Which agent found this]

[Repeat for each critical finding]

## High Priority
[Same format]

## Medium Priority
[Same format]

## Low Priority
[Same format]

## Summary
- Total findings: [count]
- Critical: [count]
- High: [count]
- Medium: [count]
- Low: [count]
```

### Step 3: Show Findings and Offer Interactive Review

**Present the organized findings to the user** with this message:

```
I've completed the workflow review using 5 parallel analysis agents. Here are the findings:

[Show the formatted findings from Step 2]

---

Would you like to:
1. Review each finding interactively (I'll ask about each one)
2. Select specific items by number to add to IMPROVEMENTS.md
3. Add all critical/high priority items
4. Skip (no changes)

What would you prefer?
```

**If user chooses option 1 (interactive review)**:
- Go through each finding one by one
- For each finding, ask: "Add to IMPROVEMENTS.md? (yes/no/skip)"
  - **yes**: Mark for addition to IMPROVEMENTS.md
  - **no**: Mark for addition to REVIEW-IGNORED.md (won't show in future reviews)
  - **skip**: Don't add anywhere (will show again in future reviews)
- Keep track of user decisions for all findings

**If user chooses option 2, 3, or 4**:
- Process their selection as before (current behavior)

### Step 4: Write Selected and Ignored Findings

Based on user's decisions:

**For findings marked "yes" (add to IMPROVEMENTS.md)**:

1. **Read existing** `project-plan/IMPROVEMENTS.md`
2. **Append selected findings** with timestamp
3. **Preserve existing** IMPROVEMENTS.md content
4. **Format**:
```markdown
## Review Findings - [Date]

[Selected findings in priority order]

### Proposed Action Plan
1. [First step based on priorities]
2. [Second step]
3. [Third step]

---

[Existing IMPROVEMENTS.md content below]
```

**For findings marked "no" (ignore in future reviews)**:

1. **Read or create** `project-plan/REVIEW-IGNORED.md`
2. **Append ignored findings** with timestamp
3. **Format**:
```markdown
# Review Findings - Marked as Won't Fix

These items were reviewed and explicitly marked as "won't fix". They won't appear in future reviews.
To reconsider an item, remove it from this list.

## [Date] - Review Session

### Finding: [Short description]
- **Category**: [Duplication/Security/Best Practices/etc.]
- **Location**: [file:line]
- **Issue**: [Full description]
- **Ignored on**: [Date]

[Repeat for each ignored finding]

---

[Existing ignored findings below]
```

**Summary message**:
```
✅ Review complete!

Added to IMPROVEMENTS.md: [count] findings
Marked as won't-fix: [count] findings
Skipped for later: [count] findings

IMPROVEMENTS.md and REVIEW-IGNORED.md updated.
```

**If user selects none**: Just thank them and exit. No file writes needed.

## Important Notes

### Parallel Execution
- **Always launch all 5 agents in parallel** (single message, multiple Task calls)
- Don't wait for one to finish before launching next
- Total review time should be ~30-40 seconds, not 2-3 minutes

### User Choice
- **Never auto-write to IMPROVEMENTS.md without user selection**
- User may want to see analysis without tracking everything
- Some findings may not be relevant to user's goals
- User knows their priorities better than we do

### Finding Quality
- Be specific about locations (file:line format)
- Provide actionable recommendations
- Explain impact (why it matters)
- Don't nitpick - focus on meaningful improvements

### If No Issues Found
If all agents report no issues, tell the user:
```
Great news! The workflow review found no significant issues:

✅ No duplication or over-engineering
✅ No conflicts or setup drift
✅ No security issues
✅ Follows best practices
✅ No goal drift detected

The workflow is in good shape. No changes needed in IMPROVEMENTS.md.
```

## Example User Interaction

```
User: /review
Assistant: Running comprehensive workflow review with 5 parallel agents...

[Agents complete in 35 seconds]

Assistant: Review complete\! Here are the findings:

## High Priority
### Parallelization: Research could be concurrent
- Duplication agent found sequential research operations
- Recommendation: Use parallel agents for notion + slack research
- Impact: Reduce time from 60s to 30s

## Medium Priority
### Simplification: Session state over-engineered
- Goal drift agent found complex JSON state management
- Recommendation: Simplify to phase.txt file
- Impact: Easier to maintain

---

Which recommendations would you like to track in IMPROVEMENTS.md?

User: Just the high priority one

Assistant: [Writes high priority finding to IMPROVEMENTS.md]

Done\! Added 1 finding to IMPROVEMENTS.md.
```
