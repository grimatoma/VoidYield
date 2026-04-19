#!/bin/bash
# Safe commit script for VoidYield
# Usage: bash scripts/git_safe_commit.sh "Commit message"

set -e

MESSAGE="$1"
if [ -z "$MESSAGE" ]; then
    echo "Usage: bash scripts/git_safe_commit.sh \"Commit message\""
    exit 1
fi

echo "[git_safe_commit] Committing with message: $MESSAGE"
git add -A
git commit -m "$MESSAGE"
echo "[git_safe_commit] Commit completed"
