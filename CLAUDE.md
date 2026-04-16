# Research Workspace — Claude Code Instructions

## What This Is

This is a **public research workspace** powered by Claude Code. It uses a folder-based pattern for iterative AI research: context goes in, prompts get run, outputs get saved, and previous outputs feed back as context for deeper investigation.

**This repository is public.** All outputs, prompts, and context files (except those in `private/`) are visible to anyone. Write accordingly.

## Root orientation files (read these first)

| File | Role |
|---|---|
| `CONTEXT.md` | Always-on background: topic, framing, key domain facts |
| `MEMORY.md` | Persistent-memory policy (default store: `context/from-history/`) |
| `WORKSPACE.md` | Quick path map of the folder contract below |

These are stable orientation. The live research state lives in `outputs/individual/` and `context/from-history/`.

## Research Workflow

### Voice note workflow

Use `/voice-note` to go from a voice recording to a running research prompt in one step:

1. Place an audio file in the project root (or provide a path)
2. The command creates `voice-notes/YYYY-MM-DD-HHMMSS/` containing:
   - The original audio file (copied)
   - `raw-transcript.md` — verbatim AssemblyAI transcription
   - `research-prompt.md` — cleaned, structured research prompt
3. The prompt is copied to `prompts/queue/` and can be run immediately

This requires an AssemblyAI API key in `.env`. See `.env.example` and `publishing-config.example.json` for setup.

### Prompts given directly in chat

If the user supplies a research prompt directly in the chat (rather than placing a file in `prompts/queue/`), first persist it before acting on it:

1. Save the prompt verbatim to `prompts/run/initial/YYYY-MM-DD-{slug}.md` (or `prompts/run/subsequent/` if it builds on prior outputs), using today's date.
2. Then process it following the normal "Running a prompt" workflow below.

This guarantees every piece of research in the repo has a corresponding, dated prompt file on disk — no prompts live only in ephemeral chat history.

### Running a prompt

1. Read all files in `context/` to build background understanding
2. Read the prompt file from `prompts/run/` (initial or subsequent)
3. Conduct the research using available tools (web search, document analysis, reasoning)
4. Save the output following the thread-mode rules below
5. If the prompt file was in `prompts/queue/`, move it to the appropriate `prompts/run/` folder after execution
6. Log the exchange to `exchanges.yaml` (see Exchange Log below)

### Building on previous work

Before running any subsequent prompt, always read:
- All files in `context/from-history/` (compacted prior findings)
- All files in `context/from-human/` (operator-provided material)
- The most recent outputs in `outputs/individual/` if they're relevant

## Thread Mode (default behaviour)

Successive prompts on the same topic are **appended to a single output file** as numbered exchanges rather than split into separate files. This is the default.

### How it works

1. **First prompt on a topic** creates `outputs/individual/YYYY-MM-DD-{slug}.md` with Exchange 1.
2. **Follow-up prompts in the same session on the same topic** append as Exchange 2, 3, etc. to the same file.
3. Each exchange gets its own `### Exchange N` heading, provenance sub-block, key findings, and sources.
4. The file's top-level provenance block records the thread as a whole.

### Thread output format

```markdown
---
thread: YYYY-MM-DD-{slug}
topic: Short description of the thread topic
started: YYYY-MM-DD
exchange_count: N
---

> **Note**: This output was produced through AI-assisted research using Claude Code.

# {Thread Topic}

## Exchange 1

**Prompt**: prompts/run/initial/YYYY-MM-DD-{slug}.md
**Summary**: One-sentence restatement.

### Key Findings

...

### Sources

...

## Exchange 2

**Prompt**: prompts/run/subsequent/YYYY-MM-DD-{slug-2}.md
**Summary**: One-sentence restatement.

### Key Findings

...

### Sources

...
```

### When to start a new file instead

- The user explicitly says "separate output", "new file", or similar
- The new prompt is on a **clearly different topic** from the active thread
- It's a new day (threads don't span midnight — start a fresh file)

When in doubt, ask: "This looks related to the current thread — append, or start a new file?"

### Updating the thread frontmatter

After appending an exchange, update `exchange_count` in the top-level provenance block.

## Exchange Log (`exchanges.yaml`)

Every prompt/output exchange is logged to `exchanges.yaml` at the repo root. This is the canonical machine-readable record of all research activity.

### Schema

```yaml
exchanges:
  - id: 1
    date: "2026-04-12"
    prompt_path: "prompts/run/initial/2026-04-12-example.md"
    prompt_summary: "What are the main approaches to distributed caching?"
    output_path: "outputs/individual/2026-04-12-distributed-caching.md"
    exchange_in_file: 1
    thread: "2026-04-12-distributed-caching"
    tools_used:
      - web_search
      - document_analysis

  - id: 2
    date: "2026-04-12"
    prompt_path: "prompts/run/subsequent/2026-04-12-redis-vs-memcached.md"
    prompt_summary: "How does Redis compare to Memcached for session storage?"
    output_path: "outputs/individual/2026-04-12-distributed-caching.md"
    exchange_in_file: 2
    thread: "2026-04-12-distributed-caching"
    tools_used:
      - web_search
```

### Fields

| Field | Type | Description |
|---|---|---|
| `id` | int | Auto-incrementing, 1-based |
| `date` | string | ISO date of the exchange |
| `prompt_path` | string | Path to the persisted prompt file |
| `prompt_summary` | string | One-sentence restatement |
| `output_path` | string | Path to the output file (thread file if threaded) |
| `exchange_in_file` | int | Which exchange number within the output file |
| `thread` | string | Thread slug — matches the output filename stem |
| `tools_used` | list | Which research tools were used (web_search, document_analysis, reasoning, etc.) |

### Rules

- Append-only. Never rewrite or reorder existing entries.
- Create the file with a header comment on first use:
  ```yaml
  # Research exchange log — auto-maintained, do not edit manually
  exchanges:
  ```
- Log the exchange **after** the output is written, so paths are accurate.

## Output formatting

- Use clear markdown with headers, bullet points, and tables where appropriate
- Include a `### Sources` section at the end of every exchange
- Use `### Key Findings` as the opening section of each exchange
- Date-stamp all output filenames (`YYYY-MM-DD-{slug}.md`)
- Include a brief `> **Note**: This output was produced through AI-assisted research using Claude Code.` disclaimer below the thread provenance block
- Write each output so it can stand alone — a reader should be able to understand the findings without reading other files in the repo

## Same-day consolidation

When several **separate** output files (not threaded exchanges) exist from the same day, use `/consolidate-day` to merge them into `outputs/aggregated/markdown/YYYY-MM-DD-daily-digest.md`. After creating a new separate file, if other files from the same day already exist, remind the user that `/consolidate-day` is available — do not auto-merge without being asked.

Note: threaded exchanges within a single file don't need consolidation — they're already together.

## Compaction

When instructed to compact (or when context is getting large), summarize the current research state:
- Read all files in `outputs/individual/`
- Create a comprehensive summary in `context/from-history/` named `YYYY-MM-DD-compaction.md`
- The summary should preserve key findings, sources, open questions, and contradictions
- This becomes the foundation context for subsequent research iterations

## Aggregation

When instructed to aggregate:
- Combine relevant individual outputs into a single document in `outputs/aggregated/markdown/`
- Add a cover section with research topic, date range, and methodology summary
- Compile all sources into a unified references section
- Optionally generate PDF to `outputs/aggregated/pdf/`

## Public Repository Awareness

This workspace is designed to be shared publicly. Every file committed to this repo (outside `private/`) may be read by external audiences — researchers, journalists, developers, or curious readers.

### Writing for a public audience

- **Assume no prior context.** Each output should be self-contained enough that a reader arriving from a link can understand the findings without reading every other file.
- **Lead with key findings.** Don't bury the takeaway — external readers will skim.
- **Cite everything.** Include URLs, paper titles, author names, dates. External readers need to verify claims.
- **Flag AI-generated content honestly.** Outputs should include a note that they were produced using AI-assisted research. The prompts that generated them are visible in the repo.
- **Avoid internal shorthand.** Don't reference "the brief" or "last iteration" without linking to the actual file.
- **Use accessible language.** Prefer plain English over jargon where possible. Define technical terms on first use.

### What stays private

The `private/` directory is gitignored. Use it for:
- Personal notes, hunches, or rough thinking
- API keys, credentials, or configuration
- Draft ideas you're not ready to share
- Anything you wouldn't want on the public internet

### README as the public front door

The `README.md` is the first thing external visitors see. It should always reflect the current state of the research — topic, status, key findings, and how to navigate the outputs. Use the `/publish-readme` slash command to regenerate it.

## Behaviour Guidelines

- Be thorough and cite sources
- Flag uncertainty and contradictions explicitly
- Distinguish between established facts, emerging consensus, and speculation
- When web searching, try multiple queries and cross-reference
- Preserve the full reasoning chain in outputs — these are research documents, not chat responses
- Write outputs as if they will be read by someone with no access to you — because they will be
