#!/bin/bash
# HawkinsOps // Script Pack 2.0
# Purpose: Add logging + reporting automation

echo ">>> Installing HawkinsOps Script Pack 2.0..."

# Directories
mkdir -p ~/HAWKINS_OPS/Data/Logs
mkdir -p ~/HAWKINS_OPS/Data/Reports
mkdir -p ~/HAWKINS_OPS/Workspace/Active

# --- 1. loglab ---
cat <<'EOF' > ~/HAWKINS_OPS/System/Scripts/loglab
#!/bin/bash
# Create timestamped log entry
if [ -z "$1" ]; then
  echo "Usage: loglab <title> [optional text]"
  exit 1
fi
LOGDIR=~/HAWKINS_OPS/Data/Logs
FILE="$LOGDIR/$(date +'%Y-%m-%d_%H-%M-%S')_${1// /_}.log"
echo "[$(date)] $1" >> "$FILE"
[ -n "$2" ] && echo "$2" >> "$FILE"
echo ">>> Log saved to $FILE"
EOF

chmod +x ~/HAWKINS_OPS/System/Scripts/loglab

# --- 2. auto_report ---
cat <<'EOF' > ~/HAWKINS_OPS/System/Scripts/auto_report
#!/bin/bash
# Generate daily summary report
REPORTDIR=~/HAWKINS_OPS/Data/Reports
OUTFILE="$REPORTDIR/auto_report_$(date +'%Y-%m-%d').txt"

echo "===============================" > "$OUTFILE"
echo " HawkinsOps Auto Report" >> "$OUTFILE"
echo " Date: $(date)" >> "$OUTFILE"
echo "===============================" >> "$OUTFILE"

find ~/HAWKINS_OPS/Data/Logs -type f -mtime -1 -exec cat {} \; >> "$OUTFILE"

echo ">>> Report generated at $OUTFILE"
EOF

chmod +x ~/HAWKINS_OPS/System/Scripts/auto_report

# --- 3. opsnote ---
cat <<'EOF' > ~/HAWKINS_OPS/System/Scripts/opsnote
#!/bin/bash
# Quick personal note utility
if [ -z "$1" ]; then
  echo "Usage: opsnote <text>"
  exit 1
fi
NOTEFILE=~/HAWKINS_OPS/Data/Notes/daily_notes_$(date +'%Y-%m-%d').txt
mkdir -p ~/HAWKINS_OPS/Data/Notes
echo "[$(date +'%H:%M:%S')] $1" >> "$NOTEFILE"
echo "Note added to $NOTEFILE"
EOF

chmod +x ~/HAWKINS_OPS/System/Scripts/opsnote

echo ">>> Script Pack 2.0 installed successfully."
echo ">>> Try running: loglab 'Rebuild Complete' 'Script Pack 2.0 installed successfully.'"
