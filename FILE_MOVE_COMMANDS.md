# File Organization Commands

Run these commands to move your existing misplaced files into the correct folders.

---

## Before You Start

```bash
cd /path/to/hawkinsops-soc-content
git status  # Make sure you're in the right repo
```

---

## Move Index Files to Correct Folders

```bash
# Hunt Matrix goes to threat-hunting
git mv 00-Hunt-Matrix.md threat-hunting/

# Playbook Index goes to incident-response
git mv 00-Playbook-Index.md incident-response/

# Rule Index goes to detection-rules
git mv 00-Rule-Index.md detection-rules/
```

---

## Move Playbooks to Correct Folder

```bash
# Create playbooks subfolder if it doesn't exist
mkdir -p incident-response/playbooks

# Move all IR playbooks
git mv IR-001-LSASS-Access.md incident-response/playbooks/
git mv IR-002-Suspicious-PowerShell.md incident-response/playbooks/
git mv IR-003-Ransomware-Detected.md incident-response/playbooks/
git mv IR-004-to-030-Quick-Reference.md incident-response/playbooks/
git mv IR-Template.md incident-response/playbooks/
```

---

## Move Loose YAML Files (if any at root)

```bash
# If you have .yml files at root, move them to sigma folder
# First check what tactic they belong to, then move accordingly

# Example for credential access rules:
git mv account_manipulation.yml detection-rules/sigma/credential-access/
git mv ad_enumeration.yml detection-rules/sigma/discovery/
```

---

## Commit the Organization

```bash
git add .
git commit -m "Organize files into correct folder structure"
git push origin main
```

---

## Verify Clean Root

After moving, your root should only have:
- README.md
- .gitignore
- detection-rules/
- incident-response/
- threat-hunting/
- runbooks/
- learning-system/
- PROOF_PACK/

No loose .md or .yml files at root.

---

## If You Get Merge Conflicts

```bash
# If files were edited on GitHub while you worked locally:
git pull --rebase origin main
# Then try pushing again
git push origin main
```

---

## If You Need to Undo

```bash
# Undo last commit but keep files staged
git reset --soft HEAD~1

# Undo last commit and unstage files
git reset HEAD~1

# Nuclear option: discard all local changes
git checkout -- .
```
