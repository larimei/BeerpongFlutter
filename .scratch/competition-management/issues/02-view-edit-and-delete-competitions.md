# 02: View, edit, and delete competitions

**What to build:** Users can open a competition, inspect its information, change its name, color, or mode, and delete it with the same interaction patterns used by Players and Teams.

**Blocked by:** 01: Create and list competitions.

**Status:** ready-for-agent

- [ ] Selecting a competition card opens an English detail page that clearly displays its name, color, mode, and current team count.
- [ ] The detail page follows the existing entity-detail design but does not show artificial won/lost statistics.
- [ ] Edit competition allows the name, card color, and mode to be changed while preserving all other competition data.
- [ ] A blank or whitespace-only edited name is rejected, while duplicate competition names remain allowed.
- [ ] Saved edits immediately update both the detail page and overview card.
- [ ] Delete competition opens a confirmation dialog consistent with Player and Team deletion.
- [ ] Confirming deletion removes only the competition and returns to the overview; cancelling leaves it unchanged.
- [ ] Automated controller and widget tests cover lookup, editing, validation, cancellation, deletion, and missing-competition handling.
- [ ] Formatting, static analysis, and all relevant tests pass.
