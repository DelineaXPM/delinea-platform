# Creating secret templates for Slack Accounts 

### Slack User Account Template

The following steps are required to create the Secret Template for Slack Users:
- Navigate to **Administration** -> **Secret Templates**
- Click on **Create / Import Template**
- Click on **Import**
- Copy and Paste the XML in the [Slack User Template](./Slack%20User%20Account.xml)
- Click on **Save**

### Slack Discovery Account Template

The following steps are required to create the Secret Template for Slack Discovery Account:
- Navigate to **Administration** -> **Secret Templates**
- Click on **Create / Import Template**
- Click on **Import**
- Copy and Paste the XML in the [Slack Discovery Account Template](./Slack%20Discovery%20Credentials.xml)
- Click on **Save**

## Create secret in Secret Server for the Slack Discovery Account
- Navigate to **Secrets**
- Click on **Create Secret**
- Select the template created in the [earlier step](#slack-discovery-account-template).
- Fill out the required fields with the information from the application registration
    - **Secret Name:** for example Slack API Account
    - **Workspace Name:**
    - **workspace-url:** Slack base workspace URL with no trailing slash
- The following field values are as created in the [create an OAuth application registry](../Instructions.md/#create-an-oauth-application-registry) Section
    - **OAuthToken:**
    - **admin-roles:**
    - **svcacct-roles:**
- Click **Create Secret**
  - For additional information regarding which [admin and service account roles](https://api.slack.com/types/user) are supported, refer to [the listing in the connector instructions document](../Instructions.md#slack-user-role-definitions)