#set document(
  title: "Skill-Creation-Research — Daily Digest 2026-04-16",
  author: "Daniel Rosehill",
)

#let space-indigo = rgb("#2B304D")
#let coral-glow  = rgb("#F58258")
#let rosewood    = rgb("#AA697D")
#let dusty-grape = rgb("#5F4FA2")

#set page(
  paper: "a4",
  margin: (x: 2cm, y: 2.4cm),
  footer: context [
    #set text(size: 8pt, fill: space-indigo)
    #grid(
      columns: (1fr, 1fr, 1fr),
      align: (left, center, right),
      [Document: Daniel Rosehill],
      [#counter(page).display()],
      [16/04/26],
    )
  ],
)

#set text(font: "IBM Plex Sans", size: 10.5pt, fill: black, lang: "en")
#set par(justify: true, leading: 0.62em, first-line-indent: 0pt)
#show link: set text(fill: dusty-grape)
#show link: underline

#show heading.where(level: 1): it => {
  pagebreak(weak: true)
  block(
    below: 1em,
    above: 0em,
    text(size: 22pt, weight: "bold", fill: space-indigo, it.body),
  )
  block(
    above: -0.2em,
    below: 1em,
    line(length: 100%, stroke: 1.5pt + coral-glow),
  )
}
#show heading.where(level: 2): it => block(
  above: 1.2em, below: 0.6em,
  text(size: 15pt, weight: "bold", fill: space-indigo, it.body),
)
#show heading.where(level: 3): it => block(
  above: 1em, below: 0.4em,
  text(size: 12.5pt, weight: "bold", fill: rosewood, it.body),
)
#show heading.where(level: 4): it => block(
  above: 0.8em, below: 0.3em,
  text(size: 11pt, weight: "bold", fill: dusty-grape, it.body),
)

#show raw.where(block: false): it => box(
  fill: luma(240),
  inset: (x: 3pt, y: 0pt),
  outset: (y: 2pt),
  radius: 2pt,
  text(fill: space-indigo, it),
)
#show raw.where(block: true): it => block(
  fill: luma(245),
  inset: 8pt,
  radius: 3pt,
  width: 100%,
  text(size: 9pt, it),
)

#show table: set table(
  stroke: 0.5pt + luma(180),
  inset: 6pt,
)
#show table.cell.where(y: 0): set text(weight: "bold", fill: space-indigo)

// ---------------- Cover ----------------
#align(center + horizon)[
  #block(
    text(size: 9pt, fill: space-indigo, tracking: 2pt, upper("Skill-Creation-Research")),
  )
  #v(0.6em)
  #line(length: 35%, stroke: 1.5pt + coral-glow)
  #v(0.6em)
  #text(size: 30pt, weight: "bold", fill: space-indigo)[Daily Research Digest]
  #v(0.2em)
  #text(size: 16pt, fill: rosewood)[2026-04-16]
  #v(2em)
  #block(width: 70%, text(size: 11pt, fill: black)[
    #emph[Cross-agent skill portability + public/private marketplace coexistence — two investigations on a single axis: authoring once, distributing everywhere.]
  ])
  #v(4em)
  #text(size: 9pt, fill: space-indigo)[Daniel Rosehill · 16/04/26]
]

#pagebreak()

// ---------------- Body ----------------

= Overview

Today's two investigations sit on the same axis: *how to author agent skills once and distribute them everywhere you need them — including across competing agent ecosystems and across the public/private visibility boundary — without building two parallel ecosystems of tooling.* The first piece looks outward (Claude + Cursor + Cline + Copilot + Codex + Gemini), asking whether a single repo can feed every agent. The second looks at the Claude side specifically: can a public plugin marketplace and a private one coexist off the same source-of-truth? Taken together they describe a layered architecture where *`SKILL.md` folders are the universal unit*, *Claude Code's marketplace is a thin catalog layer over them*, and *public/private is just another dimension of catalog curation*, not a separate authoring world.

== Prompts run today

#table(
  columns: (auto, 1fr, auto),
  align: (left, left, left),
  [*No.*], [*Prompt summary*], [*Output*],
  [1],
  [How to author agent skills once and distribute across Claude Code, Cursor, Cline, Copilot, Codex, Gemini via a single marketplace-style repo.],
  [`2026-04-16-cross-agent-skill-portability.md`],
  [2],
  [Running a public Claude Code plugin marketplace alongside a private one without maintaining two parallel ecosystems — and whether the same source-of-truth can feed non-Claude agents.],
  [`2026-04-16-public-private-marketplace-coexistence.md`],
)

= Consolidated Findings

== The universal authoring unit is already chosen: `SKILL.md`

Anthropic's Agent Skills format (YAML frontmatter + markdown body inside a folder) has been adopted by OpenAI (Codex CLI, ChatGPT), Google (Gemini CLI), GitHub (Copilot agent skills), and the Antigravity IDE as their *native* skill format. Cursor, Cline/Roo/Trae, and Windsurf accept it through adapters but keep their own rule formats as the primitive. The _authoring format_ has converged; the _installation path_ and _invocation semantics_ (model-invoked progressive disclosure vs. always-on rules) are what still diverge. This is the foundation that makes everything else below possible: one authoring cost, many distribution channels.

Not to confuse with `AGENTS.md` — a related but distinct project-level standard (the cross-tool equivalent of `CLAUDE.md`) donated to the Linux Foundation's Agentic AI Foundation in December 2025. It governs *project instructions*, not reusable skills; useful as a pointer file at the top of a marketplace repo, but irrelevant to the skill unit itself.

== Claude Code's plugin system is built for plural marketplaces, not single

This is the most load-bearing fact for both investigations. `/plugin marketplace add` accepts any number of entries; marketplace state is per-user in `~/.claude/plugins/known_marketplaces.json`; installs are namespaced (`plugin@marketplace`). Official docs formally document a *release channels* pattern — two marketplaces pointing at different refs of the same plugin repo for stable vs. latest — and that exact same primitive is what makes public-vs-private coexistence clean: two catalogs, zero code duplication.

== Plugin source is decoupled from marketplace source — the key degree of freedom

A marketplace is a catalog; each plugin entry declares *where that specific plugin lives*, independently of where the catalog itself is hosted. Plugin source types: relative path (`./plugins/foo`), `github` (`{repo: owner/name}`), `url` (any git URL), `git-subdir` (sparse-clone a monorepo path), `npm` (any registry). Two different marketplaces can therefore reference the same underlying plugin repo by `github`/`url` source and share it without copying. A version bump in the plugin repo flows into every marketplace that lists it.

== The "one ecosystem, not two" architecture — plugins as independent repos + thin catalog marketplaces

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

Plugin code lives in exactly one place. Each marketplace is a catalog of pointers. Public and private audiences see different menus over the same dishes. The same plugin repos can be consumed by non-Claude agents — clone them into `~/.codex/skills/`, `~/.gemini/skills/`, or symlink them via `skillkit`/`skillport` for Cursor/Cline/Copilot — because the plugin repo's content is just a `SKILL.md` folder tree. Claude Code's marketplace becomes *one consumer view*, not a lock-in.

== Cross-agent skill managers already exist — don't build one

A small ecosystem of OSS tools handles the fan-out to ecosystems that don't speak `SKILL.md` natively or don't run MCP. All of them take the same authoring unit:

#table(
  columns: (auto, auto, 1fr),
  [*Tool*], [*Model*], [*Trade-off*],
  [skillport], [CLI + MCP server], [Preserves progressive disclosure; requires background MCP process],
  [skillkit], [npm package manager], [45+ agent targets; translation is best-effort],
  [skillfish], [CLI], [One command, every agent; fewer registries],
  [Skills Manager], [Desktop GUI], [15+ tools; desktop-only],
  [openskills / npx skills], [Global loaders], [Lighter wrappers; smaller catalogs],
)

Two clean distribution patterns fall out of these tools, and they compose:

- *Pattern A — MCP-bridged runtime.* Run skillport (or a FastMCP Skills Provider) pointed at your repo; every MCP-speaking agent (Claude Code, Cursor, Copilot, Windsurf, Cline, Codex) reads from the same bus. Progressive disclosure preserved. Requires a background process; excludes non-MCP agents.
- *Pattern B — Static adapter builds.* CI step emits per-ecosystem artifacts into sidecar directories (`dist/cursor/.cursor/rules/`, `dist/cline/.clinerules/`, `dist/copilot/.github/skills/`). Works offline; adapters lose fidelity (Cursor rules are always-on, no model-invoked semantics).

== Private marketplaces: first-class, but with one known rough edge

Claude Code's docs explicitly support private-repo marketplaces: git credential helpers drive interactive use, and `GITHUB_TOKEN` / `GH_TOKEN` / `GITLAB_TOKEN` / `BITBUCKET_TOKEN` drive background auto-updates. Caveat: two open tracking issues (#9756, #17201) report that Claude Code's internal git library sometimes ignores `~/.gitconfig` credential helpers. Reliable fallbacks: (a) clone the private marketplace locally and register by path (`/plugin marketplace add /local/path`), or (b) export `GITHUB_TOKEN` explicitly in the shell that launches Claude Code. The local-path approach has a nice side-effect of instant edit propagation during development.

== `strict: false` and the curated-plugin pattern

A per-plugin marketplace flag. With `strict: false`, the marketplace entry becomes the authoritative definition rather than the plugin's `plugin.json`. The plugin repo can contain raw `SKILL.md` files, agents, scripts — and different marketplaces can expose *different subsets* of them to different audiences. This is orthogonal to the public/private split but useful when you want one raw plugin repo to surface a restricted subset publicly and the full set privately.

== Manifest-driven marketplace generation (optional polish)

To eliminate even the two-line manual sync between public and private `marketplace.json` files, maintain a single `plugins.yaml` listing every plugin with a `visibility: public | private` flag, and have a generator script (GitHub Action) emit both catalogs on push. Add a plugin once, both audiences update on the next CI run.

== Where full portability honestly breaks

- *Model-invoked discovery is Claude/Codex/Gemini territory.* Cursor rules and `.clinerules/` are always-on; a Claude skill ported there loses its autonomy.
- *Plugin-only Claude primitives don't translate.* Hooks, subagents, MCP-server bundles, slash commands have no 1:1 equivalent in Cursor/Cline. Keep them Claude-only; treat the cross-agent skill catalog as a strict subset.
- *Reserved marketplace names.* Anthropic reserves `agent-skills`, `anthropic-plugins`, and similar names — pick a distinctive one.
- *Path conventions aren't universal.* `~/.claude/skills/` vs. `~/.codex/skills/` vs. `~/.agents/skills/`. Skill managers paper over this; don't depend on a single canonical path yet.
- *Public monorepos can't hold private plugins.* If visibility is mixed, one-repo-per-plugin is structurally cleaner than `git-subdir` off a monorepo.

== Architectural recommendation

The two investigations converge on a single layered architecture:

+ *Plugin repos (one per plugin).* Each contains plain `SKILL.md` folders, optional Claude-specific extras (`plugin.json`, hooks, subagents, MCP servers) in a strict subset. Public plugins live in public repos; private plugins live in private repos.
+ *Two Claude Code marketplace repos.* Each is a pointer-only `.claude-plugin/marketplace.json`. Public lists public plugin repos by `github` source; private (itself a private GitHub repo) lists both public and private.
+ *Optional `plugins.yaml` + generator script* to eliminate manual catalog sync.
+ *Cross-agent fan-out* via skillkit or skillport pointed at the plugin repos directly — Claude's marketplace layer is bypassed for non-Claude tools.
+ *`GITHUB_TOKEN` in the shell* that launches Claude Code so private-marketplace updates work in background; fall back to local-path registration if the auth bug bites.

Result: authoring happens in N plugin repos. Distribution is two pointer files on the Claude side and direct consumption on other agents. Public and private audiences see different subsets of the same sources. No duplicate code, no mirroring pipeline, no lock-in to Claude as the distribution layer.

= Per-Prompt Detail

== 1. Cross-Agent Skill Portability and a Vendor-Neutral Marketplace

=== SKILL.md as de facto open standard

#table(
  columns: (auto, auto, 1fr),
  [*Tool*], [*Native SKILL.md*], [*Default location*],
  [Claude Code], [Yes (origin)], [`~/.claude/skills/<name>/SKILL.md`],
  [OpenAI Codex CLI], [Yes], [`~/.codex/skills/<name>/SKILL.md`],
  [ChatGPT], [Yes], [via hosted skill upload],
  [Gemini CLI], [Yes], [`~/.gemini/skills/`],
  [GitHub Copilot], [Yes (VS Code agent skills)], [`.github/skills/`],
  [Antigravity IDE], [Yes], [`~/.antigravity/skills/`],
  [Cursor], [Partial], [`.cursor/rules/*.mdc`],
  [Cline / Roo / Trae], [Partial], [`.clinerules/`],
  [Windsurf], [Partial], [`.windsurf/rules/`],
)

The authoring format has largely converged on `SKILL.md`. Installation path and invocation model (model-invoked progressive disclosure vs. always-on rules) are where vendors still diverge.

=== Recommended repo layout (one repo, three audiences)

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
│   └── <skill-name>/SKILL.md      # ← symlinks from plugins/*/skills/
├── skillkit.json                  # NEW: skillkit manifest
├── .skillport/config.yaml         # NEW: optional skillport config
├── AGENTS.md                      # NEW: pointer for AGENTS.md-aware agents
└── README.md
```

SKILL.md stays the canonical unit where Claude Code already expects it. The top-level `skills/` directory is either symlinks or produced by a tiny CI step that collects every SKILL.md into a flat catalog. Cross-agent tooling reads from `skills/`; Claude Code reads from `plugins/` via `marketplace.json`. Neither world interferes with the other.

=== How users install (per agent)

#table(
  columns: (auto, 1fr, 1fr),
  [*Agent*], [*Install command*], [*Mechanism*],
  [Claude Code], [`/plugin marketplace add owner/repo` then `/plugin install plugin@marketplace`], [Existing, unchanged],
  [Cursor], [`npx skillkit install github:owner/repo`], [Translates to `.cursor/rules/`],
  [Cline / Roo / Trae], [Same skillkit command], [Translates to `.clinerules/`],
  [Copilot (VS Code)], [Same skillkit command], [Translates to `.github/skills/`],
  [Codex CLI], [`cp -r skills/ ~/.codex/skills/` or skillkit], [SKILL.md is native],
  [Gemini CLI], [Same], [SKILL.md is native],
  [Any MCP client], [`skillport add github:owner/repo`], [MCP-bridged, progressive disclosure preserved],
)

=== Minimum viable first step

+ Leave the marketplace repo exactly as it is.
+ Add a top-level `skills/` symlink tree (one-line shell script in CI).
+ Add a `skillkit.json` at the root pointing at `skills/`.
+ README users: `npx skillkit install github:owner/<marketplace>` for non-Claude agents.

That unlocks Cursor, Cline, Copilot, Windsurf, Codex, Gemini installs with zero change to the Claude Code flow.

=== What not to do

- Don't hand-port skills into `.cursorrules` / `.clinerules/` format.
- Don't force Claude-specific primitives (hooks, subagents, MCP bundles) into portable skills.
- Don't depend on `~/.agents/skills/` as a universal install target yet.

== 2. Public + Private Plugin/Marketplace Coexistence

=== Plural marketplaces by design

`/plugin marketplace add` accepts any number of entries; marketplace state lives once per user in `~/.claude/plugins/known_marketplaces.json`. Installs are namespaced (`plugin@marketplace`). The docs formally document a *release channels* pattern (stable vs. latest marketplaces against the same plugin repo at different refs). Public-vs-private is the same primitive for a different axis.

=== Private marketplace auth

#table(
  columns: (auto, 1fr, 1fr),
  [*Provider*], [*Env vars*], [*Notes*],
  [GitHub], [`GITHUB_TOKEN` or `GH_TOKEN`], [Needs `repo` scope for private],
  [GitLab], [`GITLAB_TOKEN` or `GL_TOKEN`], [`read_repository` minimum],
  [Bitbucket], [`BITBUCKET_TOKEN`], [App password or repo token],
)

Open issues #9756 and #17201 track a credential-helper bug. Reliable workarounds: (a) clone the private marketplace locally and register by path, or (b) export `GITHUB_TOKEN` explicitly in the launching shell.

=== Plugin source types (the decoupling)

#table(
  columns: (auto, 1fr, 1fr),
  [*Source*], [*Shape*], [*Notes*],
  [Relative path], [`"./plugins/foo"`], [Plugin inside the marketplace repo],
  [`github`], [`{source, repo, ref?, sha?}`], [Separate GitHub repo],
  [`url`], [`{source, url, ref?, sha?}`], [Any git URL],
  [`git-subdir`], [`{source, url, path, ref?, sha?}`], [Subdirectory of a monorepo],
  [`npm`], [`{source, package, version?, registry?}`], [Public or private registry],
)

=== Example marketplace files

Public `marketplace.json`:

```json
{
  "name": "danielrosehill-plugins",
  "owner": { "name": "Daniel Rosehill" },
  "plugins": [
    { "name": "code-reviewer",
      "source": { "source": "github",
                  "repo": "danielrosehill/plugin-code-reviewer" } },
    { "name": "repo-retrofitter",
      "source": { "source": "github",
                  "repo": "danielrosehill/plugin-repo-retrofitter" } }
  ]
}
```

Private `marketplace.json`:

```json
{
  "name": "danielrosehill-private",
  "owner": { "name": "Daniel Rosehill" },
  "plugins": [
    { "name": "code-reviewer",
      "source": { "source": "github",
                  "repo": "danielrosehill/plugin-code-reviewer" } },
    { "name": "repo-retrofitter",
      "source": { "source": "github",
                  "repo": "danielrosehill/plugin-repo-retrofitter" } },
    { "name": "internal-tools",
      "source": { "source": "github",
                  "repo": "danielrosehill/plugin-internal-tools" } },
    { "name": "customer-workflows",
      "source": { "source": "github",
                  "repo": "danielrosehill/plugin-customer-workflows" } }
  ]
}
```

=== Manifest-driven generation

```
plugins:
  - name: code-reviewer
    repo: danielrosehill/plugin-code-reviewer
    visibility: public
  - name: internal-tools
    repo: danielrosehill/plugin-internal-tools
    visibility: private
```

A generator script (GitHub Action) emits each `marketplace.json` — public filters to `visibility: public`, private emits all. Add a plugin once, both catalogs update on next push.

=== `extraKnownMarketplaces` auto-registration

```json
{
  "extraKnownMarketplaces": {
    "danielrosehill-plugins": {
      "source": { "source": "github",
                  "repo": "danielrosehill/claude-marketplace" }
    },
    "danielrosehill-private": {
      "source": { "source": "github",
                  "repo": "danielrosehill/claude-marketplace-private" }
    }
  },
  "enabledPlugins": {
    "code-reviewer@danielrosehill-plugins": true,
    "internal-tools@danielrosehill-private": true
  }
}
```

=== Recommendation for Daniel's setup

+ Keep existing public plugins as standalone repos. Reference from the public `marketplace.json` via `{source: "github", repo: ...}`.
+ Create `Claude-Plugins-Marketplace-Private` as a private GitHub repo containing only `.claude-plugin/marketplace.json`.
+ Add `plugins.yaml` + generator script so both catalogs regenerate from a single manifest.
+ Export `GITHUB_TOKEN` in the launching shell; fall back to local-path clone if the auth bug bites.
+ Keep plugin repos agent-neutral — plain SKILL.md folders, no Claude-specific assumptions in the skill content.

= Consolidated Sources

== Official specs and documentation

- #link("https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview")[Agent Skills — Claude API Docs]
- #link("https://code.claude.com/docs/en/skills")[Extend Claude with skills — Claude Code Docs]
- #link("https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills")[Equipping agents for the real world with Agent Skills (Anthropic Engineering)]
- #link("https://code.claude.com/docs/en/plugin-marketplaces")[Create and distribute a plugin marketplace — Claude Code Docs]
- #link("https://github.com/anthropics/skills")[anthropics/skills — Public repository for Agent Skills]
- #link("https://developers.openai.com/codex/skills")[Agent Skills — Codex | OpenAI Developers]
- #link("https://github.com/openai/codex/blob/main/docs/skills.md")[codex/docs/skills.md — OpenAI Codex skills spec]
- #link("https://simonwillison.net/2025/Dec/12/openai-skills/")[OpenAI are quietly adopting skills — Simon Willison]
- #link("https://openai.com/index/agentic-ai-foundation/")[OpenAI co-founds the Agentic AI Foundation]
- #link("https://www.infoq.com/news/2025/08/agents-md/")[AGENTS.md Emerges as Open Standard — InfoQ]

== Claude Code issues and known rough edges

- #link("https://github.com/anthropics/claude-code/issues/9756")[claude-code #9756 — Support Auth on Private Marketplaces and Plugins]
- #link("https://github.com/anthropics/claude-code/issues/17201")[claude-code #17201 — marketplace add fails with private repos]

== Cross-agent skill managers

- #link("https://github.com/gotalab/skillport")[gotalab/skillport — Bring Agent Skills to Any AI Agent]
- #link("https://github.com/rohitg00/skillkit")[rohitg00/skillkit — Portable skills across 45 agents]
- #link("https://github.com/knoxgraeme/skillfish")[knoxgraeme/skillfish — One command, all agents]
- #link("https://github.com/xingkongliang/skills-manager")[xingkongliang/skills-manager — Desktop app for 15+ tools]
- #link("https://github.com/numman-ali/openskills")[numman-ali/openskills — Universal skills loader]
- #link("https://github.com/FrancyJGLisboa/agent-skill-creator")[FrancyJGLisboa/agent-skill-creator]
- #link("https://github.com/Karanjot786/agent-skills-cli")[Karanjot786/agent-skills-cli]
- #link("https://gofastmcp.com/servers/providers/skills")[FastMCP Skills Provider]

== Marketplace patterns and community guides

- #link("https://dominic-boettger.com/blog/claude-code-private-plugin-marketplace-guide/")[Dominic Böttger — Building a Private Claude Code Plugin Marketplace]
- #link("https://scottspence.com/posts/organising-claude-code-skills-into-plugin-marketplaces")[Scott Spence — Organising Claude Code Skills Into Plugin Marketplaces]
- #link("https://github.com/dashed/claude-marketplace")[dashed/claude-marketplace — Reference local marketplace]
- #link("https://github.com/anthropics/claude-plugins-official/blob/main/.claude-plugin/marketplace.json")[anthropics/claude-plugins-official marketplace.json]
- #link("https://github.com/aliceisjustplaying/claude-resources-monorepo")[aliceisjustplaying/claude-resources-monorepo]
- #link("https://alexmcfarland.substack.com/p/you-need-a-private-claude-plugin")[Alex McFarland — You Need a Private Claude Plugin Marketplace]

== Comparative and explanatory pieces

- #link("https://www.agensi.io/learn/claude-code-skills-vs-cursor-rules-vs-codex-skills")[Claude Code Skills vs Cursor Rules vs Codex Skills — Agensi]
- #link("https://www.agensi.io/learn/agent-skills-open-standard")[What Is the Agent Skills Open Standard? — Agensi]
- #link("https://medium.com/google-cloud/confused-about-where-to-put-your-agent-skills-ea778f3c64f3")[Confused About Where to Put Your Agent Skills? — Dazbo]
