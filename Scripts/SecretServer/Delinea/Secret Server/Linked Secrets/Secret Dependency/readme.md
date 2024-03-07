# Secret Server Linked Secrets

In some cases it is desirable to create a link between multiple secrets so that when the main secret changes its password, the others change their passwords to match. There is a [documented process](https://docs.delinea.com/secrets/current/remote-password-changing/sync-passwords-during-rpc) that uses the SOAP API. If you want a REST API implentation of the same process follow the steps outlined in the official document, but use [the script above](.\LinkedPassword_Change.ps1) instead of the script provided at the end of the documnet. All functionality is identical to the soap script as documented.

