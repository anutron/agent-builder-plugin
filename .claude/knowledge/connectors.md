# Connecting to your tools (MCP)

## What this is

A **connector** lets Claude read from and write to a system you already use – your
Notion, your email, a shared drive – instead of you copying and pasting.
Under the hood connectors speak a standard called MCP (Model Context Protocol), but
the user almost never needs that word to get anything done.

**Say "connector" when talking to a non-technical user.** Say MCP only when they'll
see the acronym on screen, and define it once when you do.

## Adding a connector – the current way

**Point people at the connectors UI, not at installing packages.** Two paths, both
click-and-sign-in:

### Claude Desktop

**Settings → Connectors.** There's a browsable list of ready-made connectors for
common tools – click one, sign in, done. Nothing to install, no file to edit.

For something not in the list, **"Add custom connector"** at the bottom of that
section takes a server URL. Authentication happens through a normal browser sign-in
(OAuth); "Advanced settings" is only needed if a server requires its own client ID
and secret.

Two things worth knowing:
- Custom connectors need a Pro, Max, Team or Enterprise plan
- On Team and Enterprise, an Organization Owner adds them in **Organization
  settings → Connectors**, so a regular user may need to ask
- Claude Desktop will **not** pick up remote servers hand-written into
  `claude_desktop_config.json` – the UI is the only route. Don't send anyone to
  that file for a remote connector

### Claude Code

- **`/mcp`** – see what's connected and manage it
- **`claude mcp add --transport http <name> <url>`** – add a remote connector; HTTP
  transport handles OAuth natively
- **`claude mcp add --transport stdio <name> -- <command>`** – for a server running
  locally on this machine

### Why the click path is the better teaching story

Not just easier – safer. A hosted connector authorized through OAuth leaves **no
long-lived API key sitting in a file on the user's laptop**, and access can be
revoked from the other service without touching anything locally. The older style
means pasting a secret into a config file and keeping it out of git forever after.

Recommend, in order: **a ready-made connector → a custom connector by URL → manual
data for V1 → a locally-run server** as a genuine last resort.

## Don't hardcode package names

This ecosystem churns fast. The old `@modelcontextprotocol/server-*` reference
packages were archived, and several official replacements (Notion's included) have
since been superseded again by hosted connectors needing no install at all. Any
list written here is wrong within months – this repo has already shipped stale
names twice.

Check what's actually connected instead:

- **`/mcp`** in Claude Code
- **`ListMcpResourcesTool`** to list connected servers programmatically, which is
  what a generated `/setup` command uses to verify requirements

When someone needs a system connected, help them find its current official
connector at that moment rather than quoting a name from this file.

### When to use a connector vs. manual data

**Use a connector when**:
- One already exists for the system, ready-made or by URL
- Their organization already provides one
- The workflow runs often enough that manual export becomes the bottleneck

**Use manual data when** it's a first version, the export is a two-minute job, or
no connector exists yet. This is a legitimate, permanent-if-you-like answer, not a
failure. See Option B below.

**When no connector exists at all**:

**During `/create-agent`, the answer is always Option B – manual for V1.** Don't
present this as a choice while someone is still trying to reach a first working
version. Writing a server from scratch is a project of its own, it needs an
authentication decision a first-time user isn't equipped to make, and offering it
mid-flow reliably prevents anyone from finishing anything.

Before concluding that nothing exists, check the actual order of preference:

1. A **ready-made connector** in Claude Desktop's Settings → Connectors list
2. A **custom connector by URL** if the vendor publishes a remote MCP endpoint –
   still just paste-and-sign-in, no code
3. **Manual data for V1** – export or paste. Perfectly fine, often permanent
4. **Writing your own server** – a separate project, only on explicit request

Option A below covers step 4, for when a user has a working workflow and explicitly
asks. It is not part of the guided build.

**Option A: Write your own MCP server** (its own project – rarely the right answer)
**Option B: Manual data handling for V1** (the default – faster to start, connect later)

### Option A: Writing your own MCP server

Only reach here after steps 1–3 above have genuinely been ruled out. If the vendor
publishes a remote endpoint, a custom connector by URL gets the same result with
none of this work.

1. **Inform user of effort**: "There's no ready-made connector for [system], and no
   remote endpoint we can point a custom connector at. We could write one, but it's
   a real project on its own. For now I'd handle [system] manually and revisit once
   the workflow has proven itself."

2. **If user chooses local MCP, create it**:
   - Generate `mcp-servers/[system-name]/` directory in the workflow project
   - Implement MCP server using the system's APIs
   - Follow MCP protocol specifications
   - Include error handling, retries, and validation
   - **Authentication priority**:
     1. **Prefer SSO/OAuth** if available (no stored credentials)
     2. Service account with scoped permissions
     3. API keys only as last resort (must be in .env, never hardcoded)
   - Document authentication setup in README

3. **Update setup for local MCP**:
   - Add to `/setup` command: how to install dependencies
   - Document in `/setup`: how to configure credentials
   - Add to `.claude/settings.local.json` template
   - Update README with local MCP instructions

4. **Quality checks before commit**:
   - Invoke `software-best-practices` skill (tests, linting, error handling)
   - Invoke `security-checker` skill (no hardcoded credentials)
   - Test MCP connection with simple query
   - Document MCP endpoints in workflow knowledge files

**Benefits of local MCP approach**:
- ✅ Cleaner workflow code (uses MCP tools, not raw API calls)
- ✅ Reusable across multiple workflows
- ✅ Error handling in one place
- ✅ Easier testing and maintenance
- ✅ Can be published for others to use
- ✅ Consistent with other MCP patterns

### Option B: Manual Data Handling (V1)

1. **Add to IMPROVEMENTS.md**: "V2: Create custom MCP for [system]"

2. **Document manual steps in workflow**:
   - Where to get the data (export, API console, etc.)
   - What format to provide it in (CSV, JSON, copy-paste)
   - Where the workflow expects it (file path, input prompt)

3. **Update workflow to accept manual input**:
   - Prompt user for data at runtime
   - OR expect data file in specific location
   - OR accept data as command argument

4. **Document in README**:
   ```markdown
   ### Manual Data Step
   Before running the workflow:
   1. Export data from [system]
   2. Save to `input/[system]-data.json`
   3. Run workflow: `/my-workflow`
   ```

**Benefits of manual approach**:
- ✅ Faster to implement (minutes vs hours)
- ✅ Proves workflow value before investing in automation
- ✅ Can automate later once pattern is proven
- ✅ Good for infrequent operations

**Trade-offs**:
- ❌ Less automated
- ❌ Manual step each time
- ❌ Potential for copy-paste errors

**When to use manual vs MCP**:
- **Manual for V1**: Quick start, prove concept, infrequent use
- **MCP for V2**: Pattern proven, frequent use, share with team


## Integration Patterns

### Pattern 1: Parallel Research
Launch multiple research agents that each query one MCP:

```markdown
Launch these agents in parallel:

**Agent 1: Notion Research**
- Use notion MCP to search for [topic]
- Write findings to session/research-notion.md

**Agent 2: Slack Research**
- Use slack MCP to search for [topic]
- Write findings to session/research-slack.md

**Agent 3: GitHub Research**
- Use github MCP to search for [topic]
- Write findings to session/research-github.md
```

**Benefit**: Research time goes from 3x30s = 90s to 30s total

### Pattern 2: Research Then Action
First gather context, then take action:

1. **Research Phase**: Query MCPs for current state
2. **Planning Phase**: Decide what to do based on findings
3. **Action Phase**: Write/update via MCPs

**Example**: Update this week's close-out report
- Research: read the sales export, the schedule, and last week's report
- Plan: identify which sections actually changed
- Action: write the updated report to wherever the GM reads it

### Pattern 3: Validation Before Write (with Parallel Writes)
Generate and validate content locally before writing to external systems in parallel:

1. **Generate**: Create all content locally in session directory
   - Write draft files to disk: `draft-section1.md`, `draft-section2.md`, etc.
   - Each draft is a complete, validated piece of content
   - Local files allow inspection and recovery if writes fail

2. **Validate**: Check against rules/schema
   - Validate each draft file independently
   - Check for required fields, format, consistency
   - Fix issues before attempting writes
   - Eliminate unnecessary duplication across drafted content

3. **Review**: Show user summary (optional)
   - "Generated 5 sections, ready to write to [system]"
   - User can inspect draft-*.md files if desired

4. **Parallel Write**: Launch write agents simultaneously if possible
   - Each agent reads one draft file and writes to MCP
   - All writes happen in parallel (not serial)
   - Example: 5 sections write in 30s instead of 2.5min

5. **Verify & Archive**: Confirm success and clean up
   - Check all writes succeeded
   - Archive draft files (external system is now source of truth)
   - Report any failures explicitly

**Worked example** – the weekly close-out report:
```markdown
Phase 3: Serial generation (local files)
- Generate draft-sales-summary.md
- Generate draft-labour.md
- Generate draft-callouts.md
(Each section reads the previous ones so it doesn't repeat them)

Phase 4: Parallel writes to the published report
Launch agents simultaneously:
- Agent 1: Write draft-sales-summary.md → report
- Agent 2: Write draft-labour.md → report
- Agent 3: Write draft-callouts.md → report

Phase 5: Archive drafts
- Move draft-*.md to drafts-archived/
- The published report is now the source of truth
```

**Benefits**:
- Prevents bad data in production systems
- Parallel writes = significant time savings
- Local drafts = resumable, inspectable, recoverable
- Clear separation: generation (serial) vs writes (parallel)

### Pattern 4: Error Handling with Retries
MCPs can fail due to network, rate limits, etc:

```python
max_attempts = 3
for attempt in range(max_attempts):
    try:
        result = mcp_call()
        break
    except Error as e:
        if attempt == max_attempts - 1:
            log_error(e)
            write_error_to_session()
        else:
            wait(exponential_backoff(attempt))
```

## Configuration Best Practices

### 1. Where connectors live

**Connectors added through the UI** (Claude Desktop Settings → Connectors, or
`claude mcp add`) are attached to the user's account or machine, **not to this
project**. That's usually what you want: connect Notion once, use it everywhere.

It also means a connector is **not** something the project can install for someone
else. A workflow can only *state what it needs*; each person adds it themselves.
That's why the generated `/setup` command verifies rather than installs.

**What the project does own** is which connector tools are pre-approved, in
`.claude/settings.json`:

```json
{
  "permissions": {
    "allow": [
      "mcp__notion__*:*"
    ]
  }
}
```

Machine-specific overrides go in `.claude/settings.local.json`, which is gitignored.

**Why be explicit**: pre-approving only the connectors a workflow actually uses
means an unexpected write to some other system still stops and asks.

### 2. Credentials: mostly not your problem any more

**With a connector added through the UI, there is no credential to manage.** Sign-in
happens in the browser, the token is held for you, and access is revoked from the
other service's own settings. Nothing lands in a file, so nothing can leak from one.

This is the single best reason to prefer connectors, and worth saying out loud to a
user who's nervous about giving an AI access to their systems: *you're not handing
over a password, and you can switch it off from the other side at any time.*

You only deal with credentials in the old-style case – a server you run locally that
takes an API key. Then the rules are absolute:

```bash
# .env (gitignored, NEVER committed)
SOME_SERVICE_API_KEY=...
```

```bash
# .env.example (committed, no real values)
SOME_SERVICE_API_KEY=
```

### 3. Test the connection early

Before building anything complex, confirm access actually works – one small read is
enough. Search for a page, list a channel, fetch a single record. Finding out that a
connector isn't authorized costs seconds now and an entire debugging session later.

## Common Patterns from Real Projects

### Single-entry-point workflow

**Parallel Notion + Slack Research**:
- Launch 2 agents simultaneously
- Each reads from one MCP
- Results merged after both complete
- Time: 30s vs 60s sequential

**Notion Write Verification**:
- After writing to Notion, read back content
- Verify sections were created
- Report success/failure to user

### Modular multi-command workflow

**Multi-Repo Exploration**:
- Parallel skills exploring different repositories
- GitHub MCP for code search
- File system access for local repos
- Results synthesized into single knowledge base

**Validation Before Execution**:
- Generated SQL validated against schema
- Warnings shown before execution
- User confirms before running

## Troubleshooting

### MCP Not Found
```
Error: MCP server "notion" not found
```

**Diagnosis**: Use `ListMcpResourcesTool()` to see which MCPs are available
```
Call: ListMcpResourcesTool()
Result: [list of available MCP servers]
```

**Fix options**, in the order to try them:

1. **Not connected yet** – the common case. Walk the user through adding it:
   - **Claude Desktop**: Settings → Connectors, pick it from the list, sign in. If
     it isn't listed, "Add custom connector" and paste the vendor's remote MCP URL
   - **Claude Code**: `/mcp`, or `claude mcp add --transport http <name> <url>`
   - Don't send them to `claude_desktop_config.json` for a remote connector – it
     won't be picked up from there

2. **Connected but not visible here** – a fresh connector sometimes needs the
   session restarted before its tools appear. Check `/mcp` shows it first.

3. **On a Team or Enterprise plan** – custom connectors are added by an Organization
   Owner in Organization settings → Connectors. If the user isn't one, the fix is a
   request to their admin, not anything they can do locally. Say so plainly rather
   than letting them hunt.

4. **No connector exists at all** – go manual for V1. See Option B.

### Permission Denied
```
Error: Permission denied for mcp__notion__pages__create
```

**Fix**: Add that tool to `permissions.allow` in `.claude/settings.json`. Note this
is a *project* permission question, not a connector problem – the connection is
working fine.

### Rate Limited
```
Error: Rate limit exceeded (429)
```

**Fix**: Back off and retry more slowly; reduce how much you're requesting at once.

### Authentication Failed
```
Error: Invalid token
```

**Fix**: For a UI connector, the sign-in has expired or been revoked – reconnect it
in Settings → Connectors. For a locally-run server, check the value in `.env`.

## Anti-Patterns

❌ **Don't hammer APIs**: Use exponential backoff
❌ **Don't hardcode tokens**: Use .env files
❌ **Don't ignore errors**: Log and handle gracefully
❌ **Don't skip validation**: Check data before writing
❌ **Don't make writes without permission**: Ask user first for destructive operations

## Testing MCP Integrations

### Manual Testing
1. Run simple queries first
2. Verify permissions work
3. Test error cases (disconnect, invalid data)
4. Test with real data

### Automated Testing
- Mock MCP responses for unit tests
- Integration tests with test workspaces
- Validate error handling paths

## Security Considerations

### Read Operations
- Generally safe, but consider data sensitivity
- Log what data was accessed
- Respect user privacy

### Write Operations
- Always require explicit permission
- Show what will be written
- Validate before writing
- Log what was changed
- Support undo when possible

### Credentials

**Authentication Method Priority**:
1. **SSO/OAuth (best)**: User authenticates via browser, no stored credentials
   - Tokens refresh automatically
   - Can be revoked centrally
   - No credentials to leak
   - Examples: Google OAuth, Microsoft SSO, Okta

2. **Service Accounts**: Dedicated account with limited scope
   - Not tied to individual user
   - Can be rotated without user impact
   - Easier to audit access

3. **API Keys (last resort)**: Only if SSO/service accounts not available
   - Must be in .env file (never hardcoded)
   - Add .env to .gitignore
   - Provide .env.example with no values
   - Document required permissions/scopes
   - Include key rotation instructions

**Universal rules**:
- Never commit tokens to git
- Log authentication method in MCP startup
- Document setup clearly in README and /setup command

## Performance Tips

### Parallel > Serial
Launch independent MCP calls in parallel

### Cache When Appropriate
Store results if data doesn't change frequently

### Batch Operations
Use batch APIs when available (create multiple items in one call)

### Pagination
Handle paginated results properly, don't just get first page

## Resources

- Official MCP docs: https://modelcontextprotocol.io
- MCP server registry: https://github.com/modelcontextprotocol/servers
- Claude Code MCP guide: https://docs.claude.com/en/docs/claude-code/mcp

## Key Takeaways

1. **MCPs abstract complexity**: Focus on workflow logic, not API details
2. **Parallel is powerful**: Reduce blocking time with simultaneous operations
3. **Validate before write**: Prevent bad data in production
4. **Handle errors gracefully**: Networks fail, have retry logic
5. **Security first**: Never commit credentials, use explicit permissions
