# Rebuild display copies without altering the original photographs.
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$root = Split-Path $PSScriptRoot -Parent
$utf8 = New-Object System.Text.UTF8Encoding($false)
$codec = [Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object MimeType -eq 'image/jpeg'
foreach ($base in @('', 'sorpresa/')) {
    $folder = Join-Path $root ($base + 'img/ricordi')
    $output = Join-Path $folder 'optimized'
    [IO.Directory]::CreateDirectory($output) | Out-Null
    $pagePath = Join-Path $root ($base + 'pages/ricordi.html')
    $page = Get-Content -Raw -Encoding utf8 -LiteralPath $pagePath
    foreach ($file in (Get-ChildItem -LiteralPath $folder -Filter *.jpg)) {
        $image = [Drawing.Image]::FromFile($file.FullName)
        try {
            if ($image.PropertyIdList -contains 274) {
                $orientation = [BitConverter]::ToUInt16($image.GetPropertyItem(274).Value, 0)
                $rotation = switch ($orientation) { 2 {'RotateNoneFlipX'} 3 {'Rotate180FlipNone'} 4 {'Rotate180FlipX'} 5 {'Rotate90FlipX'} 6 {'Rotate90FlipNone'} 7 {'Rotate270FlipX'} 8 {'Rotate270FlipNone'} default {'RotateNoneFlipNone'} }
                $image.RotateFlip([Drawing.RotateFlipType]::$rotation)
            }
            foreach ($size in @(480,960)) {
                $width = [Math]::Min($size, $image.Width)
                $height = [int][Math]::Round($image.Height * $width / $image.Width)
                $bitmap = New-Object Drawing.Bitmap($width, $height)
                $graphics = [Drawing.Graphics]::FromImage($bitmap)
                $parameters = New-Object Drawing.Imaging.EncoderParameters(1)
                try {
                    $graphics.CompositingQuality = 'HighQuality'
                    $graphics.InterpolationMode = 'HighQualityBicubic'
                    $graphics.SmoothingMode = 'HighQuality'
                    $graphics.PixelOffsetMode = 'HighQuality'
                    $graphics.DrawImage($image, 0, 0, $width, $height)
                    $parameters.Param[0] = New-Object Drawing.Imaging.EncoderParameter([Drawing.Imaging.Encoder]::Quality, [long]92)
                    $bitmap.Save((Join-Path $output ($file.BaseName + '-' + $size + '.jpg')), $codec, $parameters)
                } finally { $parameters.Dispose(); $graphics.Dispose(); $bitmap.Dispose() }
            }
            $pattern = '(?s)(<h2>([^<]+)</h2>\s*)<img\s+[^>]*src="\.\./img/ricordi/(?:optimized/)?' + [regex]::Escape($file.BaseName) + '(?:-480)?\.jpg"[^>]*>'
            $name = $file.BaseName
            $w480 = [Math]::Min(480,$image.Width); $w960 = [Math]::Min(960,$image.Width)
            $height960 = [int][Math]::Round($image.Height * $w960 / $image.Width)
            $first = $name -eq 'palestra'
            $page = [regex]::Replace($page, $pattern, [System.Text.RegularExpressions.MatchEvaluator]{ param($match)
                $loading = if ($first) { 'loading="eager" fetchpriority="high"' } else { 'loading="lazy"' }
                $srcset = '../img/ricordi/optimized/' + $name + '-480.jpg ' + $w480 + 'w'
                if ($w960 -gt $w480) { $srcset += ', ../img/ricordi/optimized/' + $name + '-960.jpg ' + $w960 + 'w' }
                $match.Groups[1].Value + '<img src="../img/ricordi/optimized/' + $name + '-480.jpg" srcset="' + $srcset + '" sizes="(max-width: 600px) calc(100vw - 90px), 400px" width="' + $w960 + '" height="' + $height960 + '" alt="' + [System.Net.WebUtility]::HtmlEncode($match.Groups[2].Value) + '" ' + $loading + ' decoding="async">'
            })
        } finally { $image.Dispose() }
    }
    [IO.File]::WriteAllText($pagePath, $page, $utf8)
}
