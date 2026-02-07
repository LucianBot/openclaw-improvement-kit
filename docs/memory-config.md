# Memory System Configuration Guide

OpenClaw's memory system has several advanced features that significantly improve recall and context management. This guide covers the recommended configuration.

## Recommended Config

Add this to your `openclaw.json` under `agents.defaults`:

```json
{
  "agents": {
    "defaults": {
      "memorySearch": {
        "enabled": true,
        "sources": ["memory", "sessions"],
        "experimental": {
          "sessionMemory": true
        },
        "provider": "gemini",
        "model": "text-embedding-004",
        "query": {
          "hybrid": {
            "enabled": true,
            "vectorWeight": 0.7,
            "textWeight": 0.3,
            "candidateMultiplier": 4
          }
        },
        "cache": {
          "enabled": true,
          "maxEntries": 50000
        }
      },
      "compaction": {
        "mode": "safeguard",
        "memoryFlush": {
          "enabled": true
        }
      }
    }
  },
  "memory": {
    "citations": "auto"
  }
}
```

## What Each Setting Does

### Session Memory Indexing
```json
"sources": ["memory", "sessions"],
"experimental": { "sessionMemory": true }
```
Indexes your actual chat history, not just memory files. Enables queries like "what did we discuss about X last week?"

### Hybrid Search (BM25 + Vector)
```json
"query": {
  "hybrid": {
    "enabled": true,
    "vectorWeight": 0.7,
    "textWeight": 0.3
  }
}
```
Combines semantic vector search with BM25 keyword matching. Vector search excels at paraphrases; BM25 catches exact tokens like IDs, config keys, and error codes.

### Embedding Cache
```json
"cache": {
  "enabled": true,
  "maxEntries": 50000
}
```
Caches chunk embeddings in SQLite. Prevents re-embedding unchanged text during reindex operations.

### Pre-Compaction Memory Flush
```json
"compaction": {
  "memoryFlush": { "enabled": true }
}
```
When approaching auto-compaction, OpenClaw triggers a silent turn reminding the agent to save durable memory before context is lost.

### Citations
```json
"memory": { "citations": "auto" }
```
Shows `Source: path#line` in memory search results for verifiability.

## Embedding Provider Options

### Gemini (Recommended for most)
```json
"provider": "gemini",
"model": "text-embedding-004"
```
Requires `GEMINI_API_KEY` or `models.providers.google.apiKey`.

### OpenAI
```json
"provider": "openai", 
"model": "text-embedding-3-small"
```
Fast batch indexing with discounted pricing.

### Local (Privacy-first)
```json
"provider": "local",
"local": {
  "modelPath": "hf:ggml-org/embeddinggemma-300M-GGUF/embeddinggemma-300M-Q8_0.gguf"
}
```
Requires `pnpm approve-builds` for node-llama-cpp native build.

## QMD Backend (Alternative)

For even more powerful search, use the QMD backend:

```json
"memory": {
  "backend": "qmd",
  "citations": "auto",
  "qmd": {
    "includeDefaultMemory": true,
    "update": { "interval": "5m" },
    "paths": [
      { "name": "docs", "path": "~/notes", "pattern": "**/*.md" }
    ]
  }
}
```

QMD combines BM25 + vectors + reranking in a local-first search sidecar. Install separately:
```bash
bun install -g https://github.com/tobi/qmd
```

## Verification

After configuration, test memory search:
```
/memory "something you wrote last week"
```

Check that results include citations and show relevant snippets from both memory files and session history.

---

*Reference: https://docs.openclaw.ai/concepts/memory*
