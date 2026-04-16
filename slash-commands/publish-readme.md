# Update README for Public Audience

Regenerate the README.md to reflect the current state of the research for external visitors.

## Steps

1. Read `context/from-human/research-brief.md` for the research topic, scope, and audience.
2. Read the most recent compaction in `context/from-history/` (if any) for a summary of findings.
3. Scan `outputs/individual/` and `outputs/aggregated/` to understand what's been produced.
4. Count prompts in `prompts/queue/`, `prompts/run/initial/`, and `prompts/run/subsequent/`.
5. Check `outputs/published/` for any export-ready documents.
6. Rewrite `README.md` with this structure:

   ```
   # {Research Topic Title}

   > One-line description of the research question or topic.

   ## About This Research

   {2-3 paragraphs: what this research investigates, why it matters, and who it's for}

   ## Key Findings

   {Bullet-point summary of the most important findings so far, or "Research in progress" if early stage}

   ## Research Status

   | Metric | Count |
   |--------|-------|
   | Research iterations completed | N |
   | Follow-up investigations | N |
   | Prompts in queue | N |
   | Published exports | N |

   ## How to Navigate This Repo

   {Brief guide to the directory structure — where to find outputs, methodology, raw prompts}

   | Directory | What You'll Find |
   |-----------|-----------------|
   | `outputs/individual/` | Raw research outputs from each iteration |
   | `outputs/aggregated/` | Combined reports and PDF exports |
   | `outputs/published/` | Blog posts, briefs, and other shareable formats |
   | `prompts/` | The prompts used to conduct this research |
   | `context/` | Background material and compacted history |

   ## Methodology

   {Brief description: AI-assisted research using Claude Code, iterative prompting, compaction loop}

   ## How This Workspace Works

   This repo uses the [Claude Research Space](https://github.com/danielrosehill/Claude-Research-Space-Public-Template) template — a folder-based pattern for iterative AI research. See CLAUDE.md for the full system instructions.

   ## License

   {License from the repo}

   ## Disclaimer

   This research was conducted using AI-assisted tools. Outputs should be independently verified. The prompts, methodology, and raw outputs are fully transparent in this repository.
   ```

7. Preserve the Claude Code Projects Index badge at the top if it exists.
8. Report what was updated.
