# Model Resilience Watchdog

A cron-based failover system that automatically handles provider quota exhaustion.

## The Problem

When using AWS Bedrock for Claude models, quota exhaustion doesn't trigger OpenClaw's normal fallback chain because Bedrock uses `aws-sdk` auth which bypasses auth-profile rotation. The agent just fails silently or throws errors.

## The Solution

A watchdog cron job running on a **different provider** (Gemini Flash) monitors the main session and auto-swaps the config when Opus fails.

### How It Works

1. Runs every 4 hours on Gemini Flash
2. Checks main session health via `sessions_list`
3. If Opus quota exhausted → patches config to Gemini-primary
4. If already on Gemini → probes Opus availability
5. When Opus recovers → patches config back to Opus-primary
6. State tracked in `memory/model-failover-state.json`

### State File Format

```json
{
  "currentPrimary": "opus",
  "lastCheck": "2026-02-06T12:00:00Z",
  "lastSwap": "2026-02-06T08:00:00Z",
  "reason": "quota_exhausted",
  "history": [
    { "ts": "...", "from": "opus", "to": "gemini", "reason": "quota" },
    { "ts": "...", "from": "gemini", "to": "opus", "reason": "recovery" }
  ]
}
```

## Setting Up the Cron Job

```javascript
// Example cron job payload
{
  "name": "Model Resilience Watchdog (4h)",
  "schedule": {
    "kind": "cron",
    "expr": "5 0,4,8,12,16,20 * * *",
    "tz": "America/New_York"
  },
  "sessionTarget": "isolated",
  "payload": {
    "kind": "agentTurn",
    "model": "google/gemini-3-flash-preview",
    "message": "Model watchdog check. Read memory/model-failover-state.json. Check main session for Bedrock quota errors. If Opus failing, swap config to Gemini-primary. If already on Gemini, probe Opus and swap back if available. Update state file. Reply with status only."
  }
}
```

### Key Points

- **Must run on different provider** — If you're monitoring Opus, run watchdog on Gemini
- **Use isolated session** — Don't pollute main session context
- **Lightweight checks** — Just probe, don't do heavy work
- **Log state** — Track swaps for debugging

## Manual Swap Commands

If you need to manually swap:

```bash
# Check current config
openclaw config get | jq '.agents.defaults.model'

# Swap to Gemini
openclaw config patch '{"agents":{"defaults":{"model":{"primary":"google/gemini-3-flash-preview"}}}}'

# Swap back to Opus
openclaw config patch '{"agents":{"defaults":{"model":{"primary":"amazon-bedrock/global.anthropic.claude-opus-4-5-20251101-v1:0"}}}}'
```

## Upstream Issue

This is a known limitation tracked at: https://github.com/openclaw/openclaw/issues/10462

Until fixed upstream, this watchdog pattern provides reliable auto-recovery.

---

*This pattern emerged from real production use. Adjust timing and provider choices to your setup.*
