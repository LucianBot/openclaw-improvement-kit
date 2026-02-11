# Security Guide for OpenClaw Agents

*Automated safeguards to prevent credential exposure.*

## The Problem

OpenClaw agents often work across multiple repositories. Credentials in your main workspace (API keys, tokens, passwords) can accidentally flow into other repos during commits, especially if you're doing cross-repo work or maintaining an improvement kit.

Manual "grep before commit" discipline **will fail eventually**. The solution is automated enforcement.

## Safeguards

### 1. Pre-commit Hook

A shell script that blocks commits containing:
- **Secret patterns** (Google API keys, PostHog tokens, GitHub PATs, OpenAI keys, etc.)
- **Sensitive files** (TOOLS.md, .env, secrets.json, config.toml, *.pem, *.key)

**Install:**
```bash
# Option 1: Install to a specific repo
./scripts/install-secret-guard.sh /path/to/repo

# Option 2: Manual install
ln -sf /path/to/pre-commit-secret-scan.sh /your/repo/.git/hooks/pre-commit
```

**What it blocks:**
```
AIzaSy[...]         # Google API Key
phx_[...]           # PostHog Personal API Key
phc_[...]           # PostHog Project Token
sk-[...]            # OpenAI API Key
sk-ant-[...]        # Anthropic API Key
ghp_/gho_/github_pat_  # GitHub tokens
xoxb-/xoxp-/xoxa-   # Slack tokens
ATTA[...]           # Trello/Atlassian tokens
ctx7sk-[...]        # Context7 keys
pplx-[...]          # Perplexity keys
vcp_[...]           # Vercel tokens
```

### 2. Pre-push Scanner

For extra safety, scan a repo before pushing:
```bash
./scripts/scan-repo-secrets.sh /path/to/repo
```

### 3. Repo-level .gitignore

Every repo should have these ignored:
```gitignore
# Sensitive files
TOOLS.md
.env
.env.*
*.pem
*.key
secrets.json
credentials.json
config.toml
```

## Best Practices

### Repo Boundaries

1. **Your main workspace is the vault** — it's supposed to contain credentials
2. **Other repos should not** — especially public ones
3. **Safeguards prevent outflow** — from vault to other repos

### New Repo Checklist

Every time you create a new repo:
1. Create it as **PRIVATE** by default
2. Run `install-secret-guard.sh` on it
3. Add comprehensive `.gitignore`
4. Only make public after reviewing entire commit history

### Cross-repo Work

When copying files between repos:
1. **Never copy your entire workspace** to another repo
2. Review each file for secrets before adding
3. Create sanitized versions of config files (remove values, keep structure)

### If You Expose Credentials

1. **Immediately rotate** all exposed secrets
2. **Make the repo private** (damage control)
3. **Check git history** — secrets may exist in old commits even after removal
4. **Consider force-push** to remove from history (only if you own the repo)
5. **Log the incident** for future learning

## The Scripts

### `pre-commit-secret-scan.sh`

```bash
#!/bin/bash
# Pre-commit hook: Block commits containing secrets
# Install: ln -sf ~/your-workspace/scripts/pre-commit-secret-scan.sh .git/hooks/pre-commit

set -e

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

# High-confidence secret patterns
PATTERNS=(
    'AIzaSy[A-Za-z0-9_-]{33}'                    # Google API Key
    'phx_[A-Za-z0-9]{40,}'                       # PostHog Personal API Key  
    'phc_[A-Za-z0-9]{40,}'                       # PostHog Project Token
    'sk-[A-Za-z0-9]{48,}'                        # OpenAI API Key
    'sk-ant-[A-Za-z0-9-]{90,}'                   # Anthropic API Key
    'ghp_[A-Za-z0-9]{36}'                        # GitHub Personal Access Token
    'gho_[A-Za-z0-9]{36}'                        # GitHub OAuth Token
    'github_pat_[A-Za-z0-9_]{82}'                # GitHub Fine-grained PAT
    'xoxb-[A-Za-z0-9-]{50,}'                     # Slack Bot Token
    'xoxp-[A-Za-z0-9-]{70,}'                     # Slack User Token
    'xoxa-[A-Za-z0-9-]{70,}'                     # Slack App Token
    'ATTA[A-Za-z0-9]{60,}'                       # Atlassian/Trello API Token
    'ctx7sk-[A-Za-z0-9-]{36}'                    # Context7 API Key
    'pplx-[A-Za-z0-9]{48,}'                      # Perplexity API Key
    'vcp_[A-Za-z0-9]{50,}'                       # Vercel Token
)

# Files that should never be committed (anywhere)
BLOCKED_FILES=(
    "TOOLS.md"
    ".env"
    ".env.local"
    ".env.production"
    "secrets.json"
    "credentials.json"
    "config.toml"
    "*.pem"
    "*.key"
)

FOUND_SECRETS=0

# Check staged files for secret patterns
for file in $(git diff --cached --name-only --diff-filter=ACM); do
    # Skip binary files
    if file "$file" | grep -q "binary"; then
        continue
    fi
    
    # Check for blocked files
    for blocked in "${BLOCKED_FILES[@]}"; do
        if [[ "$file" == $blocked ]] || [[ "$(basename "$file")" == $blocked ]]; then
            echo -e "${RED}BLOCKED:${NC} Cannot commit '$file' (sensitive file)"
            FOUND_SECRETS=1
        fi
    done
    
    # Check for secret patterns
    for pattern in "${PATTERNS[@]}"; do
        if grep -qE "$pattern" "$file" 2>/dev/null; then
            echo -e "${RED}SECRET DETECTED:${NC} in $file"
            echo -e "  Pattern: $pattern"
            FOUND_SECRETS=1
        fi
    done
done

if [ $FOUND_SECRETS -eq 1 ]; then
    echo -e "\n${RED}Commit blocked!${NC} Remove secrets before committing."
    echo -e "If this is a false positive, use: git commit --no-verify"
    exit 1
fi

echo -e "${GREEN}✓${NC} No secrets detected"
exit 0
```

### `install-secret-guard.sh`

```bash
#!/bin/bash
# Install secret scanning pre-commit hook to a repo
# Usage: ./install-secret-guard.sh /path/to/repo

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
HOOK_SOURCE="$SCRIPT_DIR/pre-commit-secret-scan.sh"

if [ -z "$1" ]; then
    echo "Usage: $0 /path/to/repo"
    exit 1
fi

REPO_PATH="$1"
HOOKS_DIR="$REPO_PATH/.git/hooks"

if [ ! -d "$HOOKS_DIR" ]; then
    echo "Error: $REPO_PATH doesn't appear to be a git repo"
    exit 1
fi

ln -sf "$HOOK_SOURCE" "$HOOKS_DIR/pre-commit"
chmod +x "$HOOKS_DIR/pre-commit"

echo "✓ Installed secret guard to $REPO_PATH"
```

### `scan-repo-secrets.sh`

```bash
#!/bin/bash
# Scan a repo for secrets before pushing
# Usage: ./scan-repo-secrets.sh [repo-path]

REPO_PATH="${1:-.}"

if [ ! -d "$REPO_PATH/.git" ]; then
    echo "Error: Not a git repository"
    exit 1
fi

cd "$REPO_PATH"

PATTERNS=(
    'AIzaSy[A-Za-z0-9_-]{33}'
    'phx_[A-Za-z0-9]{40,}'
    'phc_[A-Za-z0-9]{40,}'
    'sk-[A-Za-z0-9]{48,}'
    'sk-ant-[A-Za-z0-9-]{90,}'
    'ghp_[A-Za-z0-9]{36}'
    'ATTA[A-Za-z0-9]{60,}'
    'xoxb-[A-Za-z0-9-]{50,}'
    'vcp_[A-Za-z0-9]{50,}'
)

FOUND=0

echo "Scanning $(basename "$PWD") for secrets..."

for pattern in "${PATTERNS[@]}"; do
    results=$(git grep -l -E "$pattern" 2>/dev/null || true)
    if [ -n "$results" ]; then
        echo "⚠️  Found pattern '$pattern' in:"
        echo "$results" | sed 's/^/    /'
        FOUND=1
    fi
done

if [ $FOUND -eq 0 ]; then
    echo "✓ No secrets found"
    exit 0
else
    echo ""
    echo "⚠️  Review these files before pushing!"
    exit 1
fi
```

## Installation

1. **Copy the scripts** to your workspace's `scripts/` directory
2. **Make them executable:** `chmod +x scripts/*.sh`
3. **Install to your workspace:** `./scripts/install-secret-guard.sh .`
4. **Install to other repos** you work with

## Philosophy

This system assumes:
- You will eventually make a mistake (everyone does)
- Automated checks catch mistakes before they become incidents
- False positives are better than real exposures
- The `--no-verify` escape hatch exists for legitimate edge cases

---

*Contributed from a real incident. Learn from others' mistakes.*
