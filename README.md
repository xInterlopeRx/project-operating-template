# Project Operating Template

A copyable operating kit for starting a software project with clear product scope, architecture decisions, development setup, testing, documentation, security, and UI design guidance.

This repository is a **GitHub template repository**. Create a new repository from it, then complete [Project Kickoff](docs/PROJECT-KICKOFF.md) and use the [Phase Gates](docs/development/PHASE-GATES.md) to plan work. The kit is intentionally stack-neutral; placeholders and examples must be replaced with verified project facts.

## Start a project from this template

1. In GitHub, select **Use this template → Create a new repository**. Choose visibility deliberately and configure branch protection for the new project.
2. Replace `PROJECT_NAME`, `PRODUCT_NAME`, and other bracketed placeholders. Search the entire repository for `TODO(template)` and `REPLACE_WITH`.
3. Complete the kickoff checklist and record initial product/architecture decisions.
4. Verify actual runtime versions and dependencies from manifests/lockfiles; update development, test, and CI commands accordingly.
5. Backend-only development may proceed without a completed UI palette, font selection, stylesheet architecture, or visual system. Before starting the user-facing UI phase, complete the UI readiness gate in `docs/development/PHASE-GATES.md`.
6. At that UI gate, choose the UI stack and canonical stylesheet entry point. Adapt `examples/css/design-tokens.css`; do not copy an example palette as an approved brand system without contrast review.
7. Add local, licensed font files only when the project has selected typefaces. Record each font's source and license in `docs/ui/FONTS.md`.
8. Add a GitHub Actions workflow that runs this project's real formatter, static checks, tests, build, and any required documentation validation. The template intentionally does not claim any stack-specific CI passes.
9. Update `AGENTS.md`, `CONTRIBUTING.md`, `.github/PULL_REQUEST_TEMPLATE.md`, and docs so their rules and commands match the project.

## Included kit

- Repository-wide agent/developer rules and contribution expectations
- Product charter, release-scope, and open-decision templates
- Architecture and data-model baselines plus an ADR template
- Development, testing, documentation-maintenance, security, and deployment plans
- UI design system requirements for semantic color tokens, stylesheets, fonts, accessibility, and visual checks
- Kickoff, feature-completion, release, and pull-request checklists
- A neutral CSS token example; it is not a finished brand palette

## License

MIT. See [`LICENSE`](LICENSE).
