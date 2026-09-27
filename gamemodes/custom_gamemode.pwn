/*
    ============================================================================
                        ROMANIA ROLEPLAY / REAL LIFE
                        Full Custom SA-MP Gamemode v1.1
                        Roleplay UI & Complete Systems
    ============================================================================
*/

#pragma dynamic 65536
#pragma tabsize 4

#include <a_samp>
#include <a_sampdb>

#define FILTERSCRIPT
#undef FILTERSCRIPT

// Color Definitions
#define COLOR_WHITE         0xFFFFFFFF
#define COLOR_GREY          0xAFAFAFAA
#define COLOR_GREEN         0x33AA33AA
#define COLOR_RED           0xAA3333AA
#define COLOR_YELLOW        0xFFFF00AA
#define COLOR_ORANGE        0xFF9900AA
#define COLOR_BLUE          0x0066FFAA
#define COLOR_LIGHTBLUE     0x33CCFFAA
#define COLOR_PURPLE        0xC2A2DAAA
#define COLOR_ADMIN         0x00FFC4AA
#define COLOR_POLICE        0x2641FEAA
#define COLOR_MEDIC         0xFF6347AA
#define COLOR_CYAN          0x00FFFFFF
#define COLOR_GOLD          0xFFD700AA

// Dialog IDs
#define DIALOG_REGISTER         1001
#define DIALOG_LOGIN            1002
#define DIALOG_STATS            1003
#define DIALOG_BANK             1004
#define DIALOG_BANK_DEPOSIT     1005
#define DIALOG_BANK_WITHDRAW    1006
#define DIALOG_BANK_TRANSFER    1007
#define DIALOG_GPS              1008
#define DIALOG_DEALERSHIP       1009
#define DIALOG_STORE            1010
#define DIALOG_AMMU             1011
#define DIALOG_JOB              1012
#define DIALOG_HELP             1013
#define DIALOG_VEHICLE          1014
#define DIALOG_EVENT_CREATE     1015
#define DIALOG_DICE_INVITE      1016
#define DIALOG_FACTION_VEHICLES 1017
#define DIALOG_CLOTHES_CAT      1018
#define DIALOG_CLOTHES_LIST     1019
#define DIALOG_TUTORIAL         1020
#define DIALOG_WANTED           1021
#define DIALOG_TUTORIAL_DMV     1022
#define DIALOG_ADMIN_PANEL      1023
#define DIALOG_MDC              1024
#define DIALOG_FRISK            1025
#define DIALOG_RAPORT           1026
#define DIALOG_TUTORIAL_2       1027
#define DIALOG_TUTORIAL_3       1028
#define DIALOG_TUTORIAL_4       1029

// Max Limits
#define MAX_PERSONAL_VEHICLES   300
#define MAX_JOBS                5

// Job IDs
#define JOB_NONE        0
#define JOB_TRUCKER     1
#define JOB_PIZZA       2
#define JOB_TAXI        3
#define JOB_GARBAGE     4

// Faction IDs (Las Venturas)
#define FACTION_CIVILIAN 0
#define FACTION_POLICE   1   // Las Venturas Police Dept (LVPD)
#define FACTION_MEDIC    2   // Paramedic / SMURD LV
#define FACTION_FBI      3   // Federal Bureau / DIICOT LV
#define FACTION_MAFIA    4   // The Strip Syndicate / Yakuza
#define FACTION_HITMAN   5   // Hitman Agency LV
#define FACTION_NEWS     6   // San News Reporters LV
#define FACTION_TOW      7   // Towing Company / Mecanici LV

// Player Data Structure
enum E_PLAYER {
    pID,
    pName[MAX_PLAYER_NAME],
    pPassword[65],
    pMoney,
    pBank,
    pScore,
    pAdmin,
    pVIP,
    pJob,
    pFaction,
    pFactionRank,
    pDuty,
    pSkin,
    pKills,
    pDeaths,
    pHours,
    pWarns,
    pJailed,
    pJailTime,
    pCarLic,
    pGunLic,
    bool:pLogged,
    pCP,
    pWorkStage,
    pWorkVehicle,
    pWorkTrailer,
    pJobEarnings,
    pInTrunk,
    pFuel,
    pWanted,
    pCrimes[64],
    pRaport,
    pMuted,
    pMuteTime,
    pPhone,
    pHouse,
    pTutorial
};

new PlayerInfo[MAX_PLAYERS][E_PLAYER];

// Personal Vehicle Data Structure
enum E_VEHICLE {
    vID,
    vOwner[MAX_PLAYER_NAME],
    vModel,
    Float:vX,
    Float:vY,
    Float:vZ,
    Float:vA,
    vColor1,
    vColor2,
    vPrice,
    vLocked,
    vPlate[16],
    vServerID,
    bool:vSpawned
};

new VehicleInfo[MAX_PERSONAL_VEHICLES][E_VEHICLE];
new TotalPersonalVehicles = 0;

// Vehicle Engine & Fuel Tracking
new VehicleFuel[MAX_VEHICLES];
new bool:VehicleEngine[MAX_VEHICLES];
new bool:VehicleLights[MAX_VEHICLES];

// Textdraws
new Text:ServerLogoText;
new Text:ServerTimeText;
new PlayerText:RoleplayBoxTD[MAX_PLAYERS];
new PlayerText:RoleplayHudTD[MAX_PLAYERS];
new PlayerText:SpeedoBoxTD[MAX_PLAYERS];
new PlayerText:SpeedoInfoTD[MAX_PLAYERS];

// Event System Variables
enum {
    EVENT_NONE = 0,
    EVENT_DEAGLE,
    EVENT_LMS,
    EVENT_DERBY,
    EVENT_RACE
};

new gEventType = EVENT_NONE;
new gEventActive = 0;       // 0: inactiva, 1: inscrieri deschise, 2: in desfasurare
new gEventPrize = 50000;
new gEventParticipants = 0;
new bool:pInEvent[MAX_PLAYERS];
new EventVehicle[MAX_PLAYERS];

// Dice / Barbut System Variables
new DiceChallenger[MAX_PLAYERS];
new DiceBet[MAX_PLAYERS];

// Faction Vehicle Spawner & Duty
new PlayerFactionVeh[MAX_PLAYERS];
new CivilianSkin[MAX_PLAYERS];

// Driving School / DMV Exam
new bool:pInExam[MAX_PLAYERS];
new pExamCP[MAX_PLAYERS];
new pExamVehicle[MAX_PLAYERS];

// Admin Fly & God Mode
new bool:pFlyMode[MAX_PLAYERS];
new bool:pGodMode[MAX_PLAYERS];
new bool:pCuffed[MAX_PLAYERS];
new pSpecTarget[MAX_PLAYERS];

// Database Handle
new DB:gDB;
new gGlobalTimer;

// Phone System Variables
new CallRequest[MAX_PLAYERS];
new CallWith[MAX_PLAYERS];

// Taxi Fare System
new pTaxiFare[MAX_PLAYERS];
new pTaxiRider[MAX_PLAYERS];

// ============================================================================
//                          HOUSE SYSTEM
// ============================================================================
#define MAX_HOUSES              15
#define HOUSE_INT_ID            5
#define HOUSE_INT_WORLD_BASE    1000
#define HOUSE_INT_X             1299.14
#define HOUSE_INT_Y             -794.87
#define HOUSE_INT_Z             1084.0

enum E_HOUSE {
    hSlot,
    Float:hX,
    Float:hY,
    Float:hZ,
    hPrice,
    hOwner[MAX_PLAYER_NAME],
    hOwned,
    hPickup,
    Text3D:hLabel
};

new HouseInfo[MAX_HOUSES][E_HOUSE];

new const Float:HouseSpots[MAX_HOUSES][3] = {
    {2097.0, 2418.0, 10.82},
    {2088.0, 2312.0, 10.82},
    {1965.0, 2375.0, 10.82},
    {1930.0, 2415.0, 10.82},
    {2001.0, 2574.0, 10.82},
    {2065.0, 2608.0, 10.82},
    {2202.0, 2625.0, 10.82},
    {2265.0, 2650.0, 10.82},
    {2450.0, 1357.0, 10.82},
    {2510.0, 1290.0, 10.82},
    {2635.0, 1105.0, 10.82},
    {2670.0, 1290.0, 10.82},
    {1870.0, 2110.0, 10.82},
    {1740.0, 2205.0, 10.82},
    {1690.0, 2280.0, 10.82}
};

new const HousePrices[MAX_HOUSES] = {
    50000, 75000, 60000, 90000, 120000, 85000, 100000, 150000,
    70000, 95000, 80000, 110000, 65000, 130000, 200000
};

// Garbage Job Route (5 colectare points in Las Venturas)
new const Float:GarbageRoute[5][3] = {
    {2100.0, 2320.0, 10.82},
    {1940.0, 2160.0, 10.82},
    {2210.0, 2105.0, 10.82},
    {2385.0, 2465.0, 10.82},
    {2600.0, 2200.0, 10.82}
};

new const VehicleNames[212][32] = {
    "Landstalker","Bravura","Buffalo","Linerunner","Perennial","Sentinel","Dumper","Firetruck","Trashmaster","Stretch",
    "Manana","Infernus","Voodoo","Pony","Mule","Cheetah","Ambulance","Leviathan","Moonbeam","Esperanto",
    "Taxi","Washington","Bobcat","Mr Whoopee","BF Injection","Hunter","Premier","Enforcer","Securicar","Banshee",
    "Predator","Bus","Rhino","Barracks","Hotknife","Article Trailer 1","Previon","Coach","Cabbie","Stallion",
    "Rumpo","RC Bandit","Romero","Packer","Monster","Admiral","Squalo","Seasparrow","Pizzaboy","Tram",
    "Article Trailer 2","Turismo","Speeder","Reefer","Tropic","Flatbed","Yankee","Caddy","Solair","Topfun",
    "Skimmer","PCJ-600","Faggio","Freeway","RC Baron","RC Raider","Glendale","Oceanic","Sanchez","Sparrow",
    "Patriot","Quad","Coastguard","Dinghy","Hermes","Sabre","Rustler","ZR-350","Walton","Regina",
    "Comet","BMX","Burrito","Camper","Marquis","Baggage","Dozer","Maverick","News Chopper","Rancher",
    "FBI Rancher","Virgo","Greenwood","Jetmax","Hotring","Sandking","Blista Compact","Police Maverick","Boxville","Benson",
    "Mesa","RC Goblin","Hotring Racer A","Hotring Racer B","Bloodring Banger","Rancher Lure","Super GT","Elegant","Journey","Bike",
    "Mountain Bike","Beagle","Cropduster","Stuntplane","Tanker","Roadtrain","Nebula","Majestic","Buccaneer","Shamal",
    "Hydra","FCR-900","NRG-500","HPV1000","Cement Truck","Towtruck","Fortune","Cadrona","FBI Truck","Willard",
    "Forklift","Tractor","Combine","Feltzer","Remington","Slamvan","Blade","Freight","Streak","Vortex",
    "Vincent","Bullet","Clover","Sadler","Firetruck LA","Hustler","Intruder","Primo","Cargobob","Tampa",
    "Sunrise","Merit","Utility","Nevada","Yosemite","Windsor","Monster A","Monster B","Uranus","Jester",
    "Sultan","Stratum","Elegy","Raindance","RC Tiger","Flash","Tahoma","Savanna","Bandito","Freight Flat",
    "Streak Carriage","Kart","Mower","Dune","Sweeper","Broadway","Tornado","AT-400","DFT-30","Huntley",
    "Stafford","BF-400","Newsvan","Tug","Trailer 3","Emperor","Wayfarer","Euros","Hotdog","Club",
    "Freight Box","Trailer 4","Andromada","Dodo","RC Cam","Launch","Police Car (LSPD)","Police Car (SFPD)","Police Car (LVPD)","Police Ranger",
    "Picador","S.W.A.T.","Alpha","Phoenix","Glendale Damaged","Sadler Damaged","Luggage Trailer A","Luggage Trailer B","Stair Trailer","Boxville",
    "Farm Plow","Utility Trailer"
};

// Dealership Catalog
enum E_CATALOG {
    cModel,
    cName[32],
    cPrice,
    cCategory[20]
};

new const CarCatalog[][E_CATALOG] = {
    {462, "Faggio", 2500, "Motoare"},
    {463, "Freeway", 15000, "Motoare"},
    {522, "NRG-500", 95000, "Motoare"},
    {400, "Landstalker", 35000, "SUV"},
    {405, "Sentinel", 40000, "Sedan"},
    {410, "Manana", 12000, "Compact"},
    {411, "Infernus", 250000, "Supercar"},
    {415, "Cheetah", 180000, "Supercar"},
    {429, "Banshee", 150000, "Supercar"},
    {451, "Turismo", 220000, "Supercar"},
    {477, "ZR-350", 85000, "Sport"},
    {492, "Greenwood", 18000, "Sedan"},
    {541, "Bullet", 210000, "Supercar"},
    {560, "Sultan", 90000, "Sport"},
    {561, "Stratum", 32000, "Wagon"},
    {562, "Elegy", 95000, "Sport"},
    {579, "Huntley", 65000, "SUV"},
    {587, "Euros", 55000, "Sport"}
};

// Forward Declarations
forward OnGlobalUpdate();
forward OnPlayerSecondUpdate(playerid);
forward OnPayDay();

// ============================================================================
//                               MAIN & INIT
// ============================================================================

main() {
    print("--------------------------------------------------");
    print("    ROMANIA ROLEPLAY / REAL LIFE v1.3 LOADED      ");
    print("       Full Systems & Custom Roleplay UI          ");
    print("--------------------------------------------------");
}

public OnGameModeInit() {
    SetGameModeText("Romania RealLife v1.3");
    ShowNameTags(1);
    SetNameTagDrawDistance(35.0);
    EnableStuntBonusForAll(0);
    DisableInteriorEnterExits();
    ManualVehicleEngineAndLights();

    // Setup World & Time
    SetWorldTime(12);
    SetWeather(1);

    // Initialize Database
    InitDatabase();

    // Create World Map Additions & Spawns
    SetupWorldObjectsAndVehicles();

    // Initialize Vehicles Fuel and Event
    for(new v = 1; v < MAX_VEHICLES; v++) {
        VehicleFuel[v] = 100;
        VehicleEngine[v] = false;
        VehicleLights[v] = false;
        EventVehicle[v] = INVALID_VEHICLE_ID;
    }

    // 1. Server Branding Watermark Textdraw (Below Money HUD, no overlap)
    ServerLogoText = TextDrawCreate(498.0, 116.0, "~r~ROMANIA ~w~ROLEPLAY");
    TextDrawFont(ServerLogoText, 2);
    TextDrawLetterSize(ServerLogoText, 0.28, 1.15);
    TextDrawColor(ServerLogoText, 0xFFFFFFFF);
    TextDrawSetOutline(ServerLogoText, 1);
    TextDrawSetShadow(ServerLogoText, 0);

    // 2. Global Server Time Textdraw (Row 3 of Info Card)
    ServerTimeText = TextDrawCreate(498.0, 140.0, "~w~Ora: ~p~--:--:--");
    TextDrawFont(ServerTimeText, 1);
    TextDrawLetterSize(ServerTimeText, 0.20, 0.90);
    TextDrawColor(ServerTimeText, 0x00FFC4AA);
    TextDrawSetOutline(ServerTimeText, 1);
    TextDrawSetShadow(ServerTimeText, 0);

    // Global 1-second pulse timer
    gGlobalTimer = SetTimer("OnGlobalUpdate", 1000, true);

    print("[SERVER] Gamemode initialization complete.");
    return 1;
}

public OnGameModeExit() {
    KillTimer(gGlobalTimer);

    for(new i = 0; i < MAX_PLAYERS; i++) {
        if(IsPlayerConnected(i) && PlayerInfo[i][pLogged]) {
            SavePlayerData(i);
        }
    }

    if(gDB) {
        db_close(gDB);
    }

    print("[SERVER] Gamemode exited cleanly and database saved.");
    return 1;
}

// ============================================================================
//                              DATABASE ENGINE
// ============================================================================

InitDatabase() {
    gDB = db_open("server.db");
    if(!gDB) {
        print("[ERROR] Nu s-a putut deschide baza de date SQLite 'server.db'!");
        return;
    }

    // Players Table
    db_query(gDB, "CREATE TABLE IF NOT EXISTS players (\
        id INTEGER PRIMARY KEY AUTOINCREMENT,\
        name TEXT UNIQUE,\
        password TEXT,\
        money INTEGER DEFAULT 5000,\
        bank INTEGER DEFAULT 15000,\
        score INTEGER DEFAULT 1,\
        admin INTEGER DEFAULT 0,\
        vip INTEGER DEFAULT 0,\
        job INTEGER DEFAULT 0,\
        faction INTEGER DEFAULT 0,\
        skin INTEGER DEFAULT 26,\
        kills INTEGER DEFAULT 0,\
        deaths INTEGER DEFAULT 0,\
        hours INTEGER DEFAULT 0,\
        warns INTEGER DEFAULT 0,\
        jailed INTEGER DEFAULT 0,\
        jailtime INTEGER DEFAULT 0,\
        carlic INTEGER DEFAULT 1,\
        gunlic INTEGER DEFAULT 0,\
        wanted INTEGER DEFAULT 0,\
        crimes TEXT DEFAULT 'Niciuna',\
        raport INTEGER DEFAULT 0,\
        muted INTEGER DEFAULT 0,\
        mutetime INTEGER DEFAULT 0\
    );");

    // Add columns dynamically in case table already exists
    db_query(gDB, "ALTER TABLE players ADD COLUMN wanted INTEGER DEFAULT 0;");
    db_query(gDB, "ALTER TABLE players ADD COLUMN crimes TEXT DEFAULT 'Niciuna';");
    db_query(gDB, "ALTER TABLE players ADD COLUMN raport INTEGER DEFAULT 0;");
    db_query(gDB, "ALTER TABLE players ADD COLUMN muted INTEGER DEFAULT 0;");
    db_query(gDB, "ALTER TABLE players ADD COLUMN mutetime INTEGER DEFAULT 0;");
    db_query(gDB, "ALTER TABLE players ADD COLUMN factionrank INTEGER DEFAULT 0;");
    db_query(gDB, "ALTER TABLE players ADD COLUMN phone INTEGER DEFAULT 0;");
    db_query(gDB, "ALTER TABLE players ADD COLUMN house INTEGER DEFAULT -1;");
    db_query(gDB, "ALTER TABLE players ADD COLUMN tutorial INTEGER DEFAULT 0;");

    // Houses Table (slot fixe, proprietar salvat)
    db_query(gDB, "CREATE TABLE IF NOT EXISTS houses (\
        slot INTEGER PRIMARY KEY,\
        owner TEXT DEFAULT ''\
    );");

    // Personal Vehicles Table
    db_query(gDB, "CREATE TABLE IF NOT EXISTS vehicles (\
        id INTEGER PRIMARY KEY AUTOINCREMENT,\
        owner TEXT,\
        model INTEGER,\
        x REAL,\
        y REAL,\
        z REAL,\
        a REAL,\
        color1 INTEGER,\
        color2 INTEGER,\
        price INTEGER,\
        locked INTEGER DEFAULT 1,\
        plate TEXT\
    );");

    // Ensure atomk is permanently admin level 5 in database
    db_query(gDB, "UPDATE players SET admin = 5 WHERE name = 'atomk' COLLATE NOCASE;");

    print("[DATABASE] SQLite server.db a fost initializata cu succes.");
    LoadPersonalVehicles();
    LoadHouses();
}

SavePlayerData(playerid) {
    if(!PlayerInfo[playerid][pLogged]) return 0;

    new query[700];
    format(query, sizeof(query), "UPDATE players SET \
        money = %d, bank = %d, score = %d, admin = %d, vip = %d, job = %d, faction = %d, skin = %d,\
        kills = %d, deaths = %d, hours = %d, warns = %d, jailed = %d, jailtime = %d, carlic = %d, gunlic = %d,\
        wanted = %d, crimes = '%q', raport = %d, muted = %d, mutetime = %d, \
        factionrank = %d, phone = %d, house = %d, tutorial = %d \
        WHERE name = '%q';",
        GetPlayerMoney(playerid),
        PlayerInfo[playerid][pBank],
        GetPlayerScore(playerid),
        PlayerInfo[playerid][pAdmin],
        PlayerInfo[playerid][pVIP],
        PlayerInfo[playerid][pJob],
        PlayerInfo[playerid][pFaction],
        GetPlayerSkin(playerid),
        PlayerInfo[playerid][pKills],
        PlayerInfo[playerid][pDeaths],
        PlayerInfo[playerid][pHours],
        PlayerInfo[playerid][pWarns],
        PlayerInfo[playerid][pJailed],
        PlayerInfo[playerid][pJailTime],
        PlayerInfo[playerid][pCarLic],
        PlayerInfo[playerid][pGunLic],
        PlayerInfo[playerid][pWanted],
        PlayerInfo[playerid][pCrimes],
        PlayerInfo[playerid][pRaport],
        PlayerInfo[playerid][pMuted],
        PlayerInfo[playerid][pMuteTime],
        PlayerInfo[playerid][pFactionRank],
        PlayerInfo[playerid][pPhone],
        PlayerInfo[playerid][pHouse],
        PlayerInfo[playerid][pTutorial],
        PlayerInfo[playerid][pName]
    );

    db_query(gDB, query);
    return 1;
}

LoadPersonalVehicles() {
    new DBResult:res = db_query(gDB, "SELECT * FROM vehicles;");
    if(res) {
        new rows = db_num_rows(res);
        for(new i = 0; i < rows && i < MAX_PERSONAL_VEHICLES; i++) {
            new field[64];
            db_get_field_assoc(res, "id", field, sizeof(field));
            VehicleInfo[i][vID] = strval(field);

            db_get_field_assoc(res, "owner", VehicleInfo[i][vOwner], MAX_PLAYER_NAME);

            db_get_field_assoc(res, "model", field, sizeof(field));
            VehicleInfo[i][vModel] = strval(field);

            db_get_field_assoc(res, "x", field, sizeof(field));
            VehicleInfo[i][vX] = floatstr(field);

            db_get_field_assoc(res, "y", field, sizeof(field));
            VehicleInfo[i][vY] = floatstr(field);

            db_get_field_assoc(res, "z", field, sizeof(field));
            VehicleInfo[i][vZ] = floatstr(field);

            db_get_field_assoc(res, "a", field, sizeof(field));
            VehicleInfo[i][vA] = floatstr(field);

            db_get_field_assoc(res, "color1", field, sizeof(field));
            VehicleInfo[i][vColor1] = strval(field);

            db_get_field_assoc(res, "color2", field, sizeof(field));
            VehicleInfo[i][vColor2] = strval(field);

            db_get_field_assoc(res, "price", field, sizeof(field));
            VehicleInfo[i][vPrice] = strval(field);

            db_get_field_assoc(res, "locked", field, sizeof(field));
            VehicleInfo[i][vLocked] = strval(field);

            db_get_field_assoc(res, "plate", VehicleInfo[i][vPlate], 16);

            // Spawn car in world
            new veh = CreateVehicle(VehicleInfo[i][vModel], VehicleInfo[i][vX], VehicleInfo[i][vY], VehicleInfo[i][vZ], VehicleInfo[i][vA], VehicleInfo[i][vColor1], VehicleInfo[i][vColor2], -1);
            VehicleInfo[i][vServerID] = veh;
            VehicleInfo[i][vSpawned] = true;
            VehicleFuel[veh] = 100;
            VehicleEngine[veh] = false;
            SetVehicleNumberPlate(veh, VehicleInfo[i][vPlate]);

            if(VehicleInfo[i][vLocked]) {
                new engine, lights, alarm, doors, bonnet, boot, objective;
                GetVehicleParamsEx(veh, engine, lights, alarm, doors, bonnet, boot, objective);
                SetVehicleParamsEx(veh, engine, lights, alarm, 1, bonnet, boot, objective);
            }

            TotalPersonalVehicles++;
            db_next_row(res);
        }
        db_free_result(res);
        printf("[DATABASE] S-au incarcat %d vehicule personale din baza de date.", TotalPersonalVehicles);
    }
}

// ============================================================================
//                               MAP & STATIC CARS
// ============================================================================

SetupWorldObjectsAndVehicles() {
    // ========================================================================
    //               LAS VENTURAS MAP - 3D LABELS & KEY LOCATIONS
    // ========================================================================
    Create3DTextLabel("{00FF00}[ EMERALD ISLE CASINO & HOTEL ]\n{FFFFFF}Spawn Principal Server\n{FFFF00}/help {FFFFFF}pentru comenzi | {00FFFF}/gps", COLOR_WHITE, 2110.0, 2360.0, 11.5, 30.0, 0, 1);
    Create3DTextLabel("{0066FF}[ BANCOMAT - ATM EMERALD ISLE ]\n{FFFFFF}Tasteaza {FFFF00}/bank{FFFFFF} sau {FFFF00}/atm", COLOR_WHITE, 2112.0, 2365.0, 11.5, 20.0, 0, 1);
    Create3DTextLabel("{0066FF}[ BANCA LAS VENTURAS ]\n{FFFFFF}Tasteaza {FFFF00}/bank{FFFFFF} sau {FFFF00}/atm", COLOR_WHITE, 2006.0, 1018.0, 11.5, 25.0, 0, 1);
    Create3DTextLabel("{0044FF}[ SEDIU POLITIE - LVPD ]\n{FFFFFF}Tasteaza {FFFF00}/duty{FFFFFF} daca esti ofiter | {00FF00}/fveh", COLOR_WHITE, 2287.0, 2431.0, 11.5, 25.0, 0, 1);
    Create3DTextLabel("{FF3333}[ SPITALUL LAS VENTURAS ]\n{FFFFFF}Punct medical & recuperare | {FFFF00}/duty", COLOR_WHITE, 1607.0, 1816.0, 11.5, 25.0, 0, 1);
    Create3DTextLabel("{FFFF00}[ DEALERSHIP AUTO LAS VENTURAS ]\n{FFFFFF}Tasteaza {00FF00}/ds{FFFFFF} sau {00FF00}/buycar", COLOR_WHITE, 2130.0, 1395.0, 11.5, 25.0, 0, 1);
    Create3DTextLabel("{00FFFF}[ SCOALA DE SOFERI - DMV LV ]\n{FFFFFF}Tasteaza {FFFF00}/exam{FFFFFF} sau {FFFF00}/dmv {FFFFFF}pentru permis auto ($500)", COLOR_WHITE, 1098.0, 1375.0, 11.5, 25.0, 0, 1);
    Create3DTextLabel("{0033CC}[ BIROUL FEDERAL - FBI ]\n{FFFFFF}Sediu Federal Roca Escalante | {FFFF00}/duty", COLOR_WHITE, 2287.0, 2465.0, 11.5, 25.0, 0, 1);
    Create3DTextLabel("{FF9900}[ VILA MAFIA - STRIP SYNDICATE ]\n{FFFFFF}Teritoriul Familiei | {FFFF00}/duty", COLOR_WHITE, 2000.0, 1018.0, 11.5, 25.0, 0, 1);
    Create3DTextLabel("{990099}[ AGENTIA HITMAN ]\n{FFFFFF}Agentia Secreta Blackfield | {FFFF00}/duty", COLOR_WHITE, 1080.0, 1080.0, 11.5, 25.0, 0, 1);
    Create3DTextLabel("{FFFF00}[ SAN NEWS REPORTERS ]\n{FFFFFF}Sediu Stiri & Media LV | {FFFF00}/duty", COLOR_WHITE, 2635.0, 1180.0, 11.5, 25.0, 0, 1);
    Create3DTextLabel("{FFA500}[ DEPOZIT TIRISTI LV ]\n{FFFFFF}Tasteaza {FFFF00}/work{FFFFFF} pentru a livra marfa", COLOR_WHITE, 2755.0, 1350.0, 11.5, 25.0, 0, 1);
    Create3DTextLabel("{FF0000}[ PIZZERIA EMERALD ISLE ]\n{FFFFFF}Urca pe Faggio si tasteaza {FFFF00}/work", COLOR_WHITE, 2100.0, 2225.0, 11.5, 25.0, 0, 1);
    Create3DTextLabel("{00FF00}[ BENZINARIE THE STRIP ]\n{FFFFFF}Opreste masina si tasteaza {FFFF00}/fill", COLOR_WHITE, 2115.0, 920.0, 11.5, 20.0, 0, 1);
    Create3DTextLabel("{FF6600}[ MAGAZIN DE HAINE & SKIN ]\n{FFFFFF}Tasteaza {FFFF00}/skin {FFFFFF}sau {FFFF00}/clothes", COLOR_WHITE, 2050.0, 1020.0, 11.5, 20.0, 0, 1);

    // ========================================================================
    //               LAS VENTURAS - STATIC & FLEET VEHICLES
    // ========================================================================
    // Emerald Isle Parking Bays (Neatly parked in front of Emerald Isle plaza)
    CreateVehicle(405, 2120.0, 2380.0, 10.82, 180.0, 1, 1, 120); // Sentinel
    CreateVehicle(426, 2125.0, 2380.0, 10.82, 180.0, 1, 1, 120); // Premier
    CreateVehicle(560, 2130.0, 2380.0, 10.82, 180.0, 0, 0, 120); // Sultan
    CreateVehicle(462, 2135.0, 2380.0, 10.82, 180.0, 3, 3, 60);  // Faggio

    // LVPD Police Cars (Las Venturas Police Department HQ)
    CreateVehicle(596, 2275.0, 2435.0, 10.8, 90.0, 0, 1, 120);
    CreateVehicle(596, 2275.0, 2440.0, 10.8, 90.0, 0, 1, 120);
    CreateVehicle(596, 2275.0, 2445.0, 10.8, 90.0, 0, 1, 120);
    CreateVehicle(599, 2275.0, 2450.0, 10.8, 90.0, 0, 1, 120); // Police Ranger
    CreateVehicle(523, 2280.0, 2455.0, 10.8, 90.0, 0, 1, 120); // Police Bike
    CreateVehicle(427, 2295.0, 2435.0, 10.8, 180.0, 0, 1, 120);// Enforcer SWAT

    // Medical Ambulances (Las Venturas Medical Center)
    CreateVehicle(416, 1600.0, 1820.0, 10.8, 90.0, 1, 3, 120);
    CreateVehicle(416, 1600.0, 1825.0, 10.8, 90.0, 1, 3, 120);
    CreateVehicle(490, 1600.0, 1830.0, 10.8, 90.0, 1, 3, 120); // Paramedic Ranger

    // Driving School DMV Cars (Blackfield Stadium Driving Lot)
    CreateVehicle(405, 1090.0, 1365.0, 10.82, 0.0, 1, 1, 60);
    CreateVehicle(405, 1095.0, 1365.0, 10.82, 0.0, 1, 1, 60);
    CreateVehicle(410, 1100.0, 1365.0, 10.82, 0.0, 3, 3, 60);

    // Pizza Boy Faggios (Emerald Isle)
    CreateVehicle(448, 2095.0, 2225.0, 10.8, 0.0, 3, 6, 60);
    CreateVehicle(448, 2098.0, 2225.0, 10.8, 0.0, 3, 6, 60);
    CreateVehicle(448, 2102.0, 2225.0, 10.8, 0.0, 3, 6, 60);

    // Trucker Depot Vehicles (K.A.C.C. Las Venturas)
    CreateVehicle(515, 2750.0, 1345.0, 10.8, 180.0, 1, 1, 120); // Roadtrain
    CreateVehicle(515, 2760.0, 1345.0, 10.8, 180.0, 1, 1, 120);
    CreateVehicle(435, 2750.0, 1365.0, 10.8, 180.0, 1, 1, 120); // Trailer
    CreateVehicle(435, 2760.0, 1365.0, 10.8, 180.0, 1, 1, 120);

    // Cabs / Taxi (Starfish Casino Depot)
    CreateVehicle(420, 2145.0, 1600.0, 10.8, 90.0, 6, 6, 60);
    CreateVehicle(420, 2145.0, 1605.0, 10.8, 90.0, 6, 6, 60);

    // Garbage Trucks (Linden Station)
    CreateVehicle(408, 2805.0, 970.0, 10.8, 270.0, 16, 16, 120);
    CreateVehicle(408, 2805.0, 975.0, 10.8, 270.0, 16, 16, 120);

    // Tow Trucks (Mecanici)
    CreateVehicle(525, 2815.0, 970.0, 10.8, 270.0, 1, 1, 60);
    CreateVehicle(525, 2815.0, 975.0, 10.8, 270.0, 1, 1, 60);
}

// ============================================================================
//                          PLAYER CONNECTION & AUTH
// ============================================================================

public OnPlayerConnect(playerid) {
    GetPlayerName(playerid, PlayerInfo[playerid][pName], MAX_PLAYER_NAME);

    // Reset Player Variables
    PlayerInfo[playerid][pID] = playerid;
    PlayerInfo[playerid][pLogged] = false;
    PlayerInfo[playerid][pAdmin] = 0;
    PlayerInfo[playerid][pVIP] = 0;
    PlayerInfo[playerid][pMoney] = 5000;
    PlayerInfo[playerid][pBank] = 15000;
    PlayerInfo[playerid][pScore] = 1;
    PlayerInfo[playerid][pJob] = 0;
    PlayerInfo[playerid][pFaction] = 0;
    PlayerInfo[playerid][pDuty] = 0;
    PlayerInfo[playerid][pSkin] = 26;
    PlayerInfo[playerid][pKills] = 0;
    PlayerInfo[playerid][pDeaths] = 0;
    PlayerInfo[playerid][pHours] = 0;
    PlayerInfo[playerid][pWarns] = 0;
    PlayerInfo[playerid][pJailed] = 0;
    PlayerInfo[playerid][pJailTime] = 0;
    PlayerInfo[playerid][pCarLic] = 1;
    PlayerInfo[playerid][pGunLic] = 0;
    PlayerInfo[playerid][pCP] = 0;
    PlayerInfo[playerid][pWorkStage] = 0;
    PlayerInfo[playerid][pWorkVehicle] = 0;
    PlayerInfo[playerid][pWorkTrailer] = 0;

    PlayerInfo[playerid][pWanted] = 0;
    format(PlayerInfo[playerid][pCrimes], 64, "Niciuna");
    PlayerInfo[playerid][pRaport] = 0;
    PlayerInfo[playerid][pMuted] = 0;
    PlayerInfo[playerid][pMuteTime] = 0;
    PlayerInfo[playerid][pPhone] = 0;
    PlayerInfo[playerid][pHouse] = -1;
    PlayerInfo[playerid][pTutorial] = 0;
    pCuffed[playerid] = false;
    pSpecTarget[playerid] = INVALID_PLAYER_ID;
    CallRequest[playerid] = INVALID_PLAYER_ID;
    CallWith[playerid] = INVALID_PLAYER_ID;
    pTaxiFare[playerid] = 0;
    pTaxiRider[playerid] = INVALID_PLAYER_ID;

    // Check if player is atomk -> Automatically set Level 5 Owner
    if(!strcmp(PlayerInfo[playerid][pName], "atomk", true)) {
        PlayerInfo[playerid][pAdmin] = 5;
    }

    // Initialize Variables for Player
    DiceChallenger[playerid] = INVALID_PLAYER_ID;
    DiceBet[playerid] = 0;
    pInEvent[playerid] = false;
    EventVehicle[playerid] = INVALID_VEHICLE_ID;

    // 1. Semi-transparent Dark Glass Box for HUD Card (Placed below Money counter)
    RoleplayBoxTD[playerid] = CreatePlayerTextDraw(playerid, 492.0, 114.0, "_");
    PlayerTextDrawFont(playerid, RoleplayBoxTD[playerid], 1);
    PlayerTextDrawLetterSize(playerid, RoleplayBoxTD[playerid], 0.0, 4.3);
    PlayerTextDrawUseBox(playerid, RoleplayBoxTD[playerid], 1);
    PlayerTextDrawBoxColor(playerid, RoleplayBoxTD[playerid], 0x00000088); // Sleek Dark Glass
    PlayerTextDrawTextSize(playerid, RoleplayBoxTD[playerid], 615.0, 0.0);
    PlayerTextDrawShow(playerid, RoleplayBoxTD[playerid]);

    // Show Global Watermark & Clock
    TextDrawShowForPlayer(playerid, ServerLogoText);
    TextDrawShowForPlayer(playerid, ServerTimeText);

    // 2. Roleplay HUD TextDraw (Row 2 of Info Card: play.romaniarl.ro | ID)
    RoleplayHudTD[playerid] = CreatePlayerTextDraw(playerid, 498.0, 129.0, "~y~play.romaniarl.ro ~w~| ID: ~g~0");
    PlayerTextDrawFont(playerid, RoleplayHudTD[playerid], 1);
    PlayerTextDrawLetterSize(playerid, RoleplayHudTD[playerid], 0.20, 0.90);
    PlayerTextDrawColor(playerid, RoleplayHudTD[playerid], 0xFFFFFFFF);
    PlayerTextDrawSetOutline(playerid, RoleplayHudTD[playerid], 1);
    PlayerTextDrawShow(playerid, RoleplayHudTD[playerid]);

    new idStr[64];
    format(idStr, sizeof(idStr), "~y~play.romaniarl.ro ~w~| ID: ~g~%d", playerid);
    PlayerTextDrawSetString(playerid, RoleplayHudTD[playerid], idStr);

    // 3. Modern Roleplay Speedometer UI (Bottom Right)
    SpeedoBoxTD[playerid] = CreatePlayerTextDraw(playerid, 480.0, 355.0, "_");
    PlayerTextDrawFont(playerid, SpeedoBoxTD[playerid], 1);
    PlayerTextDrawLetterSize(playerid, SpeedoBoxTD[playerid], 0.0, 9.2);
    PlayerTextDrawUseBox(playerid, SpeedoBoxTD[playerid], 1);
    PlayerTextDrawBoxColor(playerid, SpeedoBoxTD[playerid], 0x00000099); // Dark Glass Box
    PlayerTextDrawTextSize(playerid, SpeedoBoxTD[playerid], 620.0, 0.0);

    SpeedoInfoTD[playerid] = CreatePlayerTextDraw(playerid, 485.0, 360.0, "SPEEDO");
    PlayerTextDrawFont(playerid, SpeedoInfoTD[playerid], 1);
    PlayerTextDrawLetterSize(playerid, SpeedoInfoTD[playerid], 0.23, 1.05);
    PlayerTextDrawColor(playerid, SpeedoInfoTD[playerid], 0xFFFFFFFF);
    PlayerTextDrawSetOutline(playerid, SpeedoInfoTD[playerid], 1);

    // Set clean spawn at Emerald Isle Casino & Hotel
    SetSpawnInfo(playerid, 0, 26, 2110.0, 2360.0, 10.82, 90.0, 0, 0, 0, 0, 0, 0);

    // Check Account in DB
    new query[256];
    format(query, sizeof(query), "SELECT id, password, admin FROM players WHERE name = '%q' LIMIT 1;", PlayerInfo[playerid][pName]);
    new DBResult:res = db_query(gDB, query);

    if(res && db_num_rows(res) > 0) {
        new field[64];
        db_get_field_assoc(res, "id", field, sizeof(field));
        PlayerInfo[playerid][pID] = strval(field);

        db_get_field_assoc(res, "password", PlayerInfo[playerid][pPassword], 65);

        db_get_field_assoc(res, "admin", field, sizeof(field));
        PlayerInfo[playerid][pAdmin] = strval(field);

        if(!strcmp(PlayerInfo[playerid][pName], "atomk", true)) {
            PlayerInfo[playerid][pAdmin] = 5;
        }

        db_free_result(res);

        new dialogMsg[350];
        format(dialogMsg, sizeof(dialogMsg), "{FFFFFF}Bine ai revenit pe {FF0000}Romania {FFFFFF}Roleplay, {FFFF00}%s{FFFFFF}!\n\nIntrodu parola contului tau pentru a te autentifica:\n\n{AAAAAA}* Parola este criptata si securizata.", PlayerInfo[playerid][pName]);
        ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "{0066FF}» Autentificare Cont", dialogMsg, "Login", "Iesi");
    } else {
        if(res) db_free_result(res);

        new dialogMsg[400];
        format(dialogMsg, sizeof(dialogMsg), "{FFFFFF}Bun venit pe serverul {FF0000}Romania {FFFFFF}Roleplay, {FFFF00}%s{FFFFFF}!\n\nAcest cont nu este inca inregistrat in baza noastra de date.\nTe rugam sa introduci o parola pentru a-ti crea noul cont:\n\n{00FF00}* Vei primi un pachet de bun venit: $5,000 cash si $15,000 in banca!", PlayerInfo[playerid][pName]);
        ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_INPUT, "{00FF00}» Creare Cont Nou", dialogMsg, "Inregistrare", "Iesi");
    }

    return 1;
}

public OnPlayerDisconnect(playerid, reason) {
    if(PlayerInfo[playerid][pLogged]) {
        SavePlayerData(playerid);
    }

    // Inchide apelul activ si anuleaza cererile de apel
    EndPhoneCall(playerid);
    if(CallRequest[playerid] != INVALID_PLAYER_ID && IsPlayerConnected(CallRequest[playerid])) {
        SendClientMessage(CallRequest[playerid], COLOR_YELLOW, "[TELEFON] Persoana pe care o sunai s-a deconectat.");
    }
    CallRequest[playerid] = INVALID_PLAYER_ID;
    pTaxiFare[playerid] = 0;
    pTaxiRider[playerid] = INVALID_PLAYER_ID;

    if(PlayerInfo[playerid][pWorkVehicle]) {
        DestroyVehicle(PlayerInfo[playerid][pWorkVehicle]);
        PlayerInfo[playerid][pWorkVehicle] = 0;
    }
    if(PlayerInfo[playerid][pWorkTrailer]) {
        DestroyVehicle(PlayerInfo[playerid][pWorkTrailer]);
        PlayerInfo[playerid][pWorkTrailer] = 0;
    }

    PlayerTextDrawDestroy(playerid, SpeedoBoxTD[playerid]);
    PlayerTextDrawDestroy(playerid, SpeedoInfoTD[playerid]);
    PlayerTextDrawDestroy(playerid, RoleplayHudTD[playerid]);
    return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
    switch(dialogid) {
        case DIALOG_REGISTER: {
            if(!response) return Kick(playerid);
            if(strlen(inputtext) < 4) {
                ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_INPUT, "{FF0000}Eroare Parola", "Parola este prea scurta! Introdu minim 4 caractere:", "Inregistrare", "Iesi");
                return 1;
            }

            new adminLevel = 0;
            // Check if user is atomk or first user
            if(!strcmp(PlayerInfo[playerid][pName], "atomk", true)) {
                adminLevel = 5;
            } else {
                new DBResult:resCheck = db_query(gDB, "SELECT count(*) AS total FROM players;");
                if(resCheck) {
                    new field[16];
                    db_get_field_assoc(resCheck, "total", field, sizeof(field));
                    if(strval(field) == 0) {
                        adminLevel = 5;
                    }
                    db_free_result(resCheck);
                }
            }

            new query[512];
            format(query, sizeof(query), "INSERT INTO players (name, password, admin, money, bank, score, skin, wanted, crimes, raport, muted, mutetime) VALUES ('%q', '%q', %d, 5000, 15000, 1, 26, 0, 'Niciuna', 0, 0, 0);",
                PlayerInfo[playerid][pName], inputtext, adminLevel
            );
            db_query(gDB, query);

            PlayerInfo[playerid][pLogged] = true;
            PlayerInfo[playerid][pAdmin] = adminLevel;
            PlayerInfo[playerid][pMoney] = 5000;
            PlayerInfo[playerid][pBank] = 15000;
            PlayerInfo[playerid][pScore] = 1;
            PlayerInfo[playerid][pSkin] = 26;
            PlayerInfo[playerid][pWanted] = 0;
            format(PlayerInfo[playerid][pCrimes], 64, "Niciuna");
            PlayerInfo[playerid][pRaport] = 0;
            PlayerInfo[playerid][pMuted] = 0;
            PlayerInfo[playerid][pMuteTime] = 0;

            GivePlayerMoney(playerid, 5000);
            SetPlayerScore(playerid, 1);
            CivilianSkin[playerid] = 26;
            SetSpawnInfo(playerid, 0, 26, 2110.0, 2360.0, 10.82, 90.0, 0, 0, 0, 0, 0, 0);
            SpawnPlayer(playerid);

            SetPlayerCameraPos(playerid, 2085.0, 2330.0, 30.0);
            SetPlayerCameraLookAt(playerid, 2110.0, 2360.0, 10.82);

            // Start the full 5-step interactive tutorial
            PlayerInfo[playerid][pTutorial] = 1;
            SendClientMessage(playerid, COLOR_CYAN, "==========================================================");
            SendClientMessage(playerid, COLOR_GOLD, "[TUTORIAL] Bun venit! Tutorialul interactiv incepe acum...");
            SendClientMessage(playerid, COLOR_CYAN, "==========================================================");

            ShowPlayerDialog(playerid, DIALOG_TUTORIAL_2, DIALOG_STYLE_MSGBOX, "{00FF00}Tutorial 1/5 - Bine ai venit in Las Venturas!",
                "{FFFFFF}Bun venit pe {00FF00}Romania RealLife - Las Venturas{FFFFFF}!\n\n\
                Aici te distrezi roleplay intr-un oras plin de oportunitati:\n\n\
                {FFFF00}*{FFFFFF} Joburi (Tirist, Pizza, Taxi, Gunoier) pentru bani\n\
                {FFFF00}*{FFFFFF} Case de cumparat pe tot mapul\n\
                {FFFF00}*{FFFFFF} Factiuni (Politia, SMURD, FBI, Mafia...)\n\
                {FFFF00}*{FFFFFF} Vehicule personale cu dealership auto\n\
                {FFFF00}*{FFFFFF} Telefoane, ATM-uri, events saptamanale\n\n\
                {00FF00}Vrei sa afli mai multe despre joburi acum?{FFFFFF}",
                "Da, despre joburi", "Mai tarziu"
            );

            SendClientMessage(playerid, COLOR_GREEN, "[CONT] Te-ai inregistrat cu succes! Ai primit $5,000 cash si $15,000 in banca.");
            if(adminLevel == 5) {
                SendClientMessage(playerid, COLOR_ADMIN, "[OWNER] Felicitari! Ai primit automat acces de OWNER (Admin Level 5)!");
            }
            return 1;
        }

        case DIALOG_LOGIN: {
            if(!response) return Kick(playerid);

            if(strcmp(inputtext, PlayerInfo[playerid][pPassword]) != 0) {
                ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "{FF0000}Parola Incorecta", "Parola introdusa este gresita! Incearca din nou:", "Login", "Iesi");
                return 1;
            }

            // Load full player data
            new query[256];
            format(query, sizeof(query), "SELECT * FROM players WHERE name = '%q' LIMIT 1;", PlayerInfo[playerid][pName]);
            new DBResult:res = db_query(gDB, query);
            if(res && db_num_rows(res) > 0) {
                new field[64];
                db_get_field_assoc(res, "money", field, sizeof(field)); PlayerInfo[playerid][pMoney] = strval(field);
                db_get_field_assoc(res, "bank", field, sizeof(field)); PlayerInfo[playerid][pBank] = strval(field);
                db_get_field_assoc(res, "score", field, sizeof(field)); PlayerInfo[playerid][pScore] = strval(field);
                db_get_field_assoc(res, "admin", field, sizeof(field)); PlayerInfo[playerid][pAdmin] = strval(field);
                db_get_field_assoc(res, "vip", field, sizeof(field)); PlayerInfo[playerid][pVIP] = strval(field);
                db_get_field_assoc(res, "job", field, sizeof(field)); PlayerInfo[playerid][pJob] = strval(field);
                db_get_field_assoc(res, "faction", field, sizeof(field)); PlayerInfo[playerid][pFaction] = strval(field);
                db_get_field_assoc(res, "skin", field, sizeof(field)); PlayerInfo[playerid][pSkin] = strval(field); CivilianSkin[playerid] = PlayerInfo[playerid][pSkin];
                db_get_field_assoc(res, "kills", field, sizeof(field)); PlayerInfo[playerid][pKills] = strval(field);
                db_get_field_assoc(res, "deaths", field, sizeof(field)); PlayerInfo[playerid][pDeaths] = strval(field);
                db_get_field_assoc(res, "hours", field, sizeof(field)); PlayerInfo[playerid][pHours] = strval(field);
                db_get_field_assoc(res, "warns", field, sizeof(field)); PlayerInfo[playerid][pWarns] = strval(field);
                db_get_field_assoc(res, "jailed", field, sizeof(field)); PlayerInfo[playerid][pJailed] = strval(field);
                db_get_field_assoc(res, "jailtime", field, sizeof(field)); PlayerInfo[playerid][pJailTime] = strval(field);
                db_get_field_assoc(res, "carlic", field, sizeof(field)); PlayerInfo[playerid][pCarLic] = strval(field);
                db_get_field_assoc(res, "gunlic", field, sizeof(field)); PlayerInfo[playerid][pGunLic] = strval(field);
                db_get_field_assoc(res, "wanted", field, sizeof(field)); PlayerInfo[playerid][pWanted] = strval(field);
                db_get_field_assoc(res, "crimes", PlayerInfo[playerid][pCrimes], 64);
                db_get_field_assoc(res, "raport", field, sizeof(field)); PlayerInfo[playerid][pRaport] = strval(field);
                db_get_field_assoc(res, "muted", field, sizeof(field)); PlayerInfo[playerid][pMuted] = strval(field);
                db_get_field_assoc(res, "mutetime", field, sizeof(field)); PlayerInfo[playerid][pMuteTime] = strval(field);
                db_get_field_assoc(res, "factionrank", field, sizeof(field)); PlayerInfo[playerid][pFactionRank] = strval(field);
                db_get_field_assoc(res, "phone", field, sizeof(field)); PlayerInfo[playerid][pPhone] = strval(field);
                db_get_field_assoc(res, "house", field, sizeof(field)); PlayerInfo[playerid][pHouse] = strval(field);
                db_get_field_assoc(res, "tutorial", field, sizeof(field)); PlayerInfo[playerid][pTutorial] = strval(field);
                db_free_result(res);
            }

            // Always enforce level 5 for atomk
            if(!strcmp(PlayerInfo[playerid][pName], "atomk", true)) {
                PlayerInfo[playerid][pAdmin] = 5;
                db_query(gDB, "UPDATE players SET admin = 5 WHERE name = 'atomk' COLLATE NOCASE;");
            }

            PlayerInfo[playerid][pLogged] = true;
            ResetPlayerMoney(playerid);
            GivePlayerMoney(playerid, PlayerInfo[playerid][pMoney]);
            SetPlayerScore(playerid, PlayerInfo[playerid][pScore]);

            if(PlayerInfo[playerid][pJailed]) {
                SetSpawnInfo(playerid, 0, PlayerInfo[playerid][pSkin], 264.0, 77.0, 1001.0, 0.0, 0, 0, 0, 0, 0, 0);
                SetPlayerInterior(playerid, 6);
                SendClientMessage(playerid, COLOR_RED, "[JAIL] Esti inca in inchisoare! Ispaseste-ti pedeapsa.");
            } else {
                SetSpawnInfo(playerid, 0, PlayerInfo[playerid][pSkin], 2110.0, 2360.0, 10.82, 90.0, 0, 0, 0, 0, 0, 0);
            }

            SpawnPlayer(playerid);
            SendClientMessage(playerid, COLOR_GREEN, "[CONT] Te-ai autentificat cu succes!");
            if(PlayerInfo[playerid][pAdmin] > 0) {
                new adminMsg[128];
                format(adminMsg, sizeof(adminMsg), "[STAFF] Conectat ca %s (Level %d). Tasteaza /ahelp pentru comenzi.", GetAdminRank(PlayerInfo[playerid][pAdmin]), PlayerInfo[playerid][pAdmin]);
                SendClientMessage(playerid, COLOR_ADMIN, adminMsg);
            }
            return 1;
        }

        case DIALOG_BANK: {
            if(!response) return 1;
            switch(listitem) {
                case 0: ShowPlayerDialog(playerid, DIALOG_BANK_DEPOSIT, DIALOG_STYLE_INPUT, "{0066FF}Banca - Depunere Numerar", "{FFFFFF}Introdu suma pe care doresti sa o depui in cont:", "Depune", "Inapoi");
                case 1: ShowPlayerDialog(playerid, DIALOG_BANK_WITHDRAW, DIALOG_STYLE_INPUT, "{0066FF}Banca - Retragere Numerar", "{FFFFFF}Introdu suma pe care doresti sa o retragi:", "Retrage", "Inapoi");
                case 2: ShowPlayerDialog(playerid, DIALOG_BANK_TRANSFER, DIALOG_STYLE_INPUT, "{0066FF}Banca - Transfer Bancar", "{FFFFFF}Introdu {FFFF00}[ID_Jucator] [Suma]{FFFFFF} separate prin spatiu:", "Transfera", "Inapoi");
            }
            return 1;
        }

        case DIALOG_BANK_DEPOSIT: {
            if(!response) return 1;
            new amount = strval(inputtext);
            if(amount <= 0) return SendClientMessage(playerid, COLOR_RED, "[BANCA] Suma introdusa este invalida!");
            if(GetPlayerMoney(playerid) < amount) return SendClientMessage(playerid, COLOR_RED, "[BANCA] Nu ai destui bani la tine!");

            GivePlayerMoney(playerid, -amount);
            PlayerInfo[playerid][pBank] += amount;
            PlayerInfo[playerid][pMoney] = GetPlayerMoney(playerid);

            new msg[128];
            format(msg, sizeof(msg), "[BANCA] Ai depus $%d in cont. Sold bancar: $%d.", amount, PlayerInfo[playerid][pBank]);
            SendClientMessage(playerid, COLOR_GREEN, msg);
            SavePlayerData(playerid);
            return 1;
        }

        case DIALOG_BANK_WITHDRAW: {
            if(!response) return 1;
            new amount = strval(inputtext);
            if(amount <= 0) return SendClientMessage(playerid, COLOR_RED, "[BANCA] Suma introdusa este invalida!");
            if(PlayerInfo[playerid][pBank] < amount) return SendClientMessage(playerid, COLOR_RED, "[BANCA] Nu ai destui bani in contul bancar!");

            PlayerInfo[playerid][pBank] -= amount;
            GivePlayerMoney(playerid, amount);
            PlayerInfo[playerid][pMoney] = GetPlayerMoney(playerid);

            new msg[128];
            format(msg, sizeof(msg), "[BANCA] Ai retras $%d. Sold ramas: $%d.", amount, PlayerInfo[playerid][pBank]);
            SendClientMessage(playerid, COLOR_GREEN, msg);
            SavePlayerData(playerid);
            return 1;
        }

        case DIALOG_BANK_TRANSFER: {
            if(!response) return 1;
            new targetid, amount;
            if(sscanf_custom(inputtext, targetid, amount) && amount > 0) {
                if(!IsPlayerConnected(targetid) || !PlayerInfo[targetid][pLogged]) {
                    return SendClientMessage(playerid, COLOR_RED, "[BANCA] Jucatorul specificat nu este online!");
                }
                if(targetid == playerid) return SendClientMessage(playerid, COLOR_RED, "[BANCA] Nu iti poti transfera bani tie!");
                if(PlayerInfo[playerid][pBank] < amount) return SendClientMessage(playerid, COLOR_RED, "[BANCA] Nu ai destui bani in banca!");

                PlayerInfo[playerid][pBank] -= amount;
                PlayerInfo[targetid][pBank] += amount;

                new msg[128];
                format(msg, sizeof(msg), "[BANCA] I-ai transferat lui %s suma de $%d.", PlayerInfo[targetid][pName], amount);
                SendClientMessage(playerid, COLOR_GREEN, msg);

                format(msg, sizeof(msg), "[BANCA] Ai primit un transfer de $%d de la %s.", amount, PlayerInfo[playerid][pName]);
                SendClientMessage(targetid, COLOR_GREEN, msg);

                SavePlayerData(playerid);
                SavePlayerData(targetid);
            } else {
                SendClientMessage(playerid, COLOR_RED, "[BANCA] Format incorect! Foloseste: ID Suma");
            }
            return 1;
        }

        case DIALOG_GPS: {
            if(!response) return 1;
            switch(listitem) {
                case 0: SetPlayerCheckpoint(playerid, 2110.0, 2360.0, 10.82, 4.0); // Emerald Isle Casino & Hotel (Spawn)
                case 1: SetPlayerCheckpoint(playerid, 2006.0, 1018.0, 10.82, 4.0); // Banca LV
                case 2: SetPlayerCheckpoint(playerid, 2287.0, 2431.0, 10.82, 4.0); // LVPD
                case 3: SetPlayerCheckpoint(playerid, 1607.0, 1816.0, 10.82, 4.0); // Spital LV
                case 4: SetPlayerCheckpoint(playerid, 2130.0, 1395.0, 10.82, 4.0); // Dealership LV
                case 5: SetPlayerCheckpoint(playerid, 1098.0, 1375.0, 10.82, 4.0); // Scoala de Soferi (DMV Blackfield)
                case 6: SetPlayerCheckpoint(playerid, 2287.0, 2465.0, 10.82, 4.0); // Sediu FBI
                case 7: SetPlayerCheckpoint(playerid, 2000.0, 1018.0, 10.82, 4.0); // Vila Mafia Strip
                case 8: SetPlayerCheckpoint(playerid, 1080.0, 1080.0, 10.82, 4.0); // Agentia Hitman
                case 9: SetPlayerCheckpoint(playerid, 2635.0, 1180.0, 10.82, 4.0); // San News Reporters
                case 10: SetPlayerCheckpoint(playerid, 2755.0, 1350.0, 10.82, 4.0); // Depozit Tiristi LV
                case 11: SetPlayerCheckpoint(playerid, 2100.0, 2225.0, 10.82, 4.0); // Pizzeria Emerald Isle
                case 12: SetPlayerCheckpoint(playerid, 2150.0, 1600.0, 10.82, 4.0); // Depozit Taxi Starfish
                case 13: SetPlayerCheckpoint(playerid, 2810.0, 970.0, 10.82, 4.0);  // Depozit Gunoi & Towing
                case 14: SetPlayerCheckpoint(playerid, 2115.0, 920.0, 10.82, 4.0);  // Benzinarie The Strip
                case 15: SetPlayerCheckpoint(playerid, 2050.0, 1020.0, 10.82, 4.0); // Magazin Haine / Skin
            }
            SendClientMessage(playerid, COLOR_YELLOW, "[GPS] Locatia a fost marcata pe radar cu un cerc rosu!");
            return 1;
        }

        case DIALOG_DEALERSHIP: {
            if(!response) return 1;
            new idx = listitem;
            if(idx < 0 || idx >= sizeof(CarCatalog)) return 1;

            new price = CarCatalog[idx][cPrice];
            if(PlayerInfo[playerid][pBank] < price) {
                new err[128];
                format(err, sizeof(err), "[DEALERSHIP] Nu ai destui bani in contul bancar! Pretul este $%d.", price);
                return SendClientMessage(playerid, COLOR_RED, err);
            }

            // Buy Car
            PlayerInfo[playerid][pBank] -= price;
            SavePlayerData(playerid);

            new Float:x = 2145.0, Float:y = 1395.0, Float:z = 10.82, Float:a = 90.0;
            new newPlate[16];
            format(newPlate, sizeof(newPlate), "RO-%04d", random(9000) + 1000);

            new query[512];
            format(query, sizeof(query), "INSERT INTO vehicles (owner, model, x, y, z, a, color1, color2, price, locked, plate) VALUES ('%q', %d, %f, %f, %f, %f, 1, 1, %d, 1, '%s');",
                PlayerInfo[playerid][pName], CarCatalog[idx][cModel], x, y, z, a, price, newPlate
            );
            db_query(gDB, query);

            new veh = CreateVehicle(CarCatalog[idx][cModel], x, y, z, a, 1, 1, -1);
            VehicleFuel[veh] = 100;
            VehicleEngine[veh] = false;
            SetVehicleNumberPlate(veh, newPlate);

            if(TotalPersonalVehicles < MAX_PERSONAL_VEHICLES) {
                VehicleInfo[TotalPersonalVehicles][vModel] = CarCatalog[idx][cModel];
                format(VehicleInfo[TotalPersonalVehicles][vOwner], MAX_PLAYER_NAME, "%s", PlayerInfo[playerid][pName]);
                VehicleInfo[TotalPersonalVehicles][vX] = x;
                VehicleInfo[TotalPersonalVehicles][vY] = y;
                VehicleInfo[TotalPersonalVehicles][vZ] = z;
                VehicleInfo[TotalPersonalVehicles][vA] = a;
                VehicleInfo[TotalPersonalVehicles][vPrice] = price;
                VehicleInfo[TotalPersonalVehicles][vLocked] = 1;
                format(VehicleInfo[TotalPersonalVehicles][vPlate], 16, "%s", newPlate);
                VehicleInfo[TotalPersonalVehicles][vServerID] = veh;
                VehicleInfo[TotalPersonalVehicles][vSpawned] = true;
                TotalPersonalVehicles++;
            }

            new msg[144];
            format(msg, sizeof(msg), "[DEALERSHIP] Felicitari! Ai achizitionat un %s pentru $%d. Masina te asteapta afara.", CarCatalog[idx][cName], price);
            SendClientMessage(playerid, COLOR_GREEN, msg);
            SendClientMessage(playerid, COLOR_YELLOW, "[VEHICUL] Foloseste {FFFFFF}/lock{FFFF00} pentru a incuia usile si {FFFFFF}/v{FFFF00} pentru optiuni.");
            return 1;
        }

        case DIALOG_STORE: {
            if(!response) return 1;
            switch(listitem) {
                case 0: {
                    if(GetPlayerMoney(playerid) < 150) return SendClientMessage(playerid, COLOR_RED, "Nu ai destui bani!");
                    GivePlayerMoney(playerid, -150);
                    SetPlayerHealth(playerid, 100.0);
                    SendClientMessage(playerid, COLOR_GREEN, "Ai cumparat o Trusa Medicala si ti-ai refacut viata!");
                }
                case 1: {
                    if(GetPlayerMoney(playerid) < 250) return SendClientMessage(playerid, COLOR_RED, "Nu ai destui bani!");
                    GivePlayerMoney(playerid, -250);
                    SendClientMessage(playerid, COLOR_GREEN, "Ai cumparat o Canistra de Benzina!");
                }
                case 2: {
                    if(GetPlayerMoney(playerid) < 500) return SendClientMessage(playerid, COLOR_RED, "Nu ai destui bani!");
                    if(PlayerInfo[playerid][pPhone]) return SendClientMessage(playerid, COLOR_RED, "Ai deja un telefon!");
                    GivePlayerMoney(playerid, -500);
                    PlayerInfo[playerid][pMoney] = GetPlayerMoney(playerid);
                    PlayerInfo[playerid][pPhone] = 1;
                    SavePlayerData(playerid);
                    SendClientMessage(playerid, COLOR_GREEN, "Ai cumparat un Telefon Mobil! Numarul tau este 1xx. Foloseste /phone, /call, /sms.");
                }
            }
            return 1;
        }

        case DIALOG_AMMU: {
            if(!response) return 1;
            if(!PlayerInfo[playerid][pGunLic]) {
                return SendClientMessage(playerid, COLOR_RED, "[AMMU] Nu detii permis de port-arma!");
            }
            switch(listitem) {
                case 0: {
                    if(GetPlayerMoney(playerid) < 1000) return SendClientMessage(playerid, COLOR_RED, "Nu ai destui bani!");
                    GivePlayerMoney(playerid, -1000);
                    GivePlayerWeapon(playerid, 22, 100);
                    SendClientMessage(playerid, COLOR_GREEN, "Ai cumparat un 9mm Pistol cu 100 gloante!");
                }
                case 1: {
                    if(GetPlayerMoney(playerid) < 3500) return SendClientMessage(playerid, COLOR_RED, "Nu ai destui bani!");
                    GivePlayerMoney(playerid, -3500);
                    GivePlayerWeapon(playerid, 24, 75);
                    SendClientMessage(playerid, COLOR_GREEN, "Ai cumparat un Desert Eagle cu 75 gloante!");
                }
                case 2: {
                    if(GetPlayerMoney(playerid) < 2500) return SendClientMessage(playerid, COLOR_RED, "Nu ai destui bani!");
                    GivePlayerMoney(playerid, -2500);
                    GivePlayerWeapon(playerid, 25, 50);
                    SendClientMessage(playerid, COLOR_GREEN, "Ai cumparat un Shotgun cu 50 cartuse!");
                }
                case 3: {
                    if(GetPlayerMoney(playerid) < 4000) return SendClientMessage(playerid, COLOR_RED, "Nu ai destui bani!");
                    GivePlayerMoney(playerid, -4000);
                    GivePlayerWeapon(playerid, 29, 150);
                    SendClientMessage(playerid, COLOR_GREEN, "Ai cumparat un MP5 cu 150 cartuse!");
                }
                case 4: {
                    if(GetPlayerMoney(playerid) < 1500) return SendClientMessage(playerid, COLOR_RED, "Nu ai destui bani!");
                    GivePlayerMoney(playerid, -1500);
                    SetPlayerArmour(playerid, 100.0);
                    SendClientMessage(playerid, COLOR_GREEN, "Ai echipat o Vesta Antiglont (100% Armour)!");
                }
            }
            return 1;
        }

        case DIALOG_JOB: {
            if(!response) return 1;
            new jobChoice = listitem + 1;
            PlayerInfo[playerid][pJob] = jobChoice;
            new msg[128];
            switch(jobChoice) {
                case JOB_TRUCKER: format(msg, sizeof(msg), "[JOB] Te-ai angajat ca Tirist / Trucker! Mergi la Depozit si tasteaza /work.");
                case JOB_PIZZA: format(msg, sizeof(msg), "[JOB] Te-ai angajat ca Pizza Boy! Urca pe un Faggio la Pizza si tasteaza /work.");
                case JOB_TAXI: format(msg, sizeof(msg), "[JOB] Te-ai angajat ca Taximetrist! Ia un taxi si pune tarif cu /fare.");
                case JOB_GARBAGE: format(msg, sizeof(msg), "[JOB] Te-ai angajat ca Gunoier! Ia o masina de gunoi si curata strazile.");
            }
            SendClientMessage(playerid, COLOR_GREEN, msg);
            SavePlayerData(playerid);
            return 1;
        }

        case DIALOG_FACTION_VEHICLES: {
            if(!response) return 1;
            if(PlayerInfo[playerid][pFaction] == FACTION_CIVILIAN) return 1;
            if(PlayerInfo[playerid][pDuty] == 0) return SendClientMessage(playerid, COLOR_RED, "Trebuie sa fii la datorie (/duty)!");

            new chosenModel = 0, col1 = 0, col2 = 0;
            switch(PlayerInfo[playerid][pFaction]) {
                case FACTION_POLICE: {
                    switch(listitem) {
                        case 0: chosenModel = 596; // Police Cruiser
                        case 1: chosenModel = 599; // Police Ranger
                        case 2: chosenModel = 523; // Police Bike
                        case 3: chosenModel = 427; // Enforcer SWAT
                    }
                    col1 = 0; col2 = 1;
                }
                case FACTION_MEDIC: {
                    switch(listitem) {
                        case 0: chosenModel = 416; // Ambulance
                        case 1: chosenModel = 490; // Paramedic Ranger
                        case 2: chosenModel = 563; // Raindance Chopper
                    }
                    col1 = 1; col2 = 3;
                }
                case FACTION_FBI: {
                    switch(listitem) {
                        case 0: chosenModel = 490; // FBI Rancher
                        case 1: chosenModel = 528; // FBI Truck
                        case 2: chosenModel = 415; // Cheetah Undercover
                        case 3: chosenModel = 560; // Sultan Undercover
                    }
                    col1 = 0; col2 = 0;
                }
                case FACTION_MAFIA: {
                    switch(listitem) {
                        case 0: chosenModel = 560; // Sultan Mafia
                        case 1: chosenModel = 579; // Huntley SUV
                        case 2: chosenModel = 445; // Admiral Sedan
                        case 3: chosenModel = 409; // Stretch Limousine
                    }
                    col1 = 0; col2 = 0;
                }
                case FACTION_HITMAN: {
                    switch(listitem) {
                        case 0: chosenModel = 405; // Sentinel
                        case 1: chosenModel = 468; // Sanchez
                        case 2: chosenModel = 487; // Maverick
                    }
                    col1 = 0; col2 = 0;
                }
                case FACTION_NEWS: {
                    switch(listitem) {
                        case 0: chosenModel = 582; // News Van
                        case 1: chosenModel = 488; // News Chopper
                    }
                    col1 = 1; col2 = 3;
                }
                case FACTION_TOW: {
                    switch(listitem) {
                        case 0: chosenModel = 525; // Tow Truck
                        case 1: chosenModel = 552; // Utility Van
                    }
                    col1 = 6; col2 = 6;
                }
            }

            if(chosenModel > 0) {
                if(PlayerFactionVeh[playerid] != INVALID_VEHICLE_ID) {
                    DestroyVehicle(PlayerFactionVeh[playerid]);
                    PlayerFactionVeh[playerid] = INVALID_VEHICLE_ID;
                }
                new Float:x, Float:y, Float:z, Float:a;
                GetPlayerPos(playerid, x, y, z);
                GetPlayerFacingAngle(playerid, a);

                new veh = CreateVehicle(chosenModel, x, y, z, a, col1, col2, -1);
                VehicleFuel[veh] = 100;
                VehicleEngine[veh] = true;
                VehicleLights[veh] = false;
                SetVehicleParamsEx(veh, 1, 0, 0, 0, 0, 0, 0);
                PlayerFactionVeh[playerid] = veh;
                PutPlayerInVehicle(playerid, veh, 0);

                SendClientMessage(playerid, COLOR_GREEN, "[FACTIUNE] Vehiculul tau de serviciu a fost spawnat cu motorul pornit!");
                SendClientMessage(playerid, COLOR_YELLOW, "[INFO] Tasteaza /fveh despawn cand nu mai ai nevoie de masina.");
            }
            return 1;
        }

        case DIALOG_CLOTHES_CAT: {
            if(!response) return 1;
            switch(listitem) {
                case 0: { // Elegant & Business
                    ShowPlayerDialog(playerid, DIALOG_CLOTHES_LIST, DIALOG_STYLE_LIST, "{FFFF00}Costume Elegante & Business",
                        "1. Costum Clasic Gri (Skin 17)\n2. Costum Negru Eleganta (Skin 29)\n3. Costum Camasa Alba (Skin 98)\n4. Tuxedo Gala (Skin 147)\n5. Costum Negru Cravata Rosie (Skin 165)\n6. Boss Mafiot Eleganta (Skin 171)\n7. Costum Italian Luxury (Skin 296)",
                        "Alege", "Inapoi"
                    );
                }
                case 1: { // Casual & Streetwear
                    ShowPlayerDialog(playerid, DIALOG_CLOTHES_LIST, DIALOG_STYLE_LIST, "{FFFF00}Haine Casual & Streetwear",
                        "1. Hanorac & Blugi Casual (Skin 1)\n2. Tricou Polo Alb (Skin 2)\n3. Geaca Casual Verde (Skin 7)\n4. Tricou & Blugi Comode (Skin 26)\n5. Camasa Deschisa Casual (Skin 30)\n6. Jacheta Streetwear (Skin 46)\n7. Sapca & Hanorac (Skin 101)",
                        "Alege", "Inapoi"
                    );
                }
                case 2: { // Gangster & Hip-Hop
                    ShowPlayerDialog(playerid, DIALOG_CLOTHES_LIST, DIALOG_STYLE_LIST, "{FFFF00}Haine Gangster & Hip-Hop",
                        "1. Gangster Grove Verde 1 (Skin 105)\n2. Gangster Grove Verde 2 (Skin 106)\n3. Gangster Grove Verde 3 (Skin 107)\n4. Ballas Mov Hanorac (Skin 102)\n5. Vagos Galben Bandana (Skin 108)\n6. Rapper Bandana & Lant (Skin 109)",
                        "Alege", "Inapoi"
                    );
                }
                case 3: { // Mafie & Costume Negre
                    ShowPlayerDialog(playerid, DIALOG_CLOTHES_LIST, DIALOG_STYLE_LIST, "{FFFF00}Costume Mafie & Sindicate",
                        "1. Camorra Negru Dungat (Skin 111)\n2. Yakuza Camasa Neagra (Skin 112)\n3. Don Mafiot Clasic (Skin 113)\n4. Bodyguard Costum Negru (Skin 124)\n5. Capo Costum Matase (Skin 127)",
                        "Alege", "Inapoi"
                    );
                }
                case 4: { // Fete & Modele
                    ShowPlayerDialog(playerid, DIALOG_CLOTHES_LIST, DIALOG_STYLE_LIST, "{FFFF00}Haine Femei & Modele",
                        "1. Rochie Eleganta Neagra (Skin 12)\n2. Fata Casual Top (Skin 40)\n3. Fata Denim & Geaca (Skin 56)\n4. Model Clubbing (Skin 91)\n5. Rochie Cocktail (Skin 93)\n6. Business Femeie (Skin 141)\n7. Fata Streetwear (Skin 190)",
                        "Alege", "Inapoi"
                    );
                }
            }
            return 1;
        }

        case DIALOG_CLOTHES_LIST: {
            if(!response) {
                // Inapoi la categorii
                ShowPlayerDialog(playerid, DIALOG_CLOTHES_CAT, DIALOG_STYLE_LIST, "{FFFF00}Alege Categoria de Haine",
                    "1. Costume Elegante & Business\n2. Haine Casual & Streetwear\n3. Gangster & Hip-Hop\n4. Mafie & Costume Negre\n5. Haine Femei & Modele",
                    "Alege", "Iesi"
                );
                return 1;
            }
            new chosenSkin = 26;
            // Parse skin based on selection
            new skins[35] = {
                17, 29, 98, 147, 165, 171, 296, // Cat 0 (0-6)
                1, 2, 7, 26, 30, 46, 101,       // Cat 1 (7-13)
                105, 106, 107, 102, 108, 109,   // Cat 2 (14-19)
                111, 112, 113, 124, 127,        // Cat 3 (20-24)
                12, 40, 56, 91, 93, 141, 190    // Cat 4 (25-31)
            };
            if(listitem >= 0 && listitem < 7) {
                chosenSkin = skins[listitem];
            }

            PlayerInfo[playerid][pSkin] = chosenSkin;
            CivilianSkin[playerid] = chosenSkin;
            SetPlayerSkin(playerid, chosenSkin);
            SavePlayerData(playerid);

            new smsg[128];
            format(smsg, sizeof(smsg), "[HAINE] Noua vestimentatie (Skin ID %d) a fost salvata permanent pe caracterul tau!", chosenSkin);
            SendClientMessage(playerid, COLOR_GREEN, smsg);
            PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
            return 1;
        }

        case DIALOG_TUTORIAL_DMV: {
            if(PlayerInfo[playerid][pTutorial] < 10) {
                if(response) {
                    SetPlayerPos(playerid, 1098.0, 1375.0, 10.82);
                    SetPlayerFacingAngle(playerid, 0.0);
                    GameTextForPlayer(playerid, "~g~SCOALA DE SOFERI~n~~w~Tasteaza /exam", 4000, 3);
                    PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
                    SendClientMessage(playerid, COLOR_GREEN, "[TUTORIAL] Ai fost transportat la Scoala de Soferi!");
                    SendClientMessage(playerid, COLOR_YELLOW, "[DMV] Tasteaza {00FF00}/exam {FFFF00}sau {00FF00}/dmv {FFFF00}pentru a incepe proba practica pentru permis.");
                } else {
                    SetPlayerPos(playerid, 2110.0, 2360.0, 10.82);
                    SetPlayerFacingAngle(playerid, 90.0);
                    GameTextForPlayer(playerid, "~y~BINE AI VENIT IN ~r~LAS VENTURAS!", 4000, 3);
                    PlayerPlaySound(playerid, 1187, 0.0, 0.0, 0.0);
                    SendClientMessage(playerid, COLOR_YELLOW, "[GHID] Tasteaza {FFFFFF}/help{FFFF00} pentru comenzi si {FFFFFF}/gps{FFFF00} pentru navigatie.");
                }
                PlayerInfo[playerid][pTutorial] = 10;
                SavePlayerData(playerid);
            } else {
                SetCameraBehindPlayer(playerid);
            }
            return 1;
        }

        case DIALOG_TUTORIAL_2: {
            if(response) {
                SendClientMessage(playerid, COLOR_GREEN, "[TUTORIAL] Super! Poti alege un job cu {FFFFFF}/jobs{00FF00} (Tirist, Pizza, Taxi, Gunoier). Ti-am pus un checkpoint la Agentia de Munca.");
                SetPlayerCheckpoint(playerid, 2130.0, 1395.0, 10.82, 6.0);
            } else {
                SendClientMessage(playerid, COLOR_YELLOW, "[TUTORIAL] Nicio problema, poti lua un job oricand cu /jobs.");
            }
            ShowTutorialStep3(playerid);
            return 1;
        }

        case DIALOG_TUTORIAL_3: {
            if(response) {
                SendClientMessage(playerid, COLOR_GREEN, "[TUTORIAL] Ai primit {FFFF00}$15.000 in banca{00FF00}! Foloseste /bank sau /atm la Banca LV pentru depuneri si retrageri.");
                SendClientMessage(playerid, COLOR_YELLOW, "[TUTORIAL] Cumpara un telefon din magazinul 24/7 cu /buy ($500), apoi foloseste /phone pentru apeluri si SMS!");
            } else {
                SendClientMessage(playerid, COLOR_YELLOW, "[TUTORIAL] Bani tai sunt in siguranta. Foloseste /stats oricand pentru a-ti vedea soldul.");
            }
            ShowTutorialStep4(playerid);
            return 1;
        }

        case DIALOG_TUTORIAL_4: {
            if(response) {
                SendClientMessage(playerid, COLOR_GREEN, "[TUTORIAL] Casele sunt marcate cu pickup-uri verzi! Tasteaza {FFFF00}/house{00FF00} langa una pentru a o cumpara sau pentru a intra.");
            } else {
                SendClientMessage(playerid, COLOR_YELLOW, "[TUTORIAL] Vehicule: /ds pentru dealership, tasta 2 = motor, tasta N = incuiere, /fill pentru benzina.");
            }
            ShowPlayerDialog(playerid, DIALOG_TUTORIAL_DMV, DIALOG_STYLE_MSGBOX, "{00FF00}Tutorial 5/5 - Permis de Conducere",
                "{FFFFFF}Ultimul pas al tutorialului!\n\n\
                Pentru a putea conduce legal masini si a te angaja la joburi,\n\
                ai nevoie de un {FFFF00}Permis de Conducere{FFFFFF} de la Scoala de Soferi (DMV).\n\n\
                {00FFFF}Doresti sa fii teleportat direct la DMV pentru proba practica?{FFFFFF}",
                "Da, la DMV!", "Nu, la Spawn"
            );
            return 1;
        }

        case DIALOG_TUTORIAL: {
            SetCameraBehindPlayer(playerid);
            SetPlayerInterior(playerid, 0);
            SetPlayerVirtualWorld(playerid, 0);
            SetPlayerPos(playerid, 2110.0, 2360.0, 10.82);
            SetPlayerFacingAngle(playerid, 90.0);
            GameTextForPlayer(playerid, "~y~BINE AI VENIT IN ~r~LAS VENTURAS!", 4000, 3);
            PlayerPlaySound(playerid, 1187, 0.0, 0.0, 0.0);
            SendClientMessage(playerid, COLOR_YELLOW, "[GHID] Tasteaza {FFFFFF}/help{FFFF00} pentru comenzi si {FFFFFF}/gps{FFFF00} pentru navigatie.");
            return 1;
        }

        case DIALOG_EVENT_CREATE: {
            if(!response) return 1;
            if(PlayerInfo[playerid][pAdmin] < 2) return SendClientMessage(playerid, COLOR_RED, "Nu ai permisiune!");
            if(gEventActive != 0) return SendClientMessage(playerid, COLOR_RED, "Un event este deja activ!");

            gEventType = listitem + 1;
            gEventActive = 1;
            gEventParticipants = 0;

            new eventName[32];
            switch(gEventType) {
                case EVENT_DEAGLE: {
                    format(eventName, sizeof(eventName), "Deagle Arena");
                    gEventPrize = 50000;
                }
                case EVENT_LMS: {
                    format(eventName, sizeof(eventName), "Last Man Standing");
                    gEventPrize = 75000;
                }
                case EVENT_DERBY: {
                    format(eventName, sizeof(eventName), "Derby Demolition");
                    gEventPrize = 50000;
                }
                case EVENT_RACE: {
                    format(eventName, sizeof(eventName), "Supercar Race");
                    gEventPrize = 60000;
                }
            }

            for(new i = 0; i < MAX_PLAYERS; i++) {
                pInEvent[i] = false;
                EventVehicle[i] = INVALID_VEHICLE_ID;
            }

            new str[256];
            SendClientMessageToAll(COLOR_CYAN, "==========================================================");
            format(str, sizeof(str), "[EVENT] Administratorul %s a deschis inscrierile la eventul %s!", PlayerInfo[playerid][pName], eventName);
            SendClientMessageToAll(COLOR_GREEN, str);
            format(str, sizeof(str), "[EVENT] Tasteaza /join sau /particip pentru a intra! Premiu: $%d + 5 Respect", gEventPrize);
            SendClientMessageToAll(COLOR_YELLOW, str);
            SendClientMessageToAll(COLOR_CYAN, "==========================================================");
            return 1;
        }
    }
    return 1;
}

public OnVehicleSpawn(vehicleid) {
    if(vehicleid > 0 && vehicleid < MAX_VEHICLES) {
        if(VehicleFuel[vehicleid] <= 0) VehicleFuel[vehicleid] = 100;
        VehicleEngine[vehicleid] = false;
        VehicleLights[vehicleid] = false;
        new engine, lights, alarm, doors, bonnet, boot, objective;
        GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
        SetVehicleParamsEx(vehicleid, 0, 0, alarm, doors, bonnet, boot, objective);
    }
    return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
    // Exit house interior with F/Enter (KEY_SECONDARY_ATTACK = 16)
    if((newkeys & KEY_SECONDARY_ATTACK) && !(oldkeys & KEY_SECONDARY_ATTACK)) {
        if(GetPlayerInterior(playerid) == HOUSE_INT_ID && GetPlayerVirtualWorld(playerid) >= HOUSE_INT_WORLD_BASE) {
            new slot = GetPlayerVirtualWorld(playerid) - HOUSE_INT_WORLD_BASE;
            if(slot >= 0 && slot < MAX_HOUSES) {
                SetPlayerInterior(playerid, 0);
                SetPlayerVirtualWorld(playerid, 0);
                SetPlayerPos(playerid, HouseInfo[slot][hX], HouseInfo[slot][hY], HouseInfo[slot][hZ]);
                SetPlayerFacingAngle(playerid, 0.0);
                return 1;
            }
        }
    }

    // Key '2' in vehicle (KEY_SUBMISSION = 512)
    if((newkeys & KEY_SUBMISSION) && !(oldkeys & KEY_SUBMISSION)) {
        if(IsPlayerInAnyVehicle(playerid) && GetPlayerVehicleSeat(playerid) == 0) {
            ToggleVehicleEngine(playerid);
            return 1;
        }
    }
    // Key 'N' (KEY_NO = 65536) for car lock
    if((newkeys & KEY_NO) && !(oldkeys & KEY_NO)) {
        new veh = INVALID_VEHICLE_ID;
        if(IsPlayerInAnyVehicle(playerid)) {
            veh = GetPlayerVehicleID(playerid);
        } else {
            veh = GetNearestVehicle(playerid, 4.0);
        }
        if(veh != INVALID_VEHICLE_ID) {
            new pIdx = GetPersonalVehicleIndex(veh);
            if(pIdx != -1 && !strcmp(VehicleInfo[pIdx][vOwner], PlayerInfo[playerid][pName], true)) {
                new engine, lights, alarm, doors, bonnet, boot, objective;
                GetVehicleParamsEx(veh, engine, lights, alarm, doors, bonnet, boot, objective);
                if(VehicleInfo[pIdx][vLocked] == 1) {
                    VehicleInfo[pIdx][vLocked] = 0;
                    SetVehicleParamsEx(veh, engine, lights, alarm, 0, bonnet, boot, objective);
                    GameTextForPlayer(playerid, "~g~USI DESCUIATE", 1500, 3);
                    PlayerPlaySound(playerid, 1145, 0.0, 0.0, 0.0);
                } else {
                    VehicleInfo[pIdx][vLocked] = 1;
                    SetVehicleParamsEx(veh, engine, lights, alarm, 1, bonnet, boot, objective);
                    GameTextForPlayer(playerid, "~r~USI INCUIATE", 1500, 3);
                    PlayerPlaySound(playerid, 1145, 0.0, 0.0, 0.0);
                }
                new query[128];
                format(query, sizeof(query), "UPDATE vehicles SET locked = %d WHERE id = %d;", VehicleInfo[pIdx][vLocked], VehicleInfo[pIdx][vID]);
                db_query(gDB, query);
                return 1;
            }
        }
    }
    return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate) {
    // Taxi: mark passenger as riding when boarding a taxi driver's cab
    if(newstate == PLAYER_STATE_PASSENGER) {
        new tVeh = GetPlayerVehicleID(playerid);
        new driver = INVALID_PLAYER_ID;
        for(new d = 0; d < MAX_PLAYERS; d++) {
            if(IsPlayerConnected(d) && GetPlayerVehicleID(d) == tVeh && GetPlayerVehicleSeat(d) == 0) {
                driver = d;
                break;
            }
        }
        if(driver != INVALID_PLAYER_ID && PlayerInfo[driver][pJob] == JOB_TAXI && pTaxiFare[driver] > 0) {
            pTaxiRider[driver] = playerid;
            new bstr[144];
            format(bstr, sizeof(bstr), "[TAXI] Pasagerul %s a urcat in taxi. Tarif: $%d. Cand coboara va plati automat.", PlayerInfo[playerid][pName], pTaxiFare[driver]);
            SendClientMessage(driver, COLOR_YELLOW, bstr);
            format(bstr, sizeof(bstr), "[TAXI] Ai urcat in taxiul lui %s. Tarif: $%d (platit automat la coborare).", PlayerInfo[driver][pName], pTaxiFare[driver]);
            SendClientMessage(playerid, COLOR_YELLOW, bstr);
        }
    }

    // Taxi payment when passenger exits the cab
    if(oldstate == PLAYER_STATE_PASSENGER && newstate == PLAYER_STATE_ONFOOT) {
        for(new d = 0; d < MAX_PLAYERS; d++) {
            if(IsPlayerConnected(d) && pTaxiRider[d] == playerid && PlayerInfo[d][pJob] == JOB_TAXI) {
                new fare = pTaxiFare[d];
                if(GetPlayerMoney(playerid) >= fare) {
                    GivePlayerMoney(playerid, -fare);
                    GivePlayerMoney(d, fare);
                    PlayerInfo[d][pMoney] = GetPlayerMoney(d);
                    PlayerInfo[playerid][pMoney] = GetPlayerMoney(playerid);
                    new tstr[144];
                    format(tstr, sizeof(tstr), "[TAXI] Ai platit cursa de $%d catre soferul %s.", fare, PlayerInfo[d][pName]);
                    SendClientMessage(playerid, COLOR_YELLOW, tstr);
                    format(tstr, sizeof(tstr), "[TAXI] Pasagerul %s a platit cursa de $%d.", PlayerInfo[playerid][pName], fare);
                    SendClientMessage(d, COLOR_GREEN, tstr);
                } else {
                    SendClientMessage(d, COLOR_RED, "[TAXI] Pasagerul nu a avut bani pentru cursa!");
                }
                pTaxiFare[d] = 0;
                pTaxiRider[d] = INVALID_PLAYER_ID;
                SavePlayerData(d);
                SavePlayerData(playerid);
            }
        }
    }

    if(newstate == PLAYER_STATE_DRIVER) {
        new veh = GetPlayerVehicleID(playerid);
        if(VehicleFuel[veh] <= 0) VehicleFuel[veh] = 100;
        new model = GetVehicleModel(veh);
        if(model != 481 && model != 509 && model != 510) {
            if(!VehicleEngine[veh]) {
                GameTextForPlayer(playerid, "~y~Apasa ~g~[2]~y~ sau /engine!", 2500, 3);
                SendClientMessage(playerid, COLOR_YELLOW, "[VEHICUL] Apasa tasta '2' sau scrie /engine pentru a porni motorul.");
            }
        }
    }
    return 1;
}

stock ToggleVehicleEngine(playerid) {
    if(!IsPlayerInAnyVehicle(playerid)) return 0;
    if(GetPlayerVehicleSeat(playerid) != 0) {
        SendClientMessage(playerid, COLOR_RED, "Doar soferul poate porni / opri motorul!");
        return 1;
    }
    new veh = GetPlayerVehicleID(playerid);
    new model = GetVehicleModel(veh);
    if(model == 481 || model == 509 || model == 510) {
        SendClientMessage(playerid, COLOR_YELLOW, "Bicicleta nu are motor!");
        return 1;
    }
    if(VehicleFuel[veh] <= 0) {
        SendClientMessage(playerid, COLOR_RED, "[MOTOR] Rezervorul este gol! Alimenteaza la benzinarie sau /fill.");
        GameTextForPlayer(playerid, "~r~REZERVOR GOL!", 2000, 3);
        return 1;
    }
    new engine, lights, alarm, doors, bonnet, boot, objective;
    GetVehicleParamsEx(veh, engine, lights, alarm, doors, bonnet, boot, objective);

    if(VehicleEngine[veh]) {
        VehicleEngine[veh] = false;
        SetVehicleParamsEx(veh, 0, lights, alarm, doors, bonnet, boot, objective);
        GameTextForPlayer(playerid, "~r~MOTOR OPRIT", 1500, 3);
        new str[128];
        format(str, sizeof(str), "* %s invarte cheia in contact si opreste motorul.", PlayerInfo[playerid][pName]);
        SendLocalMessage(playerid, COLOR_PURPLE, str, 15.0);
    } else {
        VehicleEngine[veh] = true;
        SetVehicleParamsEx(veh, 1, lights, alarm, doors, bonnet, boot, objective);
        GameTextForPlayer(playerid, "~g~MOTOR PORNIT", 1500, 3);
        new str[128];
        format(str, sizeof(str), "* %s invarte cheia in contact si porneste motorul.", PlayerInfo[playerid][pName]);
        SendLocalMessage(playerid, COLOR_PURPLE, str, 15.0);
    }
    return 1;
}

public OnPlayerText(playerid, text[]) {
    if(!PlayerInfo[playerid][pLogged]) {
        SendClientMessage(playerid, COLOR_RED, "[EROARE] Trebuie sa fii autentificat pentru a vorbi pe chat!");
        return 0;
    }

    if(PlayerInfo[playerid][pMuted]) {
        new mStr[128];
        format(mStr, sizeof(mStr), "[MUTE] Esti redus la tacere (mutat)! Mai ai %d secunde din sanctiune.", PlayerInfo[playerid][pMuteTime]);
        SendClientMessage(playerid, COLOR_RED, mStr);
        return 0;
    }

    new chatStr[144];
    if(pCuffed[playerid]) {
        format(chatStr, sizeof(chatStr), "%s (%d) spune cu greu (incatusat): %s", PlayerInfo[playerid][pName], playerid, text);
    } else {
        format(chatStr, sizeof(chatStr), "%s (%d) spune: %s", PlayerInfo[playerid][pName], playerid, text);
    }
    SendLocalMessage(playerid, COLOR_WHITE, chatStr, 25.0);
    return 0;
}

public OnPlayerSpawn(playerid) {
    SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, 0);

    if(PlayerInfo[playerid][pJailed]) {
        SetPlayerInterior(playerid, 6);
        SetPlayerPos(playerid, 264.0, 77.0, 1001.0);
        SendClientMessage(playerid, COLOR_RED, "[JAIL] Esti inca in inchisoare! Ispaseste-ti pedeapsa.");
    } else {
        // Emerald Isle Casino & Hotel spawn
        SetPlayerPos(playerid, 2110.0, 2360.0, 10.82);
        SetPlayerFacingAngle(playerid, 90.0);
    }

    SetCameraBehindPlayer(playerid);
    SetPlayerSkin(playerid, PlayerInfo[playerid][pSkin]);

    // Set wanted level visually on client
    SetPlayerWantedLevel(playerid, PlayerInfo[playerid][pWanted]);

    // Roleplay spawn welcome
    if(!strcmp(PlayerInfo[playerid][pName], "atomk", true)) {
        PlayerInfo[playerid][pAdmin] = 5;
        SendClientMessage(playerid, COLOR_ADMIN, "[OWNER] Bun venit atomk! Ai acces complet de FONDATOR (Admin Level 5)!");
    }
    return 1;
}

public OnPlayerDeath(playerid, killerid, reason) {
    EndPhoneCall(playerid);
    PlayerInfo[playerid][pDeaths]++;

    if(killerid != INVALID_PLAYER_ID) {
        PlayerInfo[killerid][pKills]++;

        // If killer is police/fbi and victim had wanted
        if((PlayerInfo[killerid][pFaction] == FACTION_POLICE || PlayerInfo[killerid][pFaction] == FACTION_FBI) && PlayerInfo[killerid][pDuty]) {
            if(PlayerInfo[playerid][pWanted] > 0) {
                new jailMins = PlayerInfo[playerid][pWanted] * 5; // 5 min per wanted star
                PlayerInfo[playerid][pJailed] = 1;
                PlayerInfo[playerid][pJailTime] = jailMins * 60;
                PlayerInfo[playerid][pWanted] = 0;
                SetPlayerWantedLevel(playerid, 0);
                format(PlayerInfo[playerid][pCrimes], 64, "Neutralizat de politie");

                PlayerInfo[killerid][pRaport]++;
                GivePlayerMoney(killerid, 1000);
                PlayerInfo[killerid][pMoney] = GetPlayerMoney(killerid);

                new rMsg[144];
                format(rMsg, sizeof(rMsg), "[POLITIE] Ofiterul %s a neutralizat suspectul %s! Suspectul a fost inchis pentru %d minute.", PlayerInfo[killerid][pName], PlayerInfo[playerid][pName], jailMins);
                SendClientMessageToAll(COLOR_POLICE, rMsg);
                SavePlayerData(killerid);
                SavePlayerData(playerid);
            } else {
                GivePlayerMoney(killerid, 250);
            }
        } else {
            GivePlayerMoney(killerid, 250);
            SendClientMessage(killerid, COLOR_GREEN, "[BONUS] Ai primit $250 pentru neutralizarea tintei.");
            // Non-police kill gives +1 wanted
            if(PlayerInfo[killerid][pFaction] != FACTION_POLICE && PlayerInfo[killerid][pFaction] != FACTION_FBI) {
                if(PlayerInfo[killerid][pWanted] < 6) {
                    PlayerInfo[killerid][pWanted]++;
                    SetPlayerWantedLevel(killerid, PlayerInfo[killerid][pWanted]);
                    format(PlayerInfo[killerid][pCrimes], 64, "Omor deosebit de grav");
                    new wMsg[144];
                    format(wMsg, sizeof(wMsg), "[DISPECERAT] Suspectul %s a primit Wanted %d. Motiv: Omor deosebit de grav.", PlayerInfo[killerid][pName], PlayerInfo[killerid][pWanted]);
                    for(new c = 0; c < MAX_PLAYERS; c++) {
                        if(IsPlayerConnected(c) && (PlayerInfo[c][pFaction] == FACTION_POLICE || PlayerInfo[c][pFaction] == FACTION_FBI)) {
                            SendClientMessage(c, COLOR_POLICE, wMsg);
                        }
                    }
                    SendClientMessage(killerid, COLOR_RED, "[CRIMA] Ai comis o crima! Politia a emis un mandat pe numele tau.");
                    SavePlayerData(killerid);
                }
            }
        }
    }
    SendClientMessage(playerid, COLOR_RED, "[SPITAL] Ai lesinat! Medicii te-au transportat de urgenta la Spitalul Las Venturas.");
    return 1;
}

// ============================================================================
//                               TICK PULSE & SPEEDO
// ============================================================================

static gSecondCounter = 0;

public OnGlobalUpdate() {
    gSecondCounter++;

    // Update Global Clock Textdraw
    new hour, minute, second;
    gettime(hour, minute, second);
    new timeStr[32];
    format(timeStr, sizeof(timeStr), "~w~Ora: ~p~%02d:%02d:%02d", hour, minute, second);
    TextDrawSetString(ServerTimeText, timeStr);

    for(new i = 0; i < MAX_PLAYERS; i++) {
        if(IsPlayerConnected(i) && PlayerInfo[i][pLogged]) {
            OnPlayerSecondUpdate(i);
        }
    }

    // PayDay check every 3600 seconds (1 hour)
    if(gSecondCounter >= 3600) {
        gSecondCounter = 0;
        OnPayDay();
    }
    return 1;
}

public OnPlayerSecondUpdate(playerid) {
    if(IsPlayerInAnyVehicle(playerid)) {
        new veh = GetPlayerVehicleID(playerid);
        new model = GetVehicleModel(veh);
        new Float:vx, Float:vy, Float:vz;
        GetVehicleVelocity(veh, vx, vy, vz);
        new speed = floatround(floatsqroot(vx*vx + vy*vy + vz*vz) * 180.0);

        if(VehicleFuel[veh] <= 0) {
            VehicleFuel[veh] = 0;
            if(VehicleEngine[veh]) {
                VehicleEngine[veh] = false;
                new engine, lights, alarm, doors, bonnet, boot, objective;
                GetVehicleParamsEx(veh, engine, lights, alarm, doors, bonnet, boot, objective);
                SetVehicleParamsEx(veh, 0, lights, alarm, doors, bonnet, boot, objective);
                GameTextForPlayer(playerid, "~r~REZERVOR GOL!", 2000, 3);
            }
        } else if(VehicleEngine[veh] && speed > 5 && (gSecondCounter % 15 == 0)) {
            VehicleFuel[veh]--;
        }

        // Get Vehicle Name
        new vehName[32] = "Vehicul";
        if(model >= 400 && model <= 611) {
            format(vehName, sizeof(vehName), "%s", VehicleNames[model - 400]);
        }

        new pIdx = GetPersonalVehicleIndex(veh);
        new bool:isLocked = false;
        if(pIdx != -1) {
            isLocked = (VehicleInfo[pIdx][vLocked] == 1);
        }

        new speedColor[8];
        if(speed > 160) format(speedColor, sizeof(speedColor), "~r~");
        else if(speed > 90) format(speedColor, sizeof(speedColor), "~y~");
        else format(speedColor, sizeof(speedColor), "~g~");

        new fuelBar[24];
        if(VehicleFuel[veh] >= 80) format(fuelBar, sizeof(fuelBar), "~g~||||||||||");
        else if(VehicleFuel[veh] >= 60) format(fuelBar, sizeof(fuelBar), "~g~||||||||~w~||");
        else if(VehicleFuel[veh] >= 40) format(fuelBar, sizeof(fuelBar), "~y~||||||~w~||||");
        else if(VehicleFuel[veh] >= 20) format(fuelBar, sizeof(fuelBar), "~y~||||~w~||||||");
        else format(fuelBar, sizeof(fuelBar), "~r~||~w~||||||||");

        new Float:vHealth;
        GetVehicleHealth(veh, vHealth);
        new hpPercent = floatround(vHealth / 10.0);
        if(hpPercent > 100) hpPercent = 100;
        if(hpPercent < 0) hpPercent = 0;

        new hpColor[8];
        if(hpPercent > 60) format(hpColor, sizeof(hpColor), "~g~");
        else if(hpPercent > 35) format(hpColor, sizeof(hpColor), "~y~");
        else format(hpColor, sizeof(hpColor), "~r~");

        new str[320];
        format(str, sizeof(str),
            "~y~[ %s ]~n~\
            ~w~VITEZA: %s%d ~w~KM/H~n~\
            ~w~COMBUSTIBIL: %s ~w~%d%%~n~\
            ~w~STARE CAROSERIE: %s%d%%~n~\
            ~w~MOTOR: %s ~y~[2] ~w~| USI: %s ~y~[N]",
            vehName,
            speedColor, speed,
            fuelBar, VehicleFuel[veh],
            hpColor, hpPercent,
            VehicleEngine[veh] ? ("~g~PORNIT") : ("~r~OPRIT"),
            isLocked ? ("~r~INCUIAT") : ("~g~DESCUIAT")
        );

        PlayerTextDrawSetString(playerid, SpeedoInfoTD[playerid], str);
        PlayerTextDrawShow(playerid, SpeedoBoxTD[playerid]);
        PlayerTextDrawShow(playerid, SpeedoInfoTD[playerid]);
    } else {
        PlayerTextDrawHide(playerid, SpeedoBoxTD[playerid]);
        PlayerTextDrawHide(playerid, SpeedoInfoTD[playerid]);
    }

    // Jail Timer countdown
    if(PlayerInfo[playerid][pJailed]) {
        if(PlayerInfo[playerid][pJailTime] > 0) {
            PlayerInfo[playerid][pJailTime]--;
        } else {
            PlayerInfo[playerid][pJailed] = 0;
            PlayerInfo[playerid][pJailTime] = 0;
            SetPlayerInterior(playerid, 0);
            SetPlayerVirtualWorld(playerid, 0);
            SetPlayerPos(playerid, 2110.0, 2360.0, 10.82);
            SetPlayerFacingAngle(playerid, 90.0);
            SendClientMessage(playerid, COLOR_GREEN, "[JAIL] Ti-ai ispasit pedeapsa si ai fost eliberat din inchisoare la Emerald Isle!");
            SavePlayerData(playerid);
        }
    }

    // Mute Timer countdown
    if(PlayerInfo[playerid][pMuted]) {
        if(PlayerInfo[playerid][pMuteTime] > 0) {
            PlayerInfo[playerid][pMuteTime]--;
        } else {
            PlayerInfo[playerid][pMuted] = 0;
            PlayerInfo[playerid][pMuteTime] = 0;
            SendClientMessage(playerid, COLOR_GREEN, "[MUTE] Pedeapsa de mute a expirat! Poti vorbi din nou pe chat.");
            SavePlayerData(playerid);
        }
    }
}

public OnPayDay() {
    print("[SERVER] Payday execution running for all players.");
    for(new i = 0; i < MAX_PLAYERS; i++) {
        if(IsPlayerConnected(i) && PlayerInfo[i][pLogged]) {
            PlayerInfo[i][pHours]++;
            SetPlayerScore(i, GetPlayerScore(i) + 1);

            new jobSalary = 1000;
            switch(PlayerInfo[i][pJob]) {
                case JOB_TRUCKER: jobSalary = 2500;
                case JOB_PIZZA:   jobSalary = 1800;
                case JOB_TAXI:    jobSalary = 1500;
                case JOB_GARBAGE: jobSalary = 2000;
            }

            new interest = PlayerInfo[i][pBank] / 100;
            if(interest > 10000) interest = 10000;

            PlayerInfo[i][pBank] += (jobSalary + interest);

            SendClientMessage(i, COLOR_YELLOW, "================= [ PAYDAY ] =================");
            new msg[128];
            format(msg, sizeof(msg), " Salariu de baza / Job: +$%d", jobSalary);
            SendClientMessage(i, COLOR_WHITE, msg);
            format(msg, sizeof(msg), " Dobanda Bancara (1%%): +$%d", interest);
            SendClientMessage(i, COLOR_WHITE, msg);
            format(msg, sizeof(msg), " Sold Bancar Curent: $%d | Nivel: %d", PlayerInfo[i][pBank], GetPlayerScore(i));
            SendClientMessage(i, COLOR_GREEN, msg);
            SendClientMessage(i, COLOR_YELLOW, "==============================================");

            SavePlayerData(i);
        }
    }
    return 1;
}

// ============================================================================
//                               JOB CHECKPOINTS
// ============================================================================

public OnPlayerEnterCheckpoint(playerid) {
    // DMV Driving School Exam Checkpoints
    if(pInExam[playerid]) {
        pExamCP[playerid]++;
        PlayerPlaySound(playerid, 1056, 0.0, 0.0, 0.0);
        switch(pExamCP[playerid]) {
            case 1: {
                SetPlayerCheckpoint(playerid, 1020.0, 1040.0, 10.82, 5.0);
                GameTextForPlayer(playerid, "~y~Punct 1/6 atins!~n~~w~Viraj dreapta spre Greenglass", 2500, 3);
            }
            case 2: {
                SetPlayerCheckpoint(playerid, 1200.0, 1040.0, 10.82, 5.0);
                GameTextForPlayer(playerid, "~y~Punct 2/6 atins!~n~~w~Continua pe bulevard", 2500, 3);
            }
            case 3: {
                SetPlayerCheckpoint(playerid, 1200.0, 1250.0, 10.82, 5.0);
                GameTextForPlayer(playerid, "~y~Punct 3/6 atins!~n~~w~Viraj nord spre Blackfield", 2500, 3);
            }
            case 4: {
                SetPlayerCheckpoint(playerid, 1098.0, 1365.0, 10.82, 5.0);
                GameTextForPlayer(playerid, "~y~Punct 4/6 atins!~n~~w~Apropie-te de poligonul DMV", 2500, 3);
            }
            case 5: {
                SetPlayerCheckpoint(playerid, 1098.0, 1375.0, 10.82, 5.0);
                GameTextForPlayer(playerid, "~y~Punct 5/6!~n~~g~Opreste la sediul DMV!", 3000, 3);
            }
            case 6: {
                DisablePlayerCheckpoint(playerid);
                pInExam[playerid] = false;

                new Float:vHp = 1000.0;
                if(pExamVehicle[playerid] != INVALID_VEHICLE_ID) {
                    GetVehicleHealth(pExamVehicle[playerid], vHp);
                    DestroyVehicle(pExamVehicle[playerid]);
                    pExamVehicle[playerid] = INVALID_VEHICLE_ID;
                }

                if(vHp < 650.0) {
                    SendClientMessage(playerid, COLOR_RED, "[DMV] Ai picat examenul auto! Ai avariat masina prea tare. Incearca din nou.");
                    GameTextForPlayer(playerid, "~r~EXAMEN PICAT!~n~~w~Conducere periculoasa", 4000, 3);
                } else {
                    PlayerInfo[playerid][pCarLic] = 1;
                    SavePlayerData(playerid);
                    PlayerPlaySound(playerid, 1187, 0.0, 0.0, 0.0);
                    GameTextForPlayer(playerid, "~g~EXAMEN PROMOVAT!~n~~w~Ai primit permisul!", 4000, 3);
                    SendClientMessage(playerid, COLOR_GREEN, "[DMV] Felicitari! Ai promovat examenul auto si ai primit Permisul de Conducere!");
                }
                return 1;
            }
        }
        return 1;
    }
    if(PlayerInfo[playerid][pJob] == JOB_TRUCKER && PlayerInfo[playerid][pWorkStage] == 1) {
        DisablePlayerCheckpoint(playerid);
        PlayerInfo[playerid][pWorkStage] = 0;

        new earnings = 3500 + random(1000);
        GivePlayerMoney(playerid, earnings);
        PlayerInfo[playerid][pMoney] = GetPlayerMoney(playerid);

        if(PlayerInfo[playerid][pWorkVehicle]) {
            DestroyVehicle(PlayerInfo[playerid][pWorkVehicle]);
            PlayerInfo[playerid][pWorkVehicle] = 0;
        }
        if(PlayerInfo[playerid][pWorkTrailer]) {
            DestroyVehicle(PlayerInfo[playerid][pWorkTrailer]);
            PlayerInfo[playerid][pWorkTrailer] = 0;
        }

        new msg[128];
        format(msg, sizeof(msg), "[TRUCKER] Livrare efectuata cu succes! Ai primit $%d.", earnings);
        SendClientMessage(playerid, COLOR_GREEN, msg);
        SavePlayerData(playerid);
        return 1;
    }

    if(PlayerInfo[playerid][pJob] == JOB_PIZZA && PlayerInfo[playerid][pWorkStage] == 1) {
        DisablePlayerCheckpoint(playerid);
        PlayerInfo[playerid][pWorkStage] = 0;

        new tip = 300 + random(200);
        GivePlayerMoney(playerid, tip);
        PlayerInfo[playerid][pMoney] = GetPlayerMoney(playerid);

        new msg[128];
        format(msg, sizeof(msg), "[PIZZA] Pizza a fost livrata clientului! Ai primit un bacsis de $%d.", tip);
        SendClientMessage(playerid, COLOR_GREEN, msg);
        SendClientMessage(playerid, COLOR_YELLOW, "[PIZZA] Foloseste /work din nou pentru o alta comanda.");
        SavePlayerData(playerid);
        return 1;
    }

    if(PlayerInfo[playerid][pJob] == JOB_GARBAGE && PlayerInfo[playerid][pWorkStage] >= 1) {
        PlayerInfo[playerid][pWorkStage]++;
        PlayerPlaySound(playerid, 1056, 0.0, 0.0, 0.0);

        new msg[128];
        if(PlayerInfo[playerid][pWorkStage] > sizeof(GarbageRoute)) {
            // Route finished
            DisablePlayerCheckpoint(playerid);
            PlayerInfo[playerid][pWorkStage] = 0;

            new earnings = 4000 + random(1500);
            GivePlayerMoney(playerid, earnings);
            PlayerInfo[playerid][pMoney] = GetPlayerMoney(playerid);

            if(PlayerInfo[playerid][pWorkVehicle]) {
                DestroyVehicle(PlayerInfo[playerid][pWorkVehicle]);
                PlayerInfo[playerid][pWorkVehicle] = 0;
            }
            format(msg, sizeof(msg), "[GUNOIER] Tura completa! Ai colectat gunoiul din tot cartierul si ai primit $%d.", earnings);
            SendClientMessage(playerid, COLOR_GREEN, msg);
            SavePlayerData(playerid);
        } else {
            new cp = PlayerInfo[playerid][pWorkStage] - 1;
            SetPlayerCheckpoint(playerid, GarbageRoute[cp][0], GarbageRoute[cp][1], GarbageRoute[cp][2], 6.0);
            format(msg, sizeof(msg), "[GUNOIER] Punct de colectare %d/%d atins! Mergi la urmatorul.", cp, sizeof(GarbageRoute));
            SendClientMessage(playerid, COLOR_YELLOW, msg);
        }
        return 1;
    }

    DisablePlayerCheckpoint(playerid);
    return 1;
}

public OnPlayerUpdate(playerid) {
    if(pFlyMode[playerid]) {
        new keys, ud, lr;
        GetPlayerKeys(playerid, keys, ud, lr);
        new Float:x, Float:y, Float:z;
        GetPlayerPos(playerid, x, y, z);
        new Float:camX, Float:camY, Float:camZ;
        GetPlayerCameraFrontVector(playerid, camX, camY, camZ);

        new Float:speed = 1.0;
        if(keys & KEY_SPRINT) speed = 2.6;

        if(ud < 0) { // W / Inainte
            x += camX * speed;
            y += camY * speed;
            z += camZ * speed;
        } else if(ud > 0) { // S / Inapoi
            x -= camX * speed;
            y -= camY * speed;
            z -= camZ * speed;
        }

        if(keys & KEY_JUMP) z += 1.2;
        if(keys & KEY_CROUCH) z -= 1.2;

        SetPlayerPos(playerid, x, y, z);
    }
    if(pGodMode[playerid]) {
        SetPlayerHealth(playerid, 100.0);
        SetPlayerArmour(playerid, 100.0);
    }
    return 1;
}

// ============================================================================
//                             COMMANDS PROCESSOR
// ============================================================================

public OnPlayerCommandText(playerid, cmdtext[]) {
    if(!PlayerInfo[playerid][pLogged]) {
        SendClientMessage(playerid, COLOR_RED, "[EROARE] Trebuie sa fii autentificat pentru a folosi comenzi!");
        return 1;
    }

    new cmd[32], params[128];
    new idx = 0;
    while (cmdtext[idx] > ' ') {
        cmd[idx] = cmdtext[idx];
        idx++;
    }
    cmd[idx] = '\0';
    while (cmdtext[idx] == ' ') idx++;
    format(params, sizeof(params), "%s", cmdtext[idx]);

    // Roleplay Chat & Interaction Commands
    if(!strcmp(cmd, "/me", true)) {
        if(strlen(params) == 0) return SendClientMessage(playerid, COLOR_YELLOW, "Folosire: /me [actiune]");
        new str[144];
        format(str, sizeof(str), "* %s %s", PlayerInfo[playerid][pName], params);
        SendLocalMessage(playerid, COLOR_PURPLE, str, 25.0);
        return 1;
    }

    if(!strcmp(cmd, "/do", true)) {
        if(strlen(params) == 0) return SendClientMessage(playerid, COLOR_YELLOW, "Folosire: /do [stare/descriere]");
        new str[144];
        format(str, sizeof(str), "* %s (( %s ))", params, PlayerInfo[playerid][pName]);
        SendLocalMessage(playerid, COLOR_LIGHTBLUE, str, 25.0);
        return 1;
    }

    if(!strcmp(cmd, "/b", true)) {
        if(strlen(params) == 0) return SendClientMessage(playerid, COLOR_YELLOW, "Folosire: /b [mesaj OOC]");
        new str[144];
        format(str, sizeof(str), "(( %s: %s ))", PlayerInfo[playerid][pName], params);
        SendLocalMessage(playerid, COLOR_GREY, str, 20.0);
        return 1;
    }

    if(!strcmp(cmd, "/s", true)) {
        if(strlen(params) == 0) return SendClientMessage(playerid, COLOR_YELLOW, "Folosire: /s [strigat]");
        new str[144];
        format(str, sizeof(str), "%s striga: %s!", PlayerInfo[playerid][pName], params);
        SendLocalMessage(playerid, COLOR_WHITE, str, 40.0);
        return 1;
    }

    if(!strcmp(cmd, "/w", true)) {
        new targetid, text[100];
        if(sscanf_target_str(params, targetid, text)) {
            if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_RED, "Jucatorul nu este online!");
            new Float:x, Float:y, Float:z;
            GetPlayerPos(targetid, x, y, z);
            if(!IsPlayerInRangeOfPoint(playerid, 4.0, x, y, z)) return SendClientMessage(playerid, COLOR_RED, "Jucatorul este prea departe!");

            new str[144];
            format(str, sizeof(str), "[SOPTEAI LUI %s]: %s", PlayerInfo[targetid][pName], text);
            SendClientMessage(playerid, COLOR_YELLOW, str);
            format(str, sizeof(str), "[%s ITI SOPTESTE]: %s", PlayerInfo[playerid][pName], text);
            SendClientMessage(targetid, COLOR_YELLOW, str);
        } else {
            SendClientMessage(playerid, COLOR_YELLOW, "Folosire: /w [playerid] [mesaj]");
        }
        return 1;
    }

    if(!strcmp(cmd, "/pay", true)) {
        new targetid, amount;
        if(sscanf_custom(params, targetid, amount) && amount > 0) {
            if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_RED, "Jucatorul nu este online!");
            if(targetid == playerid) return SendClientMessage(playerid, COLOR_RED, "Nu iti poti transfera bani tie!");
            new Float:x, Float:y, Float:z;
            GetPlayerPos(targetid, x, y, z);
            if(!IsPlayerInRangeOfPoint(playerid, 5.0, x, y, z)) return SendClientMessage(playerid, COLOR_RED, "Jucatorul este prea departe!");
            if(GetPlayerMoney(playerid) < amount) return SendClientMessage(playerid, COLOR_RED, "Nu ai destui bani cash la tine!");

            GivePlayerMoney(playerid, -amount);
            GivePlayerMoney(targetid, amount);

            new str[144];
            format(str, sizeof(str), "* %s scoate niste bani si ii inmaneaza lui %s.", PlayerInfo[playerid][pName], PlayerInfo[targetid][pName]);
            SendLocalMessage(playerid, COLOR_PURPLE, str, 15.0);

            format(str, sizeof(str), "[PLATA] I-ai dat $%d lui %s.", amount, PlayerInfo[targetid][pName]);
            SendClientMessage(playerid, COLOR_GREEN, str);
            format(str, sizeof(str), "[PLATA] Ai primit $%d de la %s.", amount, PlayerInfo[playerid][pName]);
            SendClientMessage(targetid, COLOR_GREEN, str);

            SavePlayerData(playerid);
            SavePlayerData(targetid);
        } else {
            SendClientMessage(playerid, COLOR_YELLOW, "Folosire: /pay [playerid] [suma]");
        }
        return 1;
    }

    if(!strcmp(cmd, "/time", true)) {
        new hour, minute, second;
        gettime(hour, minute, second);
        new str[128];
        format(str, sizeof(str), "~y~ORA EXACTA~n~~w~%02d:%02d:%02d", hour, minute, second);
        GameTextForPlayer(playerid, str, 2500, 1);
        ApplyAnimation(playerid, "COP_AMBIENT", "Coplook_watch", 4.1, 0, 0, 0, 0, 0, 1);
        return 1;
    }

    if(!strcmp(cmd, "/id", true)) {
        new targetid = strval(params);
        if(IsPlayerConnected(targetid) && PlayerInfo[targetid][pLogged]) {
            new str[144];
            format(str, sizeof(str), "[JUCATOR] Nume: %s (ID: %d) | Nivel: %d | Grad Staff: %s", PlayerInfo[targetid][pName], targetid, GetPlayerScore(targetid), GetAdminRank(PlayerInfo[targetid][pAdmin]));
            SendClientMessage(playerid, COLOR_LIGHTBLUE, str);
        } else {
            SendClientMessage(playerid, COLOR_RED, "Jucatorul nu a fost gasit sau nu este logat!");
        }
        return 1;
    }

    if(!strcmp(cmd, "/admins", true)) {
        SendClientMessage(playerid, COLOR_YELLOW, "============= [ MEMBRI STAFF ONLINE ] =============");
        new count = 0;
        for(new i = 0; i < MAX_PLAYERS; i++) {
            if(IsPlayerConnected(i) && PlayerInfo[i][pAdmin] > 0) {
                new str[128];
                format(str, sizeof(str), "* %s %s (ID: %d)", GetAdminRank(PlayerInfo[i][pAdmin]), PlayerInfo[i][pName], i);
                SendClientMessage(playerid, COLOR_WHITE, str);
                count++;
            }
        }
        if(count == 0) {
            SendClientMessage(playerid, COLOR_GREY, "Niciun administrator online in acest moment.");
        }
        SendClientMessage(playerid, COLOR_YELLOW, "===================================================");
        return 1;
    }

    // Faction Vehicle Spawner & Controls
    if(!strcmp(cmd, "/fveh", true) || !strcmp(cmd, "/fv", true)) {
        if(PlayerInfo[playerid][pFaction] == FACTION_CIVILIAN) return SendClientMessage(playerid, COLOR_RED, "Nu faci parte dintr-o factiune!");
        if(!PlayerInfo[playerid][pDuty]) return SendClientMessage(playerid, COLOR_RED, "Trebuie sa fii la datorie (/duty)!");

        if(!strcmp(params, "despawn", true)) {
            if(PlayerFactionVeh[playerid] != INVALID_VEHICLE_ID) {
                DestroyVehicle(PlayerFactionVeh[playerid]);
                PlayerFactionVeh[playerid] = INVALID_VEHICLE_ID;
                SendClientMessage(playerid, COLOR_YELLOW, "[FACTIUNE] Vehiculul tau de serviciu a fost despawnat.");
            } else {
                SendClientMessage(playerid, COLOR_RED, "Nu ai niciun vehicul de factiune spawnat!");
            }
            return 1;
        }

        new vList[400];
        switch(PlayerInfo[playerid][pFaction]) {
            case FACTION_POLICE: format(vList, sizeof(vList), "1. Police Cruiser (LSPD/LVPD)\n2. Police Ranger SUV\n3. HPV-1000 Police Bike\n4. Enforcer SWAT");
            case FACTION_MEDIC: format(vList, sizeof(vList), "1. Ambulanta SMURD\n2. Paramedic SUV Ranger\n3. Elicopter Medical Raindance");
            case FACTION_FBI: format(vList, sizeof(vList), "1. FBI Rancher Negru\n2. FBI Truck Blindat\n3. Cheetah Undercover\n4. Sultan Undercover");
            case FACTION_MAFIA: format(vList, sizeof(vList), "1. Sultan Mafia Negru\n2. Huntley SUV Mafia\n3. Admiral Sedan\n4. Stretch Limuzina");
            case FACTION_HITMAN: format(vList, sizeof(vList), "1. Sentinel Hitman\n2. Sanchez Motorcross\n3. Elicopter Maverick Negru");
            case FACTION_NEWS: format(vList, sizeof(vList), "1. San News Van\n2. San News Chopper");
            case FACTION_TOW: format(vList, sizeof(vList), "1. Tow Truck Tractare\n2. Utility Van Asistenta");
        }
        ShowPlayerDialog(playerid, DIALOG_FACTION_VEHICLES, DIALOG_STYLE_LIST, "{00FF00}Garaj Vehicule Factiune", vList, "Spawneaza", "Inchide");
        return 1;
    }

    if(!strcmp(cmd, "/f", true)) {
        if(PlayerInfo[playerid][pFaction] == FACTION_CIVILIAN) return SendClientMessage(playerid, COLOR_RED, "Nu faci parte dintr-o factiune!");
        if(strlen(params) == 0) return SendClientMessage(playerid, COLOR_YELLOW, "Folosire: /f [mesaj]");

        new fmsg[144];
        format(fmsg, sizeof(fmsg), "[Radio Factiune] %s (Rank %d): %s", PlayerInfo[playerid][pName], PlayerInfo[playerid][pFactionRank], params);
        for(new i = 0; i < MAX_PLAYERS; i++) {
            if(IsPlayerConnected(i) && PlayerInfo[i][pFaction] == PlayerInfo[playerid][pFaction]) {
                SendClientMessage(i, COLOR_LIGHTBLUE, fmsg);
            }
        }
        return 1;
    }

    if(!strcmp(cmd, "/members", true)) {
        if(PlayerInfo[playerid][pFaction] == FACTION_CIVILIAN) return SendClientMessage(playerid, COLOR_RED, "Nu faci parte dintr-o factiune!");
        SendClientMessage(playerid, COLOR_CYAN, "========== [ MEMBRII FACTIUNII TALE ONLINE ] ==========");
        new count = 0;
        for(new i = 0; i < MAX_PLAYERS; i++) {
            if(IsPlayerConnected(i) && PlayerInfo[i][pFaction] == PlayerInfo[playerid][pFaction]) {
                new mstr[128];
                format(mstr, sizeof(mstr), "* %s (ID: %d) | Rank: %d | Status: %s",
                    PlayerInfo[i][pName], i, PlayerInfo[i][pFactionRank],
                    PlayerInfo[i][pDuty] ? ("{00FF00}ON DUTY{FFFFFF}") : ("{FF0000}OFF DUTY{FFFFFF}")
                );
                SendClientMessage(playerid, COLOR_WHITE, mstr);
                count++;
            }
        }
        return 1;
    }

    // DMV / Driving School Command
    if(!strcmp(cmd, "/dmv", true) || !strcmp(cmd, "/exam", true)) {
        if(PlayerInfo[playerid][pCarLic] == 1) return SendClientMessage(playerid, COLOR_GREEN, "[DMV] Ai deja un Permis de Conducere valabil!");
        if(pInExam[playerid]) return SendClientMessage(playerid, COLOR_YELLOW, "[DMV] Esti deja in timpul examenului auto! Condu prin checkpointuri.");
        if(GetPlayerMoney(playerid) < 500) return SendClientMessage(playerid, COLOR_RED, "[DMV] Taxa de examinare auto este de $500 cash!");
        if(!IsPlayerInRangeOfPoint(playerid, 65.0, 1098.0, 1375.0, 11.5)) {
            return SendClientMessage(playerid, COLOR_RED, "[DMV] Trebuie sa fii la Scoala de Soferi din Las Venturas! Tasteaza /gps.");
        }

        GivePlayerMoney(playerid, -500);
        PlayerInfo[playerid][pMoney] = GetPlayerMoney(playerid);

        new car = CreateVehicle(405, 1090.0, 1365.0, 10.82, 0.0, 1, 1, -1);
        VehicleFuel[car] = 100;
        VehicleEngine[car] = true;
        SetVehicleParamsEx(car, 1, 0, 0, 0, 0, 0, 0);
        pExamVehicle[playerid] = car;
        PutPlayerInVehicle(playerid, car, 0);

        pInExam[playerid] = true;
        pExamCP[playerid] = 0;
        SetPlayerCheckpoint(playerid, 1098.0, 1200.0, 10.82, 5.0);

        GameTextForPlayer(playerid, "~g~EXAMEN AUTO INCEPUT!~n~~w~Urmareste traseul", 4000, 3);
        SendClientMessage(playerid, COLOR_GREEN, "[DMV] Examenul auto a inceput! Condu cu grija prin cele 6 puncte fara sa distrugi masina.");
        return 1;
    }

    // Skin & Wardrobe Commands
    if(!strcmp(cmd, "/skin", true)) {
        if(PlayerInfo[playerid][pAdmin] >= 3 && strlen(params) > 0) {
            new sId = strval(params);
            if(sId < 0 || sId > 311) return SendClientMessage(playerid, COLOR_RED, "ID Skin invalid! (0 - 311)");
            PlayerInfo[playerid][pSkin] = sId;
            CivilianSkin[playerid] = sId;
            SetPlayerSkin(playerid, sId);
            SavePlayerData(playerid);
            SendClientMessage(playerid, COLOR_ADMIN, "[ADMIN] Ti-ai schimbat skinul cu succes!");
            return 1;
        }
        ShowPlayerDialog(playerid, DIALOG_CLOTHES_CAT, DIALOG_STYLE_LIST, "{FFFF00}Alege Categoria de Haine & Skin",
            "1. Costume Elegante & Business\n2. Haine Casual & Streetwear\n3. Gangster & Hip-Hop\n4. Mafie & Costume Negre\n5. Haine Femei & Modele",
            "Alege", "Iesi"
        );
        return 1;
    }

    if(!strcmp(cmd, "/clothes", true) || !strcmp(cmd, "/wardrobe", true)) {
        ShowPlayerDialog(playerid, DIALOG_CLOTHES_CAT, DIALOG_STYLE_LIST, "{FFFF00}Alege Categoria de Haine & Skin",
            "1. Costume Elegante & Business\n2. Haine Casual & Streetwear\n3. Gangster & Hip-Hop\n4. Mafie & Costume Negre\n5. Haine Femei & Modele",
            "Alege", "Iesi"
        );
        return 1;
    }

    // Admin Fly & Godmode
    if(!strcmp(cmd, "/fly", true)) {
        if(PlayerInfo[playerid][pAdmin] < 2) return SendClientMessage(playerid, COLOR_RED, "Nu ai permisiune!");
        pFlyMode[playerid] = !pFlyMode[playerid];
        if(pFlyMode[playerid]) {
            pGodMode[playerid] = true;
            GameTextForPlayer(playerid, "~g~FLY MODE ACTIV~n~~w~[W/Sprint] Zbor ~w~[Jump] Sus ~w~[Crouch] Jos", 4000, 3);
            SendClientMessage(playerid, COLOR_ADMIN, "[ADMIN] Fly Mode activat! Foloseste Space/Shift/C pentru a zbura liber.");
        } else {
            pGodMode[playerid] = false;
            SendClientMessage(playerid, COLOR_ADMIN, "[ADMIN] Fly Mode dezactivat.");
        }
        return 1;
    }

    if(!strcmp(cmd, "/god", true) || !strcmp(cmd, "/godmode", true)) {
        if(PlayerInfo[playerid][pAdmin] < 2) return SendClientMessage(playerid, COLOR_RED, "Nu ai permisiune!");
        pGodMode[playerid] = !pGodMode[playerid];
        SendClientMessage(playerid, COLOR_ADMIN, pGodMode[playerid] ? ("[ADMIN] Godmode ACTIVAT.") : ("[ADMIN] Godmode DEZACTIVAT."));
        return 1;
    }

    // Basic & Help Commands
    if(!strcmp(cmd, "/help", true) || !strcmp(cmd, "/comenzi", true)) {
        new helpMsg[1800];
        strcat(helpMsg, "{00FF00}Comenzi Generale & Roleplay:{FFFFFF}\n");
        strcat(helpMsg, "/me [actiune] | /do [stare] | /b [OOC] | /s [strigat] | /w [soapta]\n");
        strcat(helpMsg, "/pay [id] [suma] | /dice / /barbut [id] [suma] | /accept dice\n");
        strcat(helpMsg, "/jobs | /work | /quitjob (demisie) | /wanted (lista urmariti)\n");
        strcat(helpMsg, "/join / /particip - Inscrie-te la eventul activ\n");
        strcat(helpMsg, "/skin / /clothes / /wardrobe - Alege-ti hainele si skinul\n");
        strcat(helpMsg, "/dmv / /exam - Scoala de soferi Blackfield (Permis auto)\n");
        strcat(helpMsg, "/time | /id [id] | /admins | /stats | /gps | /bank | /atm\n\n");
        strcat(helpMsg, "{FFFF00}Vehicule & Masini (Tasta '2' = Motor | Tasta 'N' = Lock):{FFFFFF}\n");
        strcat(helpMsg, "/engine (sau tasta 2) - Porneste / opreste motorul\n");
        strcat(helpMsg, "/lock (sau tasta N) - Incuie / descuie usile\n");
        strcat(helpMsg, "/lights - Aprinde / stinge farurile\n");
        strcat(helpMsg, "/fill - Alimenteaza rezervorul la benzinarie\n");
        strcat(helpMsg, "/ds / /buycar - Dealership auto Las Venturas\n\n");
        if(PlayerInfo[playerid][pFaction] > 0) {
            strcat(helpMsg, "{0066FF}Comenzi Factiune:{FFFFFF}\n");
            strcat(helpMsg, "/duty - Intra / iesi din tura (activeaza uniforma & arme)\n");
            strcat(helpMsg, "/fveh / /fv - Garaj vehicule factiune | /fveh despawn\n");
            strcat(helpMsg, "/f [mesaj] - Statie radio factiune | /members - Membri online\n");
            if(PlayerInfo[playerid][pFaction] == FACTION_POLICE || PlayerInfo[playerid][pFaction] == FACTION_FBI) {
                strcat(helpMsg, "{0044FF}Politie & FBI:{FFFFFF} /su [id] [stele] [motiv] | /mdc [id] | /cuff | /uncuff\n");
                strcat(helpMsg, "/arrest [id] [min] | /ticket [id] [amenda] | /frisk [id] | /clear [id] | /raport\n");
            }
            strcat(helpMsg, "\n");
        }
        if(PlayerInfo[playerid][pVIP] >= 1 || PlayerInfo[playerid][pAdmin] >= 1) {
            strcat(helpMsg, "{FFD700}Sistem VIP:{FFFFFF}\n");
            strcat(helpMsg, "/vc [mesaj] - Chat VIP | /vips - Membrii VIP online\n\n");
        }
        if(PlayerInfo[playerid][pAdmin] >= 1) {
            strcat(helpMsg, "{00FFFF}Comenzi Staff / Administratori:{FFFFFF}\n");
            strcat(helpMsg, "Tasteaza {FFFF00}/ahelp{00FFFF} pentru panoul complet cu toate comenzile administrative.");
        }
        ShowPlayerDialog(playerid, DIALOG_HELP, DIALOG_STYLE_MSGBOX, "{00FF00}Meniu Ajutor Romania RealLife Las Venturas", helpMsg, "Inchide", "");
        return 1;
    }

    if(!strcmp(cmd, "/stats", true)) {
        new statsMsg[512];
        new jobStr[32], factionStr[32];
        switch(PlayerInfo[playerid][pJob]) {
            case JOB_NONE: jobStr = "Somer";
            case JOB_TRUCKER: jobStr = "Tirist (Trucker)";
            case JOB_PIZZA: jobStr = "Pizza Boy";
            case JOB_TAXI: jobStr = "Taximetrist";
            case JOB_GARBAGE: jobStr = "Gunoier";
        }
        switch(PlayerInfo[playerid][pFaction]) {
            case FACTION_CIVILIAN: factionStr = "Civil";
            case FACTION_POLICE: factionStr = "LSPD Officer";
            case FACTION_MEDIC: factionStr = "Medic Paramedic";
        }

        format(statsMsg, sizeof(statsMsg),
            "{FFFFFF}Nume: {FFFF00}%s{FFFFFF} | Nivel: {00FF00}%d{FFFFFF} | Ore Jucate: {00FF00}%d\n\
            Bani Cash: {00FF00}$%d{FFFFFF} | Bani in Banca: {00FF00}$%d\n\
            Loc de munca: {FFFF00}%s{FFFFFF} | Factiune: {0066FF}%s\n\
            Grad Staff: {FF0000}%s (Level %d){FFFFFF} | Statut VIP: {FFD700}%s\n\
            Kills: {FFFFFF}%d | Deaths: {FFFFFF}%d | Avertismente: {FF0000}%d/3\n\
            Permis Conducere: %s{FFFFFF} | Permis Port-Arma: %s",
            PlayerInfo[playerid][pName], GetPlayerScore(playerid), PlayerInfo[playerid][pHours],
            GetPlayerMoney(playerid), PlayerInfo[playerid][pBank],
            jobStr, factionStr,
            GetAdminRank(PlayerInfo[playerid][pAdmin]), PlayerInfo[playerid][pAdmin],
            PlayerInfo[playerid][pVIP] ? ("ACTIV") : ("Inactiv"),
            PlayerInfo[playerid][pKills], PlayerInfo[playerid][pDeaths], PlayerInfo[playerid][pWarns],
            PlayerInfo[playerid][pCarLic] ? ("{00FF00}DETINUT") : ("{FF0000}SUSPENDAT"),
            PlayerInfo[playerid][pGunLic] ? ("{00FF00}DETINUT") : ("{FF0000}LIPSA")
        );
        ShowPlayerDialog(playerid, DIALOG_STATS, DIALOG_STYLE_MSGBOX, "{00FF00}Profilul Tau", statsMsg, "Inchide", "");
        return 1;
    }

    if(!strcmp(cmd, "/gps", true)) {
        ShowPlayerDialog(playerid, DIALOG_GPS, DIALOG_STYLE_LIST, "{FFFF00}Sistem Navigatie GPS (Las Venturas)",
            "1. Hotel Las Venturas (Spawn Principal)\n2. Banca Las Venturas\n3. Departamentul de Politie (LVPD)\n4. Spitalul Judetean LV\n5. Targ Auto Dealership LV\n6. Scoala de Soferi (DMV Permis)\n7. Sediu Federal FBI\n8. Vila Mafia Strip Syndicate\n9. Agentia Secreta Hitman\n10. San News Reporters\n11. Depozit Tiristi K.A.C.C.\n12. Pizzeria Emerald Isle\n13. Depozit Taxi Starfish\n14. Depozit Gunoi & Mecanici\n15. Benzinarie The Strip\n16. Magazin Haine & Skin",
            "Selecteaza", "Anuleaza"
        );
        return 1;
    }

    if(!strcmp(cmd, "/bank", true) || !strcmp(cmd, "/atm", true)) {
        if(!IsPlayerInRangeOfPoint(playerid, 35.0, 2006.0, 1018.0, 10.82) && !IsPlayerInRangeOfPoint(playerid, 35.0, 2034.0, 1017.0, 10.82) && !IsPlayerInRangeOfPoint(playerid, 35.0, 2232.5, 2374.0, 10.82)) {
            return SendClientMessage(playerid, COLOR_RED, "[BANCA] Trebuie sa fii la Banca din Las Venturas sau la un bancomat/ATM!");
        }
        new bankMsg[256];
        format(bankMsg, sizeof(bankMsg), "1. Depunere Numerar\n2. Retragere Numerar\n3. Transfer Bancar\n\nSold Bancar Curent: {00FF00}$%d", PlayerInfo[playerid][pBank]);
        ShowPlayerDialog(playerid, DIALOG_BANK, DIALOG_STYLE_LIST, "{0066FF}Operatiuni Bancare", bankMsg, "Selecteaza", "Inchide");
        return 1;
    }

    if(!strcmp(cmd, "/ds", true) || !strcmp(cmd, "/buycar", true)) {
        if(!IsPlayerInRangeOfPoint(playerid, 45.0, 2130.0, 1395.0, 10.82)) {
            return SendClientMessage(playerid, COLOR_RED, "[DEALERSHIP] Trebuie sa fii la Dealership-ul din Las Venturas! Foloseste /gps.");
        }
        new catalogStr[800];
        for(new i = 0; i < sizeof(CarCatalog); i++) {
            new line[64];
            format(line, sizeof(line), "%s (%s) - {00FF00}$%d{FFFFFF}\n", CarCatalog[i][cName], CarCatalog[i][cCategory], CarCatalog[i][cPrice]);
            strcat(catalogStr, line);
        }
        ShowPlayerDialog(playerid, DIALOG_DEALERSHIP, DIALOG_STYLE_LIST, "{FFFF00}Catalog Auto Dealership", catalogStr, "Cumpara", "Iesi");
        return 1;
    }

    // Vehicle Control Commands
    if(!strcmp(cmd, "/engine", true)) {
        ToggleVehicleEngine(playerid);
        return 1;
    }

    if(!strcmp(cmd, "/lights", true)) {
        if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_RED, "Trebuie sa fii intr-un vehicul!");
        new veh = GetPlayerVehicleID(playerid);
        new engine, lights, alarm, doors, bonnet, boot, objective;
        GetVehicleParamsEx(veh, engine, lights, alarm, doors, bonnet, boot, objective);

        if(VehicleLights[veh]) {
            VehicleLights[veh] = false;
            SetVehicleParamsEx(veh, engine, 0, alarm, doors, bonnet, boot, objective);
            GameTextForPlayer(playerid, "~r~FARURI STINSE", 1500, 3);
        } else {
            VehicleLights[veh] = true;
            SetVehicleParamsEx(veh, engine, 1, alarm, doors, bonnet, boot, objective);
            GameTextForPlayer(playerid, "~g~FARURI APRINSE", 1500, 3);
        }
        return 1;
    }

    if(!strcmp(cmd, "/lock", true)) {
        new veh = GetNearestVehicle(playerid, 6.0);
        if(veh == INVALID_VEHICLE_ID) return SendClientMessage(playerid, COLOR_RED, "[MASINA] Nu esti langa niciun vehicul!");

        new pIdx = GetPersonalVehicleIndex(veh);
        if(pIdx != -1) {
            if(strcmp(VehicleInfo[pIdx][vOwner], PlayerInfo[playerid][pName]) != 0 && PlayerInfo[playerid][pAdmin] < 3) {
                return SendClientMessage(playerid, COLOR_RED, "[MASINA] Nu detii cheile acestui vehicul!");
            }

            new engine, lights, alarm, doors, bonnet, boot, objective;
            GetVehicleParamsEx(veh, engine, lights, alarm, doors, bonnet, boot, objective);

            if(VehicleInfo[pIdx][vLocked]) {
                VehicleInfo[pIdx][vLocked] = 0;
                SetVehicleParamsEx(veh, engine, lights, alarm, 0, bonnet, boot, objective);
                GameTextForPlayer(playerid, "~g~DESCUIAT", 1500, 3);
                PlayerPlaySound(playerid, 1145, 0.0, 0.0, 0.0);
                new str[128];
                format(str, sizeof(str), "* %s apasa pe telecomanda cheii si descuie masina.", PlayerInfo[playerid][pName]);
                SendLocalMessage(playerid, COLOR_PURPLE, str, 15.0);
            } else {
                VehicleInfo[pIdx][vLocked] = 1;
                SetVehicleParamsEx(veh, engine, lights, alarm, 1, bonnet, boot, objective);
                GameTextForPlayer(playerid, "~r~INCUIAT", 1500, 3);
                PlayerPlaySound(playerid, 1145, 0.0, 0.0, 0.0);
                new str[128];
                format(str, sizeof(str), "* %s apasa pe telecomanda cheii si incuie masina.", PlayerInfo[playerid][pName]);
                SendLocalMessage(playerid, COLOR_PURPLE, str, 15.0);
            }
            return 1;
        } else {
            SendClientMessage(playerid, COLOR_RED, "[MASINA] Acest vehicul nu are sistem de inchidere centralizata.");
        }
        return 1;
    }

    if(!strcmp(cmd, "/fill", true)) {
        if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_RED, "Trebuie sa fii intr-un vehicul!");
        new veh = GetPlayerVehicleID(playerid);
        if(!IsPlayerInRangeOfPoint(playerid, 35.0, 2115.0, 920.0, 10.82) && !IsPlayerInRangeOfPoint(playerid, 35.0, 2638.0, 1106.0, 10.82) && !IsPlayerInRangeOfPoint(playerid, 35.0, 2145.0, 2745.0, 10.82)) {
            return SendClientMessage(playerid, COLOR_RED, "[BENZINARIE] Nu esti la o statie de alimentare! Foloseste /gps.");
        }
        if(VehicleFuel[veh] >= 100) return SendClientMessage(playerid, COLOR_RED, "[BENZINARIE] Rezervorul este deja plin!");

        new cost = (100 - VehicleFuel[veh]) * 5;
        if(GetPlayerMoney(playerid) < cost) return SendClientMessage(playerid, COLOR_RED, "[BENZINARIE] Nu ai destui bani pentru a alimenta!");

        GivePlayerMoney(playerid, -cost);
        VehicleFuel[veh] = 100;
        new msg[128];
        format(msg, sizeof(msg), "[BENZINARIE] Ai alimentat rezervorul complet pentru $%d.", cost);
        SendClientMessage(playerid, COLOR_GREEN, msg);
        return 1;
    }

    // Job Commands
    if(!strcmp(cmd, "/jobs", true)) {
        ShowPlayerDialog(playerid, DIALOG_JOB, DIALOG_STYLE_LIST, "{00FF00}Agentia de Munca Las Venturas",
            "1. Tirist / Trucker (Salariu mare, depozit marfa K.A.C.C.)\n2. Pizza Boy (Livrare rapida in Emerald Isle)\n3. Taximetrist (Transport persoane cu tarif)\n4. Gunoier (Curatare pubele stradale)",
            "Angajare", "Anulare"
        );
        return 1;
    }

    if(!strcmp(cmd, "/work", true)) {
        switch(PlayerInfo[playerid][pJob]) {
            case JOB_NONE: {
                SendClientMessage(playerid, COLOR_RED, "[JOB] Nu ai un loc de munca! Foloseste /jobs pentru a te angaja.");
            }
            case JOB_TRUCKER: {
                if(!IsPlayerInRangeOfPoint(playerid, 50.0, 2755.0, 1350.0, 10.82)) {
                    return SendClientMessage(playerid, COLOR_RED, "[TRUCKER] Trebuie sa fii la depozitul de tiristi K.A.C.C. Las Venturas! Foloseste /gps.");
                }
                if(PlayerInfo[playerid][pWorkStage] == 1) return SendClientMessage(playerid, COLOR_RED, "[TRUCKER] Ai deja o cursa activa!");

                new Float:destX = 2115.0, Float:destY = 920.0, Float:destZ = 10.82; // Benzinarie Strip LV
                SetPlayerCheckpoint(playerid, destX, destY, destZ, 8.0);
                PlayerInfo[playerid][pWorkStage] = 1;

                new truck = CreateVehicle(515, 2750.0, 1345.0, 10.8, 180.0, 1, 1, 300);
                new trailer = CreateVehicle(435, 2750.0, 1365.0, 10.8, 180.0, 1, 1, 300);
                VehicleEngine[truck] = true;
                VehicleFuel[truck] = 100;
                PutPlayerInVehicle(playerid, truck, 0);
                AttachTrailerToVehicle(trailer, truck);

                PlayerInfo[playerid][pWorkVehicle] = truck;
                PlayerInfo[playerid][pWorkTrailer] = trailer;

                SendClientMessage(playerid, COLOR_GREEN, "[TRUCKER] Cursa a inceput! Condu pana la punctul rosu de pe radar (Benzinaria Strip) pentru a descarca marfa.");
            }
            case JOB_PIZZA: {
                if(!IsPlayerInRangeOfPoint(playerid, 35.0, 2100.0, 2225.0, 10.82)) {
                    return SendClientMessage(playerid, COLOR_RED, "[PIZZA] Trebuie sa fii la Pizzeria din Emerald Isle! Foloseste /gps.");
                }
                new Float:destX = 2110.0 + (random(120) - 60), Float:destY = 2360.0 + (random(120) - 60), Float:destZ = 10.82;
                SetPlayerCheckpoint(playerid, destX, destY, destZ, 4.0);
                PlayerInfo[playerid][pWorkStage] = 1;
                SendClientMessage(playerid, COLOR_GREEN, "[PIZZA] Ai preluat comanda de pizza! Du-o rapid la clientul marcat pe radar in Emerald Isle.");
            }
            case JOB_TAXI: {
                if(pTaxiRider[playerid] != INVALID_PLAYER_ID && IsPlayerConnected(pTaxiRider[playerid])) {
                    return SendClientMessage(playerid, COLOR_YELLOW, "[TAXI] Ai deja un pasager la bord! Asteapta sa coboare pentru plata.");
                }
                if(!IsPlayerInAnyVehicle(playerid)) {
                    return SendClientMessage(playerid, COLOR_RED, "[TAXI] Trebuie sa fii in masina de taxi! Dute la depozitul Starfish si prinde un pasager.");
                }
                SendClientMessage(playerid, COLOR_GREEN, "[TAXI] Mod taxi activ! Pasagerii care urca in taxiul tau platesc automat cursa la coborare.");
                SendClientMessage(playerid, COLOR_YELLOW, "[TAXI] Seteaza tariful cu /fare [suma] (minim $50, maxim $5000).");
            }
            case JOB_GARBAGE: {
                if(!IsPlayerInRangeOfPoint(playerid, 50.0, 2805.0, 970.0, 10.82)) {
                    return SendClientMessage(playerid, COLOR_RED, "[GUNOIER] Trebuie sa fii la Linden Station (Depozitul de gunoi)! Foloseste /gps.");
                }
                if(PlayerInfo[playerid][pWorkStage] >= 1) return SendClientMessage(playerid, COLOR_RED, "[GUNOIER] Ai deja o tura activa!");
                if(!IsPlayerInAnyVehicle(playerid)) {
                    return SendClientMessage(playerid, COLOR_RED, "[GUNOIER] Trebuie sa fii intr-un camion de gunoi (Trashmaster)!");
                }

                PlayerInfo[playerid][pWorkStage] = 1;
                SetPlayerCheckpoint(playerid, GarbageRoute[0][0], GarbageRoute[0][1], GarbageRoute[0][2], 6.0);
                SendClientMessage(playerid, COLOR_GREEN, "[GUNOIER] Tura a inceput! Urmareste checkpointurile rosii si colecteaza gunoiul din 5 puncte.");
            }
            default: {
                SendClientMessage(playerid, COLOR_YELLOW, "[JOB] Pentru jobul tau, urca intr-un vehicul specific si incepe activitatea.");
            }
        }
        return 1;
    }

    if(!strcmp(cmd, "/quitjob", true) || !strcmp(cmd, "/demisie", true)) {
        if(PlayerInfo[playerid][pJob] == JOB_NONE) {
            return SendClientMessage(playerid, COLOR_RED, "[JOB] Esti deja somer!");
        }
        PlayerInfo[playerid][pJob] = JOB_NONE;
        PlayerInfo[playerid][pWorkStage] = 0;
        if(PlayerInfo[playerid][pWorkVehicle]) {
            DestroyVehicle(PlayerInfo[playerid][pWorkVehicle]);
            PlayerInfo[playerid][pWorkVehicle] = 0;
        }
        if(PlayerInfo[playerid][pWorkTrailer]) {
            DestroyVehicle(PlayerInfo[playerid][pWorkTrailer]);
            PlayerInfo[playerid][pWorkTrailer] = 0;
        }
        DisablePlayerCheckpoint(playerid);
        SendClientMessage(playerid, COLOR_GREEN, "[JOB] Ti-ai dat demisia! Acum esti somer. Poti alege un nou loc de munca cu /jobs.");
        SavePlayerData(playerid);
        return 1;
    }

    if(!strcmp(cmd, "/duty", true)) {
        if(PlayerInfo[playerid][pFaction] == FACTION_CIVILIAN) {
            return SendClientMessage(playerid, COLOR_RED, "[EROARE] Nu faci parte dintr-o factiune oficiala!");
        }

        if(PlayerInfo[playerid][pDuty]) {
            PlayerInfo[playerid][pDuty] = 0;
            ResetPlayerWeapons(playerid);
            SetPlayerArmour(playerid, 0.0);
            SetPlayerColor(playerid, COLOR_WHITE);
            SetPlayerSkin(playerid, CivilianSkin[playerid]);
            SendClientMessage(playerid, COLOR_YELLOW, "[DUTY] Ai iesit din tura. Ai revenit la hainele tale civile.");
        } else {
            PlayerInfo[playerid][pDuty] = 1;
            CivilianSkin[playerid] = PlayerInfo[playerid][pSkin];

            switch(PlayerInfo[playerid][pFaction]) {
                case FACTION_POLICE: {
                    SetPlayerSkin(playerid, 282); // LVPD Officer
                    GivePlayerWeapon(playerid, 3, 1);    // Nightstick
                    GivePlayerWeapon(playerid, 24, 150); // Desert Eagle
                    GivePlayerWeapon(playerid, 29, 300); // MP5
                    GivePlayerWeapon(playerid, 31, 300); // M4
                    SetPlayerArmour(playerid, 100.0);
                    SetPlayerColor(playerid, COLOR_POLICE);
                    SendClientMessage(playerid, COLOR_BLUE, "[LVPD] Ai intrat in tura! Uniforma de politie si echipamentul au fost activate.");
                }
                case FACTION_MEDIC: {
                    SetPlayerSkin(playerid, 274); // Paramedic
                    SetPlayerHealth(playerid, 100.0);
                    SetPlayerArmour(playerid, 100.0);
                    SetPlayerColor(playerid, COLOR_MEDIC);
                    SendClientMessage(playerid, COLOR_MEDIC, "[SMURD] Ai intrat in tura medicala! Uniforma si trusa de prim ajutor sunt pregatite.");
                }
                case FACTION_FBI: {
                    SetPlayerSkin(playerid, 286); // FBI Suit
                    GivePlayerWeapon(playerid, 24, 200); // Deagle
                    GivePlayerWeapon(playerid, 29, 400); // MP5
                    GivePlayerWeapon(playerid, 31, 400); // M4
                    GivePlayerWeapon(playerid, 34, 50);  // Sniper
                    SetPlayerArmour(playerid, 100.0);
                    SetPlayerColor(playerid, COLOR_BLUE);
                    SendClientMessage(playerid, COLOR_BLUE, "[FBI] Ai intrat in tura! Insigna federala, costumul si armamentul tactic au fost echipate.");
                }
                case FACTION_MAFIA: {
                    SetPlayerSkin(playerid, 113); // Mafioso Suit
                    GivePlayerWeapon(playerid, 24, 150);
                    GivePlayerWeapon(playerid, 25, 100);
                    GivePlayerWeapon(playerid, 30, 300); // AK-47
                    SetPlayerArmour(playerid, 80.0);
                    SetPlayerColor(playerid, COLOR_ORANGE);
                    SendClientMessage(playerid, COLOR_ORANGE, "[MAFIA] Te-ai echipat pentru afacerile familiei! Ai primit costumul si armele.");
                }
                case FACTION_HITMAN: {
                    SetPlayerSkin(playerid, 165); // Hitman Suit
                    GivePlayerWeapon(playerid, 23, 200); // Silenced 9mm
                    GivePlayerWeapon(playerid, 34, 50);  // Sniper
                    GivePlayerWeapon(playerid, 4, 1);    // Knife
                    SetPlayerArmour(playerid, 100.0);
                    SetPlayerColor(playerid, COLOR_PURPLE);
                    SendClientMessage(playerid, COLOR_PURPLE, "[HITMAN] Modul Silent Assassin activat! Ai primit costumul si armele.");
                }
                case FACTION_NEWS: {
                    SetPlayerSkin(playerid, 187); // Reporter
                    GivePlayerWeapon(playerid, 43, 200); // Camera
                    SetPlayerColor(playerid, COLOR_YELLOW);
                    SendClientMessage(playerid, COLOR_YELLOW, "[SAN NEWS] Ai intrat in direct ca Reporter San News!");
                }
                case FACTION_TOW: {
                    SetPlayerSkin(playerid, 268); // Mechanic
                    SetPlayerColor(playerid, COLOR_YELLOW);
                    SendClientMessage(playerid, COLOR_YELLOW, "[MECANIC] Ai imbracat salopeta de mecanic! Poti interveni cu /fveh.");
                }
            }
        }
        return 1;
    }

    // ========================================================================
    //                        POLICE & WANTED SYSTEM COMMANDS
    // ========================================================================
    if(!strcmp(cmd, "/su", true)) {
        if(PlayerInfo[playerid][pFaction] != FACTION_POLICE && PlayerInfo[playerid][pFaction] != FACTION_FBI) {
            return SendClientMessage(playerid, COLOR_RED, "Doar fortele de ordine pot folosi /su!");
        }
        if(!PlayerInfo[playerid][pDuty]) {
            return SendClientMessage(playerid, COLOR_RED, "Trebuie sa fii la datorie (/duty)!");
        }
        new targetid, wantedStars, reason[64];
        if(sscanf_id_val_str(params, targetid, wantedStars, reason) && wantedStars >= 1 && wantedStars <= 6) {
            if(!IsPlayerConnected(targetid) || !PlayerInfo[targetid][pLogged]) {
                return SendClientMessage(playerid, COLOR_RED, "Jucatorul nu este online sau conectat!");
            }
            if(targetid == playerid) {
                return SendClientMessage(playerid, COLOR_RED, "Nu iti poti da singur wanted!");
            }

            PlayerInfo[targetid][pWanted] = wantedStars;
            SetPlayerWantedLevel(targetid, wantedStars);
            format(PlayerInfo[targetid][pCrimes], 64, "%s", reason);

            PlayerInfo[playerid][pRaport]++;
            SavePlayerData(playerid);
            SavePlayerData(targetid);

            new dMsg[144];
            format(dMsg, sizeof(dMsg), "[DISPECERAT] Ofiterul %s i-a acordat Wanted %d lui %s. Motiv: %s", PlayerInfo[playerid][pName], wantedStars, PlayerInfo[targetid][pName], reason);
            for(new i = 0; i < MAX_PLAYERS; i++) {
                if(IsPlayerConnected(i) && (PlayerInfo[i][pFaction] == FACTION_POLICE || PlayerInfo[i][pFaction] == FACTION_FBI)) {
                    SendClientMessage(i, COLOR_POLICE, dMsg);
                }
            }

            new sMsg[144];
            format(sMsg, sizeof(sMsg), "[POLITIE] Ai primit Wanted %d de la ofiterul %s. Motiv: %s", wantedStars, PlayerInfo[playerid][pName], reason);
            SendClientMessage(targetid, COLOR_RED, sMsg);
        } else {
            SendClientMessage(playerid, COLOR_YELLOW, "Folosire: /su [playerid] [wanted 1-6] [motiv]");
        }
        return 1;
    }

    if(!strcmp(cmd, "/wanted", true)) {
        new wList[1200];
        format(wList, sizeof(wList), "Nume\tWanted\tInfractiune\n");
        new count = 0;
        for(new i = 0; i < MAX_PLAYERS; i++) {
            if(IsPlayerConnected(i) && PlayerInfo[i][pLogged] && PlayerInfo[i][pWanted] > 0) {
                new row[128];
                format(row, sizeof(row), "%s (ID: %d)\t★ %d\t%s\n", PlayerInfo[i][pName], i, PlayerInfo[i][pWanted], PlayerInfo[i][pCrimes]);
                strcat(wList, row);
                count++;
            }
        }
        if(count == 0) {
            ShowPlayerDialog(playerid, DIALOG_WANTED, DIALOG_STYLE_MSGBOX, "{0066FF}Dispecerat Politie - Suspecti Urmariti", "{FFFFFF}Nu exista suspecti urmariti cu Wanted online in acest moment!", "Inchide", "");
        } else {
            ShowPlayerDialog(playerid, DIALOG_WANTED, DIALOG_STYLE_TABLIST_HEADERS, "{0066FF}Dispecerat Politie - Suspecti Urmariti", wList, "Inchide", "");
        }
        return 1;
    }

    if(!strcmp(cmd, "/mdc", true)) {
        if(PlayerInfo[playerid][pFaction] != FACTION_POLICE && PlayerInfo[playerid][pFaction] != FACTION_FBI) {
            return SendClientMessage(playerid, COLOR_RED, "Doar fortele de ordine pot accesa calculatorul politiei (MDC)!");
        }
        new targetid = strval(params);
        if(!IsPlayerConnected(targetid) || !PlayerInfo[targetid][pLogged]) {
            return SendClientMessage(playerid, COLOR_YELLOW, "Folosire: /mdc [playerid]");
        }

        new mdcInfo[512];
        format(mdcInfo, sizeof(mdcInfo),
            "{0066FF}========== [ BAZA DE DATE DEPARTAMENT DE POLITIE ] =========={FFFFFF}\n\n\
            Nume Cetatean: {FFFF00}%s{FFFFFF} (ID: %d)\n\
            Nivel Cautat (Wanted): {FF0000}★ %d{FFFFFF}\n\
            Ultima Fapta / Caz: {FFCC00}%s{FFFFFF}\n\
            Stare Catusa: %s{FFFFFF}\n\
            Permis Conducere: %s{FFFFFF}\n\
            Permis Port-Arma: %s{FFFFFF}\n\
            Cazier Condamnari: %s{FFFFFF}",
            PlayerInfo[targetid][pName], targetid,
            PlayerInfo[targetid][pWanted],
            PlayerInfo[targetid][pCrimes],
            pCuffed[targetid] ? ("{FF0000}INCATUSAT") : ("{00FF00}Liber"),
            PlayerInfo[targetid][pCarLic] ? ("{00FF00}VALID") : ("{FF0000}SUSPENDAT"),
            PlayerInfo[targetid][pGunLic] ? ("{00FF00}DETINUT") : ("{FF0000}FARA"),
            PlayerInfo[targetid][pJailed] ? ("{FF0000}DETINUT IN PENITENCIAR") : ("{00FF00}In libertate")
        );
        ShowPlayerDialog(playerid, DIALOG_MDC, DIALOG_STYLE_MSGBOX, "{0066FF}Mobile Data Computer (MDC)", mdcInfo, "Inchide", "");
        return 1;
    }

    if(!strcmp(cmd, "/cuff", true)) {
        if(PlayerInfo[playerid][pFaction] != FACTION_POLICE && PlayerInfo[playerid][pFaction] != FACTION_FBI) {
            return SendClientMessage(playerid, COLOR_RED, "Doar fortele de ordine pot folosi catusele!");
        }
        if(!PlayerInfo[playerid][pDuty]) return SendClientMessage(playerid, COLOR_RED, "Trebuie sa fii la datorie (/duty)!");
        new targetid = strval(params);
        if(!IsPlayerConnected(targetid) || targetid == playerid) return SendClientMessage(playerid, COLOR_YELLOW, "Folosire: /cuff [playerid]");

        new Float:x, Float:y, Float:z;
        GetPlayerPos(targetid, x, y, z);
        if(!IsPlayerInRangeOfPoint(playerid, 4.0, x, y, z)) return SendClientMessage(playerid, COLOR_RED, "Suspectul este prea departe!");
        if(pCuffed[targetid]) return SendClientMessage(playerid, COLOR_RED, "Suspectul este deja incatusat!");

        pCuffed[targetid] = true;
        TogglePlayerControllable(targetid, 0);
        SetPlayerSpecialAction(targetid, SPECIAL_ACTION_CUFFED);
        PlayerPlaySound(playerid, 1056, 0.0, 0.0, 0.0);
        PlayerPlaySound(targetid, 1056, 0.0, 0.0, 0.0);

        new str[144];
        format(str, sizeof(str), "* Ofiterul %s ii pune catusele la maini lui %s.", PlayerInfo[playerid][pName], PlayerInfo[targetid][pName]);
        SendLocalMessage(playerid, COLOR_PURPLE, str, 20.0);
        SendClientMessage(targetid, COLOR_RED, "[POLITIE] Ai fost incatusat! Nu te poti deplasa pana nu esti descatusat.");
        return 1;
    }

    if(!strcmp(cmd, "/uncuff", true)) {
        if(PlayerInfo[playerid][pFaction] != FACTION_POLICE && PlayerInfo[playerid][pFaction] != FACTION_FBI) {
            return SendClientMessage(playerid, COLOR_RED, "Doar fortele de ordine pot desface catusele!");
        }
        new targetid = strval(params);
        if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_YELLOW, "Folosire: /uncuff [playerid]");
        if(!pCuffed[targetid]) return SendClientMessage(playerid, COLOR_RED, "Jucatorul nu este incatusat!");

        pCuffed[targetid] = false;
        TogglePlayerControllable(targetid, 1);
        SetPlayerSpecialAction(targetid, SPECIAL_ACTION_NONE);

        new str[144];
        format(str, sizeof(str), "* Ofiterul %s desface catusele de la mainile lui %s.", PlayerInfo[playerid][pName], PlayerInfo[targetid][pName]);
        SendLocalMessage(playerid, COLOR_PURPLE, str, 20.0);
        SendClientMessage(targetid, COLOR_GREEN, "[POLITIE] Catusele ti-au fost desfacute!");
        return 1;
    }

    if(!strcmp(cmd, "/arrest", true)) {
        if(PlayerInfo[playerid][pFaction] != FACTION_POLICE && PlayerInfo[playerid][pFaction] != FACTION_FBI) {
            return SendClientMessage(playerid, COLOR_RED, "Doar fortele de ordine pot aresta suspecti!");
        }
        if(!PlayerInfo[playerid][pDuty]) return SendClientMessage(playerid, COLOR_RED, "Trebuie sa fii la datorie (/duty)!");
        new targetid, minutes;
        if(sscanf_custom(params, targetid, minutes) && minutes > 0) {
            if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_RED, "Jucatorul nu este online!");
            new Float:x, Float:y, Float:z;
            GetPlayerPos(targetid, x, y, z);
            if(!IsPlayerInRangeOfPoint(playerid, 6.0, x, y, z)) return SendClientMessage(playerid, COLOR_RED, "Suspectul este prea departe!");

            if(PlayerInfo[targetid][pWanted] <= 0) return SendClientMessage(playerid, COLOR_RED, "Suspectul nu are wanted!");

            pCuffed[targetid] = false;
            TogglePlayerControllable(targetid, 1);
            SetPlayerSpecialAction(targetid, SPECIAL_ACTION_NONE);

            PlayerInfo[targetid][pJailed] = 1;
            PlayerInfo[targetid][pJailTime] = minutes * 60;
            PlayerInfo[targetid][pWanted] = 0;
            SetPlayerWantedLevel(targetid, 0);
            ResetPlayerWeapons(targetid);
            SetPlayerInterior(targetid, 6);
            SetPlayerPos(targetid, 264.0, 77.0, 1001.0);

            PlayerInfo[playerid][pRaport]++;
            GivePlayerMoney(playerid, 1500);
            PlayerInfo[playerid][pMoney] = GetPlayerMoney(playerid);

            new amsg[144];
            format(amsg, sizeof(amsg), "[ARESTARE] Ofiterul %s l-a arestat pe suspectul %s pentru %d minute in penitenciar!", PlayerInfo[playerid][pName], PlayerInfo[targetid][pName], minutes);
            SendClientMessageToAll(COLOR_POLICE, amsg);

            SavePlayerData(playerid);
            SavePlayerData(targetid);
        } else {
            SendClientMessage(playerid, COLOR_YELLOW, "Folosire: /arrest [playerid] [minute]");
        }
        return 1;
    }

    if(!strcmp(cmd, "/ticket", true)) {
        if(PlayerInfo[playerid][pFaction] != FACTION_POLICE && PlayerInfo[playerid][pFaction] != FACTION_FBI) {
            return SendClientMessage(playerid, COLOR_RED, "Doar fortele de ordine pot acorda amenzi!");
        }
        if(!PlayerInfo[playerid][pDuty]) return SendClientMessage(playerid, COLOR_RED, "Trebuie sa fii la datorie (/duty)!");
        new targetid, fine, reason[64];
        if(sscanf_id_val_str(params, targetid, fine, reason) && fine > 0) {
            if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_RED, "Jucatorul nu este online!");
            new Float:x, Float:y, Float:z;
            GetPlayerPos(targetid, x, y, z);
            if(!IsPlayerInRangeOfPoint(playerid, 8.0, x, y, z)) return SendClientMessage(playerid, COLOR_RED, "Jucatorul este prea departe!");

            GivePlayerMoney(targetid, -fine);
            PlayerInfo[targetid][pMoney] = GetPlayerMoney(targetid);
            GivePlayerMoney(playerid, fine / 2);
            PlayerInfo[playerid][pMoney] = GetPlayerMoney(playerid);
            PlayerInfo[playerid][pRaport]++;

            new tmsg[144];
            format(tmsg, sizeof(tmsg), "[AMENDA] Ofiterul %s ti-a emis o amenda de $%d. Motiv: %s", PlayerInfo[playerid][pName], fine, reason);
            SendClientMessage(targetid, COLOR_RED, tmsg);

            format(tmsg, sizeof(tmsg), "[AMENDA] I-ai emis o amenda de $%d lui %s. (+1 Punct Raport)", fine, PlayerInfo[targetid][pName]);
            SendClientMessage(playerid, COLOR_GREEN, tmsg);

            SavePlayerData(playerid);
            SavePlayerData(targetid);
        } else {
            SendClientMessage(playerid, COLOR_YELLOW, "Folosire: /ticket [playerid] [amenda] [motiv]");
        }
        return 1;
    }

    if(!strcmp(cmd, "/frisk", true)) {
        if(PlayerInfo[playerid][pFaction] != FACTION_POLICE && PlayerInfo[playerid][pFaction] != FACTION_FBI) {
            return SendClientMessage(playerid, COLOR_RED, "Doar fortele de ordine pot perchezitiona!");
        }
        new targetid = strval(params);
        if(!IsPlayerConnected(targetid) || targetid == playerid) return SendClientMessage(playerid, COLOR_YELLOW, "Folosire: /frisk [playerid]");
        new Float:x, Float:y, Float:z;
        GetPlayerPos(targetid, x, y, z);
        if(!IsPlayerInRangeOfPoint(playerid, 5.0, x, y, z)) return SendClientMessage(playerid, COLOR_RED, "Jucatorul este prea departe!");

        new wep1, ammo1, wep2, ammo2, wep3, ammo3;
        GetPlayerWeaponData(targetid, 2, wep1, ammo1); // Slot handgun
        GetPlayerWeaponData(targetid, 4, wep2, ammo2); // Slot shotgun
        GetPlayerWeaponData(targetid, 5, wep3, ammo3); // Slot smg/ar

        new fStr[400];
        format(fStr, sizeof(fStr),
            "{FFFF00}Perchezitie corporala suspect: %s\n\n\
            Bani Cash: $%d\n\
            Permis Port-Arma: %s\n\
            Arma 1 (Pistol): ID %d (Gloante: %d)\n\
            Arma 2 (Shotgun): ID %d (Gloante: %d)\n\
            Arma 3 (Automat): ID %d (Gloante: %d)",
            PlayerInfo[targetid][pName],
            GetPlayerMoney(targetid),
            PlayerInfo[targetid][pGunLic] ? ("{00FF00}Legal") : ("{FF0000}ILEGAL / Fara Permis"),
            wep1, ammo1, wep2, ammo2, wep3, ammo3
        );
        ShowPlayerDialog(playerid, DIALOG_FRISK, DIALOG_STYLE_MSGBOX, "{0066FF}Raport Perchezitie Corporala", fStr, "Inchide", "");

        new rmsg[144];
        format(rmsg, sizeof(rmsg), "* Ofiterul %s il perchezitioneaza corporal pe %s.", PlayerInfo[playerid][pName], PlayerInfo[targetid][pName]);
        SendLocalMessage(playerid, COLOR_PURPLE, rmsg, 15.0);
        return 1;
    }

    if(!strcmp(cmd, "/clear", true)) {
        if(PlayerInfo[playerid][pFaction] != FACTION_POLICE && PlayerInfo[playerid][pFaction] != FACTION_FBI) {
            return SendClientMessage(playerid, COLOR_RED, "Doar fortele de ordine pot curata cazierul!");
        }
        new targetid = strval(params);
        if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_YELLOW, "Folosire: /clear [playerid]");

        PlayerInfo[targetid][pWanted] = 0;
        SetPlayerWantedLevel(targetid, 0);
        format(PlayerInfo[targetid][pCrimes], 64, "Niciuna");
        SavePlayerData(targetid);

        new cmsg[144];
        format(cmsg, sizeof(cmsg), "[POLITIE] Ofiterul %s i-a sters nivelul de urmarire lui %s.", PlayerInfo[playerid][pName], PlayerInfo[targetid][pName]);
        SendClientMessageToAll(COLOR_POLICE, cmsg);
        return 1;
    }

    if(!strcmp(cmd, "/raport", true)) {
        if(PlayerInfo[playerid][pFaction] != FACTION_POLICE && PlayerInfo[playerid][pFaction] != FACTION_FBI) {
            return SendClientMessage(playerid, COLOR_RED, "Doar membrii factiunilor de politie au acces la raport!");
        }
        new rapMsg[300];
        format(rapMsg, sizeof(rapMsg),
            "{0066FF}========== [ RAPORT ACTIVITATE POLITIE / FBI ] =========={FFFFFF}\n\n\
            Ofiter: {FFFF00}%s{FFFFFF}\n\
            Factiune: {0066FF}%s (Rank %d){FFFFFF}\n\
            Puncte Raport Acumulate: {00FF00}%d puncte{FFFFFF}\n\
            Target Minim Saptamanal: {FFFF00}25 puncte{FFFFFF}\n\
            Status Raport: %s",
            PlayerInfo[playerid][pName],
            (PlayerInfo[playerid][pFaction] == FACTION_POLICE) ? ("LVPD") : ("FBI"),
            PlayerInfo[playerid][pFactionRank],
            PlayerInfo[playerid][pRaport],
            (PlayerInfo[playerid][pRaport] >= 25) ? ("{00FF00}COMPLETAT - Felicitari!") : ("{FFCC00}IN DESFASURARE")
        );
        ShowPlayerDialog(playerid, DIALOG_RAPORT, DIALOG_STYLE_MSGBOX, "{0066FF}Raportul Meu de Activitate", rapMsg, "Inchide", "");
        return 1;
    }

    // Stores
    if(!strcmp(cmd, "/buy", true)) {
        ShowPlayerDialog(playerid, DIALOG_STORE, DIALOG_STYLE_LIST, "{00FF00}Magazin 24/7",
            "1. Trusa Medicala - $150\n2. Canistra de Benzina - $250\n3. Telefon Mobil - $500",
            "Cumpara", "Iesi"
        );
        return 1;
    }

    if(!strcmp(cmd, "/buygun", true)) {
        ShowPlayerDialog(playerid, DIALOG_AMMU, DIALOG_STYLE_LIST, "{FF0000}Ammu-Nation Los Santos",
            "1. Pistol 9mm (100 gloante) - $1,000\n2. Desert Eagle (75 gloante) - $3,500\n3. Shotgun (50 cartuse) - $2,500\n4. MP5 Submachine (150 cartuse) - $4,000\n5. Vesta Antiglont (100% Armour) - $1,500",
            "Cumpara", "Iesi"
        );
        return 1;
    }

    // ========================================================================
    //                        ADMIN & STAFF COMMANDS
    // ========================================================================

    if(!strcmp(cmd, "/ahelp", true)) {
        if(PlayerInfo[playerid][pAdmin] < 1) return SendClientMessage(playerid, COLOR_RED, "Nu ai acces la aceasta comanda!");
        new aMsg[900];
        strcat(aMsg, "{FF0000}Panou Comenzi Administrative & Staff:{FFFFFF}\n\n");
        strcat(aMsg, "{00FFC4}[L1 Helper]{FFFFFF}: /a, /spec [id], /specoff, /o [mesaj], /clearchat\n");
        if(PlayerInfo[playerid][pAdmin] >= 2) strcat(aMsg, "{00FFC4}[L2 Moderator]{FFFFFF}: /kick, /mute, /unmute, /freeze, /unfreeze, /slap, /jail, /fly, /god, /setfuel, /createevent, /startevent, /stopevent\n");
        if(PlayerInfo[playerid][pAdmin] >= 3) strcat(aMsg, "{00FFC4}[L3 Admin]{FFFFFF}: /ban [id] [motiv], /goto, /gethere, /sethp, /setarmour, /rac / /respawncars, /fix, /flip, /nos, /givegun, /settime, /setweather, /fillall\n");
        if(PlayerInfo[playerid][pAdmin] >= 4) strcat(aMsg, "{00FFC4}[L4 Senior Admin]{FFFFFF}: /veh, /destroyveh / /dv, /setskin, /setvip, /setfaction\n");
        if(PlayerInfo[playerid][pAdmin] >= 5) strcat(aMsg, "{00FFC4}[L5 Owner]{FFFFFF}: /makeadmin, /givemoney, /setleader [id] [factiune]\n");
        ShowPlayerDialog(playerid, DIALOG_ADMIN_PANEL, DIALOG_STYLE_MSGBOX, "{FF0000}Comenzi Staff Server", aMsg, "Inchide", "");
        return 1;
    }

    if(!strcmp(cmd, "/a", true)) {
        if(PlayerInfo[playerid][pAdmin] < 1) return SendClientMessage(playerid, COLOR_RED, "Nu ai acces la aceasta comanda!");
        if(strlen(params) == 0) return SendClientMessage(playerid, COLOR_RED, "Folosire: /a [mesaj]");

        new aMsg[144];
        format(aMsg, sizeof(aMsg), "[STAFF CHAT] %s %s: %s", GetAdminRank(PlayerInfo[playerid][pAdmin]), PlayerInfo[playerid][pName], params);
        for(new i = 0; i < MAX_PLAYERS; i++) {
            if(IsPlayerConnected(i) && PlayerInfo[i][pAdmin] >= 1) {
                SendClientMessage(i, COLOR_ADMIN, aMsg);
            }
        }
        return 1;
    }

    if(!strcmp(cmd, "/kick", true)) {
        if(PlayerInfo[playerid][pAdmin] < 2) return SendClientMessage(playerid, COLOR_RED, "Nu ai permisiunea necesara!");
        new targetid, reason[64];
        if(sscanf_target_str(params, targetid, reason)) {
            if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_RED, "Jucatorul nu este online!");
            new str[144];
            format(str, sizeof(str), "[ADMIN] %s a fost dat afara (KICK) de adminul %s. Motiv: %s", PlayerInfo[targetid][pName], PlayerInfo[playerid][pName], reason);
            SendClientMessageToAll(COLOR_RED, str);
            Kick(targetid);
        } else {
            SendClientMessage(playerid, COLOR_YELLOW, "Folosire: /kick [playerid] [motiv]");
        }
        return 1;
    }

    if(!strcmp(cmd, "/slap", true)) {
        if(PlayerInfo[playerid][pAdmin] < 2) return SendClientMessage(playerid, COLOR_RED, "Nu ai permisiunea necesara!");
        new targetid = strval(params);
        if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_RED, "Jucatorul nu este online!");

        new Float:x, Float:y, Float:z;
        GetPlayerPos(targetid, x, y, z);
        SetPlayerPos(targetid, x, y, z + 5.0);
        PlayerPlaySound(targetid, 1130, 0.0, 0.0, 0.0);
        SendClientMessage(playerid, COLOR_ADMIN, "I-ai dat slap jucatorului.");
        return 1;
    }

    if(!strcmp(cmd, "/freeze", true)) {
        if(PlayerInfo[playerid][pAdmin] < 2) return SendClientMessage(playerid, COLOR_RED, "Nu ai permisiunea necesara!");
        new targetid = strval(params);
        if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_RED, "Jucatorul nu este online!");
        TogglePlayerControllable(targetid, 0);
        SendClientMessage(targetid, COLOR_RED, "[ADMIN] Ai fost inghetat de catre un administrator!");
        SendClientMessage(playerid, COLOR_ADMIN, "Jucatorul a fost inghetat.");
        return 1;
    }

    if(!strcmp(cmd, "/unfreeze", true)) {
        if(PlayerInfo[playerid][pAdmin] < 2) return SendClientMessage(playerid, COLOR_RED, "Nu ai permisiunea necesara!");
        new targetid = strval(params);
        if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_RED, "Jucatorul nu este online!");
        TogglePlayerControllable(targetid, 1);
        SendClientMessage(targetid, COLOR_GREEN, "[ADMIN] Ai fost dezghetat.");
        SendClientMessage(playerid, COLOR_ADMIN, "Jucatorul a fost dezghetat.");
        return 1;
    }

    if(!strcmp(cmd, "/jail", true)) {
        if(PlayerInfo[playerid][pAdmin] < 2) return SendClientMessage(playerid, COLOR_RED, "Nu ai permisiunea necesara!");
        new targetid, minutes;
        if(sscanf_custom(params, targetid, minutes) && minutes > 0) {
            if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_RED, "Jucatorul nu este online!");
            PlayerInfo[targetid][pJailed] = 1;
            PlayerInfo[targetid][pJailTime] = minutes * 60;
            SetPlayerInterior(targetid, 6);
            SetPlayerPos(targetid, 264.0, 77.0, 1001.0);
            ResetPlayerWeapons(targetid);

            new str[144];
            format(str, sizeof(str), "[ADMIN] %s a fost trimis in inchisoare de %s pentru %d minute.", PlayerInfo[targetid][pName], PlayerInfo[playerid][pName], minutes);
            SendClientMessageToAll(COLOR_RED, str);
            SavePlayerData(targetid);
        } else {
            SendClientMessage(playerid, COLOR_YELLOW, "Folosire: /jail [playerid] [minute]");
        }
        return 1;
    }

    if(!strcmp(cmd, "/goto", true)) {
        if(PlayerInfo[playerid][pAdmin] < 3) return SendClientMessage(playerid, COLOR_RED, "Nu ai permisiunea necesara!");
        new targetid = strval(params);
        if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_RED, "Jucatorul nu este online!");

        new Float:x, Float:y, Float:z;
        GetPlayerPos(targetid, x, y, z);
        SetPlayerInterior(playerid, GetPlayerInterior(targetid));
        SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(targetid));
        SetPlayerPos(playerid, x + 1.0, y + 1.0, z);

        new msg[128];
        format(msg, sizeof(msg), "[ADMIN] Te-ai teleportat la jucatorul %s.", PlayerInfo[targetid][pName]);
        SendClientMessage(playerid, COLOR_ADMIN, msg);
        return 1;
    }

    if(!strcmp(cmd, "/gethere", true)) {
        if(PlayerInfo[playerid][pAdmin] < 3) return SendClientMessage(playerid, COLOR_RED, "Nu ai permisiunea necesara!");
        new targetid = strval(params);
        if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_RED, "Jucatorul nu este online!");

        new Float:x, Float:y, Float:z;
        GetPlayerPos(playerid, x, y, z);
        SetPlayerInterior(targetid, GetPlayerInterior(playerid));
        SetPlayerVirtualWorld(targetid, GetPlayerVirtualWorld(playerid));
        SetPlayerPos(targetid, x + 1.0, y + 1.0, z);

        new msg[128];
        format(msg, sizeof(msg), "[ADMIN] L-ai teleportat pe %s la pozitia ta.", PlayerInfo[targetid][pName]);
        SendClientMessage(playerid, COLOR_ADMIN, msg);
        return 1;
    }

    if(!strcmp(cmd, "/veh", true)) {
        if(PlayerInfo[playerid][pAdmin] < 3) return SendClientMessage(playerid, COLOR_RED, "Nu ai permisiunea necesara!");
        new modelid = strval(params);
        if(modelid < 400 || modelid > 611) return SendClientMessage(playerid, COLOR_RED, "ID model invalid! (400 - 611)");

        new Float:x, Float:y, Float:z, Float:a;
        GetPlayerPos(playerid, x, y, z);
        GetPlayerFacingAngle(playerid, a);

        new veh = CreateVehicle(modelid, x, y, z, a, random(126), random(126), -1);
        VehicleFuel[veh] = 100;
        VehicleEngine[veh] = true;
        VehicleLights[veh] = false;
        SetVehicleParamsEx(veh, 1, 0, 0, 0, 0, 0, 0); // Motor pornit direct!
        PutPlayerInVehicle(playerid, veh, 0);

        new msg[128];
        format(msg, sizeof(msg), "[ADMIN] Ai spawnat vehiculul %s (Model %d) cu motorul pornit si 100%% combustibil.", VehicleNames[modelid - 400], modelid);
        SendClientMessage(playerid, COLOR_ADMIN, msg);
        return 1;
    }

    if(!strcmp(cmd, "/makeadmin", true)) {
        if(PlayerInfo[playerid][pAdmin] < 5) return SendClientMessage(playerid, COLOR_RED, "Doar un Owner poate acorda functii de admin!");
        new targetid, level;
        if(sscanf_custom(params, targetid, level) && level >= 0 && level <= 5) {
            if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_RED, "Jucatorul nu este online!");
            PlayerInfo[targetid][pAdmin] = level;

            new str[144];
            format(str, sizeof(str), "[ADMIN] Ownerul %s i-a acordat lui %s gradul de Administrator Level %d.", PlayerInfo[playerid][pName], PlayerInfo[targetid][pName], level);
            SendClientMessageToAll(COLOR_ADMIN, str);
            SavePlayerData(targetid);
        } else {
            SendClientMessage(playerid, COLOR_YELLOW, "Folosire: /makeadmin [playerid] [nivel 0-5]");
        }
        return 1;
    }

    if(!strcmp(cmd, "/givemoney", true)) {
        if(PlayerInfo[playerid][pAdmin] < 5) return SendClientMessage(playerid, COLOR_RED, "Doar un Owner poate oferi bani!");
        new targetid, amount;
        if(sscanf_custom(params, targetid, amount) && amount > 0) {
            if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_RED, "Jucatorul nu este online!");
            GivePlayerMoney(targetid, amount);
            PlayerInfo[targetid][pMoney] = GetPlayerMoney(targetid);

            new str[144];
            format(str, sizeof(str), "[ADMIN] I-ai acordat $%d jucatorului %s.", amount, PlayerInfo[targetid][pName]);
            SendClientMessage(playerid, COLOR_ADMIN, str);

            format(str, sizeof(str), "[ADMIN] Ai primit $%d de la Administratorul %s.", amount, PlayerInfo[playerid][pName]);
            SendClientMessage(targetid, COLOR_GREEN, str);
            SavePlayerData(targetid);
        } else {
            SendClientMessage(playerid, COLOR_YELLOW, "Folosire: /givemoney [playerid] [suma]");
        }
        return 1;
    }

    if(!strcmp(cmd, "/setfaction", true)) {
        if(PlayerInfo[playerid][pAdmin] < 4) return SendClientMessage(playerid, COLOR_RED, "Nu ai acces!");
        new targetid, factionid;
        if(sscanf_custom(params, targetid, factionid) && factionid >= 0 && factionid <= 7) {
            if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_RED, "Jucatorul nu este online!");
            PlayerInfo[targetid][pFaction] = factionid;
            PlayerInfo[targetid][pFactionRank] = 1;
            PlayerInfo[targetid][pDuty] = 0;

            new str[144];
            format(str, sizeof(str), "[ADMIN] Administratorul %s i-a setat factiunea lui %s la ID %d (Rank 1).", PlayerInfo[playerid][pName], PlayerInfo[targetid][pName], factionid);
            SendClientMessageToAll(COLOR_ADMIN, str);
            SendClientMessage(targetid, COLOR_GREEN, "[FACTIUNE] Ai fost transferat intr-o noua factiune! Tasteaza /duty si /fveh.");
            SavePlayerData(targetid);
        } else {
            SendClientMessage(playerid, COLOR_YELLOW, "Folosire: /setfaction [playerid] [0=Civil, 1=LVPD, 2=SMURD, 3=FBI, 4=Mafia, 5=Hitman, 6=News, 7=Tow]");
        }
        return 1;
    }

    // ========================================================================
    //                        NEW ROLEPLAY & GAME SYSTEMS
    // ========================================================================

    // 1. Admin Fuel & Vehicle Controls
    if(!strcmp(cmd, "/setfuel", true) || !strcmp(cmd, "/fuel", true)) {
        if(PlayerInfo[playerid][pAdmin] < 2) return SendClientMessage(playerid, COLOR_RED, "Nu ai permisiunea necesara!");
        new targetVeh = 0, amount = 100;
        if(IsPlayerInAnyVehicle(playerid) && strlen(params) > 0 && strfind(params, " ") == -1) {
            amount = strval(params);
            targetVeh = GetPlayerVehicleID(playerid);
        } else if(sscanf_custom(params, targetVeh, amount)) {
            // /setfuel [vehid] [procent]
        } else if(IsPlayerInAnyVehicle(playerid)) {
            amount = strval(params);
            targetVeh = GetPlayerVehicleID(playerid);
        } else {
            return SendClientMessage(playerid, COLOR_YELLOW, "Folosire: /setfuel [procent 0-100] (in masina) SAU /setfuel [vehid] [procent]");
        }

        if(amount < 0) amount = 0;
        if(amount > 100) amount = 100;
        if(targetVeh <= 0 || targetVeh >= MAX_VEHICLES) return SendClientMessage(playerid, COLOR_RED, "ID vehicul invalid!");

        VehicleFuel[targetVeh] = amount;
        new fmsg[128];
        format(fmsg, sizeof(fmsg), "[ADMIN] Benzina pentru vehiculul ID %d a fost setata la %d%%.", targetVeh, amount);
        SendClientMessage(playerid, COLOR_ADMIN, fmsg);
        return 1;
    }

    if(!strcmp(cmd, "/fillcar", true)) {
        if(PlayerInfo[playerid][pAdmin] < 1) return SendClientMessage(playerid, COLOR_RED, "Nu ai permisiune!");
        if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_RED, "Trebuie sa fii intr-un vehicul!");
        new veh = GetPlayerVehicleID(playerid);
        VehicleFuel[veh] = 100;
        SendClientMessage(playerid, COLOR_ADMIN, "[ADMIN] Vehiculul a fost alimentat complet la 100%!");
        return 1;
    }

    if(!strcmp(cmd, "/fillall", true) || !strcmp(cmd, "/fuelall", true)) {
        if(PlayerInfo[playerid][pAdmin] < 3) return SendClientMessage(playerid, COLOR_RED, "Nu ai permisiune!");
        for(new v = 1; v < MAX_VEHICLES; v++) {
            VehicleFuel[v] = 100;
        }
        SendClientMessageToAll(COLOR_ADMIN, "[SERVER] Un administrator a realimentat toate vehiculele de pe server la 100%!");
        return 1;
    }

    if(!strcmp(cmd, "/fix", true) || !strcmp(cmd, "/repair", true)) {
        if(PlayerInfo[playerid][pAdmin] < 1) return SendClientMessage(playerid, COLOR_RED, "Nu ai permisiune!");
        if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_RED, "Trebuie sa fii intr-un vehicul!");
        new veh = GetPlayerVehicleID(playerid);
        RepairVehicle(veh);
        SetVehicleHealth(veh, 1000.0);
        SendClientMessage(playerid, COLOR_ADMIN, "[VEHICUL] Vehiculul a fost reparat complet!");
        return 1;
    }

    if(!strcmp(cmd, "/flip", true)) {
        if(PlayerInfo[playerid][pAdmin] < 1) return SendClientMessage(playerid, COLOR_RED, "Nu ai permisiune!");
        if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_RED, "Trebuie sa fii intr-un vehicul!");
        new veh = GetPlayerVehicleID(playerid);
        new Float:a;
        GetVehicleZAngle(veh, a);
        SetVehicleZAngle(veh, a);
        SendClientMessage(playerid, COLOR_ADMIN, "[VEHICUL] Vehiculul a fost intors pe roti!");
        return 1;
    }

    if(!strcmp(cmd, "/nos", true) || !strcmp(cmd, "/nitro", true)) {
        if(PlayerInfo[playerid][pAdmin] < 2) return SendClientMessage(playerid, COLOR_RED, "Nu ai permisiune!");
        if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_RED, "Trebuie sa fii intr-un vehicul!");
        new veh = GetPlayerVehicleID(playerid);
        AddVehicleComponent(veh, 1010);
        SendClientMessage(playerid, COLOR_ADMIN, "[VEHICUL] Ai adaugat Nitro x10 pe vehicul!");
        return 1;
    }

    // 2. Event System Commands
    if(!strcmp(cmd, "/createevent", true) || !strcmp(cmd, "/event", true)) {
        if(PlayerInfo[playerid][pAdmin] < 2) return SendClientMessage(playerid, COLOR_RED, "Nu ai permisiune!");
        if(gEventActive != 0) return SendClientMessage(playerid, COLOR_RED, "Un event este deja activ! Foloseste /stopevent pentru a-l opri.");

        ShowPlayerDialog(playerid, DIALOG_EVENT_CREATE, DIALOG_STYLE_LIST, "{00FF00}Creaza un Event",
            "1. Deagle Arena (Duel 1v1 / FFA - Premiu $50,000)\n            2. Last Man Standing - LMS (M4 + Shotgun - Premiu $75,000)\n            3. Derby Demolition (Monster Trucks - Premiu $50,000)\n            4. Supercar Race (Infernus Sprint - Premiu $60,000)",
            "Alege", "Anuleaza"
        );
        return 1;
    }

    if(!strcmp(cmd, "/join", true) || !strcmp(cmd, "/particip", true) || !strcmp(cmd, "/joinevent", true)) {
        if(gEventActive != 1) return SendClientMessage(playerid, COLOR_RED, "Nu exista niciun event deschis pentru inscrieri!");
        if(pInEvent[playerid]) return SendClientMessage(playerid, COLOR_YELLOW, "Esti deja inscris la event!");

        pInEvent[playerid] = true;
        gEventParticipants++;

        ResetPlayerWeapons(playerid);
        SetPlayerHealth(playerid, 100.0);
        SetPlayerArmour(playerid, 100.0);
        SetPlayerInterior(playerid, 0);
        SetPlayerVirtualWorld(playerid, 100);

        // Teleport to staging area at Verdant Meadows airstrip
        new Float:offsetX = (gEventParticipants % 5) * 4.0;
        new Float:offsetY = (gEventParticipants / 5) * 4.0;
        SetPlayerPos(playerid, 400.0 + offsetX, 2520.0 + offsetY, 16.6);
        SetPlayerFacingAngle(playerid, 90.0);
        TogglePlayerControllable(playerid, 0); // Freeze until start

        GameTextForPlayer(playerid, "~g~TE-AI INSCRI LA EVENT!~n~~w~Asteapta startul.", 3000, 3);

        new emsg[144];
        format(emsg, sizeof(emsg), "[EVENT] Jucatorul %s s-a alaturat eventului! Total inscrisi: %d.", PlayerInfo[playerid][pName], gEventParticipants);
        SendClientMessageToAll(COLOR_YELLOW, emsg);
        return 1;
    }

    if(!strcmp(cmd, "/startevent", true)) {
        if(PlayerInfo[playerid][pAdmin] < 2) return SendClientMessage(playerid, COLOR_RED, "Nu ai permisiune!");
        if(gEventActive != 1) return SendClientMessage(playerid, COLOR_RED, "Nu exista un event deschis pentru start!");
        if(gEventParticipants < 1) return SendClientMessage(playerid, COLOR_RED, "Nu sunt suficienti participanti inscrisi!");

        gEventActive = 2; // In progress

        for(new i = 0; i < MAX_PLAYERS; i++) {
            if(IsPlayerConnected(i) && pInEvent[i]) {
                TogglePlayerControllable(i, 1);
                SetPlayerHealth(i, 100.0);
                SetPlayerArmour(i, 100.0);

                switch(gEventType) {
                    case EVENT_DEAGLE: {
                        GivePlayerWeapon(i, 24, 500); // Desert Eagle
                    }
                    case EVENT_LMS: {
                        GivePlayerWeapon(i, 31, 600); // M4
                        GivePlayerWeapon(i, 25, 200); // Shotgun
                    }
                    case EVENT_DERBY: {
                        new Float:x, Float:y, Float:z;
                        GetPlayerPos(i, x, y, z);
                        new car = CreateVehicle(444, x, y, z, 90.0, random(126), random(126), -1);
                        VehicleFuel[car] = 100;
                        VehicleEngine[car] = true;
                        SetVehicleParamsEx(car, 1, 0, 0, 0, 0, 0, 0);
                        EventVehicle[i] = car;
                        SetVehicleVirtualWorld(car, 100);
                        PutPlayerInVehicle(i, car, 0);
                    }
                    case EVENT_RACE: {
                        new Float:x, Float:y, Float:z;
                        GetPlayerPos(i, x, y, z);
                        new car = CreateVehicle(411, x, y, z, 90.0, random(126), random(126), -1); // Infernus
                        VehicleFuel[car] = 100;
                        VehicleEngine[car] = true;
                        SetVehicleParamsEx(car, 1, 0, 0, 0, 0, 0, 0);
                        EventVehicle[i] = car;
                        SetVehicleVirtualWorld(car, 100);
                        PutPlayerInVehicle(i, car, 0);
                    }
                }
                GameTextForPlayer(i, "~g~START EVENT! SUCCES!", 3000, 3);
                PlayerPlaySound(i, 1057, 0.0, 0.0, 0.0);
            }
        }

        SendClientMessageToAll(COLOR_GREEN, "[EVENT] Administratorul a dat START la event! Succes tuturor participantilor!");
        return 1;
    }

    if(!strcmp(cmd, "/stopevent", true) || !strcmp(cmd, "/cancelevent", true)) {
        if(PlayerInfo[playerid][pAdmin] < 2) return SendClientMessage(playerid, COLOR_RED, "Nu ai permisiune!");
        if(gEventActive == 0) return SendClientMessage(playerid, COLOR_RED, "Nu este niciun event activ!");

        for(new i = 0; i < MAX_PLAYERS; i++) {
            if(IsPlayerConnected(i) && pInEvent[i]) {
                pInEvent[i] = false;
                if(EventVehicle[i] != INVALID_VEHICLE_ID) {
                    DestroyVehicle(EventVehicle[i]);
                    EventVehicle[i] = INVALID_VEHICLE_ID;
                }
                ResetPlayerWeapons(i);
                SetPlayerInterior(i, 0);
                SetPlayerVirtualWorld(i, 0);
                SetPlayerPos(i, 2232.5, 2374.0, 10.82);
                SetPlayerFacingAngle(i, 90.0);
                TogglePlayerControllable(i, 1);
                SendClientMessage(i, COLOR_YELLOW, "[EVENT] Ai fost repus la spawn deoarece eventul a fost oprit.");
            }
        }
        gEventActive = 0;
        gEventParticipants = 0;
        gEventType = EVENT_NONE;
        SendClientMessageToAll(COLOR_ADMIN, "[EVENT] Eventul curent a fost oprit de un administrator.");
        return 1;
    }

    // 3. Dice / Barbut System
    if(!strcmp(cmd, "/dice", true) || !strcmp(cmd, "/barbut", true)) {
        new targetid, amount;
        if(sscanf_custom(params, targetid, amount) && amount > 0) {
            if(!IsPlayerConnected(targetid) || targetid == playerid) return SendClientMessage(playerid, COLOR_RED, "Jucator invalid!");
            if(GetPlayerMoney(playerid) < amount) return SendClientMessage(playerid, COLOR_RED, "Nu ai suficienti bani cash!");
            if(GetPlayerMoney(targetid) < amount) return SendClientMessage(playerid, COLOR_RED, "Adversarul nu are suficienti bani cash!");

            new Float:x, Float:y, Float:z;
            GetPlayerPos(targetid, x, y, z);
            if(!IsPlayerInRangeOfPoint(playerid, 6.0, x, y, z)) return SendClientMessage(playerid, COLOR_RED, "Trebuie sa fii langa jucator!");

            DiceChallenger[targetid] = playerid;
            DiceBet[targetid] = amount;

            new dstr[144];
            format(dstr, sizeof(dstr), "[BARBUT] L-ai provocat pe %s la barbut pe suma de $%d.", PlayerInfo[targetid][pName], amount);
            SendClientMessage(playerid, COLOR_YELLOW, dstr);

            format(dstr, sizeof(dstr), "[BARBUT] %s te provoaca la zaruri pe suma de $%d! Tasteaza /accept dice pentru a juca.", PlayerInfo[playerid][pName], amount);
            SendClientMessage(targetid, COLOR_GREEN, dstr);
        } else {
            SendClientMessage(playerid, COLOR_YELLOW, "Folosire: /dice [playerid] [suma]");
        }
        return 1;
    }

    if(!strcmp(cmd, "/accept", true)) {
        if(!strcmp(params, "dice", true) || !strcmp(params, "barbut", true)) {
            new challenger = DiceChallenger[playerid];
            if(challenger == INVALID_PLAYER_ID || !IsPlayerConnected(challenger)) {
                return SendClientMessage(playerid, COLOR_RED, "Nu ai nicio cerere activa de barbut!");
            }
            new amount = DiceBet[playerid];
            if(GetPlayerMoney(playerid) < amount || GetPlayerMoney(challenger) < amount) {
                DiceChallenger[playerid] = INVALID_PLAYER_ID;
                return SendClientMessage(playerid, COLOR_RED, "Unul dintre jucatori nu mai are suma necesara!");
            }

            new Float:x, Float:y, Float:z;
            GetPlayerPos(challenger, x, y, z);
            if(!IsPlayerInRangeOfPoint(playerid, 6.0, x, y, z)) {
                return SendClientMessage(playerid, COLOR_RED, "Adversarul este prea departe!");
            }

            // Roll Dice (1 - 6)
            new roll1 = random(6) + 1;
            new roll2 = random(6) + 1;

            PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
            PlayerPlaySound(challenger, 1052, 0.0, 0.0, 0.0);

            new rmsg[144];
            format(rmsg, sizeof(rmsg), "* %s a dat zarul si a picat: [ %d ]! %s a dat zarul si a picat: [ %d ]!", PlayerInfo[challenger][pName], roll1, PlayerInfo[playerid][pName], roll2);
            SendLocalMessage(playerid, COLOR_PURPLE, rmsg, 20.0);

            if(roll1 > roll2) {
                GivePlayerMoney(challenger, amount);
                GivePlayerMoney(playerid, -amount);
                PlayerInfo[challenger][pMoney] = GetPlayerMoney(challenger);
                PlayerInfo[playerid][pMoney] = GetPlayerMoney(playerid);
                SavePlayerData(challenger);
                SavePlayerData(playerid);
                format(rmsg, sizeof(rmsg), "[BARBUT] %s a CASTIGAT potul de $%d!", PlayerInfo[challenger][pName], amount * 2);
                SendLocalMessage(playerid, COLOR_GREEN, rmsg, 20.0);
            } else if(roll2 > roll1) {
                GivePlayerMoney(playerid, amount);
                GivePlayerMoney(challenger, -amount);
                PlayerInfo[playerid][pMoney] = GetPlayerMoney(playerid);
                PlayerInfo[challenger][pMoney] = GetPlayerMoney(challenger);
                SavePlayerData(playerid);
                SavePlayerData(challenger);
                format(rmsg, sizeof(rmsg), "[BARBUT] %s a CASTIGAT potul de $%d!", PlayerInfo[playerid][pName], amount * 2);
                SendLocalMessage(playerid, COLOR_GREEN, rmsg, 20.0);
            } else {
                SendLocalMessage(playerid, COLOR_YELLOW, "[BARBUT] Egalitate! Niciun jucator nu a pierdut bani.", 20.0);
            }

            DiceChallenger[playerid] = INVALID_PLAYER_ID;
            DiceBet[playerid] = 0;
            return 1;
        }
        SendClientMessage(playerid, COLOR_YELLOW, "Folosire: /accept dice");
        return 1;
    }

    // 4. Server Utilities & Staff Commands
    if(!strcmp(cmd, "/clearchat", true) || !strcmp(cmd, "/cc", true)) {
        if(PlayerInfo[playerid][pAdmin] < 1) return SendClientMessage(playerid, COLOR_RED, "Nu ai permisiune!");
        for(new i = 0; i < 50; i++) SendClientMessageToAll(COLOR_WHITE, " ");
        new ccmsg[128];
        format(ccmsg, sizeof(ccmsg), "[SERVER] Chatul a fost curatat de administratorul %s.", PlayerInfo[playerid][pName]);
        SendClientMessageToAll(COLOR_ADMIN, ccmsg);
        return 1;
    }

    if(!strcmp(cmd, "/o", true) || !strcmp(cmd, "/ooc", true)) {
        if(PlayerInfo[playerid][pAdmin] < 1) return SendClientMessage(playerid, COLOR_RED, "Nu ai permisiune!");
        if(strlen(params) == 0) return SendClientMessage(playerid, COLOR_YELLOW, "Folosire: /o [mesaj global]");

        new oMsg[144];
        format(oMsg, sizeof(oMsg), "(( [ANUNT GLOBAL STAFF] %s %s: %s ))", GetAdminRank(PlayerInfo[playerid][pAdmin]), PlayerInfo[playerid][pName], params);
        SendClientMessageToAll(COLOR_CYAN, oMsg);
        return 1;
    }

    if(!strcmp(cmd, "/spec", true)) {
        if(PlayerInfo[playerid][pAdmin] < 1) return SendClientMessage(playerid, COLOR_RED, "Nu ai permisiune!");
        new targetid = strval(params);
        if(!IsPlayerConnected(targetid) || targetid == playerid) return SendClientMessage(playerid, COLOR_YELLOW, "Folosire: /spec [playerid]");

        pSpecTarget[playerid] = targetid;
        TogglePlayerSpectating(playerid, 1);
        SetPlayerInterior(playerid, GetPlayerInterior(targetid));
        SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(targetid));

        if(IsPlayerInAnyVehicle(targetid)) {
            PlayerSpectateVehicle(playerid, GetPlayerVehicleID(targetid));
        } else {
            PlayerSpectatePlayer(playerid, targetid);
        }
        new sMsg[128];
        format(sMsg, sizeof(sMsg), "[ADMIN] Mod spectator pe %s (ID: %d). Tasteaza /specoff pentru a reveni.", PlayerInfo[targetid][pName], targetid);
        SendClientMessage(playerid, COLOR_ADMIN, sMsg);
        return 1;
    }

    if(!strcmp(cmd, "/specoff", true)) {
        if(PlayerInfo[playerid][pAdmin] < 1) return SendClientMessage(playerid, COLOR_RED, "Nu ai permisiune!");
        pSpecTarget[playerid] = INVALID_PLAYER_ID;
        TogglePlayerSpectating(playerid, 0);
        SetPlayerInterior(playerid, 0);
        SetPlayerVirtualWorld(playerid, 0);
        SetPlayerPos(playerid, 2110.0, 2360.0, 10.82);
        SetPlayerFacingAngle(playerid, 90.0);
        SendClientMessage(playerid, COLOR_ADMIN, "[ADMIN] Ai oprit modul spectator.");
        return 1;
    }

    if(!strcmp(cmd, "/mute", true)) {
        if(PlayerInfo[playerid][pAdmin] < 2) return SendClientMessage(playerid, COLOR_RED, "Nu ai permisiune!");
        new targetid, minutes, reason[64];
        if(sscanf_id_val_str(params, targetid, minutes, reason) && minutes > 0) {
            if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_RED, "Jucatorul nu este online!");
            PlayerInfo[targetid][pMuted] = 1;
            PlayerInfo[targetid][pMuteTime] = minutes * 60;
            SavePlayerData(targetid);

            new mMsg[144];
            format(mMsg, sizeof(mMsg), "[ADMIN] %s a fost redus la tacere (MUTE) de %s pentru %d minute. Motiv: %s", PlayerInfo[targetid][pName], PlayerInfo[playerid][pName], minutes, reason);
            SendClientMessageToAll(COLOR_RED, mMsg);
        } else {
            SendClientMessage(playerid, COLOR_YELLOW, "Folosire: /mute [playerid] [minute] [motiv]");
        }
        return 1;
    }

    if(!strcmp(cmd, "/unmute", true)) {
        if(PlayerInfo[playerid][pAdmin] < 2) return SendClientMessage(playerid, COLOR_RED, "Nu ai permisiune!");
        new targetid = strval(params);
        if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_YELLOW, "Folosire: /unmute [playerid]");
        if(!PlayerInfo[targetid][pMuted]) return SendClientMessage(playerid, COLOR_RED, "Jucatorul nu este mutat!");

        PlayerInfo[targetid][pMuted] = 0;
        PlayerInfo[targetid][pMuteTime] = 0;
        SavePlayerData(targetid);

        new uMsg[144];
        format(uMsg, sizeof(uMsg), "[ADMIN] %s a primit unmute de la administratorul %s.", PlayerInfo[targetid][pName], PlayerInfo[playerid][pName]);
        SendClientMessageToAll(COLOR_GREEN, uMsg);
        return 1;
    }

    if(!strcmp(cmd, "/ban", true)) {
        if(PlayerInfo[playerid][pAdmin] < 3) return SendClientMessage(playerid, COLOR_RED, "Nu ai permisiune!");
        new targetid, reason[64];
        if(sscanf_target_str(params, targetid, reason)) {
            if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_RED, "Jucatorul nu este online!");
            new bMsg[144];
            format(bMsg, sizeof(bMsg), "[BAN] %s a fost banat permanent de administratorul %s. Motiv: %s", PlayerInfo[targetid][pName], PlayerInfo[playerid][pName], reason);
            SendClientMessageToAll(COLOR_RED, bMsg);
            BanEx(targetid, reason);
        } else {
            SendClientMessage(playerid, COLOR_YELLOW, "Folosire: /ban [playerid] [motiv]");
        }
        return 1;
    }

    if(!strcmp(cmd, "/rac", true) || !strcmp(cmd, "/respawncars", true)) {
        if(PlayerInfo[playerid][pAdmin] < 3) return SendClientMessage(playerid, COLOR_RED, "Nu ai permisiune!");
        new count = 0;
        for(new v = 1; v < MAX_VEHICLES; v++) {
            if(GetVehicleModel(v) > 0) {
                new occupied = 0;
                for(new p = 0; p < MAX_PLAYERS; p++) {
                    if(IsPlayerConnected(p) && GetPlayerVehicleID(p) == v) {
                        occupied = 1;
                        break;
                    }
                }
                if(!occupied) {
                    SetVehicleToRespawn(v);
                    count++;
                }
            }
        }
        new rMsg[128];
        format(rMsg, sizeof(rMsg), "[SERVER] Administratorul %s a respawnat toate vehiculele libere (%d vehicule).", PlayerInfo[playerid][pName], count);
        SendClientMessageToAll(COLOR_ADMIN, rMsg);
        return 1;
    }

    if(!strcmp(cmd, "/sethp", true)) {
        if(PlayerInfo[playerid][pAdmin] < 3) return SendClientMessage(playerid, COLOR_RED, "Nu ai permisiune!");
        new targetid, hp;
        if(sscanf_custom(params, targetid, hp)) {
            if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_RED, "Jucatorul nu este online!");
            SetPlayerHealth(targetid, float(hp));
            new hMsg[128];
            format(hMsg, sizeof(hMsg), "[ADMIN] I-ai setat viata lui %s la %d HP.", PlayerInfo[targetid][pName], hp);
            SendClientMessage(playerid, COLOR_ADMIN, hMsg);
        } else {
            SendClientMessage(playerid, COLOR_YELLOW, "Folosire: /sethp [playerid] [viata 0-100]");
        }
        return 1;
    }

    if(!strcmp(cmd, "/setarmour", true)) {
        if(PlayerInfo[playerid][pAdmin] < 3) return SendClientMessage(playerid, COLOR_RED, "Nu ai permisiune!");
        new targetid, arm;
        if(sscanf_custom(params, targetid, arm)) {
            if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_RED, "Jucatorul nu este online!");
            SetPlayerArmour(targetid, float(arm));
            new aMsg[128];
            format(aMsg, sizeof(aMsg), "[ADMIN] I-ai setat armura lui %s la %d Armour.", PlayerInfo[targetid][pName], arm);
            SendClientMessage(playerid, COLOR_ADMIN, aMsg);
        } else {
            SendClientMessage(playerid, COLOR_YELLOW, "Folosire: /setarmour [playerid] [armura 0-100]");
        }
        return 1;
    }

    if(!strcmp(cmd, "/destroyveh", true) || !strcmp(cmd, "/dv", true)) {
        if(PlayerInfo[playerid][pAdmin] < 4) return SendClientMessage(playerid, COLOR_RED, "Nu ai permisiune!");
        new veh = INVALID_VEHICLE_ID;
        if(IsPlayerInAnyVehicle(playerid)) {
            veh = GetPlayerVehicleID(playerid);
        } else {
            veh = GetNearestVehicle(playerid, 5.0);
        }
        if(veh == INVALID_VEHICLE_ID) return SendClientMessage(playerid, COLOR_RED, "Nu esti intr-un vehicul sau langa un vehicul!");

        DestroyVehicle(veh);
        SendClientMessage(playerid, COLOR_ADMIN, "[ADMIN] Vehiculul a fost sters din lume!");
        return 1;
    }

    if(!strcmp(cmd, "/setleader", true)) {
        if(PlayerInfo[playerid][pAdmin] < 5) return SendClientMessage(playerid, COLOR_RED, "Doar un Owner poate acorda functii de Lider!");
        new targetid, factionid;
        if(sscanf_custom(params, targetid, factionid) && factionid >= 1 && factionid <= 7) {
            if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_RED, "Jucatorul nu este online!");
            PlayerInfo[targetid][pFaction] = factionid;
            PlayerInfo[targetid][pFactionRank] = 6;
            PlayerInfo[targetid][pDuty] = 0;
            SavePlayerData(targetid);

            new lMsg[144];
            format(lMsg, sizeof(lMsg), "[LEADER] Ownerul %s l-a numit pe %s ca LIDER al factiunii ID %d!", PlayerInfo[playerid][pName], PlayerInfo[targetid][pName], factionid);
            SendClientMessageToAll(COLOR_GOLD, lMsg);
        } else {
            SendClientMessage(playerid, COLOR_YELLOW, "Folosire: /setleader [playerid] [factiune 1-7]");
        }
        return 1;
    }

    if(!strcmp(cmd, "/settime", true)) {
        if(PlayerInfo[playerid][pAdmin] < 3) return SendClientMessage(playerid, COLOR_RED, "Nu ai permisiune!");
        new tVal = strval(params);
        if(tVal < 0 || tVal > 23) return SendClientMessage(playerid, COLOR_RED, "Ora invalida! (0 - 23)");
        SetWorldTime(tVal);
        new tmsg[128];
        format(tmsg, sizeof(tmsg), "[SERVER] Ora serverului a fost setata la %d:00 de adminul %s.", tVal, PlayerInfo[playerid][pName]);
        SendClientMessageToAll(COLOR_ADMIN, tmsg);
        return 1;
    }

    if(!strcmp(cmd, "/setweather", true)) {
        if(PlayerInfo[playerid][pAdmin] < 3) return SendClientMessage(playerid, COLOR_RED, "Nu ai permisiune!");
        new wVal = strval(params);
        SetWeather(wVal);
        new wmsg[128];
        format(wmsg, sizeof(wmsg), "[SERVER] Vremea a fost schimbata la ID %d de adminul %s.", wVal, PlayerInfo[playerid][pName]);
        SendClientMessageToAll(COLOR_ADMIN, wmsg);
        return 1;
    }

    if(!strcmp(cmd, "/givegun", true)) {
        if(PlayerInfo[playerid][pAdmin] < 3) return SendClientMessage(playerid, COLOR_RED, "Nu ai permisiune!");
        new targetid, weaponid, ammo = 200;
        if(sscanf_custom(params, targetid, weaponid)) {
            if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_RED, "Jucatorul nu este online!");
            GivePlayerWeapon(targetid, weaponid, ammo);
            new gmsg[128];
            format(gmsg, sizeof(gmsg), "[ADMIN] I-ai dat arma ID %d lui %s.", weaponid, PlayerInfo[targetid][pName]);
            SendClientMessage(playerid, COLOR_ADMIN, gmsg);
            format(gmsg, sizeof(gmsg), "[ADMIN] Administratorul %s ti-a acordat arma ID %d cu %d gloante.", PlayerInfo[playerid][pName], weaponid, ammo);
            SendClientMessage(targetid, COLOR_GREEN, gmsg);
        } else {
            SendClientMessage(playerid, COLOR_YELLOW, "Folosire: /givegun [playerid] [weaponid]");
        }
        return 1;
    }

    // 5. VIP System
    if(!strcmp(cmd, "/vc", true)) {
        if(PlayerInfo[playerid][pVIP] < 1 && PlayerInfo[playerid][pAdmin] < 1) {
            return SendClientMessage(playerid, COLOR_RED, "Doar membrii VIP pot folosi acest chat!");
        }
        if(strlen(params) == 0) return SendClientMessage(playerid, COLOR_YELLOW, "Folosire: /vc [mesaj]");
        new vmsg[144];
        format(vmsg, sizeof(vmsg), "[VIP Chat] %s: %s", PlayerInfo[playerid][pName], params);
        for(new i = 0; i < MAX_PLAYERS; i++) {
            if(IsPlayerConnected(i) && (PlayerInfo[i][pVIP] >= 1 || PlayerInfo[i][pAdmin] >= 1)) {
                SendClientMessage(i, COLOR_GOLD, vmsg);
            }
        }
        return 1;
    }

    if(!strcmp(cmd, "/vips", true)) {
        SendClientMessage(playerid, COLOR_GOLD, "=== Membrii VIP Online ===");
        new count = 0;
        for(new i = 0; i < MAX_PLAYERS; i++) {
            if(IsPlayerConnected(i) && PlayerInfo[i][pVIP] >= 1) {
                new vstr[128];
                format(vstr, sizeof(vstr), "[VIP Lvl %d] %s (ID: %d)", PlayerInfo[i][pVIP], PlayerInfo[i][pName], i);
                SendClientMessage(playerid, COLOR_WHITE, vstr);
                count++;
            }
        }
        if(count == 0) SendClientMessage(playerid, COLOR_GREY, "Niciun membru VIP online in acest moment.");
        return 1;
    }

    if(!strcmp(cmd, "/setvip", true)) {
        if(PlayerInfo[playerid][pAdmin] < 4) return SendClientMessage(playerid, COLOR_RED, "Nu ai permisiune!");
        new targetid, vLevel;
        if(sscanf_custom(params, targetid, vLevel) && vLevel >= 0 && vLevel <= 3) {
            if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, COLOR_RED, "Jucatorul nu este online!");
            PlayerInfo[targetid][pVIP] = vLevel;
            new vmsg[128];
            format(vmsg, sizeof(vmsg), "[ADMIN] I-ai setat gradul VIP al lui %s la Nivelul %d.", PlayerInfo[targetid][pName], vLevel);
            SendClientMessage(playerid, COLOR_ADMIN, vmsg);
            format(vmsg, sizeof(vmsg), "[VIP] Felicitari! Ai primit statutul de membru VIP Nivelul %d!", vLevel);
            SendClientMessage(targetid, COLOR_GOLD, vmsg);
            SavePlayerData(targetid);
        } else {
            SendClientMessage(playerid, COLOR_YELLOW, "Folosire: /setvip [playerid] [nivel 0-3]");
        }
        return 1;
    }

    // Replay Tutorial Command
    if(!strcmp(cmd, "/tutorial", true) || !strcmp(cmd, "/ghid", true)) {
        if(PlayerInfo[playerid][pTutorial] >= 10) {
            ShowPlayerDialog(playerid, DIALOG_TUTORIAL_2, DIALOG_STYLE_MSGBOX, "{00FF00}Replay Tutorial 1/5 - Bine ai venit in Las Venturas!",
                "{FFFFFF}Reia-mi tutorialul de la inceput?\n\n\
                Vei primi informatii despre joburi, bani, case, vehicule, telefoane si permisul de conducere.",
                "Incepe", "Anuleaza"
            );
            return 1;
        }
        SendClientMessage(playerid, COLOR_YELLOW, "[TUTORIAL] Esti deja in tutorial!");
        return 1;
    }

    // ========================================================================
    //                        HOUSE SYSTEM COMMANDS
    // ========================================================================
    if(!strcmp(cmd, "/house", true) || !strcmp(cmd, "/casa", true)) {
        if(strlen(params) == 0) {
            new slot = GetNearestHouse(playerid);
            new hInfo[400];
            if(slot == -1) {
                if(PlayerInfo[playerid][pHouse] == -1) {
                    format(hInfo, sizeof(hInfo), "{FFFFFF}Nu esti langa nicio casa si nu detii una.\n\nCasele sunt marcate cu pickup-uri verzi pe harta!\nApropie-te de una si tasteaza {00FF00}/house{FFFFFF}.");
                } else {
                    format(hInfo, sizeof(hInfo), "{FFFFFF}Casa ta: #{FFFF00}%d\n\n{00FF00}Vrei sa o vinzi la jumatate din pret?{FFFFFF}\nTasteaza /house vinde", PlayerInfo[playerid][pHouse]);
                }
            } else {
                format(hInfo, sizeof(hInfo), "{FFFF00}Casa #%d{FFFFFF}\nPret: {00FF00}$%d{FFFFFF}\nStatus: %s\n\n{00FFFF}Optiuni:{FFFFFF}\n- /house cumpara (daca este libera)\n- /house intra (daca este a ta)", slot, HouseInfo[slot][hPrice], HouseInfo[slot][hOwned] ? "Occupata" : "De vanzare");
            }
            ShowPlayerDialog(playerid, DIALOG_HELP, DIALOG_STYLE_MSGBOX, "{00FF00}Sistemul de Case - Las Venturas", hInfo, "Inchide", "");
            return 1;
        }

        if(!strcmp(params, "cumpara", true) || !strcmp(params, "buy", true)) {
            BuyHouse(playerid);
            return 1;
        }
        if(!strcmp(params, "vinde", true) || !strcmp(params, "sell", true)) {
            SellHouse(playerid);
            return 1;
        }
        if(!strcmp(params, "intra", true) || !strcmp(params, "enter", true)) {
            EnterHouse(playerid);
            return 1;
        }
        SendClientMessage(playerid, COLOR_YELLOW, "Folosire: /house [cumpara|vinde|intra]");
        return 1;
    }

    // ========================================================================
    //                        TAXI FARE COMMANDS
    // ========================================================================
    if(!strcmp(cmd, "/fare", true)) {
        if(PlayerInfo[playerid][pJob] != JOB_TAXI) return SendClientMessage(playerid, COLOR_RED, "[TAXI] Trebuie sa fii Taximetrist! Angajeaza-te cu /jobs.");
        new fare = strval(params);
        if(fare < 50 || fare > 5000) return SendClientMessage(playerid, COLOR_YELLOW, "Folosire: /fare [suma 50-5000]");
        pTaxiFare[playerid] = fare;
        new fmsg[128];
        format(fmsg, sizeof(fmsg), "[TAXI] Tariful tau a fost setat la $%d per cursa. Pasagerii platesc automat la coborare.", fare);
        SendClientMessage(playerid, COLOR_GREEN, fmsg);
        return 1;
    }

    // ========================================================================
    //                        PHONE SYSTEM COMMANDS
    // ========================================================================
    if(!strcmp(cmd, "/phone", true) || !strcmp(cmd, "/telefon", true)) {
        if(!PlayerInfo[playerid][pPhone]) return SendClientMessage(playerid, COLOR_RED, "[TELEFON] Nu detii un telefon! Cumpara unul din magazinul 24/7 cu /buy.");
        new pmsg[400];
        format(pmsg, sizeof(pmsg), "{FFFF00}=== TELEFONUL TAU ==={FFFFFF}\n\nNumarul tau: {00FF00}%d{FFFFFF}\nBaterie: {00FF00}100%%{FFFFFF}\nSemnal: {00FF00}Full{FFFFFF}\n\n{00FFFF}Comenzi disponibile:{FFFFFF}\n/call [numar] - Suna pe cineva\n/sms [numar] [mesaj] - Trimite un SMS\n/answer - Raspunde la apel\n/hangup - Inchide apelul", GetPlayerPhoneNumber(playerid));
        ShowPlayerDialog(playerid, DIALOG_HELP, DIALOG_STYLE_MSGBOX, "{00FF00}Telefon Mobil", pmsg, "Inchide", "");
        return 1;
    }

    if(!strcmp(cmd, "/call", true)) {
        if(!PlayerInfo[playerid][pPhone]) return SendClientMessage(playerid, COLOR_RED, "[TELEFON] Nu detii un telefon! Cumpara unul cu /buy.");
        if(CallWith[playerid] != INVALID_PLAYER_ID) return SendClientMessage(playerid, COLOR_RED, "[TELEFON] Esti deja la telefon! Foloseste /hangup mai intai.");
        if(CallRequest[playerid] != INVALID_PLAYER_ID) return SendClientMessage(playerid, COLOR_RED, "[TELEFON] Ai deja un apel in asteptare!");
        new number = strval(params);
        if(number < 100 || number >= 100 + MAX_PLAYERS) return SendClientMessage(playerid, COLOR_YELLOW, "Folosire: /call [numar] (numerele sunt 100 - %d)", 99 + MAX_PLAYERS);

        new targetid = number - 100;
        if(!IsPlayerConnected(targetid) || !PlayerInfo[targetid][pLogged]) {
            return SendClientMessage(playerid, COLOR_RED, "[TELEFON] Numarul este indisponibil sau persoana nu este online!");
        }
        if(!PlayerInfo[targetid][pPhone]) {
            return SendClientMessage(playerid, COLOR_RED, "[TELEFON] Persoana apelata nu detine un telefon!");
        }
        if(targetid == playerid) {
            return SendClientMessage(playerid, COLOR_RED, "[TELEFON] Nu te poti suna pe tine insuti!");
        }
        if(CallWith[targetid] != INVALID_PLAYER_ID) {
            return SendClientMessage(playerid, COLOR_RED, "[TELEFON] Persoana apelata este deja intr-un apel!");
        }

        CallRequest[targetid] = playerid;
        new cmsg[144];
        format(cmsg, sizeof(cmsg), "[TELEFON] Iti suna telefonul de la numarul %d! Tasteaza /answer pentru a raspunde.", GetPlayerPhoneNumber(playerid));
        SendClientMessage(targetid, COLOR_YELLOW, cmsg);
        SendClientMessage(playerid, COLOR_GREEN, "[TELEFON] Se aude ton de apel... Asteapta raspunsul.");
        PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
        return 1;
    }

    if(!strcmp(cmd, "/answer", true)) {
        if(!PlayerInfo[playerid][pPhone]) return SendClientMessage(playerid, COLOR_RED, "[TELEFON] Nu detii un telefon!");
        if(CallRequest[playerid] == INVALID_PLAYER_ID) return SendClientMessage(playerid, COLOR_RED, "[TELEFON] Nimeni nu te suna in acest moment!");

        new caller = CallRequest[playerid];
        if(!IsPlayerConnected(caller) || !PlayerInfo[caller][pLogged]) {
            CallRequest[playerid] = INVALID_PLAYER_ID;
            return SendClientMessage(playerid, COLOR_RED, "[TELEFON] Persoana care te suna s-a deconectat.");
        }

        CallWith[playerid] = caller;
        CallWith[caller] = playerid;
        CallRequest[playerid] = INVALID_PLAYER_ID;

        new amsg[144];
        format(amsg, sizeof(amsg), "[TELEFON] %d a raspuns la apelul tau. Vorbiti acum.", GetPlayerPhoneNumber(playerid));
        SendClientMessage(caller, COLOR_GREEN, amsg);
        SendClientMessage(playerid, COLOR_GREEN, "[TELEFON] Ai raspuns la apel. Vorbiti acum.");
        PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
        PlayerPlaySound(caller, 1057, 0.0, 0.0, 0.0);
        return 1;
    }

    if(!strcmp(cmd, "/hangup", true)) {
        if(!PlayerInfo[playerid][pPhone]) return SendClientMessage(playerid, COLOR_RED, "[TELEFON] Nu detii un telefon!");
        if(CallWith[playerid] == INVALID_PLAYER_ID && CallRequest[playerid] == INVALID_PLAYER_ID) {
            return SendClientMessage(playerid, COLOR_RED, "[TELEFON] Nu esti intr-un apel!");
        }
        EndPhoneCall(playerid);
        if(CallRequest[playerid] != INVALID_PLAYER_ID) {
            if(IsPlayerConnected(CallRequest[playerid])) {
                SendClientMessage(CallRequest[playerid], COLOR_YELLOW, "[TELEFON] Apelul tau a fost refuzat / inchis.");
            }
            CallRequest[playerid] = INVALID_PLAYER_ID;
        }
        SendClientMessage(playerid, COLOR_YELLOW, "[TELEFON] Ai inchis apelul.");
        return 1;
    }

    if(!strcmp(cmd, "/sms", true)) {
        if(!PlayerInfo[playerid][pPhone]) return SendClientMessage(playerid, COLOR_RED, "[TELEFON] Nu detii un telefon! Cumpara unul cu /buy.");
        new number, text[100];
        if(sscanf_target_str(params, number, text) && number >= 100 && number < 100 + MAX_PLAYERS) {
            new targetid = number - 100;
            if(!IsPlayerConnected(targetid) || !PlayerInfo[targetid][pLogged]) {
                return SendClientMessage(playerid, COLOR_RED, "[SMS] Numarul este indisponibil sau persoana nu este online!");
            }
            if(!PlayerInfo[targetid][pPhone]) {
                return SendClientMessage(playerid, COLOR_RED, "[SMS] Persoana nu detine un telefon!");
            }
            new smsg[144];
            format(smsg, sizeof(smsg), "[SMS de la %d]: %s", GetPlayerPhoneNumber(playerid), text);
            SendClientMessage(targetid, COLOR_YELLOW, smsg);
            format(smsg, sizeof(smsg), "[SMS catre %d]: %s", number, text);
            SendClientMessage(playerid, COLOR_GREEN, smsg);
        } else {
            SendClientMessage(playerid, COLOR_YELLOW, "Folosire: /sms [numar] [mesaj]");
        }
        return 1;
    }

    SendClientMessage(playerid, COLOR_RED, "[EROARE] Comanda necunoscuta! Tasteaza {FFFFFF}/help{FF0000} pentru lista de comenzi.");
    return 1;
}

// ============================================================================
//                               HELPER FUNCTIONS
// ============================================================================

// ============================================================================
//                          TUTORIAL STEP FUNCTIONS
// ============================================================================

stock ShowTutorialStep3(playerid) {
    ShowPlayerDialog(playerid, DIALOG_TUTORIAL_3, DIALOG_STYLE_MSGBOX, "{00FF00}Tutorial 3/5 - Banii & Telefonul",
        "{FFFFFF}Pasiunea a 3-a: {FFFF00}BANII{FFFFFF}!\n\n\
        In acest server ai doua surse de bani:\n\n\
        {FFFF00}*{FFFFFF} Cash (ce porti la tine)\n\
        {FFFF00}*{FFFFFF} Banca (sold securizat, cu dobanda saptamanala de payday)\n\n\
        Poti depune/retrage la Banca LV sau la ATM-uri cu {00FF00}/bank{FFFFFF} sau {00FF00}/atm{FFFFFF}.\n\
        Poti cumpara un {FFFF00}telefon mobil{FFFFFF} din magazinul 24/7 cu {00FF00}/buy{FFFFFF} pentru {00FF00}$500{FFFFFF},\n\
        apoi poti suna pe alti jucatori ({00FF00}/call{FFFFFF}) sau trimite mesaje ({00FF00}/sms{FFFFFF}).\n\n\
        {00FF00}Vrei sa afli despre banci si telefoane?{FFFFFF}",
        "Da, despre banca", "Skip"
    );
    return 1;
}

stock ShowTutorialStep4(playerid) {
    ShowPlayerDialog(playerid, DIALOG_TUTORIAL_4, DIALOG_STYLE_MSGBOX, "{00FF00}Tutorial 4/5 - Case & Vehicule",
        "{FFFFFF}Pasiunea a 4-a: {FFFF00}CASE SI MASINI{FFFFFF}!\n\n\
        {FFFF00}CASE:{FFFFFF} Pe tot mapul exista case de vanzare marcate cu pickup-uri verzi.\n\
        Apropie-te de una si tasteaza {00FF00}/house cumpara{FFFFFF} pentru a o cumpara cu bani din banca.\n\
        Poti intra in casa ta cu {00FF00}/house intra{FFFFFF} si o poti vinde la jumatate din pret cu {00FF00}/house vinde{FFFFFF}.\n\n\
        {FFFF00}VEHICULE:{FFFFFF} Mergi la Dealership (tasteaza {00FF00}/ds{FFFFFF}) si alege masina preferata din catalog.\n\
        Motor pornit/oprit pe tasta {FFFF00}2{FFFFFF}, inchidere usi pe tasta {FFFF00}N{FFFFFF}.\n\n\
        {00FF00}Vrei sa afli despre case si vehicule?{FFFFFF}",
        "Da, despre case", "Skip"
    );
    return 1;
}

// ============================================================================
//                          HOUSE SYSTEM FUNCTIONS
// ============================================================================

LoadHouses() {
    for(new i = 0; i < MAX_HOUSES; i++) {
        HouseInfo[i][hSlot] = i;
        HouseInfo[i][hX] = HouseSpots[i][0];
        HouseInfo[i][hY] = HouseSpots[i][1];
        HouseInfo[i][hZ] = HouseSpots[i][2];
        HouseInfo[i][hPrice] = HousePrices[i];
        HouseInfo[i][hOwner] = "";
        HouseInfo[i][hOwned] = 0;

        new query[256];
        format(query, sizeof(query), "SELECT owner FROM houses WHERE slot = %d LIMIT 1;", i);
        new DBResult:res = db_query(gDB, query);
        if(res) {
            if(db_num_rows(res) > 0) {
                new owner[MAX_PLAYER_NAME];
                db_get_field_assoc(res, "owner", owner, MAX_PLAYER_NAME);
                if(strlen(owner) > 0) {
                    format(HouseInfo[i][hOwner], MAX_PLAYER_NAME, "%s", owner);
                    HouseInfo[i][hOwned] = 1;
                }
            }
            db_free_result(res);
        }

        // Create pickup + label
        if(HouseInfo[i][hOwned]) {
            HouseInfo[i][hPickup] = CreatePickup(1272, 1, HouseInfo[i][hX], HouseInfo[i][hY], HouseInfo[i][hZ], -1);
        } else {
            HouseInfo[i][hPickup] = CreatePickup(1273, 1, HouseInfo[i][hX], HouseInfo[i][hY], HouseInfo[i][hZ], -1);
        }
        UpdateHouseLabel(i);
    }
    printf("[HOUSES] S-au incarcat %d case in Las Venturas.", MAX_HOUSES);
}

UpdateHouseLabel(slot) {
    if(slot < 0 || slot >= MAX_HOUSES) return;
    new label[128];
    if(HouseInfo[slot][hOwned]) {
        format(label, sizeof(label), "{00FF00}[ CASE DE VANZARE - OCCUPATA ]\n{FFFFFF}Proprietar: {FFFF00}%s\n{FFFFFF}Tasteaza {00FF00}/house", HouseInfo[slot][hOwner]);
    } else {
        format(label, sizeof(label), "{FFFF00}[ CASA DE VANZARE ]\n{FFFFFF}Pret: {00FF00}$%d\n{FFFFFF}Tasteaza {00FF00}/house cumpara", HouseInfo[slot][hPrice]);
    }
    if(HouseInfo[slot][hLabel] != Text3D:INVALID_3DTEXT_ID) {
        Delete3DTextLabel(HouseInfo[slot][hLabel]);
    }
    HouseInfo[slot][hLabel] = Create3DTextLabel(label, COLOR_WHITE, HouseInfo[slot][hX], HouseInfo[slot][hY], HouseInfo[slot][hZ] + 1.2, 25.0, 0, 1);
}

GetNearestHouse(playerid) {
    for(new i = 0; i < MAX_HOUSES; i++) {
        if(IsPlayerInRangeOfPoint(playerid, 3.5, HouseInfo[i][hX], HouseInfo[i][hY], HouseInfo[i][hZ])) {
            return i;
        }
    }
    return -1;
}

stock BuyHouse(playerid) {
    new slot = GetNearestHouse(playerid);
    if(slot == -1) return SendClientMessage(playerid, COLOR_RED, "[CASA] Nu esti langa nicio casa de vanzare!");

    if(HouseInfo[slot][hOwned]) {
        if(!strcmp(HouseInfo[slot][hOwner], PlayerInfo[playerid][pName], true)) {
            return SendClientMessage(playerid, COLOR_YELLOW, "[CASA] Aceasta casa este deja a ta! Tasteaza /house intra pentru a intra.");
        }
        return SendClientMessage(playerid, COLOR_RED, "[CASA] Aceasta casa are deja proprietar!");
    }
    if(PlayerInfo[playerid][pHouse] != -1) {
        return SendClientMessage(playerid, COLOR_RED, "[CASA] Detii deja o casa! Vinde-o prima data cu /house vinde.");
    }
    if(PlayerInfo[playerid][pBank] < HouseInfo[slot][hPrice]) {
        new err[128];
        format(err, sizeof(err), "[CASA] Nu ai destui bani in banca! Pretul casei este $%d.", HouseInfo[slot][hPrice]);
        return SendClientMessage(playerid, COLOR_RED, err);
    }

    PlayerInfo[playerid][pBank] -= HouseInfo[slot][hPrice];
    PlayerInfo[playerid][pHouse] = slot;
    HouseInfo[slot][hOwned] = 1;
    format(HouseInfo[slot][hOwner], MAX_PLAYER_NAME, "%s", PlayerInfo[playerid][pName]);

    DestroyPickup(HouseInfo[slot][hPickup]);
    HouseInfo[slot][hPickup] = CreatePickup(1272, 1, HouseInfo[slot][hX], HouseInfo[slot][hY], HouseInfo[slot][hZ], -1);
    UpdateHouseLabel(slot);

    new query[256];
    format(query, sizeof(query), "INSERT OR REPLACE INTO houses (slot, owner) VALUES (%d, '%q');", slot, PlayerInfo[playerid][pName]);
    db_query(gDB, query);
    SavePlayerData(playerid);

    new msg[144];
    format(msg, sizeof(msg), "[CASA] Felicitari! Ai cumparat casa #%d pentru $%d. Tasteaza /house intra pentru a intra.", slot, HouseInfo[slot][hPrice]);
    SendClientMessage(playerid, COLOR_GREEN, msg);
    PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
    return 1;
}

stock SellHouse(playerid) {
    if(PlayerInfo[playerid][pHouse] == -1) return SendClientMessage(playerid, COLOR_RED, "[CASA] Nu detii nicio casa!");

    new slot = PlayerInfo[playerid][pHouse];
    new refund = HouseInfo[slot][hPrice] / 2;

    PlayerInfo[playerid][pBank] += refund;
    PlayerInfo[playerid][pHouse] = -1;
    HouseInfo[slot][hOwned] = 0;
    HouseInfo[slot][hOwner] = "";

    DestroyPickup(HouseInfo[slot][hPickup]);
    HouseInfo[slot][hPickup] = CreatePickup(1273, 1, HouseInfo[slot][hX], HouseInfo[slot][hY], HouseInfo[slot][hZ], -1);
    UpdateHouseLabel(slot);

    new query[128];
    format(query, sizeof(query), "DELETE FROM houses WHERE slot = %d;", slot);
    db_query(gDB, query);
    SavePlayerData(playerid);

    new msg[144];
    format(msg, sizeof(msg), "[CASA] Ai vandut casa pentru $%d (jumatate din pret). Banii au fost trimisi in contul tau bancar.", refund);
    SendClientMessage(playerid, COLOR_GREEN, msg);
    return 1;
}

stock EnterHouse(playerid) {
    new slot = GetNearestHouse(playerid);
    if(slot == -1) return SendClientMessage(playerid, COLOR_RED, "[CASA] Nu esti langa nicio casa!");

    if(!HouseInfo[slot][hOwned]) {
        return SendClientMessage(playerid, COLOR_RED, "[CASA] Aceasta casa nu are proprietar si este inchisa!");
    }
    if(!strcmp(HouseInfo[slot][hOwner], PlayerInfo[playerid][pName], true) || PlayerInfo[playerid][pAdmin] >= 3) {
        SetPlayerInterior(playerid, HOUSE_INT_ID);
        SetPlayerVirtualWorld(playerid, HOUSE_INT_WORLD_BASE + slot);
        SetPlayerPos(playerid, HOUSE_INT_X, HOUSE_INT_Y, HOUSE_INT_Z);
        GameTextForPlayer(playerid, "~g~CASA TA", 2000, 3);
        SendClientMessage(playerid, COLOR_GREEN, "[CASA] Bine ai venit acasa! Iesi prin pickup pentru a iesi.");
    } else {
        SendClientMessage(playerid, COLOR_RED, "[CASA] Aceasta casa nu este a ta si usa este incuiata!");
    }
    return 1;
}

// ============================================================================
//                          PHONE SYSTEM FUNCTIONS
// ============================================================================

stock GetPlayerPhoneNumber(playerid) {
    // Numarul de telefon = ID player + 100 (simplic si unic per sesiune)
    return playerid + 100;
}

stock EndPhoneCall(playerid) {
    if(CallWith[playerid] != INVALID_PLAYER_ID && IsPlayerConnected(CallWith[playerid])) {
        new other = CallWith[playerid];
        SendClientMessage(other, COLOR_YELLOW, "[TELEFON] Apelul a fost inchis.");
        CallWith[other] = INVALID_PLAYER_ID;
    }
    CallWith[playerid] = INVALID_PLAYER_ID;
    return 1;
}

stock SendLocalMessage(playerid, color, const string[], Float:radius) {
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    for(new i = 0; i < MAX_PLAYERS; i++) {
        if(IsPlayerConnected(i)) {
            if(IsPlayerInRangeOfPoint(i, radius, x, y, z)) {
                SendClientMessage(i, color, string);
            }
        }
    }
    return 1;
}

stock GetAdminRank(level) {
    new rank[32];
    switch(level) {
        case 1: rank = "Helper";
        case 2: rank = "Moderator";
        case 3: rank = "Admin";
        case 4: rank = "Senior Admin";
        case 5: rank = "Owner / Fondator";
        default: rank = "Jucator";
    }
    return rank;
}

stock GetNearestVehicle(playerid, Float:radius) {
    new Float:px, Float:py, Float:pz;
    GetPlayerPos(playerid, px, py, pz);
    for(new v = 1; v < MAX_VEHICLES; v++) {
        if(GetVehicleModel(v) > 0) {
            new Float:vx, Float:vy, Float:vz;
            GetVehiclePos(v, vx, vy, vz);
            if(floatsqroot((px-vx)*(px-vx) + (py-vy)*(py-vy) + (pz-vz)*(pz-vz)) <= radius) {
                return v;
            }
        }
    }
    return INVALID_VEHICLE_ID;
}

stock GetPersonalVehicleIndex(vehicleid) {
    for(new i = 0; i < TotalPersonalVehicles; i++) {
        if(VehicleInfo[i][vServerID] == vehicleid) return i;
    }
    return -1;
}

stock sscanf_custom(const string[], &arg1, &arg2) {
    new idx = 0;
    while(string[idx] == ' ') idx++;
    if(string[idx] == '\0') return 0;

    new part1[32];
    new p1 = 0;
    while(string[idx] > ' ' && p1 < 31) {
        part1[p1++] = string[idx++];
    }
    part1[p1] = '\0';

    while(string[idx] == ' ') idx++;
    if(string[idx] == '\0') return 0;

    new part2[32];
    new p2 = 0;
    while(string[idx] > ' ' && p2 < 31) {
        part2[p2++] = string[idx++];
    }
    part2[p2] = '\0';

    arg1 = strval(part1);
    arg2 = strval(part2);
    return 1;
}

stock sscanf_target_str(const string[], &arg1, arg2[]) {
    new idx = 0;
    while(string[idx] == ' ') idx++;
    if(string[idx] == '\0') return 0;

    new part1[32];
    new p1 = 0;
    while(string[idx] > ' ' && p1 < 31) {
        part1[p1++] = string[idx++];
    }
    part1[p1] = '\0';

    while(string[idx] == ' ') idx++;
    if(string[idx] == '\0') return 0;

    format(arg2, 64, "%s", string[idx]);
    arg1 = strval(part1);
    return 1;
}

stock sscanf_id_val_str(const string[], &arg1, &arg2, arg3[]) {
    new idx = 0;
    while(string[idx] == ' ') idx++;
    if(string[idx] == '\0') return 0;

    new part1[32];
    new p1 = 0;
    while(string[idx] > ' ' && p1 < 31) {
        part1[p1++] = string[idx++];
    }
    part1[p1] = '\0';

    while(string[idx] == ' ') idx++;
    if(string[idx] == '\0') return 0;

    new part2[32];
    new p2 = 0;
    while(string[idx] > ' ' && p2 < 31) {
        part2[p2++] = string[idx++];
    }
    part2[p2] = '\0';

    while(string[idx] == ' ') idx++;
    if(string[idx] == '\0') return 0;

    format(arg3, 64, "%s", string[idx]);
    arg1 = strval(part1);
    arg2 = strval(part2);
    return 1;
}
