# Changelog

All notable changes to the agent-builder plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
