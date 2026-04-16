# MEMORY — Persistence Policy

Where durable knowledge about this research project lives.

## Default store

`context/from-history/` is the canonical persistent-memory store. Compacted summaries of prior research iterations are written here as `YYYY-MM-DD-compaction.md` and read at the start of subsequent runs.

## What goes where

| Kind of memory | Location |
|---|---|
| Compacted findings from prior iterations | `context/from-history/` |
| Human-authored background and source material | `context/from-human/` |
| Web sources and external reference material | `context/from-internet/` |
| Working notes, hunches, methodology | `notes/` |
| Private/unshared thinking | `private/` (gitignored) |

## Compaction

When context grows large, run a compaction pass: read `outputs/individual/`, distill key findings, open questions, and contradictions into a dated file in `context/from-history/`. This becomes the foundation for the next iteration. See `CLAUDE.md` → *Compaction* for the full procedure.

## Exchange log

`exchanges.yaml` at the repo root is the machine-readable record of every prompt/output exchange. It is append-only and auto-maintained — do not edit manually. Use it to reconstruct the full research timeline, thread membership, and tool usage programmatically.

## Optional vector layer

If a vector store (e.g. Pinecone MCP) is available, treat it as an *addition* to `context/from-history/`, not a replacement — always mirror durable context to markdown so the workspace stays usable offline and version-controlled.
