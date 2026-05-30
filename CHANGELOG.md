# Changelog

All notable changes to the agent-builder plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed
- Phase 0 of `/create-agent` no longer hardcodes the marketplace directory name
  - Install script is now invoked via `${CLAUDE_PLUGIN_ROOT}`, so it resolves regardless of how the user named the marketplace (previously hardcoded `thanx-agent-builder`, which failed with exit 127)
  - `workflow-reviewer` skill resolves the plugin knowledge directory with a glob (`*agent-builder*`) instead of the stale hardcoded path
- `.agent-builder-version` is now written by `install.sh` reading the version from `plugin.json` (single source of truth) instead of a hardcoded literal that drifted out of date

### Changed
- Phase 0 of `/create-agent` continues directly into the interview in the same session
  - Commands and skills hot-reload, so the forced two-pass restart is gone
  - After install, it probes that the tools are live (invokes `workflow-reviewer`) and continues to Phase 1 on success
  - The "please restart your session" message is now a fallback shown only if the probe fails, not the default path
  - Collapsed the redundant "installed but not loaded" branch into the single probe step

## [0.1.17] - 2025-11-02

### Fixed
- Removed unnecessary whitelist from review exclusions
  - Now only blacklists plugin-maintained files
  - Reviews ALL other files in the project (no artificial limits)
  - Allows reviewer to find issues in any user-created files

## [0.1.16] - 2025-11-02

### Changed
- Review agents now exclude agent-builder plugin files
  - Skips: review-workflow.md, save-workflow.md, workflow-reviewer, review agents, templates
  - Only reviews: user's workflow, setup.md, custom skills/agents, project files
  - Prevents false positives on plugin-maintained files
  - Exclusion list passed to all 5 review agents

## [0.1.15] - 2025-11-02

### Added
- Interactive review workflow with won't-fix tracking
  - New option to review each finding one-by-one
  - Ask "yes/no/skip" for each finding
  - "no" marks items as won't-fix in `project-plan/REVIEW-IGNORED.md`
  - Future reviews automatically filter out ignored items
  - Prevents review fatigue from seeing same findings repeatedly
- REVIEW-IGNORED.md file format with metadata
  - Category, location, issue description, ignored date
  - Users can remove items to reconsider them
  - Appends to existing file to preserve history

### Changed
- workflow-reviewer now checks REVIEW-IGNORED.md before showing findings
- Added Step 0 to check for previously ignored items
- Step 2 filters out ignored findings from results
- Step 3 offers 4 options including interactive review
- Step 4 writes to both IMPROVEMENTS.md and REVIEW-IGNORED.md as needed

## [0.1.14] - 2025-11-02

### Fixed
- Clarified config file usage in setup template
  - MCP configuration: `~/.claude/settings.json` (global) or `.claude/settings.local.json` (local)
  - Permissions: `.claude/config.json` (created by installer)
  - Added note explaining permissions are already configured
  - Prevents confusion about which file to edit

## [0.1.13] - 2025-11-02

### Fixed
- workflow-reviewer skill now references knowledge files from plugin location
  - Changed paths from `.claude/knowledge/` to `~/.claude/plugins/marketplaces/thanx-agent-builder/.claude/knowledge/`
  - Knowledge files stay centralized in plugin (no duplication across projects)
  - Updates to best practices automatically affect all projects
  - Files: workflow-patterns.md, security-guidelines.md, component-decision-guide.md

## [0.1.12] - 2025-11-02

### Changed
- `/agent-builder:update-agent-builder` now checks if plugin itself is outdated
  - Uses GitHub MCP (if available) to check latest version on GitHub
  - If plugin outdated: Tells user to run `/plugin update` first, then stops
  - If plugin current: Proceeds with project file updates as before
  - If GitHub MCP not available: Skips plugin check, updates project files only
- Prevents confusion from updating project files with outdated plugin

## [0.1.11] - 2025-11-02

### Changed
- Updated README.md to reflect recent changes:
  - Command is `/agent-builder:create-agent` (namespaced by plugin)
  - Commands are `/review-workflow` and `/save-workflow` (renamed in v0.1.4)
  - Phase 1 has two paths (fast/guided, added in v0.1.8)
  - Phase 0 creates config.json (added in v0.1.7)
  - Removed reference to non-existent skill file (inlined in v0.1.2)
  - Updated installation instructions with restart flow

## [0.1.10] - 2025-11-02

### Changed
- Final summary now presents two clear next-step options:
  - Option 1: Run `/review-workflow` for security and improvement analysis
  - Option 2: Run the workflow to test it on a real use case
- Explains what each option does to help users choose
- Ends with "Which option would you like to try first?" prompt

## [0.1.9] - 2025-11-02

### Fixed
- Final summary now has proper line breaks between items with emojis
  - Added explicit formatting instructions for clean, readable output
  - Prevents text from running together on one line

## [0.1.8] - 2025-11-02

### Changed
- Phase 1 now asks if user knows what they want to automate
  - Option 1: Skip discovery, go straight to describing their specific workflow
  - Option 2: Guided discovery for users who need help identifying opportunities
  - Faster path for experienced users who know what they want

## [0.1.7] - 2025-11-02

### Changed
- Install script now creates `.claude/config.json` immediately during installation
  - Replaces `[PROJECT_PATH]` placeholder with actual project path
  - Sets up file operation and bash command permissions
  - Phase 4 permissions section removed (handled in Phase 0)

### Fixed
- Removed non-functional skill permissions from config template
  - Skills don't use the permission system (they use `allowed-tools` in SKILL.md)
  - Users will still see permission prompt on first skill invocation
  - This is expected Claude Code behavior

## [0.1.6] - 2025-11-02

### Changed
- Added skill permissions to config template to prevent permission prompts
  - workflow-reviewer, save-progress, security-checker, software-best-practices
  - Users no longer prompted when these skills are invoked

## [0.1.5] - 2025-11-02

### Fixed
- `/create-agent` now properly stops after installation with clearer restart instructions
- Strengthened STOP instructions to prevent Phase 1 from running before restart
- Clearer skill loading check logic

## [0.1.4] - 2025-11-02

### Changed
- **BREAKING**: Renamed commands to avoid conflicts
  - `/review` → `/review-workflow`
  - `/save` → `/save-workflow`
- `/create-agent` now stops after installation and requires Claude restart
  - Checks if skills are loaded before proceeding with interview
  - User runs `/create-agent` twice: once to install, once to create workflow
  - Prevents Phase 1 from running without access to installed skills

### Fixed
- Commands and skills now available during workflow creation (after restart)

## [0.1.3] - 2025-11-02

### Added
- `/update-agent-builder` command to update agent-builder tools non-destructively
- Version tracking via `.agent-builder-version` file
- Automatic backups before updates to `.claude/backups/`
- `--backup` flag support in install script
- CHANGELOG.md for tracking changes between versions

### Changed
- `/create-agent` now writes `.agent-builder-version` file after installation
- Gitignore template now excludes `.claude/backups/` directory

## [0.1.2] - 2025-11-02

### Added
- Install script for efficient file copying (saves ~60KB tokens per installation)
- Idempotent installation checks (won't reinstall if files already exist)

### Changed
- Inlined skill logic into command for reliability
- Phase 0 now checks for existing installations before copying files

### Fixed
- Plugin now works correctly (command no longer depends on unloaded skill)
- Questions now asked one at a time instead of all at once

## [0.1.1] - 2025-11-02

### Fixed
- Removed invalid `agents` field from plugin.json that caused validation errors

## [0.1.0] - 2025-11-01

### Added
- Initial release
- `/create-agent` command for guided workflow creation
- 6-phase workflow: Install tools, Discovery, Process interview, Data source setup, Design, Implementation, Git init
- Agent-builder tools: `/review`, `/save` commands
- Skills: workflow-reviewer, save-progress, security-checker, software-best-practices
- 5 parallel review agents
- File templates for workflow generation
