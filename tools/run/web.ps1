param([string]$FlutterRoot, [int]$Port = 7357)
. (Join-Path $PSScriptRoot '../common.ps1')
& (Join-Path $ProjectRoot 'tools/build/update-config.ps1')
$flutter = Find-Flutter $FlutterRoot
Push-Location (Join-Path $ProjectRoot 'src/apps/pay_by_second')
try { Invoke-Checked $flutter @('run', '-d', 'web-server', '--web-hostname', '127.0.0.1', '--web-port', "$Port") } finally { Pop-Location }
