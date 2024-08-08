# Delinea Platform API Access Token Python Script

This repository contains a Python script designed to manage OAuth tokens and test API connectivity for the Delinea Platform.

This is a simplified example and might need to be adapted to fit your specific requirements

## Overview

The script performs the following tasks:
1. Obtains initial OAuth tokens (access and refresh tokens).
2. Refreshes the access token when it is expired.
3. Calls a test API endpoint to verify token validity and connectivity.



## Prerequisites
- Python 3.6+
- Ensure you have `pip`, the Python package installer, to install the required packages. pip usually comes bundled with Python installations.
- `requests` library 
- `colorama` library
- The script provided is written in Python and should be able to run on any operating system that supports Python, including Windows, macOS, and Linux. For this documentation, we are providing instructions validated on Linux.


## Installation

1. Clone the repository:

``` bash
git clone https://github.com/your-username/your-repo-name.git cd your-repo-name
```

Note: Replace "https://github.com/your-username/your-repo-name.git" with the actual URL of your GitHub repository

2. Create a virtual environment (optional but recommended):
``` bash
python3 -m venv venv
source venv/bin/activate # On Windows, use `.\venv\Scripts\activate`
```

3. Install the required packages:

Note: it is highly recommended to set up a Virtual Environment. Otherwise, packages will be installed system-wide. 

``` bash
pip install requests colorama
```

## Files

- `config.py`: Contains configuration variables required for token management and API calls.
- `main.py`: The main Python script that performs token management and API calls.

## Configuration

Update the `config.py` file with your specific configuration details:

```python
# Configuration variables
TOKEN_URL = "https://your-hostname.delinea.app/identity/api/oauth2/token/xpmplatform"
CLIENT_ID = "your-client-id"
CLIENT_SECRET = "your-client-secret"
SCOPE = "xpmheadless"  
GRANT_TYPE = "client_credentials"  # Default grant type
REFRESH_GRANT_TYPE = "refresh_token"  # Grant type for refreshing the token
TEST_API_URL = "https://your-hostname.delinea.app/identity/entities/xpmusers?detail=true"  # Test API endpoint
```

- `TOKEN_URL`: Specifies the URL where OAuth 2.0 tokens can be obtained from your platform tenant.
- `CLIENT_ID` and `CLIENT_SECRET`: Your OAuth 2.0 client credentials used for authentication.
- `SCOPE`: Defines the scope of access requested by the client application. default: xpmheadless
- `GRANT_TYPE`: Specifies the OAuth 2.0 grant type (client_credentials) used for obtaining access tokens. 
- `REFRESH_GRANT_TYPE`: Indicates the grant type (refresh_token) used for refreshing tokens.
- `TEST_API_URL`: Provides the URL of a test API endpoint. This example includes the API endpoint for accessing user entities with detailed information.

## Usage

1. Run the main script inside the python virtual environment to check and renew the access token and call the test API:

``` bash
python main.py
 ```

The script will:

- Check if the current access token is valid.
- If the token is expired, it will refresh the token using the refresh token.
- After refreshing or confirming the token's validity, it will call the specified test API endpoint and print the response.

### Example Output

``` bash
Access token expired, refreshing...
New access token obtained: your-new-access-token
Test API call successful!
{
    "data": "sample response from your API"
}
```

The script accepts a command-line parameter that allows you to mimic an expired token. Append command-line parameter `--mimic-expired` to mimic an expired token.

```bash
python main.py --mimic-expired
```

## Notes
This script is provided as-is without any warranties. Please review the code and test it in a controlled environment before deploying it in a production setting. Use it at your own risk.
Ensure you have appropriate permissions and access to the Delinea Platform API.
