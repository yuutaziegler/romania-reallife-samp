# Romania Real Life - Las Venturas (SA-MP Gamemode & Server)

Server complet de SA-MP 0.3.7 bazat pe Las Venturas, cu sisteme avansate de Roleplay / RPG romanesc inspirat din clasicele comunitati (RedBugged, B-Hood).

## Caracteristici & Sisteme Principale

- **Spawn Principal**: Emerald Isle Casino & Hotel (Las Venturas) cu ATM functional si masini de spawn aliniate curat.
- **Tutorial Permis Incepatori**: Dialog interactiv la inregistrare (`DIALOG_TUTORIAL_DMV`) care ofera teleportare si ghid direct catre Scoala de Soferi.
- **Scoala de Soferi (DMV)**: Relocata la Blackfield Stadium Grounds cu un traseu de examen realist pe sosea in 6 puncte si verificare integritate caroserie.
- **Sistem Wanted & Infractiuni (1 - 6 stele)**: Sincronizat in timp real cu HUD-ul SA-MP si salvat in baza de date SQLite (`server.db`).
- **Sistem Politie & Raport de Activitate (`/raport`)**:
  - `/su [id] [wanted 1-6] [motiv]` – acorda mandat de urmarire si alerteaza dispeceratul.
  - `/wanted` – lista suspecților cautati online.
  - `/mdc [id]` – Mobile Data Computer cu cazierul complet si statusul catuselor.
  - `/cuff` si `/uncuff` – incatusare cu animatie oficiala (`SPECIAL_ACTION_CUFFED`).
  - `/arrest [id] [minute]` – incarcerare la penitenciar cu recompensa si punct la raport.
  - `/ticket [id] [amenda] [motiv]` – emitere amenda rutiera cu cota de 50% pentru ofiter.
  - `/frisk [id]` – perchezitie corporala suspect (bani cash, permis port-arma, arme pe sloturi).
  - `/clear [id]` – stergere cazier si urmarire.
  - `/raport` – panou de activitate cu puncte acumulate si target saptamanal.
- **7 Factiuni Active**:
  1. LVPD (Politie)
  2. SMURD / Paramedics (Medici)
  3. FBI (Biroul Federal)
  4. The Strip Syndicate (Mafie)
  5. Hitman Agency (Agentia Secreta)
  6. San News (Reporteri)
  7. Towing & Mechanics (Mecanici)
  - `/duty` pentru schimbare uniforma si echipare arme.
  - `/fveh` pentru garaj vehicule de factiune.
  - `/f` radio si `/members` pentru membrii online.
- **Joburi Las Venturas**:
  - Tirist / Trucker la Depozitul K.A.C.C. Las Venturas (Roadtrain + remorca).
  - Pizza Boy la Emerald Isle Pizzeria (Faggio).
  - Taximetrist & Gunoier.
  - `/quitjob` / `/demisie` pentru demisie rapida.
- **Sistem Vehicule Personale & Dealership**:
  - Dealership auto Las Venturas cu catalog auto (`/ds`, `/buycar`).
  - Motor pornit/oprit pe tasta `2` sau `/engine`.
  - Inchidere centralizata usi pe tasta `N` sau `/lock`.
  - Vitezometru digital Dark Obsidian Glass cu viteza, benzina dinamica si viata caroserie.
- **Garda Administrativa / Staff (`/ahelp`)**:
  - Comenzi organizate pe grade de la L1 Helper pana la L5 Owner (`/spec`, `/specoff`, `/kick`, `/mute`, `/unmute`, `/freeze`, `/unfreeze`, `/slap`, `/jail`, `/fly`, `/god`, `/ban`, `/goto`, `/gethere`, `/sethp`, `/setarmour`, `/rac`, `/destroyveh`, `/o`, `/makeadmin`, `/givemoney`, `/setleader`).
  - Recunoastere automata de Owner (Level 5) pentru utilizatorul `atomk`.

## Rulare pe Pterodactyl / Linux

1. Urca fisierele pe serverul tau Pterodactyl.
2. Asigura-te ca `samp03svr` si `start.sh` au permisiuni de executie (`chmod +x samp03svr start.sh`).
3. Porneste serverul din consola panoului.
