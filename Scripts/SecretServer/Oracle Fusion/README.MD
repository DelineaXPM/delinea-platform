# Oracle Fusion Remote Password Changer

## Overview

This integration enables Remote Password Changing (RPC) and Heartbeat for Oracle Fusion Cloud user accounts. It uses JWT authentication with RS256 signing for password changes and Basic Auth for heartbeat verification.

## How It Works

1. **Heartbeat Script** (`Oracle-Fusion-Heartbeat.ps1`) - Validates the target user's current password using Basic Auth against the SCIM API.
2. **Password Changer Script** (`Oracle-Fusion-Password-Changer.ps1`) - Generates a signed JWT using your private key and X.509 certificate, then updates the target user's password via the SCIM API.

---

## Prerequisites

- PowerShell 7.0 or higher installed on the Distributed Engine
- Oracle Fusion Cloud environment with SCIM API enabled
- A registered JWT Assertion application in Oracle Fusion with:
  - A private key (PEM format)
  - A public X.509 certificate (PEM format)
  - The Issuer value from your Oracle Fusion JWT configuration
- A Fusion user account with sufficient privileges to perform password changes via SCIM
- Target users must have API access permissions for Heartbeat to function

---

## Distributed Engine Configuration

### Install PowerShell 7+

The scripts require PowerShell 7.0 or higher due to the use of `ImportFromPem()` for RSA key handling. Windows PowerShell 5.1 (the default) does not support this method.

1. Download PowerShell 7+ from the official Microsoft GitHub releases:
   ```
   https://github.com/PowerShell/PowerShell/releases
   ```

2. Install using the MSI installer (e.g., `PowerShell-7.4.1-win-x64.msi`)

3. Verify installation by opening a command prompt and running:
   ```
   pwsh -v
   ```

4. In Secret Server, ensure your Password Changer is configured to use PowerShell 7:
   - Navigate to **Admin > Remote Password Changing > Configure Password Changers**
   - Edit your Oracle Fusion Password Changer
   - Verify the PowerShell path points to `pwsh.exe` (typically `C:\Program Files\PowerShell\7\pwsh.exe`)

---

## Certificate Generation

A bash script (`generate-jwt-cert.sh`) is provided in this directory to generate the required private key and X.509 certificate for JWT authentication.

### Prerequisites

- OpenSSL installed and available in your PATH
- Bash shell (Linux, macOS, or Windows with Git Bash/WSL)

### Running the Script

```bash
chmod +x generate-jwt-cert.sh
./generate-jwt-cert.sh
```

### Generated Files

The script creates a `fusion_jwt_cert` directory containing:

| File | Description | Usage |
|------|-------------|-------|
| `private.key` | RSA private key (PEM format) | Store in Secret Server `PrivateKey` field |
| `public.pem` | X.509 certificate (PEM format) | Store in Secret Server `Certificate` field |
| `public.cer` | X.509 certificate (DER format) | Upload to Oracle Fusion |
| `jwtclient.pfx` | PKCS#12 bundle (optional) | For Windows certificate store import |

### Configuration Options

You can modify the following variables at the top of the script:

| Variable | Default | Description |
|----------|---------|-------------|
| `OUT_DIR` | `./fusion_jwt_cert` | Output directory for generated files |
| `KEY_SIZE` | `2048` | RSA key size in bits (2048 minimum recommended) |
| `DAYS_VALID` | `365` | Certificate validity period in days |
| `PFX_PASSWORD` | (empty) | Password for PFX file; leave empty to be prompted |

### Upload Certificate to Oracle Fusion

1. Log in to your Oracle Fusion Cloud environment
2. Navigate to **Setup and Maintenance > Security Console**
3. Go to **Inbound API Authentication Public Certificates**
4. Upload the `public.cer` file (DER format)
5. Note the **Issuer** value assigned to your certificate

---

## Script Configuration

### Step 1: Create the Heartbeat Script

1. Navigate to **Admin > Scripts**
2. Click **Create Script**
3. Configure as follows:
   - **Name:** `Oracle Fusion Heartbeat`
   - **Description:** `Validates Oracle Fusion user password via Basic Auth`
   - **Category:** `Heartbeat`
   - **Script:**
     ```
     Copy and paste the contents of Oracle-Fusion-Heartbeat.ps1
     ```

### Step 2: Create the Password Changer Script

1. Navigate to **Admin > Scripts**
2. Click **Create Script**
3. Configure as follows:
   - **Name:** `Oracle Fusion Password Changer`
   - **Description:** `Changes Oracle Fusion user password via SCIM API using JWT authentication`
   - **Category:** `Password Changing`
   - **Script:**
     ```
     Copy and paste the contents of Oracle-Fusion-Password-Changer.ps1
     ```

---

## Password Changer Configuration

### Create the Password Changer

1. Navigate to **Admin > Remote Password Changing > Configure Password Changers**
2. Click **Create New Password Changer**
3. Configure as follows:
   - **Base Password Changer:** `PowerShell Script`
   - **Name:** `Oracle Fusion Password Changer`

### Configure Verify Password Changed Commands (Heartbeat)

The Heartbeat script validates the target user's password using Basic Auth.

| Setting | Value |
|---------|-------|
| **PowerShell Script** | `Oracle Fusion Heartbeat` |
| **Script Arguments** | `$BASEURL $USERNAME $PASSWORD` |

### Configure Password Change Commands

The Password Change script generates a JWT and updates the target user's password via SCIM.

| Setting | Value |
|---------|-------|
| **PowerShell Script** | `Oracle Fusion Password Changer` |
| **Script Arguments** | `$PRIVATEKEY $CERTIFICATE $ISSUER $FUSIONUSER $BASEURL $USERNAME $NEWPASSWORD` |

---

## Secret Template Configuration

### Import the Secret Templates

Two secret templates are provided in this directory for import:

1. **`Oracle-Fusion-Account-Template.xml`** — Template for storing Oracle Fusion user accounts (target accounts for password rotation)
2. **`Oracle-Fusion-JWT-Credentials-Template.xml`** — Template for storing the JWT authentication credentials (private key, certificate, issuer, etc.)

#### Import Steps

1. Navigate to **Admin > Secret Templates**
2. Click **Import**
3. Copy and paste the contents of `Oracle-Fusion-JWT-Credentials-Template.xml` and click **Import**
4. Repeat for `Oracle-Fusion-Account-Template.xml`

#### Configure Password Changer Mapping

After importing the Oracle Fusion Account template, you must map it to the Oracle Fusion Password Changer:

1. Navigate to **Admin > Secret Templates**
2. Click on **Oracle Fusion Account**
3. Click **Edit**
4. Click **Configure Password Changing**
5. Click on the **Mapping** tab
6. Set **Password Type to use** to `Oracle Fusion Password Changer`
7. Map the fields appropriately to match the Password Changer arguments
8. Click **Save**

---

## Script Arguments Reference

### Heartbeat Script Arguments

| Order | Argument | Secret Field | Description |
|-------|----------|--------------|-------------|
| 1 | `$BASEURL` | BaseURL | Oracle Fusion Pod URL |
| 2 | `$USERNAME` | Username | Target user's SCIM userName |
| 3 | `$PASSWORD` | Password | Current password to verify |

### Password Change Script Arguments

| Order | Argument | Secret Field | Description |
|-------|----------|--------------|-------------|
| 1 | `$PRIVATEKEY` | PrivateKey | RSA private key in PEM format |
| 2 | `$CERTIFICATE` | Certificate | X.509 certificate in PEM format |
| 3 | `$ISSUER` | Issuer | JWT Issuer from Oracle Fusion configuration |
| 4 | `$FUSIONUSER` | FusionUser | User to impersonate for API authentication |
| 5 | `$BASEURL` | BaseURL | Oracle Fusion Pod URL |
| 6 | `$USERNAME` | Username | Target user's SCIM userName |
| 7 | `$NEWPASSWORD` | Password | New password to set |

---

## Obtaining Oracle Fusion Configuration Values

### Issuer Value

1. Log in to your Oracle Fusion Cloud environment
2. Navigate to **Setup and Maintenance > Security Console**
3. Go to **JWT Assertion** configuration
4. Copy the **Issuer** value for your registered application

### Base URL

Your Oracle Fusion base URL follows this format:
```
https://<pod-name>.fa.ocs.oraclecloud.com
```

Example: `https://ibnjjb-dev2.fa.ocs.oraclecloud.com`

### Private Key and Certificate

These are generated when you create a JWT Assertion application in Oracle Fusion:
1. Generate an RSA key pair (2048-bit minimum recommended)
2. Create an X.509 certificate from the public key
3. Upload the certificate to Oracle Fusion
4. Store the private key securely in Secret Server

---

## Logging

Both scripts write logs to the following location on the Distributed Engine:

```
C:\Program Files\Thycotic Software Ltd\Distributed Engine\Oracle Fusion RPC\
```

| Script | Log File |
|--------|----------|
| Heartbeat | `Heartbeat-YYYYMMDD.log` |
| Password Changer | `PasswordChanger-YYYYMMDD.log` |

Log entries include timestamps, log levels (INFO, WARN, ERROR), and detailed operation information for troubleshooting.

---

## Troubleshooting

| Issue | Possible Cause | Solution |
|-------|---------------|----------|
| Heartbeat returns 401 | Invalid password | Verify the password is correct |
| Heartbeat returns 403 | User lacks API permissions | Grant SCIM API access to the target user |
| JWT generation fails | Invalid PEM format | Ensure private key includes full `-----BEGIN/END-----` markers |
| Password change returns 401 | Expired or invalid JWT | Verify Issuer value matches Oracle configuration |
| User not found | Incorrect username format | Ensure username matches SCIM userName exactly (usually email format) |
| Connection timeout | Incorrect Base URL | Verify the Pod URL is correct and accessible |

---

## Security Considerations

- Store private keys only in Secret Server's secure fields
- Use a dedicated service account for the Fusion-User with minimal required privileges
- Rotate certificates according to your organization's security policy
- Enable auditing in both Secret Server and Oracle Fusion for compliance
- Target users require API access for Heartbeat; consider security implications

---

## Disclaimer

The provided scripts are for informational purposes only and are not intended to be used for any production or commercial purposes without proper testing. You are responsible for ensuring that the scripts are compatible with your system and that you have the necessary permissions to run them. The authors of the scripts are not responsible for any damages or losses that may result from the use of the scripts. The end user agrees to use the provided scripts at their own risk.