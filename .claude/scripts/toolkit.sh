#!/usr/bin/env bash
#
# agent-builder toolkit helper (macOS / Linux)
#
# Every shell operation the /create-agent flow needs lives here, so the guided
# walkthrough never has to embed raw shell. There is a matching toolkit.ps1 for
# Windows that accepts the same verbs and prints the same output, so the
# walkthrough's logic is identical on every platform.
#
# Always invoke as:  bash .claude/scripts/toolkit.sh <verb> [args]
# (never ./toolkit.sh - zip archives don't reliably preserve the exec bit)

set -u

VERB="${1:-}"

# ---------------------------------------------------------------------------
# git-probe - report environment WITHOUT changing or triggering anything.
#
# Critical on macOS: /usr/bin/git exists as a stub even when no toolchain is
# installed, and RUNNING it is what pops the Command Line Tools installer. We
# must never invoke git here just to find out whether git exists, or we trigger
# the very dialog the walkthrough is trying to ask permission for first.
# xcode-select -p answers the question without side effects.
# ---------------------------------------------------------------------------
cmd_git_probe() {
  git_state="missing"

  if [ "$(uname)" = "Darwin" ]; then
    if xcode-select -p >/dev/null 2>&1; then
      git_state="ready"
    fi
  else
    if command -v git >/dev/null 2>&1; then
      git_state="ready"
    fi
  fi

  # Only safe to actually run git once we know the toolchain is present.
  if [ "$git_state" = "ready" ] && ! git --version >/dev/null 2>&1; then
    git_state="missing"
  fi

  if [ "$git_state" != "ready" ]; then
    echo "git=missing"
    echo "identity=unknown"
    echo "repo=unknown"
    return 0
  fi

  echo "git=ready"

  name="$(git config user.name 2>/dev/null || true)"
  email="$(git config user.email 2>/dev/null || true)"
  if [ -n "$name" ] && [ -n "$email" ]; then
    echo "identity=set"
  else
    echo "identity=missing"
  fi

  if git rev-parse --git-dir >/dev/null 2>&1; then
    echo "repo=yes"
  else
    echo "repo=no"
  fi
}

# ---------------------------------------------------------------------------
# git-setup [name] [email] - start tracking this folder, take first snapshot.
# Safe to re-run. Pass name/email only when git-probe said identity=missing.
# ---------------------------------------------------------------------------
cmd_git_setup() {
  name="${1:-}"
  email="${2:-}"

  git rev-parse --git-dir >/dev/null 2>&1 || git init --quiet

  if [ -n "$name" ]; then
    git config --local user.name "$name"
  fi
  if [ -n "$email" ]; then
    git config --local user.email "$email"
  fi

  git add -A
  if git diff --cached --quiet; then
    echo "result=nothing-to-commit"
  else
    git commit --quiet -m "Starting point: agent-builder toolkit"
    echo "result=committed"
  fi
}

# ---------------------------------------------------------------------------
# checkpoint "<message>" - snapshot after a phase. Silently does nothing if git
# was never set up, so the walkthrough can call it unconditionally.
# ---------------------------------------------------------------------------
cmd_checkpoint() {
  message="${1:-Checkpoint}"

  if ! git rev-parse --git-dir >/dev/null 2>&1; then
    echo "result=skipped-no-git"
    return 0
  fi

  git add -A
  if git diff --cached --quiet; then
    echo "result=nothing-to-commit"
  else
    git commit --quiet -m "$message"
    echo "result=committed"
  fi
}

# ---------------------------------------------------------------------------
# final-commit "<message>" - closing snapshot, then show the history so the
# user can see what "saving as you go" actually produced.
# ---------------------------------------------------------------------------
cmd_final_commit() {
  message="${1:-Complete V1}"

  if ! git rev-parse --git-dir >/dev/null 2>&1; then
    echo "result=skipped-no-git"
    return 0
  fi

  git add -A
  if git diff --cached --quiet; then
    echo "result=nothing-to-commit"
  else
    git commit --quiet -m "$message"
    echo "result=committed"
  fi

  echo "--- history ---"
  git log --oneline
}

# ---------------------------------------------------------------------------
# scaffold [sessions-dir] - create the standard workflow directories.
# ---------------------------------------------------------------------------
cmd_scaffold() {
  sessions="${1:-}"

  mkdir -p .claude/commands .claude/agents .claude/skills .claude/knowledge project-plan
  if [ -n "$sessions" ]; then
    mkdir -p "$sessions"
  fi

  echo "result=scaffolded"
}

# ---------------------------------------------------------------------------
# settings-init - install project permissions from the template.
# ---------------------------------------------------------------------------
cmd_settings_init() {
  template=".claude/knowledge/templates/settings.template.json"

  if [ ! -f "$template" ]; then
    echo "result=template-missing"
    return 1
  fi

  mkdir -p .claude
  cp "$template" .claude/settings.json
  echo "result=installed"
}

# ---------------------------------------------------------------------------
# copy-toolkit <dest> - copy just the agent-builder tooling into a new folder
# for a second, unrelated workflow. Deliberately does NOT copy project-plan/,
# the user's custom command, CLAUDE.md or README.md.
# ---------------------------------------------------------------------------
cmd_copy_toolkit() {
  dest="${1:-}"

  if [ -z "$dest" ]; then
    echo "result=error-no-destination"
    return 1
  fi

  # Every destination subdirectory must exist before cp runs; copying multiple
  # sources into a missing directory is an error, not an implicit mkdir.
  mkdir -p "$dest/.claude/commands" "$dest/.claude/skills" "$dest/.claude/scripts"

  for c in review-workflow save-workflow improve-workflow; do
    cp ".claude/commands/$c.md" "$dest/.claude/commands/"
  done

  for s in create-agent workflow-reviewer save-progress security-checker \
           software-best-practices workflow-improver; do
    cp -R ".claude/skills/$s" "$dest/.claude/skills/"
  done

  cp -R .claude/agents "$dest/.claude/"
  cp -R .claude/knowledge "$dest/.claude/"
  cp .claude/scripts/toolkit.sh .claude/scripts/toolkit.ps1 "$dest/.claude/scripts/"

  if [ -f .gitignore ]; then
    cp .gitignore "$dest/"
  fi

  echo "result=copied"
}

case "$VERB" in
  git-probe)     cmd_git_probe ;;
  git-setup)     shift; cmd_git_setup "${@:-}" ;;
  checkpoint)    shift; cmd_checkpoint "${@:-}" ;;
  final-commit)  shift; cmd_final_commit "${@:-}" ;;
  scaffold)      shift; cmd_scaffold "${@:-}" ;;
  settings-init) cmd_settings_init ;;
  copy-toolkit)  shift; cmd_copy_toolkit "${@:-}" ;;
  *)
    echo "Usage: bash .claude/scripts/toolkit.sh <verb> [args]" >&2
    echo "Verbs: git-probe, git-setup, checkpoint, final-commit, scaffold, settings-init, copy-toolkit" >&2
    exit 2
    ;;
esac
