# HawkinsOps 365-Day SOC Learning System

**Target:** SOC Analyst Level 1 - Huntsville, AL
**Job-Ready Deadline:** Day 180 (May 1, 2026)
**Total Duration:** 365 Days

---

## Quick Start

1. **Read the Master Roadmap:**
   ```bash
   cat roadmap/00-Master-Roadmap.md
   ```

2. **Review Your Current Phase:**
   - Phase 1 (Days 1-90): `roadmap/Phase-1-Foundation.md`
   - Phase 2 (Days 91-180): `roadmap/Phase-2-Intermediate.md`
   - Phase 3 (Days 181-270): `roadmap/Phase-3-Advanced.md`
   - Phase 4 (Days 271-365): `roadmap/Phase-4-Job-Prep.md`

3. **Start Day 1:**
   ```bash
   cat roadmap/daily-breakdown/day-001.md
   ```

4. **Execute Daily:**
   - Read the day's learning objectives
   - Complete the lab of the day
   - Execute hands-on commands
   - Document your work
   - Reflect and prepare for tomorrow

---

## Directory Structure

```
learning-system/
├── README.md                          # This file
├── roadmap/
│   ├── 00-Master-Roadmap.md           # Complete 365-day overview
│   ├── Phase-1-Foundation.md          # Days 1-90
│   ├── Phase-2-Intermediate.md        # Days 91-180 (JOB-READY)
│   ├── Phase-3-Advanced.md            # Days 181-270
│   ├── Phase-4-Job-Prep.md            # Days 271-365
│   └── daily-breakdown/
│       ├── day-001.md                 # Daily guides
│       ├── day-002.md
│       └── ...
│       └── day-365.md
└── generate_daily_files.py            # Generator script (reference only)
```

---

## How to Use This System

### Daily Routine

**Time Required:** 2-4 hours/day (minimum 2 hours)

1. **Morning (15 min):**
   - Read today's markdown file
   - Review learning objectives
   - Set up your HawkinsOps environment

2. **Hands-On (90-180 min):**
   - Complete the lab of the day
   - Execute all commands (Windows, Linux, Wazuh)
   - Experiment and explore
   - Take screenshots for portfolio

3. **Documentation (30-60 min):**
   - Answer documentation prompts
   - Update GitHub portfolio
   - Write summary in learning journal
   - Add detection rules/scripts if created

4. **Reflection (15 min):**
   - Review what you learned
   - Identify gaps or challenges
   - Plan for tomorrow

---

## Phase Breakdown

### Phase 1: Foundation (Days 1-90)
**Goal:** Build core SOC fundamentals

**Key Skills:**
- Windows & Linux logging
- SIEM basics (Wazuh)
- Network fundamentals
- Sysmon mastery
- Basic detection rules
- MITRE ATT&CK introduction

**Job Readiness:** 25%

---

### Phase 2: Intermediate (Days 91-180)
**Goal:** Achieve job-interview readiness

**Key Skills:**
- Threat hunting
- Detection engineering
- Incident response
- Advanced SIEM
- Malware analysis basics
- Interview preparation

**Job Readiness:** 100% ✅ (MAY 1, 2026 TARGET)

---

### Phase 3: Advanced (Days 181-270)
**Goal:** Deepen expertise and specialization

**Key Skills:**
- Digital forensics (DFIR)
- Advanced malware analysis
- Purple team operations
- SOC automation
- Threat intelligence
- Cloud security basics

**Job Readiness:** 150%+ (Competitive Advantage)

---

### Phase 4: Job Prep & Mastery (Days 271-365)
**Goal:** Perfect portfolio and ace interviews

**Key Skills:**
- Interview mastery
- Portfolio polish
- Technical blogging
- Community networking
- Teaching/mentoring
- Staying current

**Job Readiness:** Expert L1, Ready for L2

---

## Lab Integration

All 50 HawkinsOps SOC labs are referenced throughout the 365 days:

- **LAB-01 to LAB-21:** Foundation (Phase 1)
- **LAB-22 to LAB-43:** Intermediate (Phase 2)
- **LAB-44 to LAB-50:** Advanced (Phase 3)
- **Capstone Projects:** Phase 4

Labs are referenced by ID (e.g., LAB-07) to avoid fragile filename dependencies.

---

## Portfolio Development

By Day 180, you will have:
- ✅ 35+ documented lab investigations
- ✅ 10+ detection rules (Sigma/Wazuh)
- ✅ 5+ automation scripts (Python)
- ✅ 3+ incident response writeups
- ✅ GitHub portfolio with professional README
- ✅ Resume tailored for Huntsville market

By Day 365, you will have:
- ✅ 50+ labs completed
- ✅ 25+ detection rules
- ✅ 15+ automation tools
- ✅ 10+ incident investigations
- ✅ Capstone project
- ✅ Technical blog presence

---

## ADHD-Optimized Design

This system is designed for ADHD success:

- **Daily variety:** Mix of Windows, Linux, network, SIEM
- **Clear objectives:** 3-5 specific goals each day
- **Immediate feedback:** Hands-on commands with visible results
- **Pomodoro-friendly:** 25-minute focus blocks work well
- **Momentum-focused:** If stuck, move to next day (revisit later)
- **Celebration built-in:** Track progress percentage daily

---

## Navigation Tips

### Find Today's Day

```bash
# If today is your 15th day in the program:
cat roadmap/daily-breakdown/day-015.md
```

### Jump to Next Phase

```bash
# Completed Phase 1? Read Phase 2 overview:
cat roadmap/Phase-2-Intermediate.md
```

### Search for Specific Topics

```bash
# Find all days covering Sysmon:
grep -r "Sysmon" roadmap/daily-breakdown/

# Find all days with Wazuh labs:
grep -r "Wazuh" roadmap/daily-breakdown/
```

### List All Labs

```bash
# See which labs are assigned each day:
grep -h "LAB-" roadmap/daily-breakdown/*.md | sort -u
```

---

## Customization & Flexibility

### Falling Behind?

- **Don't panic.** Life happens.
- Skip to the next day to maintain momentum
- Revisit missed days during Phase 4
- Focus on Phase 1 & 2 completion (job-readiness)

### Ahead of Schedule?

- Tackle advanced labs early
- Build extra portfolio projects
- Start job applications before Day 180
- Contribute to open-source SOC tools

### Need to Adjust?

- Extend Phase 2 if needed for job-readiness
- Compress Phase 3 & 4 if employment secured
- Repeat challenging weeks as needed

---

## Success Metrics

### Weekly Check-In
- [ ] Completed 7/7 daily activities
- [ ] Portfolio updated
- [ ] 3+ new techniques learned

### Monthly Check-In
- [ ] All monthly labs completed
- [ ] Phase deliverables on track
- [ ] Skills gap identified

### Phase Completion
- [ ] All phase objectives met
- [ ] Portfolio entries added
- [ ] Self-assessment shows competency

---

## Support & Resources

### HawkinsOps Environment
- **MINT-3:** Primary workstation (Linux Mint)
- **Windows 11:** Event log analysis, Sysmon
- **Wazuh:** SIEM platform
- **pfSense:** Network monitoring
- **Proxmox:** Lab orchestration

### External Resources
- [MITRE ATT&CK](https://attack.mitre.org/)
- [Wazuh Docs](https://documentation.wazuh.com/)
- [Sysmon Docs](https://docs.microsoft.com/en-us/sysinternals/downloads/sysmon)
- [Sigma Rules](https://github.com/SigmaHQ/sigma)

### Community
- Reddit: r/cybersecurity, r/BlueTeamSec
- Discord: Security communities
- Huntsville: DefSec, ISSA chapters
- LinkedIn: Connect with SOC professionals

---

## Critical Milestones

**Day 30:** Foundation solid - comfortable with log analysis
**Day 60:** Sysmon and basic detection proficiency
**Day 90:** Phase 1 complete - ready for advanced work

**Day 120:** Threat hunting and ATT&CK fluency
**Day 150:** Incident response and detection engineering
**Day 180:** 🎯 **JOB-READY** - Can interview confidently

**Day 210:** Forensics and advanced investigations
**Day 270:** Phase 3 complete - exceptional skills

**Day 300:** Interview mastery
**Day 365:** 🎓 **COMPLETE** - SOC expert ready to excel

---

## Troubleshooting

### Can't access a lab?
- Check ~/HAWKINS_OPS/runbooks/ for lab files
- Ensure HawkinsOps environment is running
- Substitute similar scenarios if needed

### Command doesn't work?
- Verify you're on correct OS (Windows vs Linux)
- Check permissions (sudo required for many Linux commands)
- Adapt to your specific environment paths

### Feeling overwhelmed?
- Take a break (sustainability > speed)
- Focus on one objective at a time
- Skip theory, do hands-on first
- Ask for help in communities

---

## Final Notes

**This is YOUR journey.**

- Customize as needed
- Celebrate small wins
- Don't compare to others
- Document everything
- Stay consistent

**By Day 180, you WILL be job-ready.**

**By Day 365, you WILL be exceptional.**

---

## Let's Begin

```bash
# Start your journey:
cat roadmap/daily-breakdown/day-001.md
```

**Good luck, future SOC Analyst. You've got this.**

---

*Created for Raylee's HawkinsOps SOC build - Let's get that Huntsville job!*
