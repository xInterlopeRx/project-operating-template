# Project Kickoff Checklist

Complete the core product and backend foundation work before substantial implementation. The UI readiness subsection below is required only before user-facing UI work; it does not block backend-only development. Mark intentional omissions with a reason; do not fill unknowns with guesses.

## Identity and ownership

- [ ] Set product/repository name, one-sentence purpose, owner, maintainers, support channel, and license.
- [ ] Identify primary users, operating environment, accessibility needs, and critical user journeys.
- [ ] Set repository visibility, default branch, branch protection, CODEOWNERS (if applicable), and GitHub Actions permissions.
- [ ] Choose a data classification and identify legal/privacy obligations relevant to the product.

## Product scope

- [ ] Complete `docs/product/PRODUCT.md` with user problems, outcomes, principles, and success measures.
- [ ] Complete `docs/product/RELEASE-PLAN.md` with included work, explicit exclusions, acceptance criteria, and release success.
- [ ] List open decisions with a named owner and next action.
- [ ] Identify out-of-scope work to prevent accidental scope growth.

## Architecture and data

- [ ] Record system context, runtime components, trust boundaries, external dependencies, and failure modes.
- [ ] Identify the authoritative source for each important data set and external side effect.
- [ ] Model entities, stable IDs, ownership, deletion/retention, constraints, indexes, and expected query bounds.
- [ ] Choose an initial architecture that meets measured needs; record consequential choices as ADRs.
- [ ] Decide supported environments, deployment target, backup/restore requirements, and recovery objectives.

## Toolchain and development

- [ ] Select versions and verify support against manifests/lockfiles and official sources.
- [ ] Add reproducible environment setup, safe `.env.example`, canonical start/stop/test/build/format commands, and seed/fixture policy.
- [ ] Decide supported developer OS/container setup; document browser origin vs bind address when relevant.
- [ ] Define branch, pull request, review, merge, release, and rollback conventions.
- [ ] Add CI that actually runs project checks; make required status checks explicit.

## Testing and operations

- [ ] Define unit, integration, feature/API, UI/browser, accessibility, migration, and security test layers appropriate to the product.
- [ ] Force tests away from production credentials, databases, queues, storage, and external APIs.
- [ ] Add fakes/mocks/contract fixtures for provider boundaries and document how sandbox smoke tests are authorized.
- [ ] Define logs, correlation IDs, metrics, alerting, health checks, incident ownership, backups, and restore tests.
- [ ] Establish dependency, secret, static-analysis, and security scanning policy.

## UI readiness gate (required before starting user-facing UI, not backend-only work)

- [ ] Backend contracts and protected journeys are stable enough to inform UI work; confirm in `docs/development/PHASE-GATES.md`.
- [ ] Select the UI technology and identify its canonical stylesheet entry point.
- [ ] Approve a semantic color scheme with foreground/background/state contrast checks.
- [ ] Select fonts and record license/provenance before adding font assets; font binaries are not required until selected.
- [ ] Define typography, spacing, surfaces, borders, focus, controls, status, responsive behavior, reduced motion, and empty/error/loading states.
- [ ] Verify keyboard-only, screen-reader semantics, zoom/reflow, touch targets, and representative desktop/mobile screens.
- [ ] Define how visual regression or documented manual visual checks will be performed.
- [ ] Record gate completion in the task/phase plan. Do not retroactively block backend-only work on this gate.

## Ready to implement

- [ ] Replace all `TODO(template)` and `REPLACE_WITH` placeholders.
- [ ] Confirm docs describe decisions rather than guesses and link to one canonical source per rule.
- [ ] Confirm a clean clone can install dependencies, initialize test services, run tests, build, and follow CI instructions.
- [ ] Review repository contents for secrets, personal data, unrelated examples, and incorrect licensing before making it public.
