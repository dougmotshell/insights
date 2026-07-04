# Architecture — C4 Model

We document system structure using the [C4 model](https://c4model.com/) (Context, Container, Component, Code). It gives a consistent zoom level for every diagram so anyone — human or AI agent — knows exactly which level of detail they're looking at.

## Levels

1. **Context** (`c4/context.md`) — the system as one box, its users, and the other systems it talks to. Audience: anyone, including non-technical stakeholders.
2. **Container** (`c4/container.md`) — the applications/services/data stores that make up the system, and how they communicate. Audience: technical, both inside and outside the team.
3. **Component** (`c4/component.md`) — the internal building blocks of a single container. Audience: the team that owns that container.
4. **Code** (optional) — class/module-level diagrams. Only add these if a component's internals are genuinely hard to follow from the code itself; generated UML from an IDE is usually enough and doesn't need to live here.

## Rules

- One file per diagram, named after the system/container it describes: `c4/context-<system-slug>.md`, `c4/container-<system-slug>.md`, etc. Start from the templates below.
- Diagrams are written in **Mermaid C4 syntax** so GitHub renders them natively (no external tool required).
- **Update the diagram in the same PR** that changes the structure it depicts. A stale diagram is worse than no diagram.
- Every diagram file has a short "Notes" section below the diagram — use it for anything Mermaid can't express (rate limits, protocols, ownership).

## Templates

- [`c4/context.md`](./c4/context.md) — Level 1
- [`c4/container.md`](./c4/container.md) — Level 2
- [`c4/component.md`](./c4/component.md) — Level 3

Copy the relevant template, rename it, and fill it in — don't edit the templates themselves to describe a real system.
