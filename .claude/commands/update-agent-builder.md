# Update Agent Builder - Update Agent-Builder Tools

Update the agent-builder tools (commands, skills, agents, templates) to the latest version without touching your custom workflow files.

## What Gets Updated

This command updates **only** the agent-builder tools:
- Commands: `/review-workflow`, `/save-workflow`
- Skills: `workflow-reviewer`, `save-progress`, `security-checker`, `software-best-practices`
- Agents: All 5 review agents
- Templates: File templates in `.claude/knowledge/templates/`

## What Never Gets Touched

Your workflow and settings are safe:
- Your custom workflow commands (e.g., `/write-prd`, `/analyze-tickets`)
- Your custom skills and agents
- `CLAUDE.md` (project instructions)
- `README.md` (project documentation)
- `.claude/config.json` (local permissions)
- `.env` (environment variables)
- `project-plan/` (design documents)
- Any workflow session directories

## Instructions

1. **Check if agent-builder is installed**:
   - Try to read `.agent-builder-version` file
   - If file doesn't exist:
     - Show error message (see Error Handling section)
     - STOP command immediately
     - Do NOT proceed to any other steps
   - If file exists: Continue to step 2

2. **Check plugin version first** (only if GitHub MCP available):
   - Try to check if GitHub MCP is available by attempting to use it
   - If available:
     - Get latest release from GitHub: `mcp__plugin_github_github__get_file_contents` with:
       - owner: "thanx-ai"
       - repo: "agent-builder-plugin"
       - path: ".claude-plugin/plugin.json"
     - Extract version from the JSON response
     - Get installed plugin version from `~/.claude/plugins/marketplaces/thanx-agent-builder/.claude-plugin/plugin.json`
     - If installed plugin is outdated:
       ```
       ⚠️  Your plugin is outdated!

       Installed: v{old}
       Latest: v{new}

       Please update the plugin first:
       1. Run: /plugin update agent-builder@thanx-agent-builder
       2. Restart Claude Code
       3. Run /agent-builder:update-agent-builder again

       (This command only updates project files, not the plugin itself)
       ```
       - STOP here, do not continue with project updates
   - If GitHub MCP not available:
     - Skip plugin version check (proceed to step 3)

3. **Check if project update is needed**:
   - Read `.agent-builder-version` file to get current project version
   - Get plugin version from `~/.claude/plugins/marketplaces/thanx-agent-builder/.claude-plugin/plugin.json`
   - If versions match:
     ```
     ✅ Your project is already up to date!

     Current version: v{version}
     Plugin version: v{version}

     No update needed.
     ```
     - STOP here, exit command
   - If project version is older: Continue with update

4. **Show what's new**:
   - Read `~/.claude/plugins/marketplaces/thanx-agent-builder/CHANGELOG.md`
   - Extract changelog entries between current version and new version
   - Present to user:
     ```
     📦 Update available: v{old} → v{new}

     What's new in v{new}:
     [changelog entries]

     This will update agent-builder tools (review, save, skills, agents, templates).
     Your workflow files will NOT be touched.

     A backup will be created at .claude/backups/agent-builder-{old}-{timestamp}/
     ```

5. **Confirm with user**:
   - Ask: "Would you like to update to v{new}?"
   - If no: Exit gracefully
   - If yes: Proceed

6. **Run update**:
   ```bash
   bash ~/.claude/plugins/marketplaces/thanx-agent-builder/.claude/files-to-install/install.sh --backup
   ```

7. **Update version file**:
   - Write new version to `.agent-builder-version`
   ```bash
   echo "{new_version}" > .agent-builder-version
   ```

8. **Show summary**:
   ```
   ✅ Update complete!

   Updated from: v{old}
   Current version: v{new}

   Updated:
   - {count} commands
   - {count} skills
   - {count} agents
   - {count} templates

   Backup saved: .claude/backups/agent-builder-{old}-{timestamp}/

   If anything broke, restore from backup:
     cp -r .claude/backups/agent-builder-{old}-{timestamp}/* .claude/
   ```

## Error Handling

**If `.agent-builder-version` doesn't exist**:
- STOP immediately and show:
  ```
  ❌ Agent-builder is not installed in this project

  This command updates an existing agent-builder installation.
  You need to install it first.

  To install agent-builder in this project:
  1. Run: /create-agent
  2. Follow the setup wizard
  3. Then you can use /update-agent-builder to get updates

  If you already have agent-builder files but no version file,
  the installation was incomplete. Run /create-agent to set up properly.
  ```
- Do NOT proceed with any update
- Do NOT offer to create version file
- Exit command

**If backup fails**:
- Warn user but continue: "⚠️ Backup failed, but continuing with update..."

**If install fails**:
- Show error and backup location
- User can restore from backup manually

## Notes

- Backups are kept in `.claude/backups/` (add to .gitignore if not already)
- Users can run this command anytime to check for updates
- Safe to run multiple times (idempotent)
