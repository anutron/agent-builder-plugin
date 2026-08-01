# Changelog

All notable changes to the agent-builder plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.4.1] - 2026-07-31

### Added
- The interview now tells the user they can **dictate instead of typing**, recommending `/voice tap` (press space once to start, again to send). This is the one place it materially helps - the useful answers are two or three paragraphs about how someone actually works, and most people won't type that but will happily say it. Mentions the microphone requirement and that transcription doesn't count against usage, offers it exactly once, and doesn't debug at length if it fails

### Changed
- Phase 1 no longer opens by asking the user to pick a path. "Do you already know what you want, or shall I ask questions?" forces a decision before they know what either option involves, and frames the interview as the fallback route. It now states what's happening, notes that skipping is available, and asks the first question in the same breath - the interview is the method being taught, not a consolation prize. Users who realize mid-interview that they know what they want can still say so at any point
- Phase 0's welcome no longer ends with "Let's build your workflow!", since Phase 1 immediately opens with its own call to action
- The permission-modes explanation lists **four** modes (Plan, Default, Accept edits, Auto), not five. The fifth skips permission checks entirely, is off by default behind advanced settings, and nobody in the target audience will have it enabled - naming it to a first-time user only plants the idea of disabling the thing standing between them and an unrecoverable mistake. The skill now says explicitly not to introduce it, while answering honestly if a user raises it
- Quick start collapsed to **one paste**. The user now copies a single block that tells Claude to download, verify it landed at the top level, then hand back `/reload-skills` and `/create-agent` in order with an explanation of each. Setup is two steps: make a folder, paste one thing
  - Claude cannot run its own slash commands, so the prompt explicitly instructs it to hand those two to the user and wait rather than attempting them
  - Troubleshooting moved into its own section, ordered by likelihood, instead of being nested inside a numbered step

### Fixed
- **The download no longer lands in a sub-folder.** Found in a real first-run test: the old curl+unzip instructions produced `agent-builder-plugin-main/`, and getting out of it took a judgement call mid-setup that a less confident user wouldn't make. Now a single tarball command with `--strip-components=1` unpacks straight into the project folder
  - Also removes a silent failure mode: moving contents up with `mv folder/* .` skips dotfiles, which would have left `.claude/` behind and the toolkit non-functional in a way that's hard to diagnose. Verified end to end that `.claude/`, `CLAUDE.md` and `.gitignore` all land correctly
  - Windows gets an explicit `curl.exe` variant, since PowerShell aliases `curl` to `Invoke-WebRequest` and breaks the pipe
- **`/reload-skills` is now a documented step, not troubleshooting.** Claude Code scans for skills at session start, so freshly downloaded ones aren't visible – a real first run hit `Unknown command: /create-agent` and stalled. The README now says to run it, with restarting the session as the fallback for older versions
- `/create-agent`'s "toolkit missing" path now checks for a wrapper folder first and fixes it, rather than telling the user to re-download something they already have. It also warns explicitly about hidden files when moving contents up

## [2.4.0] - 2026-07-31

### Changed
- **Reframed all data-source guidance around connectors instead of installing MCP servers by hand.** The repo taught the old path – npm install a package, hand-edit a settings JSON, store an API key – which is both harder and less safe than the current one
  - Renamed `mcp-integration.md` to `connectors.md` and rewrote its front half: ready-made connectors in **Claude Desktop → Settings → Connectors**, "Add custom connector" by URL for anything not listed, `/mcp` and `claude mcp add --transport http` in Claude Code
  - Recommendation order is now explicit: ready-made connector → custom connector by URL → manual data for V1 → writing your own server as a genuine last resort
  - Writing your own server is demoted to an appendix and explicitly excluded from the guided build
  - Says "connector" to users, and mentions MCP once so the acronym isn't a mystery
- Documented three things a first-timer would otherwise hit blind: custom connectors need a Pro/Max/Team/Enterprise plan, Team and Enterprise route through an Organization Owner, and Claude Desktop will **not** load remote servers written into `claude_desktop_config.json` – the UI is the only path, so nobody should be sent to that file
- Security guidance now leads with the strongest argument for connectors: OAuth sign-in means **no long-lived API key on disk**, nothing to leak or accidentally commit, and access revocable from the other service. The hand-configured example is kept as the "old style, handle with care" case
- `/setup` generation now **verifies** connectors rather than instructing installation – connectors belong to a person's account, not a project, so a workflow can only state what it needs. Reports how to add a missing one and what the manual fallback is, and never blocks
- `README.template` prerequisites, `CLAUDE.template`, `setup.template` and `setup-command-guide.md` all reworded from "Required MCPs" to connectors, with a manual-steps section alongside
- Review agents use connector vocabulary; the setup-drift example is now a missing Google Drive connector rather than a Jira npm package

## [2.3.0] - 2026-07-31

### Changed
- **Rewrote every example for the actual audience.** The repo taught a non-technical audience using nothing but software-engineering examples (PRD authoring, bug triage, SQL generation, Snowflake, LookML), which told a restaurant manager that this tool wasn't for them
  - `workflow-patterns.md` rebuilt around two restaurant workflows – a weekly close-out report and a vendor price tracker – carrying all 11 patterns, the architectural comparison, best practices and anti-patterns unchanged
  - README example use cases replaced with close-out report, vendor price tracking, onboarding packet and shift handoff
  - Example command names throughout are now `/close-out` and `/vendor-watch` rather than `/write-prd` and `/analyze-tickets`
  - Session directory examples are `close-out-sessions`, not `prd-sessions`
- **README rewritten for a first-timer.** Drops "MCP-powered" from the opening sentence (an unexplained acronym in the first line), adds a pointer to installing Claude Code, explains how to make a folder, warns that GitHub's zip unpacks into a `-main` wrapper folder, sets a realistic time expectation, and notes what Windows users should expect
- Phase 2.5 cut from 128 lines to roughly 40. It arrived before the user had built anything and asked them to choose between OAuth, service accounts and API keys while offering to build a custom MCP server
  - Now has exactly two outcomes per data source: already connected, or manual for V1
  - Explicitly forbids offering to build a custom MCP server mid-flow; `mcp-integration.md` agrees rather than contradicting it
  - Defines "MCP" in one plain sentence the first time the word appears
- The `/create-agent` skill description now says what it does in plain language and states it's written for people who have never coded

### Fixed
- Stale MCP package names (`@modelcontextprotocol/server-notion` and friends) removed rather than updated. Those reference packages were archived, and the official replacements have since been superseded again by hosted connectors – any hardcoded list is wrong within months. Guidance now points at `/mcp` and `ListMcpResourcesTool`
- Surviving "Claude Code Plugin Marketplace" reference in Phase 2.5, which contradicted the README's opening line
- A 🧭 Guide's note addressed to Claude rather than the user ("When you explain this architecture choice to the user...") sat among four notes that are printed verbatim, so a student would have read a note telling them to explain architecture to themselves
- `GOAL.template` was orphaned – advertised in the README and described by `CLAUDE.template`, but nothing ever read it. `CLAUDE.template` now points at the actual file
- Dead reference to a root `CLAUDE.md` that does not exist
- `workflow-reviewer` now excludes `.claude/scripts/*` and `.claude/settings.json`, so a student's first review doesn't report findings against toolkit-owned files
- Escaped shell bangs (`Review complete\!`) in user-facing sample output
- README repository tree was missing `improve-workflow.md`, `workflow-improver/`, `scripts/`, `settings.json`, `CHANGELOG.md` and `LICENSE`, and its phase list omitted git setup and the final save
- `/promote` is no longer presented as a command students can type – it isn't in this repo. `/fewer-permission-prompts`, `/mcp` and `/workflows` are built in and stay

## [2.2.0] - 2026-07-31

### Added
- `.claude/scripts/toolkit.sh` and `.claude/scripts/toolkit.ps1` – verb-based helper scripts holding every shell operation the guided flow needs, with identical verbs and identical machine-readable output on both platforms
  - Verbs: `git-probe`, `git-setup`, `checkpoint`, `final-commit`, `scaffold`, `settings-init`, `copy-toolkit`
  - `/create-agent` now contains no raw shell at all; it calls verbs and branches on their output
  - Both are pre-approved in the shipped `.claude/settings.json`, so neither prompts
- `.claude/settings.json` now ships with the toolkit rather than being created in Phase 4.2, so permissions apply from the very first step instead of halfway through

### Fixed
- **Windows support.** The flow previously emitted POSIX-only shell (`uname`, `command -v`, `mkdir -p`, `>/dev/null`) which fails on Windows, where Claude Code falls back to PowerShell when Git for Windows isn't installed
  - Platform choice moved out of shell (where detecting it was circular – the probe's own syntax depended on what it was probing for) and into Claude's knowledge of its own environment
  - `.ps1` is invoked with `-ExecutionPolicy Bypass`, required because files extracted from a downloaded zip carry the Mark of the Web and are blocked under the default RemoteSigned policy
  - Shell scripts are invoked via `bash <path>` rather than `./<path>`, since zip archives don't reliably preserve the executable bit
  - Windows git offer now quotes Git for Windows (~2-3 min) rather than the macOS figure, and notes it also improves Claude Code's shell on Windows
- Phase 0's "build a second workflow" copy failed outright: it created only `[new-folder]/.claude`, then copied multiple sources into `commands/` and `skills/` subdirectories that didn't exist. Now handled by `copy-toolkit`, which creates every destination directory first (verified against a non-existent target)
- Phase 4.6 instructed Claude to run `/setup`, which it cannot do – Claude cannot invoke its own slash commands, so the generated `/setup` shipped untested. Now asks the user to run it, with a read-and-verify fallback

## [2.1.0] - 2026-07-31

### Added
- New `/improve-workflow` command and `workflow-improver` skill – a trimmed, per-project retrospective loop (build → use → improve → use again), distinct from `/review-workflow`'s code-quality/security checks
- Generated workflow commands (`command.template`) now close with a standard reminder to run `/improve-workflow` after actual use
- "Leveling Up" section in `component-decision-guide.md` covering when a workflow is ready for a deterministic bash-embedded skill, the `/workflows` tool, or a CLI/local web server – offered only after V1 works, not during design
- 🧭 Guide's note callouts woven through `/create-agent` and `workflow-reviewer` narrating real Claude Code features (Plan Mode, Auto mode, Subagents, Skills) as they fire, with a ground-rule explanation at the start of the flow
- `/create-agent` Phase 0 now detects an existing `project-plan/project-design.md` and offers to either redirect to `/improve-workflow` or set up a fresh folder for a second, unrelated workflow
- `/create-agent` Phase 2 now offers unprompted automation ideas ("want me to suggest ideas, or do you know what you want built?") before locking in scope
- `/create-agent` Phase 3 now drafts the goal and constraints back to the user for confirmation instead of asking them to author it from scratch
- README "Going further" section pointing to global skills/CLAUDE.md, `/promote`, `/fewer-permission-prompts`, and `github.com/anutron/ai`

### Fixed
- Remaining stale unnamespaced `/save`/`/review` references in `save-progress/SKILL.md` and `component-decision-guide.md`, missed in the 2.0.0 pass

## [2.0.0] - 2026-07-31

### Removed
- **BREAKING**: Dropped the Claude Code plugin/marketplace distribution model entirely
  - Removed `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json`
  - No more `/plugin marketplace add` + `/plugin install` flow
  - No more `/agent-builder:create-agent` namespaced command
- Removed `.claude/files-to-install/` staging directory and `install.sh`
  - All tooling now lives directly at the repo root's `.claude/` tree
  - Nothing to copy: downloading the repo *is* the install step
- Removed `/update-agent-builder` command
  - Its entire design assumed a plugin-marketplace cache path to re-run `install.sh` against
  - No replacement: re-download the repo into a fresh folder if tooling changes
- Deleted stale working notes `RECOVERY_PLAN.md` and `dogfooding-notes.md`
  - Documented bugs in the plugin/skill-loading architecture this release removes

### Changed
- New install flow: download the repo as a zip (curl + unzip, no `git clone` needed) directly into an empty project folder, then run `/create-agent`
  - Avoids the macOS Xcode Command Line Tools popup that a first `git` invocation triggers on a fresh Mac
  - Matches Windows, where git is optional and Claude Code's PowerShell fallback handles the download natively
- Consolidated the two divergent `create-agent` implementations into a single source of truth: `.claude/skills/create-agent/SKILL.md`
  - Removed `.claude/commands/create-agent.md` (the version the plugin actually loaded, now redundant)
  - Kept the skill version's Plan Mode integration (`EnterPlanMode`/`ExitPlanMode`), which had been dead code – the plugin never loaded skills
  - Ported forward the "already know what you want?" Phase 1 fast-path from the old command file
  - Rewrote Phase 0 from "copy files + restart Claude" to a lightweight presence check, since tooling is already in place at download time
- Fixed stale references across moved skills/templates: `review.md`/`save.md` → `review-workflow.md`/`save-workflow.md`, and plugin-cache paths (`~/.claude/plugins/marketplaces/...`) → plain `.claude/knowledge/...` paths
- `workflow-reviewer`'s exclusion list now also skips `.claude/skills/create-agent/*` and agent-builder's own knowledge docs, since they now live in the same folder as the user's generated workflow
- Rewrote `README.md` for the new download-and-go flow and flat repository structure

## [1.0.1] - 2026-05-30

Released under the plugin/marketplace model that 2.0.0 removed. Kept here as history.

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
