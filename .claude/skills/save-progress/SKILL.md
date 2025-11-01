---
name: save-progress
description: Commit changes to git with detailed context from IMPROVEMENTS.md. Generates meaningful commit messages, cleans up completed items, and updates documentation.
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# Save Progress Skill

You are saving the user's workflow improvements to git with proper context.

## Your Task

Create a git commit that captures:
- What changed
- Why it changed
- Context from IMPROVEMENTS.md
- Any learnings or discoveries

### Step 1: Check Git

Check if git is initialized:
```bash
git status
```

If not initialized, offer to initialize:
- "I notice git isn't initialized. Would you like me to set it up?"
- If yes: `git init`

### Step 2: Read IMPROVEMENTS.md

Read `project-plan/IMPROVEMENTS.md` to understand:
- What improvements were made
- Why they were needed
- What was tried
- What worked

If IMPROVEMENTS.md doesn't exist, create it first with a note about what changed.

### Step 3: Stage Changes

Stage all changes:
```bash
git add .
```

### Step 4: Generate Commit Message

Create a detailed commit message using this format:

```
[Type]: Brief description

Detailed changes:
- Change 1 from IMPROVEMENTS.md
- Change 2 from IMPROVEMENTS.md
- Change 3 from IMPROVEMENTS.md

Context:
- Why this was needed
- What was tried (if relevant)
- What worked / what didn't

References: IMPROVEMENTS.md
```

**Types**:
- `feat`: New feature or capability
- `fix`: Bug fix or correction
- `refactor`: Code restructuring
- `docs`: Documentation changes
- `test`: Test additions or changes
- `chore`: Maintenance tasks

**Examples**:

```
feat: Add parallel research to Notion and Slack

Detailed changes:
- Split research into two agents (notion-researcher, slack-researcher)
- Modified main workflow to launch agents in parallel
- Reduced research phase from 60s to 20s

Context:
- Research phase was the main bottleneck
- Tried sequential optimization first, but parallel was more effective
- Both sources are independent, so parallelization is safe

References: IMPROVEMENTS.md - "Parallelize research phase"
```

```
fix: Handle Notion write errors gracefully

Detailed changes:
- Add retry logic for Notion writes (3 attempts)
- Use insert_content_after instead of replace_content
- Add error logging to session directory

Context:
- Workflow was failing on Notion writes
- Tried replace_content pattern first, but insert_content_after is more reliable
- Added retry logic to handle transient API errors

References: IMPROVEMENTS.md - "Notion write pattern doesn't work"
```

### Step 5: Commit

Use a HEREDOC to ensure proper formatting:

```bash
git commit -m "$(cat <<'EOF'
[Your commit message here with proper formatting]
EOF
)"
```

### Step 6: Clean IMPROVEMENTS.md

Update `project-plan/IMPROVEMENTS.md`:
- Remove completed items that were committed
- Keep in-progress items
- Keep future items
- Add a note about what was completed

Example update:
```markdown
## Completed - [Date]
- ✅ [Item that was just completed]

## In Progress
- [Current work]

## Future Enhancements
- [Planned improvements]
```

### Step 7: Update Documentation (if needed)

Check if README.md or CLAUDE.md need updates based on changes:
- New commands/skills added?
- New MCPs required?
- Usage changed?
- New error handling patterns?

If updates needed, make them now.

### Step 8: Show Summary

Show the user what was committed:
```
✅ Changes committed successfully

Committed:
- [File 1]
- [File 2]
- [File 3]

Commit message:
[Brief version of commit message]

Cleaned from IMPROVEMENTS.md:
- [Completed item 1]
- [Completed item 2]

Updated documentation:
- [Doc that was updated, if any]
```

### Step 9: Offer Review

"Would you like me to run `/review` to analyze the workflow and suggest more improvements?"

## Error Handling

**If git commit fails**:
- Show the error
- Check if it's a common issue (no files to commit, merge conflict, etc.)
- Suggest fix

**If IMPROVEMENTS.md is empty**:
- Don't fail, just commit with a generic message
- Suggest: "Consider adding notes to IMPROVEMENTS.md before saving next time. It helps create better commit messages!"

**If no changes to commit**:
- Let the user know: "No changes to commit. Everything is up to date."
- Don't create an empty commit

## Best Practices

1. **Meaningful messages**: Explain the "why", not just the "what"
2. **Clean history**: Each commit should represent a logical unit of work
3. **Context preservation**: Future you (or future Claude) needs to understand what happened
4. **Documentation sync**: Keep docs in sync with code
5. **Completed vs planned**: Clear separation in IMPROVEMENTS.md

## Integration with Self-Improvement Loop

This skill is called:
1. **Manually** by user via `/save` command
2. **Autonomously** by Claude after completing improvements:
   - User asks for improvement
   - Claude updates IMPROVEMENTS.md
   - Claude does the work
   - Claude tests changes
   - Claude asks if user wants to save
   - If yes, invoke this skill
3. **After fixes** when Claude struggles then succeeds:
   - Claude encounters error
   - Claude tries workarounds
   - Claude finds solution
   - Claude updates IMPROVEMENTS.md
   - Claude asks if user wants to save the fix
   - If yes, invoke this skill

The skill enables both loops to persist their learnings.
