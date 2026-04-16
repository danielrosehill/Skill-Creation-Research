# Set Up Publishing Integrations

Scaffold an `.mcp.json` configuration file for piping research outputs to external platforms.

## Steps

1. Ask the user which publishing integrations they want to configure. Supported options:

   - **WordPress** — Publish blog posts and reports via WordPress REST API
   - **Ghost** — Publish to a Ghost blog
   - **Notion** — Export findings to a Notion database
   - **Obsidian** — Copy outputs to an Obsidian vault directory
   - **Custom webhook** — POST formatted output to an arbitrary URL

2. For each selected integration, collect the required configuration:

   - **WordPress**: site URL, application password or API key
   - **Ghost**: API URL, Admin API key
   - **Notion**: integration token, target database ID
   - **Obsidian**: vault path on the local filesystem
   - **Custom webhook**: URL, optional headers, HTTP method

3. Generate `.mcp.json` at the project root with the selected MCP server configurations. Use this structure:

   ```json
   {
     "mcpServers": {
       "<integration-name>": {
         "command": "...",
         "args": ["..."],
         "env": {
           "API_KEY": "..."
         }
       }
     }
   }
   ```

4. Add `.mcp.json` to `.gitignore` (it will contain credentials).
5. Create a `publishing-config.example.json` showing the structure with placeholder values, so other users of the repo can set up their own integrations.
6. Report which integrations were configured and remind the user to test them.

## Notes

- The `.mcp.json` file should NEVER be committed (it contains secrets).
- The example file should be committed so collaborators can replicate the setup.
- For WordPress specifically, suggest the `@anthropic/mcp-wordpress` server if available, or a generic HTTP MCP server as fallback.
