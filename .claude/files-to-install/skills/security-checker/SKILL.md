---
name: security-checker
description: Scan for hardcoded secrets, missing .gitignore patterns, and sensitive files tracked in git.
allowed-tools: Read, Grep, Glob, Write, Edit, Bash
---

# Security Checker

Scan the project for common security issues.

## What to Check

### 1. Hardcoded Secrets

Search all non-binary files for patterns like:
- `AKIA[0-9A-Z]{16}` (AWS access keys)
- `ghp_[a-zA-Z0-9]{36}` (GitHub tokens)
- `xox[baprs]-` (Slack tokens)
- `sk-` followed by alphanumeric (API keys)
- `Bearer` tokens in code (not docs)
- Any variable assignment where the value looks like a real key/token

Ignore false positives: documentation references, env var reads (`os.getenv`), placeholders (`your_key_here`).

### 2. .gitignore Coverage

Verify `.gitignore` includes:
- `.env` and `.env.local`
- `*.key`, `*.pem`, `credentials.json`, `secrets.json`
- `.claude/settings.local.json`
- Session/output directories

### 3. Sensitive Files in Git

Run `git ls-files` and flag any tracked `.env`, credential, key, or secret files.

### 4. .env Setup

If the project uses environment variables, check that `.env.example` exists with placeholder values (no real secrets).

## Output

If issues found: warn immediately with file, line, issue type, and recommended fix.
If clean: brief confirmation of what was checked.

Write findings to `project-plan/IMPROVEMENTS.md` under a Security section.
