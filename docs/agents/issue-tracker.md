# Issue tracker: Local Markdown

Issues and specs for this repo live as Markdown files in `.scratch/`.

## Conventions

- One feature per directory: `.scratch/<feature-slug>/`
- The spec is `.scratch/<feature-slug>/spec.md`
- Implementation issues are one file per ticket at `.scratch/<feature-slug>/issues/<NN>-<slug>.md`, numbered from `01`
- Triage state is recorded as a `Status:` line near the top of each issue file
- Comments and conversation history are appended under a `## Comments` heading

## Publishing and fetching

When a skill says “publish to the issue tracker,” create a file under `.scratch/<feature-slug>/`.

When a skill says “fetch the relevant ticket,” read the referenced file.

## Wayfinding operations

- Map: `.scratch/<effort>/map.md`
- Child ticket: `.scratch/<effort>/issues/NN-<slug>.md`
- Ticket types: `research`, `prototype`, `grilling`, or `task`
- Ticket statuses: `claimed` or `resolved`
- Dependencies use `Blocked by: NN, NN`
- Claiming sets `Status: claimed`
- Resolving adds an `## Answer`, sets `Status: resolved`, and records the result in `map.md`
