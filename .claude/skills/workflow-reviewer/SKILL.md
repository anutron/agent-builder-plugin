---
name: workflow-reviewer
description: Comprehensive workflow analysis to identify improvements, security issues, conflicts, and simplification opportunities. Writes actionable recommendations to IMPROVEMENTS.md.
allowed-tools: Read, Write, Edit, Glob, Grep
---

# Workflow Reviewer Skill

You are analyzing a workflow project to find improvement opportunities.

**Reference files:**
- `.claude/knowledge/workflow-patterns.md` - Best practices from successful projects
- `.claude/knowledge/security-guidelines.md` - Security patterns to check

## Your Task

Analyze the workflow comprehensively and write findings to `project-plan/IMPROVEMENTS.md`.

### Step 1: Understand the Workflow

Read key files to understand what this workflow does:
1. `README.md` - What is this workflow for?
2. `CLAUDE.md` - What are the project rules?
3. `.claude/commands/*.md` - What are the user-facing workflows?
4. `.claude/skills/*/SKILL.md` OR `.claude/agents/*.md` - What components exist?
5. `.claude/knowledge/*.md` - What reference materials are used?
6. `project-plan/project-design.md` - What was the original design?

### Step 2: Analyze for Improvements

Look for these opportunities (LLM decides what to examine in depth):

#### 2.1 Duplication Opportunities
- Same logic in multiple places?
- Could shared logic become a skill?
- Repeated patterns that should be in knowledge files?
- Similar agent prompts that could be templated?

**Example finding**:
```markdown
### Duplication: Research patterns repeated across agents
- Both notion-researcher and slack-researcher have identical retry logic
- **Recommendation**: Extract retry logic into a reusable skill
- **Impact**: Easier maintenance, consistency across agents
```

#### 2.2 Better Use of Features
- Could serial operations be parallel?
- Should agents be skills or vice versa?
- Missing opportunities for Task tool parallelization?
- Knowledge files vs inline instructions?

**Example finding**:
```markdown
### Parallelization: Generation could be concurrent
- Currently generating 3 sections sequentially (90s)
- Sections are independent and could run in parallel
- **Recommendation**: Use Task tool to launch 3 section-writer agents concurrently
- **Impact**: Reduce generation time from 90s to 30s
```

#### 2.3 Conflicts and Contradictions
- Do files contradict each other?
- Does CLAUDE.md conflict with command instructions?
- Are there inconsistent patterns?
- Outdated documentation?

**Example finding**:
```markdown
### Conflict: CLAUDE.md vs actual workflow
- CLAUDE.md says "always use replace_content"
- But workflow uses insert_content_after (which works)
- **Recommendation**: Update CLAUDE.md to match working pattern
```

#### 2.4 Security Issues
Invoke `security-checker` skill for detailed security analysis.

Check for:
- API keys or secrets in code
- Sensitive files not in .gitignore
- Missing .env.example
- Hardcoded credentials

**Example finding**:
```markdown
### Security: API key in workflow file
- Found hardcoded API key in .claude/commands/query.md
- Not in .gitignore patterns
- **Recommendation**: Move to .env file, add .env to .gitignore
- **Priority**: HIGH - Fix before next commit
```

#### 2.5 Best Practice Violations
Invoke `software-best-practices` skill if code files exist.

Check for:
- Missing tests
- No linting setup
- Missing run script
- Poor error handling
- No progress visibility

**Example finding**:
```markdown
### Best Practice: Missing tests
- query-validator skill has no tests
- Complex logic that could break
- **Recommendation**: Add unit tests for query validation
- **Impact**: Catch regressions early
```

#### 2.6 Simplification Opportunities
- Overly complex logic?
- Unnecessary abstractions?
- Could simpler approach work?
- Unused features or files?

**Example finding**:
```markdown
### Simplification: Session management is over-engineered
- Current approach uses JSON state files with complex schema
- Only tracking phase number and status
- **Recommendation**: Simplify to just phase.txt with current phase
- **Impact**: Easier to understand and maintain
```

#### 2.7 Setup Command Drift
- Does `/setup` document all required MCPs?
- Are new environment variables documented in `/setup`?
- Are new local config files explained in `/setup`?
- Does `/setup` match current workflow requirements?

**When to check**:
- Workflow uses MCP tools not listed in `/setup` MCP list
- .env files exist but not documented in `/setup`
- New local config files created but not in `/setup`
- Directory structure changed but `/setup` still checks old dirs

**Example finding**:
```markdown
### Setup Drift: New Jira MCP not documented
- Workflow now calls Jira MCP tools (added in v2)
- `/setup` command doesn't check for Jira availability
- New users will get runtime errors instead of setup validation
- **Recommendation**: Add jira to [MCP_LIST] in `.claude/commands/setup.md`
- **Impact**: Better onboarding experience, catches missing MCPs early
```

### Step 3: Prioritize Findings

Organize findings by priority:
1. **Critical**: Security issues, blocking bugs
2. **High**: Significant time savings, major improvements
3. **Medium**: Nice-to-haves, polish
4. **Low**: Future considerations

### Step 4: Write to IMPROVEMENTS.md

Read existing `project-plan/IMPROVEMENTS.md` and add findings:

```markdown
## Review Findings - [Date]

### Critical Priority
- [Finding with recommendation]

### High Priority
- [Finding with recommendation]

### Medium Priority
- [Finding with recommendation]

### Low Priority
- [Finding with recommendation]

### Proposed Action Plan
1. [Step 1 - what to do first]
2. [Step 2 - what to do next]
3. [Step 3 - etc]

Estimated time: [X hours]
Expected impact: [What will improve]
```

### Step 5: Present Findings

Show the user:
1. Summary of what you found
2. Prioritized list (focus on high-impact items)
3. Proposed action plan
4. Estimated time and impact

**Example**:
```
📊 Workflow Review Complete

Found 8 improvement opportunities:
- 2 high priority (70% time savings potential)
- 4 medium priority (code quality improvements)
- 2 low priority (future enhancements)

Top recommendations:
1. Parallelize research phase → 40s time savings
2. Extract retry logic to skill → easier maintenance
3. Update CLAUDE.md → fix contradictions

Full details in: project-plan/IMPROVEMENTS.md

Would you like me to:
1. Start implementing these improvements?
2. Focus on just the high-priority items?
3. Let you review first?
```

### Step 6: Offer to Implement

If user agrees:
1. Create project plan from IMPROVEMENTS.md
2. Start with highest priority items
3. Test after each change
4. Use `/save` to commit when ready

## What to Review (LLM Decision)

You decide what areas to examine based on:
- Project size and complexity
- Time since last review
- What's changed recently (check git log)
- What user is struggling with

Don't review everything every time. Focus on high-value analysis.

## Good Review Characteristics

✅ **Specific**: "Line 45 has retry logic" not "retries are scattered"
✅ **Actionable**: Concrete recommendation, not just observation
✅ **Prioritized**: High-impact first
✅ **Realistic**: Achievable improvements, not rewrites
✅ **Explained**: Why this matters, what the benefit is

❌ **Vague**: "Code could be better"
❌ **Overwhelming**: 50 items to fix
❌ **Obvious**: "You could add comments"
❌ **Theoretical**: "Rewrite in Rust for performance"

## Error Handling

**If no workflow files exist**:
- "No workflow files found. Have you run `/quick-start` yet?"

**If IMPROVEMENTS.md doesn't exist**:
- Create it with findings

**If nothing significant found**:
- Still write a brief review noting things look good
- Suggest possible future enhancements
- Don't invent problems that don't exist

## Integration with Improvement Loops

This skill feeds both loops:

**User-initiated improvements**:
- User runs `/review`
- LLM finds opportunities
- User chooses what to fix
- Use `/save` when done

**LLM-initiated improvements**:
- After `/save`, offer `/review`
- Surface issues LLM noticed during execution
- Propose fixes based on recent struggles

## Examples from Real Projects

### From prd_sidekick:
```markdown
### High Priority: Parallelize Notion and Slack research
- Currently runs sequentially (2+ minutes total)
- Both sources are independent
- Recommendation: Launch as parallel agents via Task tool
- Expected: Significant time savings from parallel execution
```

### From data-knowledge:
```markdown
### Medium Priority: Extract validation logic to skill
- Validation code duplicated in 3 commands
- Should be single query-validator skill
- Benefits: Consistent validation, easier to improve
```

## Key Principles

1. **Be helpful, not pedantic**: Focus on real improvements
2. **Prioritize impact**: Time savings and bug prevention matter most
3. **Be specific**: Point to exact files and lines
4. **Explain tradeoffs**: Why this recommendation makes sense
5. **Respect the user**: Their workflow, their decisions
