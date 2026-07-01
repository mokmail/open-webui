---
name: Meeting Notes and Summarizer
description: Structured meeting capture with decisions, action items, and follow-ups
tags: [meetings, productivity, notes, collaboration]
version: 1.0.0
---

# Meeting Notes & Summarizer

## Input Sources

Process meeting information from:
- Raw transcript or chat log
- Bullet-point notes
- Audio/video recording description
- Calendar invite with agenda

## Output Format

### Standard Meeting Summary

```
# Meeting Summary: {Meeting Title}
**Date:** {date}
**Duration:** {duration}
**Participants:** {names, count}

## Agenda
{List of topics discussed}

## Key Decisions
{Each decision with context and rationale}

## Action Items
| # | Action | Owner | Deadline | Status |
|---|--------|-------|----------|--------|
| 1 | {task} | @person | {date} | ☐ |
| 2 | {task} | @person | {date} | ☐ |

## Discussion Notes
### {Topic 1}
{Key points, arguments, data presented}

### {Topic 2}
{Key points, arguments, data presented}

## Risks & Blockers
- {Risk/blocker} — {owner} — {impact if not resolved}

## Next Meeting
{Date/time or "No next meeting scheduled"}
```

### When Given a Transcript Specifically

1. Identify speaker turns and tag each point to the speaker.
2. Distinguish between: statements of fact, opinions, questions, commitments.
3. Flag any decision made explicitly (e.g., "we agreed to...", "let's go with...").
4. Extract every action item: look for verbs like "I will", "can you", "please", assignment language.
5. Resolve ambiguous ownership: if someone says "we need to do X" but no owner is named, flag it as unassigned.

### Summary Tone

- Neutral and factual. Do not editorialize.
- Capture dissent: "Person A proposed X, Person B disagreed because Y."
- Prioritize decisions and action items over discussion detail.
- Omit off-topic tangents unless they produced a decision or action item.

## Quality Checklist

- [ ] Every action item has an owner
- [ ] Every deadline is captured (or explicitly noted as TBD)
- [ ] Decisions are stated clearly, not buried in narrative text
- [ ] Participants who were mentioned but absent are noted
- [ ] Risks/blockers are surfaced prominently
