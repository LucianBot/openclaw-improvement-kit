# Session Management Guide

*Preventing memory leaks from accumulating sessions.*

## The Problem

OpenClaw cron jobs with `sessionTarget: "isolated"` create persistent session transcript files. Unlike sub-agents (which have `archiveAfterMinutes` auto-cleanup), cron sessions accumulate indefinitely.

**Symptoms of session leak:**
- Gateway slowness / high CPU
- Increasing memory usage over time
- Slow response times that worsen throughout the day

## How Sessions Accumulate

Each cron run creates a `.jsonl` file in `~/.openclaw/agents/<agent>/sessions/`.

With a typical schedule:
- 8 heartbeats/day × 7 days = 56 session files
- 3 sprints/day × 5 days = 75 session files  
- Nightly jobs × 7 = 7 session files

After a week: ~140+ session files. After a month: 500+.

The gateway loads these on restart, causing startup delays and memory pressure.

## Solution: Scheduled Cleanup

### The Script

```bash
#!/bin/bash
# cleanup-sessions.sh
# Remove old session transcripts to prevent accumulation
# Usage: ./cleanup-sessions.sh [retention_days]
# Default: 3 days retention

RETENTION_DAYS="${1:-3}"
SESSIONS_DIR="$HOME/.openclaw/agents/main/sessions"

if [ ! -d "$SESSIONS_DIR" ]; then
    echo "Sessions directory not found: $SESSIONS_DIR"
    exit 1
fi

BEFORE=$(ls "$SESSIONS_DIR"/*.jsonl 2>/dev/null | wc -l | tr -d ' ')

# Remove old session files
find "$SESSIONS_DIR" -name "*.jsonl" -mtime "+$RETENTION_DAYS" -delete 2>/dev/null

# Also clean archived/deleted sessions
find "$SESSIONS_DIR" -name ".deleted.*" -mtime "+$RETENTION_DAYS" -delete 2>/dev/null

AFTER=$(ls "$SESSIONS_DIR"/*.jsonl 2>/dev/null | wc -l | tr -d ' ')
REMOVED=$((BEFORE - AFTER))

echo "Session cleanup: $BEFORE → $AFTER (removed $REMOVED files older than $RETENTION_DAYS days)"
```

### Scheduling

Add to a nightly cron job (e.g., your backup or maintenance cron):

```yaml
payload:
  kind: "agentTurn"
  message: |
    Run session cleanup:
    ~/your-workspace/scripts/cleanup-sessions.sh 3
```

Or run manually when you notice slowness:
```bash
./scripts/cleanup-sessions.sh 3
```

## Monitoring

Check session count periodically:
```bash
ls ~/.openclaw/agents/main/sessions/*.jsonl | wc -l
```

Healthy: < 100 files  
Warning: 100-300 files  
Action needed: > 300 files

## Related: Sub-Agent Cleanup

Sub-agents have built-in cleanup via `archiveAfterMinutes` in your config:

```yaml
agents:
  defaults:
    subagents:
      archiveAfterMinutes: 60  # Auto-delete after 1 hour
```

This only affects sub-agents, not cron isolated sessions.

## When to Restart

If session count is very high (500+), a gateway restart after cleanup helps:
- Flushes the session index from memory
- Reloads only remaining active sessions
- Immediate performance improvement

```bash
openclaw gateway restart
```

---

*Learned from debugging ~2000 accumulated sessions causing gateway slowdowns.*
