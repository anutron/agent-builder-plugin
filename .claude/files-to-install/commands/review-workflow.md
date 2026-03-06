# Review Workflow

Analyze this workflow project for improvement opportunities.

## Instructions

Review the project holistically, checking for:

1. **Security** - Hardcoded secrets, missing .gitignore patterns, sensitive files tracked in git
2. **Code quality** - Tests exist and pass, clear error messages, code actually runs
3. **Architecture** - Duplication, unnecessary complexity, goal drift from original purpose
4. **Documentation** - README accuracy, CLAUDE.md completeness, setup instructions work
5. **Conflicts** - Contradictory instructions across files, stale references

## Process

1. Read `project-plan/interview-notes.md` and `project-plan/project-design.md` to understand the original intent
2. Scan the codebase for issues across all five categories above
3. Present findings grouped by category, prioritized by impact
4. For each finding, include a concrete fix recommendation
5. Ask the user which findings to track in `project-plan/IMPROVEMENTS.md`

## Tone

Be thorough but actionable. Lead with high-impact items. Skip nitpicks unless there's nothing else to report.
