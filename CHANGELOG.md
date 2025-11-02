# Changelog

All notable changes to the agent-builder plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
