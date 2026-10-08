# Architecture

## Status and scope

- Status/date: **TODO(template)**
- Applies to: **TODO(template)**
- Related accepted ADRs: **TODO(template)**

## System context

Describe users, application boundaries, trusted/untrusted inputs, external systems, and system-of-record ownership. Add a maintained diagram when it clarifies the boundary; link its source file.

## Architecture style

**TODO(template):** State the chosen architecture and constraints. Explain the minimum reason; link the accepted ADR. Do not treat this template's examples as a default decision.

## Runtime components and data flow

| Component | Responsibility | Trust boundary / credentials | Failure and recovery |
|---|---|---|---|
| TODO(template) | TODO(template) | TODO(template) | TODO(template) |

## External systems and side effects

| Provider | Data/operation | Direction and authority | Auth boundary | Retry/idempotency | Sandbox/test plan |
|---|---|---|---|---|---|
| TODO(template) | TODO(template) | TODO(template) | TODO(template) | TODO(template) | TODO(template) |

## Cross-cutting requirements

- Authentication and authorization: TODO(template)
- Privacy, retention, and audit: TODO(template)
- Background work, retries, and idempotency: TODO(template)
- Observability and support: TODO(template)
- Performance and availability: TODO(template)
- Deployment portability: TODO(template)

## Constraints and deferred architecture

TODO(template): Record explicit constraints and avoid building speculative layers before evidence/decision.
