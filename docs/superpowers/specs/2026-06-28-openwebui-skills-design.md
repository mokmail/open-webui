# Open WebUI Skills Collection — Design Doc

## Overview

A curated collection of 10 reusable, importable Skill files for Open WebUI. Skills are Markdown-based instruction sets that teach AI models how to approach specific tasks. These cover the most universally useful workflows for Open WebUI users.

## Format

Each skill is a `.md` file with YAML frontmatter containing `name`, `description`, `tags`, and `version`. This matches Open WebUI's import pipeline (`Workspace > Skills > Import > .md` files), which auto-populates name and description from frontmatter.

## Skills

### 1. Code Review Guidelines
Systematic code review covering security, correctness, performance, style/maintainability, and testing. Uses severity tiers (🔴 Critical, 🟡 Warning, 🔵 Suggestion, 💬 Nitpick). Requires exact file/line citations, explanation of why each issue matters, and concrete fix snippets.

### 2. Writing Style Guide
Tone and voice rules, formatting conventions, terminology management, document structure. Applicable to content writing, documentation, emails, and reports.

### 3. Troubleshooting Playbook
Step-by-step diagnostic workflow: gather context, check logs, verify configs, test connectivity, isolate variable, escalate. For system/software/network issues.

### 4. Research Assistant
Multi-source academic research workflow: define question, identify sources (arXiv, Semantic Scholar, PubMed, web), extract findings, cross-reference, produce structured briefing with citations.

### 5. Data Analysis
End-to-end data analysis: load CSV/data, validate schema, handle missing values, compute statistics, identify trends, visualize with charts, produce PDF-ready report.

### 6. Prompt Engineer
Guide for crafting effective prompts: define objective, choose persona, specify format, set constraints, iterate via A/B testing, document what works.

### 7. Meeting Notes & Summarizer
Structured meeting capture: participants, agenda, key decisions, action items (owner + deadline), risks, follow-up schedule. Works with transcript or notes.

### 8. Security Review
AppSec-focused code review referencing OWASP Top 10: injection, broken auth, XSS, insecure deserialization, misconfiguration, sensitive data exposure. Evidence-first triage.

### 9. Translation & Localization
High-quality translation workflow: preserve formatting/links, handle idioms/context, maintain terminology consistency, adapt for locale (dates, currency, units).

### 10. RAG Knowledge Guide
Guide for working with Open WebUI Knowledge bases: chunking strategies, query formulation, retrieval optimization, combining multiple knowledge sources, troubleshooting low-quality results.

## Success Criteria

- Each file imports cleanly into Open WebUI via Workspace > Skills > Import
- Each skill is self-contained, actionable, and follows documented best practices
- Skills are usable both via `$mention` and as model-attached skills
