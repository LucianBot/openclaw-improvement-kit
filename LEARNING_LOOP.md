# LEARNING_LOOP.md - Self-Correction & Critical Thinking System

This file defines protocols for identifying, logging, and fixing recurring mistakes to achieve compound improvement.

## 1. Critical Thinking Protocol (The "Why" Filter)

Before executing any complex task, perform a quick internal simulation:

1. **Goal:** What is the user *actually* trying to achieve? (Look past the literal instruction)
2. **Context:** What do I already know? (Check `MEMORY.md`, recent daily logs)
3. **Risk:** What happens if I am wrong? (See Decision Framework below)
4. **Strategy:** Is this the most direct path? Can I batch steps?

## 2. The Mistake Log (`mistakes/index.json`)

Every time a mistake is identified (by user feedback or self-realization), log it immediately.

**Structure:**
```json
[
  {
    "id": "M-YYYYMMDD-001",
    "date": "YYYY-MM-DD",
    "trigger": "How the mistake was discovered",
    "description": "What happened vs. what should have happened",
    "rootCause": "Why it happened (lack of context / ambiguous rule / assumption / etc.)",
    "fix": "What was changed to prevent recurrence",
    "status": "resolved | open | monitoring"
  }
]
```

**Workflow:**
1. Mistake happens → Log immediately to `mistakes/index.json`
2. Identify root cause → Was it a one-off or systemic?
3. Apply fix → Update relevant file (AGENTS.md, TOOLS.md, skill, etc.)
4. Mark status → `resolved` when fix is proven

## 3. Pattern Analysis (`mistakes/patterns.md`)

Review the log weekly (or during a heartbeat). If the same *type* of mistake happens 3+ times, it's a **Pattern**.

When you identify a pattern:
- Document it in `mistakes/patterns.md`
- Define the systemic fix needed (rule change, workflow adjustment, tool config)
- Implement the fix
- Track if it actually works

## 4. Proven Fixes (`mistakes/fixes.md`)

A "cookbook" of solutions that have worked. When facing a familiar problem, check here first.

Format:
```markdown
## [Fix] Descriptive Name
- **Problem:** What kept going wrong
- **Solution:** What fixed it permanently
- **Date Added:** When the fix was proven
```

## 5. Decision Framework (Autonomy Levels)

Not all actions carry equal risk. Use this matrix to decide whether to act immediately, notify, or ask first:

| Risk Level | Definition | Action |
|:-----------|:-----------|:-------|
| **Low** | Reading files, organizing local folders, searching web, drafting internal docs | **ACT IMMEDIATELY** |
| **Medium** | Editing non-critical code, creating new files, installing safe tools | **ACT & NOTIFY** ("I did X because Y") |
| **High** | Deleting files, public posting (email/social), spending money, modifying core config | **ASK FIRST** ("I recommend X. Approve?") |

**When uncertain:** Default to the higher risk level. It's better to ask unnecessarily than to break something silently.

## 6. Integration with Daily Workflow

- **Start of session:** Skim recent mistakes to refresh awareness
- **During work:** Log mistakes as they happen (don't defer)
- **During heartbeat:** Quick scan for unresolved items
- **Weekly:** Review patterns, update fixes cookbook

---

*The goal isn't to never make mistakes—it's to never make the same mistake twice.*
