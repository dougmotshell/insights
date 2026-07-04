# Architecture Decision Records (ADR)

An ADR captures a single significant, hard-to-reverse technical decision: the context that forced it, the options considered, the choice made, and its consequences. Format follows [Michael Nygard's original proposal](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions) with light [MADR](https://adr.github.io/madr/)-style additions (decision drivers, considered options).

## When to write one

Write an ADR when a decision:
- would be expensive or disruptive to reverse (choice of database, protocol, framework, auth model, etc.), or
- resolves a real disagreement/trade-off worth remembering, or
- future contributors (human or AI agent) would otherwise have to reverse-engineer from the code.

Don't write an ADR for reversible implementation details, naming choices, or anything a code comment already explains well.

## Process

1. Copy [`template.md`](./template.md) to `NNNN-kebab-case-title.md`, using the next sequential number (check the highest existing number first).
2. Set `Status: Proposed`, fill in Context / Decision Drivers / Considered Options / Decision / Consequences.
3. Get it reviewed alongside the code/design it justifies.
4. On merge, set `Status: Accepted`.
5. If a later decision replaces this one, do **not** edit this file's decision — add a new ADR and set this one's status to `Superseded by ADR-00XX` (link it). ADRs are an immutable log, not a wiki page.

## Index

| # | Title | Status |
|---|---|---|
| [0001](./0001-record-architecture-decisions.md) | Record architecture decisions | Accepted |
| [0002](./0002-adopt-c4-and-sdd-documentation-standards.md) | Adopt C4 and SDD documentation standards | Accepted |

Update this table whenever an ADR is added or its status changes.
