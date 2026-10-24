# JOURNAL

Ein Eintrag pro Arbeitssession. Die "verstehe ich nicht"-Zeilen sind Quizstoff.

---

## 2026-10-01
**Was ich machte:**
- Board-Entscheidung: iCESugar-Pro statt ULX3S (Preis). Bestellt.
- Repo angelegt.

**Was mich überraschte:**
-

**Was ich nicht verstehe:**
-

## 2026-10-18
**Was ich machte:**
- Board kam an, Blinky-Test erfolgreich (LED blinkt blau). Build + Upload per iCELink-Laufwerk, steht in der README.
- ALU begonnen (src/alu.vhd): Generic WIDTH, Ports, `case op` im Prozess.

**Was mich überraschte:**
- openFPGALoader kennt das Board nicht; Programmieren geht per Drag-and-drop.

**Was ich nicht verstehe:** (Quizstoff, siehe EETheorie/CPU/VHDL Knowledge/Slices, resize and conversions)
- `WIDTH - 1 downto 0`: was heißt das genau, warum `-1`?
- `resize(...)`: was macht es und warum brauche ich es?
- Klammern in `std_logic_vector(...)` und `wide_result(...)`: Konvertierung vs. Slice.
- (gefällt mir) `'1' when ... = 0 else '0';`
