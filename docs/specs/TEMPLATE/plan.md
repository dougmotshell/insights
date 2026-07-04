<!-- TEMPLATE — copy this whole TEMPLATE/ folder to docs/specs/<feature-slug>/ and fill in. Delete these comments when done. -->
# Plan: \<Feature Name\>

**Spec:** [`spec.md`](./spec.md)
**Related ADRs:** \<links, or "none yet — this plan may spawn one, see below"\>
**Related C4 diagrams:** \<links to diagrams this feature affects; update them alongside this plan\>

## Approach

How will this be built, at a level someone unfamiliar with the codebase (or an AI agent with no prior context) can follow. Reference the containers/components from the C4 diagrams by name.

## Data model / interfaces

Schemas, API contracts, function signatures — whatever is load-bearing for implementation. Keep it precise; this is what tasks.md will be derived from.

## Decisions requiring an ADR

List any choice made in this plan that is significant/hard to reverse (new dependency, protocol, storage choice). Write the ADR under `docs/adr/` and link it here before implementation starts.

- \<decision\> → [ADR-00XX](../../adr/00XX-title.md)

## Risks / trade-offs

- \<risk 1 and mitigation\>

## Test strategy

How will we know each acceptance criterion in `spec.md` is met (unit, integration, manual)?
