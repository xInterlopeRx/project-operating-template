# Testing Strategy

Replace generic examples with the actual project's test tools and commands. CI and local commands must agree.

## Quality layers

| Layer | Proves | Typical scope |
|---|---|---|
| Unit | Deterministic domain behavior | Calculations, validation rules, mapping, state transitions |
| Component/UI | Component behavior and accessibility semantics | Controls, loading/error/empty states, keyboard interactions |
| Feature/API | Application workflows and trust boundaries | Authentication, authorization, validation, persistence, response contract |
| Integration/contract | Boundaries with real local/test dependencies | Database engine, storage, queue, provider adapters, schema compatibility |
| Browser/e2e | Critical end-to-end user journeys | Navigation, responsive behavior, file workflows, real browser errors |
| Security/privacy | Threat-specific protections | Object access, tenant/resource isolation, secrets, uploads, audit, abuse limits |
| Migration/operations | Safe change and recovery | Upgrade, backfill, rollback, backup/restore, health checks |

Use the cheapest test that gives meaningful evidence; add higher-level coverage for critical or high-risk paths. Do not treat mock-only tests as proof of production-provider permission or deployment behavior.

## Initial protected journeys

1. TODO(template): highest-value successful user journey.
2. Unauthenticated and unauthorized requests are rejected at the server boundary.
3. Invalid and out-of-scope input fails safely without partial persistence.
4. Repeated jobs/webhooks/retries do not duplicate externally visible effects.
5. Protected data cannot be read or changed by a non-owner/non-authorized actor.
6. Provider outage, throttling, timeout, and ambiguous write outcomes are observable and recoverable.
7. Key UI paths work with keyboard, narrow viewports, and supported assistive technology.

## External-service isolation

- Tests use isolated databases/storage/queues and fake credentials by default.
- Force-disable live provider writes in the test environment independently of a developer `.env` file.
- Tests that cover integration behavior explicitly enable a test-only feature gate and fake the HTTP/provider boundary.
- Never send a test message, create a live calendar event, upload/delete live files, or modify production records as a side effect of an ordinary test run.
- Sandbox smoke tests require explicit scope, a designated sandbox account, bounded data, and clear cleanup ownership.
- Protect ambiguous external write failures from blind retries. Test duplicate, timeout-after-acceptance, throttling, permission-denied, and partial-failure paths.

## Required test concerns for a behavior change

- Success path and persisted state
- Authentication, authorization, and ownership boundary
- Validation and malformed/oversized input
- Duplicate, concurrency, retry, and stale-version behavior where applicable
- External failure and safe user-visible error handling
- Data integrity/migration effects
- Audit/notification/logging effects and secret/PII redaction
- UI states, accessibility, and responsive behavior when UI changes

## Commands and results

| Check | Command | Required in CI? | Owner/exception |
|---|---|---|---|
| Formatter | TODO(template) | Yes/No | TODO(template) |
| Static analysis/typecheck | TODO(template) | Yes/No | TODO(template) |
| Focused tests | TODO(template) | Yes/No | TODO(template) |
| Full tests | TODO(template) | Yes/No | TODO(template) |
| Production build | TODO(template) | Yes/No | TODO(template) |
| Documentation checks | TODO(template) | Yes/No | TODO(template) |

## Definition of done

A change is complete when required behavior works; server-side security and database integrity are protected; tests and builds pass; external failures are safe; migrations and operational effects are reviewed; documentation is accurate; visual changes receive visual/accessibility checks; no unrelated changes or secret/generated files are included; and unrun checks/blockers are explicitly reported.
