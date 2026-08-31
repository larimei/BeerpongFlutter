# Domain Docs

This repository uses a single-context domain-documentation layout.

## Before exploring

Read these when they exist:

- `CONTEXT.md` at the repository root
- Relevant decisions under `docs/adr/`

If these files do not exist, proceed silently. Domain-modeling skills create them when terminology or architectural decisions need to be recorded.

## File structure

```
/
├── CONTEXT.md
├── docs/
│   └── adr/
└── beerpong/
    └── lib/
```

## Vocabulary

Use domain concepts as defined in `CONTEXT.md`. Avoid introducing synonyms that conflict with its glossary.

If a required concept is missing, reconsider whether it belongs to the project vocabulary or note it for domain modeling.

## ADR conflicts

Explicitly flag output that contradicts an existing architectural decision rather than silently overriding it.
