# Entra setup: app-only `Sites.Selected` for docs sync

Goal: let a project's docs sync run **unattended** with the **narrowest** Share
Point permission — an app that can write to **one site only** — instead of a
broad delegated consent such as `Sites.FullControl.All`.

This is an **administrator runbook**. Perform it only with explicit approval that
names the tenant, the app, the permission, and the scope. Substitute the
placeholders (`<...>`) with your environment's values.

- Microsoft Graph API resource app id: `00000003-0000-0000-c000-000000000000`
- `Sites.Selected` **application** role id: `883ea226-0bf2-4a8f-9f9d-92c9162a727d`
- (for reference) `Sites.ReadWrite.All` application `9492366f-…`, `Sites.FullControl.All` application `a82116e5-…`

## Path A — reuse an app that already qualifies (fastest; no new consent)

If an app already holds `Sites.Selected` and a **write** grant on the target site,
you only need a client secret and the tenant/client ids.

1. Confirm the site-level grant exists:

```powershell
Connect-MgGraph -Scopes 'Sites.Read.All' -ContextScope CurrentUser
Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/sites/<site-id>/permissions"
# expect an entry: roles=["write"] with grantedTo/grantedToIdentities application id == <client-id>
```

2. Confirm the app registration carries `Sites.Selected` (Role) and note its
   object id, then create/renew a client secret (store it as a secret — do not
   paste it into chat, config, or shell history):

```bash
az ad app credential reset --id <app-object-id> --append \
  --display-name "docs-sync" --years 1 --query password -o tsv   # treat output as a secret
```

## Path B — create a dedicated app (cleanest isolation)

```bash
# 1. Create the app registration
az ad app create --display-name "Project Docs Sync" --query appId -o tsv     # -> <client-id>
az ad app show --id <client-id> --query id -o tsv                            # -> <app-object-id>

# 2. Ensure a service principal exists
az ad sp create --id <client-id>

# 3. Add the Sites.Selected application permission
az ad app permission add --id <app-object-id> \
  --api 00000003-0000-0000-c000-000000000000 \
  --api-permissions 883ea226-0bf2-4a8f-9f9d-92c9162a727d=Role

# 4. Grant admin consent (requires a tenant admin)
az ad app permission admin-consent --id <app-object-id>

# 5. Create a client secret (treat the output as a secret)
az ad app credential reset --id <app-object-id> --append \
  --display-name "docs-sync" --years 1 --query password -o tsv
```

## Grant the app write on one site only

Performed by an admin holding full-control delegated access (Graph REST):

```
POST https://graph.microsoft.com/v1.0/sites/<site-id>/permissions
Content-Type: application/json

{
  "roles": ["write"],
  "grantedToIdentities": [
    { "application": { "id": "<client-id>", "displayName": "<app display name>" } }
  ]
}
```

`Sites.Selected` grants the app **no site** by default; this call is what opens
exactly one site (and, if you grant a folder later, exactly one folder). Repeat
per additional project site you deliberately approve.

## Store the secret and run the sync

1. Store the client secret in the secret manager (BWS project or Key Vault). Do
   not commit it.
2. Export it at run time and sync:

```powershell
$env:SHAREPOINT_SYNC_CLIENT_SECRET = <secret>
pwsh -File docs-sync/scripts/sync-docs.ps1 -SourceRoot . -DryRun -TenantId <tenant-id> -ClientId <client-id>
pwsh -File docs-sync/scripts/sync-docs.ps1 -SourceRoot . -TenantId <tenant-id> -ClientId <client-id>
```

3. The script reports `Auth : app-only (Sites.Selected)` and needs no user
   sign-in.

## Verify and (optionally) reduce broad grants

- Confirm the sync writes only under `<rootFolder>/<projectSlug>/` and nothing
  outside the granted site.
- Review and reduce over-broad consent separately: e.g. the Microsoft Graph
  Command Line Tools delegated grant `Sites.FullControl.All` (and unrelated
  directory/app-management grants such as `Application.ReadWrite.All`). Removing
  consent is an Entra admin action; do not broaden or revoke without explicit
  approval naming the tenant, app, permission, and scope.

## Notes

- Client-credentials tokens use only **application** roles; an app's unrelated
  delegated scopes do not widen app-only access.
- `Sites.Selected` is the only delegated-safe way to bound a SharePoint app to
  specific sites; tenant-wide `Sites.ReadWrite.All`/`Sites.FullControl.All`
  application grants are not acceptable here.
- If a site grant is missing, the app receives `403 accessDenied` — fix the grant
  rather than broadening permissions.