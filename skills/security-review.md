---
name: Security Review
description: AppSec-focused code review referencing OWASP Top 10 with evidence-first triage
tags: [security, appsec, code-review, penetration-testing]
version: 1.0.0
---

# Security Review

## Principles

- **Evidence first, severity second.** Triage based on exploitability and impact, not on category labels.
- **Safe by default.** All review is read-only. Never execute untrusted code or access production data.
- **Report clearly.** Each finding must include: location, proof of concept or evidence, impact, and remediation.

## Review Checklist

### Authentication & Authorization
- [ ] Session management: tokens stored securely, proper expiry, rotation on privilege change
- [ ] Password policies: minimum strength, hashing algorithm (bcrypt/argon2/scrypt), no plaintext storage
- [ ] Authorization checks on every endpoint/resource — not just on the UI layer
- [ ] Role-based access control (RBAC) enforced server-side
- [ ] Insecure direct object references (IDOR): user A should not access user B's data by changing an ID

### Input Validation & Injection
- [ ] SQL injection: parameterized queries or ORM usage everywhere — no string concatenation
- [ ] Command injection: no user input passed to shell commands without strict validation
- [ ] Cross-site scripting (XSS): output encoding for all user-supplied data in HTML/JS context
- [ ] File upload: file type validation (content-type + magic bytes, not just extension), size limits, virus scanning
- [ ] SSRF: outbound request URLs validated against allowlist, not user-supplied

### Data Protection
- [ ] Secrets and keys: stored in environment variables or a vault, not in code or config files
- [ ] Encryption in transit: TLS everywhere, no HTTP internal endpoints transmitting sensitive data
- [ ] Encryption at rest: sensitive columns/tables encrypted, proper key management
- [ ] Logging: no secrets, PII, or session tokens in logs
- [ ] Data exposure: APIs return only the fields the caller needs, not full database objects

### Configuration & Deployment
- [ ] Debug/development endpoints disabled in production
- [ ] CORS configured to the minimum necessary origins
- [ ] Rate limiting on authentication endpoints and APIs
- [ ] Dependency vulnerabilities: check for known CVEs in dependencies
- [ ] Container/host: no unnecessary ports exposed, minimal base images, non-root user

### Business Logic
- [ ] Rate limiting / abuse prevention on sensitive operations
- [ ] Transaction integrity: no race conditions on payments, credits, or inventory
- [ ] Idempotency on critical operations to prevent duplicate processing
- [ ] Audit trail: who did what and when for sensitive operations

## Severity Definitions

| Severity | Criteria |
|----------|----------|
| 🔴 Critical | Direct exploit path to data breach, RCE, privilege escalation, or account takeover |
| 🟠 High | Exploitable with moderate effort; significant impact but requires conditions |
| 🟡 Medium | Limited exploitability or impact; defense-in-depth gap |
| 🔵 Low | Theoretical risk, hardening opportunity, policy violation with no active exploit path |

## Output Template

```
## Finding: {Title}
**Severity:** {level}
**Location:** `{file}:{line}`
**Type:** {OWASP category or CWE}
**Impact:** {what an attacker could achieve}
**Evidence:** {code snippet, request/response, or description of the vulnerable scenario}
**Fix:** {specific remediation steps with code example if applicable}
```
