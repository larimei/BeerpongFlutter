# 03: Protect tournament history and derive statistics

**What to build:** Users can safely maintain competitions without corrupting tournament history, while Team and Player detail pages show their overall wins and losses from confirmed competition games. Team or mode changes before the first confirmed game clearly warn that the generated plan will be replaced; after that point they require an explicit tournament reset. Player changes within a participating team remain allowed without affecting the tournament.

**Blocked by:** 01: Play a knockout competition; 02: Play a round-robin competition.

**Status:** ready-for-agent

- [ ] Before any confirmed game, changing a competition's teams or mode warns that the existing plan will be regenerated; cancelling preserves it and confirming replaces the unstarted plan.
- [ ] After a confirmed game, teams and mode can change only through a clearly explained reset that removes the generated tournament and its outcomes.
- [ ] A confirmed knockout result can be corrected only when no dependent later match has been confirmed; otherwise the user can explicitly clear the affected path of outcomes.
- [ ] Team and Player statistic bars show total confirmed wins and losses across competitions, with no per-competition statistics in those detail pages.
- [ ] A confirmed game attributes player results to the players in the team at confirmation time; later player membership changes do not alter the tournament or historical statistics.
- [ ] Resetting or clearing confirmed outcomes removes their derived team and player statistic effects.
- [ ] Automated domain/controller and widget tests cover generation warnings, reset and correction cascades, player membership changes, historical result attribution, and derived statistic updates.
- [ ] Formatting, static analysis, and all relevant tests pass.
