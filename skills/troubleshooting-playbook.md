---
name: Troubleshooting Playbook
description: Step-by-step diagnostic workflow for system, software, and network issues
tags: [troubleshooting, debugging, operations, devops]
version: 1.0.0
---

# Troubleshooting Playbook

## General Diagnostic Workflow

### 1. Gather Context
- Ask: What exactly is broken? What should be happening vs. what is happening?
- When did it start? Was it working before? What changed recently (deploy, config, dependency)?
- Is it reproducible? On what inputs/environments?
- Who is affected? All users, a subset, just you?

### 2. Check Logs First
- Application logs: recent errors, stack traces, warnings leading up to the issue.
- System logs: `dmesg`, syslog, event viewer for hardware/OS-level indicators.
- Access/audit logs if authentication or authorization is involved.
- Look for patterns: timestamps correlating with the symptom, repeated errors, rate-limited requests.

### 3. Verify Configuration
- Compare config against known-good baseline or documentation.
- Check environment variables and secrets are set correctly.
- Validate config syntax (YAML, JSON, TOML, etc.) if applicable.
- Check for stale caches that might hold old configuration.

### 4. Test Connectivity
- Is the service reachable? `ping`, `curl`, `nc` at the network layer.
- Are the right ports open? `ss`, `netstat`, firewall rules.
- Is DNS resolving correctly? `dig`, `nslookup`, `/etc/hosts`.
- Is TLS/SSL valid? Certificate expiry, chain issues, hostname mismatch.

### 5. Isolate the Variable
- Reduce the system to minimal components. Does it work with just the core?
- Swap components one at a time: different input, different environment, different user.
- Check resource constraints: disk space, memory, CPU, file descriptors, connection pools.
- Check rate limits and throttling if the system is under load.

### 6. Formulate a Hypothesis
- Based on evidence, propose a root cause. Write it down.
- Design a test that would prove or disprove it.
- Run the test. If it disproves the hypothesis, return to step 5.

### 7. Fix & Verify
- Apply the fix with the smallest possible change.
- Verify the fix resolves the issue without introducing new problems.
- Run existing tests or sanity checks.
- Document the root cause and resolution.

## Quick Reference: Common Issues

| Symptom | First Thing to Check |
|---------|---------------------|
| Service won't start | Config syntax, port conflicts, missing dependencies |
| Slow response times | Resource usage (CPU/mem/disk), database query times, upstream latency |
| Error 500 | Application logs, stack trace, recent deploys |
| Connection refused | Is the process running? Is it listening on the expected interface/port? |
| Authentication fails | Secret/key rotation, clock skew, token expiry |
| Data inconsistency | Transaction logs, replication lag, concurrent write conflicts |

## Escalation Criteria
- Root cause is outside your access or expertise.
- Issue causes data loss or corruption.
- Issue is a security incident (follow incident response plan instead).
- Issue affects production customers and you cannot resolve within SLA.
