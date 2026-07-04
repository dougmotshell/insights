# AGENTS.md

Instructions for any AI coding agent (Claude Code, Cursor, Aider, Copilot, Codex, etc.) working in this repository. This file is the canonical source of project conventions — tool-specific files (e.g. `CLAUDE.md`) should import/reference it instead of duplicating it.

## Project

`insights` — repository scaffold. Update this section with a one-paragraph description as soon as the project's purpose is defined.

## Documentation standards (mandatory)

Every document added to this repo MUST fit one of these three frameworks. Do not invent ad-hoc doc formats or add loose notes/README dumps outside these structures.

| Framework | Purpose | Location | Use when |
|---|---|---|---|
| **C4 model** | Visualize architecture at Context / Container / Component (/ Code) levels | `docs/architecture/c4/` | Describing or changing system structure, integrations, or how components relate |
| **ADR** (Architecture Decision Records) | Record a significant, hard-to-reverse technical decision and its rationale | `docs/adr/` | Choosing a technology, pattern, protocol, or reversing/superseding a prior decision |
| **SDD** (Spec-Driven Development) | Define a feature via spec → plan → tasks before implementation | `docs/specs/` | Building a new feature, endpoint, workflow, or any non-trivial change in behavior |

Full process details, templates, and examples live in `docs/README.md` and the `README.md` of each subfolder. Read the relevant one before writing a new doc.

### Ground rules

- **ADRs are immutable once accepted.** To change a past decision, write a new ADR that supersedes it (update the old one's `Status` to `Superseded by ADR-00XX`) — never edit history in place.
- **C4 diagrams must stay in sync with reality.** If a change alters container/component boundaries or integrations, update the corresponding C4 diagram in the same PR.
- **No code before a spec for non-trivial work.** For any feature beyond a trivial fix, write `spec.md` (what/why) and `plan.md` (how) under `docs/specs/<feature-slug>/` before writing implementation code. Trivial fixes (typos, small bug fixes, config tweaks) don't need a spec.
- **Number ADRs sequentially**, zero-padded to 4 digits: `NNNN-kebab-case-title.md`.
- Diagrams use **Mermaid C4 syntax** (`C4Context`, `C4Container`, `C4Component`) so they render natively on GitHub without extra tooling.

## Working conventions

- Prefer editing existing files over creating new ones; don't scatter documentation outside the three structures above.
- Keep changes scoped to what was asked — no speculative abstractions or unrelated refactors.
- Commands (build/lint/test) are not yet defined for this repo — add them here once tooling is introduced, and keep this section current.

## Repository layout

```
.
├── AGENTS.md              # this file — canonical agent instructions
├── CLAUDE.md              # Claude Code entry point (imports this file)
├── docs/
│   ├── README.md          # documentation index & decision tree
│   ├── architecture/      # C4 model diagrams
│   │   └── c4/
│   ├── adr/                # Architecture Decision Records
│   └── specs/               # Spec-Driven Development specs
└── prompts/                # prompt assets (project-specific)
```
