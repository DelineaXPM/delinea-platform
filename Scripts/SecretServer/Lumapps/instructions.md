# Prerequisites for Lumapps Integrations
- [OAUTH access configured](https://docs.lumapps.com/docs/admin-l02262716934071929extensions)
- [SaaS Client Credential template](./Template/SaaSClientCredentials.xml) installed with the following data entered
  - Application ID
  - Application Secret
  - Organization ID
  - API Url
  - Email for admin account
- SaaS Client Credential mapped to password changer for web user account changer (this mapping is just to enable features within Secret Server, the template will **not** update the OAUTH credentials)
  - RPC enabled 
  - Host -> APIUrl
  - Password -> ApplicationSecret
  - User Name -> ApplicationID

# Configuration
- Configure [Lumapps Password Changer](./RemotePasswordChanger/readme.md)
- Configure [Lumapps Discovery Source](./Discovery/readme.md)
- Import secrets
  - Assign SaaS Client Credential template secret as associated secret #1 to all accounts either directly or by using a [secret policy](https://docs.delinea.com/online-help/secret-server/secret-management/procedures/creating-secret-policies/index.htm)
  
