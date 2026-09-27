# RedZone Roleplay - SA-MP / open.mp Gamemode

Gamemode complet de Roleplay / RPG pentru SA-MP și open.mp (RedZone România).

## 🚀 Caracteristici & Sisteme Incluse
- **Bază de date SQL:** Fișierul `red-zone.sql` inclus pentru import în MariaDB / MySQL.
- **Sistem Factiuni & Turfs:** Lideri, rank-uri, rapoarte, războaie de teritorii (Turfs).
- **Economie & Bizz / Case:** Sisteme complete de afaceri, case și licitații (`House.pwn`, `Bussines.pwn`, `Licitatie.pwn`).
- **Vehicule Personale & Dealership:** Dealership integrat, garaj, tuning, salvare în baza de date (`PersonalCar.pwn`).
- **Sistem de Joburi & Progres:** Multiple job-uri interactive cu obiective (`jobs.pwn`, `jobgoal.pwn`).
- **Sistem Computer / Browser:** Aplicații in-game: DRPCIV (școală de șoferi), RedSkins, TotalBet, Dealership etc.
- **BattlePass & Special Quests:** Misiuni zilnice/sezoniere și recompense (`BattlePass.pwn`, `special_quest.pwn`).
- **Inventar & Iteme:** Inventar complet pe textdraw-uri (`Inventar.pwn`).
- **AntiCheat integrat:** Protecții anti-cheat avansate (`antiCheat/`).
- **Sistem Clanuri & Prieteni:** Clan tags, chat de clan, seif clan (`clans.pwn`, `friends.pwn`).
- **Casino & Mini-jocuri:** Ruletă, Carnaval, jocuri de noroc (`rouletta.pwn`, `carnaval.pwn`).

## 📁 Structură
- `server-package/`: Sursa gamemode-ului (`main.pwn`, `src/`) și binarul compilat `main.amx`.
- `red-zone.sql`: Structura și tabelele bazei de date.
- `plugins/` & `components/`: Plugin-uri și componente compatibile SA-MP / open.mp.
- `filterscripts/`: Speedometre, sisteme adiționale.
- `scriptfiles/`: Fișiere de configurare și cache.
- `compiler/`: Set de compilare și include-uri.
