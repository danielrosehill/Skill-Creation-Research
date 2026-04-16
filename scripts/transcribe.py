#!/usr/bin/env python3
"""Transcribe a local audio file using AssemblyAI's API.

Usage:
    python scripts/transcribe.py <audio-file-path> <output-path>

Reads ASSEMBLYAI_API_KEY from .env or environment.
Writes the raw transcript text to <output-path>.
"""

import json
import os
import sys
import time
import urllib.request

def load_env():
    """Load .env file if present."""
    env_path = os.path.join(os.path.dirname(__file__), "..", ".env")
    if os.path.exists(env_path):
        with open(env_path) as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith("#") and "=" in line:
                    key, _, value = line.partition("=")
                    os.environ.setdefault(key.strip(), value.strip())

def upload_file(api_key, file_path):
    """Upload a local file to AssemblyAI and return the upload URL."""
    with open(file_path, "rb") as f:
        data = f.read()
    req = urllib.request.Request(
        "https://api.assemblyai.com/v2/upload",
        data=data,
        headers={
            "Authorization": api_key,
            "Content-Type": "application/octet-stream",
        },
        method="POST",
    )
    with urllib.request.urlopen(req) as resp:
        return json.loads(resp.read())["upload_url"]

def transcribe(api_key, audio_url):
    """Submit transcription and poll until complete."""
    payload = json.dumps({"audio_url": audio_url}).encode()
    req = urllib.request.Request(
        "https://api.assemblyai.com/v2/transcript",
        data=payload,
        headers={
            "Authorization": api_key,
            "Content-Type": "application/json",
        },
        method="POST",
    )
    with urllib.request.urlopen(req) as resp:
        result = json.loads(resp.read())
    transcript_id = result["id"]

    # Poll for completion
    poll_url = f"https://api.assemblyai.com/v2/transcript/{transcript_id}"
    while True:
        req = urllib.request.Request(
            poll_url,
            headers={"Authorization": api_key},
        )
        with urllib.request.urlopen(req) as resp:
            result = json.loads(resp.read())
        status = result["status"]
        if status == "completed":
            return result["text"]
        if status == "error":
            raise RuntimeError(f"Transcription failed: {result.get('error', 'unknown error')}")
        print(f"  Status: {status}... waiting", file=sys.stderr)
        time.sleep(3)

def main():
    if len(sys.argv) != 3:
        print(f"Usage: {sys.argv[0]} <audio-file> <output-path>", file=sys.stderr)
        sys.exit(1)

    audio_file = sys.argv[1]
    output_path = sys.argv[2]

    if not os.path.exists(audio_file):
        print(f"Error: file not found: {audio_file}", file=sys.stderr)
        sys.exit(1)

    load_env()
    api_key = os.environ.get("ASSEMBLYAI_API_KEY")
    if not api_key:
        print("Error: ASSEMBLYAI_API_KEY not set. Add it to .env or export it.", file=sys.stderr)
        sys.exit(1)

    print(f"Uploading {audio_file}...", file=sys.stderr)
    url = upload_file(api_key, audio_file)
    print("Transcribing...", file=sys.stderr)
    text = transcribe(api_key, url)

    with open(output_path, "w") as f:
        f.write(text)
    print(f"Transcript saved to {output_path}", file=sys.stderr)

if __name__ == "__main__":
    main()
