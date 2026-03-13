window.onload = function () {

    const textElement = document.getElementById("text");

    const message = `Se sei arrivata qui significa che hai trovato uno dei posti più nascosti di questo sito.

Forse non era facile trovarlo, in realtà questo posto non è fatto per essere perfetto o complicato, ma per essere nostro.

Ho fatto tutto questo in modo che tu avessi uno spazio tutto per te.
Uno spazio dove perdere tempo, divertirti, o semplicemente per farti alzare il morale quando sei giù.

Magari lo userai quando sentirai la mia mancanza, o in un momento in cui io non ci sarò, che sarò lontano.
Oppure solo quando avrai voglia di tornare qui.

Ma volevo anche darti qualcosa che non molte persone hanno:
un posto creato solo per te.
La verità è che ho fatto tutto questo perché ti amo.
E il mio amore per te mi ha sempre spinto oltre i miei limiti.

Mi ha fatto provare cose nuove, imparare cose che prima non sapevo fare e impegnarmi in qualcosa che non avrei mai pensato di creare.

Tutto questo esiste solo perché esisti tu.

E voglio che tu sappia una cosa, sempre.

Qualsiasi cosa succeda nella vita, io sarò sempre dalla tua parte.
Vorrò sempre vederti felice, vederti crescere e vederti vincere nella vita.

Anche nei momenti difficili, anche quando dubiterai di te stessa,
io continuerò a credere in te.

Perché per me sei una delle persone più importanti che esistano.

Ti amo da morire Carolina ❤️`;

    let i = 0;
    const speed = 35;

    function typeWriter() {

        if (i === 0) {
            textElement.style.opacity = 1;
            textElement.style.transform = "translateY(0)";
        }

        if (i < message.length) {
            textElement.innerHTML += message.charAt(i);
            i++;
            setTimeout(typeWriter, speed);
        }
    }

    

    setTimeout(typeWriter, 800);
};

function goHome() {
    window.location.href = "../home.html";
}