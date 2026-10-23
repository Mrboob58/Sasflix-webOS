$ErrorActionPreference = 'Stop'
$project = Split-Path -Parent $MyInvocation.MyCommand.Path
$app = Join-Path $project 'app'
$out = Join-Path $project 'dist'

$packager = Get-Command ares-package -ErrorAction SilentlyContinue
if (-not $packager) {
    $localPackager = Join-Path $project '.tools\cli\node_modules\.bin\ares-package.cmd'
    $localNode = Join-Path $project '.tools\node-v20.19.5-win-x64'
    if ((Test-Path -LiteralPath $localPackager) -and (Test-Path -LiteralPath (Join-Path $localNode 'node.exe'))) {
        $env:PATH = "$localNode;$env:PATH"
        $packager = $localPackager
    } else {
        throw 'ares-package was not found. Install Node.js and run npm install -g @webos-tools/cli.'
    }
}
if (-not (Test-Path -LiteralPath $out)) {
    New-Item -ItemType Directory -Path $out | Out-Null
}
& $packager --no-minify --outdir $out $app
if ($LASTEXITCODE -ne 0) { throw "ares-package failed with exit code $LASTEXITCODE" }
