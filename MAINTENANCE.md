# MAINTENANCE.md - System Health Guardrails

Protocols to ensure your agent stays healthy in perpetuity.

## Automated Maintenance

Set up these cron jobs for hands-off health:

| Time | Job | Purpose |
|------|-----|---------|
| 12:00 AM | Daily Recap | Summarize day's work |
| 12:30 AM | Nightly Self-Review | Audit and fix issues |
| 3:00 AM | Update Check | Check for OpenClaw updates |

## File Health Rules

### Core Files (Touch Carefully)

| File | Target Size | Review |
|------|-------------|--------|
| MEMORY.md | ~3KB | Weekly |
| AGENTS.md | ~3KB | Monthly |
| HEARTBEAT.md | ~1.5KB | Monthly |

If a file exceeds target, it needs pruning.

### Memory Files

- **Daily logs** — Keep 14 days in `memory/`, archive older
- **Archive** — Move old benchmarks, research to `memory/archive/`
- **Checkpoints** — Keep only `latest.md`

### State Files

- `memory/heartbeat-state.json` — Track check timestamps
- `mistakes/index.json` — Append-only log

## Weekly Audit Checklist

During weekly review:

1. **File counts:**
   - `memory/*.md` < 30 files
   - `mistakes/index.json` < 50 entries

2. **Doc consistency:**
   - MEMORY.md reflects current reality
   - Cron schedule matches docs
   - Channel IDs are correct

3. **Cron health:**
   - No disabled jobs lingering
   - No repeated errors

## Red Flags (Immediate Action)

| Symptom | Likely Cause | Fix |
|---------|--------------|-----|
| Cron errors | Missing `channel:` prefix | Update job with correct format |
| Context overflow | Verbose output, big files | Checkpoint and reset |
| Same mistake 3x | Missing systemic fix | Add to patterns.md |
| Stale MEMORY.md | Nightly review not running | Check cron status |

## Recovery Procedures

### Context Explosion
1. Checkpoint to `memory/checkpoints/latest.md`
2. Log summary to today's daily file
3. Request `/reset`

### Cron Keeps Failing
1. Check error: `cron runs --jobId=<id>`
2. Common fixes in docs
3. Test: `cron run --jobId=<id>`

### Stale Memory
1. Read recent daily files
2. Update MEMORY.md
3. Prune outdated entries
4. Refresh search index

### Doc Conflicts
1. Identify the conflict
2. Resolve (newer > older)
3. Update all affected files
4. Log resolution

## Monthly Checklist

- [ ] Core files under size targets
- [ ] Memory archived (14 days active)
- [ ] No disabled cron jobs
- [ ] MEMORY.md current
- [ ] Patterns have fixes
- [ ] Search index fresh

---

*This is the meta-protocol. If it becomes outdated, update it during nightly review.*
