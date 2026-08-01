---
name: security-checker
description: Scan for API keys, tokens, passwords, and other security issues. Validates .gitignore patterns and warns about hardcoded credentials.
allowed-tools: Read, Grep, Glob, Write, Edit
---

# Security Checker Skill

You are scanning for security issues in the workflow project.

**Reference files:**
- `.claude/knowledge/security-guidelines.md` - Security patterns and best practices

## Your Task

Find and report security vulnerabilities, especially:
1. Hardcoded secrets
2. Missing .gitignore patterns
3. Sensitive files tracked in git
4. Insecure configuration patterns

### Step 1: Scan for Hardcoded Secrets

Search all files for common secret patterns:

**API Keys and Tokens**:
- `api[_-]?key` (case insensitive)
- `token`
- `secret`
- `password`
- `passwd`
- `credentials`

**Specific Services**:
- `AKIA` (AWS access keys)
- `ghp_` (GitHub personal access tokens)
- `xox[baprs]-` (Slack tokens)
- `sk-` (OpenAI keys)
- `Bearer [A-Za-z0-9-._~+/]+=*` (Bearer tokens)

**Patterns to check**:
```bash
# Use Grep to search for patterns
grep -i "api[_-]?key" --output_mode=content
grep -i "token.*=.*['\"]" --output_mode=content
grep "AKIA[0-9A-Z]{16}" --output_mode=content
grep "ghp_[a-zA-Z0-9]{36}" --output_mode=content
```

**Exclude false positives**:
- Documentation mentioning "API key" generically
- Environment variable names (e.g., `API_KEY=` without value)
- Example placeholders (e.g., `your_api_key_here`)

### Step 2: Check .gitignore

Read `.gitignore` and verify it includes:
```
# Secrets
.env
.env.local
**/*.key
**/*.pem
**/credentials.json
**/secrets.json

# Local settings
.claude/settings.local.json

# Session data (workflow-specific)
[sessions-directory]/
```

If .gitignore is missing patterns, add to findings.

### Step 3: Check for Sensitive Files in Git

List files tracked by git:
```bash
git ls-files
```

Check if any sensitive files are tracked:
- `.env` files
- `credentials.json`
- `secrets.json`
- `.key` or `.pem` files
- `settings.local.json`

If found, these need to be removed from git history.

### Step 4: Check .env Usage

If project uses environment variables:

**Check for .env.example**:
- Does `.env.example` exist?
- Does it show required variables without values?

**Example good pattern**:
```
# .env.example
NOTION_API_KEY=
SLACK_TOKEN=
DATABASE_URL=
```

If missing, recommend creating it.

### Step 5: Check Configuration Files

Look for hardcoded credentials in:
- `.claude/settings.local.json`
- Config files (`.json`, `.yaml`, `.toml`)
- Python files (`config.py`)
- JavaScript files (`config.js`)

### Step 6: Report Findings

**If issues found** (PRIORITY: WARN IMMEDIATELY):

Show user right away:
```
⚠️  SECURITY ISSUES FOUND

Critical:
- [File]: [Line] - [Type of secret found]
- [File]: [Line] - [Type of secret found]

Recommendations:
1. Remove hardcoded secrets
2. Move to .env file
3. Add .env to .gitignore
4. Remove from git history if committed

Should I help fix these issues now?
```

Write to `project-plan/IMPROVEMENTS.md`:
```markdown
## Security Issues - [Date] - CRITICAL

### Hardcoded Secrets
- **File**: [path]
  **Line**: [number]
  **Issue**: [type of secret]
  **Fix**: Move to .env, add to .gitignore

### Missing .gitignore Patterns
- Missing: [pattern]
- Risk: [what could be exposed]
- Fix: Add to .gitignore

### Sensitive Files Tracked
- File: [path]
- Should be: In .gitignore, removed from git
- Fix: `git rm --cached [file]` and add to .gitignore
```

**If no issues found**:

Brief positive report:
```
✅ Security Check Passed

Checked:
- No hardcoded API keys or tokens found
- .gitignore includes proper patterns
- No sensitive files tracked in git
- Environment variable usage looks good
```

Still write brief note to IMPROVEMENTS.md:
```markdown
## Security Check - [Date]
✅ No security issues found

Checked:
- Hardcoded secrets: None
- .gitignore patterns: Good
- Sensitive files: None tracked
- Environment variables: Proper usage
```

## Fix Recommendations

When issues found, recommend specific fixes:

### For hardcoded secrets:
1. Create `.env` file with secrets
2. Update code to read from environment
3. Add `.env` to `.gitignore`
4. Create `.env.example` with placeholders
5. If committed to git: Remove from history

```bash
# Remove from git history
git filter-branch --force --index-filter \
  'git rm --cached --ignore-unmatch [file]' \
  --prune-empty --tag-name-filter cat -- --all
```

### For missing .gitignore patterns:
1. Add patterns to `.gitignore`
2. Check if files already tracked: `git ls-files | grep [pattern]`
3. If tracked: `git rm --cached [file]`

### For .env usage:
1. Create `.env.example`
2. Document required variables in README
3. Update CLAUDE.md with environment setup

## Autonomous Invocation

This skill can be invoked autonomously when:
- Files created/modified that might contain secrets
- New configuration files added
- User mentions API keys, tokens, credentials

**Trigger patterns**:
- Creating files with names: `config`, `credentials`, `secrets`, `.env`
- Modifying files with API calls or authentication
- User says "API key" or "token" in conversation

**When invoked autonomously**:
1. Run checks silently
2. If issues found: Warn immediately, block commit if possible
3. If clean: Continue without interrupting user

## Integration with Other Skills

**Called by**:
- `workflow-reviewer` skill during comprehensive review
- `create-agent` skill during initial setup
- Autonomously when security-sensitive files touched

**Works with**:
- `save-progress` skill: Block commits with security issues
- `software-best-practices` skill: Environment configuration

## Key Principles

1. **Be cautious but not paranoid**: Real issues vs false positives
2. **Warn immediately**: Don't wait for review to report critical issues
3. **Provide fixes**: Not just problems, but solutions
4. **Educate**: Explain why it's a problem
5. **Prevent commits**: Catch before secrets reach git

## False Positive Examples

**Don't flag these**:
- `"Set your API_KEY environment variable"` (documentation)
- `api_key = os.getenv("API_KEY")` (reading from env)
- `your_api_key_here` (placeholder)
- `example_token_abc123` (obvious example)
- `# TODO: Add API key` (comment)

**Do flag these**:
- `api_key = "sk-abc123..."` (hardcoded)
- `NOTION_TOKEN = "secret_xyz"` (hardcoded)
- Actual AWS keys, GitHub tokens, etc.
