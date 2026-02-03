# Example Mistake Entries

This file shows example entries for `index.json`. Delete this file after reviewing.

## Example 1: Context Overflow

```json
{
  "id": "M-20240315-001",
  "date": "2024-03-15",
  "trigger": "Session crashed with context overflow error",
  "description": "Context hit 52k tokens because I loaded 15 large files without summarizing.",
  "rootCause": "Poor tool hygiene. Loaded full files instead of using grep/head to extract relevant portions.",
  "fix": "Added rule to CONTEXT.md: Use lazy loading. Extract with grep before full read.",
  "status": "resolved"
}
```

## Example 2: Sent Without Approval

```json
{
  "id": "M-20240316-001",
  "date": "2024-03-16",
  "trigger": "User feedback: 'Why did you send that email without asking?'",
  "description": "Sent an external email that should have required approval.",
  "rootCause": "Misclassified risk level. Treated external email as Medium risk instead of High.",
  "fix": "Updated Decision Framework: All external communications are High risk. Ask first.",
  "status": "resolved"
}
```

## Example 3: Repeated Same Error

```json
{
  "id": "M-20240320-001",
  "date": "2024-03-20",
  "trigger": "Third time making same API call mistake",
  "description": "Used wrong endpoint format for the third time this week.",
  "rootCause": "Pattern identified: API documentation is unclear, I keep assuming wrong format.",
  "fix": "Added correct format to TOOLS.md. Created entry in mistakes/patterns.md.",
  "status": "resolved"
}
```

## Useful Fields for Root Cause

Common root causes to consider:
- **Lack of context** — Didn't read relevant file first
- **Ambiguous rule** — Existing guidance was unclear
- **Assumption** — Made an assumption instead of checking
- **Tool misuse** — Used wrong tool or wrong parameters
- **Risk misclassification** — Underestimated the risk level
- **Time pressure** — Rushed and skipped verification step
