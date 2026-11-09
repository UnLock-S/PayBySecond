param([string]$FlutterRoot)
. (Join-Path $PSScriptRoot '../common.ps1')
& (Join-Path $ProjectRoot 'tools/build/update-config.ps1')
$flutter = Find-Flutter $FlutterRoot
Push-Location (Join-Path $ProjectRoot 'src/apps/pay_by_second')
try {
    Invoke-Checked $flutter @('build', 'web', '--release', '--no-web-resources-cdn')
    # Versioned destinations prevent old files from leaking into newer builds.
    $buildId = (Get-Date -Format 'yyyyMMdd-HHmmss') + '-' + [guid]::NewGuid().ToString('N').Substring(0, 6)
    $destination = Join-Path $ProjectRoot "out/web/$buildId"
    New-Item -ItemType Directory -Path $destination -Force | Out-Null
    Copy-Item -Path 'build/web/*' -Destination $destination -Recurse
    Write-Output "Web output: $destination"
} finally { Pop-Location }
