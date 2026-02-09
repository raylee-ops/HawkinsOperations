# ==========================
# HAWKINS OPS :: AUTOSYNC
# ==========================
$src = "C:\HAWKINS_OPS"
$dst = "D:\Backups\HAWKINS_OPS"   # change D: if your backup drive has another letter
$log = "C:\HAWKINS_OPS\data\logs\mirror_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

# Mirror directory structure and files
robocopy $src $dst /MIR /R:1 /W:1 /NFL /NDL /NP /LOG:$log

# Push updates to GitHub
Set-Location $src
git add .
git commit -m "Auto-sync: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
git push origin main
