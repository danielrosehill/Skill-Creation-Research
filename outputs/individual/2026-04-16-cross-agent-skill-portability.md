---
thread: 2026-04-16-cross-agent-skill-portability
topic: Authoring agent skills once and distributing them across Claude Code, Cursor, Cline, Copilot, Codex and other agent ecosystems via a single marketplace-style repo
started: 2026-04-16
exchange_count: 1
---

> **Note**: This output was produced through AI-assisted research using Claude Code.

# Cross-Agent Skill Portability and a Vendor-Neutral Marketplace

## Exchange 1

**Prompt**: `prompts/run/initial/2026-04-16-cross-agent-skills.md`
**Summary**: How to author agent skills so they install across multiple agent frameworks while preserving a centralized, marketplace-style update flow — ideally without abandoning the Claude Code plugin marketplace Daniel already runs.

### Key Findings

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

- ✅ Single source of truth, zero format conversion, preserves model-invoked semantics.
- ✅ Updates propagate instantly.
- ❌ Requires a background MCP process per machine.
- ❌ Non-MCP agents (plain `.cursorrules` users, older tools) are left out.

**Pattern B — Static adapter builds (publish-time).**
Keep SKILL.md as canonical. Run a build step (GitHub Action + `skillkit build` or a custom script) that emits per-ecosystem artifacts into sidecar directories or companion branches: `dist/cursor/.cursor/rules/`, `dist/cline/.clinerules/`, `dist/copilot/.github/skills/`, etc. Users install via whatever their ecosystem supports — copy a directory, pull a branch, or `skillkit install github:daniel/marketplace`.

- ✅ Works for tools with no MCP support.
- ✅ Entirely static — no runtime.
- ❌ Adapters lose fidelity (Cursor rules are always-on — no progressive disclosure).
- ❌ More maintenance; format translation can drift silently.

#### 5. Where full portability breaks — the honest caveats

- **Model-invoked discovery is Claude/Codex/Gemini territory.** Cursor rules and `.clinerules/` are loaded into every request. If you port a Claude skill over, it becomes an always-on rule and loses the autonomy Daniel currently benefits from.
- **Plugin-only features don't translate.** Slash commands, hooks, agents, and MCP-server bundles in a Claude Code plugin have no 1:1 equivalent in Cursor or Cline. Cursor has "commands" as a separate concept; Cline has "workflows". These should stay Claude-specific.
- **Reserved marketplace names.** Anthropic reserves a list of names (`agent-skills`, `anthropic-plugins`, etc.) — pick a distinctive marketplace name you can use anywhere.
- **Path conventions are not universal.** `~/.claude/skills/` vs. `~/.codex/skills/` vs. `~/.agents/skills/`. The ecosystem hasn't picked a winner; skill *managers* paper over this.

### Recommended approach for Daniel

A low-friction, change-as-little-as-possible design that preserves his current Claude Code plugin marketplace:

#### Repository layout (one repo, three audiences)

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

The key move: **SKILL.md stays the canonical unit**, and it lives under `plugins/<plugin>/skills/<skill>/` where Claude Code already expects it. The top-level `skills/` directory is either a set of symlinks or produced by a tiny CI step that collects every SKILL.md out of the plugin tree into a flat catalog. Cross-agent tooling reads from `skills/`; Claude Code reads from `plugins/` via `marketplace.json`. Neither world interferes with the other.

#### How users install (per agent)

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

#### Minimum viable first step

If Daniel doesn't want to restructure today:

1. Leave the marketplace repo exactly as it is.
2. Add a top-level `skills/` symlink tree (one-line shell script in CI, commits on push).
3. Add a `skillkit.json` at the root that points at `skills/`.
4. Tell users on the README: `npx skillkit install github:danielrosehill/<marketplace>` for non-Claude agents.

That unlocks Cursor, Cline, Copilot, Windsurf, Codex, Gemini installs with zero change to the Claude Code flow. Pattern A (MCP-bridged via skillport) can be added later for users who want model-invoked semantics everywhere.

#### What to *not* do

- Don't hand-port skills into `.cursorrules` / `.clinerules/` format. Format translation is exactly what skillkit/skillport exist to do, and doing it by hand defeats the "update in one place" goal.
- Don't try to force Claude-specific primitives (hooks, subagents, MCP bundles) into portable skills. Keep those Claude-only in the plugin tree; the cross-agent skill catalog is a strict subset.
- Don't depend on `~/.agents/skills/` as a universal install target yet — it's an emerging convention, not a spec, and skill managers do the right thing on each platform anyway.

### Sources

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
- [gotalab/skillport — Bring Agent Skills to Any AI Agent via CLI or MCP](https://github.com/gotalab/skillport)
- [rohitg00/skillkit — Portable skills across 45 agents](https://github.com/rohitg00/skillkit)
- [knoxgraeme/skillfish — One command, all agents](https://github.com/knoxgraeme/skillfish)
- [xingkongliang/skills-manager — Desktop app for 15+ tools](https://github.com/xingkongliang/skills-manager)
- [numman-ali/openskills — Universal skills loader](https://github.com/numman-ali/openskills)
- [FrancyJGLisboa/agent-skill-creator — One SKILL.md, every platform](https://github.com/FrancyJGLisboa/agent-skill-creator)
- [Karanjot786/agent-skills-cli — Universal CLI for Agent Skills](https://github.com/Karanjot786/agent-skills-cli)
- [Claude Code Skills vs Cursor Rules vs Codex Skills — Agensi](https://www.agensi.io/learn/claude-code-skills-vs-cursor-rules-vs-codex-skills)
- [What Is the Agent Skills Open Standard? (2026 Explainer) — Agensi](https://www.agensi.io/learn/agent-skills-open-standard)
- [Confused About Where to Put Your Agent Skills? — Dazbo on Medium](https://medium.com/google-cloud/confused-about-where-to-put-your-agent-skills-ea778f3c64f3)
- [Skills Provider — FastMCP docs](https://gofastmcp.com/servers/providers/skills)
