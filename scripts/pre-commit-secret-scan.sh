#!/bin/bash
# Pre-commit hook: Block commits containing secrets
# Install: ln -sf ~/clawd/scripts/pre-commit-secret-scan.sh .git/hooks/pre-commit

set -e

RED='\033[0;31m'
YELLOW='\033[1;33m'
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
    'xox[baprs]-[A-Za-z0-9-]+'                   # Slack Token
    'ATTA[A-Za-z0-9]{60,}'                       # Trello Token
    'vcp_[A-Za-z0-9]{50,}'                       # Vercel Token
    'ctx7sk-[a-f0-9-]{36}'                       # Context7 Key
    'pplx-[A-Za-z0-9]{48}'                       # Perplexity Key
    'GOCSPX-[A-Za-z0-9_-]{20,}'                  # Google OAuth Client Secret
    'AQ\.[A-Za-z0-9]{50,}'                       # Vertex AI Token
    '[0-9]+\|[A-Za-z0-9]{40,}'                   # Coolify-style tokens
    'discord\.com/api/webhooks/[0-9]+/[A-Za-z0-9_-]+' # Discord Webhook
)

# Files that should NEVER leave this workspace
SENSITIVE_FILES=(
    'TOOLS.md'
    '.env'
    '.env.local'
    '.env.production'
    'secrets.json'
    'credentials.json'
    '**/config.toml'  # himalaya config has passwords
)

STAGED=$(git diff --cached --name-only)

if [ -z "$STAGED" ]; then
    exit 0
fi

BLOCKED=0

# Check for sensitive files being committed
for pattern in "${SENSITIVE_FILES[@]}"; do
    matches=$(echo "$STAGED" | grep -E "$pattern" || true)
    if [ -n "$matches" ]; then
        echo -e "${RED}🚨 BLOCKED: Sensitive file staged for commit:${NC}"
        echo "$matches"
        echo ""
        echo "These files should stay in clawd-backup only."
        echo "Remove with: git reset HEAD <file>"
        BLOCKED=1
    fi
done

# Check staged content for secret patterns
DIFF=$(git diff --cached)

for pattern in "${PATTERNS[@]}"; do
    if echo "$DIFF" | grep -qE "$pattern"; then
        echo -e "${RED}🚨 BLOCKED: Potential secret detected in staged changes${NC}"
        echo "Pattern matched: $pattern"
        echo ""
        echo "Review your staged changes for exposed credentials."
        echo "If this is a false positive, use: git commit --no-verify"
        BLOCKED=1
        break
    fi
done

# Warn about generic patterns (but don't block)
WARN_PATTERNS='(password|secret|token|api_key|apikey|private_key)["\x27]?\s*[:=]\s*["\x27][^"\x27]{8,}'
if echo "$DIFF" | grep -qiE "$WARN_PATTERNS"; then
    echo -e "${YELLOW}⚠️  WARNING: Possible credential assignment detected${NC}"
    echo "Please verify no secrets are being committed."
    echo ""
fi

if [ $BLOCKED -eq 1 ]; then
    echo -e "${RED}Commit blocked. Fix the issues above or use --no-verify to bypass.${NC}"
    exit 1
fi

exit 0
