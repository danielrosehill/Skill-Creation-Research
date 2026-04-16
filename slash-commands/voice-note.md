# Voice Note → Research Prompt

Transcribe a voice note, clean it into a structured research prompt, and optionally run it.

## Arguments

The user may provide a path to an audio file (e.g., `/voice-note ~/Downloads/recording.mp3`). If no path is given, look for the most recent audio file (`.mp3`, `.m4a`, `.wav`, `.ogg`, `.webm`, `.flac`) in the project root directory.

## Steps

### 1. Locate the audio file

- If a path argument was provided, use that file.
- If no argument, scan the project root for audio files and pick the most recent one.
- If no audio file is found, ask the user to provide a path.

### 2. Create a timestamped folder

Create a folder: `voice-notes/YYYY-MM-DD-HHMMSS/`

Use the current date and time for the timestamp.

### 3. Copy the audio file

Copy (do not move) the original audio file into the timestamped folder, preserving the original filename.

### 4. Transcribe

Run the transcription helper script:

```bash
python3 scripts/transcribe.py "<path-to-audio-file>" "voice-notes/YYYY-MM-DD-HHMMSS/raw-transcript.md"
```

This uploads the file to AssemblyAI, transcribes it, and saves the raw text.

If the script fails (missing API key, network error), stop and tell the user what went wrong.

### 5. Format the raw transcript

Read `voice-notes/YYYY-MM-DD-HHMMSS/raw-transcript.md` and save a lightly formatted version back to the same file — add a markdown header and preserve the original text exactly:

```markdown
# Raw Transcript

> Transcribed from `<original-filename>` on YYYY-MM-DD using AssemblyAI.

<raw transcript text>
```

### 6. Generate a structured research prompt

Read the raw transcript and interpret what the user is asking to be researched. Transform it into a clear, well-structured research prompt. Save it as:

`voice-notes/YYYY-MM-DD-HHMMSS/research-prompt.md`

The prompt should follow this structure:

```markdown
# Research Prompt

> Generated from voice note `<original-filename>` on YYYY-MM-DD.

## Research Question

<Clear, concise statement of what to investigate>

## Scope

<Boundaries — what's in and out of scope>

## Key Areas to Explore

- <area 1>
- <area 2>
- ...

## Specific Questions

1. <question>
2. <question>
3. ...

## Context

<Any background or constraints mentioned in the voice note>

## Desired Output

<What form the answer should take — comparison table, summary, recommendation, etc.>
```

Use your best judgment to interpret the voice note. If the user was rambling or thinking out loud, distill the core research intent. If they were precise, preserve their specificity.

### 7. Queue the prompt

Copy `voice-notes/YYYY-MM-DD-HHMMSS/research-prompt.md` to `prompts/queue/` with the filename format: `YYYY-MM-DD-<slug>.md` where `<slug>` is a short descriptive name derived from the research question.

### 8. Report and offer to run

Tell the user:
- Where the voice note artifacts are saved (the timestamped folder)
- A brief summary of what you interpreted the research question to be
- That the prompt has been queued

Then ask: **"Want me to run this prompt now?"**

If they say yes, execute `/run-prompt`.
