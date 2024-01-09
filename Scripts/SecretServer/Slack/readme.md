
# Slack Delinea Secret Server Integration

This package is designed to discover Slack User Accounts. It will alos provide a method of determining Administrative and Service accounts based on a configurable criteria. It will provide detailed instructions and the necessary Scripts to perform these functions. Before beginning to implement any of the specific processes it is a requirement to perform the tasks contained in the Instructions.md document which can be found [Here](./Instructions.md)

**NOTE** - Slack does not support Remote Password changing or Heartbeat. There is a placeholder script along with instructions that can be used to create a "Mock" password changer that will allow the importing of discovered accounts.  

# Authentication and Authorization Disclaimer

The provided configurations are developed by using a static [user OAuth Access Token](https://api.slack.com/authentication/token-types) for Authentication and Authorization. For a production implementation, it will be up to you to configure an OAuth 2.0 Client Credential for authentication. Due to a user challenge requirement with redirect URI, we have opted to use a static token for this automation integration. For more information regarding OAuth and Slack, please reference [Slack OAuth v2 Authentication](https://api.slack.com/authentication/oauth-v2). For additional Security Best Practices, please reference [Slack API Best Practices for Security](https://api.slack.com/authentication/best-practices).

# Disclaimer

The provided scripts are for informational purposes only and are not intended to be used for any production or commercial purposes. You are responsible for ensuring that the scripts are compatible with your system and that you have the necessary permissions to run them. The provided scripts are not guaranteed to be error-free or to function as intended. The end user is responsible for testing the scripts thoroughly before using them in any environment. The authors of the scripts are not responsible for any damages or losses that may result from the use of the scripts. The end user agrees to use the provided scripts at their own risk. Please note that the provided scripts may be subject to change without notice.

