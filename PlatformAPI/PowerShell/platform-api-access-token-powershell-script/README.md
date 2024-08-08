
# Delinea Platform API Access Token Powershell Script

This repository contains a PowerShell script designed to manage OAuth tokens and test API connectivity for the Delinea Platform.

This is a simplified example and might need to be adapted to fit your specific requirements

## Overview

The script performs the following tasks:
1. Obtains initial OAuth tokens (access and refresh tokens).
2. Refreshes the access token when it is expired.
3. Calls a test API endpoint to verify token validity and connectivity.

## Prerequisites
- PowerShell 5.1 or later

## Installation

1. Clone the repository:

``` bash
git clone https://github.com/your-username/your-repo-name.git cd your-repo-name
```

Note: Replace "https://github.com/your-username/your-repo-name.git" with the actual URL of your GitHub repository


## Files

- `config.ps1`: Contains configuration variables required for token management and API calls.
- `main.ps1`: The main PowerShell script that performs token management and API calls.

## Configuration

Update the `config.ps1` file with your specific configuration details:

```powershell
# Configuration variables
$global:TOKEN_URL = "https://your-hostname.delinea.app/identity/api/oauth2/token/xpmplatform"
$global:CLIENT_ID = "your-client-id"
$global:CLIENT_SECRET = "your-client-secret"
$global:SCOPE = "xpmheadless"  
$global:GRANT_TYPE = "client_credentials"  # Default grant type
$global:REFRESH_GRANT_TYPE = "refresh_token"  # Grant type for refreshing the token
$global:API_URL = "https://your-hostname.delinea.app/identity/entities/xpmusers?detail=true"  # Test API endpoint
```

- $global:TOKEN_URL: Specifies the URL where OAuth 2.0 tokens can be obtained from your platform tenant.
- $global:CLIENT_ID and CLIENT_SECRET: Your OAuth 2.0 client credentials used for authentication.
- $global:SCOPE: Defines the scope of access requested by the client application. default: xpmheadless
- $global:GRANT_TYPE: Specifies the OAuth 2.0 grant type (client_credentials) used for obtaining access tokens. 
- $global:REFRESH_GRANT_TYPE: Indicates the grant type (refresh_token) used for refreshing tokens.
- $global:API_URL: Provides the URL of a test API endpoint. This example includes the API endpoint for accessing user entities with detailed information.

## Usage

The script will:

- Check if the current access token is valid.
- If the token is expired, it will refresh the token using the refresh token.
- After refreshing or confirming the token's validity, it will call the specified test API endpoint and print the response.


## Running the Script

1. Open a PowerShell prompt and navigate to the directory where the scripts are saved.
2. Run the main.ps1 script:

```powershell
.\main.ps1
```



## Notes
This script is provided as-is without any warranties. Please review the code and test it in a controlled environment before deploying it in a production setting. Use it at your own risk.
Ensure you have appropriate permissions and access to the Delinea Platform API.
