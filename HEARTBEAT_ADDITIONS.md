# HEARTBEAT_ADDITIONS.md - Enhancements for HEARTBEAT.md

These additions layer on top of OpenClaw's default heartbeat behavior. Add them to your `HEARTBEAT.md`.

---

## 🛡️ Context Sentinel (Add as first check)

Monitor token usage every heartbeat to prevent crashes:

```markdown
### 🛡️ Context Sentinel
Check context size and trigger compaction if needed:
- Use `session_status` to check current token count
- **Warning thresholds:**
  - Gemini models: 40k tokens
  - Claude Sonnet: 50k tokens  
  - Claude Opus: 60k tokens
- **Critical thresholds:** (trigger compaction)
  - Gemini models: 60k tokens
  - Claude Sonnet: 80k tokens
  - Claude Opus: 90k tokens
- If critical: Follow Compaction Protocol in CONTEXT.md
```

---

## 🔍 Error Monitoring (Add to quick checks)

Catch problems before they escalate:

```markdown
### ⚠️ System Health
- [ ] Check `cron list` for any `lastStatus: "error"` jobs
- [ ] Check `sessions_list` for failed sub-agents
- [ ] Skim `mistakes/index.json` for unresolved items

If errors found → alert user immediately.
```

---

## 📊 State Persistence

Track what you've checked to avoid redundant work:

```markdown
## State File

Maintain `memory/heartbeat-state.json`:

```json
{
  "lastChecks": {
    "email": 1703275200,
    "calendar": 1703260800,
    "github": null,
    "context": 1703280000
  },
  "lastMemoryReview": 1703200000,
  "lastMistakeReview": 1703100000
}
```

Update timestamps after each check. Don't repeat checks within 2 hours unless triggered.
```

---

## 🧠 Periodic Maintenance (Add to background work)

Tasks to do silently during heartbeats:

```markdown
## Background Work (Silent)

These can be done without alerting the user:
- Review recent `memory/YYYY-MM-DD.md` files
- Update `MEMORY.md` if significant events aren't captured  
- Check `mistakes/index.json` for patterns (3+ similar errors = pattern)
- Run memory indexing if new files added (e.g., `qmd update && qmd embed`)
- `git status` check on workspace
```

---

## Example Complete HEARTBEAT.md

Here's what a complete file might look like:

```markdown
# HEARTBEAT.md

## Quick Checks (Every Heartbeat)

### 🛡️ Context Sentinel
- Check `session_status` for token count
- If > warning: Be conservative with file reads
- If > critical: Trigger Compaction Protocol

### ⚠️ System Health  
- [ ] Check for failed cron jobs or sub-agents
- [ ] Skim mistakes/index.json for unresolved items

## Rotating Checks (Pick 1-2 per heartbeat)

Track last check times in `memory/heartbeat-state.json`.

- 📧 Email - Unread messages?
- 📅 Calendar - Events in next 2 hours?
- 🐙 GitHub - Notifications or failed CI?

## Quiet Hours

**23:00 - 08:00:** Skip proactive outreach unless urgent.

## Background Work (Silent)

- Memory file maintenance
- Mistake log review
- Documentation updates
```
