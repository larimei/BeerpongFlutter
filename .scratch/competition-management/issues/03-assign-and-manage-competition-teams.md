# 03: Assign and manage competition teams

**What to build:** Users can select existing teams while creating a competition and later manage its team membership from the competition detail page.

**Blocked by:** 02: View, edit, and delete competitions.

**Status:** ready-for-agent

- [ ] The creation form includes a bounded, scrollable checkbox list showing each existing team's name and color.
- [ ] If no teams exist, the form displays `No teams available. You can add teams later.` and still permits competition creation.
- [ ] A competition may contain zero or more teams, and the same team may belong to multiple competitions.
- [ ] Team selection order has no seeding or gameplay meaning, and duplicate team references are not stored.
- [ ] The detail page displays the assigned teams and provides a separate Manage teams action.
- [ ] Manage teams supports adding and removing memberships, saving changes, and cancelling without changes.
- [ ] Editing competition metadata preserves its team memberships, and managing teams preserves its name, color, and mode.
- [ ] Overview cards and detail information immediately reflect the current team count.
- [ ] The selection UI introduces no search, filter, sorting, round, game, or seeding behavior.
- [ ] Automated controller and widget tests cover empty availability, initial selection, membership changes, cancellation, deduplication, and live team-count updates.
- [ ] Formatting, static analysis, and all relevant tests pass.
