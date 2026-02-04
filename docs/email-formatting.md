# Email Formatting for AI Agents

## The Problem

Plain-text-only emails render in **monospace** fonts in most modern email clients. This makes your emails look robotic and different from human-sent emails.

## The Solution

Always send emails as `multipart/alternative` with both plain text AND HTML parts.

### Why This Works

- Email clients prefer the HTML part when available
- HTML renders with proportional fonts (like normal emails)
- Plain text part serves as fallback for older clients
- The result looks identical to emails sent from Thunderbird, Gmail, etc.

## Template

```bash
BOUNDARY="----=_Part_$(date +%s)"

curl -s --url "smtps://YOUR_SMTP_SERVER:465" \
  --user "you@example.com:password" \
  --mail-from "you@example.com" \
  --mail-rcpt "recipient@example.com" \
  --upload-file - << EOF
From: Your Name <you@example.com>
To: Recipient Name <recipient@example.com>
Subject: Your Subject
MIME-Version: 1.0
Content-Type: multipart/alternative; boundary="${BOUNDARY}"

--${BOUNDARY}
Content-Type: text/plain; charset=UTF-8; format=flowed

Hey,

Your plain text message here.
Wrap lines at ~72 characters for proper display.

Your Name

--${BOUNDARY}
Content-Type: text/html; charset=UTF-8

<!DOCTYPE html>
<html>
<body>
<p>Hey,</p>
<p>Your plain text message here. Wrap lines at ~72 characters for proper display.</p>
<p>Your Name</p>
</body>
</html>

--${BOUNDARY}--
EOF
```

## Guidelines

1. **Keep HTML minimal** — Use only `<p>` tags. No styling, colors, or fancy formatting.
2. **Match both parts** — The plain text and HTML should say the same thing.
3. **Wrap plain text** — Use ~72 character line width with `format=flowed`.
4. **Sound human** — Write like you're typing in an email client, not generating a report.

## What NOT to Do

❌ Plain text only (renders in monospace)
❌ Fancy HTML with colors, headers, or sections (looks like marketing/bot)
❌ HTML tables or complex layouts (breaks replies)
❌ Long unwrapped lines (looks wrong when quoted in replies)

## Result

Your emails will render identically to emails sent by humans using Thunderbird, Apple Mail, Gmail, etc.
