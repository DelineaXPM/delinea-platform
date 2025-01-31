# Azure Key Vault Secret Retrieval

This repository contains a sample script to authenticate with Azure and retrieve secrets from **Azure Key Vault (AKV)**. The script uses the Azure CLI for authentication and secret retrieval.

Instead of hardcoding credentials in configuration files, this script demonstrates how you can dynamically fetch secrets at runtime, enhancing security and reducing the risk of credential exposure.  For instance, you can store and retrieve the Platform Client ID and Secret used for authenticating to the Platform.  

## Files

- `akv_config.py`: Configuration file containing the Key Vault name and Azure tenant ID.
- `akv-retrieve.py`: Script to authenticate with Azure and retrieve secrets from Azure Key Vault.

## Prerequisites

- Python 3.6 or higher
- PIP3 command line tool for installing Python 3 modules.
- Azure CLI
- Required Python packages: `colorama`

## Installation

1. Clone the repository

2. Install the required Python packages:
    ```bash
    pip3 install colorama
    ```

3. Configure Azure  CLI:
    Ensure you have the Azure CLI installed and configured. You can install it from [here](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli).

## Configuration

1. Update `akv_config.py` file:

   Replace the placeholders with your actual Azure Key Vault name and tenant ID.
    ```python
    KEY_VAULT_NAME = "<your-key-vault-name>"  # Replace with your actual Key Vault name
    AZURE_TENANT_ID = "<your-tenant-id>"  # Replace with your actual Azure tenant ID
    ```

## Usage

1. Run the script:
    ```bash
    python3 akv-retrieve.py
    ```

    The script will:
    - Authenticate to Azure using the Azure CLI.
    - Retrieve the secrets `PLATFORM_CLIENT_ID` and `PLATFORM_CLIENT_SECRET` from the specified Azure Key Vault.
    - Obfuscate the retrieved secrets.
    - Print the obfuscated secrets.

## Troubleshooting

- Ensure you have the correct permissions to access the Azure Key Vault.
- Make sure the Azure CLI is installed and configured correctly.
- Verify that the secrets `PLATFORM-CLIENT-ID` and `PLATFORM-CLIENT-SECRET` exist in the specified Key Vault.

## Notes

- This script is provided as-is without any warranties. Please review and test the code in a controlled environment before deploying it in a production setting. **Use it at your own risk.**


