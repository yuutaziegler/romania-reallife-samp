# Romania Real Life - Las Venturas (SA-MP Gamemode & Server)

Server complet de SA-MP 0.3.7 bazat pe Las Venturas, cu sisteme avansate de Roleplay / RPG romanesc inspirat din clasicele comunitati (RedBugged, B-Hood).

## Sisteme Noi (v1.3)

- **Tutorial Interactiv 5 Pasí**: La înregistrare, jucătorii trec printr-un tutorial complet (Joburi -> Banca & Telefon -> Case & Vehicule -> Permis DMV). Se poate relua oricând cu `/tutorial`.
- **Sistem de Case (15 locatii)**: Case de vânzare marcate pe map, `/house cumpara|vinde|intra`, interior privat (virtual world per casă), salvare în SQLite.
- **Sistem de Telefon**: Cumperi telefon din 24/7 (`/buy`), apoi `/phone`, `/call`, `/answer`, `/hangup`, `/sms` — apeluri reale între jucători.
- **Jobul Taxi complet**: `/fare [suma]` setează tariful, pasagerii plătesc automat la coborâre.
- **Jobul Gunoier complet**: Tură cu 5 puncte de colectare, plată la final de traseu.
- **Sistem Afaceri (10 biz-uri)**: `/biz`, `/bizcumpara`, `/bizvinde` — venit automat la payday.
- **Loterie**: `/loterie` ($500/bilet), extragere la payday cu pot care crește.
- **/v + /vpark**: meniu vehicule personale, respawn și parcare salvată.
- **/n (Newbie Chat) + /report**: întrebări pentru începători și raportare către staff.
- **/gunlicenta**: permis port-armă la LVPD ($10.000, nu pentru urmăriți).
- **Comenzi lider factiune**: `/invite`, `/uninvite`, `/giverank` (rank 1-5).
- **Banca Factiunii (v1.5)**: Bancă separată per factiune salvată în SQLite, `/fbank [depune|retrage]`, `/fsalariu` distribuire bani membrilor online.
- **Admin Jail (v1.5)**: `/ajail [id] [min] [motiv]` + `/unjail` — interior separat, doar `/report` și `/n` permise, countdown vizibil.
- **Ammo Shop (v1.5)**: `/ammo` la Ammu-Nation — cumperi gloante pentru armele pe care le porti.
- **/balance**: verificare rapidă cash + bancă de oriunde.
- **Skin Selection (v1.5)**: alegerea skinului la înregistrare (8 skinuri starter, bărbați/femei).

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

## Gamemode Red-Zone RPG (folder `red-zone/`)

Pachet complet **open.mp + MySQL** (gamemode profesional, modular, ~54.000 linii Pawn):

### Structura
- `red-zone/server-package/main.amx` – gamemode-ul compilat (modular, inclus din `src/` — Admins, Factions, Houses, Bussines, Inventar, iPhone, computer, clans, turfs, BattlePass etc.)
- `red-zone/red-zone.sql` – dump MySQL complet (conturi RESETATE la ID 1, fara conturi vechi, casele/biz-urile marcate ca libere)
- `red-zone/plugins/` – pluginuri Linux (.so): crashdetect, mysql, sscanf, streamer, gvar, ColAndreas
- `red-zone/server.cfg` – config Linux adaptat (port 7777, fara bind)

### Setup MySQL (obligatoriu)
1. Instaleaza MySQL/MariaDB si porneste-l.
2. `CREATE DATABASE samp;`
3. `mysql -u root samp < red-zone/red-zone.sql`
4. User `root` fara parola local (sau editezi `server-package/src/Variables.pwn` — `MySQL_UserLocal` / `MySQL_PassLocal` / `MySQL_DataLocal` — si recompilezi).

### Pornire
- Linux: ruleaza `./start-redzone.sh` (descarca runtime-ul open.mp Linux `omp-server` in `red-zone/` daca nu ai deja).
- Windows: ruleaza `red-zone/omp-server.exe` direct.

> Atentie: gamemode-ul Red-Zone ruleaza pe **open.mp** cu **MySQL**, in timp ce gamemode-ul vechi (custom_gamemode) ruleaza pe SA-MP 0.3.7 clasic cu **SQLite**. Sunt separate — `server.cfg` din root porneste custom_gamemode, `red-zone/server.cfg` porneste Red-Zone.

## Rulare pe Pterodactyl / Linux

1. Urca fisierele pe serverul tau Pterodactyl.
2. Asigura-te ca `samp03svr` si `start.sh` au permisiuni de executie (`chmod +x samp03svr start.sh`).
3. Porneste serverul din consola panoului.
