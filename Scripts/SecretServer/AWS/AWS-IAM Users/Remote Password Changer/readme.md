# AWS Remote Password Changer

**NOTE** AWS IAM User Password Changer does not support Heatbeats.If the password change fails an error will be reported

## Associate the Amazon IAM Console Password Privileged Account Remote Password Changer with the AWS IAM User template
- Log in to the Delinea Secret Server
- Navigate to Admin / Secret Templates
- Click on the AWS User Advanced template create in the [instructions.md file](../Instructions.md)
- Click on Mapping
- Click on Edit
- Change the following field to use the Amazon IAM Console Password Privileged Account password type
    - Password Type to use: Select the Amazon IAM Console Password Privileged Account
- Click on Save
-

## Associate scripting account to Azure AD secret
To be able to correctly use the password changer, the AWS Service account must be associated with the AWS IAM User secret. This can be done by following the steps below:
- Log in to the Delinea Secret Server
- Navigate to Secrets
- Locate your secret(s) based on the AWS IAM User template
- Click on the secret
- Click on Remote Password Changing
- Go the Associated Secrets section in the bottom of the page
- Click on Edit
- Click on Add Secret
- Search for the earlier created [AW Service Accountsecret](../Instructions.md#create-secret-in-secret-server-for-the-aws-service-account) for the application registration and select that
- Click on Save

 This can Also bee done using a Secret Poicy assigned to the Parent Folder

## Testing the configuration
If all went well, you now should have:
- A secret template for the application registration
- An application registration in Azure AD / Entra ID
- A secret in Secret Server for the application registration
- The password changer script in Secret Server
- The password changer configured in Secret Server to use the script
- The password changer associated with the Azure AD Account template
- An Azure AD Account secret (not covered in this guide)
- The application registration secret associated with the Azure AD Account secret

To test the configuration, you can first start with performing a Heartbeat on the Azure AD Account secret. This can be done by following the steps below:
- Log in to the Delinea Secret Server
- Navigate to Secrets
- Locate your secret(s) based on the Azure AD Account template
- Click on the secret
- Click on Heartbeat
After a few moments the heartbeat should complete successfully.

To test the configuration, you can now change the password of the Azure AD Account secret. This can be done by following the steps below:
- Log in to the Delinea Secret Server
- Navigate to Secrets
- Locate your secret(s) based on the Azure AD Account template
- Click on the secret
- Click on Change Password Now
- Select Randoly Generated or Manual (and enter a password)
- Click on Change Password

If there are any issues, please check the following:

- SSDE.log on the Distributed Engine