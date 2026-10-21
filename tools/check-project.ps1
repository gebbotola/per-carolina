$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
Set-Location -LiteralPath $root
function GitText($arguments) {
    $info = New-Object Diagnostics.ProcessStartInfo
    $info.FileName = 'git'; $info.Arguments = $arguments
    $info.WorkingDirectory = $root; $info.UseShellExecute = $false
    $info.RedirectStandardOutput = $true; $info.StandardOutputEncoding = [Text.Encoding]::UTF8
    $process = [Diagnostics.Process]::Start($info)
    $value = $process.StandardOutput.ReadToEnd(); $process.WaitForExit()
    if ($process.ExitCode) { throw "git $arguments failed" }
    return $value
}
if ((GitText 'branch --show-current').Trim() -ne 'codex-miglioramenti') { throw 'Wrong branch' }
$files = @(Get-ChildItem -LiteralPath $root -Recurse -File | Where-Object FullName -NotMatch '\\.git\\')
$paths = @($files | ForEach-Object FullName)
$html = @($files | Where-Object { $_.Extension -eq '.html' -and $_.FullName -notmatch '\\tools\\' })
foreach ($file in $html) {
    $source = Get-Content -Raw -Encoding utf8 -LiteralPath $file.FullName
    $relative = $file.FullName.Substring($root.Length+1).Replace('\','/')
    if ([regex]::Matches($source,'name="viewport"').Count -ne 1) { throw "$relative viewport" }
    if ([regex]::Matches($source,'id="main-content"').Count -ne 1) { throw "$relative main" }
    foreach ($match in [regex]::Matches($source,'<(?:a|link|script|img)\b[^>]*?\b(?:href|src)="([^"]+)"')) {
        $value = $match.Groups[1].Value
        if ($value -match '^[a-z]+:|^#') { continue }
        $target = [IO.Path]::GetFullPath((Join-Path $file.DirectoryName (($value -split '[?#]')[0])))
        if ($paths -cnotcontains $target) { throw "$relative missing or case-mismatched link: $value" }
    }
    foreach ($match in [regex]::Matches($source,'srcset="([^"]+)"')) {
        foreach ($entry in $match.Groups[1].Value.Split(',')) {
            $value = ($entry.Trim() -split '\s+')[0]
            $target = [IO.Path]::GetFullPath((Join-Path $file.DirectoryName $value))
            if ($paths -cnotcontains $target) { throw "$relative missing srcset $value" }
        }
    }
    if ($relative -match '/favole/|/leggi-quando/|/ricordi.html$') {
        $before = GitText ('show HEAD:' + $relative)
        foreach ($tag in @('h1','h2','p')) {
            $pattern = '(?s)<' + $tag + '\b[^>]*>(.*?)</' + $tag + '>'
            $old = @([regex]::Matches($before,$pattern) | ForEach-Object { $_.Groups[1].Value })
            $new = @([regex]::Matches($source,$pattern) | ForEach-Object { $_.Groups[1].Value })
            if (($old -join "`0").Replace("`r`n","`n") -cne ($new -join "`0").Replace("`r`n","`n")) { throw "$relative changed narrative $tag" }
        }
    }
}
foreach ($path in @('js/secret.js','sorpresa/js/secret.js')) {
    $before = GitText ('show HEAD:'+$path)
    $after = Get-Content -Raw -Encoding utf8 $path
    $pattern = '(?s)const message = `(.*?)`;'
    if ([regex]::Match($before,$pattern).Groups[1].Value.Replace("`r`n","`n") -cne [regex]::Match($after,$pattern).Groups[1].Value.Replace("`r`n","`n")) { throw "$path changed dedication" }
}
$originals = @(($files | Where-Object { $_.Extension -eq '.jpg' -and $_.FullName -notmatch '\\optimized\\' }))
foreach ($file in $originals) {
    $relative = $file.FullName.Substring($root.Length+1).Replace('\','/')
    $expected = (GitText ('rev-parse HEAD:'+$relative)).Trim()
    $actual = (GitText ('hash-object "'+$relative+'"')).Trim()
    if ($expected -ne $actual) { throw "$relative original changed" }
}
$tracked = (GitText 'ls-files') -split "`n" | Where-Object { $_ }
foreach ($path in $tracked) { if (!(Test-Path -LiteralPath $path)) { throw "Deleted file $path" } }
Write-Output "PASS: $($html.Count) HTML pages, local links and srcset including exact letter case"
Write-Output 'PASS: Original narrative headings, paragraphs and secret dedication unchanged'
Write-Output "PASS: $($originals.Count) original photographs and covers unchanged; no tracked files deleted"
Write-Output 'PASS: Working branch codex-miglioramenti'
$small = (Get-ChildItem img/ricordi/optimized -Filter '*-480.jpg' | Measure-Object Length -Sum).Sum
$large = (Get-ChildItem img/ricordi/optimized -Filter '*-960.jpg' | Measure-Object Length -Sum).Sum
$original = (Get-ChildItem img/ricordi -Filter '*.jpg' | Measure-Object Length -Sum).Sum
Write-Output "Photo bytes per complete set: originals=$original; 480px=$small; 960px=$large"
