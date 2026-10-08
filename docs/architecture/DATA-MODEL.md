# Data Model Baseline

## Database style

TODO(template): Record selected persistence systems, consistency requirements, and the principle for relational/document/blob boundaries. Keep provider payloads from replacing known domain relationships.

## Entities and ownership

| Entity | Owner/source of truth | Stable external identity | Retention/deletion | Important constraints |
|---|---|---|---|---|
| TODO(template) | TODO(template) | TODO(template) | TODO(template) | TODO(template) |

## Modeling rules

- Use internal identifiers independently of provider identifiers.
- Define foreign keys, uniqueness, nullability, delete behavior, and archival/retention explicitly.
- Record timestamps and time-zone conventions; keep deterministic ordering and bounded/paginated reads.
- Store binary files in an approved object store; persist metadata, authorization context, and integrity information separately.
- Use flexible JSON only for genuinely variable/provider-specific information, not to avoid modeling known relationships.
- Define indexes from known query paths and validate expensive queries against expected data volume.
- Define data classification, PII handling, encryption, audit, backup, and purge rules.
- TODO(template): project-specific invariants.

## Migrations and data changes

TODO(template): State compatibility, rollout, backfill, rollback, and production migration review requirements. Distinguish a reversible schema rollback from restoration of transformed/deleted data.
