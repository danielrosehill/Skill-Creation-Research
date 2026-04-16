[![Claude Code Projects Index](https://img.shields.io/badge/Claude%20Code-Projects%20Index-blue?style=flat-square&logo=github)](https://github.com/danielrosehill/Claude-Code-Repos-Index)

> **See also**: [Claude Research Workspace](https://github.com/danielrosehill/Claude-Research-Workspace-General-Template) — the private/personal version of this template (no public-audience features, no export commands).

# Open Research Workspace — Claude Code Template

A template for conducting **public, transparent AI-assisted research** using Claude Code as the execution engine. Fork it, fill in your research brief, and start investigating — with every prompt, output, and methodology choice visible to the world.

## What Makes This Different

This isn't just a research workspace — it's designed to be **open-sourced from day one**. That means:

- **Full transparency**: Every prompt, every output, every compaction is committed to the repo. Readers can trace exactly how conclusions were reached.
- **External-audience outputs**: The agent writes findings for public readers, not just the researcher. Key findings are accessible, well-cited, and self-contained.
- **Export-ready**: Built-in commands to format research as blog posts, reports, briefing documents, and social media threads.
- **Publishing integrations**: Scaffold MCP connections to WordPress, Ghost, Notion, and more.
- **AI disclosure**: All outputs include a standard note that they were produced using AI-assisted research.

## Getting Started

### 1. Use this template

Click **Use this template** on GitHub, or run:

```bash
./new-project.sh "my-research-topic" ~/repos/github/
```

### 2. Set up your research brief

Edit `context/from-human/research-brief.md` with:
- Your research topic and scope
- Key questions to investigate
- **Intended audience** — who will read this?
- **Licensing** — how should others use your findings?

### 3. Write your first prompt (or record a voice note)

**Option A — Write it:** Create a prompt in `prompts/run/initial/` describing what you want to investigate. See the example prompt for the format.

**Option B — Speak it:** Record a voice note, drop the audio file in the project root, and run:

```
/voice-note
```

This transcribes your recording via AssemblyAI, distills it into a structured research prompt, and queues it — preserving the audio, raw transcript, and cleaned prompt in a timestamped `voice-notes/` folder. Requires an AssemblyAI API key in `.env` (see `.env.example`).

### 4. Run it

Open the repo in Claude Code and tell it to run the prompt:

```
/run-prompt
```

### 5. Iterate, export, share

- Review outputs in `outputs/individual/`
- Write follow-up prompts in `prompts/run/subsequent/`
- When ready to share: `/export blog` or `/export report`
- Update the public README: `/publish-readme`

## Directory Structure

```
├── .env.example                 # API keys template (copy to .env)
├── CLAUDE.md                    # System instructions for Claude Code
├── context/
│   ├── from-human/              # Your research brief and background info
│   ├── from-history/            # Compacted findings from prior iterations
│   └── from-internet/           # Saved web sources and references
├── prompts/
│   ├── drafting/                # Prompts under development
│   ├── queue/                   # Ready to run (ordered)
│   └── run/
│       ├── initial/             # First-pass research prompts
│       └── subsequent/          # Follow-up prompts
├── outputs/
│   ├── individual/              # Per-prompt research outputs
│   ├── aggregated/
│   │   ├── markdown/            # Combined research documents
│   │   └── pdf/                 # PDF exports
│   ├── published/               # Export-ready formats (blog, report, social)
│   └── final/                   # Polished deliverables
├── private/                     # Researcher's private notes (gitignored)
├── scripts/
│   └── transcribe.py            # AssemblyAI transcription helper
├── slash-commands/              # Custom Claude Code slash commands
├── voice-notes/                 # Timestamped voice note artifacts
└── notes/                       # Working notes and methodology
```

## Workflow

```
 ┌─────────────┐
 │   Context    │◄──────────────────────┐
 │  (from-human │                       │
 │  from-history│                       │
 │  from-internet)                      │
 └──────┬──────┘                        │
        │                               │
        ▼                               │
 ┌─────────────┐                        │
 │   Prompt     │                       │
 │  (queue/run) │                       │
 └──────┬──────┘                        │
        │                               │
        ▼                               │
 ┌─────────────┐      ┌────────────┐    │
 │   Claude     │─────►│  Output    │    │
 │   Code       │      │ (individual)   │
 └─────────────┘      └──────┬─────┘    │
                             │          │
                     ┌───────┴───────┐  │
                     │  Compaction   │──┘
                     │  (summarise   │
                     │   → history)  │
                     └───────┬───────┘
                             │
                     ┌───────┴───────┐
                     │               │
                     ▼               ▼
              ┌────────────┐  ┌────────────┐
              │ Aggregation│  │   Export    │
              │ (combined  │  │ (blog, rpt,│
              │  report)   │  │  social)   │
              └────────────┘  └────────────┘
```

## Slash Commands

| Command | Purpose |
|---------|---------|
| `/run-prompt` | Execute the next prompt in the queue |
| `/compact` | Summarise outputs into compacted history |
| `/aggregate` | Combine individual outputs into a single document |
| `/status` | Show research progress |
| `/export` | Format outputs for publishing (blog, report, brief, social, newsletter) |
| `/publish-readme` | Regenerate README.md with current findings for external readers |
| `/voice-note` | Transcribe a voice recording → structured research prompt → queue |
| `/setup-publishing` | Scaffold `.mcp.json` for CMS/publishing integrations |

## For Readers

If you're here to **read the research** (not use the template), here's where to look:

- **`outputs/published/`** — Polished, export-ready versions of the findings
- **`outputs/aggregated/markdown/`** — Full combined research reports
- **`outputs/individual/`** — Raw outputs from each research iteration
- **`prompts/`** — The exact prompts used, so you can see what questions were asked
- **`context/from-human/research-brief.md`** — The original research brief

## For Researchers

If you want to **use this template** for your own public research:

1. Click **Use this template** on GitHub
2. Replace the research brief with your topic
3. Clear the example prompts
4. Start researching with Claude Code
5. Everything you commit is public — use `private/` for anything you want to keep off the record

## Design Philosophy

- **Transparency by default**: The research process is the product, not just the findings
- **Filesystem as workflow engine**: Folder structure defines the process
- **Markdown-native**: Everything is plain text, version-controlled, portable
- **Compaction over RAG**: Summarise and feed back rather than vectorise
- **Iterative deepening**: Each round builds on compacted findings from the last
- **Export-ready**: Research should flow naturally from workspace to publication

## Disclaimer

Research in this workspace is conducted using AI-assisted tools (Claude Code). All prompts, methodology, and raw outputs are transparent in the repository. Findings should be independently verified before being relied upon for decision-making.

## License

MIT

---

For more Claude Code projects, visit my [Claude Code Projects Index](https://github.com/danielrosehill/Claude-Code-Repos-Index).
