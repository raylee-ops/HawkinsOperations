# Scenario 10: Unauthorized Firewall Rule Change - pfSense

## Environment Context
- **Primary Detection**: pfSense configuration logs, Wazuh (if monitoring pfSense), change management system
- **Affected System**: pfSense firewall/router
- **HawkinsOps Components Involved**:
  - pfSense (network gateway/firewall)
  - All protected network segments
  - Wazuh server (if pfSense syslog configured)
  - PRIMARY_OS (investigation/remediation workstation)

## Detection

### Detection Methods

**pfSense Native Logging:**
- Configuration change logs
- User authentication logs (who logged into pfSense)
- Firewall rule modification timestamps
- System logs showing rule reloads

**Wazuh Alerts** (if pfSense sends syslogs to Wazuh):
- pfSense authentication events
- Configuration change notifications
- Custom rules for firewall modifications

**External Indicators:**
- Unexpected network connectivity changes
- Services becoming accessible/inaccessible
- Security scans detect newly opened ports
- Users report connectivity issues
- Unusual traffic patterns detected

**Change Management:**
- No corresponding change ticket
- Modification outside change window
- Unknown administrator

## Triage Steps

1. **Review pfSense Configuration Change Log**
   ```
   Navigate to: Status → System Logs → System
   Look for entries containing:
   - "webConfigurator"
   - "filter reload"
   - "firewall rules"

   Note: timestamp, username, source IP of change
   ```

2. **Check Recent Configuration History**
   ```
   Diagnostics → Backup & Restore → Config History
   - Review recent configuration changes
   - Compare timestamps with alert
   - Download affected config version for analysis
   ```

3. **Identify What Was Changed**
   ```
   Firewall → Rules → All tabs (WAN, LAN, VPN, etc.)
   - Review all rules for unexpected entries
   - Check for:
     * New rules allowing inbound traffic
     * Disabled security rules
     * Changes to existing rules (source/dest/port)
     * Logging disabled on rules

   Compare against baseline or previous config:
   Diagnostics → Backup & Restore → Config History
   Download current and previous version
   Use diff tool to compare
   ```

4. **Review Authentication Logs**
   ```
   Status → System Logs → System
   Filter for authentication events:
   - Successful admin logins
   - Failed login attempts
   - Source IPs of login attempts

   Check for:
   - Logins from unexpected IPs
   - Logins at unusual times
   - Multiple failed attempts before success (brute-force)
   - Accounts you don't recognize
   ```

5. **Check for Other Configuration Changes**
   ```
   Review all sections for unauthorized modifications:

   System → User Manager:
   - New user accounts created?
   - Existing accounts modified (privileges elevated)?

   VPN → OpenVPN / IPsec:
   - New VPN users or tunnels?
   - Changes to VPN settings?

   Services → DHCP Server:
   - Changed IP assignments?
   - New static mappings?

   System → Advanced:
   - SSH enabled/disabled?
   - Secure Shell settings changed?

   Firewall → NAT:
   - Port forwards added/modified?
   - Outbound NAT changes?
   ```

6. **Analyze Config File Diff**
   ```bash
   # On PRIMARY_OS:
   # Download both configs from pfSense:
   # Diagnostics → Backup & Restore → Download configuration

   # Extract XML from .xml files:
   # Use diff or specialized config comparison tool

   diff -u pfsense_config_before.xml pfsense_config_after.xml > config_changes.diff

   # Or use vimdiff for visual comparison:
   vimdiff pfsense_config_before.xml pfsense_config_after.xml

   # Look for changes in:
   # - <filter> section (firewall rules)
   # - <nat> section (port forwards)
   # - <system><user> (user accounts)
   ```

7. **Investigate Who Made the Change**
   ```
   From System Logs, identify:
   - Username that made change
   - Source IP of admin session
   - Time of change

   Verify:
   - Is this a legitimate admin?
   - Was admin authorized to make this change?
   - Does source IP match admin's expected location?
   - Was admin working at this time? (verify with admin directly)

   Check if account is compromised:
   - Recent password changes?
   - Failed login attempts for this account?
   - Same account making changes from multiple IPs?
   ```

8. **Assess Impact of Change**
   ```
   If firewall rule added/modified:
   - What traffic does it allow/block?
   - Does it expose internal services?
   - Does it bypass security controls?
   - Could it enable data exfiltration?
   - Does it allow lateral movement?

   Check current connections:
   Diagnostics → States → Show States
   - Look for connections matching suspicious new rule
   - Identify any active exploitation
   ```

9. **Check for Network Anomalies**
   ```
   Status → Monitoring → Traffic Graph
   - Unusual traffic spikes after rule change?
   - New destinations being contacted?

   Status → System Logs → Firewall
   - New traffic patterns matching suspicious rule
   - High volume of connections on newly opened port
   ```

10. **Review Wazuh Alerts** (if integrated)
    ```
    Check for correlated events:
    - Unusual network traffic from protected hosts
    - Newly accessible services being probed
    - Connection attempts to previously blocked destinations
    ```

## Investigation Checklist

- [ ] Change corresponds to approved change ticket?
- [ ] Admin account that made change is legitimate and authorized?
- [ ] Source IP of change matches expected admin location?
- [ ] Admin confirms they made the change?
- [ ] Change made during authorized maintenance window?
- [ ] Firewall rule allows unexpected inbound access?
- [ ] Firewall rule disables critical security control?
- [ ] Other configuration changes made simultaneously (user accounts, VPN, etc.)?
- [ ] Evidence of account compromise (brute-force, unusual login patterns)?
- [ ] Network traffic shows exploitation of new rule?
- [ ] Similar unauthorized changes on other network devices?
- [ ] Configuration backup available for rollback?

## Containment Actions

### IMMEDIATE ACTIONS (if malicious):

1. **Revert Unauthorized Rule Change**
   ```
   Option 1 - Manual reversion:
   Firewall → Rules → [affected interface]
   - Delete unauthorized rule, or
   - Modify rule back to original state
   - Click Apply Changes

   Option 2 - Config rollback (if major changes):
   Diagnostics → Backup & Restore → Config History
   - Select configuration from before unauthorized change
   - Click "Restore" button
   - Confirm restoration
   - pfSense will reload with previous configuration
   ```

2. **Block Attacker IP** (if external access detected)
   ```
   Firewall → Rules → WAN (or mgmt interface)
   - Add block rule for attacker IP at top of rule list
   - Apply changes

   OR

   Diagnostics → Tables → View → bogonsv4
   - Manually add IP to block table (temporary)
   ```

3. **Disable Compromised Admin Account**
   ```
   System → User Manager
   - Locate compromised account
   - Click "Disabled" checkbox
   - Save changes

   OR completely delete if it's an unauthorized account
   ```

4. **Kill Active Admin Sessions**
   ```
   Status → System Logs → System
   - Identify session ID of suspicious admin

   Diagnostics → Command Prompt
   Execute: pkill -KILL -U <username>

   OR restart web interface:
   Diagnostics → Reboot → Submit (only if necessary)
   ```

5. **Reset Admin Account Password**
   ```
   System → User Manager
   - Edit affected admin account
   - Set new strong password
   - Save

   Notify legitimate admin of password change via secure channel
   ```

6. **Restrict Admin Access**
   ```
   System → Advanced → Admin Access
   - Change webConfigurator port (default 443 to custom)
   - Disable HTTP redirect if enabled
   - Set "Allowed IP addresses" to restrict admin access to trusted IPs only

   System → Advanced → Admin Access → Secure Shell
   - Disable SSH if not needed
   - Or restrict SSH to specific IPs
   ```

7. **Check for Backdoors**
   ```
   Review for:

   Firewall → Rules:
   - Hidden rules allowing attacker access

   System → User Manager:
   - Unauthorized user accounts

   VPN → OpenVPN / IPsec:
   - Unauthorized VPN users or tunnels

   System → Package Manager → Installed Packages:
   - Unexpected packages installed

   Diagnostics → Command Prompt:
   # Check for suspicious processes:
   ps auxww | grep -v "^\[" | less

   # Check for unexpected listening ports:
   sockstat -4l
   ```

### POST-INCIDENT:

1. **Enable Enhanced Logging**
   ```
   Status → System Logs → Settings
   - Increase log retention
   - Enable remote syslog to Wazuh
   - Enable all relevant log categories
   ```

2. **Document Incident**
   - What was changed
   - By whom (or unauthorized entity)
   - When it occurred
   - How it was detected
   - What was the impact
   - Remediation actions taken

3. **Notify Stakeholders**
   - Security team
   - Network team
   - Management (if significant)
   - Affected business units (if connectivity impacted)

## Evidence to Capture

1. **Configuration Files**
   ```
   Diagnostics → Backup & Restore → Download configuration
   - Download current config
   - Download pre-incident config from Config History

   Save to: ~/HAWKINS_OPS/incidents/YYYY-MM-DD_pfsense_unauthorized_change/
   ```

2. **System Logs**
   ```
   Status → System Logs → System
   - Save/export entire log for relevant timeframe

   Manual method: SSH to pfSense
   cat /var/log/system.log > /tmp/system.log
   scp /tmp/system.log admin@PRIMARY_OS:~/HAWKINS_OPS/incidents/YYYY-MM-DD_pfsense_unauthorized_change/
   ```

3. **Firewall Logs**
   ```
   Status → System Logs → Firewall
   - Export logs showing traffic matching unauthorized rule

   Save to: ~/HAWKINS_OPS/incidents/YYYY-MM-DD_pfsense_unauthorized_change/firewall.log
   ```

4. **Config Diff**
   ```bash
   # On PRIMARY_OS after downloading both configs:
   diff -u pfsense_config_before.xml pfsense_config_after.xml > \
     ~/HAWKINS_OPS/incidents/YYYY-MM-DD_pfsense_unauthorized_change/config_diff.txt
   ```

5. **Authentication Logs**
   ```
   From System Logs, extract all authentication events:
   - Failed login attempts
   - Successful logins
   - Logouts

   Document: username, source IP, timestamp
   ```

6. **Screenshots**
   - Unauthorized firewall rule (before deletion)
   - System log showing configuration change
   - Config History page
   - Authentication log entries
   - User Manager page (if accounts added/modified)

7. **Network State**
   ```
   Diagnostics → States → Show States
   - Export current connection states

   Status → Monitoring → Traffic Graph
   - Screenshot traffic patterns
   ```

8. **Wazuh Alerts** (if applicable)
   - Export any correlated Wazuh alerts
   - Network traffic anomalies

9. **Change Management**
   - Document lack of change ticket (or unauthorized change)
   - Email communications about the change (if any)

## Closure & Lessons Learned

### Ticket Closure Steps:
1. Verify unauthorized change has been reverted
2. Confirm no backdoors or persistence mechanisms remain
3. Validate all admin accounts are authorized and secured
4. Update change management system with incident details
5. Archive all evidence
6. Update runbooks based on lessons learned

### Hardening Recommendations:

**Access Control:**
- **Implement MFA for pfSense admin access**:
  ```
  System → User Manager → Authentication Servers
  - Add RADIUS or LDAP with MFA
  - Or use package: "FreeRADIUS" + Google Authenticator
  ```
- **Restrict admin access to specific IPs**:
  ```
  System → Advanced → Admin Access
  - Set "Allowed IP addresses" to management network only
  ```
- **Disable admin access from WAN** (if currently allowed):
  ```
  System → Advanced → Admin Access
  - Uncheck "Enable webConfigurator on WAN"
  ```
- **Change default admin ports**:
  ```
  System → Advanced → Admin Access
  - TCP port: 443 → custom port (e.g., 8443)
  - Reduces automated attacks
  ```
- **Disable unused admin protocols**:
  ```
  System → Advanced → Admin Access → Secure Shell
  - Disable SSH if not needed
  - Or use SSH key authentication only
  ```

**Monitoring & Alerting:**
- **Send pfSense logs to Wazuh**:
  ```
  Status → System Logs → Settings → Remote Logging
  - Enable "Send log messages to remote syslog server"
  - Remote log server: <Wazuh_IP>:514
  - Check all relevant log categories
  ```
- **Create Wazuh rules for pfSense**:
  - Admin authentication (success/failure)
  - Configuration changes
  - Firewall rule modifications
  - New user account creation
- **Enable email alerts for config changes**:
  ```
  System → Advanced → Notifications
  - Configure SMTP settings
  - Enable notifications for configuration changes
  ```

**Change Management:**
- **Implement formal change control process**
  - All firewall changes require approved ticket
  - Peer review for rule changes
  - Testing in non-production environment
- **Configuration backups**:
  ```
  Diagnostics → Backup & Restore
  - Schedule automatic backups (use AutoConfigBackup package)
  - Store backups off-device
  - Test restoration process quarterly
  ```
- **Baseline firewall rules**:
  - Document approved rules with business justification
  - Regular audits (monthly/quarterly)
  - Remove unused rules

**Hardening:**
- **Principle of least privilege**:
  ```
  System → User Manager
  - Create role-based accounts (read-only, firewall-admin, full-admin)
  - Users only get privileges needed for their role
  ```
- **Session timeout**:
  ```
  System → Advanced → Admin Access
  - Set "Session timeout" to reasonable value (e.g., 15 minutes)
  ```
- **HTTPS only**:
  ```
  System → Advanced → Admin Access
  - Disable "Disable HTTP Redirect"
  - Ensure valid SSL certificate installed
  ```
- **Keep pfSense updated**:
  ```
  System → Update
  - Regular patching schedule
  - Subscribe to pfSense security advisories
  ```
- **Audit user accounts**:
  ```
  System → User Manager
  - Remove accounts for former admins
  - Regular quarterly review of access
  ```
- **Disable package installation** (if not needed):
  ```
  System → Package Manager
  - Remove ability for lower-privilege admins
  ```

**Documentation:**
- **Maintain network diagram** showing firewall rules and segmentation
- **Document all firewall rules** with business justification
- **Standard Operating Procedures** for firewall changes
- **Incident response plan** for firewall compromise

**Testing:**
- **Regular penetration testing** of firewall configuration
- **Quarterly firewall rule audit**
- **Test incident response procedures** (tabletop exercises)
- **Validate backups** - test restoration quarterly

### Portfolio Notes:
- Demonstrates understanding of network security architecture
- Shows firewall administration and troubleshooting skills
- Highlights change management and configuration control
- Emphasizes defense of critical infrastructure
- Understanding of access control and authentication
- Incident response for infrastructure compromise
