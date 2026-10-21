# Anteprima locale e verifiche

Le modifiche si trovano nel branch `codex-miglioramenti`, senza commit o pubblicazioni.

## Avviare il sito su Windows

Aprire PowerShell nella cartella del progetto ed eseguire:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\preview.ps1
```

Aprire http://localhost:5500/ oppure http://localhost:5500/home.html per entrare direttamente nel menu. La copia secondaria rimane disponibile su http://localhost:5500/sorpresa/.

Il server legge i file della cartella di lavoro, invia risposte senza cache ed e' accessibile solo da questo PC. Per fermarlo, usare Ctrl+C nella finestra PowerShell. Se la porta e' gia' occupata dal server avviato durante il lavoro, usare quello oppure scegliere una porta diversa:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\preview.ps1 -Port 5501
```

## Controllare il layout mobile

In Chrome o Edge: F12, poi Ctrl+Shift+M. Provare larghezze di 320, 390 e 768 pixel, orientamento orizzontale e zoom. L'emulazione non sostituisce un telefono reale.

## Verifiche ripetibili

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\check-project.ps1
```

Controlla percorsi e maiuscole, viewport, contenuti narrativi, fotografie originali e branch. Il confronto usa HEAD come riferimento originale: va aggiornato se in futuro si eseguono commit delle modifiche.

`tools/check-browser.ps1` richiede il server sulla porta 5500 e Chrome/Edge avviato con il protocollo di debug sulla porta 9222. Usa un profilo temporaneo separato. Verifica giochi, tutte le pagine a tre larghezze, movimento ridotto e pagina segreta. Le richieste ai font esterni sono bloccate durante questi test per controllare anche i caratteri di riserva.

`tools/optimize-photos.ps1` rigenera le versioni JPEG da 480 e 960 pixel, qualita' 92, senza alterare gli originali. La timeline sceglie la risoluzione tramite srcset e carica progressivamente le immagini fuori schermo. Gli originali rimangono in img/ricordi e sorpresa/img/ricordi.

## Versione pubblicata verificata prima delle modifiche

Il deployment GitHub Pages 4065922036 risulta riuscito, da main, commit b7bc0b53f5622b76c3590ed4b832d1eb53190ba0, con URL https://gebbotola.github.io/per-carolina/.

I file pubblicati css/tempo.css e pages/favole.html coincidevano con la copia principale e differivano dalla copia sorpresa. Anche sorpresa/pages/favole.html era raggiungibile pubblicamente come sottocartella. Entrambe le copie sono conservate e ricevono le correzioni tecniche; le differenze preesistenti non coinvolte sono mantenute.
