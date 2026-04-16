---
thread: 2026-04-16-public-private-marketplace-coexistence
topic: Running a public Claude Code plugin marketplace alongside a private one without maintaining two parallel ecosystems
started: 2026-04-16
exchange_count: 1
---

> **Note**: This output was produced through AI-assisted research using Claude Code.

# Public + Private Plugin/Marketplace Coexistence

## Exchange 1

**Prompt**: `prompts/run/initial/2026-04-16-public-private-marketplace.md`

**Summary**: Claude Code plugins feel awkward when some skills must stay private and you also want to keep authoring portable beyond Claude. How do you run a public marketplace and a private one in tandem, without duplicating code or tooling, and ideally with a source-of-truth that other agent ecosystems can also consume?

### Key Findings

#### 1. Claude Code already treats marketplaces as plural — this is not a workaround

The Claude Code plugin system is explicitly designed for multiple marketplaces registered side-by-side on the same machine. Marketplace state lives once per user in `~/.claude/plugins/known_marketplaces.json`, and `/plugin marketplace add` accepts any number of entries. A user can have:

- `my-plugins` → a **public** GitHub marketplace (e.g. `danielrosehill/claude-marketplace`)
- `my-plugins-private` → a **private** GitHub marketplace (e.g. `danielrosehill/claude-marketplace-private`)

registered concurrently. Installs are namespaced (`/plugin install foo@my-plugins` vs `/plugin install bar@my-plugins-private`), so there is no collision risk even if two marketplaces list the same plugin.

The docs go further and formally document a **release-channels** pattern ("stable" vs "latest" marketplaces against the same plugin repo at different refs). Public-vs-private is the same primitive used for a different axis.

#### 2. Private marketplaces are a first-class, documented feature

From [the official marketplace docs](https://code.claude.com/docs/en/plugin-marketplaces):

> *Claude Code supports installing plugins from private repositories. For manual installation and updates, Claude Code uses your existing git credential helpers. If `git clone` works for a private repository in your terminal, it works in Claude Code too.*

For **background auto-updates** (where interactive prompts would block startup), token env vars are supported:

| Provider | Env vars | Notes |
|---|---|---|
| GitHub | `GITHUB_TOKEN` or `GH_TOKEN` | Needs `repo` scope for private |
| GitLab | `GITLAB_TOKEN` or `GL_TOKEN` | `read_repository` minimum |
| Bitbucket | `BITBUCKET_TOKEN` | App password or repo token |

**Known rough edge (2026):** two open issues — [#9756](https://github.com/anthropics/claude-code/issues/9756) and [#17201](https://github.com/anthropics/claude-code/issues/17201) — report that Claude Code's internal git library sometimes ignores `~/.gitconfig` credential helpers, causing private-repo auth to fail even when `git clone` works at the terminal. The reliable workarounds are (a) cloning the private marketplace locally and registering it via local path (`/plugin marketplace add /path/to/clone`), or (b) setting `GITHUB_TOKEN` explicitly in the shell that launches Claude Code.

#### 3. The decoupling that makes "no parallel ecosystems" possible: marketplace source ≠ plugin source

This is the key mechanical detail. A marketplace is a thin JSON catalog; each plugin entry declares **where that specific plugin lives**, independently of where the catalog itself is hosted. The supported plugin source types are:

| Source type | Shape | Notes |
|---|---|---|
| Relative path | `"source": "./plugins/foo"` | Plugin code lives inside the marketplace repo itself |
| `github` | `{source: "github", repo: "owner/repo", ref?, sha?}` | Plugin is a separate GitHub repo |
| `url` | `{source: "url", url: "...", ref?, sha?}` | Any git URL (GitLab, Bitbucket, self-hosted, Azure DevOps) |
| `git-subdir` | `{source: "git-subdir", url, path, ref?, sha?}` | Subdirectory of a monorepo; sparse-cloned for bandwidth |
| `npm` | `{source: "npm", package, version?, registry?}` | Installed via `npm install`; supports private registries |

Because plugin sources are references, **two different marketplaces can list the same plugin** by pointing at the same underlying repo. No code is copied between them. A version bump in the plugin repo flows into every marketplace that references it.

#### 4. `strict: false` — the marketplace-curated plugin

A per-plugin flag that changes authoring economics:

- `strict: true` (default): the plugin repo's `plugin.json` is authoritative. The marketplace entry can only supplement it. Best when the plugin is self-describing and used across marketplaces.
- `strict: false`: the marketplace entry *is* the definition. The plugin repo provides raw files (SKILL.md folders, agent .md files, scripts); the marketplace decides which of those files are exposed as skills, agents, hooks, MCP servers, etc. — and can even expose different subsets from different marketplaces.

For a public/private split, this means you can have **one raw plugin repo** and expose a restricted subset publicly (read-only commands, say) while the private marketplace exposes the full set — without forking the plugin.

#### 5. The elegant architecture: plugins as independent repos + thin catalog-only marketplaces

This is the pattern the Claude Code plugin system implicitly rewards, and it's what the more careful community write-ups converge on ([Scott Spence on organizing skills into marketplaces](https://scottspence.com/posts/organising-claude-code-skills-into-plugin-marketplaces), [dashed/claude-marketplace](https://github.com/dashed/claude-marketplace), [Dominic Böttger's private marketplace guide](https://dominic-boettger.com/blog/claude-code-private-plugin-marketplace-guide/)).

**Recommended layout:**

```
# Plugin repos (one per plugin, each standalone & versioned)
danielrosehill/plugin-code-reviewer          (public)
danielrosehill/plugin-repo-retrofitter       (public)
danielrosehill/plugin-internal-tools         (PRIVATE)
danielrosehill/plugin-customer-workflows     (PRIVATE)

# Marketplace repos — pure catalogs, ~20 lines of JSON each
danielrosehill/claude-marketplace            (public, only lists public plugins)
danielrosehill/claude-marketplace-private    (PRIVATE, lists public + private)
```

**Public `marketplace.json`:**
```json
{
  "name": "danielrosehill-plugins",
  "owner": { "name": "Daniel Rosehill" },
  "plugins": [
    { "name": "code-reviewer",      "source": { "source": "github", "repo": "danielrosehill/plugin-code-reviewer" } },
    { "name": "repo-retrofitter",   "source": { "source": "github", "repo": "danielrosehill/plugin-repo-retrofitter" } }
  ]
}
```

**Private `marketplace.json`:**
```json
{
  "name": "danielrosehill-private",
  "owner": { "name": "Daniel Rosehill" },
  "plugins": [
    { "name": "code-reviewer",        "source": { "source": "github", "repo": "danielrosehill/plugin-code-reviewer" } },
    { "name": "repo-retrofitter",     "source": { "source": "github", "repo": "danielrosehill/plugin-repo-retrofitter" } },
    { "name": "internal-tools",       "source": { "source": "github", "repo": "danielrosehill/plugin-internal-tools" } },
    { "name": "customer-workflows",   "source": { "source": "github", "repo": "danielrosehill/plugin-customer-workflows" } }
  ]
}
```

**Why this is "one ecosystem, not two":**

- Plugin code lives in exactly one place (the plugin repo). There is no copy/mirror.
- A marketplace file is ~1–3 lines per plugin — trivial to keep in sync.
- Versions, tags, releases all happen in the plugin repo and propagate automatically (or with a pin bump if you use `ref`/`sha`).
- The split is purely about **which subset each audience sees**, not about where authoring happens.
- Tooling (CI, validators, tests) lives in each plugin repo — you don't need any pipeline that straddles the boundary.

#### 6. Manifest-driven marketplace generation (optional polish)

If you want zero manual sync between the two `marketplace.json` files, maintain a single `plugins.yaml` source-of-truth:

```yaml
plugins:
  - name: code-reviewer
    repo: danielrosehill/plugin-code-reviewer
    visibility: public
  - name: repo-retrofitter
    repo: danielrosehill/plugin-repo-retrofitter
    visibility: public
  - name: internal-tools
    repo: danielrosehill/plugin-internal-tools
    visibility: private
  - name: customer-workflows
    repo: danielrosehill/plugin-customer-workflows
    visibility: private
```

A tiny generator script (run by a GitHub Action) emits `marketplace.json` in each marketplace repo — public filters to `visibility: public`, private emits all of them. Add a plugin once, both catalogs update on the next push. This is the "monorepo of pointers" pattern without the monorepo constraint.

#### 7. Monorepo variant: one repo, `git-subdir`, two catalogs

If you actually want a single repo of plugins (rather than one repo per plugin), you can still drive two marketplaces off it using `git-subdir`:

```json
{
  "name": "foo-plugin",
  "source": {
    "source": "git-subdir",
    "url": "danielrosehill/claude-plugins-mono",
    "path": "plugins/foo"
  }
}
```

**Caveat:** this only works cleanly when every plugin has the **same visibility**. A public monorepo cannot contain private plugins. If you need mixed visibility inside a single repo of plugin code, you'd need a private monorepo, and the public marketplace would then need a publishing step that mirrors the public subset to a second repo. That reintroduces the parallel ecosystem this architecture tries to avoid — so **plugin-per-repo is preferable whenever visibility is mixed**.

#### 8. Local-path private marketplace (reliable fallback)

If the `GITHUB_TOKEN` auth bug bites you today (issues [#9756](https://github.com/anthropics/claude-code/issues/9756), [#17201](https://github.com/anthropics/claude-code/issues/17201)), skip the git layer entirely for the private marketplace:

```bash
git clone git@github.com:danielrosehill/claude-marketplace-private.git ~/.claude-marketplaces/private
/plugin marketplace add ~/.claude-marketplaces/private
```

This also has a nice dev-time property: edits to the local clone are picked up instantly, no `/plugin marketplace update` needed. The public marketplace can still be added via `owner/repo` shorthand since it has no auth requirement.

#### 9. `extraKnownMarketplaces` — auto-register on project entry

For a team (or for yourself across machines), you can have Claude Code auto-register marketplaces when it enters a trusted project:

```json
// .claude/settings.json (per-project) or managed settings (org-wide)
{
  "extraKnownMarketplaces": {
    "danielrosehill-plugins": {
      "source": { "source": "github", "repo": "danielrosehill/claude-marketplace" }
    },
    "danielrosehill-private": {
      "source": { "source": "github", "repo": "danielrosehill/claude-marketplace-private" }
    }
  },
  "enabledPlugins": {
    "code-reviewer@danielrosehill-plugins": true,
    "internal-tools@danielrosehill-private": true
  }
}
```

This lets you describe "here is my whole plugin environment" declaratively, including the private pieces — no manual `/plugin marketplace add` steps per machine.

#### 10. Generalising beyond Claude — the agent-neutral source of truth

This ties back to the prior thread on cross-agent portability. If every plugin repo contains a conventional `SKILL.md` folder layout (`plugins/<name>/skills/<skill>/SKILL.md`), then:

- **Claude Code** consumes them via the marketplace catalog layer (above).
- **OpenAI Codex CLI, Gemini CLI, Antigravity, Copilot agent skills** can consume the same `SKILL.md` folders directly by cloning the plugin repo into their respective skill directories (`~/.codex/skills/`, `~/.gemini/skills/`, etc.).
- A thin `install.sh` in each plugin repo can detect which agent CLI is present and symlink into the right location — so a single `git clone && ./install.sh` onboards that plugin into whichever agent ecosystem the user runs.

In this model, **Claude Code's marketplace is one consumer view over the same underlying plugin repos, not the authoring format**. You are not locked into Claude's distribution channel; you just benefit from it when you're using Claude.

### Architectural recommendation (for Daniel's setup specifically)

Given there's already a public `Claude-Plugins-Marketplace` in Daniel's GitHub:

1. **Keep existing public plugins as standalone repos** (or factor them out of the current marketplace repo into one-plugin-per-repo if they're currently inlined via `./relative` paths). Reference them from the public `marketplace.json` via `{source: "github", repo: "danielrosehill/plugin-X"}`.
2. **Create `Claude-Plugins-Marketplace-Private`** as a private GitHub repo containing only a `.claude-plugin/marketplace.json`. List both public and private plugins by `github` source.
3. **Add a `plugins.yaml` + generator script** to either (a) the private marketplace repo, or (b) a small tooling repo, so both `marketplace.json` files regenerate from a single manifest.
4. **Ensure `GITHUB_TOKEN` is exported** in the shell that launches Claude Code so background updates of the private marketplace work. If the auth bug bites, fall back to cloning `Claude-Plugins-Marketplace-Private` locally and adding it by path.
5. **Plugin repos stay agent-neutral**: plain SKILL.md folders, no Claude-specific assumptions in the content itself. Claude Code's `plugin.json` is a thin manifest that Claude alone cares about; it doesn't constrain portability.

Result: authoring happens in N plugin repos. Distribution is two pointer files. Public and private audiences see different menus of the same dishes. No duplicate code, no mirroring pipeline, no lock-in to Claude as the distribution layer.

### Sources

- [Create and distribute a plugin marketplace — Claude Code docs](https://code.claude.com/docs/en/plugin-marketplaces) — canonical reference for marketplace schema, plugin source types, private-repo auth, `strict` mode, release channels, `extraKnownMarketplaces`, seed directories
- [Anthropic claude-code issue #9756 — Support Auth on Private Marketplaces and Plugins](https://github.com/anthropics/claude-code/issues/9756) — tracking issue for private-repo auth gaps
- [Anthropic claude-code issue #17201 — marketplace add fails with private repos despite configured git credentials](https://github.com/anthropics/claude-code/issues/17201) — credential helper bug, local-path workaround
- [Dominic Böttger — Building a Private Claude Code Plugin Marketplace for Your Team](https://dominic-boettger.com/blog/claude-code-private-plugin-marketplace-guide/) — private marketplace patterns, local clone recommendation
- [Scott Spence — Organising Claude Code Skills Into Plugin Marketplaces](https://scottspence.com/posts/organising-claude-code-skills-into-plugin-marketplaces) — split-by-audience rationale, single-source-of-truth outcome
- [dashed/claude-marketplace](https://github.com/dashed/claude-marketplace) — reference local/personal marketplace layout
- [anthropics/claude-plugins-official marketplace.json](https://github.com/anthropics/claude-plugins-official/blob/main/.claude-plugin/marketplace.json) — Anthropic's own catalog-only marketplace as a reference shape
- [aliceisjustplaying/claude-resources-monorepo](https://github.com/aliceisjustplaying/claude-resources-monorepo) — alternative monorepo layout for reference
- [Alex McFarland — You Need a Private Claude Plugin Marketplace](https://alexmcfarland.substack.com/p/you-need-a-private-claude-plugin) — motivation for private-marketplace approach
