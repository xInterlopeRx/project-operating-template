# Project Instructions

Replace every `TODO(template)` before relying on this file. Keep durable rules concise, specific, and verifiable.

## Project purpose and authority

- Project: **[PRODUCT_NAME]**
- Purpose: **[ONE-SENTENCE PURPOSE]**
- Primary users: **[USER TYPES]**
- Canonical product entry: `docs/product/PRODUCT.md`
- Canonical current release scope: `docs/product/RELEASE-PLAN.md`
- Canonical architecture decisions: accepted ADRs in `docs/architecture/decisions/`

Resolve conflicts in this order: (1) user's current explicit request, (2) accepted ADRs and documented release scope, (3) product and architecture docs, (4) implementation for actual current behavior and versions, (5) assumptions. If a request intentionally changes a documented decision, implement only its stated scope and update affected canonical docs; add/amend an ADR for material architectural changes.

## Before planning or changing implementation

1. Confirm repository root, branch, working-tree state, and relevant local changes.
2. Read this file, `README.md`, `docs/README.md`, product scope, applicable architecture/data-model docs, relevant ADRs, and closer instructions.
3. Verify that every referenced path exists. Search for existing behavior and read sibling implementation and tests before naming/creating files.
4. Inspect manifests and lockfiles before relying on framework/library versions, APIs, commands, or packages.
5. Read the relevant UI, security, testing, and integration guidance for the change.
6. Identify product scope, authorization, validation, persistence/migration, external side effects, observability, documentation, and test impacts.

## Implementation rules

- Prefer the smallest complete vertical slice that satisfies the request.
- Follow observed project patterns. Do not add dependencies, top-level folders, frameworks, or architecture layers without approval.
- Enforce access on the server; hidden UI controls are not an authorization boundary.
- Validate input at trust boundaries; protect database integrity with constraints and transactions where needed.
- Keep external-provider behavior behind bounded adapters. Queue retryable/slow external work when appropriate; make retries safe and observable.
- Keep secrets, personal data, and credentials out of source control, browser storage, logs, exceptions, screenshots, and queued payloads.
- Do not silently expand product scope or use live systems/data when sandbox, fake, or test paths suffice.
- Treat unfamiliar files and existing changes as user work; do not broadly reset, overwrite, or delete them.

## UI and design system

- Backend-only work is not blocked by UI palette, font, stylesheet, or visual-design decisions. Before beginning a user-facing UI phase, satisfy the UI readiness gate in `docs/development/PHASE-GATES.md`.
- After the gate is satisfied, read `docs/ui/DESIGN-SYSTEM.md` before adding or restyling user-facing UI.
- Use the project's documented stylesheet entry point and semantic design tokens; do not scatter unexplained raw brand colors across components.
- Preserve keyboard operation, visible focus, semantic controls, readable contrast, touch targets, responsive layouts, reduced-motion preferences, and status cues that do not rely on color alone.
- Do not add font files until their usage rights/source and license are recorded. Prefer local self-hosting when approved; never introduce an unreviewed remote font service or font binary.
- Verify the changed UI at relevant desktop and mobile widths and report the method/results. Do not claim visual inspection if only a build was run.

## Documentation and tests

- Update canonical documentation when behavior, scope, architecture, data contracts, security, setup, or operations change. Avoid duplicating long rationale in multiple documents.
- Record progress/blockers in `docs/development/TASKLOG.md`; record durable decisions in ADRs instead.
- Add tests at the layer that proves behavior. Protect authorization, invalid input, failure/retry behavior, persistence integrity, and important UI workflows.
- Tests must be isolated from production systems and must not depend on developers' local credentials/configuration. Fake external providers by default.
- Run the narrowest relevant checks, then broader checks when risk warrants. Format changed code and review migration/external contracts.

## Completion report

Before reporting completion:

1. Inspect the complete relevant diff and `git diff --check`.
2. Run the applicable commands from `docs/development/TESTING.md` and report actual results, including checks not run.
3. Review secrets/generated files and unrelated changes; preserve existing user work.
4. Update affected canonical docs and the task handoff.
5. Summarize behavior, files, validation, external/live side effects, risks, and remaining decisions.
