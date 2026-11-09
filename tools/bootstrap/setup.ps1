param([string]$FlutterRoot)
. (Join-Path $PSScriptRoot '../common.ps1')
$flutter = Find-Flutter $FlutterRoot
$versionText = & $flutter --version --machine
if ($LASTEXITCODE -ne 0) { throw 'Could not query Flutter version.' }
$version = $versionText | ConvertFrom-Json
$expected = (Get-Content (Join-Path $ProjectRoot '.flutter-version') -Raw).Trim()
if ($version.frameworkVersion -ne $expected) { throw "Expected Flutter $expected; got $($version.frameworkVersion). Select the pinned SDK." }
$selectedRoot = Split-Path -Parent (Split-Path -Parent $flutter)
$localDirectory = Join-Path $ProjectRoot '.local'
New-Item -ItemType Directory -Path $localDirectory -Force | Out-Null
@{ flutterRoot = $selectedRoot } | ConvertTo-Json | Set-Content (Join-Path $localDirectory 'toolchain.json') -Encoding utf8
Push-Location (Join-Path $ProjectRoot 'src/packages/earnings_core')
try {
    $dart = Join-Path $selectedRoot $(if ($IsWindows) { 'bin/dart.bat' } else { 'bin/dart' })
    Invoke-Checked $dart @('pub', 'get')
} finally { Pop-Location }
Push-Location (Join-Path $ProjectRoot 'src/apps/pay_by_second')
try { Invoke-Checked $flutter @('pub', 'get') } finally { Pop-Location }
Write-Output "Ready: Flutter $expected. No global PATH changes."
