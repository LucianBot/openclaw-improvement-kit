#!/usr/bin/env node
/**
 * DuckDuckGo HTML Search - Rate-limit-free fallback
 * 
 * Uses html.duckduckgo.com (lightweight HTML version) to avoid API rate limits.
 * Extracts titles, URLs, and snippets from search results.
 * 
 * Why this works:
 * - html.duckduckgo.com is a lightweight, JS-free version of DDG
 * - No API key required, no rate limits
 * - Simple HTML scraping = pure, raw data access
 * 
 * Usage: 
 *   node ddg-search.js "your search query"
 *   node ddg-search.js "your search query" --json
 *   node ddg-search.js "your search query" --save
 * 
 * Options:
 *   --json    Output results as JSON
 *   --save    Save results to memory/local_search_results.txt
 */

const https = require('https');
const http = require('http');

const query = process.argv[2];
const flags = process.argv.slice(3);

if (!query) {
  console.error('Usage: node ddg-search.js "search query" [--json] [--save]');
  process.exit(1);
}

const outputJson = flags.includes('--json');
const saveToFile = flags.includes('--save');

// URL encode the query
const encodedQuery = encodeURIComponent(query);
const url = `https://html.duckduckgo.com/html/?q=${encodedQuery}`;

function fetch(url) {
  return new Promise((resolve, reject) => {
    const client = url.startsWith('https') ? https : http;
    const req = client.get(url, {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml',
        'Accept-Language': 'en-US,en;q=0.9',
      }
    }, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => resolve(data));
    });
    req.on('error', reject);
    req.setTimeout(15000, () => {
      req.destroy();
      reject(new Error('Request timeout'));
    });
  });
}

function parseResults(html) {
  const results = [];
  
  // DuckDuckGo HTML uses class="result__a" for links and "result__snippet" for descriptions
  const linkRegex = /<a[^>]*class="result__a"[^>]*href="([^"]*)"[^>]*>([\s\S]*?)<\/a>/gi;
  const snippetRegex = /<a[^>]*class="result__snippet"[^>]*>([\s\S]*?)<\/a>/gi;
  
  // Extract all links
  const links = [];
  let match;
  while ((match = linkRegex.exec(html)) !== null) {
    links.push({
      url: decodeURIComponent(match[1].replace(/.*uddg=/, '').replace(/&.*/, '')),
      title: stripTags(match[2])
    });
  }
  
  // Extract all snippets
  const snippets = [];
  while ((match = snippetRegex.exec(html)) !== null) {
    snippets.push(stripTags(match[1]));
  }
  
  // Combine links with their snippets
  for (let i = 0; i < links.length && i < 10; i++) {
    results.push({
      title: links[i].title,
      url: links[i].url,
      snippet: snippets[i] || ''
    });
  }
  
  return results;
}

function stripTags(html) {
  return html
    .replace(/<[^>]*>/g, '')
    .replace(/&amp;/g, '&')
    .replace(/&lt;/g, '<')
    .replace(/&gt;/g, '>')
    .replace(/&quot;/g, '"')
    .replace(/&#39;/g, "'")
    .replace(/&nbsp;/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();
}

function formatResults(results, query) {
  let output = `Search: "${query}"\n`;
  output += `Results: ${results.length}\n`;
  output += '─'.repeat(50) + '\n\n';
  
  results.forEach((r, i) => {
    output += `${i + 1}. ${r.title}\n`;
    output += `   ${r.url}\n`;
    if (r.snippet) {
      output += `   ${r.snippet}\n`;
    }
    output += '\n';
  });
  
  return output;
}

async function main() {
  try {
    const html = await fetch(url);
    const results = parseResults(html);
    
    if (results.length === 0) {
      console.error('No results found. DDG may have changed their HTML structure.');
      process.exit(1);
    }
    
    if (outputJson) {
      console.log(JSON.stringify({ query, results }, null, 2));
    } else {
      const formatted = formatResults(results, query);
      console.log(formatted);
      
      if (saveToFile) {
        const fs = require('fs');
        const path = require('path');
        const outPath = path.join(__dirname, '..', 'memory', 'local_search_results.txt');
        fs.writeFileSync(outPath, formatted);
        console.error(`Saved to: ${outPath}`);
      }
    }
  } catch (err) {
    console.error('Search failed:', err.message);
    process.exit(1);
  }
}

main();
