# 02: Play a round-robin competition

**What to build:** Users can generate and play a round-robin competition in the same Tournament tab. Every pair of participating teams plays once as a sequential individual game, confirmed winners update the standings, and the competition finishes after its final game.

**Blocked by:** 01: Play a knockout competition.

**Status:** ready-for-agent

- [ ] Generating a round-robin competition creates each unique pair of assigned teams exactly once and presents them as sequential games rather than multi-match rounds.
- [ ] A user selects and confirms exactly one winner for every game; the resulting team scores and ordering update immediately.
- [ ] Standings are ranked by wins, then direct comparison, then the persisted draw order when a ranking remains tied.
- [ ] The competition automatically completes and presents its winner after the final game is confirmed.
- [ ] Automated domain/controller and widget tests cover pair generation, confirmed outcomes, standings tie-breaking, and completion.
- [ ] Formatting, static analysis, and all relevant tests pass.
