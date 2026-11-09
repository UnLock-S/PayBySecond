$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$coverage = [System.Collections.Generic.HashSet[int]]::new()
Get-Content (Join-Path $root 'src/apps/pay_by_second/assets/fonts/coverage.txt') | ForEach-Object {
    [void]$coverage.Add([Convert]::ToInt32($_, 16))
}
$missing = [System.Collections.Generic.HashSet[int]]::new()
$seed = Get-Content (Join-Path $root 'config/app/font-extra-characters.txt') -Raw -Encoding utf8
foreach ($character in $seed.ToCharArray()) {
    $code = [int]$character
    if ($code -ge 128 -and -not $coverage.Contains($code)) { [void]$missing.Add($code) }
}
Get-ChildItem (Join-Path $root 'src') -Recurse -File -Filter '*.dart' |
    Where-Object { $_.FullName -notmatch '[\\/](build|\.dart_tool)[\\/]' } | ForEach-Object {
        $text = Get-Content -LiteralPath $_.FullName -Raw -Encoding utf8
        foreach ($character in $text.ToCharArray()) {
            $code = [int]$character
            if ($code -ge 128 -and -not $coverage.Contains($code)) { [void]$missing.Add($code) }
        }
    }
if ($missing.Count -gt 0) {
    throw "UI font missing codepoints: $($missing -join ', '). Regenerate with tools/build/subset_font.py."
}
Write-Output 'Local UI font coverage: PASS'
