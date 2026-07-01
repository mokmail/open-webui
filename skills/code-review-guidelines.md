---
name: Code Review Guidelines
description: Systematic code review covering security, correctness, performance, style, and testing
tags: [code-review, development, best-practices, quality]
version: 1.0.0
---

# Code Review Guidelines

## Process

1. Understand the change: Read the PR description, linked issues, and related context before reviewing code.
2. Review each file in order: Start with entry points and work inward.
3. Categorize every finding using severity tiers below.
4. For each finding: cite the exact file + line, explain WHY it's a problem, and provide a concrete fix snippet.
5. Write a summary: overall assessment, counts by severity, and a clear recommendation (approve / request changes).

## Severity Tiers

| Severity | Label | Action |
|----------|-------|--------|
| 🔴 Critical | Must fix | Security vulnerabilities, data loss, crashes, incorrect business logic |
| 🟡 Warning | Should fix | Performance issues, correctness edge cases, error handling gaps |
| 🔵 Suggestion | Nice to have | Refactoring opportunities, readability improvements |
| 💬 Nitpick | Optional | Naming preferences, formatting (if no formatter is in use) |

## What to Check

### Security
- SQL injection, command injection, path traversal
- Hardcoded secrets, tokens, or credentials
- Missing or broken authentication/authorization checks
- Unsafe deserialization
- Cross-site scripting (XSS) in user-facing output
- Insecure direct object references (IDOR)

### Correctness
- Logic errors, off-by-one, incorrect comparisons
- Unhandled edge cases (empty input, null values, boundary conditions)
- Race conditions in concurrent code
- Missing error handling: exceptions swallowed without logging or recovery
- Incorrect state management

### Performance
- N+1 database queries
- Unnecessary loops or iterations
- Missing database indexes
- Large objects in memory unnecessarily
- Blocking calls in async code paths
- Redundant API calls or computations

### Style & Maintainability
- Inconsistent naming conventions with the project
- Functions or methods that are too long or do too many things
- Dead code, commented-out code, or unused imports
- Magic numbers or strings without named constants
- Missing or misleading docstrings/comments
- Overly complex conditionals or nested structures

### Testing
- New code paths covered by tests
- Edge cases tested (empty states, errors, boundary values)
- Tests are deterministic and not flaky
- Mocks are appropriate — not over-mocked, not under-mocked

## Output Format

For each finding follow this template:

```
**{severity}** `{file}:{line}` — {short title}
> {explanation of why this is a problem}
> **Fix:** {concrete code snippet or description of the fix}
```

End with:

```
## Summary
- 🔴 Critical: N
- 🟡 Warning: N
- 🔵 Suggestion: N
- 💬 Nitpick: N
**Recommendation:** {Approve / Request changes}
```
