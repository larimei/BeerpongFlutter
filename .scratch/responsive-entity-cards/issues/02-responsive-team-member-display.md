# 02: Team-Cards mit responsiver Mitgliederanzeige

**What to build:** Team-Cards verwenden die gemeinsame overflow-sichere Card-Gestaltung und zeigen zusätzlich die tatsächlich vorhandenen Teammitglieder. Eine Card ohne Mitglieder zeigt `No players`, bei einem Mitglied erscheint dessen Name und bei zwei Mitgliedern erscheinen beide Namen jeweils auf einer eigenen kompakten Zeile. Bei mehr als zwei vorhandenen Mitgliedern wird stattdessen die Anzahl als englischer Text wie `4 players` angezeigt. Nicht mehr existierende Spieler werden weder angezeigt noch gezählt. Lange Team- und Spielernamen bleiben innerhalb des quadratischen Layouts und sind bei Kürzung vollständig zugänglich.

**Blocked by:** 01: Overflow-sichere Player-Card als gemeinsame Card-Basis.

**Status:** ready-for-agent

- [ ] Eine Team-Card mit keinem vorhandenen Mitglied zeigt `No players`.
- [ ] Eine Team-Card mit einem vorhandenen Mitglied zeigt dessen Namen.
- [ ] Eine Team-Card mit zwei vorhandenen Mitgliedern zeigt beide Namen auf jeweils einer eigenen Zeile.
- [ ] Eine Team-Card mit mehr als zwei vorhandenen Mitgliedern zeigt statt der Namen die korrekte englische Spieleranzahl.
- [ ] Verwaiste Spielerzuordnungen werden ignoriert; Darstellung und Anzahl beruhen ausschließlich auf aktuell existierenden Spielern.
- [ ] Teamname und Zusatzinformationen überschreiten niemals die Card-Grenzen; gekürzte Namen verwenden `…` und bleiben per Tooltip und Screenreader vollständig zugänglich.
- [ ] Widget-Tests sichern alle Mitgliederfälle, lange Namen, ein schmales Display und das Ausbleiben von Layout-Ausnahmen ab.
