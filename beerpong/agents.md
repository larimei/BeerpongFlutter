# Bierpong Manager

## Product

Flutter web app for managing beer pong tournaments.

The app only manages data.
It does not simulate beer pong gameplay.

Main entities:

- Player
- Team
- Competition
- Game

Main pages:

- Players
- Teams
- Competitions

Games are managed inside competitions.

## Architecture

Use feature-based Flutter architecture.

Keep business logic outside widgets.

Use repositories for data access so persistence can be replaced later.

Prefer small reusable widgets.

Use Material 3.

The UI must work on desktop and mobile web.

## Code rules

- Keep files small.
- Avoid unnecessary abstractions.
- Do not add dependencies without explaining why.
- Never rewrite unrelated files.
- Run dart format after changes.
- Run flutter analyze after changes.
- Add tests for business logic.
- Fix analyzer warnings before declaring a task complete.

## Workflow

Before implementing a larger feature:

1. Inspect existing code.
2. Explain the intended changes.
3. Implement only the requested feature.
4. Run flutter analyze.
5. Run relevant tests.
6. Summarize changed files.
