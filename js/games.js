const trisGame = document.getElementById('trisGame');
const memoryGame = document.getElementById('memoryGame');
const trisBoard = document.getElementById('trisBoard');
const trisStatus = document.getElementById('trisStatus');
const mode = document.getElementById('mode');
const difficulty = document.getElementById('difficulty');
const memoryBoard = document.getElementById('memoryBoard');
const memoryStatus = document.getElementById('memoryStatus');
const wins = [[0,1,2],[3,4,5],[6,7,8],[0,3,6],[1,4,7],[2,5,8],[0,4,8],[2,4,6]];
let trisCells = Array(9).fill(''), player = '❤️', over = false;
let scoreH = 0, scoreS = 0, pcTimer = null, memoryTimer = null;
let first = null, lock = false, found = 0;
const emojis = ['❤️','⭐','🌙','💫','🔥','🍀','🌸','🎵','✨'];
function shuffleCards(values) {
    const result = [...values];
    for (let i = result.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [result[i], result[j]] = [result[j], result[i]];
    }
    return result;
}
function showTris() {
    trisGame.classList.remove('hidden'); memoryGame.classList.add('hidden');
    document.getElementById('trisTab').setAttribute('aria-pressed','true');
    document.getElementById('memoryTab').setAttribute('aria-pressed','false');
}
function showMemory() {
    memoryGame.classList.remove('hidden'); trisGame.classList.add('hidden');
    document.getElementById('trisTab').setAttribute('aria-pressed','false');
    document.getElementById('memoryTab').setAttribute('aria-pressed','true');
}
function winner(board) {
    for (const [a,b,c] of wins) if (board[a] && board[a] === board[b] && board[a] === board[c]) return board[a];
    return board.includes('') ? null : 'draw';
}
function drawTris() {
    if (!trisBoard.children.length) {
        for (let i = 0; i < 9; i++) {
            const cell = document.createElement('button');
            cell.type = 'button'; cell.className = 'cell';
            cell.onclick = () => move(i); trisBoard.appendChild(cell);
        }
    }
    [...trisBoard.children].forEach((cell, i) => {
        cell.textContent = trisCells[i];
        cell.setAttribute('aria-label', `Riga ${Math.floor(i / 3) + 1}, colonna ${i % 3 + 1}: ${trisCells[i] || 'vuota'}`);
        cell.disabled = over || Boolean(trisCells[i]) || (mode.value === 'pc' && player === '⭐');
    });
}
function check() {
    const result = winner(trisCells);
    if (!result) return false;
    over = true;
    if (result === 'draw') trisStatus.textContent = 'Pareggio ✨';
    else {
        if (result === '❤️') scoreH++; else scoreS++;
        document.getElementById('scoreH').textContent = scoreH;
        document.getElementById('scoreS').textContent = scoreS;
        trisStatus.textContent = result + ' vince ';
    }
    return true;
}
function move(i) {
    if (over || trisCells[i] || (mode.value === 'pc' && player === '⭐')) return;
    trisCells[i] = player;
    if (!check()) {
        player = player === '❤️' ? '⭐' : '❤️';
        trisStatus.textContent = 'Tocca a ' + player;
        if (mode.value === 'pc' && player === '⭐') pcTimer = setTimeout(pcMove, 400);
    }
    drawTris();
}
function minimax(board, turn, depth = 0) {
    const result = winner(board);
    if (result) return result === '⭐' ? 10 - depth : result === '❤️' ? depth - 10 : 0;
    const scores = [];
    board.forEach((value, i) => {
        if (value) return;
        board[i] = turn;
        scores.push(minimax(board, turn === '⭐' ? '❤️' : '⭐', depth + 1));
        board[i] = '';
    });
    return turn === '⭐' ? Math.max(...scores) : Math.min(...scores);
}
function choosePcMove() {
    const empty = trisCells.map((v,i) => v ? -1 : i).filter(i => i >= 0);
    if (!empty.length) return null;
    if (difficulty.value === 'hard') {
        let best = -Infinity, choice = empty[0];
        for (const i of empty) {
            trisCells[i] = '⭐'; const value = minimax(trisCells, '❤️'); trisCells[i] = '';
            if (value > best) { best = value; choice = i; }
        }
        return choice;
    }
    if (difficulty.value === 'medium') {
        for (const symbol of ['⭐','❤️']) for (const i of empty) {
            trisCells[i] = symbol; const result = winner(trisCells); trisCells[i] = '';
            if (result === symbol) return i;
        }
    }
    return empty[Math.floor(Math.random() * empty.length)];
}
function pcMove() {
    pcTimer = null;
    if (mode.value !== 'pc' || over || player !== '⭐') return;
    const i = choosePcMove(); if (i === null) return;
    trisCells[i] = '⭐';
    if (!check()) { player = '❤️'; trisStatus.textContent = 'Tocca a ❤️'; }
    drawTris();
    if (!over && !trisGame.classList.contains('hidden')) [...trisBoard.children].find(cell => !cell.disabled)?.focus({preventScroll:true});
}
function resetTris() {
    clearTimeout(pcTimer); pcTimer = null;
    trisCells = Array(9).fill(''); player = '❤️'; over = false;
    trisStatus.textContent = 'Tocca a ❤️';
    difficulty.disabled = mode.value !== 'pc'; drawTris();
}
function resetScore() {
    scoreH = 0; scoreS = 0;
    document.getElementById('scoreH').textContent = 0;
    document.getElementById('scoreS').textContent = 0;
}
function startMemory() {
    clearTimeout(memoryTimer); memoryTimer = null;
    found = 0; first = null; lock = false;
    memoryStatus.textContent = 'Trova tutte le coppie.'; memoryBoard.replaceChildren();
    shuffleCards([...emojis,...emojis]).forEach((sym, i) => {
        const card = document.createElement('button');
        card.type = 'button'; card.className = 'memory-card'; card.dataset.sym = sym;
        card.dataset.position = i + 1; card.setAttribute('aria-label', `Carta ${i + 1}, coperta`);
        card.onclick = () => flip(card); memoryBoard.appendChild(card);
    });
}
function flip(card) {
    if (lock || card.classList.contains('revealed')) return;
    card.textContent = card.dataset.sym; card.classList.add('revealed');
    card.setAttribute('aria-label', `Carta ${card.dataset.position}: ${card.dataset.sym}`);
    if (!first) { first = card; return; }
    const previous = first; first = null;
    if (previous.dataset.sym === card.dataset.sym) {
        found++;
        previous.setAttribute('aria-disabled','true'); card.setAttribute('aria-disabled','true');
        memoryStatus.textContent = found === emojis.length ? 'Tutte le coppie trovate ❤️' : `Coppie trovate: ${found} / ${emojis.length}`;
    } else {
        lock = true;
        memoryTimer = setTimeout(() => {
            for (const item of [previous,card]) {
                item.textContent = ''; item.classList.remove('revealed');
                item.setAttribute('aria-label', `Carta ${item.dataset.position}, coperta`);
            }
            lock = false; memoryTimer = null;
        },800);
    }
}
resetTris(); startMemory();
