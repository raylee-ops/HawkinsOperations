[CmdletBinding()]
param(
    [switch]$InstallMissingTools
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..")).Path
$outputDir = Join-Path $repoRoot "OUTPUTS"
$testsPath = Join-Path $repoRoot "tests"
$gitleaksConfigPath = Join-Path $repoRoot ".gitleaks.toml"
$trivyConfigPath = Join-Path $repoRoot "trivy.yaml"

$scanSummaryPath = Join-Path $outputDir "scan_summary.md"
$trivyReportPath = Join-Path $outputDir "trivy.txt"
$gitleaksReportPath = Join-Path $outputDir "gitleaks.json"
$pesterReportPath = Join-Path $outputDir "pester.xml"
$screenshotsChecklistPath = Join-Path $outputDir "screenshots_checklist.md"

$toolVersions = [ordered]@{
    Gitleaks = "8.24.2"
    Trivy    = "0.56.2"
    Pester   = "5.6.1"
}

$status = [ordered]@{
    Gitleaks  = "NOT_RUN"
    Trivy     = "NOT_RUN"
    Pester    = "NOT_RUN"
    CodeQL    = "CI_ONLY"
    Scorecard = "CI_ONLY"
}

$overallFail = $false

function Write-Step {
    param([string]$Message)
    Write-Host "[ci] $Message"
}

function Test-Tool {
    param([string]$Name)
    return $null -ne (Get-Command -Name $Name -ErrorAction SilentlyContinue)
}

function Ensure-Pester {
    param(
        [string]$RequiredVersion,
        [switch]$AutoInstall
    )

    $required = [version]$RequiredVersion
    $installed = Get-Module -ListAvailable -Name Pester | Where-Object { $_.Version -eq $required } | Select-Object -First 1

    if (-not $installed) {
        if (-not $AutoInstall) {
            throw "Pester v$RequiredVersion is required. Re-run with -InstallMissingTools."
        }

        Write-Step "Installing Pester v$RequiredVersion (CurrentUser)"
        Install-Module -Name Pester -RequiredVersion $RequiredVersion -Scope CurrentUser -Force -SkipPublisherCheck -AllowClobber
    }

    Import-Module -Name Pester -RequiredVersion $RequiredVersion -Force
}

New-Item -ItemType Directory -Path $outputDir -Force | Out-Null

foreach ($p in @($scanSummaryPath, $trivyReportPath, $gitleaksReportPath, $pesterReportPath, $screenshotsChecklistPath)) {
    if (Test-Path -LiteralPath $p) {
        Remove-Item -LiteralPath $p -Force
    }
}

if (-not (Test-Path -LiteralPath $gitleaksConfigPath)) {
    throw "Missing required file: $gitleaksConfigPath"
}

if (-not (Test-Path -LiteralPath $trivyConfigPath)) {
    throw "Missing required file: $trivyConfigPath"
}

Write-Step "Repository root: $repoRoot"

Write-Step "Running gitleaks"
if (Test-Tool -Name "gitleaks") {
    Push-Location -Path $repoRoot
    try {
        & gitleaks detect --no-banner --redact --source $repoRoot --config $gitleaksConfigPath --report-format json --report-path $gitleaksReportPath --exit-code 1
        $gitleaksExit = $LASTEXITCODE
    }
    finally {
        Pop-Location
    }

    if ($gitleaksExit -eq 0) {
        $status.Gitleaks = "PASS"
    }
    else {
        $status.Gitleaks = "FAIL"
        $overallFail = $true
    }
}
else {
    Set-Content -LiteralPath $gitleaksReportPath -Value "[]" -Encoding utf8
    $status.Gitleaks = "ERROR_MISSING_TOOL"
    $overallFail = $true
}

Write-Step "Running trivy"
if (Test-Tool -Name "trivy") {
    Push-Location -Path $repoRoot
    try {
        & trivy fs $repoRoot --config $trivyConfigPath --output $trivyReportPath --exit-code 1
        $trivyExit = $LASTEXITCODE
    }
    finally {
        Pop-Location
    }

    if ($trivyExit -eq 0) {
        $status.Trivy = "PASS"
    }
    else {
        $status.Trivy = "FAIL"
        $overallFail = $true
    }
}
else {
    Set-Content -LiteralPath $trivyReportPath -Value "trivy is not installed. Install v$($toolVersions.Trivy)." -Encoding utf8
    $status.Trivy = "ERROR_MISSING_TOOL"
    $overallFail = $true
}

Write-Step "Running pester"
try {
    Ensure-Pester -RequiredVersion $toolVersions.Pester -AutoInstall:$InstallMissingTools

    if (-not (Test-Path -LiteralPath $testsPath)) {
        New-Item -ItemType Directory -Path $testsPath -Force | Out-Null
    }

    $cfg = New-PesterConfiguration
    $cfg.Run.Path = @($testsPath)
    $cfg.Run.PassThru = $true
    $cfg.Output.Verbosity = "Detailed"
    $cfg.TestResult.Enabled = $true
    $cfg.TestResult.OutputFormat = "NUnitXml"
    $cfg.TestResult.OutputPath = $pesterReportPath

    $pesterResult = Invoke-Pester -Configuration $cfg
    if ($pesterResult.FailedCount -gt 0) {
        $status.Pester = "FAIL"
        $overallFail = $true
    }
    else {
        $status.Pester = "PASS"
    }
}
catch {
    Set-Content -LiteralPath $pesterReportPath -Value "<testsuites></testsuites>" -Encoding utf8
    $status.Pester = "ERROR"
    $overallFail = $true
}

$gitleaksFindings = 0
try {
    $payload = Get-Content -LiteralPath $gitleaksReportPath -Raw | ConvertFrom-Json
    if ($null -eq $payload) {
        $gitleaksFindings = 0
    }
    elseif ($payload -is [array]) {
        $gitleaksFindings = $payload.Count
    }
    else {
        $gitleaksFindings = 1
    }
}
catch {
    $gitleaksFindings = -1
}

$trivyHighCriticalHits = 0
if (Test-Path -LiteralPath $trivyReportPath) {
    $trivyHighCriticalHits = @(Select-String -LiteralPath $trivyReportPath -Pattern "\bHIGH\b|\bCRITICAL\b").Count
}

$runTime = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss zzz")
$summary = @(
    "# Scan Summary"
    ""
    "- Run time: $runTime"
    "- Repository: $repoRoot"
    ""
    "## Pinned Versions"
    "- gitleaks: $($toolVersions["Gitleaks"])"
    "- trivy: $($toolVersions["Trivy"])"
    "- pester: $($toolVersions["Pester"])"
    ""
    "## Status"
    "| Check | Status |"
    "| --- | --- |"
    "| Gitleaks | $($status["Gitleaks"]) |"
    "| Trivy | $($status["Trivy"]) |"
    "| Pester | $($status["Pester"]) |"
    "| CodeQL | $($status["CodeQL"]) |"
    "| Scorecard | $($status["Scorecard"]) |"
    ""
    "## Findings Snapshot"
    "- Gitleaks findings: $gitleaksFindings"
    "- Trivy HIGH/CRITICAL line hits: $trivyHighCriticalHits"
    ""
    "## Evidence Files"
    "- OUTPUTS\scan_summary.md"
    "- OUTPUTS\trivy.txt"
    "- OUTPUTS\gitleaks.json"
    "- OUTPUTS\pester.xml"
    "- OUTPUTS\screenshots_checklist.md"
) -join "`n"
Set-Content -LiteralPath $scanSummaryPath -Value $summary -Encoding utf8

$checklist = @(
    "# Recruiter Proof Screenshots Checklist"
    ""
    "- [ ] Checks page with all required checks green"
    "- [ ] security-local-parity workflow run summary"
    "- [ ] Evidence artifact contents (OUTPUTS/*)"
    "- [ ] Code scanning alerts page (CodeQL + Scorecard)"
    "- [ ] Workflow file view with SHA-pinned actions"
) -join "`n"
Set-Content -LiteralPath $screenshotsChecklistPath -Value $checklist -Encoding utf8

Write-Step "Wrote $scanSummaryPath"
Write-Step "Wrote $trivyReportPath"
Write-Step "Wrote $gitleaksReportPath"
Write-Step "Wrote $pesterReportPath"
Write-Step "Wrote $screenshotsChecklistPath"

if ($overallFail) {
    Write-Step "Completed with failures."
    exit 1
}

Write-Step "Completed successfully."
exit 0
