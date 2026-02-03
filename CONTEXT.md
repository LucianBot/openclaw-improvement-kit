# CONTEXT.md - Context & Token Management Protocol

## Philosophy

Context is finite and expensive. A cluttered context leads to hallucinations, slow responses, and errors. You must be intentional about what stays in working memory.

## 1. The Sentinel (Monitoring)

**When to check:** During every heartbeat, or after heavy file operations.

**How to check:** Use `session_status` tool to see current token usage.

**Thresholds (adjust based on your model):**

| Model Type | Warning | Critical |
|:-----------|:--------|:---------|
| Gemini models | 40k tokens | 60k tokens |
| Claude Sonnet | 50k tokens | 80k tokens |
| Claude Opus | 60k tokens | 90k tokens |

- **Below Warning:** Healthy. No action needed.
- **Warning Zone:** Begin summarizing active work. Avoid loading large files.
- **Critical:** Trigger Compaction Protocol immediately.

## 2. The Compaction Protocol

When tokens exceed your critical threshold (or performance degrades noticeably):

### Step 1: Create Checkpoint

Write a snapshot to `memory/checkpoints/latest.md`:

```markdown
# Checkpoint [YYYY-MM-DD HH:MM]

## Active Tasks
- Task A: [status] — next steps...
- Task B: [status] — blocked on...

## Recent Decisions
- Decided X because Y
- Changed Z for reason W

## Context Keys
- /path/to/important/file.md
- /path/to/other/relevant/file

## Open Questions
- Need to clarify X with user
```

### Step 2: Archive (Optional)

If the checkpoint contains valuable context, append it to today's memory file (`memory/YYYY-MM-DD.md`).

### Step 3: Request Reset

Inform your user:
> "Context is at [X]k tokens. I've saved a checkpoint. Ready for `/reset` when you are."

After reset, read the checkpoint to restore context quickly.

**Note:** If running as a sub-agent (`sessions_spawn`), simply complete your task and exit. The parent session stays clean.

## 3. Tool Hygiene (Input Token Reduction)

Prevent context bloat at the source:

- **Lazy Loading:** Don't `read` entire files unless necessary. Use `grep` or `head`/`tail` first.
- **Output Suppression:** For maintenance commands, redirect noise: `command > /dev/null 2>&1`
- **Skill Discipline:** Only load a `SKILL.md` when the task actually matches.
- **Truncation:** When reading large files, use `limit` and `offset` parameters.
- **Quiet Flags:** Use `--quiet`, `-q`, or similar for CLI tools when you don't need verbose output.

## 4. Retrieval Over Storage

Instead of keeping everything in context, **search for it when needed**.

**Memory hierarchy:**
1. **Immediate context** — Only what's needed for the current task
2. **Workspace files** — `MEMORY.md`, `AGENTS.md`, recent daily logs
3. **Searchable archive** — Older daily logs, indexed with semantic search

**Search tools:**
- `memory_search` — OpenClaw's built-in semantic search
- `qmd query "concept"` — Hybrid semantic/keyword search (if installed)
- `grep -r "keyword" memory/` — Fast keyword fallback

**Principle:** Log details to files, then drop them from immediate focus. Search when you need them again.

## 5. Sub-Agent Offloading

For heavy tasks that would bloat your context:

- **Spawn:** Use `sessions_spawn` with a specific, bounded task
- **Benefit:** The sub-agent consumes tokens; your main session only sees the summary
- **Use cases:** "Analyze this codebase", "Research this topic", "Process these files"

## 6. Heartbeat Integration

Add this to your `HEARTBEAT.md`:

```markdown
### 🛡️ Context Sentinel
- Check `session_status` for token count
- If > [warning threshold]: Note in daily log, be conservative with file reads
- If > [critical threshold]: Trigger Compaction Protocol
```

---

*A clean context is a fast context. Retrieve, don't retain.*
