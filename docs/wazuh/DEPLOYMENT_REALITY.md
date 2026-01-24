# Wazuh Deployment Reality (HawkinsOperations)

This repo stores Wazuh rules in a **portfolio-friendly** layout, but Wazuh managers expect rules in specific directories on disk.

This document bridges that gap.

---

## Where the rules live in this repo (source of truth)

**Primary Wazuh rule modules (XML, stored individually):**

- `detection-rules/wazuh/_incoming/WAZUH_RULES_PRIMARY/*.xml`

> Note: some XML modules contain **multiple `<rule id="...">` blocks**. Use `docs/VERIFY_COMMANDS_POWERSHELL.md` to count rule blocks accurately.

---

## Where the rules go on a Wazuh manager (deployment target)

Typical Wazuh manager locations:

- Rules: `/var/ossec/etc/rules/`
- Decoders: `/var/ossec/etc/decoders/`
- Lists: `/var/ossec/etc/lists/`

For a simple “portfolio deploy,” we bundle your rule modules into **one** file:

- Target file: `/var/ossec/etc/rules/local_rules.xml`

---

## Fast path: build a deployable bundle

From repo root:

```bash
bash ./scripts/build-wazuh-bundle.sh
```

Output:

- `dist/wazuh/local_rules.xml`

---

## Deploy to manager (example)

```bash
sudo cp dist/wazuh/local_rules.xml /var/ossec/etc/rules/local_rules.xml
sudo systemctl restart wazuh-manager
```

---

## Verify rules loaded (example)

```bash
sudo tail -n 120 /var/ossec/logs/ossec.log | grep -i -E 'rule|local_rules'
```

If you see XML parse errors or rule ID collisions, fix those before calling anything “production-ready.”
