BeforeAll {
    $RepoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..")).Path
}

Describe "Security stack scaffold" {
    It "has scanner config files" {
        Test-Path -LiteralPath (Join-Path $RepoRoot ".gitleaks.toml") | Should -BeTrue
        Test-Path -LiteralPath (Join-Path $RepoRoot "trivy.yaml") | Should -BeTrue
    }

    It "has required workflow files" {
        $required = @(
            ".github\workflows\gitleaks.yml",
            ".github\workflows\trivy.yml",
            ".github\workflows\codeql.yml",
            ".github\workflows\scorecard.yml",
            ".github\workflows\security-parity.yml"
        )

        foreach ($path in $required) {
            Test-Path -LiteralPath (Join-Path $RepoRoot $path) | Should -BeTrue
        }
    }

    It "has local CI runner script" {
        Test-Path -LiteralPath (Join-Path $RepoRoot "scripts\ci.ps1") | Should -BeTrue
    }
}
