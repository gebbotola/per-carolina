const questions = [

    // ❤️ VOI DUE
    { q: "Quando abbiamo iniziato a parlare?", a: ["26 agosto 2025", "6 settembre 2025", "30 luglio 2025", "3 settembre 2025"], correct: 2 },
    { q: "Quando ci siamo messi insieme?", a: ["26 agosto", "3 settembre", "30 luglio", "6 settembre"], correct: 3 },
    { q: "Dove ci siamo incontrati per la prima volta?", a: ["A scuola", "In palestra", "Al parco", "In centro"], correct: 1 },
    { q: "Qual è il nostro posto?", a: ["Il bar", "La palestra", "La panchina fuori", "Il parcheggio"], correct: 2 },
    { q: "Cosa facciamo di solito dopo esserci allenati?", a: ["Torniamo a casa", "Mangiamo", "Parliamo", "Guardiamo il telefono"], correct: 2 },
    { q: "Quando ci siamo dati il primo bacio?", a: ["30 luglio", "26 agosto", "3 settembre", "6 settembre"], correct: 1 },
    { q: "Chi ha dato il primo bacio?", a: ["Io", "Tu", "Insieme", "Nessuno"], correct: 2 },
    { q: "Come ti chiamo a volte?", a: ["Amore", "Amo", "Nasino", "Piccola"], correct: 2 },
    { q: "Dove siamo andati il 3 settembre?", a: ["Al mare", "In centro", "A Rainbow MagicLand", "A cena"], correct: 2 },
    { q: "Quando dici “ma tutto bene”, io:", a: ["Mi preoccupo", "Ignoro", "Rido e sfotto", "Mi arrabbio"], correct: 2 },

    { q: "Qual è una cosa che mi calma davvero quando sto con te?", a: ["Parlare", "Ridere", "Abbracciarti", "Stare in silenzio"], correct: 2 },
    { q: "Qual è una cosa che faccio spesso con te?", a: ["Ti abbraccio", "Ti guardo negli occhi", "Gioco con i tuoi capelli", "Ti tengo la mano"], correct: 2 },
    { q: "Cosa facciamo spesso in chiamata?", a: ["Parliamo poco", "Dormiamo insieme", "Giochiamo", "Guardiamo video"], correct: 1 },
    { q: "Quando parliamo di più?", a: ["Solo di giorno", "Solo di notte", "Tutto il giorno", "Solo quando usciamo"], correct: 2 },
    { q: "Una cosa che amo di te?", a: ["Il carattere", "Il sorriso", "Gli occhi e le labbra", "Il modo di parlare"], correct: 2 },
    { q: "Quale di questi momenti per me è stato il più importante?", a: ["Quando abbiamo iniziato a parlare", "Rainbow MagicLand", "Primo bacio", "Quando ci siamo messi insieme"], correct: 3 },
    { q: "Il nostro rapporto è più:", a: ["Serio", "Normale", "Intenso e profondo", "Leggero"], correct: 2 },
    { q: "Cosa ci diverte fare insieme?", a: ["Studiare", "Allenarci", "Dormire", "Uscire poco"], correct: 1 },
    { q: "Dove ci vediamo spesso?", a: ["Bar", "Casa", "Palestra", "Centro"], correct: 2 },
    { q: "Cosa facciamo spesso dopo palestra?", a: ["Andiamo via", "Mangiamo", "Parliamo", "Guardiamo telefono"], correct: 2 },

    // 🧠 TE
    { q: "Quale marca di auto mi piace di più?", a: ["BMW", "Audi", "Mercedes", "Tesla"], correct: 0 },
    { q: "Che tipo di macchina preferisco?", a: ["Elegante", "Sportiva", "Familiare", "Elettrica"], correct: 1 },
    { q: "Che tipo di musica mi rappresenta di più?", a: ["Pop", "Rock", "Trap/chill", "Indie"], correct: 2 },
    { q: "Quando mi sento più attivo?", a: ["In inverno", "Primavera", "Estate", "Sempre"], correct: 2 },
    { q: "Preferisco:", a: ["Mattina", "Pomeriggio", "Sera", "Notte"], correct: 3 },
    { q: "Uscire o stare a casa?", a: ["Sempre uscire", "Sempre casa", "Dipende", "Nessuno"], correct: 2 },
    { q: "Cosa non mi piace mangiare?", a: ["Verdure", "Carne", "Pesce", "Dolci"], correct: 2 },
    { q: "Se devo scegliere cosa mangiare:", a: ["Sushi", "Hamburger", "Insalata", "Pizza"], correct: 1 },
    { q: "Il colore che mi rappresenta?", a: ["Blu", "Nero", "Rosso", "Bianco"], correct: 2 },
    { q: "In una relazione sono:", a: ["Geloso", "Tranquillo", "Freddo", "Distaccato"], correct: 1 },

    { q: "Preferisco:", a: ["Mare", "Montagna", "Città", "Campagna"], correct: 0 },
    { q: "Il mio stile è più:", a: ["Elegante", "Sportivo", "Street", "Classico"], correct: 2 },
    { q: "Cosa mi piace fare?", a: ["Studiare", "Allenarmi", "Ascoltare la musica", "Disegnare"], correct: 2 },
    { q: "Cosa mi rilassa di più?", a: ["Musica", "Allenamento", "Stare con te", "Dormire"], correct: 2 },
    { q: "Sono più:", a: ["Estroverso", "Introverso", "Calmo", "Caotico"], correct: 1 },
    { q: "Quando sono nei miei pensieri:", a: ["Mi distraggo", "Rifletto in silenzio", "Parlo", "Ignoro"], correct: 2 },
    { q: "Mi piace di più:", a: ["Routine", "Cambiamento", "Un mix", "Niente"], correct: 1 },
    { q: "Il mio mood è più:", a: ["Energico", "Tranquillo", "Ansioso", "Caotico"], correct: 2 },

    // 💖 LEI
    { q: "Qual è il tuo cibo preferito?", a: ["Pizza", "Pasta", "Sushi", "Carne"], correct: 2 },
    { q: "Qual è il tuo colore preferito?", a: ["Blu", "Rosso", "Verde", "Nero"], correct: 1 },
    { q: "Qual è il film che ami di più?", a: ["Titanic", "Inception", "Interstellar", "Avatar"], correct: 2 },
    { q: "Qual è la serie che preferisci?", a: ["Stranger Things", "Elite", "Dark", "Breaking Bad"], correct: 2 },
    { q: "Qual è il tuo artista preferito?", a: ["Taylor Swift", "Harry Styles", "Ariana Grande", "Billie Eilish"], correct: 1 },
    { q: "Quando ti arrabbi, cosa dici?", a: ["Lascia stare", "Ok", "Ma tutto bene", "Non importa"], correct: 2 },
    { q: "Qual è una cosa che mi hai visto fare spesso?", a: ["Guardare telefono", "Giocare con i capelli", "Stare zitto", "Distrarmi"], correct: 1 },
    { q: "A Rainbow MagicLand cosa ti ricordi di più?", a: ["Le giostre", "La paura delle montagne russe", "Il caldo", "Le file"], correct: 1 },
    { q: "Qual è una cosa che secondo te mi rende diverso?", a: ["Il modo di parlare", "Il carattere", "Il modo in cui ti tratto", "I gusti"], correct: 2 }

];

let quiz = [];
let current = 0;
let score = 0;
let locked = false;

function shuffle(array) {
    return [...array].sort(() => Math.random() - 0.5);
}

function startQuiz() {
    quiz = shuffle(questions).slice(0, 10);
    current = 0;
    score = 0;

    document.getElementById("quiz").classList.remove("hidden");
    document.getElementById("result").classList.add("hidden");

    showQuestion();
}

function showQuestion() {
    locked = false;

    const q = quiz[current];

    document.getElementById("progressText").textContent =
        `Domanda ${current + 1} / 10`;

    document.getElementById("question").textContent = q.q;

    const answersDiv = document.getElementById("answers");
    answersDiv.innerHTML = "";

    q.a.forEach((text, index) => {
        const btn = document.createElement("button");
        btn.textContent = text;

        btn.onclick = () => answerClick(index === q.correct);

        answersDiv.appendChild(btn);
    });

    updateBar();
}

function answerClick(correct) {
    if (locked) return;
    locked = true;

    if (correct) score++;

    current++;

    if (current < 10) {
        setTimeout(showQuestion, 200);
    } else {
        setTimeout(showResult, 200);
    }
}

function updateBar() {
    const percent = (current / 10) * 100;
    document.getElementById("barFill").style.width = percent + "%";
}

function showResult() {
    document.getElementById("quiz").classList.add("hidden");
    document.getElementById("result").classList.remove("hidden");

    document.getElementById("resultTitle").textContent =
        `Punteggio: ${score} / 10`;

    let text = "";

    if (score <= 4) text = "Mmm... dobbiamo lavorarci 😅";
    else if (score <= 7) text = "Non male… ma puoi fare di meglio ❤️";
    else if (score <= 9) text = "Mi conosci davvero bene 💕";
    else {
        text = "Ok… mi conosci troppo bene.";

        document.body.classList.add("wormhole");

        setTimeout(() => {
            window.location.href = "secret.html";
        }, 1800);
    }

    document.getElementById("resultText").textContent = text;
}

function goHome() {
    window.location.href = "../home.html";
}

startQuiz();