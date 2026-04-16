---
date: 2026-04-16
type: initial
topic: Coexisting public and private plugin/skill marketplaces for Claude Code (and agent-agnostic authoring)
---

# Public + Private Plugin/Marketplace Coexistence

Plugins are great, but they fall down a bit when you want a **local** plugin — i.e. skills for your own use that you don't want to open-source by publishing to a publicly available marketplace.

The same challenge exists if you want to **detach your plugin and skill development from Claude as a platform**.

If you wanted to develop a public marketplace **and**, in tandem, a private repository for pulling in your own agent skills — what would be the most elegant solution to do both **without having to maintain two parallel ecosystems**?

Specifically:

- How does Claude Code's plugin/marketplace mechanism handle private git repos?
- Can multiple marketplaces (one public, one private) be registered and used side-by-side?
- What's the cleanest way to avoid duplicating plugin code, tooling, or metadata between the two?
- Are there patterns (monorepo + CI mirror, submodules, manifest-driven marketplaces, framework-neutral source-of-truth) that keep authoring in one place while exposing different subsets to different audiences?
- Does this generalize beyond Claude — i.e. can the same source-of-truth feed a Cursor/Copilot/Codex skill distribution as well?
