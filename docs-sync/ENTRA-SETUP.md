# Entra setup: app-only `Sites.Selected` for docs sync

Goal: let a project's docs sync run **unattended** with the **narrowest** SharePoint
permission — an app that can write to **one site only** — instead of a broad
delegated consent such as `Sites.FullControl.All`.

This is an **administrator runbook**. Perform it only with explicit approval that
names the tenant, the app, the permission, and the scope. Substitute the
placeholders (`<...>`) with your environment's values.

- Microsoft Graph API resource app id: `00000003-0000-0000-c000-000000000000`
- `Sites.Selected` **application** role id: `883ea226-0bf2-4a8f-9f9d-92c9162a727d`
- (for reference) `Sites.ReadWrite.All` application `9492366f-…`, `Sites.FullControl.All` application `a82116e5-…`

## Use a dedicated app (recommended)

Create a **dedicated** app registration for docs sync. Do **not** share a
production or integration app.

**Why separate:**

- **Blast radius.** A leaked docs-sync secret is then a narrow docs credential,
  not the identity of an app that also carries mail/calendar/contacts (or other)
  access.
- **Rotation coupling.** Separate apps rotate secrets and certificates
  independently; rotating the docs credential cannot break a production
  integration.
- **Audit clarity.** Sync activity is attributable to its own app.
- **Permission drift.** A dedicated app can hold **only** `Sites.Selected`, which
  keeps the least-privilege review meaningful. Adding a developer tool's needs to
  a production app invites scope creep.
- **Attestation integrity.** A site `write` grant attested for a production app's
  purpose should not be repurposed for a developer tool; keep the production
  grant's scope and evidence clean.

## Path 1 — create a dedicated app

```bash
# 1. Create the app registration
az ad app create --display-name "docs-sync" --query appId -o tsv            # -> <client-id>
az ad app show --id <client-id> --query id -o tsv                           # -> <app-object-id>

# 2. Ensure a service principal exists
az ad sp create --id <client-id>

# 3. Add the Sites.Selected application permission (only this)
az ad app permission add --id <app-object-id> \
  --api 00000003-0000-0000-c000-000000000000 \
  --api-permissions 883ea226-0bf2-4a8f-9f9d-92c9162a727d=Role

# 4. Grant admin consent (requires a tenant admin)
az ad app permission admin-consent --id <app-object-id>

# 5. Create a client secret (treat the output as a secret; store it in BWS/Key Vault)
az ad app credential reset --id <app-object-id> --append \
  --display-name "docs-sync" --years 1 --query password -o tsv
```

## Grant the app write on one site only

Performed by an admin holding full-control delegated access (Graph REST). Repeat
per additional site you deliberately approve; `Sites.Selected` grants the app
**no site** by default.

```
POST https://graph.microsoft.com/v1.0/sites/<site-id>/permissions
Content-Type: application/json

{
  "roles": ["write"],
  "grantedToIdentities": [
    { "application": { "id": "<client-id>", "displayName": "docs-sync" } }
  ]
}
```

## Path 2 — reuse an existing app (only when deliberately accepted)

Reusing an app that already holds `Sites.Selected` and a `write` grant on the
target site avoids new consent, but shares that app's identity, secret rotation,
and audit trail with whatever else uses it. Use this only if you explicitly
accept the shared blast radius; otherwise prefer Path 1.

1. Confirm the site-level grant exists:

```powershell
Connect-MgGraph -Scopes 'Sites.Read.All' -ContextScope CurrentUser
Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/sites/<site-id>/permissions"
# expect an entry: roles=["write"] with grantedTo/grantedToIdentities application id == <client-id>
```

2. Create or renew a client secret for that app (store it as a secret):

```bash
az ad app credential reset --id <app-object-id> --append \
  --display-name "docs-sync" --years 1 --query password -o tsv
```

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
- Review and reduce over-broad consent separately: e.g. a Microsoft Graph Command
  Line Tools delegated grant `Sites.FullControl.All` (and unrelated
  directory/app-management grants such as `Application.ReadWrite.All`). Removing
  consent is an Entra admin action; do not broaden or revoke without explicit
  approval naming the tenant, app, permission, and scope.

## Notes

- Client-credentials tokens use only **application** roles; an app's unrelated
  delegated scopes do not widen app-only access.
- `Sites.Selected` is the way to bound a SharePoint app to specific sites;
  tenant-wide `Sites.ReadWrite.All`/`Sites.FullControl.All` application grants are
  not acceptable here.
- If a site grant is missing, the app receives `403 accessDenied` — fix the grant
  rather than broadening permissions.