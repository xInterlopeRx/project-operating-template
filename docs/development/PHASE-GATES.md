# Project Phase Gates

Use these gates to keep work moving without treating later-phase deliverables as prerequisites for unrelated backend development. Tailor acceptance criteria to the product and record the owner/status in the project plan.

## Gate A — Backend foundation to first user-facing UI

**Purpose:** establish enough product, API/data, security, and test contracts to design a UI against stable behavior. The UI design-system checklist below is required to pass this gate; it is **not required to continue backend-only development**.

### Backend foundation ready

- [ ] Primary user journeys and release scope are written down, including what is intentionally not included.
- [ ] Core backend/API contracts and data ownership/source-of-truth rules are documented well enough to inform screens and error states.
- [ ] Authentication, authorization, validation, and privacy boundaries for the UI-facing operations are defined.
- [ ] The development/test environment and backend verification commands are reproducible.
- [ ] Tests cover the highest-risk protected workflows; provider calls and live writes are isolated in ordinary tests.
- [ ] Known unresolved product/API decisions affecting the first screens have owners and a decision path.

### UI readiness items — required before UI implementation begins

- [ ] UI framework/runtime and supported browsers/devices are selected and version-verified.
- [ ] A canonical stylesheet entry point and token ownership model are recorded.
- [ ] Semantic color roles are selected; representative text, surface, action, focus, border, and status pairs have measured contrast evidence.
- [ ] Font families/weights are selected or system fonts are intentionally chosen. No binary is added until source, license, and redistribution/embedding rights are recorded.
- [ ] Typography, spacing, interaction states, focus behavior, responsive/reflow, reduced motion, and loading/empty/error/permission states are specified to the level needed for the first workflows.
- [ ] Keyboard and screen-reader semantics and a manual/automated accessibility verification plan are agreed.
- [ ] Visual review method (browser, viewports, themes, screenshots or regression tests) is agreed.
- [ ] `docs/ui/DESIGN-SYSTEM.md` is updated with the actual decisions, not placeholders, and the relevant owners approve the gate.

- **Gate result:** `Not started | In progress | Passed | Waived with owner/reason`
- **Owner/date:** TODO(template)
- **Evidence/links:** TODO(template)

## Gate B — UI feature ready for release

- [ ] The specific user journey has success, empty, loading, error, and access-denied behavior as applicable.
- [ ] Responsive behavior, keyboard operation, visible focus, labels, contrast, and status-not-by-color-only are checked.
- [ ] Changed screens are visually inspected at agreed desktop/mobile sizes and supported theme(s).
- [ ] Browser console/network errors, overflow, and font loading are checked.
- [ ] UI tests, server/API tests, build, and documentation updates pass the defined project checks.
- [ ] Known accessibility/browser limitations and release risks are recorded with owner/remediation.

## Exceptions

A gate can be waived only by the named product/engineering owner. Record scope, rationale, expiry/revisit condition, and risk. Do not use a waiver to claim compliance or to block unrelated backend work.
