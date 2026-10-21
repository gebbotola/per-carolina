param([int]$Port = 5500)
# Small static server bound only to this PC. No installation or publishing.
$ErrorActionPreference = 'Stop'
$root = [IO.Path]::GetFullPath((Split-Path $PSScriptRoot -Parent)).TrimEnd('\')
$server = New-Object Net.Sockets.TcpListener([Net.IPAddress]::Loopback, $Port)
$server.Start()
Write-Host "Anteprima: http://localhost:$Port/ - Ctrl+C per terminare"
$types = @{'.html'='text/html; charset=utf-8';'.css'='text/css; charset=utf-8';'.js'='text/javascript; charset=utf-8';'.jpg'='image/jpeg';'.png'='image/png';'.svg'='image/svg+xml';'.json'='application/json; charset=utf-8'}
try {
    while ($true) {
        $client = $server.AcceptTcpClient()
        try {
            $client.ReceiveTimeout = 3000; $client.SendTimeout = 3000
            $stream = $client.GetStream()
            $reader = New-Object IO.StreamReader($stream, [Text.Encoding]::ASCII, $false, 1024, $true)
            $request = $reader.ReadLine()
            if (!$request) { continue }
            while ($reader.ReadLine() -ne '') { }
            $parts = $request.Split(' ')
            $method = $parts[0]
            $urlPath = [Uri]::UnescapeDataString(($parts[1] -split '\?')[0]).TrimStart('/')
            if (!$urlPath -or $urlPath.EndsWith('/')) { $urlPath += 'index.html' }
            $path = [IO.Path]::GetFullPath((Join-Path $root $urlPath))
            $allowed = $path.StartsWith($root + '\', [StringComparison]::OrdinalIgnoreCase) -and $urlPath -notmatch '(^|[/\\])\.'
            $status = '200 OK'
            if ($method -notin @('GET','HEAD')) { $status = '405 Method Not Allowed' }
            elseif (!$allowed -or !(Test-Path -LiteralPath $path -PathType Leaf)) { $status = '404 Not Found' }
            if ($status -eq '200 OK') {
                $bytes = [IO.File]::ReadAllBytes($path)
                $type = $types[[IO.Path]::GetExtension($path).ToLowerInvariant()]
                if (!$type) { $type = 'application/octet-stream' }
            } else { $bytes = [Text.Encoding]::UTF8.GetBytes($status); $type = 'text/plain; charset=utf-8' }
            $header = [Text.Encoding]::ASCII.GetBytes("HTTP/1.1 $status`r`nContent-Type: $type`r`nContent-Length: $($bytes.Length)`r`nCache-Control: no-store`r`nConnection: close`r`n`r`n")
            $stream.Write($header,0,$header.Length)
            if ($method -ne 'HEAD') { $stream.Write($bytes,0,$bytes.Length) }
        } catch { Write-Warning $_.Exception.Message } finally { $client.Dispose() }
    }
} finally { $server.Stop() }
