# Export Research for Publishing

Format research outputs for sharing on external platforms.

## Usage

When run, ask the user which format they want (or accept as an argument):

- `blog` — Long-form blog post (1500-3000 words)
- `report` — Formal research report with executive summary
- `brief` — One-page briefing document
- `social` — Thread-style summary (numbered points, each under 280 chars)
- `newsletter` — Email-friendly digest format

## Steps

1. Read all files in `outputs/individual/` and `outputs/aggregated/markdown/` to understand the full body of research.
2. Read `context/from-human/research-brief.md` for topic and audience context.
3. Generate the requested format and save to `outputs/published/YYYY-MM-DD-{format}-{slug}.md`.
4. Each exported document must include:
   - **Title** appropriate to the format
   - **Attribution**: "Research conducted using [Claude Code](https://claude.ai/code) — an AI-assisted research workspace. Prompts, methodology, and raw outputs are available in the [source repository](.)."
   - **Sources** section (consolidated from all referenced outputs)
   - **License** note matching the repo license
5. For `blog` format: use an engaging opening, subheadings, and a conclusion with open questions.
6. For `report` format: include executive summary, methodology, findings, analysis, recommendations, and appendix.
7. For `brief` format: one page max — key findings, implications, and 3-5 bullet recommendations.
8. For `social` format: create a numbered thread. First post hooks the reader, subsequent posts cover findings, final post links to the full repo.
9. For `newsletter` format: conversational tone, scannable structure, clear CTA to read the full research.
10. Report the file path and a word count when done.
