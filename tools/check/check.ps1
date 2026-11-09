param([string]$FlutterRoot)
. (Join-Path $PSScriptRoot '../common.ps1')
& (Join-Path $ProjectRoot 'tools/build/update-config.ps1')
& (Join-Path $ProjectRoot 'tools/check/docs.ps1')
$flutter = Find-Flutter $FlutterRoot
$sdkRoot = Split-Path -Parent (Split-Path -Parent $flutter)
$dart = Join-Path $sdkRoot $(if ($IsWindows) { 'bin/dart.bat' } else { 'bin/dart' })
Push-Location $ProjectRoot
try {
    Push-Location 'src/apps/pay_by_second'
    try { Invoke-Checked $flutter @('gen-l10n') } finally { Pop-Location }
    & (Join-Path $PSScriptRoot 'font-coverage.ps1')
    Invoke-Checked $dart @('format', '--output=none', '--set-exit-if-changed', 'src')
    Push-Location 'src/packages/earnings_core'
    try {
        Invoke-Checked $dart @('analyze', '--fatal-infos')
        Invoke-Checked $dart @('test')
    } finally { Pop-Location }
    Push-Location 'src/apps/pay_by_second'
    try {
        Invoke-Checked $flutter @('analyze', '--fatal-infos')
        Invoke-Checked $flutter @('test')
    } finally { Pop-Location }
    Invoke-Checked 'git' @('diff', '--check')
} finally { Pop-Location }
