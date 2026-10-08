# Security and Privacy Baseline

Replace examples with an application-specific threat model and controls. This baseline does not replace legal/privacy review or penetration testing where required.

## Credentials and secrets

- Never commit passwords, tokens, private keys, production connection strings, secret-bearing exports, or credential screenshots.
- Keep recoverable credentials in an approved secret manager or encrypted with externally managed key material. Hash only values that never need to be recovered (for example user passwords).
- Keep secrets out of browser storage, logs, exceptions, analytics, command history, generated docs, and serialized queue payloads.
- Use separate credentials and rotation/revocation procedures per environment. Grant least privilege and test denial outside intended scope.

## Application controls

- Authenticate explicitly and authorize every protected server-side read and write; frontend visibility is not access control.
- Validate input at trust boundaries, encode output, and protect browser sessions/CSRF where relevant.
- Set safe upload type/size limits, randomized object keys, malware scanning where appropriate, and owner-scoped download authorization.
- Apply abuse/rate controls to authentication, search, exports, integrations, uploads, and other expensive operations.
- Minimize retained personal/sensitive data; document access, encryption, audit, retention, deletion, backup, and breach procedures.
- Use dependency, secret, static-analysis, and vulnerability checks; define response/remediation ownership.

## Environments and external systems

- Separate development, test, staging, and production databases, credentials, storage, queues, and external provider tenants/accounts.
- Default tests and local setup to fakes/sandboxes; prevent accidental production calls and destructive live actions.
- Document provider scopes, resource-level boundaries, token renewal/revocation, webhook verification, retry safety, and audit correlation.
- Require explicit target/scope authorization for live writes, data resets, deletions, publication, and permission changes.

## Project threat model

- Sensitive data and classification: TODO(template)
- Trust boundaries and attacker goals: TODO(template)
- High-risk endpoints/assets: TODO(template)
- Required controls and validation evidence: TODO(template)
- Incident contact and response path: TODO(template)
