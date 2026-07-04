# 0002. Adopt C4 and SDD documentation standards

**Status:** Accepted
**Date:** 2026-07-04
**Deciders:** douglas.silva
**Related:** [ADR-0001](./0001-record-architecture-decisions.md), [`docs/architecture/README.md`](../architecture/README.md), [`docs/specs/README.md`](../specs/README.md)

## Context

This repository is being bootstrapped from scratch, before any code or established conventions exist. Beyond decisions (covered by ADRs, see ADR-0001), we also need a consistent way to (a) show how the system is structured and (b) define features before building them — so that both human contributors and AI coding agents produce documentation that stays comparable and doesn't drift into inconsistent, ad-hoc formats.

## Decision Drivers

- Needs to be legible to AI agents with no prior context on the project.
- Should render natively on GitHub without extra tooling where possible.
- Should scale from "empty repo" to a real system without requiring a rewrite of the convention later.

## Considered Options

- Free-form Markdown docs per topic, no fixed structure.
- UML diagrams (full notation) for architecture, free-form design docs for features.
- **C4 model** for architecture + **Spec-Driven Development (SDD)** for features, alongside ADRs for decisions.

## Decision

We will use the **C4 model** (Context/Container/Component, Mermaid syntax) for all architecture documentation under `docs/architecture/c4/`, and **Spec-Driven Development** (spec → plan → tasks) for all feature work under `docs/specs/`. Combined with ADRs (ADR-0001), these three frameworks are the *only* accepted documentation formats in this repository — see `docs/README.md` for the decision tree between them.

C4 was chosen over full UML for its fixed, small set of abstraction levels — it's fast to produce and consistently interpretable without a legend, and Mermaid's `C4Context`/`C4Container`/`C4Component` diagrams render directly on GitHub. SDD was chosen over free-form design docs because it forces a machine- and human-readable spec and plan to exist *before* implementation, which is especially valuable when AI agents are doing a meaningful share of the implementation work — a clear spec constrains what they build far better than a prose description embedded in a ticket.

## Consequences

- **Positive:** Any contributor or AI agent can predict where to find/put architecture, decision, and feature documentation without asking.
- **Negative:** Small upfront overhead per feature (spec + plan before code) and per structural change (diagram update).
- **Follow-ups:** Templates live in `docs/architecture/c4/`, `docs/adr/template.md`, and `docs/specs/TEMPLATE/`; `AGENTS.md` encodes the mandate for agents.
