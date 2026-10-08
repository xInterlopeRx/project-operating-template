# UI Design System and Frontend Quality Bar

This document is a **phase gate for user-facing UI work**, not a prerequisite for backend-only development. Complete the required sections before beginning UI implementation or a major UI redesign; unrelated backend work may continue while the gate is open. It prevents color, type, and component decisions from fragmenting across pages. Replace every placeholder with project-approved values and link to the canonical stylesheet/design-token files.

## Design ownership and source files

- UI/product owner: **TODO(template)**
- Design reference/source: **TODO(template)**
- UI framework and verified version: **TODO(template)**
- Canonical stylesheet entry point: **TODO(template)**
- Canonical token file(s): **TODO(template)**
- Component/storybook/design-preview location: **TODO(template)** or Not used (reason)
- Supported viewport/browser range: **TODO(template)**
- Theme modes supported: **TODO(template)** (light is required; document dark/high-contrast modes if supported)

Once the UI gate is met, no component should invent a competing palette or typography system. Build pages from semantic tokens and documented primitives; raw one-off values require an explicit exception and should not silently create new design language.

## Stylesheet requirements

1. Select and document exactly one canonical stylesheet entry point for global reset/base rules, tokens, font-face definitions, and shared components. Page/component styles may exist, but follow the documented ownership and layering model.
2. Keep semantic design tokens centralized (for example, `--color-text-primary`, `--color-surface`, `--color-border`, `--color-action`, `--color-danger`, `--focus-ring`). Do not use brand names as the only semantic meaning of a token.
3. Reference tokens from components rather than repeating raw color codes. A CSS grep/lint or visual review should detect avoidable literal colors and fonts outside the token and typography files.
4. Define responsive behavior, layering/z-index rules, motion policy, and any CSS architecture/conventions that match the selected framework.
5. Ensure styles compile in the production build; avoid stylesheet imports from undocumented remote origins.
6. Test global changes for unintended regressions across authenticated, form, table/list, dialog, empty/error, and print/export surfaces where present.

The [`examples/css/design-tokens.css`](../../examples/css/design-tokens.css) file is only an illustrative neutral starting palette. Replace it with an approved product palette and measured contrast results; it is not a final design system.

## Color scheme requirements

Record the approved palette, color profiles, and role mapping in this table. Do not fill it by sampling a logo or copying an existing application's values without approval.

| Semantic role | Light value | Dark/high-contrast value if supported | Foreground/background pair | Verified contrast |
|---|---|---|---|---|
| Primary text | TODO(template) | TODO(template) | TODO(template) | TODO(template) |
| Secondary text | TODO(template) | TODO(template) | TODO(template) | TODO(template) |
| Page background | TODO(template) | TODO(template) | TODO(template) | N/A |
| Raised surface | TODO(template) | TODO(template) | TODO(template) | TODO(template) |
| Border/divider | TODO(template) | TODO(template) | TODO(template) | TODO(template) |
| Primary action | TODO(template) | TODO(template) | TODO(template) | TODO(template) |
| Focus indicator | TODO(template) | TODO(template) | TODO(template) | TODO(template) |
| Success / warning / error / info | TODO(template) | TODO(template) | TODO(template) | TODO(template) |

Required color rules:

- Meet WCAG 2.2 AA contrast for text: at least **4.5:1** for normal text and **3:1** for large text. Meaningful graphical objects, control boundaries, and focus indicators require at least **3:1** against adjacent colors where WCAG applies.
- Verify actual foreground/background combinations for default, hover, focus, active, selected, disabled, error, and status states—not just isolated swatches. Disabled-state exceptions do not justify poor contrast in other states.
- Never communicate status, validation, selection, or permission by color alone. Include text, shape, icon, or accessible name as appropriate.
- Keep focus rings visible on every surface and when adjacent to component borders.
- If dark mode is supported, define/verify a separate semantic mapping; do not mechanically invert colors. Test user preference and contrast in both themes.
- Record the tool/method and date used for contrast review; manually inspect dynamic/composited colors and focus rings.

## Typography and font asset requirements

| Role | Family | Weights/styles | Fallback stack | Source/license record |
|---|---|---|---|---|
| UI/body | TODO(template) | TODO(template) | TODO(template) | TODO(template) |
| Display/heading | TODO(template) or same as UI | TODO(template) | TODO(template) | TODO(template) |
| Code/data | TODO(template) | TODO(template) | TODO(template) | TODO(template) |

- Choose readable fonts for the language, scripts, small screens, and expected viewing distance. Define type sizes, line heights, weights, and tabular-number behavior for dense data.
- Prefer WOFF2 for web delivery where the license permits. Include only used families, weights, and styles; remove unused large files.
- Before adding any font binary, verify redistribution/web-embedding rights and store its license text or license reference with the asset. Maintain source URL, version/date, family, weights, formats, checksum if useful, and license in `docs/ui/FONTS.md` or `public/fonts/README.md`.
- Include a system fallback stack and `font-display: swap` or a documented reason for another loading behavior. Avoid layout shifts with suitable metric overrides where available.
- Do not fetch production fonts from a third-party CDN by default. A remote font service requires explicit privacy, availability, CSP, and licensing review.
- Do not include font files copied from another project's repository or machine unless rights and provenance are established.

## Interaction, accessibility, and responsive requirements

- Use semantic HTML and native controls where possible. Every control has an accessible name, correct role/state, and logical reading/focus order.
- All actions are keyboard operable, focus is visible and not obscured, dialogs manage focus and dismissal correctly, and no keyboard trap is introduced.
- Form fields have labels, instructions, required/invalid state, and errors connected programmatically; preserve entered data after recoverable errors.
- Target WCAG 2.2 AA for supported user journeys. Include automated accessibility checks plus manual keyboard and screen-reader sampling; tools alone are not proof of conformance.
- Provide touch targets and spacing appropriate to the supported mobile environments. Avoid hover-only actions.
- Define reflow behavior at 320 CSS px and browser zoom; prevent unnecessary two-dimensional scrolling, clipped controls, and hidden critical actions.
- Honor `prefers-reduced-motion`; animation must not be required to understand state and should not delay core interactions.
- Include loading, empty, success, partial failure, error, offline, and permission-denied states as relevant. Communicate status with more than color.
- Treat performance as part of design: bound lists, defer noncritical media, use appropriately sized images, and avoid blocking interactions on external calls.

## UI verification record

For UI changes, record in the PR/task log:

- Tested viewport(s), browser, and theme.
- Keyboard-only checks and accessibility tooling/manual checks performed.
- Screenshot/story visual check and pages/states covered.
- Console/network errors and overflow findings.
- Any unsupported state/browser or known limitation.

Do not claim visual verification when only a compile/build succeeded.
