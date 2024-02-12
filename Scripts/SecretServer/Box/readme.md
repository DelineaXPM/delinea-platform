# Box Delinea Secret Server Integration

  

This package is designed to discover Box User Accounts. It will provide detailed instructions and the necessary scripts to perform these functions. Before beginning to implement any of the specific processes it is a requirement to perform the tasks contained in the Instructions.md document which can be found [here](./Instructions.md)

  
  

**NOTE** - Box does not support Remote Password changing or Heartbeat. There is a placeholder script along with instructions that can be used to create a "mock" password changer that will allow the importing of discovered accounts.

  

# Authentication and Authorization Disclaimer

  

This connector utilizes an OAuth 2.0 application in Box using the Client Credentials grant type. This flow is typically used for server-to-server API requests where the application itself needs to authenticate and interact with Box APIs.

More information can be found [here](https://developer.box.com/guides/authentication/oauth2/).

  
  

# Disclaimer
  

The provided scripts are for informational purposes only and are not intended to be used for any production or commercial purposes. You are responsible for ensuring that the scripts are compatible with your system and that you have the necessary permissions to run them. The provided scripts are not guaranteed to be error-free or to function as intended. The end user is responsible for testing the scripts thoroughly before using them in any environment. The authors of the scripts are not responsible for any damages or losses that may result from the use of the scripts. The end user agrees to use the provided scripts at their own risk. Please note that the provided scripts may be subject to change without notice.