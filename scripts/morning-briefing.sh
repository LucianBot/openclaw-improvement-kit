#!/bin/bash
# Morning Briefing Generator
# Generates a consolidated briefing with Trello status, recent git activity, and system health
# Usage: ./morning-briefing.sh [--json]

set -e

SCRIPT_DIR="$(dirname "$0")"
OUTPUT_JSON=false

[[ "$1" == "--json" ]] && OUTPUT_JSON=true

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Trello Config
TRELLO_API_KEY="${TRELLO_API_KEY:-c668d7077112474a860bcecee5903411}"
TRELLO_TOKEN="${TRELLO_TOKEN:-ATTA82b5cb6431748b29ff823b10a9b7d7277226536e7978b64bc185ef2c939601540B1A8F2C}"
BOARD_ID="${TRELLO_BOARD_ID:-6980312cade1076e658f6266}"
API_BASE="https://api.trello.com/1"
AUTH="key=$TRELLO_API_KEY&token=$TRELLO_TOKEN"

# List IDs
LIST_IN_PROGRESS="69803133c1ce60b503438d12"
LIST_THIS_WEEK="69803134d4ff40c8cbfb43b8"
LIST_DONE="69803133ffa0037ddcaf2807"

echo -e "${BLUE}🌅 Morning Briefing — $(date '+%A, %B %d, %Y')${NC}"
echo "================================================"
echo ""

# 1. Trello Status
echo -e "${YELLOW}📋 TRELLO STATUS${NC}"
echo "----------------"

# Get card counts
INBOX_COUNT=$(curl -s "$API_BASE/lists/69803134f54cdfea885e8cde/cards?$AUTH" | jq '. | length')
WEEK_COUNT=$(curl -s "$API_BASE/lists/$LIST_THIS_WEEK/cards?$AUTH" | jq '. | length')
PROGRESS_COUNT=$(curl -s "$API_BASE/lists/$LIST_IN_PROGRESS/cards?$AUTH" | jq '. | length')
DONE_COUNT=$(curl -s "$API_BASE/lists/$LIST_DONE/cards?$AUTH" | jq '. | length')

echo "Inbox: $INBOX_COUNT | This Week: $WEEK_COUNT | In Progress: $PROGRESS_COUNT | Done: $DONE_COUNT"
echo ""

# Show in-progress cards
echo -e "${GREEN}🔄 In Progress:${NC}"
IN_PROGRESS_CARDS=$(curl -s "$API_BASE/lists/$LIST_IN_PROGRESS/cards?$AUTH" | jq -r '.[] | "  • \(.name)"')
if [[ -n "$IN_PROGRESS_CARDS" ]]; then
    echo "$IN_PROGRESS_CARDS"
else
    echo "  (none)"
fi
echo ""

# Show this week cards
echo -e "${BLUE}📅 This Week:${NC}"
THIS_WEEK_CARDS=$(curl -s "$API_BASE/lists/$LIST_THIS_WEEK/cards?$AUTH" | jq -r '.[] | "  • \(.name)"')
if [[ -n "$THIS_WEEK_CARDS" ]]; then
    echo "$THIS_WEEK_CARDS"
else
    echo "  (none)"
fi
echo ""

# 2. Recent Git Activity
echo -e "${YELLOW}🔧 GIT ACTIVITY (Last 24h)${NC}"
echo "--------------------------"

# Check common project directories
for dir in /Users/agent/clawd /Users/agent/clawd/projects/*; do
    if [[ -d "$dir/.git" ]]; then
        repo_name=$(basename "$dir")
        recent_commits=$(cd "$dir" && git log --oneline --since="24 hours ago" 2>/dev/null | head -3)
        if [[ -n "$recent_commits" ]]; then
            echo -e "${GREEN}$repo_name:${NC}"
            echo "$recent_commits" | sed 's/^/  /'
            echo ""
        fi
    fi
done

# 3. System Health Quick Check
echo -e "${YELLOW}💻 SYSTEM HEALTH${NC}"
echo "----------------"

# Disk usage
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}')
echo "Disk: $DISK_USAGE used"

# Memory
if command -v vm_stat &> /dev/null; then
    # macOS
    FREE_MEM=$(vm_stat | awk '/Pages free/ {free=$3} /Pages inactive/ {inactive=$3} END {print int((free+inactive)*4096/1024/1024/1024)"GB free"}')
    echo "Memory: $FREE_MEM"
fi

# OpenClaw status
if command -v openclaw &> /dev/null; then
    OC_VERSION=$(openclaw --version 2>/dev/null || echo "unknown")
    echo "OpenClaw: $OC_VERSION"
fi

echo ""
echo -e "${BLUE}================================================${NC}"
echo "Ready for sprint. Let's build something great! 🦾"
