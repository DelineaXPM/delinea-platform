# Workday Delinea Secret Server Integration

This package is designed to discover Workday and Rotate the passwords of User Accounts. It will also provide a method of determining Administrative and Service accounts based on a configurable criteria as well as local accounts. It will provide detailed instructions and the necessary Scripts to perform these functions. Before beginning to implement any of the specific processes it is a requirement to perform the tasks contained in the Instructions.md document which can be found  [Here](./instructions.md)

## Functionality

-   Discovery of Local, Admin, and Service Accounts
-   Remote Password Change of User Accounts

### Not available

**NOTE**  - Workday does not support Heartbeat. There is a placeholder script along with instructions that can be used to create a "Mock" password changer that will allow the importing of discovered accounts.

# Authentication and Authorization Disclaimer

The provided configurations are developed by using a generate JSON Web Token [JSON Web Token OAuth Access Token](https://community.workday.com/node/752269)  for Authentication and Authorization. This is one of the many methods to authenticate and provide the necessary access to complete this process, but one of the most secure.

# Disclaimer

The provided scripts are for informational purposes only and are not intended to be used for any production or commercial purposes. You are responsible for ensuring that the scripts are compatible with your system and that you have the necessary permissions to run them. The provided scripts are not guaranteed to be error-free or to function as intended. The end user is responsible for testing the scripts thoroughly before using them in any environment. The authors of the scripts are not responsible for any damages or losses that may result from the use of the scripts. The end user agrees to use the provided scripts at their own risk. Please note that the provided scripts may be subject to change without notice.