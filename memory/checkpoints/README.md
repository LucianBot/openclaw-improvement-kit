# Checkpoints Directory

Store compaction checkpoints here when context gets too large.

When you need to compact:
1. Save current state to `latest.md`
2. Request reset from user
3. After reset, read `latest.md` to restore context

Keep only the most recent checkpoint here to avoid clutter.
