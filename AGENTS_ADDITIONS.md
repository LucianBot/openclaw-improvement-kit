# AGENTS_ADDITIONS.md - Enhancements for AGENTS.md

These additions layer on top of OpenClaw's default `AGENTS.md`. Merge them into your existing file.

---

## 📝 Memory Prefixes (Add to "Write It Down" section)

Use these prefixes in your daily logs to make memory searchable:

- `[DECISION]` - Choices made and why
- `[LEARNING]` - New skills, tools, or knowledge acquired
- `[INSIGHT]` - Aha moments, realizations
- `[TASK]` - Open loops or TODOs
- `[EVENT]` - Milestones, launches, completions

**Example daily log entry:**
```markdown
## 2024-03-15

[DECISION] Switched from REST to GraphQL for the dashboard API because we need nested queries without multiple round trips.

[LEARNING] Discovered that `qmd` supports hybrid search - combines semantic and keyword matching for better recall.

[TASK] Still need to migrate the user settings endpoint.

[EVENT] Shipped v2.1 to production.
```

These prefixes make it much easier to find specific types of information later:
- "What decisions did we make about X?" → search for `[DECISION] X`
- "What's still open?" → search for `[TASK]`

---

## 🔄 Session Startup (Add to "Every Session" section)

Add these to your session startup routine:

```markdown
5. Read `LEARNING_LOOP.md` — this is how you improve
6. Read `CONTEXT.md` — this is how you manage memory
7. Skim `mistakes/index.json` — refresh awareness of past errors
```

---

## 🛡️ Self-Improvement Protocol (New section)

When you make a mistake:

1. **Acknowledge it** — Don't hide it or hope it goes unnoticed
2. **Log it** — Add to `mistakes/index.json` with root cause analysis
3. **Fix it** — Update the relevant file to prevent recurrence
4. **Learn from it** — If it's a pattern, add to `mistakes/patterns.md`

The goal isn't perfection—it's compound improvement. Each logged mistake makes you better.

---

## 📊 Engineering Protocols (Optional - for coding agents)

If you do coding work, consider adding:

```markdown
## Engineering Protocols

**Before writing code:**
1. Check `git status` — know your starting state
2. Never `git reset --hard` without explicit permission
3. Prefer atomic commits (one logical change per commit)

**After writing code:**
4. Run tests (if they exist)
5. Explain the "why" in commit messages and comments
6. Update relevant docs if behavior changed

**Deletions:**
7. Use `trash` instead of `rm` when possible (recoverable > gone)
8. For destructive operations, ask first
```
