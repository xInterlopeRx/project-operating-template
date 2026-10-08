# Contributing

## Before opening a change

- Read `AGENTS.md`, `README.md`, the relevant product/architecture docs, and `docs/development/DEVELOPMENT.md` plus `TESTING.md`.
- Check the current branch and worktree. Use a focused branch and preserve unrelated changes.
- For behavior changes, identify scope, security, data, UI, operational, documentation, and test impacts before editing.

## Change expectations

- Keep pull requests focused; do not combine unrelated refactors or broad formatting.
- Add/update tests and docs for behavior changes. Add an ADR when a significant architecture choice changes.
- Never commit credentials, `.env` files, customer data, generated output, or local state.
- Do not run destructive data operations or actions against live external services without explicit scope and target authorization.
- Complete `.github/PULL_REQUEST_TEMPLATE.md` and report checks honestly.

## Local validation

Replace these placeholders with the exact commands verified for this project's locked toolchain:

```text
TODO(template): formatter
TODO(template): static analysis / type check
TODO(template): focused test command
TODO(template): full test command
TODO(template): production build
TODO(template): documentation checks
```

The merge gate is the project's protected-branch CI, not a developer's unrecorded local setup. Document any required manual/environment-specific checks in the pull request.
