# Prerequisites for Lumapps Integrations
* [OAUTH access configured](https://docs.lumapps.com/docs/admin-l02262716934071929extensions)
* SaaS Client Credential template installed with the following data entered
  * Application ID
  * Application Secret
  * Organization ID
  * API Url
  * Email for admin account
* SaaS Client Credential mapped to password changer for web user account changer (this mapping is just to enable features within Secret Server, the template will **not** update the OAUTH credentials)
  * RPC enabled 
  * Host -> APIUrl
  * Password -> ApplicationSecret
  * User Name -> ApplicationID
  
