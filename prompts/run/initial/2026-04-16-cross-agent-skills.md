# Cross-agent-compatible skills and marketplace distribution

**Date**: 2026-04-16
**Source**: chat prompt (lightly cleaned)

## Prompt

Agent skills are very useful, but it doesn't make sense to lock them into one vendor ecosystem — the most useful skill definitions are developed so they can be installed across agent frameworks.

I use Claude Code and create plugins for my own use, most of which are also open-sourced on my marketplace. What's the way to do this in a cross-agent-compatible way that I could also continue using via Claude, ideally as seamlessly as possible — following a similar method of creating a marketplace that I can update in one place rather than having to set up each plugin one by one?

## Interpretation

Daniel wants:

1. A skill-authoring pattern that is **portable** across multiple agent ecosystems (Claude Code, Cursor, Cline, Continue, Windsurf, OpenAI Agents SDK, etc.), not locked to Anthropic.
2. To continue using **Claude Code** as his primary agent and keep the ergonomic parts of the current workflow — `SKILL.md` progressive disclosure, slash commands, his existing plugin marketplace.
3. A **single-source-of-truth marketplace repo** that he can maintain and update in one place, which then publishes/syncs to multiple agent ecosystems, instead of re-authoring each skill for each vendor.

## Expected output

A concrete technical recommendation covering:
- The current landscape of skill formats (Anthropic Skills, Cursor Rules, Cline/Roo/Continue rules, OpenAI Agents, etc.) and what overlaps between them.
- Emerging standards or community conventions that aim to be cross-agent (e.g. AGENTS.md, MCP, open skill formats).
- A concrete pattern Daniel can adopt — directory layout, authoring format, build/sync pipeline — to maintain skills once and distribute everywhere.
- Trade-offs and where full portability breaks (e.g. Claude's model-invoked skill autonomy vs. Cursor's always-on rules).
