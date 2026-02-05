# LEARNING_LOOP.md - Self-Improvement System

A structured system for compound improvement through mistake tracking and pattern recognition.

## The Loop

```
Mistake → Log → Pattern? → Fix → Verify → Document
```

## 1. Log Every Mistake

When something goes wrong, add to `mistakes/index.json`:

```json
{
  "id": "M-YYYYMMDD-001",
  "date": "YYYY-MM-DD",
  "trigger": "What revealed the mistake",
  "description": "What went wrong",
  "rootCause": "Why it happened",
  "fix": "What was changed",
  "status": "resolved|ongoing"
}
```

**Key insight:** Log immediately when the mistake happens, not later. You'll forget the details.

## 2. Detect Patterns

If the same *type* of mistake happens 2+ times → it's a pattern.

Add to `mistakes/patterns.md`:
- Related mistake IDs
- Common root cause
- Systemic fix (not a band-aid)

**Pattern examples from real usage:**
- Channel/destination confusion (3 occurrences → created mapping doc)
- Token/context overflow (2 occurrences → added sentinel checks)
- Infrastructure mental model errors (2 occurrences → documented architecture)

## 3. Document Fixes

When a fix works, add to `mistakes/fixes.md`:
- Problem description
- Solution that worked
- Prevention steps

This becomes your "cookbook" — check it before solving similar problems.

## 4. Pre-Task Checklist

Before complex tasks, quick mental check:

1. **Goal** — What does the user *actually* want?
2. **Context** — What do I already know? (Search memory first)
3. **Risk** — What if I'm wrong? (See autonomy levels)
4. **Prior art** — Have I solved this before?

## 5. Decision Framework

| Risk | Examples | Action |
|------|----------|--------|
| **Low** | Read files, web search, organize | Act immediately |
| **Medium** | Edit code, create files, install tools | Act & notify |
| **High** | Delete files, public posts, spend money | Ask first |

**When uncertain:** Default to higher risk level.

## 6. Automation

For daily self-review without manual effort, create a nightly cron job that:
1. Reviews today's memory file
2. Checks for new mistakes
3. Scans for pattern emergence
4. Implements fixes
5. Verifies changes

Example cron schedule: `30 0 * * *` (12:30 AM daily)

This makes the learning loop automatic, not dependent on remembering to do it.

---

*The goal isn't zero mistakes—it's zero repeated mistakes.*
