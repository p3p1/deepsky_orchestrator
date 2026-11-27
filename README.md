# DeepSky Orchestrator

Planner deep-sky personalizzato per il setup:

- **Telescopio:** Askar FRA400 (400mm f/5.6)
- **Camera:** ZWO ASI2600MC Pro (APS-C, 23.5 x 15.7 mm, pixel 3.76 um)
- **Riduttore:** 0.8x opzionale -> 320mm f/4.5
- **Montatura:** ZWO AM3N + ASIAIR Plus
- **Autoguida:** ZWO ASI120mm mini + SVBONY SV165

## Funzionalita'

- Catalogo ~140 oggetti deep-sky (Messier + NGC/IC selezionati)
- Punteggio fattibilita' 0-10 calcolato sul setup reale (30% match campo, 30% magnitudine, 20% risolvibilita', 20% tipo)
- Doppia inquadratura: dimensione oggetto vs FOV con e senza riduttore (3.36x2.25 gradi vs 4.20x2.81 gradi)
- Assegnazione automatica filtro consigliato: nebulose/SNR/planetarie -> dual-band, ammassi -> UV/IR cut, galassie -> nessuno
- Filtri catalogo: tipo, filtro usato, FOV (nativo/riduttore/mosaico), mese utile, slider punteggio minimo
- Ordinamento: punteggio, sigla, dimensione, ascensione retta, declinazione
- Layout responsive: master-detail su Samsung Z Fold 8 (schermo interno aperto), lista a tutto schermo in modalita' compatta

## Struttura

```
lib/main.dart           App Flutter completa (catalogo, scoring, UI)
pubspec.yaml            Dipendenze
data/dark_library.csv   Database dark e bias (template)
mockup/index.html       Mockup UI interattivo (v2)
README.md
```

## Build

```bash
flutter create deepsky_orchestrator
cd deepsky_orchestrator
# copiare lib/main.dart e pubspec.yaml dal repo nel progetto
flutter pub get
flutter run            # debug sul telefono
flutter build apk      # APK installabile
```

## Dark Library

`data/dark_library.csv`: registra ogni combinazione di gain/offset/temperatura/esposizione acquisita con l'ASI2600MC Pro.

Convenzione nomi master:
- `bias_g{gain}_o{offset}_t{temp}.fit`
- `dark_{sec}s_g{gain}_o{offset}_t{temp}.fit`

## Note

Coordinate, magnitudini e dimensioni sono approssimate (buone per pianificare; verificare con Stellarium/SkySafari per composizioni critiche).
