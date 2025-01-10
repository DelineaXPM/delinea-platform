# config.py

# Main Variables - update these values as needed
PLATFORM_URL = "https://yourplatform.url"  # Your Platform tenant URL (e.g. https://your-hostname.delinea.app)
PLATFORM_CLIENT_ID = "your_client_id"  # Client ID for the Delinea platform (client credentials)
PLATFORM_CLIENT_SECRET = "your_client_secret"  # Client secret for the Delinea platform
APP_NAME = "YourAppName"  # Sets the name for the app registration, will apply to both Azure and Platform.
DOMAIN_NAMES = "yourdomain.com"  # Domain name for the registered app, separated by commas.
PLATFORM_SCOPE = "your_scope"  # Specifies the scope for the Delinea platform
AZURE_TENANT_ID =  "azure_tenant_id" # Specifies the tenant id in Azure

# Optional settings for Azure AD app registration
AZURE_SECRET_DURATION_MONTHS = 6  # Specifies the lifespan of the client secret in months.
AZURE_SECRET_DISPLAY_NAME = "Auto Generated Secret"  # Sets a descriptive name for the client secret.
AZURE_GRAPH_API_ID = "00000003-0000-0000-c000-000000000000"  # Identifies the Microsoft Graph API used for configuring permission
s.

# Optional settings for Delinea Platform
PLATFORM_GRANT_TYPE = "client_credentials"  # Default grant type
PLATFORM_REG_APP_DESC = "Auto Generated APP"  # Sets a description for the registered app in the Delinea platform.
