# Get Shit Done (GSD) Integration

A meta-prompting and spec-driven development system that solves **context rot** — the quality degradation that happens as Claude fills its context window.

> **Source:** https://github.com/glittercowboy/get-shit-done

## Why GSD?

When you spawn coding agents (Claude Code, OpenCode, Gemini CLI) for complex builds, they face a fundamental problem: as the context window fills up, output quality degrades. GSD fixes this by:

1. **Fresh context per task** — Each plan executes in a clean 200k context window
2. **Structured planning files** — PROJECT.md, REQUIREMENTS.md, ROADMAP.md persist across sessions
3. **Multi-agent orchestration** — Spawns specialized agents for research, planning, execution
4. **Atomic commits** — Every task gets its own git commit with clean history

## Installation

```bash
# Install for all supported runtimes
npx get-shit-done-cc --all --global

# Or install for specific runtimes
npx get-shit-done-cc --claude --global    # Claude Code only
npx get-shit-done-cc --opencode --global  # OpenCode only
npx get-shit-done-cc --gemini --global    # Gemini CLI only
```

Verify installation:
- Claude Code: `/gsd:help`
- OpenCode: `/gsd-help`
- Gemini CLI: `/gsd:help`

## Core Workflow

### 1. Initialize Project
```
/gsd:new-project
```
Questions → Research → Requirements → Roadmap

### 2. Plan Phase
```
/gsd:discuss-phase 1    # Capture implementation decisions
/gsd:plan-phase 1       # Research + plan + verify
```

### 3. Execute Phase
```
/gsd:execute-phase 1    # Run plans in parallel waves
/gsd:verify-work 1      # Manual acceptance testing
```

### 4. Complete & Continue
```
/gsd:complete-milestone
/gsd:new-milestone
```

## Quick Mode

For ad-hoc tasks that don't need full planning:

```
/gsd:quick
> What do you want to do? "Add dark mode toggle to settings"
```

Same quality guarantees (atomic commits, state tracking), faster path.

## Key Commands

| Command | Purpose |
|---------|---------|
| `/gsd:new-project` | Full initialization with research |
| `/gsd:plan-phase N` | Research + plan + verify for phase N |
| `/gsd:execute-phase N` | Execute all plans, verify on complete |
| `/gsd:quick` | Ad-hoc task with GSD guarantees |
| `/gsd:progress` | Show current status and next steps |
| `/gsd:map-codebase` | Analyze existing code before new project |

## For OpenClaw Agents

When using the `coding-agent` skill to spawn Claude Code or other coding CLIs, GSD commands will be available in those sessions if installed globally. This means:

1. **Spawn Claude Code** via coding-agent skill
2. **Use GSD workflow** for complex features
3. **Planning files persist** in `.planning/` directory
4. **Fresh contexts** for each task prevent degradation

### Example: Orchestrating a Build

```
# In OpenClaw, spawn a coding agent
sessions_spawn(
  task: "Build user authentication system. Use /gsd:new-project to plan it properly.",
  label: "auth-build"
)
```

The spawned Claude Code session will have access to all GSD commands.

## Configuration

GSD settings live in `.planning/config.json`:

- **mode**: `yolo` (auto-approve) or `interactive` (confirm each step)
- **depth**: `quick`, `standard`, `comprehensive`
- **profiles**: `quality` (Opus), `balanced` (Opus+Sonnet), `budget` (Sonnet+Haiku)

## Files Created

| File | Purpose |
|------|---------|
| `PROJECT.md` | Project vision, always loaded |
| `REQUIREMENTS.md` | Scoped v1/v2 requirements |
| `ROADMAP.md` | Phases and progress |
| `STATE.md` | Decisions, blockers, session memory |
| `.planning/` | Research, plans, summaries |

## Updating

```bash
npx get-shit-done-cc@latest
```

---

*GSD is created by TÂCHES. This integration doc is maintained by the OpenClaw Improvement Kit.*
