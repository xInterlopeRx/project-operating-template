# SharePoint Docs Sync

Sync a repository's eligible Markdown — and, when a project opts in, its data
documents — to a per-project folder in SharePoint via Microsoft Graph. One
folder per project at a shared target, so many projects publish docs without
colliding.

## Layout

```
docs-sync/
  scripts/sync-docs.ps1          # portable sync
  sharepoint-sync.example.json   # per-project config template
  ENTRA-SETUP.md                 # admin runbook: app-only Sites.Selected setup
```

See [`ENTRA-SETUP.md`](./ENTRA-SETUP.md) for the administrator runbook that grants
a **dedicated** app write to **one site only** (the preferred, least-privilege
auth).

Each project keeps its own committed config at `.opencode/sharepoint-sync.json`
and writes to `<rootFolder>/<projectSlug>/<repo-relative-path>` in the configured
drive. Result:

```
<library>/Documents/
  Projects/
    fieldops/
      TASKLOG.md
      docs/operations/DEPLOYMENT.md
    another-project/
      README.md
```

## Auth and least privilege

Request the **narrowest** scope that works; never accept a broader one just to
make a sync succeed. `Sites.FullControl.All` is over-broad for writing
documentation and must not be relied on or requested.

**App-only `Sites.Selected` (preferred — durable, unattended, narrow).** Use a
**dedicated** app registration (do not share a production/integration app — see
the runbook), with the client credentials the script accepts:

```powershell
$env:SHAREPOINT_SYNC_CLIENT_SECRET = <secret>   # from BWS/Key Vault, never committed
pwsh -File scripts/sync-docs.ps1 -SourceRoot . -DryRun -TenantId <tenant> -ClientId <app>
pwsh -File scripts/sync-docs.ps1 -SourceRoot . -TenantId <tenant> -ClientId <app>
```

If the secret lives in **Bitwarden Secrets Manager** under the matching name
`SHAREPOINT_SYNC_CLIENT_SECRET`, let the CLI inject it so the value never touches
disk or shell history (the secret name matches the variable the script reads):

```bash
BWS_ACCESS_TOKEN=<machine-account-token> bws run -- \
  pwsh -File scripts/sync-docs.ps1 -SourceRoot . -TenantId <tenant> -ClientId <app>
```

Setup (admin actions; see [`ENTRA-SETUP.md`](./ENTRA-SETUP.md); do not perform
without explicit approval naming the tenant, app, permission, and scope):

1. Create a dedicated Entra app registration with the **`Sites.Selected`**
   application permission and grant admin consent.
2. Grant that app write on the target site only:
   `POST https://graph.microsoft.com/v1.0/sites/{siteId}/permissions` with
   `{ "roles": ["write"], "grantedToIdentities": [ { "application": { "id": "<clientId>", "displayName": "<name>" } } ] }`
   — this endpoint needs a caller with `Sites.FullControl.All`. The Microsoft
   Graph Command Line Tools tenant-wide grant had that scope revoked on
   2026-10-23, so perform the grant from a temporary admin consent (revoke it
   afterwards) or a dedicated grant app; see the runbook.
3. Store the client secret in a secret manager and export it as
   `SHAREPOINT_SYNC_CLIENT_SECRET` at run time. With Bitwarden Secrets Manager,
   store it under the same name and run `bws run -- pwsh -File … <sync args>` so
   the value is injected without touching disk or shell history.

**Delegated (interactive fallback)** — request only `Sites.ReadWrite.All`, bounded
by the signed-in user's own SharePoint membership:

```powershell
Connect-MgGraph -Scopes 'Sites.ReadWrite.All' -ContextScope CurrentUser
```

Do **not** use the Azure CLI (`az account get-access-token`) as the token source:
its consented delegated scopes are directory/app-management heavy
(`Application.ReadWrite.All`, `AppRoleAssignment.ReadWrite.All`,
`Directory.AccessAsUser.All`, `User.ReadWrite.All`, …) and it does not model the
Sites grant at all.

An existing Graph PowerShell consent may return broader scopes than requested
(incremental consent). If a session reports `Sites.FullControl.All` or other wide
grants, treat that as the environment's pre-existing consent: prefer the app-only
`Sites.Selected` path, and have an administrator review and reduce the broad
consent separately. Never remove or broaden tenant permissions without explicit
approval. The script warns when it detects over-broad scopes.

## Usage

```powershell
# enumerate + compare, no writes
pwsh -File scripts/sync-docs.ps1 -SourceRoot . -DryRun

# apply (writes to SharePoint)
pwsh -File scripts/sync-docs.ps1 -SourceRoot .
```

`-SourceRoot` defaults to the current git root; `-ConfigPath` defaults to
`<SourceRoot>/.opencode/sharepoint-sync.json`. `-Force` re-uploads unchanged
files.

## Config

```json
{
  "projectSlug": "my-project",
  "rootFolder": "Projects",
  "siteId": "<sharepoint-site-id>",
  "driveId": "<sharepoint-drive-id>",
  "include": ["**/*.md"],
  "excludeDirectories": [".git", "node_modules", "vendor", "reference"],
  "excludeFiles": ["AGENTS.md", "CLAUDE.md"]
}
```

`include` takes globs (`**` spans directories; `*` and `?` match inside a path
segment) and defaults to Markdown only. To publish non-Markdown project files —
for example generated data documents under `reference/` — add their patterns
**and** remove `reference` from `excludeDirectories`:

```json
"include": ["**/*.md", "reference/**/*.xlsx", "reference/**/*.csv", "reference/**/*.pdf"],
"excludeDirectories": [".git", ".idea", ".vscode", ".agents", ".claude", "node_modules", "vendor", "storage", "coverage", "dist", "build", "target", ".phpunit.cache", ".venv", "__pycache__"],
```

Uploaded files use a MIME type derived from their extension.

The project folder is created on first sync. The config holds only non-secret
identifiers; never commit tokens, client secrets, or key material.

## Rules

- Dry-run first; apply only with explicit authorization for the remote writes.
- Keep one folder per project; never write into another project's folder.
- Do not broaden permissions to make a sync succeed.
- Eligibility excludes VCS/dependency/build directories and agent-only docs
  (`AGENTS.md`, `CLAUDE.md`, `.agents/**`, `.claude/**`). `reference/` is excluded
  by default; opt into it deliberately (see the config above) before publishing
  data documents.
- Never upload secrets or editor artefacts. Regardless of `include`, the script
  refuses dotfiles and `.env*`, `*.swp`, `*.swo`, `*.pem`, `*.key`, `*.pfx`,
  `*.p12`, and `*:Zone.Identifier`.
- Files are skipped when remote size and modified time already match local
  (SharePoint exposes `quickXorHash`; this portable script compares size/mtime
  instead and uses `-Force` to override).

## Notes

Projects on Laravel may already have an app-only, exact-hash sync command; this
portable script is the stack-neutral path and the source of truth for the
workflow.