# Git Delinea Secret Server Integration

This package is designed to discover Github User Accounts. It will also provide a method of determining Administrative and Service accounts based on a configurable criteria. It will provide detailed instructions and the necessary Scripts to perform these functions. Before beginning to implement any of the specific processes it is a requirement to perform the tasks contained in the Instructions.md document which can be found  [Here](https://file+.vscode-resource.vscode-cdn.net/c%3A/DelineaPS/Secret-Server-Customer-Integrations/Github/instructions.md)

## Functionality

-   Discovery of User Accounts

### Not available

**NOTE**  - Github does not support Remote Password changing or Heartbeat. There is a placeholder script along with instructions that can be used to create a "Mock" password changer that will allow the importing of discovered accounts.

# Authentication and Authorization Disclaimer

The provided configurations are developed by using a static  [user OAuth Access Token](https://docs.github.com/en/organizations/managing-programmatic-access-to-your-organization/setting-a-personal-access-token-policy-for-your-organization#restricting-access-by-personal-access-tokens-classic)  for Authentication and Authorization. This the only current method to authentcate and provide teh bneccessary access to complete this process. Due to a user challenge requirement with redirect URI, we have opted to use a static token for this automation integration.

# Disclaimer

The provided scripts are for informational purposes only and are not intended to be used for any production or commercial purposes. You are responsible for ensuring that the scripts are compatible with your system and that you have the necessary permissions to run them. The provided scripts are not guaranteed to be error-free or to function as intended. The end user is responsible for testing the scripts thoroughly before using them in any environment. The authors of the scripts are not responsible for any damages or losses that may result from the use of the scripts. The end user agrees to use the provided scripts at their own risk. Please note that the provided scripts may be subject to change without notice.