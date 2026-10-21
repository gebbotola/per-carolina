param([int]$DebugPort = 9222)
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$target = Invoke-RestMethod -Method Put -Uri "http://localhost:$DebugPort/json/new?about:blank"
$socket = New-Object Net.WebSockets.ClientWebSocket
$null = $socket.ConnectAsync([Uri]$target.webSocketDebuggerUrl, [Threading.CancellationToken]::None).GetAwaiter().GetResult()
$script:nextId = 0
$script:issues = New-Object 'System.Collections.Generic.List[string]'
function Receive-Message {
    $buffer = New-Object byte[] 262144
    $memory = New-Object IO.MemoryStream
    $cancel = New-Object Threading.CancellationTokenSource(15000)
    try {
        do {
            $result = $socket.ReceiveAsync([ArraySegment[byte]]::new($buffer), $cancel.Token).GetAwaiter().GetResult()
            $memory.Write($buffer, 0, $result.Count)
        } while (!$result.EndOfMessage)
        $message = [Text.Encoding]::UTF8.GetString($memory.ToArray()) | ConvertFrom-Json
        if ($message.method -eq 'Runtime.exceptionThrown') { $script:issues.Add(($message.params.exceptionDetails | ConvertTo-Json -Compress -Depth 8)) }
        return $message
    } finally { $cancel.Dispose(); $memory.Dispose() }
}
function CDP($method, $params = @{}) {
    $script:nextId++
    $bytes = [Text.Encoding]::UTF8.GetBytes((@{id=$script:nextId;method=$method;params=$params} | ConvertTo-Json -Compress -Depth 20))
    $null = $socket.SendAsync([ArraySegment[byte]]::new($bytes),[Net.WebSockets.WebSocketMessageType]::Text,$true,[Threading.CancellationToken]::None).GetAwaiter().GetResult()
    do { $message = Receive-Message } while ($message.id -ne $script:nextId)
    if ($message.error) { throw ($message.error | ConvertTo-Json -Compress) }
    return $message.result
}
function JS($expression) {
    $r = CDP 'Runtime.evaluate' @{expression=$expression;returnByValue=$true;awaitPromise=$true}
    if ($r.exceptionDetails) { throw ($r.exceptionDetails | ConvertTo-Json -Depth 8) }
    return $r.result.value
}
function Navigate($path) {
    $null = CDP 'Page.navigate' @{url=('http://localhost:5500/' + $path)}
    do { $event = Receive-Message } while ($event.method -ne 'Page.loadEventFired')
}
function Assert-JS($name, $expression) {
    if (!(JS $expression)) { $detail=JS 'JSON.stringify(window.failedBoard)'; throw "FAIL: $name $detail" }
    Write-Output "PASS: $name"
}
try {
    $null = CDP 'Page.enable'; $null = CDP 'Runtime.enable'; $null = CDP 'Network.enable'
    # Check offline font fallbacks too, without waiting for external services.
    $null = CDP 'Network.setBlockedURLs' @{urls=@('*fonts.googleapis.com*','*fonts.gstatic.com*')}
    foreach ($base in @('', 'sorpresa/')) {
        Navigate ($base + 'pages/giochi.html')
        Assert-JS ($base+'Tris blocks extra clicks and cancels stale computer moves') @'
new Promise(resolve => {
 mode.value='pc'; resetTris(); move(0); move(1);
 const blocked=trisCells.filter(Boolean).length===1;
 resetTris();
 setTimeout(()=>resolve(blocked && trisCells.every(v=>v==='')),500);
})
'@
        Assert-JS ($base+'Memory restart cancels mismatch timer') @'
new Promise(resolve => {
 startMemory(); const cards=[...memoryBoard.children];
 flip(cards[0]); flip(cards.find(c=>c.dataset.sym!==cards[0].dataset.sym));
 startMemory(); setTimeout(()=>resolve(!lock && first===null && found===0 && memoryBoard.children.length===18 && memoryStatus.textContent==='Trova tutte le coppie.'),900);
})
'@
        Assert-JS ($base+'Hard computer cannot lose against any human sequence') @'
(()=>{
 difficulty.value='hard';
 function explore(board) {
   const outcome=winner(board); if(outcome) return outcome!=='❤️';
   for(let i=0;i<9;i++) if(!board[i]) {
     const next=[...board]; next[i]='❤️';
     if(winner(next)==='❤️') { window.failedBoard=next; return false; }
     if(winner(next)==='draw') continue;
     trisCells=[...next]; const pc=choosePcMove(); next[pc]='⭐';
     if(!explore(next)) return false;
   }
   return true;
 }
 const ok=explore(Array(9).fill('')); resetTris(); return ok;
})()
'@
        Assert-JS ($base+'Medium computer wins and blocks immediate threats') @'
(()=>{difficulty.value='medium'; trisCells=['⭐','⭐','','❤️','','','','','']; const win=choosePcMove()===2; trisCells=['❤️','❤️','','','⭐','','','','']; const block=choosePcMove()===2; resetTris(); return win&&block;})()
'@
        Navigate ($base+'pages/quiz.html')
        Assert-JS ($base+'Quiz rejects double answers and cancels pending question on restart') @'
new Promise(resolve=>{answerClick(true);answerClick(true);const once=current===1&&score===1;startQuiz();setTimeout(()=>resolve(once&&current===0&&score===0&&!locked),450);})
'@
        Assert-JS ($base+'Quiz reaches 100% and cancels secret transition on restart') @'
new Promise(resolve=>{current=9;score=8;locked=false;answerClick(false);const complete=document.querySelector('.bar').getAttribute('aria-valuenow')==='100';clearTimeout(questionTimer);score=10;showResult();startQuiz();setTimeout(()=>resolve(complete&&!document.body.classList.contains('wormhole')&&location.pathname.endsWith('quiz.html')),1900);})
'@
    }
    Navigate 'index.html'
    $null = CDP 'Input.dispatchKeyEvent' @{type='keyDown';key='1';code='Digit1';text='1'}
    $null = CDP 'Input.dispatchKeyEvent' @{type='keyUp';key='1';code='Digit1'}
    Assert-JS 'Access keypad accepts physical number keys' "inputCode==='1'"
    $null = CDP 'Input.dispatchKeyEvent' @{type='keyDown';key='Backspace';code='Backspace';windowsVirtualKeyCode=8}
    Assert-JS 'Access keypad supports physical Backspace' "inputCode===''"
    Navigate 'pages/giochi.html'
    $null = JS "document.getElementById('memoryTab').focus()"
    $null = CDP 'Input.dispatchKeyEvent' @{type='keyDown';key=' ';code='Space';windowsVirtualKeyCode=32}
    $null = CDP 'Input.dispatchKeyEvent' @{type='keyUp';key=' ';code='Space';windowsVirtualKeyCode=32}
    Assert-JS 'Game menu responds to keyboard Space' "!memoryGame.classList.contains('hidden') && document.getElementById('memoryTab').getAttribute('aria-pressed')==='true'"
    $null = JS 'memoryBoard.firstElementChild.focus()'
    $null = CDP 'Input.dispatchKeyEvent' @{type='keyDown';key=' ';code='Space';windowsVirtualKeyCode=32}
    $null = CDP 'Input.dispatchKeyEvent' @{type='keyUp';key=' ';code='Space';windowsVirtualKeyCode=32}
    Assert-JS 'Memory cards respond to keyboard Space with visible focus' "memoryBoard.firstElementChild.classList.contains('revealed') && getComputedStyle(document.activeElement).outlineStyle!=='none'"
    $html = Get-ChildItem -LiteralPath $root -Recurse -Filter *.html | Where-Object FullName -NotMatch '\\tools\\'
    foreach ($width in @(320,768,1440)) {
        $null = CDP 'Emulation.setDeviceMetricsOverride' @{width=$width;height=900;deviceScaleFactor=1;mobile=($width -eq 320)}
        foreach ($file in $html) {
            $path=$file.FullName.Substring($root.Length+1).Replace('\','/')
            Navigate $path
            $problem = JS @'
(()=>{
 const errors=[];
 if(document.documentElement.scrollWidth>innerWidth+1) errors.push('horizontal overflow '+document.documentElement.scrollWidth+'/'+innerWidth);
 if(!document.querySelector('meta[name=viewport]')) errors.push('viewport');
 if(!document.querySelector('#main-content')) errors.push('main');
 for(const img of document.images) {
   if(!img.hasAttribute('alt')) errors.push('missing alt '+img.src);
   if(img.loading!=='lazy'&&img.complete&&!img.naturalWidth) errors.push('broken image '+img.src);
 }
 return errors.join('; ');
})()
'@
            if ($problem) { throw "${width}px $path : $problem" }
        }
        Write-Output "PASS: $($html.Count) pages at ${width}px, no overflow, viewport, main landmarks and image markup"
    }
    $null = CDP 'Emulation.setDeviceMetricsOverride' @{width=844;height=390;deviceScaleFactor=1;mobile=$true}
    foreach ($path in @('index.html','pages/giochi.html','pages/quiz.html','pages/tempo.html','pages/biglietti.html')) {
        Navigate $path
        Assert-JS ('Landscape '+$path) "document.documentElement.scrollWidth<=innerWidth+1 && document.getElementById('main-content').getBoundingClientRect().top>=0"
    }
    $null = CDP 'Emulation.setDeviceMetricsOverride' @{width=390;height=844;deviceScaleFactor=1;mobile=$true}
    Navigate 'pages/secret.html'
    Assert-JS 'Secret letter is complete and reachable after reveal' @'
(()=>{document.querySelector('.reveal-letter').click(); const p=document.getElementById('text');const r=p.getBoundingClientRect();const back=document.querySelector('.back').getBoundingClientRect();return p.innerText.includes('Ti amo da morire Carolina')&&r.top>=0&&back.top>=r.bottom;})()
'@
    $null = CDP 'Emulation.setEmulatedMedia' @{features=@(@{name='prefers-reduced-motion';value='reduce'})}
    Navigate 'pages/secret.html'
    Assert-JS 'Reduced motion reveals the full secret immediately' "document.querySelector('.reveal-letter').hidden && document.querySelector('#text').innerText.includes('Ti amo da morire Carolina')"
    Navigate 'pages/ricordi.html'
    Assert-JS 'Reduced motion keeps memories visible' "[...document.querySelectorAll('.timeline-item')].every(e=>getComputedStyle(e).opacity==='1')"
    $null = CDP 'Emulation.setEmulatedMedia' @{features=@()}
    Navigate 'home.html'
    $out = Join-Path $env:TEMP 'per-carolina-preview-mobile.png'
    $shot = CDP 'Page.captureScreenshot' @{format='png';captureBeyondViewport=$true}
    [IO.File]::WriteAllBytes($out,[Convert]::FromBase64String($shot.data))
    Write-Output "SCREENSHOT: $out"
    if ($script:issues.Count) { throw ($script:issues -join "`n") }
    Write-Output 'PASS: No uncaught JavaScript exceptions'
} finally { $socket.Dispose() }
