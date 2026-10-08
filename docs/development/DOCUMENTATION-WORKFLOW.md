# Documentation Maintenance Workflow

## Which document changes?

| Change | Update |
|---|---|
| Product purpose, primary user, principles, success measure | `docs/product/PRODUCT.md` |
| Release inclusion/exclusion or acceptance criteria | `docs/product/RELEASE-PLAN.md` |
| Unresolved product/technical choice | `docs/product/OPEN-DECISIONS.md` |
| Material architecture/trust-boundary choice | New or amended ADR; then architecture overview |
| Persistent entities, identifiers, constraints, lifecycle | `docs/architecture/DATA-MODEL.md` |
| Local setup, commands, branch/review flow, hook behavior | `docs/development/DEVELOPMENT.md` |
| Test strategy, isolation, quality gate | `docs/development/TESTING.md` |
| Credentials, data sensitivity, authorization, threat boundary | `docs/operations/SECURITY.md` |
| Release, backup, restore, monitoring, rollback | `docs/operations/DEPLOYMENT.md` |
| Provider-specific behavior and operational steps | `docs/integrations/<PROVIDER>.md` or runbook |
| Current work, blockers, handoff | `docs/development/TASKLOG.md` |
| Durable rationale/lessons across tasks | `MEMORY.md` or project equivalent |

## Change procedure

1. Identify the canonical document and whether the change is a fact, decision, proposal, or unresolved item.
2. Confirm the behavior from code/config/manifests or primary external documentation. Label assumptions and date time-sensitive research.
3. Update the canonical source and relevant index/links. Avoid duplicate policy copies.
4. If a decision is proposed but not accepted, mark it Proposed and list who decides and what evidence is missing.
5. Remove or revise superseded instructions and links; do not leave contradictory current guidance.
6. Check relative links, paths, code snippets, table formatting, spelling, and whether examples are secret-safe.
7. Run documentation lint/link checks if configured. Record any external link unavailable during validation.
8. Update the task log with the purpose, changed docs, validation, and remaining decisions.
9. Inspect `git diff --check` and the final diff before review/merge.

## Documentation inventory and publication

TODO(template): State whether docs are indexed, versioned, published, synchronized externally, or excluded by policy. Record allowlists/denylists, generated-artifact handling, permissions, publication timing, failure behavior, and how users reconcile a failed sync. Do not silently publish internal instructions or sensitive environment details.
