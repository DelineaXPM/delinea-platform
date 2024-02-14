
# Login VSI Delinea Secret Server Integration

This package is designed to discover Login VSI User Accounts & create matching Delinea Secret Server secrets based on the discovered accounts. It will alos provide a method of determining Administrative and Service accounts based on a configurable criteria. It will provide detailed instructions and the necessary Scripts to perform these functions. Before beginning to implement any of the specific processes, it is a requirement to perform the tasks contained in the Instructions.md document which can be found [Here](./Instructions.md)

**NOTE** - Login VSI does not currently support Remote Password Changing or Heartbeat, which are two functions of Delinea's Secret Server. There is a placeholder script along with instructions that can be used to create a "Mock" password changer that will allow the importing of discovered accounts.  

# Authentication and Authorization Disclaimer

To proceed with this integration, you will need to be able to access the Login VSI virtual appliance portal and create or access an API Access Token.  Creation of an API Access Token in Login VSI is done in the Login VSI virtual appliance portal:  Go to External Notifications -> Public API -> and then click on the right side of the portal page on New system access token.  

When you create a new system access token, the actual token will only be displayed in clear text at this time, please note the access token because you will never be able to access the clear text of the access token again.  If you lose access to the clear-text of the access token, you can delete it, and create a new access token with the same rights & permissions.

# Disclaimer

The provided scripts are for informational purposes only and are not intended to be used for any production or commercial purposes. You are responsible for ensuring that the scripts are compatible with your system and that you have the necessary permissions to run them. The provided scripts are not guaranteed to be error-free or to function as intended. The end user is responsible for testing the scripts thoroughly before using them in any environment. The authors of the scripts are not responsible for any damages or losses that may result from the use of the scripts. The end user agrees to use the provided scripts at their own risk. Please note that the provided scripts may be subject to change without notice.

