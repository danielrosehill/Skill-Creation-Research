# Daily Research Digest — 2026-04-16

> **Note**: This digest was produced through AI-assisted research using Claude Code. It consolidates 2 individual outputs from the same day.

## Overview

Today's two investigations sit on the same axis: **how to author agent skills once and distribute them everywhere you need them — including across competing agent ecosystems and across the public/private visibility boundary — without building two parallel ecosystems of tooling.** The first piece looks outward (Claude + Cursor + Cline + Copilot + Codex + Gemini), asking whether a single repo can feed every agent. The second looks at the Claude side specifically: can a public plugin marketplace and a private one coexist off the same source-of-truth? Taken together they describe a layered architecture where **`SKILL.md` folders are the universal unit**, **Claude Code's marketplace is a thin catalog layer over them**, and **public/private is just another dimension of catalog curation**, not a separate authoring world.

## Prompts run today

| # | Prompt summary | Prompt path | Output path |
|---|---|---|---|
| 1 | How to author agent skills once and distribute across Claude Code, Cursor, Cline, Copilot, Codex, Gemini via a single marketplace-style repo. | `prompts/run/initial/2026-04-16-cross-agent-skills.md` | `outputs/individual/2026-04-16-cross-agent-skill-portability.md` |
| 2 | Running a public Claude Code plugin marketplace alongside a private one without maintaining two parallel ecosystems — and whether the same source-of-truth can feed non-Claude agents. | `prompts/run/initial/2026-04-16-public-private-marketplace.md` | `outputs/individual/2026-04-16-public-private-marketplace-coexistence.md` |

## Consolidated findings

### The universal authoring unit is already chosen: `SKILL.md`

Anthropic's Agent Skills format (YAML frontmatter + markdown body inside a folder) has been adopted by OpenAI (Codex CLI, ChatGPT), Google (Gemini CLI), GitHub (Copilot agent skills), and the Antigravity IDE as their **native** skill format. Cursor, Cline/Roo/Trae, and Windsurf accept it through adapters but keep their own rule formats as the primitive. The *authoring format* has converged; the *installation path* and *invocation semantics* (model-invoked progressive disclosure vs. always-on rules) are what still diverge. This is the foundation that makes everything else below possible: one authoring cost, many distribution channels.

Not to confuse with `AGENTS.md` — a related but distinct project-level standard (the cross-tool equivalent of `CLAUDE.md`) donated to the Linux Foundation's Agentic AI Foundation in December 2025. It governs **project instructions**, not reusable skills; useful as a pointer file at the top of a marketplace repo, but irrelevant to the skill unit itself.

### Claude Code's plugin system is built for plural marketplaces, not single

This is the most load-bearing fact for both investigations. `/plugin marketplace add` accepts any number of entries; marketplace state is per-user in `~/.claude/plugins/known_marketplaces.json`; installs are namespaced (`plugin@marketplace`). Official docs formally document a **release channels** pattern — two marketplaces pointing at different refs of the same plugin repo for stable vs. latest — and that exact same primitive is what makes public-vs-private coexistence clean: two catalogs, zero code duplication.

### Plugin source is decoupled from marketplace source — the key degree of freedom

A marketplace is a catalog; each plugin entry declares **where that specific plugin lives**, independently of where the catalog itself is hosted. Plugin source types: relative path (`./plugins/foo`), `github` (`{repo: owner/name}`), `url` (any git URL), `git-subdir` (sparse-clone a monorepo path), `npm` (any registry). Two different marketplaces can therefore reference the same underlying plugin repo by `github`/`url` source and share it without copying. A version bump in the plugin repo flows into every marketplace that lists it.

### The "one ecosystem, not two" architecture — plugins as independent repos + thin catalog marketplaces

Across both investigations the same layout emerges as the low-friction answer:

```
# Plugin repos (one per plugin, each a standalone SKILL.md tree)
danielrosehill/plugin-code-reviewer      (public)
danielrosehill/plugin-repo-retrofitter   (public)
danielrosehill/plugin-internal-tools     (PRIVATE)

# Marketplace repos — pure catalogs, ~20 lines of JSON each
danielrosehill/claude-marketplace           (public, public plugins only)
danielrosehill/claude-marketplace-private   (PRIVATE, all plugins)
```

Plugin code lives in exactly one place. Each marketplace is a catalog of pointers. Public and private audiences see different menus over the same dishes. The same plugin repos can be consumed by non-Claude agents — clone them into `~/.codex/skills/`, `~/.gemini/skills/`, or symlink them via `skillkit`/`skillport` for Cursor/Cline/Copilot — because the plugin repo's content is just a `SKILL.md` folder tree. Claude Code's marketplace becomes **one consumer view**, not a lock-in.

### Cross-agent skill managers already exist — don't build one

A small ecosystem of OSS tools handles the fan-out to ecosystems that don't speak `SKILL.md` natively or don't run MCP. All of them take the same authoring unit:

- **skillport** — MCP server that exposes a skills directory to any MCP client; preserves progressive disclosure.
- **skillkit** — npm package manager targeting 45+ agents; auto-translates `SKILL.md` → Cursor `.mdc`, Cline rules, Copilot `.github/skills/`, Windsurf rules.
- **skillfish** — one-command install to every detected agent.
- **Skills Manager** (xingkongliang) — desktop GUI.
- **openskills**, **npx skills** (Vercel Labs) — universal loaders.

Two clean distribution patterns fall out of these tools, and they compose:

- **Pattern A — MCP-bridged runtime.** Run skillport (or a FastMCP Skills Provider) pointed at your repo; every MCP-speaking agent (Claude Code, Cursor, Copilot, Windsurf, Cline, Codex) reads from the same bus. Progressive disclosure preserved. Requires a background process; excludes non-MCP agents.
- **Pattern B — Static adapter builds.** CI step emits per-ecosystem artifacts into sidecar directories (`dist/cursor/.cursor/rules/`, `dist/cline/.clinerules/`, `dist/copilot/.github/skills/`). Works offline; adapters lose fidelity (Cursor rules are always-on, no model-invoked semantics).

### Private marketplaces: first-class, but with one known rough edge

Claude Code's docs explicitly support private-repo marketplaces: git credential helpers drive interactive use, and `GITHUB_TOKEN` / `GH_TOKEN` / `GITLAB_TOKEN` / `BITBUCKET_TOKEN` drive background auto-updates. Caveat: two open tracking issues ([#9756](https://github.com/anthropics/claude-code/issues/9756), [#17201](https://github.com/anthropics/claude-code/issues/17201)) report that Claude Code's internal git library sometimes ignores `~/.gitconfig` credential helpers. Reliable fallbacks: (a) clone the private marketplace locally and register by path (`/plugin marketplace add /local/path`), or (b) export `GITHUB_TOKEN` explicitly in the shell that launches Claude Code. The local-path approach has a nice side-effect of instant edit propagation during development.

### `strict: false` and the curated-plugin pattern

A per-plugin marketplace flag. With `strict: false`, the marketplace entry becomes the authoritative definition rather than the plugin's `plugin.json`. The plugin repo can contain raw `SKILL.md` files, agents, scripts — and different marketplaces can expose **different subsets** of them to different audiences. This is orthogonal to the public/private split but useful when you want one raw plugin repo to surface a restricted subset publicly and the full set privately.

### Manifest-driven marketplace generation (optional polish)

To eliminate even the two-line manual sync between public and private `marketplace.json` files, maintain a single `plugins.yaml` listing every plugin with a `visibility: public | private` flag, and have a generator script (GitHub Action) emit both catalogs on push. Add a plugin once, both audiences update on the next CI run.

### Where full portability honestly breaks

- **Model-invoked discovery is Claude/Codex/Gemini territory.** Cursor rules and `.clinerules/` are always-on; a Claude skill ported there loses its autonomy.
- **Plugin-only Claude primitives don't translate.** Hooks, subagents, MCP-server bundles, slash commands have no 1:1 equivalent in Cursor/Cline. Keep them Claude-only; treat the cross-agent skill catalog as a strict subset.
- **Reserved marketplace names.** Anthropic reserves `agent-skills`, `anthropic-plugins`, and similar names — pick a distinctive one.
- **Path conventions aren't universal.** `~/.claude/skills/` vs. `~/.codex/skills/` vs. `~/.agents/skills/`. Skill managers paper over this; don't depend on a single canonical path yet.
- **Public monorepos can't hold private plugins.** If visibility is mixed, one-repo-per-plugin is structurally cleaner than `git-subdir` off a monorepo.

### Architectural recommendation

The two investigations converge on a single layered architecture:

1. **Plugin repos (one per plugin).** Each contains plain `SKILL.md` folders, optional Claude-specific extras (`plugin.json`, hooks, subagents, MCP servers) in a strict subset. Public plugins live in public repos; private plugins live in private repos.
2. **Two Claude Code marketplace repos.** Each is a pointer-only `.claude-plugin/marketplace.json`. Public lists public plugin repos by `github` source; private (itself a private GitHub repo) lists both public and private.
3. **Optional `plugins.yaml` + generator script** to eliminate manual catalog sync.
4. **Cross-agent fan-out** via skillkit or skillport pointed at the plugin repos directly — Claude's marketplace layer is bypassed for non-Claude tools.
5. **`GITHUB_TOKEN` in the shell** that launches Claude Code so private-marketplace updates work in background; fall back to local-path registration if the auth bug bites.

Result: authoring happens in N plugin repos. Distribution is two pointer files on the Claude side and direct consumption on other agents. Public and private audiences see different subsets of the same sources. No duplicate code, no mirroring pipeline, no lock-in to Claude as the distribution layer.

## Per-prompt detail

### 1. Cross-Agent Skill Portability and a Vendor-Neutral Marketplace

#### 1. There is now a de facto open standard — `SKILL.md`

Anthropic's **Agent Skills** format (`SKILL.md` — YAML frontmatter + markdown body inside a folder) was released as an open standard and has been adopted well beyond Claude:

| Tool | Native SKILL.md support | Default skill location |
|---|---|---|
| Claude Code | Yes (origin) | `~/.claude/skills/<name>/SKILL.md` (and inside plugins) |
| OpenAI Codex CLI | Yes | `~/.codex/skills/<name>/SKILL.md` (optional `openai.yaml` sidecar) |
| ChatGPT (hosted skills) | Yes | via ChatGPT skill upload |
| Gemini CLI | Yes | `~/.gemini/skills/` |
| GitHub Copilot | Yes (via VS Code agent skills) | `.github/skills/` |
| Antigravity IDE | Yes | `~/.antigravity/skills/` |
| Cursor | **Partial** — can load from directory, but native primitive is `.cursor/rules/*.mdc` | `~/.cursor/skills/` (non-standard), rules dir preferred |
| Cline / Roo / Trae | **Partial** — uses `.clinerules/` with plain markdown | Adapter-based |
| Windsurf | **Partial** — uses `.windsurf/rules/` | Adapter-based |

Reading between the lines: the *authoring format* has largely converged on `SKILL.md`. The *installation path* and *invocation model* (model-invoked progressive disclosure vs. always-on rules) are where vendors still diverge. A sort-of tool-agnostic convention is emerging: `~/.agents/skills/` as a neutral global location.

#### 2. `AGENTS.md` is a related but different standard — don't confuse them

Sometimes cited alongside `SKILL.md`, `AGENTS.md` is the project-level equivalent of `CLAUDE.md` — conventions, build steps, testing notes. It was donated by OpenAI and Anthropic to the Linux Foundation in December 2025 under the new **Agentic AI Foundation (AAIF)** and is read natively by Codex CLI, Cursor, Windsurf, Copilot, Devin, Jules, Gemini CLI, etc. Claude Code still prefers `CLAUDE.md` (AGENTS.md support is on the roadmap).

For Daniel's question, `AGENTS.md` is **not** the answer — it governs project instructions, not reusable skills. But including a top-level `AGENTS.md` in the marketplace repo that points at the skills directory is a cheap way to help AGENTS.md-aware agents discover the catalog.

#### 3. Cross-agent skill *managers* already exist — you don't have to build one

A small ecosystem of OSS tools has emerged to solve exactly Daniel's problem — "install/sync skills to whichever agent I'm using today":

| Tool | Model | Strengths | Trade-off |
|---|---|---|---|
| [**skillport**](https://github.com/gotalab/skillport) | CLI + **MCP server** | Exposes a `.skills/` directory to any MCP client (Cursor, Cline, Copilot, Windsurf, Codex, Claude Code). Loads metadata only (~100 tokens/skill), full body on demand — preserves progressive disclosure. Can ingest from GitHub. | Requires running a local MCP server. |
| [**skillkit**](https://github.com/rohitg00/skillkit) | npm package manager | 45+ agent targets. Auto-translates SKILL.md → Cursor `.mdc`, Cline rules, Copilot `.github/skills/`, Windsurf rules. `skillkit init / install / sync`. Team-shareable via manifest. | Translation is best-effort; loses some Claude-specific features (disable-model-invocation, plugin-only fields). |
| [**skillfish**](https://github.com/knoxgraeme/skillfish) | CLI | One command installs the skill to every detected agent on the machine (symlink or copy). | Lighter-weight than skillkit, fewer registries. |
| [**Skills Manager** (xingkongliang)](https://github.com/xingkongliang/skills-manager) | Desktop app | GUI for 15+ tools, one-click sync. | Desktop-only. |
| [**openskills**](https://github.com/numman-ali/openskills) | npm global CLI | Very thin "universal loader" wrapper. | Smaller catalog. |
| **npx skills** (Vercel Labs) | Package manager pattern | Vercel backing. | Newer, smaller ecosystem. |

All of these accept the **same authoring unit**: a folder containing `SKILL.md` + optional scripts/assets. So the authoring cost is paid once regardless of which distribution tool you pick.

#### 4. Two clean distribution patterns

There are two architecturally different ways to make one repo serve every agent. They can be combined.

**Pattern A — MCP-bridged distribution (runtime).**
Run a SKILL.md-aware MCP server (skillport, or a FastMCP "Skills Provider") pointed at the marketplace repo. Any agent that speaks MCP — Claude Code, Cursor, Copilot, Windsurf, Cline, Codex — connects once and sees every skill via `search_skills` / `load_skill`. Progressive disclosure is preserved because the MCP server only returns descriptions upfront, bodies on demand. Skills update when the repo updates; no per-agent sync step.

- Single source of truth, zero format conversion, preserves model-invoked semantics.
- Updates propagate instantly.
- Requires a background MCP process per machine.
- Non-MCP agents (plain `.cursorrules` users, older tools) are left out.

**Pattern B — Static adapter builds (publish-time).**
Keep SKILL.md as canonical. Run a build step (GitHub Action + `skillkit build` or a custom script) that emits per-ecosystem artifacts into sidecar directories or companion branches: `dist/cursor/.cursor/rules/`, `dist/cline/.clinerules/`, `dist/copilot/.github/skills/`, etc. Users install via whatever their ecosystem supports — copy a directory, pull a branch, or `skillkit install github:daniel/marketplace`.

- Works for tools with no MCP support.
- Entirely static — no runtime.
- Adapters lose fidelity (Cursor rules are always-on — no progressive disclosure).
- More maintenance; format translation can drift silently.

#### 5. Where full portability breaks — the honest caveats

- **Model-invoked discovery is Claude/Codex/Gemini territory.** Cursor rules and `.clinerules/` are loaded into every request. If you port a Claude skill over, it becomes an always-on rule and loses the autonomy Daniel currently benefits from.
- **Plugin-only features don't translate.** Slash commands, hooks, agents, and MCP-server bundles in a Claude Code plugin have no 1:1 equivalent in Cursor or Cline. Cursor has "commands" as a separate concept; Cline has "workflows". These should stay Claude-specific.
- **Reserved marketplace names.** Anthropic reserves a list of names (`agent-skills`, `anthropic-plugins`, etc.) — pick a distinctive marketplace name you can use anywhere.
- **Path conventions are not universal.** `~/.claude/skills/` vs. `~/.codex/skills/` vs. `~/.agents/skills/`. The ecosystem hasn't picked a winner; skill *managers* paper over this.

#### Recommended approach

A low-friction, change-as-little-as-possible design that preserves the existing Claude Code plugin marketplace:

**Repository layout (one repo, three audiences):**

```
daniel-skills-marketplace/
├── .claude-plugin/
│   └── marketplace.json          # unchanged — Claude Code reads this
├── plugins/                       # Claude Code plugin groupings (unchanged)
│   └── <plugin-name>/
│       ├── .claude-plugin/plugin.json
│       ├── skills/
│       │   └── <skill-name>/SKILL.md
│       ├── commands/              # Claude-only
│       ├── agents/                # Claude-only
│       └── hooks/                 # Claude-only
├── skills/                        # NEW: flat catalog for cross-agent consumers
│   └── <skill-name>/SKILL.md      # ← symlinks or copies from plugins/*/skills/
├── skillkit.json                  # NEW: skillkit manifest
├── .skillport/config.yaml         # NEW: optional skillport config
├── AGENTS.md                      # NEW: brief pointer — "skills live under /skills"
└── README.md
```

SKILL.md stays the canonical unit and lives under `plugins/<plugin>/skills/<skill>/` where Claude Code already expects it. The top-level `skills/` directory is either symlinks or produced by a tiny CI step that collects every SKILL.md into a flat catalog. Cross-agent tooling reads from `skills/`; Claude Code reads from `plugins/` via `marketplace.json`. Neither world interferes with the other.

**How users install (per agent):**

| Agent | Install command | Mechanism |
|---|---|---|
| Claude Code | `/plugin marketplace add danielrosehill/skills` then `/plugin install <plugin>@<marketplace>` | Existing, unchanged |
| Cursor | `npx skillkit install github:danielrosehill/skills` | Translates to `.cursor/rules/` |
| Cline / Roo / Trae | Same skillkit command | Translates to `.clinerules/` |
| Copilot (VS Code) | Same skillkit command | Translates to `.github/skills/` |
| Codex CLI | `cp -r skills/ ~/.codex/skills/` or `skillkit install` | SKILL.md is native |
| Gemini CLI | Same | SKILL.md is native |
| Any MCP client | `skillport add github:danielrosehill/skills` then configure MCP | MCP-bridged, progressive disclosure preserved |

One repo, one push, seven+ agents updated on next pull/refresh.

**Minimum viable first step:**

1. Leave the marketplace repo exactly as it is.
2. Add a top-level `skills/` symlink tree (one-line shell script in CI, commits on push).
3. Add a `skillkit.json` at the root that points at `skills/`.
4. Tell users on the README: `npx skillkit install github:danielrosehill/<marketplace>` for non-Claude agents.

That unlocks Cursor, Cline, Copilot, Windsurf, Codex, Gemini installs with zero change to the Claude Code flow. Pattern A (MCP-bridged via skillport) can be added later for users who want model-invoked semantics everywhere.

**What to *not* do:**

- Don't hand-port skills into `.cursorrules` / `.clinerules/` format. Format translation is exactly what skillkit/skillport exist to do, and doing it by hand defeats the "update in one place" goal.
- Don't try to force Claude-specific primitives (hooks, subagents, MCP bundles) into portable skills. Keep those Claude-only in the plugin tree; the cross-agent skill catalog is a strict subset.
- Don't depend on `~/.agents/skills/` as a universal install target yet — it's an emerging convention, not a spec, and skill managers do the right thing on each platform anyway.

### 2. Public + Private Plugin/Marketplace Coexistence

#### 1. Claude Code already treats marketplaces as plural — this is not a workaround

The Claude Code plugin system is explicitly designed for multiple marketplaces registered side-by-side on the same machine. Marketplace state lives once per user in `~/.claude/plugins/known_marketplaces.json`, and `/plugin marketplace add` accepts any number of entries. A user can have:

- `my-plugins` → a **public** GitHub marketplace (e.g. `danielrosehill/claude-marketplace`)
- `my-plugins-private` → a **private** GitHub marketplace (e.g. `danielrosehill/claude-marketplace-private`)

registered concurrently. Installs are namespaced (`/plugin install foo@my-plugins` vs `/plugin install bar@my-plugins-private`), so there is no collision risk even if two marketplaces list the same plugin.

The docs go further and formally document a **release-channels** pattern ("stable" vs "latest" marketplaces against the same plugin repo at different refs). Public-vs-private is the same primitive used for a different axis.

#### 2. Private marketplaces are a first-class, documented feature

From the official marketplace docs:

> *Claude Code supports installing plugins from private repositories. For manual installation and updates, Claude Code uses your existing git credential helpers. If `git clone` works for a private repository in your terminal, it works in Claude Code too.*

For **background auto-updates** (where interactive prompts would block startup), token env vars are supported:

| Provider | Env vars | Notes |
|---|---|---|
| GitHub | `GITHUB_TOKEN` or `GH_TOKEN` | Needs `repo` scope for private |
| GitLab | `GITLAB_TOKEN` or `GL_TOKEN` | `read_repository` minimum |
| Bitbucket | `BITBUCKET_TOKEN` | App password or repo token |

**Known rough edge (2026):** two open issues — [#9756](https://github.com/anthropics/claude-code/issues/9756) and [#17201](https://github.com/anthropics/claude-code/issues/17201) — report that Claude Code's internal git library sometimes ignores `~/.gitconfig` credential helpers, causing private-repo auth to fail even when `git clone` works at the terminal. The reliable workarounds are (a) cloning the private marketplace locally and registering it via local path (`/plugin marketplace add /path/to/clone`), or (b) setting `GITHUB_TOKEN` explicitly in the shell that launches Claude Code.

#### 3. The decoupling that makes "no parallel ecosystems" possible: marketplace source ≠ plugin source

A marketplace is a thin JSON catalog; each plugin entry declares **where that specific plugin lives**, independently of where the catalog itself is hosted. The supported plugin source types are:

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

If every plugin repo contains a conventional `SKILL.md` folder layout (`plugins/<name>/skills/<skill>/SKILL.md`), then:

- **Claude Code** consumes them via the marketplace catalog layer (above).
- **OpenAI Codex CLI, Gemini CLI, Antigravity, Copilot agent skills** can consume the same `SKILL.md` folders directly by cloning the plugin repo into their respective skill directories (`~/.codex/skills/`, `~/.gemini/skills/`, etc.).
- A thin `install.sh` in each plugin repo can detect which agent CLI is present and symlink into the right location — so a single `git clone && ./install.sh` onboards that plugin into whichever agent ecosystem the user runs.

In this model, **Claude Code's marketplace is one consumer view over the same underlying plugin repos, not the authoring format**. You are not locked into Claude's distribution channel; you just benefit from it when you're using Claude.

#### Architectural recommendation (for Daniel's setup specifically)

Given there's already a public `Claude-Plugins-Marketplace` in Daniel's GitHub:

1. **Keep existing public plugins as standalone repos** (or factor them out of the current marketplace repo into one-plugin-per-repo if they're currently inlined via `./relative` paths). Reference them from the public `marketplace.json` via `{source: "github", repo: "danielrosehill/plugin-X"}`.
2. **Create `Claude-Plugins-Marketplace-Private`** as a private GitHub repo containing only a `.claude-plugin/marketplace.json`. List both public and private plugins by `github` source.
3. **Add a `plugins.yaml` + generator script** to either (a) the private marketplace repo, or (b) a small tooling repo, so both `marketplace.json` files regenerate from a single manifest.
4. **Ensure `GITHUB_TOKEN` is exported** in the shell that launches Claude Code so background updates of the private marketplace work. If the auth bug bites, fall back to cloning `Claude-Plugins-Marketplace-Private` locally and adding it by path.
5. **Plugin repos stay agent-neutral**: plain SKILL.md folders, no Claude-specific assumptions in the content itself. Claude Code's `plugin.json` is a thin manifest that Claude alone cares about; it doesn't constrain portability.

Result: authoring happens in N plugin repos. Distribution is two pointer files. Public and private audiences see different menus of the same dishes. No duplicate code, no mirroring pipeline, no lock-in to Claude as the distribution layer.

## Consolidated sources

### Official specs and documentation

- [Agent Skills — Claude API Docs](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview)
- [Extend Claude with skills — Claude Code Docs](https://code.claude.com/docs/en/skills)
- [Equipping agents for the real world with Agent Skills (Anthropic Engineering)](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills)
- [Create and distribute a plugin marketplace — Claude Code Docs](https://code.claude.com/docs/en/plugin-marketplaces)
- [anthropics/skills — Public repository for Agent Skills](https://github.com/anthropics/skills)
- [Agent Skills — Codex | OpenAI Developers](https://developers.openai.com/codex/skills)
- [codex/docs/skills.md — OpenAI Codex skills spec](https://github.com/openai/codex/blob/main/docs/skills.md)
- [OpenAI are quietly adopting skills — Simon Willison](https://simonwillison.net/2025/Dec/12/openai-skills/)
- [OpenAI co-founds the Agentic AI Foundation under the Linux Foundation](https://openai.com/index/agentic-ai-foundation/)
- [AGENTS.md Emerges as Open Standard for AI Coding Agents — InfoQ](https://www.infoq.com/news/2025/08/agents-md/)

### Claude Code issues and known rough edges

- [claude-code issue #9756 — Support Auth on Private Marketplaces and Plugins](https://github.com/anthropics/claude-code/issues/9756)
- [claude-code issue #17201 — marketplace add fails with private repos despite configured git credentials](https://github.com/anthropics/claude-code/issues/17201)

### Cross-agent skill managers

- [gotalab/skillport — Bring Agent Skills to Any AI Agent via CLI or MCP](https://github.com/gotalab/skillport)
- [rohitg00/skillkit — Portable skills across 45 agents](https://github.com/rohitg00/skillkit)
- [knoxgraeme/skillfish — One command, all agents](https://github.com/knoxgraeme/skillfish)
- [xingkongliang/skills-manager — Desktop app for 15+ tools](https://github.com/xingkongliang/skills-manager)
- [numman-ali/openskills — Universal skills loader](https://github.com/numman-ali/openskills)
- [FrancyJGLisboa/agent-skill-creator — One SKILL.md, every platform](https://github.com/FrancyJGLisboa/agent-skill-creator)
- [Karanjot786/agent-skills-cli — Universal CLI for Agent Skills](https://github.com/Karanjot786/agent-skills-cli)
- [Skills Provider — FastMCP docs](https://gofastmcp.com/servers/providers/skills)

### Marketplace patterns and community guides

- [Dominic Böttger — Building a Private Claude Code Plugin Marketplace for Your Team](https://dominic-boettger.com/blog/claude-code-private-plugin-marketplace-guide/)
- [Scott Spence — Organising Claude Code Skills Into Plugin Marketplaces](https://scottspence.com/posts/organising-claude-code-skills-into-plugin-marketplaces)
- [dashed/claude-marketplace — Reference local/personal marketplace](https://github.com/dashed/claude-marketplace)
- [anthropics/claude-plugins-official marketplace.json](https://github.com/anthropics/claude-plugins-official/blob/main/.claude-plugin/marketplace.json)
- [aliceisjustplaying/claude-resources-monorepo — Alternative monorepo layout](https://github.com/aliceisjustplaying/claude-resources-monorepo)
- [Alex McFarland — You Need a Private Claude Plugin Marketplace](https://alexmcfarland.substack.com/p/you-need-a-private-claude-plugin)

### Comparative and explanatory pieces

- [Claude Code Skills vs Cursor Rules vs Codex Skills — Agensi](https://www.agensi.io/learn/claude-code-skills-vs-cursor-rules-vs-codex-skills)
- [What Is the Agent Skills Open Standard? (2026 Explainer) — Agensi](https://www.agensi.io/learn/agent-skills-open-standard)
- [Confused About Where to Put Your Agent Skills? — Dazbo on Medium](https://medium.com/google-cloud/confused-about-where-to-put-your-agent-skills-ea778f3c64f3)
