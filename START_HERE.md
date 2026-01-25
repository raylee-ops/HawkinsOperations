# Start Here

## 90-Second Validation Path (Recruiters & Hiring Managers)

Validate this portfolio in under 90 seconds:

### 1. README → What's Here (20 seconds)
**File:** `README.md`

**What you'll see:**
- Multi-platform detection rules (Sigma, Splunk, Wazuh)
- Incident response playbooks
- Verifiable counts (no hard-coded claims)

**Key takeaway:** Multi-platform SOC expertise with deployment path

---

### 2. Verified Counts → Proof (15 seconds)
**File:** `PROOF_PACK/VERIFIED_COUNTS.md`

**What you'll see:**
- Auto-verified detection rule counts
- Platform breakdown (Sigma, Splunk, Wazuh)
- IR playbook counts
- Last verification timestamp

**Key takeaway:** Claims are verifiable and auto-validated via GitHub Actions

---

### 3. Samples → Quality Check (30 seconds)
**File:** `PROOF_PACK/SAMPLES/README.md`

**What you'll see:**
- 2 Sigma rules (credential dumping, encoded PowerShell)
- 1 Splunk query (LSASS detection)
- 1 Wazuh rule (brute force detection)
- 1 IR playbook excerpt (LSASS response)

**Key takeaway:** Production-ready content with MITRE ATT&CK mapping

---

### 4. Architecture → Technical Depth (15 seconds)
**File:** `PROOF_PACK/ARCHITECTURE.md`

**What you'll see:**
- Detection platform coverage (Sigma/Splunk/Wazuh)
- 7-step IR framework
- Deployment architecture (repo → production)
- MITRE ATT&CK tactic mapping

**Key takeaway:** Understands production SOC operations, not just theory

---

### 5. Deployment → Production Ready (10 seconds)
**File:** `docs/wazuh/DEPLOYMENT_REALITY.md`

**What you'll see:**
- Build script: `scripts/build-wazuh-bundle.sh`
- Deployment target: `/var/ossec/etc/rules/local_rules.xml`
- Verification commands

**Key takeaway:** Rules aren't just YAML files—they're deployable to production

---

## For Technical Reviewers

If you have more time and want to validate claims:

### Run Verification Commands (2 minutes)
**File:** `docs/VERIFY_COMMANDS_POWERSHELL.md`

From repo root (Windows PowerShell):
```powershell
# Count all detection rules by platform
$sigma  = (Get-ChildItem -Recurse -Filter *.yml -Path ".\detection-rules\sigma" -ErrorAction SilentlyContinue).Count
$splunk = (Get-ChildItem -Recurse -Filter *.spl -Path ".\detection-rules\splunk" -ErrorAction SilentlyContinue).Count
$wazuhXmlFiles = (Get-ChildItem -Recurse -Filter *.xml -Path ".\detection-rules\wazuh\rules" -ErrorAction SilentlyContinue).Count
$wazuhRuleBlocks = (Get-ChildItem -Recurse -Filter *.xml -Path ".\detection-rules\wazuh\rules" -ErrorAction SilentlyContinue |
    Select-String -Pattern "<rule id=" | Measure-Object).Count

Write-Host "Sigma (.yml): $sigma | Splunk (.spl): $splunk | Wazuh XML files: $wazuhXmlFiles | Wazuh rule blocks: $wazuhRuleBlocks"
```

**Expected result:** Counts match `PROOF_PACK/VERIFIED_COUNTS.md`

### Build Wazuh Bundle (1 minute)
From repo root:

**PowerShell (Windows):**
```powershell
.\scripts\build-wazuh-bundle.ps1
```

**Bash (Linux/WSL):**
```bash
bash ./scripts/build-wazuh-bundle.sh
```

**Output:** `dist/wazuh/local_rules.xml`

**What this proves:** Rules are production-deployable, not just theoretical

---

## Deep Dive (Optional)

Want to explore specific content?

| Area | Location | Time |
|------|----------|------|
| **Detection Rules** | `detection-rules/INDEX.md` | 2 min |
| **IR Playbooks** | `incident-response/00-Playbook-Index.md` | 2 min |
| **Threat Hunting** | `threat-hunting/00-Hunt-Matrix.md` | 2 min |
| **Security Policy** | `SECURITY.md` | 1 min |

---

## Interview Prep

**Common questions this repo answers:**

**Q: "How many detection rules have you written?"**
A: Check `PROOF_PACK/VERIFIED_COUNTS.md` for exact counts by platform

**Q: "Can you walk me through a detection you've written?"**
A: Review `PROOF_PACK/SAMPLES/README.md` for annotated examples

**Q: "How would you respond to an LSASS access alert?"**
A: See `incident-response/playbooks/IR-001-LSASS-Access.md`

**Q: "Do you have production deployment experience?"**
A: See `docs/wazuh/DEPLOYMENT_REALITY.md` and `scripts/build-wazuh-bundle.sh`

---

**Total validation time:** 90 seconds
**What you validated:** Multi-platform detection expertise, production deployment knowledge, structured IR methodology, verifiable claims
