# AWS Remote Password Changer

**NOTE** AWS IAM User Password Changer does not support Heartbeats. If the password change fails an error will be reported

## Associate the Amazon IAM Console Password Privileged Account Remote Password Changer with the AWS IAM User template
- Log in to the Delinea Secret Server
- Navigate to Admin / Secret Templates
- Click on the AWS User Advanced template created in the [instructions.md file](../Instructions.md)
- Click on Mapping
- Click on Edit
- Change the following field to use the Amazon IAM Console Password Privileged Account password type
    - Password Type to use: Select the Amazon IAM Console Password Privileged Account
- Click on Save

## Associate AWS Service account to AWS secret
To be able to correctly use the password changer, the AWS Service account must be associated with the AWS IAM User secret. This can be done by following the steps below:
- Log in to the Delinea Secret Server
- Navigate to Secrets
- Locate your secret(s) based on the AWS IAM User template
- Click on the secret
- Click on Remote Password Changing
- Go to the Associated Secrets section at the bottom of the page
- Click on Edit
- Click on Add Secret
- Search for the earlier created [AWS Service Account secret](../Instructions.md#create-secret-in-secret-server-for-the-aws-service-account) for the application registration and select that
- Click on Save

 This can also be done using a Secret Policy assigned to the Parent Folder or Directly to The Secret

