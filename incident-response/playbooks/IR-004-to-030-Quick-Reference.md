# IR Quick Reference (IR-004 to IR-030)

This file is intentionally lightweight: it’s a fast checklist view for responders.

## Universal first 5 minutes
- Confirm alert source + timestamps
- Identify impacted host/user
- Decide: contain now vs investigate first
- Start a timeline

## Universal containment levers
- Isolate endpoint(s)
- Disable/reset accounts
- Block known bad indicators
- Preserve evidence (logs/process tree)

## Evidence to grab quickly
- EDR process tree + command line
- Auth logs (success/fail, source IP)
- DNS/Proxy logs for outbound
- Any suspicious binaries/scripts (hash + path)
