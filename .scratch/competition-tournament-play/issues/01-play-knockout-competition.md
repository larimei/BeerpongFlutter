# 01: Play a knockout competition

**What to build:** Users can open a competition's Info and Tournament tabs, generate and play a complete knockout tournament with two or more assigned teams, and see its winner when the final is confirmed. The generated tournament randomly assigns pairings, adds visible automatic byes when needed, and shows locked future-match placeholders until both participants are known. A match lets the user choose exactly one winning team and explicitly confirm that outcome before the winner advances.

**Blocked by:** None (can start immediately).

**Status:** ready-for-agent

- [ ] A competition with at least two assigned teams can generate a knockout tournament from its Info tab; the Tournament tab has a clear empty state before generation.
- [ ] Generated brackets use a random, persisted draw order, create required byes up to the next power of two, and display known and future matches in their correct knockout stages.
- [ ] Each playable match permits exactly one selected winner; confirming it records the outcome and advances that team only after confirmation.
- [ ] Future matches remain visible but cannot be decided until both participants are known, and the competition completes automatically when its final is confirmed.
- [ ] Automated domain/controller and widget tests cover two teams, non-power-of-two team counts, byes, winner advancement, and completion.
- [ ] Formatting, static analysis, and all relevant tests pass.
