# Security Guidelines for Workflow Projects

## Core Principle
**Never commit secrets to git**. Once a secret is in git history, assume it's compromised.

## Common Secrets to Protect

### API Keys and Tokens
- Notion API keys (`secret_...`)
- Slack tokens (`xoxb-...`, `xoxp-...`)
- GitHub personal access tokens (`ghp_...`)
- OpenAI API keys (`sk-...`)
- AWS access keys (`AKIA...`)
- Database passwords
- OAuth tokens
- Webhook secrets

### Configuration Files
- `.env` files
- `credentials.json`
- `secrets.json`
- `.key` or `.pem` files
- `config.json` with sensitive data

### Local Settings
- `.claude/settings.local.json` (contains MCP tokens)
- IDE settings with credentials
- Local database files

## .gitignore Patterns

### Minimal Required .gitignore
```gitignore
# Secrets (NEVER commit these)
.env
.env.local
.env.*.local
**/*.key
**/*.pem
**/credentials.json
**/secrets.json
**/secrets.yaml

# Local settings
.claude/settings.local.json

# Session data (workflow-specific)
# Add your session directories here
# Example: prd-sessions/
# Example: query-sessions/

# System files
.DS_Store
*.swp
*.swo
Thumbs.db
```

### Extended .gitignore (Recommended)
Add these for specific languages/frameworks:

**Python**:
```gitignore
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
venv/
env/
ENV/
.venv
```

**Node.js**:
```gitignore
node_modules/
npm-debug.log
yarn-error.log
.npm
.yarn
```

**Databases**:
```gitignore
*.db
*.sqlite
*.sqlite3
```

## Environment Variable Best Practices

### Structure
```bash
# .env (GITIGNORED)
NOTION_API_KEY=secret_abc123...
SLACK_TOKEN=xoxb-xyz789...
DATABASE_URL=postgresql://user:pass@localhost/db
```

### Template
```bash
# .env.example (COMMITTED)
# Copy this to .env and fill in your values

# Notion integration
NOTION_API_KEY=

# Slack workspace
SLACK_TOKEN=

# Database connection
DATABASE_URL=
```

### Loading in Code

**Python**:
```python
import os
from dotenv import load_dotenv

load_dotenv()

notion_key = os.getenv("NOTION_API_KEY")
if not notion_key:
    raise ValueError("NOTION_API_KEY not found in environment")
```

**JavaScript**:
```javascript
require('dotenv').config();

const notionKey = process.env.NOTION_API_KEY;
if (!notionKey) {
    throw new Error("NOTION_API_KEY not found in environment");
}
```

## Common Mistakes

### ❌ Hardcoded in Code
```python
# DON'T DO THIS
api_key = "secret_abc123..."
```

### ✅ Environment Variable
```python
# DO THIS
api_key = os.getenv("API_KEY")
```

### ❌ Config File Committed
```json
// config.json (COMMITTED TO GIT)
{
  "api_key": "secret_abc123..."
}
```

### ✅ Config Structure Only
```json
// config.json (COMMITTED)
{
  "api_key_env": "NOTION_API_KEY"
}
```

### ❌ Comments with Secrets
```python
# My API key is: secret_abc123...
# TODO: Replace with: xoxb-real-token
```

### ✅ Generic Comments
```python
# Load API key from environment
# See .env.example for required variables
```

## MCP-Specific Security

### Settings File Location
`.claude/settings.local.json` should ALWAYS be gitignored:

```json
{
  "permissions": {
    "allow": ["mcp__notion__*:*"]
  },
  "mcpServers": {
    "notion": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-notion"],
      "env": {
        "NOTION_API_KEY": "secret_abc123..."
      }
    }
  }
}
```

**Why gitignore**: Contains API keys in `env` section

### User-Specific Settings
Different developers use different tokens. Settings must be local.

## Detecting Secrets in Files

### Patterns to Flag
- `api[_-]?key\s*[:=]\s*["']?[A-Za-z0-9_-]{20,}` (API keys)
- `token\s*[:=]\s*["']?[A-Za-z0-9_-]{20,}` (Tokens)
- `secret\s*[:=]\s*["']?[A-Za-z0-9_-]{20,}` (Secrets)
- `password\s*[:=]\s*["']?[A-Za-z0-9_-]{8,}` (Passwords)
- `AKIA[0-9A-Z]{16}` (AWS access keys)
- `ghp_[a-zA-Z0-9]{36}` (GitHub tokens)
- `xox[baprs]-[a-zA-Z0-9-]+` (Slack tokens)
- `sk-[a-zA-Z0-9]{48}` (OpenAI keys)

### False Positives to Ignore
- `api_key = os.getenv("API_KEY")` (reading from env)
- `"your_api_key_here"` (placeholder)
- `# Set your API_KEY` (documentation)
- `example_token_abc123` (obvious example)

## Cleaning Up Committed Secrets

If you accidentally committed a secret:

### 1. Revoke the Secret Immediately
Go to the service and revoke/regenerate the token/key

### 2. Remove from Git History
```bash
# Remove specific file from all history
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch path/to/secret/file" \
  --prune-empty --tag-name-filter cat -- --all

# Force push (WARNING: Coordinate with team)
git push origin --force --all
git push origin --force --tags
```

### 3. Tell Team Members
If this is a shared repo, teammates need to:
```bash
git fetch origin
git reset --hard origin/main
```

### 4. Update .gitignore
Add pattern to prevent future commits

## Security Checklist

Before each commit:
- [ ] No secrets in code
- [ ] .env in .gitignore
- [ ] .env.example has no values
- [ ] settings.local.json in .gitignore
- [ ] No credentials.json committed
- [ ] README documents required env vars
- [ ] Sensitive session data in .gitignore

## Tools to Help

### Pre-commit Hooks
Add to `.git/hooks/pre-commit`:
```bash
#!/bin/bash
# Check for common secret patterns

if git diff --cached | grep -E "api[_-]?key\s*[:=]\s*['\"][^'\"]{20,}"; then
    echo "ERROR: API key detected in staged changes"
    exit 1
fi

# Check if .env is staged
if git diff --cached --name-only | grep "^\.env$"; then
    echo "ERROR: .env file should not be committed"
    exit 1
fi
```

### git-secrets
Install and configure git-secrets:
```bash
brew install git-secrets
git secrets --install
git secrets --register-aws
```

## When User Needs to Share Credentials

### For Development
Use a secrets management system:
- 1Password Teams
- AWS Secrets Manager
- HashiCorp Vault

### For Documentation
Provide setup instructions:
```markdown
## Setup

1. Create `.env` from template:
   ```bash
   cp .env.example .env
   ```

2. Get credentials:
   - Notion: https://www.notion.so/my-integrations
   - Slack: https://api.slack.com/apps
   - GitHub: https://github.com/settings/tokens

3. Fill in .env with your tokens
```

## Key Principles

1. **Never commit secrets** - Once in git, assume compromised
2. **Use .env files** - Keep secrets out of code
3. **Provide .env.example** - Document required variables
4. **Revoke immediately** - If secret leaked, revoke before cleaning history
5. **Educate team** - Make security part of workflow

## Additional Resources

- [GitHub: Removing sensitive data](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository)
- [git-secrets tool](https://github.com/awslabs/git-secrets)
- [12-factor app: Config](https://12factor.net/config)
