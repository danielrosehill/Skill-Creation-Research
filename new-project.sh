#!/bin/bash
# Spin out a clean research project from this template.
# Usage: ./new-project.sh <project-name> [destination-dir]
#
# Example:
#   ./new-project.sh "ai-regulation-research" ~/repos/github/

set -euo pipefail

PROJECT_NAME="${1:?Usage: ./new-project.sh <project-name> [destination-dir]}"
DEST_DIR="${2:-.}"
TARGET="$DEST_DIR/$PROJECT_NAME"

if [ -d "$TARGET" ]; then
    echo "Error: $TARGET already exists"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Copy template structure
cp -r "$SCRIPT_DIR" "$TARGET"

# Clean out example files and git history
rm -rf "$TARGET/.git"
rm -f "$TARGET/prompts/run/initial/example-initial-prompt.md"
rm -f "$TARGET/prompts/run/subsequent/example-subsequent-prompt.md"
rm -f "$TARGET/new-project.sh"

# Reset the research brief to blank template
cat > "$TARGET/context/from-human/research-brief.md" << 'EOF'
# Research Brief

## Topic



## Scope



## Background



## Key Questions

1.
2.
3.

## Constraints



## Intended Audience

<!-- Who will read this research? This repo is public — describe who you're writing for. -->

## Desired Output

<!-- What form should the final deliverable take? Blog post, report, briefing doc, social thread? -->

## Licensing

<!-- How should others use your findings? Default: MIT -->

EOF

# Ensure private directory exists
mkdir -p "$TARGET/private"
touch "$TARGET/private/.gitkeep"

# Ensure published output directory exists
mkdir -p "$TARGET/outputs/published"
touch "$TARGET/outputs/published/.gitkeep"

# Ensure voice-notes directory exists
mkdir -p "$TARGET/voice-notes"
touch "$TARGET/voice-notes/.gitkeep"

# Ensure scripts directory exists
mkdir -p "$TARGET/scripts"

# Initialise fresh git repo
cd "$TARGET"
git init
git add -A
git commit -m "Initialise public research workspace: $PROJECT_NAME"

echo ""
echo "Public research workspace created at: $TARGET"
echo "Next steps:"
echo "  1. cd $TARGET"
echo "  2. Edit context/from-human/research-brief.md"
echo "  3. (Optional) Copy .env.example to .env and add your AssemblyAI key for voice notes"
echo "  4. Add your first prompt to prompts/run/initial/ — or use /voice-note"
echo "  5. Open in Claude Code and start researching"
echo "  6. Everything committed is public — use private/ for off-record notes"
