# Slack Connector Core Configuration

This connector provides the following functions  

- Discovery of Slack User Accounts in a given Workspace

## Not currently available
- Remote Password Changing Slack users
- Heartbeats to verify that user credentials are still valid

Follow the Steps below to complete the base setup for the Connector

# Prepare Oauth Authentication

## OAuth Client Credentials Flow in Slack

This connector utilizes an OAuth application in Slack using the bearer token grant type. This flow is typically used for server-to-server API requests where the application itself needs to authenticate and interact with Slack APIs.
​
### Prerequisites

- Access to a Slack instance with administrative privileges.
Basic understanding of OAuth Access Token authentication and Slack administration.

## Create an OAuth Application Registry

- Create an OAuth application registry in Slack to provide a source of authentication for programmatic Discovery found [here](https://api.slack.com/start/quickstart).

*** For more information click [here](https://api.slack.com/web#authentication).

- Document the following values as they will be needed in the upcoming sections
  - OAuth Token value
  - Grant the OAuth Token Scope: ```user:read```

# Creating secret template for Slack Accounts 

### Slack User Account Template

The following steps are required to create the Secret Template for Slack Users:

- Log in to the Delinea Secret Server (If you have not already done so)
- Navigate to ***Administration*** -> ***Secret Templates***
- Click on ***Create / Import Template***
- Select on ***Import XML***
- Copy and Paste the XML in the [Slack User Account Template](./Templates/Slack%20User%20Account.xml).
- Click on ***Save***


### Slack Discovery Account Template

The following steps are required to create the Secret Template for Slack Discovery Account:

- Log in to the Delinea Secret Server (If you have not already done so)
- Navigate to ***Administration*** -> ***Secret Templates***
- Click on ***Create / Import Template***
- Select on ***Import XML***
- Copy and Paste the XML in the [Slack Discovery Account Template](./Templates/Slack%20Discovery%20Credentials.xml).
- Click on ***Save***

## Create secret in Secret Server for the Slack Discovery Account
 
- Log in to the Delinea Secret Server (If you have not already done so)
- Navigate to ***Secrets***
- Click on ***Create Secret***
- Select the template created in the [earlier step](#slack-discovery-account-template).
- Fill out the required fields with the information from the application registration
    - ***Secret Name:*** (for example Slack API Account )
    - ***Workspace Name:***
    - ***workspace-URL:*** (Slack base workspace URL with no trailing slash)
- The following field values are as created in the [Create an OAuth Application Registry](#create-an-oauth-application-registry) Section
    - ***OAuthToken***
    - ***admin-roles***
    - ***svcacct-roles***
- Click ***Create Secret***
  - For additional information regarding which admin and service account roles are supported, refer to the table and examples below.

# Slack Roles as defined by [slack user types](https://api.slack.com/types/user)
## Slack User Role Definitions
- ***is_admin:*** Indicates whether the user is an Admin of the current workspace
- ***is_owner:*** Indicates whether the user is an Owner of the current workspace.
- ***is_restricted:*** Indicates whether or not the user is a guest user.
- ***is_ultra_restricted:*** Indicates whether the restricted user is a single-channel guest.
- ***Is_app_user:*** Indicates whether the user is an authorized user of the calling app.
- ***Is_bot:*** Indicates whether the user is actually a bot user. 
    >{!Note]
    >Slackbot is special, so is_bot will be false for it. :robot:

Use the following comma-separated syntax to define what constitutes an "Admin" or "Service Account". These fields can be used to tailor your results of discovered users accordingly. **These examples are provided as a way to demonstrate syntax and formatting, not necessarily as a recommendation.**
>### Example 1
>- **admin-roles:** Is_admin=True,Is_Owner=True
>- **svcacct-roles:** Is_app_user=True,Is_bot=True


>### Example 2
>- **admin-roles:** Is_admin=True,is_restricted=False
>- **svcacct-roles:** Is_app_user=True,Is_bot=False,Is_admin=True


## Next Steps

Once the tasks above are completed you can now proceed to create a [discovery scanner](./Discovery/readme.md).
