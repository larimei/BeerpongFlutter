# 01: Create and list competitions

**What to build:** Users can create in-memory competitions with a name, card color, and tournament mode, then see them in the Competitions overview using the same visual language as Players and Teams.

**Blocked by:** None (can start immediately).

**Status:** ready-for-agent

- [ ] The empty Competitions page explains that no competitions exist yet and remains usable on mobile and desktop web.
- [ ] The global add action on the Competitions page opens an English creation form for name, mode, and card color.
- [ ] A new form starts with an empty name, Knockout selected, no team assignments, and the existing yellow default color.
- [ ] The available modes are Knockout and Round robin, represented as fixed domain values rather than free text.
- [ ] A blank or whitespace-only name is rejected, while duplicate competition names are allowed.
- [ ] Submitting valid values creates an in-memory competition and immediately adds a trophy card to the overview.
- [ ] Each card displays the competition name and a compact summary such as `Knockout - 0 teams`.
- [ ] Competitions retain creation order and no sorting, searching, filtering, round, game, seeding, or persistent-storage behavior is introduced.
- [ ] Automated controller and widget tests cover validation, defaults, creation, mode handling, and overview rendering.
- [ ] Formatting, static analysis, and all relevant tests pass without changing unrelated Player or Team behavior.
