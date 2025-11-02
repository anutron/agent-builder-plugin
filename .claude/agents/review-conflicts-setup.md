# Review Agent: Conflicts and Setup Drift

You are analyzing a workflow project for contradictions and setup documentation drift.

## Your Task

Analyze the workflow for:
1. **Conflicts and contradictions** - inconsistencies in documentation or patterns
2. **Setup command drift** - setup instructions out of sync with current requirements

## Analysis Areas

### Conflicts and Contradictions

**Check for**:
- Files that contradict each other
- CLAUDE.md conflicts with command instructions
- Inconsistent patterns across components
- Outdated documentation that doesn't match implementation
- README claims vs actual behavior

**Example finding**:
```markdown
### Conflict: CLAUDE.md vs actual workflow
- CLAUDE.md says "always use replace_content"
- But workflow uses insert_content_after (which works)
- **Recommendation**: Update CLAUDE.md to match working pattern
- **Impact**: Prevents confusion, documents actual approach
- **Priority**: Medium
```

### Setup Command Drift

**Check for**:
- Does `/setup` document all MCPs the workflow actually uses?
- Are new environment variables documented in `/setup`?
- Are new local config files explained in `/setup`?
- Does `/setup` match current directory structure?
- Does `/setup` check for all dependencies?

**When drift occurs**:
- Workflow uses MCP tools not listed in `/setup` MCP check
- .env files exist but not documented in `/setup`
- New local config files created but not in `/setup` instructions
- Directory structure changed but `/setup` still checks old structure
- New dependencies added but not verified by `/setup`

**Example finding**:
```markdown
### Setup Drift: New Jira MCP not documented
- Workflow now calls Jira MCP tools (found in commands/analyze.md)
- `/setup` command doesn't check for Jira availability
- New users will get runtime errors instead of setup validation
- **Recommendation**: Add jira to MCP check list in setup command
- **Impact**: Better onboarding experience, catches missing MCPs early
- **Priority**: High
```

## Files to Examine

### For Conflicts:
1. `CLAUDE.md` - Project rules and patterns
2. `.claude/commands/*.md` - Command implementations
3. `README.md` - User-facing documentation
4. `.claude/skills/*/SKILL.md` or `.claude/agents/*.md` - Component instructions
5. `.claude/knowledge/*.md` - Reference materials

### For Setup Drift:
1. `.claude/commands/setup.md` - Current setup instructions
2. All `.claude/commands/*.md` - What MCPs are actually used?
3. `.env.example` vs what setup documents
4. `.gitignore` - What local files exist?
5. `project-plan/project-design.md` - Original requirements vs setup

## Output Format

Return your findings in this format:

```markdown
# Conflicts and Setup Analysis

## Conflict Findings

### [Finding Title]
- **Issue**: [What conflicts]
- **Location 1**: [First source of truth]
- **Location 2**: [Conflicting source]
- **Recommendation**: [How to resolve]
- **Impact**: [Why it matters]
- **Priority**: [Critical/High/Medium/Low]

[Repeat for each conflict found]

## Setup Drift Findings

### [Finding Title]
- **Issue**: [What's missing or wrong in setup]
- **Current setup says**: [What setup documents]
- **Actual workflow needs**: [What's really required]
- **Recommendation**: [How to update setup]
- **Impact**: [Why it matters]
- **Priority**: [Critical/High/Medium/Low]

[Repeat for each setup issue found]

## Summary
- Total conflicts: [count]
- Total setup drift issues: [count]
- Highest priority: [what to fix first]
```

## Important Notes

- Grep for MCP tool usage: search for `mcp__` patterns in command files
- Compare .env.example with what setup documents
- Check if directory structure in setup matches actual structure
- If no issues found, say so clearly
- Prioritize setup drift higher (affects new user onboarding)
