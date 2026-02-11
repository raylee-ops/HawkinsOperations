---
name: Feature Request
about: Suggest a new detection rule, playbook, or enhancement
title: '[FEATURE] '
labels: enhancement
assignees: ''

---

## Feature Description

**What would you like to add or change:**
A clear and concise description of the feature or enhancement.

**Type of Request:**
- [ ] New Detection Rule (Sigma/Splunk/Wazuh)
- [ ] New IR Playbook
- [ ] Documentation Enhancement
- [ ] Script/Automation Improvement
- [ ] New Platform Support
- [ ] Other (specify)

---

## Use Case

**Problem this solves:**
Describe the security scenario or problem this feature addresses.

**MITRE ATT&CK Technique:** (if applicable)
T#### - Technique Name

**Example Scenario:**
Provide a concrete example of when this would be useful.

---

## Proposed Solution

**How it should work:**
Describe your proposed implementation or approach.

**Example Detection Logic:** (if applicable)
\`\`\`yaml
# Sigma example
title: Your Rule Title
detection:
  selection:
    # Your detection logic
\`\`\`

**Example Playbook Steps:** (if applicable)
1. Detection
2. Triage
3. Investigation
...

---

## Alternatives Considered

**Other approaches you've considered:**
Describe alternative solutions or features you've considered.

**Why this approach is better:**
Explain why your proposed solution is preferable.

---

## Additional Context

**References:**
- MITRE ATT&CK: https://attack.mitre.org/techniques/T####/
- Research/Blog Posts: (links)
- Similar implementations: (links)

**Platform Compatibility:**
Which platforms should this support? (Sigma/Splunk/Wazuh/All)

---

## Checklist

- [ ] I have searched existing issues/PRs to avoid duplicates
- [ ] I have described the use case clearly
- [ ] I have provided example logic or steps (if applicable)
- [ ] I have included MITRE ATT&CK mapping (if applicable)
- [ ] This aligns with the repository's purpose (security operations portfolio)
