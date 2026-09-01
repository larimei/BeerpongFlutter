# 01: Overflow-sichere Player-Card als gemeinsame Card-Basis

**What to build:** Player-Cards zeigen auch lange Namen innerhalb einer responsiven, quadratischen Card. Die Gestaltung bildet zugleich die gemeinsame Basis für Team- und Competition-Cards: Alle Cards verwenden ein einheitliches 40-px-Icon und gleich große Quadrate innerhalb einer Übersicht. Der Name verwendet bevorzugt 18 px, darf bis 14 px verkleinert werden, umfasst höchstens zwei Zeilen und endet danach mit `…`. Ein gekürzter Name bleibt über einen Tooltip sowie für Screenreader vollständig zugänglich. Die Systemschriftgröße wird respektiert; bei erhöhtem Textmaßstab wird bei Bedarf früher gekürzt, ohne einen Layout-Overflow zu erzeugen.

**Blocked by:** None (can start immediately).

**Status:** ready-for-agent

- [ ] Player-Cards bleiben in allen unterstützten Viewport-Größen quadratisch und innerhalb ihres Grids gleich groß.
- [ ] Das Icon ist auf allen Entity-Cards einheitlich 40 px groß.
- [ ] Player-Namen verwenden höchstens zwei Zeilen, skalieren im vorgesehenen Bereich von 18 bis 14 px und werden erst danach mit `…` gekürzt.
- [ ] Kein langer Name erzeugt horizontalen oder vertikalen Flutter-Overflow, auch nicht auf einem schmalen Display.
- [ ] Ein gekürzter Name ist über einen Tooltip vollständig lesbar und wird Screenreadern vollständig bereitgestellt.
- [ ] Erhöhte Systemschrift wird respektiert und führt kontrolliert zu früherer Kürzung statt zu einem Overflow.
- [ ] Widget-Tests sichern lange Namen, ein schmales Display, erhöhte Systemschrift und das Ausbleiben von Layout-Ausnahmen ab.
