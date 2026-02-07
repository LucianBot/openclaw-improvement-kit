# Cron Job Best Practices

Hard-won lessons from running OpenClaw cron jobs in production.

## Golden Rules

1. **Always use `channel:` prefix for Discord**
   ```json
   "delivery": { "to": "channel:1467220286859382895" }
   ```
   Without this, you get "Ambiguous Discord recipient" errors.

2. **Specify models explicitly for sub-agents**
   ```json
   "message": "Spawn a sub-agent with model gemini-flash for..."
   ```

3. **One job = one outcome**
   Don't pack multiple tasks into one cron. Keep them focused.

4. **Heavy research → sub-agents**
   Cron sessions have limited context. Spawn sub-agents for research-heavy work.

5. **Delete disabled jobs**
   Don't let old jobs clutter your cron list.

## Common Errors & Fixes

| Error | Cause | Fix |
|-------|-------|-----|
| `Ambiguous Discord recipient` | Missing channel prefix | Add `channel:` to target |
| Timeout | Too much work in one job | Break into sub-agent spawns |
| Rate limit | Too many API calls | Add delays, use batch patterns |
| Silent failure | Agent didn't produce output | Add explicit delivery check |

## Schedule Patterns

### Daily recap (midnight)
```json
{
  "kind": "cron",
  "expr": "0 0 * * *",
  "tz": "America/New_York"
}
```

### Weekday sprints (6am, 12pm, 6pm Tue-Thu)
```json
{
  "kind": "cron", 
  "expr": "0 6,12,18 * * 2-4",
  "tz": "America/New_York"
}
```

### Every 4 hours
```json
{
  "kind": "cron",
  "expr": "0 0,4,8,12,16,20 * * *",
  "tz": "America/New_York"
}
```

### Weekly (Saturday 9am)
```json
{
  "kind": "cron",
  "expr": "0 9 * * 6",
  "tz": "America/New_York"
}
```

## Sub-Agent Strategy

Spawn aggressively during cron jobs:

| Task | Model | Why |
|------|-------|-----|
| Email scan | gemini-flash | Fast, cheap |
| GitHub checks | gemini-flash | Fast, cheap |
| Web research | gemini-flash | Fast, cheap |
| Code review | codex | Code-specialized |
| Design feedback | gemini-pro | Better reasoning |

**Parallel > Sequential.** Three Flash sub-agents cost less context than doing all three checks in the main session.

## Delivery Modes

For isolated sessions:
```json
"delivery": { 
  "mode": "announce",
  "channel": "discord", 
  "to": "channel:1467220286859382895" 
}
```

- `mode: "announce"` — Posts summary to channel when job completes
- `mode: "none"` — Silent (for maintenance jobs)

## Sprint Delivery Verification

Problem: Cron says "ok" but agent stayed silent.

Solution: Add a heartbeat check that verifies output actually appeared:

1. Check which sprint(s) should have fired today
2. Read the target channel's recent messages
3. If sprint was due but no report exists → alert

This catches the "job ran but produced nothing" failure mode.

## Debugging

```bash
# Check job history
cron runs --jobId=<id>

# Test a job manually
cron run --jobId=<id>

# List all jobs
cron list

# List including disabled
cron list --includeDisabled
```

---

*Reference: https://docs.openclaw.ai/reference/cron*
