# Disclaimer

The provided scripts are for informational purposes only and are not intended to be used for any production or commercial purposes. You are responsible for ensuring that the scripts are compatible with your system and that you have the necessary permissions to run them. The provided scripts are not guaranteed to be error-free or to function as intended. The end user is responsible for testing the scripts thoroughly before using them in any environment. The authors of the scripts are not responsible for any damages or losses that may result from the use of the scripts. The end user agrees to use the provided scripts at their own risk. Please note that the provided scripts may be subject to change without notice.

# Introduction

This documents provides the details for configuring a dependency changer for your SQL Server Logins utilized by **Solarwinds DPA** for monitoring.

## DPA Requirements

API access for DPA is managed by the Solarwinds Administrator through the DPA interface, under the management section.

You can find the full steps for creating the required refresh token needed for this dependency changer [here](https://documentation.solarwinds.com/en/success_center/dpa/Content/DPA-create-manage-refresh-tokens.htm#Create).

> **Note**: The script used for this dependency changer depends on the token, so when as it expires you will have to update the script.

## Secret Server Template

This changer is only required for SQL Logins that are utilized by DPA to monitor a given SQL Server instance. The template in Secret Server recommended is the **SQL Server Account** template. This template handles the RPC and Heartbeat functionality automatically for you, out of the box.

## Create Script

1. Navigate to **Admin | Scripts**
2. Enter name: **Solarwinds DPA - Update Password**
3. Description: **Script for rotating SQL Login for DPA monitoring connection**
4. Category: **Dependency**
5. Script: **Copy and Paste** the provided script [solarwindsdpa-dependency.ps1](solarwindsdpa-dependency.ps1)
6. Click **OK**

> **Note**: Ensure you update the `$baseUrl` and `$refreshToken` values in the script with the required data

## Create Dependency

1. Navigate to your desired secret
2. Navigate to **Dependencies** tab
3. Create a **New Dependency** (_create a dependency group if one does not currently exists_)
4. Click the drop down for **Type**
5. Select the **Solarwinds DPA - Update Password** under the **Run PowerShell Script** section
6. Provide a **Dependency Name**
7. Select a **Run As** secret if required according to your Secret Server configuration
8. Enter **5** for **Wait(s)**
9. Arguments enter `$SERVER $PASSWORD`
10. Click **Save**

> **Note**: The `$SERVER` is the field specific to the SQL Server Account template that holds the name of your SQL Server instance of the given SQL Login. If you are using a different template adjust this field variable accordingly.

You should now be able to rotate the password of the SQL Login secret and after 5 seconds the dependency changer will update the DPA monitor connection for that same server.
