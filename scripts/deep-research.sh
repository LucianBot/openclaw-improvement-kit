#!/bin/bash
# Deep Research Tool - Combines Perplexity + Gemini for comprehensive research
# Outputs both raw research AND a YAML summary for LLM context injection
# Usage: ./deep-research.sh "query" [output_file] [topic_slug]

set -e

QUERY="$1"
OUTPUT="${2:-/dev/stdout}"
TOPIC_SLUG="${3:-$(echo "$QUERY" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | sed 's/[^a-z0-9-]//g')}"

if [ -z "$QUERY" ]; then
    echo "Usage: $0 \"research query\" [output_file.md] [topic-slug]"
    echo "Example: $0 \"viral marketing tactics 2026\" research/viral-marketing.md viral-marketing"
    exit 1
fi

# API Keys
PERPLEXITY_KEY="${PERPLEXITY_API_KEY:-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}"
GEMINI_KEY="${GEMINI_API_KEY:-AIzaSyDGTH6OiosWmSuXrxwRD0D7YqydMdSJCwk}"

echo "🔍 Running Deep Research: $QUERY" >&2
echo "" >&2

# Perplexity Search (with citations)
echo "📡 Querying Perplexity (Sonar Pro)..." >&2
PERPLEXITY_RESPONSE=$(curl -s "https://api.perplexity.ai/chat/completions" \
  -H "Authorization: Bearer $PERPLEXITY_KEY" \
  -H "Content-Type: application/json" \
  -d "{
    \"model\": \"sonar-pro\",
    \"messages\": [{\"role\": \"user\", \"content\": \"$QUERY. Provide detailed analysis with specific examples, statistics, and actionable tactics.\"}],
    \"return_citations\": true
  }")

PERPLEXITY_CONTENT=$(echo "$PERPLEXITY_RESPONSE" | jq -r '.choices[0].message.content // "Error: No response"')
PERPLEXITY_CITATIONS=$(echo "$PERPLEXITY_RESPONSE" | jq -r '.citations // [] | .[]' | head -10)

# Gemini Search (with Google Search grounding)
echo "🔮 Querying Gemini (with Search Grounding)..." >&2
GEMINI_RESPONSE=$(curl -s "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$GEMINI_KEY" \
  -H "Content-Type: application/json" \
  -d "{
    \"contents\": [{\"parts\": [{\"text\": \"$QUERY. Provide detailed analysis with specific examples, data points, statistics, case studies, and actionable recommendations. Be comprehensive and cite specific numbers where possible.\"}]}],
    \"tools\": [{\"google_search\": {}}]
  }")

GEMINI_CONTENT=$(echo "$GEMINI_RESPONSE" | jq -r '.candidates[0].content.parts[0].text // "Error: No response"')

# Generate YAML summary using Gemini
echo "📝 Generating YAML summary..." >&2
SUMMARY_PROMPT="Based on this research, create a YAML summary block for LLM context injection. Include:
- topic: $TOPIC_SLUG
- key_insight: one sentence main takeaway
- core_concepts: list of 3-5 key concepts with name and summary
- actionable_tactics: list of 5-7 specific things to do
- anti_patterns: list of 3-5 things to avoid
- key_stats: list of 3-5 important statistics mentioned

Research content:
$PERPLEXITY_CONTENT

$GEMINI_CONTENT

Output ONLY valid YAML, no explanation. Start with 'topic:' and nothing before it."

YAML_RESPONSE=$(curl -s "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$GEMINI_KEY" \
  -H "Content-Type: application/json" \
  -d "{
    \"contents\": [{\"parts\": [{\"text\": \"$SUMMARY_PROMPT\"}]}]
  }")

YAML_CONTENT=$(echo "$YAML_RESPONSE" | jq -r '.candidates[0].content.parts[0].text // ""' | sed 's/^```yaml//' | sed 's/^```//' | sed 's/```$//')

# Output combined report with YAML summary
{
    echo "{/* LLM Context Summary - Copy this block for AI prompts */}"
    echo '```yaml'
    echo "$YAML_CONTENT"
    echo '```'
    echo ""
    echo "# Research: $QUERY"
    echo ""
    echo "**Generated:** $(date '+%Y-%m-%d %H:%M %Z')"
    echo ""
    echo "---"
    echo ""
    echo "## Analysis (Perplexity)"
    echo ""
    echo "$PERPLEXITY_CONTENT"
    echo ""
    if [ -n "$PERPLEXITY_CITATIONS" ]; then
        echo "### Sources"
        echo ""
        echo "$PERPLEXITY_CITATIONS" | while read -r url; do
            [ -n "$url" ] && echo "- $url"
        done
        echo ""
    fi
    echo "---"
    echo ""
    echo "## Analysis (Gemini + Google Search)"
    echo ""
    echo "$GEMINI_CONTENT"
    echo ""
} > "$OUTPUT"

echo "✅ Research complete!" >&2
if [ "$OUTPUT" != "/dev/stdout" ]; then
    echo "📄 Output saved to: $OUTPUT" >&2
    echo "📋 YAML summary included at top for LLM context" >&2
fi
