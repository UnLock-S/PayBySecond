$ErrorActionPreference = 'Stop'
$script:ProjectRoot = Split-Path -Parent $PSScriptRoot

function Find-Flutter {
    param([string]$FlutterRoot)
    if (-not $FlutterRoot) { $FlutterRoot = $env:PBS_FLUTTER_ROOT }
    $localConfig = Join-Path $script:ProjectRoot '.local/toolchain.json'
    if (-not $FlutterRoot -and (Test-Path -LiteralPath $localConfig)) {
        $FlutterRoot = (Get-Content -LiteralPath $localConfig -Raw | ConvertFrom-Json).flutterRoot
    }
    if ($FlutterRoot) {
        $executable = if ($IsWindows) { 'bin/flutter.bat' } else { 'bin/flutter' }
        $candidate = Join-Path $FlutterRoot $executable
        if (Test-Path -LiteralPath $candidate) { return (Resolve-Path -LiteralPath $candidate).Path }
        throw "Flutter not found: $candidate"
    }
    $command = Get-Command flutter -ErrorAction SilentlyContinue
    if ($command) { return $command.Source }
    throw 'Set PBS_FLUTTER_ROOT or run tools/bootstrap/setup.ps1 -FlutterRoot <SDK path>.'
}

function Invoke-Checked {
    param([string]$Command, [string[]]$Arguments)
    & $Command @Arguments
    if ($LASTEXITCODE -ne 0) { throw "Command failed ($LASTEXITCODE): $Command $($Arguments -join ' ')" }
}
