# 04: Safely delete assigned teams

**What to build:** Users receive a clear warning before deleting a team assigned to competitions, and confirmed deletion safely removes that team from every affected competition.

**Blocked by:** 03: Assign and manage competition teams.

**Status:** ready-for-agent

- [ ] Deleting an unassigned team retains the existing confirmation behavior.
- [ ] Deleting an assigned team warns how many competitions contain it and explains that it will be removed from them.
- [ ] Cancelling the warning leaves both the team and all competition memberships unchanged.
- [ ] Confirming deletion removes the team and its membership from every affected competition without changing the other teams or competition metadata.
- [ ] Competition cards and open detail pages immediately reflect the updated team memberships and counts.
- [ ] No round-reference deletion guard is implemented before the future Rounds feature provides that domain data.
- [ ] Automated controller and widget tests cover unassigned deletion, affected-competition counts, cancellation, cleanup across multiple competitions, and immediate UI updates.
- [ ] Formatting, static analysis, and all relevant tests pass.
