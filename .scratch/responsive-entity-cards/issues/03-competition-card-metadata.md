# 03: Competition-Cards mit Modus und gültiger Teamanzahl

**What to build:** Competition-Cards verwenden die gemeinsame overflow-sichere Card-Gestaltung und zeigen unter dem Namen eine kompakte englische Metazeile mit dem vorhandenen Modus-Label und der Anzahl der aktuell existierenden zugehörigen Teams, zum Beispiel `Round robin · 8 teams`. Verwaiste Teamzuordnungen werden bei der Anzahl ignoriert. Name und Metadaten bleiben auch bei langen Namen, erhöhter Systemschrift und schmalen Displays vollständig innerhalb des quadratischen Layouts; ein gekürzter Competition-Name bleibt vollständig zugänglich.

**Blocked by:** 01: Overflow-sichere Player-Card als gemeinsame Card-Basis.

**Status:** resolved

- [ ] Jede Competition-Card zeigt das vorhandene englische Modus-Label.
- [ ] Jede Competition-Card zeigt die Anzahl der aktuell existierenden zugehörigen Teams als englischen Text.
- [ ] Verwaiste Teamzuordnungen werden bei der angezeigten Anzahl nicht mitgezählt.
- [ ] Modus und Teamanzahl erscheinen gemeinsam in einer kompakten Metazeile.
- [ ] Competition-Name und Metazeile überschreiten niemals die Card-Grenzen, auch nicht auf einem schmalen Display oder bei erhöhter Systemschrift.
- [ ] Ein gekürzter Competition-Name verwendet `…` und bleibt per Tooltip und Screenreader vollständig zugänglich.
- [ ] Widget-Tests sichern lange Namen, beide Competition-Modi, unterschiedliche Teamanzahlen, ein schmales Display und das Ausbleiben von Layout-Ausnahmen ab.

## Answer

Competition-Cards zeigen jetzt eine kompakte Metazeile im Format
`Round robin · 8 teams`. Die Anzahl beruecksichtigt nur aktuell existierende,
zugeordnete Teams. Die gemeinsame Card-Basis begrenzt Name und Metadaten auch
bei schmalen Cards und grosser Systemschrift; gekuerzte Namen bleiben per
Tooltip und Semantics zugaenglich. Widget-Tests decken beide Modi,
Singular/Plural, verwaiste Zuordnungen und das responsive Layout ab.
