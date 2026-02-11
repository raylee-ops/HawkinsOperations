# v1.0.1 Release Checklist (Day 2)

## Canonical + link integrity
- [ ] Archived/legacy repos clearly point to the canonical repo (no dead ends)
- [ ] No references to deprecated repo names remain in this repo (run name purge)

## Wazuh credibility
- [ ] `docs/wazuh/DEPLOYMENT_REALITY.md` matches the repo layout
- [ ] `docs/VERIFY_COMMANDS_POWERSHELL.md` produces the counts you cite
- [ ] Bundle script generates `dist/wazuh/local_rules.xml`

## Repo hygiene
- [ ] `.github` templates present (PR + issue templates)
- [ ] `SECURITY.md` present (no spam email required)
- [ ] `LICENSE` present

## Release artifact
- [ ] Tag: `v1.0.1`
- [ ] GitHub Release notes summarize: verification + reality bridge + hygiene
