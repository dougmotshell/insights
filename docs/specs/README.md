# Spec-Driven Development (SDD)

For any non-trivial feature or behavior change, we write the spec **before** the code: what/why (`spec.md`), then how (`plan.md`), then the ordered execution checklist (`tasks.md`). This is especially important when an AI agent is doing the implementation — a precise spec constrains it far better than an ad-hoc prompt or a one-line ticket description.

Trivial changes (typo fixes, small bug fixes, config tweaks, dependency bumps) don't need a spec — use judgment, and default to writing one when in doubt.

## Workflow

1. Create `docs/specs/<feature-slug>/` (kebab-case, e.g. `docs/specs/user-password-reset/`).
2. Copy the three template files from [`TEMPLATE/`](./TEMPLATE/) into it.
3. Write **`spec.md`** first — requirements and acceptance criteria, no implementation detail. Get it agreed before moving on.
4. Write **`plan.md`** — the technical approach: architecture touched, data model, sequencing, and links to any ADR the plan relies on or that this plan should spawn.
5. Write **`tasks.md`** — a checked-off, ordered list of concrete implementation steps derived from the plan.
6. Implement by working through `tasks.md`. If reality diverges from the plan, update `plan.md` (and `spec.md` if the requirement itself changed) — keep them truthful, not just historical.

## Index

| Feature | Status | Spec |
|---|---|---|
| _(none yet)_ | | |

Add a row here for every spec folder created, and keep `Status` current (`Draft` / `In Progress` / `Done` / `Abandoned`).
