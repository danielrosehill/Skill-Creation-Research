# WORKSPACE — Path Map

Quick reference for where things live in this research workspace. For the full contract, see `CLAUDE.md`.

## Inputs (human → agent)

| Path | Purpose |
|---|---|
| `context/from-human/` | Background notes, source material you provide |
| `context/from-internet/` | Web sources, articles, reference material |
| `prompts/drafting/` | Prompts under development |
| `prompts/queue/` | Prompts ready to run, in order |
| `voice-notes/` | Audio captures → transcripts → generated prompts |
| `private/` | Gitignored personal notes, credentials, drafts |

## Agent surfaces

| Path | Purpose |
|---|---|
| `context/from-history/` | Compacted summaries of prior research iterations |
| `prompts/run/initial/` | First-pass prompts that have been executed |
| `prompts/run/subsequent/` | Follow-up prompts that build on earlier outputs |
| `outputs/individual/` | Raw output from each prompt run (`YYYY-MM-DD-{slug}.md`) |
| `outputs/aggregated/markdown/` | Combined multi-output documents |
| `outputs/aggregated/pdf/` | PDF exports of aggregated research |
| `outputs/final/` | Polished deliverables |
| `outputs/published/` | Export-ready formats (blog, report, social) |
| `notes/` | Working notes, observations, methodology |

## Root files

| File | Role |
|---|---|
| `SCOPE.md` | What this research project is and isn't |
| `CONTEXT.md` | Always-on background — topic, framing, key facts |
| `MEMORY.md` | Persistent memory policy (default store: `context/from-history/`) |
| `WORKSPACE.md` | This file — path map |
| `CLAUDE.md` | Full agent instructions and workflow |
| `exchanges.yaml` | Machine-readable log of every prompt/output exchange (auto-maintained) |
