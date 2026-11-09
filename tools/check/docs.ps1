. (Join-Path $PSScriptRoot '../common.ps1')
Push-Location $ProjectRoot
try {
    $docFiles = @(& git ls-files --cached --others --exclude-standard -- '*.md') | Sort-Object -Unique
    foreach ($docFile in $docFiles) {
        if (-not (Test-Path -LiteralPath $docFile)) { continue }
        $body = Get-Content -LiteralPath $docFile -Raw
        if ($body -notmatch '(?m)^## English\s*$' -or $body -notmatch '(?m)^## 中文\s*$') {
            throw "Missing English/Chinese sections: $docFile. Upstream legal text must remain in its original license file."
        }
        foreach ($match in [regex]::Matches($body, '\]\(([^)]+)\)')) {
            $target = $match.Groups[1].Value.Trim('<', '>')
            if ($target -match '^(https?://|mailto:|#)') { continue }
            $relative = [uri]::UnescapeDataString(($target -split '#', 2)[0])
            $resolved = Join-Path (Split-Path -Parent (Join-Path $ProjectRoot $docFile)) $relative
            if (-not (Test-Path -LiteralPath $resolved)) { throw "Broken link in ${docFile}: $target" }
        }
    }
    Write-Output "Bilingual documentation and local links: PASS ($($docFiles.Count) Markdown files)"
} finally { Pop-Location }
