# 0001. Record architecture decisions

**Status:** Accepted
**Date:** 2026-07-04
**Deciders:** douglas.silva
**Related:** —

## Context

We need a lightweight, durable way to record why significant technical decisions were made — for humans and for AI agents that will work in this repo without having lived through the original discussion. Decisions made verbally or only in chat/PR comments get lost or require archaeology to reconstruct.

## Decision Drivers

- Must be plain text, versioned alongside the code, and cheap to write.
- Must be readable by AI coding agents without special tooling.
- Must make it obvious when a decision has been superseded rather than silently changed.

## Considered Options

- No formal record — rely on commit messages and PR descriptions.
- A wiki page per decision, editable in place.
- Architecture Decision Records (ADRs), one immutable file per decision, in-repo.

## Decision

We will use **ADRs**, one file per decision under `docs/adr/`, following the template in `docs/adr/template.md`.

Commit messages and PRs describe *what* changed; ADRs describe *why* a structural decision was made and what else was considered. In-repo plain-text files keep them versioned with the code and trivially readable by any AI agent operating in this repository, unlike a wiki.

## Consequences

- **Positive:** Decision history survives team turnover and is directly accessible to any agent working in the repo.
- **Negative:** Adds a small amount of process overhead for decisions that qualify.
- **Follow-ups:** Every subsequent ADR must be added to the index in `docs/adr/README.md`.
