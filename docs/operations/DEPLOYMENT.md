# Deployment and Operations Baseline

## Supported target and release owner

- Target(s): TODO(template)
- Release owner/approval: TODO(template)
- Runtime/toolchain image: TODO(template)
- Availability/recovery targets: TODO(template)

## Required practices

- Build immutable, traceable artifacts from reviewed source; do not patch source inside running production instances.
- Externalize runtime configuration and retrieve secrets from the approved secret manager.
- Separate production from development/test provider accounts, credentials, databases, queues, and storage.
- Run schema migrations as a reviewed and observable deployment step; plan for backward compatibility and rollback.
- Back up database and object/blob data; test restoration and document RPO/RTO.
- Define health/readiness checks for application and critical dependencies, structured logs, request/job correlation IDs, metrics, and actionable alerts.
- Document queue draining/retries, scheduled tasks, certificate/domain renewal, data retention, and incident contacts.
- Keep deployment least-privileged and auditable; restrict production access and record manual interventions.

## Release checklist

- [ ] CI passes for the exact release commit.
- [ ] Dependency/security review completed; secrets scan clean.
- [ ] Migrations reviewed against expected data size and compatibility.
- [ ] Backup/restore status and recovery procedure verified.
- [ ] External integrations use production-approved scopes/targets and safe rollout flags.
- [ ] Monitoring and rollback criteria are active.
- [ ] Smoke test is bounded and non-destructive.
- [ ] Release notes, owner, support path, and known risks are recorded.

## Rollback and recovery

TODO(template): State rollback triggers, artifact rollback, database compatibility, queue/job handling, external side-effect reconciliation, and escalation path. A code rollback does not undo an external write or restore deleted data.
