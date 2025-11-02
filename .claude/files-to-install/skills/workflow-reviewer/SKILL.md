---
name: workflow-reviewer
description: Comprehensive workflow analysis to identify improvements, security issues, conflicts, and simplification opportunities. Shows recommendations to user for selection.
allowed-tools: Task, Read, Write, Edit, Glob, Grep
---

# Workflow Reviewer Skill

You are analyzing a workflow project to find improvement opportunities.

**Reference files (from plugin):**
- `~/.claude/plugins/marketplaces/thanx-agent-builder/.claude/knowledge/workflow-patterns.md` - Best practices from successful projects
- `~/.claude/plugins/marketplaces/thanx-agent-builder/.claude/knowledge/security-guidelines.md` - Security patterns to check
- `~/.claude/plugins/marketplaces/thanx-agent-builder/.claude/knowledge/component-decision-guide.md` - Architecture guidance

## Your Task

Analyze the workflow comprehensively using parallel agents, show findings to user, and write selected recommendations to `project-plan/IMPROVEMENTS.md`.

## Process

### Step 1: Launch Parallel Review Agents

Launch these 5 agents simultaneously using the Task tool:

**Agent 1: Duplication and Simplification**
- Subagent: `review-duplication-simplification`
- Analyzes: Repeated logic, over-engineering, unnecessary complexity

**Agent 2: Conflicts and Setup Drift**
- Subagent: `review-conflicts-setup`
- Analyzes: Documentation conflicts, setup command accuracy

**Agent 3: Security Analysis**
- Subagent: `review-security`
- Invokes: `security-checker` skill
- Analyzes: Credentials, secrets, .gitignore patterns

**Agent 4: Best Practices**
- Subagent: `review-best-practices`
- Invokes: `software-best-practices` skill if code exists
- Analyzes: Code quality, workflow architecture, parallelization opportunities

**Agent 5: Goal Drift Detection**
- Subagent: `review-goal-drift`
- Analyzes: Over-engineered solutions, scope creep

**IMPORTANT**: Launch all 5 agents in a single message using multiple Task tool calls.

### Step 2: Aggregate Findings

Once all agents complete:

1. **Collect all findings** from agent reports
2. **Organize by priority**:
   - **Critical**: Security issues, blocking bugs
   - **High**: Significant time savings, setup drift, major improvements
   - **Medium**: Nice-to-haves, polish, minor simplifications
   - **Low**: Future considerations

3. **Deduplicate**: If multiple agents found same issue, merge into one finding

4. **Format for user review**:
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

### Step 3: Show Findings to User

**Present the organized findings to the user** with this message:

```
I've completed the workflow review using 5 parallel analysis agents. Here are the findings:

[Show the formatted findings from Step 2]

---

Which of these recommendations would you like to track in IMPROVEMENTS.md?

You can select:
- All critical and high priority items
- Specific items by number
- All items
- None (just wanted to see the analysis)

Let me know which findings to save.
```

### Step 4: Write Selected Findings

Based on user's selection:

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

**If user selects none**: Just thank them and exit. No file write needed.

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
