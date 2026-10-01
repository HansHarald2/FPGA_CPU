# constraints/

Hier kommt `icesugar_pro.lpf` hin – die Pin-Zuordnung (welcher VHDL-Port an welchem Chip-Pin hängt).

**Regel:** NUR aus der offiziellen Quelle kopieren, nie Pins raten:
https://github.com/wuxx/icesugar-pro

Danach: Port-Namen in `src/top.vhd` an die Namen in der LPF-Datei anpassen
(oder umgekehrt – aber dann bewusst und im JOURNAL notiert).
