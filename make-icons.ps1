$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$app = Join-Path $root 'app'
$sourcePath = Get-ChildItem -Path $root -Recurse -File -Filter '*.png' | Where-Object { $_.Length -eq 20665 } | Select-Object -First 1 -ExpandProperty FullName
if (-not $sourcePath) { throw 'Design icon source was not found.' }
$source = [System.Drawing.Image]::FromFile($sourcePath)

foreach ($size in @(80, 130)) {
    $file = if ($size -eq 80) { 'icon.png' } else { 'largeicon.png' }
    $bitmap = New-Object System.Drawing.Bitmap($size, $size)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $graphics.DrawImage($source, 0, 0, $size, $size)
    $bitmap.Save((Join-Path $app $file), [System.Drawing.Imaging.ImageFormat]::Png)
    $graphics.Dispose()
    $bitmap.Dispose()
}

# webOS shows this native image while the web runtime is still starting.
# Keep its composition in sync with the HTML launch layer for a seamless handoff.
$splashWidth = 1920
$splashHeight = 1080
$logoSize = 176
$splash = New-Object System.Drawing.Bitmap($splashWidth, $splashHeight)
$splashGraphics = [System.Drawing.Graphics]::FromImage($splash)
$splashGraphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$splashGraphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$splashGraphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$splashGraphics.Clear([System.Drawing.Color]::FromArgb(9, 11, 12))

$centerX = [int]($splashWidth / 2)
$centerY = [int]($splashHeight / 2)
for ($radius = 460; $radius -ge 180; $radius -= 20) {
    $glowBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(3, 255, 116, 23))
    $splashGraphics.FillEllipse($glowBrush, $centerX - $radius, $centerY - $radius, $radius * 2, $radius * 2)
    $glowBrush.Dispose()
}
$splashGraphics.DrawImage($source, $centerX - [int]($logoSize / 2), $centerY - [int]($logoSize / 2), $logoSize, $logoSize)
$splash.Save((Join-Path $app 'splash.png'), [System.Drawing.Imaging.ImageFormat]::Png)
$splashGraphics.Dispose()
$splash.Dispose()

$source.Dispose()
