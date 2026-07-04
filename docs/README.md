# Documentation

All documentation in this repository follows one of three frameworks. There is no fourth category — if what you want to write doesn't fit, it usually means it belongs inside one of these three, not next to them.

| I want to... | Use | Where |
|---|---|---|
| Show how the system (or a part of it) is structured | **C4 model** | [`architecture/`](./architecture/README.md) |
| Justify/record a significant technical decision | **ADR** | [`adr/`](./adr/README.md) |
| Define a feature before building it | **SDD** | [`specs/`](./specs/README.md) |

## Decision tree

```
Is this about *why* we chose an approach (tech, protocol, pattern)?
  └─ yes → write an ADR                              → docs/adr/
Is this about *what the system looks like* (structure, integrations)?
  └─ yes → update/add a C4 diagram                    → docs/architecture/c4/
Is this about *what to build* (a feature, endpoint, workflow)?
  └─ yes → write a spec → plan → tasks (SDD)           → docs/specs/<feature-slug>/
```

The three are complementary, not exclusive: a feature spec (SDD) commonly triggers a new C4 diagram update and one or more ADRs for the decisions made along the way. Cross-link between them (e.g. an SDD `plan.md` should link to any ADR it relies on; an ADR should link to the C4 diagram it affects).

## Quick links

- [Architecture (C4)](./architecture/README.md)
- [Architecture Decision Records](./adr/README.md)
- [Spec-Driven Development](./specs/README.md)
