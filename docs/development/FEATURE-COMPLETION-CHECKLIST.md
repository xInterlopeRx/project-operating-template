# Feature Completion Checklist

Copy into an issue/PR where useful. Remove inapplicable items with a reason.

## Scope and design

- [ ] User outcome and acceptance criteria are clear.
- [ ] Release scope/open decisions were checked; no silent expansion.
- [ ] Existing implementation, sibling patterns, routes/config/manifests, and tests were inspected.
- [ ] Authorization, validation, ownership, data model/migration, performance, and operational effects are identified.
- [ ] If this begins or materially redesigns user-facing UI, the UI readiness gate is passed or explicitly waived; backend-only work is not blocked by it.
- [ ] UI behavior and states follow the documented design system.

## Implementation and verification

- [ ] Smallest complete vertical slice implemented; provider details remain behind appropriate boundary.
- [ ] Success, denied/invalid, failure/retry, and edge paths are tested at the right layers.
- [ ] External systems are faked or sandboxed; no accidental live side effect occurred.
- [ ] Focused tests pass; broader suite/build/static checks run as risk requires.
- [ ] Changed code is formatted; migration and external contracts reviewed.
- [ ] UI changes checked for keyboard/accessibility, responsive overflow, visual states, and browser errors.

## Documentation and handoff

- [ ] Canonical product/architecture/security/development docs updated if they became incomplete.
- [ ] ADR added/amended for material architecture choice; unresolved item has owner/next action.
- [ ] Task log updated with outcome, actual validation, side effects, and blockers.
- [ ] `git diff --check` passes and final diff contains no secrets, generated files, or unrelated changes.
- [ ] Completion report lists paths, commands/results, unrun checks, and limitations.
