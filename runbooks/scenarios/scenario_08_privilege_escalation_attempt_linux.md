# Scenario 08: Privilege Escalation Attempt - Linux

## Environment Context
- **Primary Detection**: Wazuh SIEM, Linux auth logs, system monitoring
- **Affected System**: PRIMARY_OS or MINT-3 (Linux endpoints)
- **HawkinsOps Components Involved**:
  - Linux endpoint
  - Wazuh server (monitoring/alerting)
  - pfSense (network context)

## Detection

### Detection Indicators

**Wazuh Alerts:**
- **Rule ID**: 5402 (Successful sudo execution)
- **Rule ID**: 5403 (Failed sudo attempt)
- **Rule ID**: 5555 (Integrity checksum changed)
- **Rule ID**: Custom rules for suspicious privilege escalation behavior

**Linux Log Sources:**
- `/var/log/auth.log` - sudo attempts, su usage, authentication
- `/var/log/secure` - RHEL/CentOS equivalent
- `/var/log/syslog` - General system messages
- Wazuh FIM alerts for SUID/SGID file modifications

**Common Indicators:**
- Multiple failed sudo attempts
- Successful sudo after multiple fails
- SUID/SGID bit set on unusual files
- Kernel module loading (rootkit activity)
- /etc/sudoers file modification
- Exploits targeting known vulnerabilities (Dirty COW, Polkit, etc.)
- Suspicious processes running as root
- User added to sudo/wheel group unexpectedly

## Triage Steps

1. **Review Wazuh Alert**
   - Note: username, command attempted, success/failure
   - Timestamp and frequency of attempts
   - Context: what else was user doing?

2. **Check sudo/su Activity**
   ```bash
   # Recent sudo attempts:
   sudo grep sudo /var/log/auth.log | tail -50

   # Failed sudo attempts:
   sudo grep "sudo.*COMMAND" /var/log/auth.log | grep "NOT" | tail -20

   # Successful sudo by specific user:
   sudo grep "sudo.*<username>.*COMMAND" /var/log/auth.log | tail -30

   # su (switch user) attempts:
   sudo grep "su\[" /var/log/auth.log | tail -20

   # Count failed attempts per user:
   sudo grep "sudo.*NOT" /var/log/auth.log | awk '{print $(NF-2)}' | sort | uniq -c | sort -rn
   ```

3. **Identify Suspicious Commands**
   ```bash
   # What commands were attempted with sudo:
   sudo grep "COMMAND" /var/log/auth.log | tail -50

   # Look for privilege escalation tools:
   sudo grep -E "sudo.*(chmod|chown|visudo|useradd|passwd|pkexec|systemctl)" /var/log/auth.log

   # Check for exploit attempts in syslog:
   sudo grep -E "segfault|exploit|exploit-db" /var/log/syslog
   ```

4. **Check for SUID/SGID Modifications**
   ```bash
   # Find all SUID binaries (should be limited set):
   sudo find / -perm -4000 -type f -ls 2>/dev/null

   # Find all SGID binaries:
   sudo find / -perm -2000 -type f -ls 2>/dev/null

   # Check for recently modified SUID files:
   sudo find / -perm -4000 -type f -mtime -1 -ls 2>/dev/null

   # Compare against baseline (if you have one):
   # diff current_suid_list.txt baseline_suid_list.txt

   # Common suspicious SUID files:
   sudo find / -name "nmap" -o -name "vim" -o -name "python*" -o -name "perl" \
     -o -name "find" -o -name "less" -perm -4000 2>/dev/null
   ```

5. **Check /etc/sudoers Configuration**
   ```bash
   # View current sudoers config:
   sudo cat /etc/sudoers

   # Check sudoers.d directory:
   sudo ls -la /etc/sudoers.d/
   sudo cat /etc/sudoers.d/*

   # Check for recent modifications:
   sudo stat /etc/sudoers
   sudo find /etc/sudoers.d/ -type f -mtime -7 -ls

   # Look for dangerous entries:
   # - NOPASSWD: ALL
   # - User added to ALL=(ALL) ALL
   # - Wildcards in command specifications
   ```

6. **Review User and Group Membership**
   ```bash
   # Check sudo group members:
   grep sudo /etc/group

   # Check wheel group (some distros):
   grep wheel /etc/group

   # Check for recently modified groups:
   sudo stat /etc/group /etc/gshadow

   # Review user's groups:
   groups <username>
   id <username>

   # Check for recently created users:
   sudo grep "useradd\|adduser" /var/log/auth.log
   ```

7. **Look for Kernel Exploits/Modules**
   ```bash
   # List loaded kernel modules:
   lsmod

   # Check for recently loaded modules:
   sudo dmesg | grep -i "module"

   # Check for kernel exploit attempts in logs:
   sudo grep -i "exploit\|overflow\|segfault" /var/log/syslog | tail -50

   # Check kernel version and known vulns:
   uname -a
   # Search for CVEs matching kernel version
   ```

8. **Investigate Running Processes**
   ```bash
   # Processes running as root (should be system processes only):
   ps aux | grep "^root" | less

   # Look for unusual root processes:
   ps aux | grep "^root" | grep -v "\[" | less

   # Check process tree for suspicious hierarchy:
   pstree -p | less

   # Processes running from /tmp or unusual locations:
   sudo lsof +D /tmp | grep -v "chrome\|firefox"
   ```

9. **Check Capabilities** (alternative to SUID)
   ```bash
   # List files with capabilities:
   sudo getcap -r / 2>/dev/null

   # Common dangerous capabilities:
   # CAP_SETUID, CAP_SETGID, CAP_SYS_ADMIN
   ```

10. **Review Scheduled Tasks** (persistence)
    ```bash
    # User cron jobs:
    crontab -l
    sudo crontab -l

    # System cron:
    sudo cat /etc/crontab
    sudo ls -la /etc/cron.d/
    sudo ls -la /etc/cron.daily/
    sudo ls -la /etc/cron.hourly/
    sudo ls -la /etc/cron.weekly/

    # At jobs:
    sudo atq
    ```

## Investigation Checklist

- [ ] Multiple failed sudo attempts followed by success?
- [ ] User attempting commands outside their job function?
- [ ] SUID/SGID files in unusual locations or on unusual binaries?
- [ ] /etc/sudoers or /etc/group recently modified?
- [ ] User added to privileged groups without authorization?
- [ ] Kernel modules loaded unexpectedly?
- [ ] Known exploit tools present (linpeas, linuxprivchecker, etc.)?
- [ ] Unusual root processes running?
- [ ] System files (in /bin, /sbin, /usr/bin) recently modified?
- [ ] User has legitimate need for attempted privilege escalation?
- [ ] Timing correlates with other suspicious activity?
- [ ] Same user attempting escalation on multiple systems?

## Containment Actions

### If Unauthorized Escalation Confirmed:

1. **Lock User Account Immediately**
   ```bash
   # Lock the account:
   sudo passwd -l <username>

   # Or disable entirely:
   sudo usermod -L <username>

   # Expire account:
   sudo usermod -e 1 <username>
   ```

2. **Kill Active User Sessions**
   ```bash
   # Find user's sessions:
   who | grep <username>
   w | grep <username>

   # Kill all user processes:
   sudo pkill -9 -u <username>

   # Or kill specific session:
   sudo pkill -9 -t pts/X
   ```

3. **Remove from Privileged Groups**
   ```bash
   # Remove from sudo group:
   sudo deluser <username> sudo

   # Remove from other privileged groups:
   sudo deluser <username> adm
   sudo deluser <username> wheel
   ```

4. **Remove Unauthorized SUID/SGID**
   ```bash
   # Remove SUID bit from suspicious file:
   sudo chmod u-s <file_path>

   # Remove SGID bit:
   sudo chmod g-s <file_path>

   # Or remove completely:
   sudo rm <suspicious_file>
   ```

5. **Revert /etc/sudoers Changes**
   ```bash
   # Edit sudoers safely:
   sudo visudo

   # Remove unauthorized entries
   # Check syntax before saving (visudo does this automatically)

   # Check sudoers.d:
   sudo ls /etc/sudoers.d/
   # Remove any unauthorized files:
   sudo rm /etc/sudoers.d/<unauthorized_file>
   ```

6. **Check for Backdoors/Persistence**
   ```bash
   # Check for SSH keys added:
   sudo cat /home/<username>/.ssh/authorized_keys
   sudo cat /root/.ssh/authorized_keys

   # Check for suspicious cron jobs:
   sudo crontab -l -u <username>
   sudo crontab -r -u <username>  # Remove all

   # Check systemd services:
   sudo systemctl list-unit-files --type=service --state=enabled | grep -v "^[a-z0-9-]*@"

   # Check for added users:
   sudo grep "$(date +%Y-%m-%d)" /var/log/auth.log | grep useradd
   ```

7. **Network Isolation** (if compromise suspected)
   ```bash
   # Block endpoint at pfSense
   # OR disable network on endpoint:
   sudo ip link set eth0 down
   ```

### If Authorized but Risky:

1. Document business justification
2. Implement Just-In-Time (JIT) sudo access
3. Use fine-grained sudoers rules (specific commands only)
4. Enable additional auditing for this user

## Evidence to Capture

1. **Auth Logs**
   ```bash
   # Copy auth log:
   sudo cp /var/log/auth.log ~/HAWKINS_OPS/incidents/YYYY-MM-DD_priv_esc/auth.log
   sudo cp /var/log/auth.log.1 ~/HAWKINS_OPS/incidents/YYYY-MM-DD_priv_esc/auth.log.1

   # Extract relevant sudo entries:
   sudo grep sudo /var/log/auth.log > ~/HAWKINS_OPS/incidents/YYYY-MM-DD_priv_esc/sudo_activity.log
   ```

2. **SUID/SGID File List**
   ```bash
   sudo find / -perm -4000 -type f -ls 2>/dev/null > ~/HAWKINS_OPS/incidents/YYYY-MM-DD_priv_esc/suid_files.txt
   sudo find / -perm -2000 -type f -ls 2>/dev/null > ~/HAWKINS_OPS/incidents/YYYY-MM-DD_priv_esc/sgid_files.txt
   ```

3. **System Configuration**
   ```bash
   # Copy sudoers:
   sudo cp /etc/sudoers ~/HAWKINS_OPS/incidents/YYYY-MM-DD_priv_esc/sudoers.backup
   sudo cp -r /etc/sudoers.d ~/HAWKINS_OPS/incidents/YYYY-MM-DD_priv_esc/

   # Copy group file:
   sudo cp /etc/group ~/HAWKINS_OPS/incidents/YYYY-MM-DD_priv_esc/group.backup
   sudo cp /etc/passwd ~/HAWKINS_OPS/incidents/YYYY-MM-DD_priv_esc/passwd.backup
   ```

4. **Process and File Listings**
   ```bash
   # Process snapshot:
   ps auxf > ~/HAWKINS_OPS/incidents/YYYY-MM-DD_priv_esc/processes.txt

   # Files with capabilities:
   sudo getcap -r / 2>/dev/null > ~/HAWKINS_OPS/incidents/YYYY-MM-DD_priv_esc/capabilities.txt

   # Loaded kernel modules:
   lsmod > ~/HAWKINS_OPS/incidents/YYYY-MM-DD_priv_esc/kernel_modules.txt
   ```

5. **Cron Jobs**
   ```bash
   # Export all cron jobs:
   sudo crontab -l > ~/HAWKINS_OPS/incidents/YYYY-MM-DD_priv_esc/root_crontab.txt
   crontab -l > ~/HAWKINS_OPS/incidents/YYYY-MM-DD_priv_esc/user_crontab.txt 2>/dev/null
   sudo cp /etc/crontab ~/HAWKINS_OPS/incidents/YYYY-MM-DD_priv_esc/
   ```

6. **Wazuh Alerts**
   - Export related Wazuh alerts (JSON format)
   - Include FIM alerts for /etc/sudoers, /etc/group

7. **Bash History**
   ```bash
   sudo cp /home/<username>/.bash_history ~/HAWKINS_OPS/incidents/YYYY-MM-DD_priv_esc/user_bash_history.txt
   sudo cp /root/.bash_history ~/HAWKINS_OPS/incidents/YYYY-MM-DD_priv_esc/root_bash_history.txt 2>/dev/null
   ```

8. **System Logs**
   ```bash
   sudo cp /var/log/syslog ~/HAWKINS_OPS/incidents/YYYY-MM-DD_priv_esc/
   sudo dmesg > ~/HAWKINS_OPS/incidents/YYYY-MM-DD_priv_esc/dmesg.txt
   ```

## Closure & Lessons Learned

### Ticket Closure Steps:
1. Verify unauthorized access has been revoked
2. Confirm no persistence mechanisms remain
3. Document attack vector (exploit, misconfiguration, social engineering)
4. Update Wazuh alert with findings
5. Archive evidence to incidents folder
6. Create change ticket if system hardening needed
7. Security awareness training for user (if applicable)

### Hardening Recommendations:

**Immediate:**
- **Patch system** - ensure kernel and all packages up to date:
  ```bash
  sudo apt update && sudo apt upgrade -y
  ```
- **Review and tighten /etc/sudoers**:
  - Remove NOPASSWD where not needed
  - Use specific command paths, not wildcards
  - Remove ALL=(ALL) ALL for non-admin users
  - Example good entry: `user ALL=(ALL) /usr/bin/systemctl restart myapp`
- **Enable sudo logging**:
  ```bash
  sudo visudo
  # Add: Defaults logfile="/var/log/sudo.log"
  # Add: Defaults log_input, log_output
  ```

**Long-term:**
- **Implement least privilege principle**:
  - Users should NOT have sudo access by default
  - Create role-based sudo configurations
  - Use sudoedit for file editing instead of sudo vim
- **Deploy SELinux or AppArmor**:
  ```bash
  # Check AppArmor status:
  sudo aa-status

  # Enable AppArmor profiles:
  sudo aa-enforce /etc/apparmor.d/*
  ```
- **File Integrity Monitoring** via Wazuh:
  - Monitor /etc/sudoers, /etc/group, /etc/passwd
  - Monitor SUID/SGID files
  - Alert on capability changes
- **Regular SUID/SGID audits**:
  ```bash
  # Create baseline:
  sudo find / -perm -4000 -o -perm -2000 -type f -ls 2>/dev/null > /root/suid_baseline.txt

  # Compare monthly
  ```
- **Kernel hardening**:
  - Enable kernel protections in /etc/sysctl.conf:
    ```
    kernel.dmesg_restrict = 1
    kernel.kptr_restrict = 2
    kernel.yama.ptrace_scope = 1
    ```
- **Deploy Auditd** for enhanced logging:
  ```bash
  sudo apt install auditd
  # Configure rules for privilege escalation monitoring
  ```
- **Remove unnecessary compilers** (gcc, make) from production systems
- **Disable core dumps** for security:
  ```bash
  echo "* hard core 0" | sudo tee -a /etc/security/limits.conf
  ```
- **Create Wazuh custom rules** for:
  - Multiple failed sudo attempts (threshold: 5 in 5 minutes)
  - Successful sudo after failed attempts
  - SUID file creation/modification
  - User added to sudo group
  - /etc/sudoers modification
- **Just-In-Time (JIT) privilege access**:
  - Temporary sudo access via ticketing system
  - Auto-revoke after time period
- **MFA for sudo** (Google Authenticator PAM module)

### Portfolio Notes:
- Demonstrates understanding of Linux privilege models
- Shows knowledge of privilege escalation techniques
- Highlights system hardening expertise
- Emphasizes least privilege principle
- Understanding of Linux security controls (SELinux, AppArmor, Auditd)
