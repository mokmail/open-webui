---
name: Prompt Engineer
description: Guide for crafting, testing, and iterating effective prompts for LLMs
tags: [prompt-engineering, llm, best-practices, optimization]
version: 1.0.0
---

# Prompt Engineer

## Core Principles

1. **Be explicit, not implicit.** State exactly what you want. Don't make the model infer intent.
2. **Provide context before instructions.** Give the model the information it needs before telling it what to do.
3. **Define the output format.** Specify structure, length, tone, and style upfront.
4. **Use examples (few-shot).** Show 1-3 examples of ideal input/output pairs for complex tasks.
5. **Iterate systematically.** Change one variable at a time. Compare outputs side by side.

## Prompt Structure Template

```
## Context
{Background information the model needs to understand the task}

## Role
{Optional: define a persona for the model to adopt}

## Task
{Clear, specific instruction for what to do}

## Requirements
- {Constraint 1: format, length, tone}
- {Constraint 2: what to include or exclude}
- {Constraint 3: audience or reading level}

## Examples
{Optional: 1-3 input/output demonstrations}

## Input
{The actual input to process}
```

## Techniques by Goal

| Goal | Technique |
|------|-----------|
| Complex reasoning | Chain-of-thought: ask the model to think step by step before answering |
| Consistent output | Structured output format with JSON, XML, or markdown template |
| Creative tasks | Provide stylistic examples, set temperature expectations |
| Factual accuracy | Ask the model to cite sources or explain its reasoning |
| Reducing bias | Explicitly ask for multiple perspectives or counterarguments |
| Code generation | Specify language, framework, version, and coding standards |
| Summarization | Include length constraint ("3 sentences", "100 words max") and audience |

## Testing Loop

1. **Write** the prompt following the structure above.
2. **Run** it with representative input.
3. **Evaluate** the output against your criteria (accuracy, format, tone, completeness).
4. **Identify** the gap: is the instruction unclear? Missing context? Wrong format constraint?
5. **Adjust** one element at a time.
6. **Repeat** until output consistently meets the bar.
7. **Freeze** the prompt once stable, and document what worked.

## Common Pitfalls

- Overloading the prompt with too many instructions in one message
- Assuming the model shares your assumptions or context
- Using vague qualifiers ("good", "appropriate", "reasonable") without definition
- Forgetting to set length/format constraints for bulk or repeated use
- Not testing edge cases (empty input, very long input, unusual formatting)
