#Requires -Version 7.0

<#
.SYNOPSIS
    Validates project_config.json invariants for RH_MIGRATION_2026_V2

.DESCRIPTION
    Enforces critical invariants:
    1. allowlist_roots must be exactly ["INBOX", "OPS"] or ["OPS", "INBOX"] (order-insensitive)
    2. quarantine_root must be exactly "TEMPORARY"
    3. TEMPORARY must NOT appear in allowlist_roots
    4. Config file must exist and be valid JSON

.PARAMETER ConfigPath
    Path to project_config.json (defaults to project root)

.EXAMPLE
    .\tools\validate_config.ps1
    .\tools\validate_config.ps1 -ConfigPath "C:\custom\path\project_config.json"

.NOTES
    Exit codes:
    0 = Success (all invariants pass)
    1 = Validation failure (invariants violated)
    2 = Config file missing or invalid JSON
#>

[CmdletBinding()]
param(
    [string]$ConfigPath = "$PSScriptRoot\..\project_config.json"
)

$ErrorActionPreference = 'Stop'

function Write-FailMessage {
    param([string]$Message)
    Write-Host "❌ FAIL: $Message" -ForegroundColor Red
}

function Write-PassMessage {
    param([string]$Message)
    Write-Host "✅ PASS: $Message" -ForegroundColor Green
}

function Write-InfoMessage {
    param([string]$Message)
    Write-Host "ℹ️  $Message" -ForegroundColor Cyan
}

# Validation state
$validationFailed = $false

Write-InfoMessage "Validating config at: $ConfigPath"
Write-Host ""

# Check 1: Config file exists
if (-not (Test-Path -LiteralPath $ConfigPath)) {
    Write-FailMessage "Config file not found: $ConfigPath"
    exit 2
}
Write-PassMessage "Config file exists"

# Check 2: Valid JSON
try {
    $config = Get-Content -LiteralPath $ConfigPath -Raw -Encoding UTF8 | ConvertFrom-Json
    Write-PassMessage "Config is valid JSON"
} catch {
    Write-FailMessage "Config is not valid JSON: $_"
    exit 2
}

# Check 3: allowlist_roots exists and is an array
if (-not $config.PSObject.Properties.Name.Contains('allowlist_roots')) {
    Write-FailMessage "Config missing 'allowlist_roots' property"
    $validationFailed = $true
} elseif ($config.allowlist_roots -isnot [System.Array]) {
    Write-FailMessage "'allowlist_roots' is not an array"
    $validationFailed = $true
} else {
    Write-PassMessage "'allowlist_roots' exists and is an array"

    # Check 4: allowlist_roots contains exactly C:\RH\INBOX and C:\RH\OPS (order-insensitive)
    $allowlistSorted = $config.allowlist_roots | Sort-Object
    $expectedSorted = @('C:\RH\INBOX', 'C:\RH\OPS') | Sort-Object

    if ($allowlistSorted.Count -ne 2) {
        Write-FailMessage "'allowlist_roots' must contain exactly 2 entries, found: $($allowlistSorted.Count)"
        Write-InfoMessage "Current value: [$($config.allowlist_roots -join ', ')]"
        $validationFailed = $true
    } elseif (($allowlistSorted[0] -ne $expectedSorted[0]) -or ($allowlistSorted[1] -ne $expectedSorted[1])) {
        Write-FailMessage "'allowlist_roots' must be exactly ['C:\RH\INBOX', 'C:\RH\OPS'] (order-insensitive)"
        Write-InfoMessage "Expected: [$($expectedSorted -join ', ')]"
        Write-InfoMessage "Found:    [$($allowlistSorted -join ', ')]"
        $validationFailed = $true
    } else {
        Write-PassMessage "'allowlist_roots' = ['$($config.allowlist_roots[0])', '$($config.allowlist_roots[1])'] (correct)"
    }
}

# Check 5: quarantine_root exists and is "TEMPORARY"
if (-not $config.PSObject.Properties.Name.Contains('quarantine_root')) {
    Write-FailMessage "Config missing 'quarantine_root' property"
    $validationFailed = $true
} elseif ($config.quarantine_root -ne 'C:\RH\TEMPORARY') {
    Write-FailMessage "'quarantine_root' must be exactly 'C:\RH\TEMPORARY'"
    Write-InfoMessage "Found: '$($config.quarantine_root)'"
    $validationFailed = $true
} else {
    Write-PassMessage "'quarantine_root' = 'C:\RH\TEMPORARY' (correct)"
}

# Check 6: TEMPORARY must NOT appear in allowlist_roots
if (($config.allowlist_roots -contains 'TEMPORARY') -or ($config.allowlist_roots -contains 'C:\RH\TEMPORARY')) {
    Write-FailMessage "CRITICAL: 'TEMPORARY' or 'C:\RH\TEMPORARY' found in 'allowlist_roots' (quarantine must never be scanned)"
    Write-InfoMessage "Quarantine is a destination-only directory and must not appear in scan roots"
    $validationFailed = $true
} else {
    Write-PassMessage "C:\RH\TEMPORARY not in allowlist_roots (correct - quarantine never scanned)"
}

# Summary
Write-Host ""
Write-Host "═══════════════════════════════════════════════════" -ForegroundColor White

if ($validationFailed) {
    Write-Host "❌ VALIDATION FAILED" -ForegroundColor Red -BackgroundColor Black
    Write-Host "═══════════════════════════════════════════════════" -ForegroundColor White
    Write-Host ""
    Write-InfoMessage "Fix the issues above in project_config.json and re-run this script."
    exit 1
} else {
    Write-Host "✅ ALL CHECKS PASSED" -ForegroundColor Green -BackgroundColor Black
    Write-Host "═══════════════════════════════════════════════════" -ForegroundColor White
    Write-Host ""
    Write-InfoMessage "Configuration is valid. Safe to proceed."
    exit 0
}
