# SharePoint Docs Sync

Sync a repository's eligible Markdown to a per-project folder in SharePoint via
Microsoft Graph (delegated). One folder per project at a shared target, so many
projects publish docs without colliding.

## Layout

```
docs-sync/
  scripts/sync-docs.ps1          # portable sync (delegated Graph)
  sharepoint-sync.example.json   # per-project config template
```

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

## Auth (delegated)

```powershell
Connect-MgGraph -Scopes 'Sites.ReadWrite.All' -UseDeviceCode -ContextScope CurrentUser
```

`-ContextScope CurrentUser` persists the session so later processes reuse it
silently. Writes are performed as the signed-in user, so that user must be able
to write to the target library.

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

The project folder is created on first sync. The config holds only non-secret
identifiers; never commit tokens, client secrets, or key material.

## Rules

- Dry-run first; apply only with explicit authorization for the remote writes.
- Keep one folder per project; never write into another project's folder.
- Do not broaden permissions to make a sync succeed.
- Eligibility excludes VCS/dependency/build directories, `reference/`, and
  agent-only docs (`AGENTS.md`, `CLAUDE.md`, `.agents/**`, `.claude/**`).
- Files are skipped when remote size and modified time already match local
  (SharePoint exposes `quickXorHash`; this portable script compares size/mtime
  instead and uses `-Force` to override).

## Notes

Projects on Laravel may already have an app-only, exact-hash sync command; this
portable script is the stack-neutral path and the source of truth for the
workflow.
