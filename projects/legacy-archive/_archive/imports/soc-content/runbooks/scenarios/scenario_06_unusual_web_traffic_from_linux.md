# Scenario 06: Unusual Web Traffic from Linux Endpoint

## Environment Context
- **Primary Detection**: pfSense firewall logs, Wazuh SIEM
- **Affected System**: PRIMARY_OS or MINT-3 (Linux endpoints)
- **HawkinsOps Components Involved**:
  - Linux endpoint
  - pfSense (traffic monitoring/filtering)
  - Wazuh server (correlation/alerting)
  - Network infrastructure

## Detection

### Detection Sources

**pfSense Indicators:**
- High volume HTTP/HTTPS requests to single domain
- Connections to suspicious/unknown domains
- Traffic to unusual destination ports (8080, 8443, non-standard)
- Large data transfers (potential exfiltration)
- Traffic to known malicious IPs (blocklist matches)

**Wazuh Alerts:**
- **Rule ID**: Custom web access anomaly rules
- **Rule ID**: 31101+ (Web server attack rules, if applicable)
- **File Integrity Monitoring**: Modified web browsing configs
- Correlation of multiple suspicious web requests

**Linux System Logs:**
- Unusual process making web requests
- Non-browser applications with HTTP/HTTPS traffic
- Automated scripts hitting web endpoints

**Behavioral Indicators:**
- Web traffic during non-business hours
- Automated/scripted request patterns
- User-agent strings indicating bots or scripts
- Traffic volume inconsistent with normal usage

## Triage Steps

1. **Review Initial Alert/Detection**
   - Note: source IP (endpoint), destination IP/domain, traffic volume
   - Timestamp and duration of activity
   - Protocol details (HTTP, HTTPS, port numbers)

2. **Analyze pfSense Firewall Logs**
   ```
   Navigate to: Status → System Logs → Firewall
   - Filter by source IP (Linux endpoint)
   - Look for:
     * Repeated connections to same destination
     * Large transfer sizes
     * Unusual destination ports
     * Blocked attempts (if firewall rules triggered)

   Export relevant log entries
   ```

3. **Identify Traffic Characteristics**
   ```bash
   # On pfSense or PRIMARY_OS with access to network captures:
   # Capture live traffic from suspected endpoint:
   sudo tcpdump -i eth0 -n host <endpoint_IP> and port 80 or port 443 -w /tmp/web_traffic.pcap

   # Let run for 2-5 minutes to capture pattern
   ```

4. **Analyze Destination**
   ```bash
   # On PRIMARY_OS:
   # WHOIS lookup:
   whois <destination_domain>

   # DNS resolution:
   dig <destination_domain>
   host <destination_domain>

   # Check domain reputation:
   # VirusTotal, URLVoid, Cisco Talos Intelligence

   # Check IP reputation:
   whois <destination_IP>
   # AbuseIPDB, GreyNoise, AlienVault OTX
   ```

5. **Investigate on Linux Endpoint**

   ```bash
   # Check active network connections:
   sudo lsof -i -n -P | grep -E ':80|:443|:8080|:8443'

   # With process details:
   sudo ss -tnp | grep -E ':80|:443|:8080'

   # Identify which process is making requests:
   sudo netstat -antp | grep ESTABLISHED | grep -E ':80|:443'
   ```

6. **Review Process Making Requests**
   ```bash
   # Get full process details:
   ps aux | grep <PID>

   # Check process command line:
   cat /proc/<PID>/cmdline | tr '\0' ' '

   # Check what user owns the process:
   ls -l /proc/<PID>

   # Check process binary location and signature:
   ls -la /proc/<PID>/exe
   file /proc/<PID>/exe
   ```

7. **Check for Scripts or Automation**
   ```bash
   # Look for curl/wget usage in recent commands:
   cat ~/.bash_history | grep -E 'curl|wget|python|nc'

   # Check cron jobs:
   crontab -l
   sudo cat /etc/crontab
   sudo ls -la /etc/cron.*

   # Check for running Python/script processes:
   ps aux | grep -E 'python|perl|ruby|bash|sh'

   # Check recent file modifications (potential malicious scripts):
   sudo find /home /tmp /var/tmp -type f -name "*.sh" -o -name "*.py" -mtime -1
   ```

8. **Analyze Web Traffic Content** (if HTTPS, limited without MITM)
   ```bash
   # For HTTP traffic (unencrypted):
   # Analyze pcap with tshark:
   tshark -r /tmp/web_traffic.pcap -Y http.request -T fields -e http.host -e http.request.uri | sort | uniq -c

   # Extract HTTP user-agents:
   tshark -r /tmp/web_traffic.pcap -Y http.request -T fields -e http.user_agent | sort | uniq

   # For HTTPS, check SNI (Server Name Indication):
   tshark -r /tmp/web_traffic.pcap -Y ssl.handshake.extensions_server_name -T fields -e ssl.handshake.extensions_server_name | sort | uniq -c
   ```

9. **Check Browser History** (if browser-based)
   ```bash
   # Firefox:
   ls -la ~/.mozilla/firefox/*.default*/places.sqlite

   # Chrome/Chromium:
   ls -la ~/.config/google-chrome/Default/History
   ls -la ~/.config/chromium/Default/History

   # View history with sqlite3:
   sqlite3 ~/.mozilla/firefox/*.default*/places.sqlite "SELECT datetime(visit_date/1000000,'unixepoch'), url FROM moz_places, moz_historyvisits WHERE moz_places.id=moz_historyvisits.place_id ORDER BY visit_date DESC LIMIT 100;"
   ```

## Investigation Checklist

- [ ] Traffic volume consistent with manual browsing or automated?
- [ ] Destination domain/IP has legitimate business purpose?
- [ ] Domain recently registered or suspicious reputation?
- [ ] Process making requests is legitimate application?
- [ ] User acknowledges and authorizes this activity?
- [ ] Traffic occurs during expected user activity hours?
- [ ] User-agent string matches expected browser/tool?
- [ ] Similar traffic from other endpoints (botnet/coordinated attack)?
- [ ] Data being uploaded (POST requests, large outbound transfers)?
- [ ] C2 beacon pattern (regular intervals, small requests)?
- [ ] Malware communication or legitimate software update?

## Containment Actions

### If Malicious Activity Confirmed:

1. **Isolate Endpoint**
   ```bash
   # Disable network interface:
   sudo ip link set eth0 down

   # Or block specific destination:
   sudo iptables -A OUTPUT -d <malicious_IP> -j DROP
   sudo iptables -A OUTPUT -d <malicious_domain> -j DROP
   ```

2. **Block at pfSense** (preferred - network-wide protection)
   ```
   Firewall → Aliases → Add malicious IP/domain
   Firewall → Rules → LAN → Add block rule
   ```

3. **Kill Suspicious Process**
   ```bash
   # Gracefully:
   sudo kill <PID>

   # Force kill if needed:
   sudo kill -9 <PID>
   ```

4. **Remove Malicious Script/Binary**
   ```bash
   # Move to quarantine:
   sudo mkdir -p /quarantine
   sudo mv <suspicious_file> /quarantine/
   sudo chmod 000 /quarantine/*
   ```

5. **Disable Cron Job** (if automated)
   ```bash
   # Edit and comment out:
   crontab -e

   # Or remove entirely:
   crontab -r
   ```

6. **Check for Additional Compromise**
   - Follow Scenario 05 (Malware) checklist
   - Check for persistence mechanisms
   - Review other suspicious processes

### If Legitimate but Risky:

1. **Document business justification**
2. **Configure proper controls**:
   - Restrict to specific times (cron scheduling)
   - Use authenticated/encrypted connections
   - Implement rate limiting
3. **Create Wazuh exception** if recurring
4. **User training** on secure practices

## Evidence to Capture

1. **pfSense Logs**
   ```
   Status → System Logs → Firewall
   Export filtered logs for relevant timeframe
   Save to: ~/HAWKINS_OPS/incidents/YYYY-MM-DD_unusual_web_traffic/pfsense_firewall.log
   ```

2. **Packet Capture**
   ```bash
   # Copy pcap from capture location:
   cp /tmp/web_traffic.pcap ~/HAWKINS_OPS/incidents/YYYY-MM-DD_unusual_web_traffic/
   ```

3. **Process Information**
   ```bash
   # Process details:
   ps aux > ~/HAWKINS_OPS/incidents/YYYY-MM-DD_unusual_web_traffic/processes.txt

   # Network connections:
   sudo netstat -antp > ~/HAWKINS_OPS/incidents/YYYY-MM-DD_unusual_web_traffic/network_connections.txt

   # Process tree:
   pstree -p > ~/HAWKINS_OPS/incidents/YYYY-MM-DD_unusual_web_traffic/process_tree.txt
   ```

4. **Suspicious Scripts/Binaries**
   ```bash
   # Copy to evidence folder:
   sudo cp <suspicious_file> ~/HAWKINS_OPS/incidents/YYYY-MM-DD_unusual_web_traffic/

   # Calculate hash:
   sha256sum <suspicious_file> > ~/HAWKINS_OPS/incidents/YYYY-MM-DD_unusual_web_traffic/file_hashes.txt
   ```

5. **Bash History**
   ```bash
   cp ~/.bash_history ~/HAWKINS_OPS/incidents/YYYY-MM-DD_unusual_web_traffic/bash_history.txt
   ```

6. **Cron Jobs**
   ```bash
   crontab -l > ~/HAWKINS_OPS/incidents/YYYY-MM-DD_unusual_web_traffic/user_crontab.txt
   sudo cat /etc/crontab > ~/HAWKINS_OPS/incidents/YYYY-MM-DD_unusual_web_traffic/system_crontab.txt
   ```

7. **Wazuh Alerts**
   - Export full alert JSON
   - Include correlation data

8. **Domain/IP Intelligence**
   ```bash
   # Save WHOIS:
   whois <domain> > ~/HAWKINS_OPS/incidents/YYYY-MM-DD_unusual_web_traffic/domain_whois.txt

   # Save DNS records:
   dig <domain> ANY > ~/HAWKINS_OPS/incidents/YYYY-MM-DD_unusual_web_traffic/domain_dns.txt
   ```

9. **Screenshots**
   - pfSense log view
   - Wireshark packet analysis
   - Threat intelligence lookups

## Closure & Lessons Learned

### Ticket Closure Steps:
1. Verify malicious traffic has stopped
2. Confirm destination blocked at firewall if malicious
3. Document root cause (malware, misconfiguration, user action)
4. Update Wazuh alert with resolution
5. Archive evidence to incidents folder
6. Update IOC database with malicious indicators

### Hardening Recommendations:
- **Deploy web filtering at pfSense** (pfBlockerNG with DNSBL)
- **Implement egress filtering**: Only allow necessary outbound protocols
- **Configure application-level firewall** (AppArmor, SELinux profiles)
- **Restrict curl/wget usage** via sudoers or remove for standard users
- **Monitor script execution**:
  ```bash
  # Audit script execution in Wazuh:
  # Create FIM rule for /tmp, /var/tmp
  # Create custom rule for shell script execution
  ```
- **Implement proxy with authentication** for all web traffic
- **Create Wazuh custom rules** for:
  - High-volume HTTP/HTTPS from single host
  - Web requests from non-browser processes
  - Connections to newly registered domains
- **Regular review of cron jobs and scheduled tasks**
- **User training** on safe software installation and script usage
- **Deploy IDS/IPS** (Suricata on pfSense) with web attack signatures
- **Certificate pinning** for critical applications
- **Network segmentation** - separate user endpoints from servers
- **Baseline normal web traffic** per endpoint type for anomaly detection

### Portfolio Notes:
- Demonstrates network traffic analysis skills
- Shows understanding of application-layer protocols
- Highlights packet capture and analysis proficiency
- Emphasizes defense-in-depth (endpoint + network + SIEM)
- Understanding of Linux process investigation
