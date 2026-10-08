# Development Environment

## Verified toolchain

| Tool/runtime | Supported version | Source of truth | Verification command |
|---|---|---|---|
| TODO(template) | TODO(template) | manifest/lockfile/image | TODO(template) |

Do not copy versions from this template. Confirm them from the actual project manifests, lockfiles, images, and CI configuration.

## Prerequisites

- TODO(template): operating system/container runtime
- TODO(template): runtimes, package managers, database, services
- Access requirements: TODO(template); never put credentials in this document

## First-time setup

1. Clone and copy the safe example environment file; never copy real secrets into tracked files.
2. Install dependencies from lockfiles using the documented clean-install commands.
3. Start required local dependencies using documented health checks.
4. Generate local-only keys and initialize a disposable development/test database.
5. Run migrations/fixtures according to their documented safety and idempotency guarantees.
6. Run baseline tests, formatter/static checks, and a production build before feature work.
7. Confirm local app access and external integrations are sandboxed/off by default.

## Canonical commands

| Task | Command | Notes / expected result |
|---|---|---|
| Install | TODO(template) | lockfile-frozen install |
| Start services | TODO(template) | TODO(template) |
| Stop services | TODO(template) | preserve volumes unless reset is intended |
| Unit/feature tests | TODO(template) | isolated from live systems |
| Full tests | TODO(template) | TODO(template) |
| Formatter | TODO(template) | check or format policy |
| Static analysis/type check | TODO(template) | TODO(template) |
| Build | TODO(template) | production build |
| Migration preview/status | TODO(template) | TODO(template) |

## Environment and test data

- Keep real credentials in an approved secret store or ignored local environment file.
- Commit only documented placeholder keys in `.env.example`; verify all keys and defaults against configuration.
- Separate development, test, staging, and production credentials, databases, storage, and external accounts.
- Label fixtures as synthetic; never commit production/customer exports or copied live data.
- Document fixture ownership, reset scope, preserved accounts/configuration, and confirmation gates for destructive resets.
- External write features default off in tests and should use sandbox credentials only for explicitly authorized smoke tests.

## Branch and review flow

1. Keep the default branch releasable; use a focused feature/fix/docs branch.
2. Keep each pull request coherent; do not include unrelated cleanup.
3. Update tests and canonical docs alongside behavior changes.
4. Require the project's CI checks and appropriate code/security review.
5. Merge with the project's chosen strategy after reviewing the final diff and deployment effects.
6. Release through the documented deployment and rollback process.

## Work-phase planning

Use [`PHASE-GATES.md`](PHASE-GATES.md) to separate backend foundation work from the UI readiness/release gate. Color, font, stylesheet, and visual-system decisions are required before beginning user-facing UI implementation, not before continuing backend-only development.

## Local networking and integrations

TODO(template): Document browser-reachable origins separately from server bind addresses, callback URLs, local TLS/proxies, and sandbox-only integration setup. Do not expose private host addresses or account identifiers in a public template.

## Project-specific automation

Document hooks, generated-doc publication, deployment triggers, external side effects, opt-outs, prerequisites, and failure semantics before enabling automation. A Git hook is local unless it is explicitly installed/configured in each clone; a hook is not a substitute for CI.
