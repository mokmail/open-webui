---
name: Translation and Localization
description: High-quality multi-language translation preserving meaning, context, and locale conventions
tags: [translation, localization, i18n, language]
version: 1.0.0
---

# Translation & Localization

## Workflow

### 1. Analyze Source Content
Before translating, assess the source:
- Identify the content type: technical docs, marketing copy, UI strings, legal text, creative content.
- Note special elements: code snippets, links, variables/placeholders, formatting tags, images with text.
- Identify culturally specific references, idioms, metaphors, or humor.
- Determine the target audience and locale (not just language — e.g., Spanish for Mexico vs Spain).

### 2. Translate for Meaning, Not Words
- Translate the meaning of each sentence, not a word-for-word substitution.
- Adapt idioms and metaphors to culturally equivalent expressions in the target language.
- Preserve the original tone: formal, casual, technical, persuasive.
- Maintain consistent terminology for key concepts throughout.

### 3. Handle Technical Elements
- **Variables/placeholders:** Preserve `{variable}`, `%s`, `{{mustache}}`, and other template syntax exactly.
- **Code:** Do not translate code, commands, or identifiers. Translate comments and user-facing strings only.
- **Links/URLs:** Keep URLs intact. If localized pages exist, update the path accordingly.
- **Formatting:** Preserve Markdown, HTML, and other markup exactly.
- **Length sensitivity:** UI strings may need shortening to fit buttons, labels, or layouts.

### 4. Locale Adaptation
Adapt for the target locale:
- **Dates:** M/D/Y → D/M/Y or Y-M-D depending on locale
- **Time:** 12h vs 24h format, timezone awareness
- **Currency:** Symbol placement ($10 vs 10$), decimal separators (1,234.56 vs 1.234,56)
- **Units:** imperial ↔ metric, temperature, distance, volume
- **Names:** Personal name order (given + family vs family + given)
- **Addresses:** Format per local postal standard
- **Numbers:** Digit grouping, decimal separator

### 5. Review & Quality Check
- Check for truncation: does the translation fit UI constraints?
- Check for placeholder integrity: are all `{variables}` present and in the right positions?
- Check for consistency: are key terms translated the same way throughout?
- Check for left-to-right vs right-to-left layout impacts if applicable.
- Review for false friends and literal translations that change meaning.

## Output Format

Present translations as a side-by-side comparison:

```
## {Document/Section Name}

| Source ({source_lang}) | Translation ({target_lang}) |
|------------------------|----------------------------|
| Original text here      | Translated text here        |
| ...                     | ...                         |

### Notes
- {Any adaptation decisions, cultural substitutions, or formatting changes}
```

## When to Flag
- Ambiguous source text that could be interpreted multiple ways
- Content that references localized laws, regulations, or norms you can't verify
- Terms that don't have a standard translation in the target language
- Source text with regional dialects or slang
