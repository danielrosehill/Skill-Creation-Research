# Run Next Prompt

Execute the next research prompt in the workflow.

## Steps

1. Check `prompts/queue/` for any queued prompts. If found, take the first one (alphabetically).
2. If no queued prompts, check `prompts/run/initial/` for unexecuted initial prompts.
3. If no initial prompts remain, check `prompts/run/subsequent/` for follow-up prompts.
4. Before running, read all files in `context/from-human/`, `context/from-history/`, and `context/from-internet/` to build full context.
5. **Thread check**: Is there an active thread from today on the same topic in `outputs/individual/`? If yes, append as the next exchange. If no, create a new file.
6. Execute the prompt: conduct the research, use web search and reasoning as needed.
7. Save output following thread-mode format (see CLAUDE.md → Thread Mode):
   - New thread: create `outputs/individual/YYYY-MM-DD-{slug}.md` with full thread frontmatter, AI disclaimer, and Exchange 1.
   - Existing thread: append `## Exchange N` to the active thread file and update `exchange_count` in frontmatter.
8. If the prompt came from `prompts/queue/`, move it to `prompts/run/initial/` or `prompts/run/subsequent/` as appropriate.
9. **Log to exchanges.yaml**: append an entry with id, date, prompt_path, prompt_summary, output_path, exchange_in_file, thread slug, and tools_used.
10. **Same-day consolidation check** (separate files only): if there are now 2+ separate output files from today, remind the user about `/consolidate-day`. Threaded exchanges within a single file don't need consolidation.
11. Report what was run and a brief summary of findings, including the output path and exchange number.
