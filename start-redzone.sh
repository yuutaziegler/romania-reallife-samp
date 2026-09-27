#!/bin/bash
# ============================================================
# Red-Zone RPG (open.mp) - Linux Launch Script
# Porneste gamemode-ul red-zone/server-package/main
#
# CERINTE:
#   1. MySQL server local pornit (localhost:3306)
#   2. Baza de date creata:  CREATE DATABASE samp;
#   3. Dump importat:        mysql -u root samp < red-zone/red-zone.sql
#   4. User MySQL root FARA parola (sau editeaza
#      red-zone/server-package/src/Variables.pwn si recompileaza)
#
# NOTA: pluginurile .so sunt incluse in red-zone/plugins/
#       open.mp server = red-zone/omp-server (vezi omp-server.exe)
# ============================================================
set -e

REDZONE_DIR="$(cd "$(dirname "$0")" && pwd)/red-zone"
cd "$REDZONE_DIR"

echo "[RED-ZONE] Director: $REDZONE_DIR"
echo "[RED-ZONE] Pornire open.mp server (gamemode: server-package/main)..."

if [ ! -f server-package/main.amx ]; then
    echo "[RED-ZONE][EROARE] server-package/main.amx lipseste!"
    exit 1
fi

# pe Linux rulam omp-server nativ daca exista, altfel avertisment
if [ -x ./omp-server ]; then
    ./omp-server
elif [ -f ./omp-server.exe ]; then
    echo "[RED-ZONE][WARN] Exista doar omp-server.exe (Windows)."
    echo "  -> Pentru Linux: descarca open.mp Linux runtime si pune 'omp-server'"
    echo "     in acest folder. Componentele .so si pluginurile .so sunt deja aici."
    echo "  -> Sau ruleaza pachetul pe Windows: omp-server.exe"
    exit 1
else
    echo "[RED-ZONE][EROARE] Nu exista omp-server in $REDZONE_DIR"
    exit 1
fi
