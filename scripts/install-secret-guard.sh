#!/bin/bash
# Install secret scanning pre-commit hook in a git repository
# Usage: ./install-secret-guard.sh /path/to/repo

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
HOOK_SOURCE="$SCRIPT_DIR/pre-commit-secret-scan.sh"

if [ -z "$1" ]; then
    echo "Usage: $0 <repo-path>"
    echo "Installs the secret scanning pre-commit hook in the specified repo."
    exit 1
fi

REPO="$1"

if [ ! -d "$REPO/.git" ]; then
    echo "Error: $REPO is not a git repository"
    exit 1
fi

HOOKS_DIR="$REPO/.git/hooks"

# Create hooks directory if it doesn't exist
mkdir -p "$HOOKS_DIR"

# Install the hook
ln -sf "$HOOK_SOURCE" "$HOOKS_DIR/pre-commit"

echo "✅ Secret scanning hook installed in $REPO"
