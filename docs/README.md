# Documentation Index

Replace placeholders and keep this index synchronized with the files actually adopted by the project.

## Canonical documents

- [Product charter](product/PRODUCT.md) — purpose, users, problems, principles, outcomes.
- [Release plan](product/RELEASE-PLAN.md) — included scope, exclusions, acceptance/success criteria.
- [Open decisions](product/OPEN-DECISIONS.md) — unresolved choices and owners/next steps.
- [Architecture](architecture/ARCHITECTURE.md) — system boundaries, components, dependencies, operations.
- [Data model](architecture/DATA-MODEL.md) — persistent entities, constraints, ownership, lifecycle.
- [Development](development/DEVELOPMENT.md) — setup, commands, branch/PR workflow.
- [Testing](development/TESTING.md) — strategy, isolation, test matrix, validation commands.
- [Phase gates](development/PHASE-GATES.md) — backend foundation-to-UI and UI release readiness; UI prerequisites do not block backend-only work.
- [Documentation workflow](development/DOCUMENTATION-WORKFLOW.md) — where updates belong and how to validate them.
- [Task log](development/TASKLOG.md) — current progress and handoff, not durable architecture decisions.
- [UI design system](ui/DESIGN-SYSTEM.md) — stylesheet entry point, tokens, colors, typography, responsive/accessibility rules.
- [Security baseline](operations/SECURITY.md) — credentials, authorization, privacy, environment separation.
- [Deployment baseline](operations/DEPLOYMENT.md) — release, migration, backup, monitoring, recovery.

## Decision records

Store material architecture decisions in `architecture/decisions/ADR-NNNN-short-title.md`. Copy `architecture/decisions/ADR-TEMPLATE.md`; maintain sequential numbering and an explicit status (`Proposed`, `Accepted`, `Superseded`, or `Retired`). Product-scope decisions may live in product docs unless they materially affect architecture or persistent contracts.

## Writing rules

- State the owner/source of truth, status, date, and scope where useful.
- Separate verified facts, decisions, recommendations, and unresolved questions.
- Link to canonical documents rather than repeating full policy text.
- Date time-sensitive integration findings and cite primary sources.
- Never put credentials, tokens, private customer data, or secret-bearing environment examples in docs.
- Delete or revise obsolete instructions instead of leaving conflicting copies.
