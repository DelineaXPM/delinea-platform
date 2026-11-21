# ServiceNow Secret Templates

## Native Support Notice

Secret Server now includes native out-of-the-box support for ServiceNow password changing and built-in templates. These custom templates remain fully functional and can be used when:

- You need additional custom fields not available in the native templates
- You require specific field configurations for your organization
- You are using an older version of Secret Server without native ServiceNow support

## Templates Included

### ServiceNow Privileged Account Template

**File:** `ServiceNow Privileged Account Template.xml`

Used for storing credentials that authenticate to the ServiceNow API for discovery and password management operations.

| Field | Required | Description |
|-------|----------|-------------|
| Tenant-url | Yes | Base URL for the ServiceNow instance (e.g., `https://myinstance.service-now.com`) |
| Username | Yes | Username for OAuth authentication to ServiceNow API |
| Password | Yes | Password for the username (masked field) |
| client-id | Yes | ServiceNow API Application Client ID |
| Client-Secret | Yes | ServiceNow API Application Client Secret (masked field) |
| Admin-Roles | No | Role IDs used to identify admin accounts during discovery |
| Service-Account-Group-Ids | No | Group IDs used to identify service accounts during discovery |
| Local-Account-Group-Ids | No | Group IDs used to identify local accounts during discovery |

### ServiceNow User Template

**File:** `ServiceNow User Template.xml`

Used for storing discovered ServiceNow user account credentials.

| Field | Required | Description |
|-------|----------|-------------|
| host | Yes | Base URL for the ServiceNow instance |
| Username | No | The account username |
| Password | Yes | The account password (masked field) |
| Notes | No | Additional comments or information |
| Admin-Account | No | Indicates if the account is an admin |
| Service Account | No | Indicates if the account is a service account |
| Local Account | No | Indicates if the account is a local account |

## Importing Templates

1. Log in to Secret Server
2. Navigate to **Admin** > **Secret Templates**
3. Click **Import**
4. Select the XML template file
5. Click **Import**

## Related Documentation

- [Discovery Configuration](../Discovery/readme.md)
- [Remote Password Changer Configuration](../Remote%20Password%20Changer/readme.md)
- [ServiceNow Setup Instructions](../Instructions.md)
