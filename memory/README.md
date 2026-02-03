# Memory Directory

This directory holds your daily logs and state files.

## Structure

```
memory/
├── YYYY-MM-DD.md          # Daily logs (one per day)
├── heartbeat-state.json   # Tracks what you've checked and when
└── checkpoints/
    └── latest.md          # Most recent compaction checkpoint
```

## Daily Log Format

Each day, create a file named with the date (e.g., `2024-03-15.md`):

```markdown
# 2024-03-15

## Summary
Brief overview of what happened today.

## Log

[DECISION] Made choice X because Y.

[LEARNING] Discovered that Z works better than W.

[TASK] Need to follow up on the API integration.

[EVENT] Deployed v2.0 to staging.

[INSIGHT] Realized the caching issue was caused by stale headers.
```

## Heartbeat State

Track your periodic checks to avoid redundant work:

```json
{
  "lastChecks": {
    "email": 1710500000,
    "calendar": 1710490000,
    "context": 1710505000
  },
  "lastMemoryReview": 1710400000
}
```

## Checkpoints

When context gets too large, save state before requesting a reset:

```markdown
# Checkpoint 2024-03-15 14:30

## Active Tasks
- Task A: In progress, need to finish X
- Task B: Blocked on user input

## Recent Decisions  
- Chose approach X over Y because...

## Context Keys
- /path/to/important/file
- /path/to/another/file
```

After reset, read this checkpoint to restore context quickly.
