# MCP Integration Best Practices

## What are MCPs?

Model Context Protocol (MCP) servers provide Claude Code with access to external systems and data sources. They act as bridges between Claude and your tools.

## Common MCP Servers

### Official MCPs
- **@modelcontextprotocol/server-notion** - Notion workspace integration
- **@modelcontextprotocol/server-slack** - Slack workspace access
- **@modelcontextprotocol/server-github** - GitHub repositories
- **@modelcontextprotocol/server-google-drive** - Google Drive files
- **@modelcontextprotocol/server-gmail** - Gmail access

### When to Use MCPs vs APIs

**Use MCPs when**:
- Official MCP exists for the system
- Your org provides custom MCP
- Need structured, validated access
- Want automatic retries and error handling

**When no MCP exists**:
Instead of using APIs directly in your workflow, create a local MCP server:

1. **Inform user of effort**: "No MCP exists for [system]. We'll create a custom MCP server for you. This takes extra time upfront but makes your workflow cleaner and more maintainable."

2. **Create local MCP server**:
   - Generate `mcp-servers/[system-name]/` directory in the workflow project
   - Implement MCP server using the system's APIs
   - Follow MCP protocol specifications
   - Include error handling, retries, and validation
   - Document required API credentials

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

**Only use raw APIs when**:
- Very simple one-off operation (single GET request)
- Performance absolutely critical
- Custom needs can't fit MCP model

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

**Example**: Update PRD in Notion
- Research: Read existing PRD, related docs, Slack discussions
- Plan: Identify what sections need updates
- Action: Write updates to Notion

### Pattern 3: Validation Before Write
Validate data before writing to external systems:

1. **Generate**: Create content locally
2. **Validate**: Check against rules/schema
3. **Review**: Show user (optional)
4. **Write**: Send to MCP

**Benefit**: Prevents bad data in production systems

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

### 1. Permissions Configuration
Use `.claude/settings.local.json` to explicitly allow MCP operations:

```json
{
  "permissions": {
    "allow": [
      "mcp__notion__*:*",
      "mcp__slack__*:*",
      "mcp__github__*:*"
    ]
  },
  "enabledMcpjsonServers": [
    "notion",
    "slack",
    "github"
  ]
}
```

**Why**: Explicit permissions prevent accidental writes to production

### 2. Environment Variables for Credentials
Never hardcode API tokens in workflow files:

```bash
# .env (gitignored)
NOTION_API_KEY=secret_xyz...
SLACK_TOKEN=xoxb-...
GITHUB_TOKEN=ghp_...
```

```bash
# .env.example (committed)
NOTION_API_KEY=
SLACK_TOKEN=
GITHUB_TOKEN=
```

### 3. Test Connections Early
Before building complex workflows, verify MCP access:

```javascript
// Simple test
notion.pages.search("test")
slack.conversations.list()
github.repos.get("owner", "repo")
```

## Common Patterns from Real Projects

### From prd_sidekick

**Parallel Notion + Slack Research**:
- Launch 2 agents simultaneously
- Each reads from one MCP
- Results merged after both complete
- Time: 30s vs 60s sequential

**Notion Write Verification**:
- After writing to Notion, read back content
- Verify sections were created
- Report success/failure to user

### From data-knowledge

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

**Fix**: Check `enabledMcpjsonServers` in settings

### Permission Denied
```
Error: Permission denied for mcp__notion__pages__create
```

**Fix**: Add to `permissions.allow` list

### Rate Limited
```
Error: Rate limit exceeded (429)
```

**Fix**: Implement exponential backoff, reduce request frequency

### Authentication Failed
```
Error: Invalid token
```

**Fix**: Verify credentials in .env, check token hasn't expired

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
- Never commit tokens to git
- Use .env files
- Add .env to .gitignore
- Provide .env.example with no values
- Document required permissions

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
