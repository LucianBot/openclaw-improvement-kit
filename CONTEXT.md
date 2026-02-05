# CONTEXT.md - Token Management

Context is finite. Clutter leads to errors. Be ruthless.

## Thresholds

Check with `session_status` during heartbeats.

| Model | Warning | Compact At |
|-------|---------|------------|
| Gemini | 48k | 60k tokens |
| Claude Opus | 72k | 90k tokens |
| Claude Sonnet | 40k | 50k tokens |
| Others | 40k | 50k tokens |

## Compaction Protocol

When approaching threshold:

### 1. Checkpoint

Write to `memory/checkpoints/latest.md`:

```markdown
# Checkpoint [YYYY-MM-DD HH:MM]

## Active Tasks
- Task A: status, next steps

## Recent Decisions
- Key decision 1

## Files Needed After Reset
- path/to/important/file.md
```

### 2. Log

Append summary to today's `memory/YYYY-MM-DD.md`

### 3. Request Reset

Tell user: "Context high. Checkpoint saved. Ready for /reset."

### 4. Sub-agents

Just return result and exit (no user prompt needed).

## Token Hygiene

Prevent bloat at the source:

- **Lazy load** — Don't read huge files. Use `grep` or `limit/offset`
- **Redirect noise** — `command 2>/dev/null` for verbose CLI output
- **Skip skills** — Don't load SKILL.md unless task matches
- **Quiet flags** — Use `--quiet`, `-q` where available
- **Offload heavy tasks** — Spawn sub-agents instead

## Memory Over Context

Don't keep everything in context. Search for it.

**Primary:** `memory_search` or `qmd query "concept"`
**Fallback:** `grep -r "keyword" memory/`

**Principle:** Log to files, drop from focus, search when needed.

### Conflict Resolution

When info contradicts:
- Newer decisions > older assumptions
- User statements > agent inferences
- Log: `[CONFLICT] old: X, new: Y, resolved: Z`

### Decay

- Mark time-sensitive: `[EXPIRES: YYYY-MM-DD]`
- Prune MEMORY.md entries >30 days unless `[PERMANENT]`
- Recent daily logs trump old MEMORY.md on same topic

## Heartbeat Integration

Add to your `HEARTBEAT.md`:

```markdown
### 🛡️ Context Sentinel
- Check `session_status` for token count
- If > warning: Be conservative with file reads
- If > critical: Trigger Compaction Protocol
```

---

*A clean context is a fast context.*
