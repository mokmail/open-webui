---
name: Website Scraper
description: Scrape any website by URL, analyze its features and content, and save the analysis as a markdown file. Use when user provides a URL and asks to extract, document, or save the site's content and features.
tags: [scraping, web, analysis, documentation, research]
version: 1.0.0
---

# Website Scraper

## Overview

Extract all content from a given URL, analyze the website's purpose and features, and produce a comprehensive markdown document covering every aspect of the site.

## Tools Used

- `fetch_url(url)` — Fetches the main text content from any web page
- `write_note(title, content)` — Saves the output as a persistent note in markdown format

## Workflow

### 1. Accept URL

Ask the user for the URL if not provided. Validate it starts with `http://` or `https://`.

### 2. Fetch Content

Call `fetch_url(url)` to retrieve the page content:

```
fetch_url(url="https://example.com")
```

If the returned content is very large, you may need to call `fetch_url` on individual sub-pages to get full coverage.

### 3. Analyze Content

Analyze the fetched content to identify:

- **Site identity**: Name, tagline, brand description
- **Core purpose**: What problem does it solve? Who is it for?
- **All features**: Every feature, tool, capability, or section mentioned
  - Group features by category (e.g., Core Features, Integrations, Pricing, API)
  - Include sub-features and options
- **Navigation structure**: Sections, categories, and heirarchy
- **Technical details**: Technology stack, API availability, SDKs, documentation links
- **Pricing/plans**: If available, document all tiers with their limits
- **Integrations**: Connected services, platforms, or tools
- **Use cases**: Example scenarios, target audiences
- **Links**: Important internal and external links found

### 4. Produce Markdown Document

Format the output as a comprehensive markdown document:

```markdown
# {Website Name} — Complete Feature Documentation

**URL:** {url}
**Scraped on:** {date}

## Overview
{2-3 paragraph summary of the website}

## Core Purpose
{What the site does and who it serves}

## Features

### {Category 1}
- **{Feature name}**: {Description, how it works, key details}

### {Category 2}
- **{Feature name}**: {Description, how it works, key details}

...

## Navigation Structure
{Sitemap or section heirarchy}

## Integrations
{Connected services, APIs, platforms}

## Pricing
{Pricing tiers, features per tier, limits}

## Technical Details
{API docs, SDKs, technology mentions}

## Use Cases
{Example scenarios and target audiences}

## Links
- [Link text](url)
```

### 5. Save (Optional)

Ask the user if they want to save the document. If yes, call:

```
write_note(
    title="{Website Name} — Feature Documentation",
    content="{full markdown content}"
)
```

## Important Notes

- If the page content is truncated by `fetch_url` (due to size limits), inform the user and offer to scrape individual sub-pages
- For multi-page sites, ask the user which sections to prioritize
- Preserve all URLs, links, and references exactly as found
- If the site requires authentication or is blocked, inform the user
