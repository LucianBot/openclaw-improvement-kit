#!/bin/bash
# cleanup-sessions.sh - Prune old session transcript files
# 
# Problem: OpenClaw creates isolated sessions for each cron job run, but never
# cleans them up. This causes disk accumulation and memory pressure when the
# gateway loads sessions on restart.
#
# Root causes of session accumulation:
# 1. Cron jobs with sessionTarget="isolated" create new sessions each run
# 2. Sub-agents spawned during sprints create session files
# 3. Neither is automatically cleaned up by OpenClaw
#
# Solution: Delete session files older than N days (default: 3)
# 
# Usage: ./cleanup-sessions.sh [days]

set -e

DAYS=${1:-3}
SESSIONS_DIR="$HOME/.openclaw/agents/main/sessions"
CRON_RUNS_DIR="$HOME/.openclaw/cron/runs"

echo "=== Session Cleanup ==="
echo "Removing files older than $DAYS days..."
echo ""

# Clean main sessions directory
if [ -d "$SESSIONS_DIR" ]; then
    BEFORE=$(ls "$SESSIONS_DIR"/*.jsonl 2>/dev/null | wc -l | tr -d ' ')
    
    # Delete old .jsonl files
    find "$SESSIONS_DIR" -name "*.jsonl" -mtime +$DAYS -type f -delete 2>/dev/null || true
    # Also clean up any .deleted files (archived sessions)
    find "$SESSIONS_DIR" -name "*.deleted.*" -mtime +$DAYS -type f -delete 2>/dev/null || true
    
    AFTER=$(ls "$SESSIONS_DIR"/*.jsonl 2>/dev/null | wc -l | tr -d ' ')
    echo "Agent sessions: $BEFORE → $AFTER (removed $((BEFORE - AFTER)))"
    echo "  Size: $(du -sh "$SESSIONS_DIR" 2>/dev/null | cut -f1)"
else
    echo "Agent sessions: directory not found"
fi

echo ""

# Clean cron runs directory (isolated cron session transcripts)
if [ -d "$CRON_RUNS_DIR" ]; then
    CRON_BEFORE=$(ls "$CRON_RUNS_DIR"/*.jsonl 2>/dev/null | wc -l | tr -d ' ')
    
    # Delete old cron run transcripts
    find "$CRON_RUNS_DIR" -name "*.jsonl" -mtime +$DAYS -type f -delete 2>/dev/null || true
    
    CRON_AFTER=$(ls "$CRON_RUNS_DIR"/*.jsonl 2>/dev/null | wc -l | tr -d ' ')
    echo "Cron runs: $CRON_BEFORE → $CRON_AFTER (removed $((CRON_BEFORE - CRON_AFTER)))"
    echo "  Size: $(du -sh "$CRON_RUNS_DIR" 2>/dev/null | cut -f1)"
else
    echo "Cron runs: directory not found"
fi

echo ""
echo "=== Cleanup Complete ==="
