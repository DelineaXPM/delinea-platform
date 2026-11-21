# Oracle Database local account discovery

`OracleDB_LocalAccount_Discovery.ps1` is an extensible discovery scanner script for Secret Server. It
connects to an Oracle database from the Distributed Engine, reads `DBA_USERS` and returns the open
accounts that Oracle does not maintain, so they can be imported as secrets and rotated.

Extensible discovery is not covered by Delinea Support. Test on a lab tenant first.

## Prerequisites

- A site with a Distributed Engine that can reach the database listener (TCP 1521 by default).
- `Oracle.ManagedDataAccess.dll` in the engine folder
  (`C:\Program Files\Thycotic Software Ltd\Distributed Engine`). Current engines ship it.
- A discovery account in the database with `CREATE SESSION` and `SELECT_CATALOG_ROLE` (or `SELECT`
  on `DBA_USERS`), stored as a secret.
- A privileged account (for example `SYSTEM`) stored as a secret, if imported accounts should be
  taken over and rotated.

## Configuration

### 1. Script

Settings > Scripts > Create script.

| Setting | Value |
|---|---|
| Name | Oracle DB Local Account Discovery |
| Script type | PowerShell |
| Category | Discovery scanner |
| Script | contents of `OracleDB_LocalAccount_Discovery.ps1` |

### 2. Scan template

Discovery > Configuration > Extensible discovery > Configure scan templates > Create scan template.

| Setting | Value |
|---|---|
| Name | Oracle Database Account |
| Scan type | Account |
| Parent scan template | Account (Basic) |

| Field | Parent | Include in match |
|---|---|---|
| Resource | Resource | Yes |
| Username | Username | Yes |
| Password | Password | No |
| Database | (none) | Yes |
| Port | (none) | No |

Database and Port are optional. With them, an import fills in the secret's Database and Port fields,
and the same user name on two databases on one host is recorded as two accounts. A scan template
cannot be edited once a scanner has used it, so add them before the first scan.

### 3. Scanner

Configure discovery scanners > Create scanner.

| Setting | Value |
|---|---|
| Name | Oracle Local Accounts |
| Scanner type | Accounts |
| Base scanner | PowerShell Discovery |
| Input template | Computer (or Windows Computer for databases on Windows hosts found by AD discovery) |
| Output template | Oracle Database Account |
| Script | Oracle DB Local Account Discovery |
| Script arguments | `$target $[1]$Username $[1]$Password 1521 ORCLPDB1` |

`$[1]` is the first credential on the discovery source. Replace `1521` and `ORCLPDB1` with the
listener port and service name. Leave out the service name to connect with `SID=ORCL`.

### 4. Discovery source

Create an empty discovery source on the engine's site and add scanners so the flow reaches a
Computer item: for example Manual Host Range > Manual Machine List (listing the database hosts) >
Oracle Local Accounts. On the Oracle scanner:

- Add the discovery account secret as credential 1.
- Set **Use site run as secret** to Yes, so PowerShell runs as the site's run-as account and the
  Oracle credential is used only for the database login.

### 5. Import mapping

So that discovered accounts can be imported as Oracle Account (Template Ver 2) secrets, map that
password changer to the new scan template (Configure Password Changers > Oracle Account (Template
Ver 2) > Configure Scan Template). Map host to Resource, username to Username, password to Password,
database to Database and port to Port. The same change can be made with the REST API:

```
PATCH /api/v1/remote-password-changing/scan-templates-fields/{passwordTypeId}
{ "scanTemplateId": <scan template id>,
  "fields": [ { "passwordTypeFieldId": <host field id>, "scanItemFieldId": <Resource field id> }, ... ] }
```

`GET /api/v1/secret-templates/{secretTemplateId}/password-type` lists the password changer's field ids.

This replaces the default mapping (SQL Local Account) for that password changer on the tenant.

Import from Discovery > Network view (filter by scan template Oracle Database Account), choose
**Generate a random password for each account**, and pick the privileged secret for the take-over
and for future password changes.

## Troubleshooting

| Error | Cause |
|---|---|
| `You cannot call a method on a null-valued expression` or `The type initializer for 'OracleInternal.Common.ProviderConfig' threw an exception` | ODP.NET 23 could not load its dependencies. Use this version of the script, which resolves them from the engine folder. |
| `ORA-12514` or `ORA-12505` | Wrong service name or SID. Pluggable databases need the service name argument. |
| `ORA-01017` | Wrong discovery credential. |
| `ORA-28000` | The discovery account is locked. |
| Scan finds 0 accounts | Check the discovery account can read `DBA_USERS` (`SELECT_CATALOG_ROLE`). |

Results and errors appear under Discovery > Computer scan log.

## Tested with

Secret Server Cloud 11.10, Distributed Engine with Oracle.ManagedDataAccess 4.122.23.1, Windows
PowerShell 5.1, Oracle Database 23ai Free (pluggable database FREEPDB1).
