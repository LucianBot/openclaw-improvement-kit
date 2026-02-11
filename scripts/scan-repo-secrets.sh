#!/bin/bash
# Scan a repository for secrets before pushing
# Usage: ./scan-repo-secrets.sh [repo-path]
# If no path given, scans current directory

set -e

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

REPO="${1:-.}"

if [ ! -d "$REPO/.git" ]; then
    echo "Error: Not a git repository: $REPO"
    exit 1
fi

cd "$REPO"

echo "Scanning $(pwd) for secrets..."
echo ""

# Files that should never be in any repo except clawd-backup
DANGEROUS_FILES=(
    "TOOLS.md"
    ".env"
    ".env.local" 
    ".env.production"
    "secrets.json"
    "credentials.json"
    "config.toml"
)

FOUND_ISSUES=0

# Check if dangerous files exist in repo history
for file in "${DANGEROUS_FILES[@]}"; do
    if git ls-files --error-unmatch "$file" 2>/dev/null; then
        echo -e "${RED}🚨 DANGEROUS FILE IN REPO: $file${NC}"
        FOUND_ISSUES=1
    fi
done

# Scan tracked files for secret patterns
SECRET_PATTERNS=(
    'AIzaSy[A-Za-z0-9_-]{33}'
    'phx_[A-Za-z0-9]{40,}'
    'sk-[A-Za-z0-9]{48,}'
    'sk-ant-[A-Za-z0-9-]{90,}'
    'ghp_[A-Za-z0-9]{36}'
    'ATTA[A-Za-z0-9]{60,}'
    'vcp_[A-Za-z0-9]{50,}'
    'GOCSPX-[A-Za-z0-9_-]{20,}'
    'pplx-[A-Za-z0-9]{48}'
)

for pattern in "${SECRET_PATTERNS[@]}"; do
    matches=$(git grep -l -E "$pattern" 2>/dev/null || true)
    if [ -n "$matches" ]; then
        echo -e "${RED}🚨 SECRET PATTERN FOUND: $pattern${NC}"
        echo "In files: $matches"
        FOUND_ISSUES=1
    fi
done

# Check for common credential keywords with values
KEYWORD_MATCHES=$(git grep -l -iE '(password|secret|token|api_key)["\x27]?\s*[:=]\s*["\x27][A-Za-z0-9_-]{16,}' 2>/dev/null || true)
if [ -n "$KEYWORD_MATCHES" ]; then
    echo -e "${YELLOW}⚠️  Possible credentials in: $KEYWORD_MATCHES${NC}"
    echo "   (Manual review recommended)"
fi

echo ""
if [ $FOUND_ISSUES -eq 0 ]; then
    echo -e "${GREEN}✅ No obvious secrets found${NC}"
    exit 0
else
    echo -e "${RED}❌ Security issues found - DO NOT PUSH${NC}"
    exit 1
fi
