# STATUS (vor jeder neuen Session aktualisieren)
Board bestellt: ja, 01.10.2026 – iCESugar-Pro (LFE5U-25F-6BG256C), Lieferung ca. Mitte Oktober
Assignment A gemacht: [ja/nein – Schätzung: __ LUTs / __ FFs, real: __]
Quiz-Antworten abgegeben: [ja/nein]

---

# WER ICH BIN
Ich lerne FPGA-Design mit VHDL. Ich habe Grundlagen-Erfahrung (blinky, 
Testbench-Workflow mit GHDL/GTKWave). Mein Ziel: einen kompletten CPU 
selbst verstehen und bauen — tiefes Verständnis ist das Ziel, nicht das 
Endergebnis. "The journey is the goal."

# ARBEITSREGELN (Lern-Contract)
1. Vor jedem Schritt kurz erklären WAS und WARUM — keine Zeile Code, 
   die ich nicht erklären kann.
2. Nach jedem Meilenstein 2–3 Quizfragen, ich antworte in eigenen Worten, 
   BEVOR wir weitergehen.
3. Wenn ich "gib mir einfach den fertigen Code" sage: erinnere mich an 
   diesen Contract und gib mir nur ein Skelett + Hinweise.
4. Simulation first: nichts aufs FPGA, was ich nicht in GTKWave gesehen habe.
5. Ich führe ein JOURNAL.md (was ich machte / was mich überraschte / 
   was ich nicht verstehe) — die "verstehe ich nicht"-Zeilen sind Quizstoff.

# TOOLCHAIN
- OSS CAD Suite (github.com/YosysHQ/oss-cad-suite-build) — enthält Yosys 
  mit GHDL-Plugin, nextpnr (ice40+ecp5), ecppack, icestorm, openFPGALoader.
- Simulation: ghdl -a/-e/-r --vcd → GTKWave
- ECP5-Flow: 
  yosys -m ghdl -p "ghdl synth -top top; synth_ecp5 -json top.json" top.vhd
  nextpnr-ecp5 --25k --package CABGA256 --json top.json --lpf icesugar_pro.lpf --textcfg top.cfg
  ecppack top.cfg top.bit
  openFPGALoader -b <BOARD> top.bit      # SRAM, zum Experimentieren
  openFPGALoader -b <BOARD> -f top.bit   # Flash, wenn's funktioniert
  (alles in build.sh verpackt: ./build.sh sim|synth|pnr|bit|prog|flash)
- Wichtig: iCE40 = Project IceStorm, ECP5 = Project Trellis (zwei 
  getrennte Open-Source-Projekte, gleiches Prinzip).

# HARDWARE
- Board: iCESugar-Pro (Muse Lab, AliExpress), FPGA LFE5U-25F-6BG256C, 
  JTAG-IDCODE: [selbst nachschlagen]. openFPGALoader-Board-Name: [verifizieren].
- Warum dieses Board: 24k LUTs, 32 MB SDRAM, microSD, onboard iCELink 
  (JTAG + USB-UART) → reicht bis M6 Linux (icesugar_pro ist in 
  linux-on-litex-vexriscv). Kein Ethernet, kein HDMI – bewusst, Preis.
  (Vorher geplant: ULX3S 85F, ~220 CHF – zu teuer.)
- ECP5 ist SRAM-basiert → vergisst Bitstream bei Power-off → 
  Konfigurationsflash (25F: [selbst rechnen: Frames × Bits]; Board hat 32 MB Flash).
- Constraint-Dateien NUR aus offiziellen Quellen kopieren 
  (github.com/wuxx/icesugar-pro), nie Pins raten.
- Der BGA-Chip wird später NICHT vom Board gelöst — portabel sind 
  VHDL + Skills. Eigenes PCB (M7) bekommt einen frischen Chip.

# ROADMAP
M0  Bring-up: blinky + UART "Hello" auf dem Board
M1  UART TX (und RX) komplett in Simulation, dann auf Hardware
M2  MiniCPU-8: 8-Bit-CPU im Ben-Eater-Stil (Akkumulator, Flags, 
    FSM FETCH→DECODE→EXECUTE, 256 B Block-RAM, Programme via textio/Hex)
M3  Assembler in Python (~100 Zeilen)
M4  Eigener RV32I-Kern; Interrupts + Timer → FreeRTOS auf dem EIGENEN Kern
M5  SoC: Wishbone, UART, Timer, GPIO, SPI; SDRAM-Controller; SD-Karte
M6  Linux über LiteX + VexRiscv auf iCESugar-Pro (mainline Kernel, 
    liteuart/liteeth/litex-mmc sind im Kernel)
M7  Eigenes PCB: handlötbar, z. B. iCE40-HX1K/4K-TQ144, 
    mit dem bisherigen icestorm-Flow
M8  Mini-Laptop: HDMI/eDP-Panel, USB-Host-Tastatur, ESP32 als 
    WLAN-Modem, LiPo — mein SoC als CPU
S1  Side-Quest Musik-DSP: DDS (Phasenakkumulator; Rechteck = MSB, 
    Dreieck = XOR-Fold, Sägezahn = Accumulator, Sinus = ROM-Tabelle), 
    Distortion (Hard/Soft-Clip, Bitcrush), Delay = BRAM-Ringbuffer, 
    I2S-DAC (PCM5102), Thema Aliasing/Oversampling

# OFFENE PUNKTE (nicht abgehakt)
- Quiz #0: (1) Was speichert eine LUT und wie landet Blinky-Logik darin? 
  (2) Pin-Typo im Constraint — failed Yosys oder nextpnr, und warum 
  kümmert das andere nicht?
- Assignment A: blinky für ECP5 synthetisieren, LUT4/FF-Schätzung VOR 
  dem stat-Output notieren, Differenz erklären.
- M1-Einstiegsfrage: Warum hat jedes UART-Byte ein Start-Bit? 
  Was bricht ohne es? (Stichwort: zwei unabhängige Takte)
- Zu verifizieren: hat die ECP5-Familie doch ein TQFP144-Package 
  (Datenblatt checken)?

# FACHLICHER RAHMEN (schon geklärt, bitte nicht neu erklären)
- Bitstream = Konfiguration, die Hardware WIRD, kein Programm.
- LUTs speichern Truth Tables; BRAM vs. SPRAM (UP5K: 128 KB, single-port).
- 12F/25F = Binning (fast gleiches Die); iCE40-"4K"-Chips sind 8K-Dies.
- SerDes nur in LFE5UM-Varianten, mit Open-Source-Tools nicht nutzbar — egal für uns.
- Op-Amp geht nicht im FPGA (analog ≠ digital); Musik-DSP trotzdem 
  perfekt machbar → S1.
- SDRAM-Controller (row activate / CAS / refresh) ist M5-Baustein, 
  DRAM-Zellen selbst kann man nicht "bauen".