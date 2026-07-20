$app = Get-Content -LiteralPath 'index.html' -Raw -Encoding UTF8
$iconSvg = Get-Content -LiteralPath 'icon.svg' -Raw -Encoding UTF8

function ToBase64Utf8($text) {
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($text)
    return [Convert]::ToBase64String($bytes)
}

$iconB64 = ToBase64Utf8($iconSvg)

# Inline the favicon as a data URI; drop external manifest/apple-touch-icon links
# (this single-file build doesn't ship manifest.json / icon-512.png alongside it)
$app = $app -replace '<link rel="icon" type="image/svg\+xml" href="icon\.svg">', "<link rel=`"icon`" type=`"image/svg+xml`" href=`"data:image/svg+xml;base64,$iconB64`">"
$app = $app -replace '<link rel="manifest" href="manifest\.json">\r?\n', ''
$app = $app -replace '<link rel="apple-touch-icon" href="icon-512\.png">\r?\n', ''

# Drop the service worker registration block (no separate service-worker.js ships with this build)
$app = $app -replace '(?s)if\("serviceWorker" in navigator\)\{.*?\n\}\r?\n', ''

if (!(Test-Path 'dist')) { New-Item -ItemType Directory -Path 'dist' | Out-Null }
$out = 'dist\Recovery.html'
Set-Content -LiteralPath $out -Value $app -Encoding UTF8
Write-Host "Done: $out"
