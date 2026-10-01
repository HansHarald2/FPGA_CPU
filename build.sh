#!/usr/bin/env bash
# =============================================================================
# build.sh – FPGA-Flow für das iCESugar-Pro (Lattice ECP5 LFE5U-25F-6BG256C)
#
# Benutzung:
#   ./build.sh sim   <testbench>   # GHDL-Simulation -> build/<tb>.vcd -> GTKWave
#   ./build.sh synth               # VHDL -> Netzliste (Yosys + GHDL-Plugin)
#   ./build.sh pnr                 # Place & Route (nextpnr-ecp5)
#   ./build.sh bit                 # Bitstream packen (ecppack)
#   ./build.sh prog                # ins SRAM laden (weg nach Power-off)
#   ./build.sh flash               # ins Konfig-Flash schreiben (bleibt)
#   ./build.sh all                 # synth + pnr + bit
#   ./build.sh clean
#
# Regel 4 aus dem Lern-Contract: Nichts aufs Board, was nicht in GTKWave war.
# =============================================================================
set -euo pipefail          # bei jedem Fehler sofort abbrechen

# ---- Projekt-Einstellungen --------------------------------------------------
TOP=top                     # Name der Top-Level-Entity
SRC_DIR=src                 # synthetisierbares VHDL
SIM_DIR=sim                 # Testbenches (werden NIE synthetisiert)
BUILD=build                 # alle generierten Dateien (in .gitignore)
LPF=constraints/icesugar_pro.lpf   # NUR aus github.com/wuxx/icesugar-pro kopieren!

# ---- Chip-Parameter (iCESugar-Pro) ------------------------------------------
DEVICE=25k                  # LFE5U-25F
PACKAGE=CABGA256            # BG256-Gehäuse
# TODO: Board-Namen in der openFPGALoader-Kompatibilitätsliste verifizieren
BOARD=icesugar_pro

GHDL_STD=--std=08           # VHDL-2008

mkdir -p "$BUILD"

# Alle .vhd-Dateien aus src/ einsammeln (Reihenfolge: alphabetisch;
# bei Package-Abhängigkeiten später ggf. explizit sortieren)
src_files() { ls "$SRC_DIR"/*.vhd; }

case "${1:-help}" in

  sim)
    TB="${2:?Name der Testbench-Entity angeben, z.B. ./build.sh sim blinky_tb}"
    # -a  analysieren: Syntax + Semantik prüfen, in Bibliothek 'work' ablegen
    ghdl -a $GHDL_STD --workdir="$BUILD" $(src_files) "$SIM_DIR"/*.vhd
    # -e  elaborieren: Hierarchie zusammensetzen, ausführbares Modell bauen
    ghdl -e $GHDL_STD --workdir="$BUILD" -o "$BUILD/$TB" "$TB"
    # -r  laufen lassen und alle Signale als VCD mitschreiben
    ghdl -r $GHDL_STD --workdir="$BUILD" "$TB" --vcd="$BUILD/$TB.vcd" --stop-time=10ms
    echo ">> Fertig. Öffnen mit: gtkwave $BUILD/$TB.vcd"
    ;;

  synth)
    # GHDL liest VHDL, Yosys mappt die Logik auf ECP5-Primitive (LUT4, FF, ...)
    # 'stat' am Ende = Ressourcen-Zählung -> Assignment A!
    yosys -m ghdl -p "ghdl $GHDL_STD $(src_files | tr '\n' ' ') -e $TOP; \
                      synth_ecp5 -top $TOP -json $BUILD/$TOP.json; \
                      stat" \
          2>&1 | tee "$BUILD/synth.log"
    ;;

  pnr)
    # Platzieren (welche LUT wo?) + Verdrahten (welche Leitungen?)
    # Hier, nicht in Yosys, werden die Pins aus der LPF-Datei geprüft.
    nextpnr-ecp5 --$DEVICE --package $PACKAGE \
                 --json "$BUILD/$TOP.json" --lpf "$LPF" \
                 --textcfg "$BUILD/$TOP.cfg" \
                 2>&1 | tee "$BUILD/pnr.log"
    ;;

  bit)
    # Textuelle Konfiguration -> binärer Bitstream
    ecppack "$BUILD/$TOP.cfg" "$BUILD/$TOP.bit"
    ;;

  all)
    "$0" synth && "$0" pnr && "$0" bit
    ;;

  prog)
    openFPGALoader -b $BOARD "$BUILD/$TOP.bit"
    ;;

  flash)
    openFPGALoader -b $BOARD -f "$BUILD/$TOP.bit"
    ;;

  clean)
    rm -rf "$BUILD"
    ;;

  *)
    sed -n '2,17p' "$0"     # Kopfkommentar als Hilfe ausgeben
    ;;
esac
