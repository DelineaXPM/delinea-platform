# Prerequisites
Install the [JiraPS](https://atlassianps.org/docs/JiraPS/) module from the [AtlassianPS project](https://atlassianps.org/) on all of the engines or webservers that will be performing the discovery functions


This can be found on the [PS Gallery](https://www.powershellgallery.com/packages/JiraPS) and installed with the following command

`install-module -name jiraps`

## Authentication
Rest API access is controlled by basic authentication using an Atlassian account and API token

Background: https://developer.atlassian.com/cloud/jira/platform/basic-auth-for-rest-apis/

Details on how to generate an API token can be found on the Atlassian documentation: https://support.atlassian.com/atlassian-account/docs/manage-api-tokens-for-your-atlassian-account/

##

Once you have created the required token per Atlassian documentation it will need to be stored as a secret using the Web Password Template
- **URL:** URL of the Jira instance
- **UserName:** email address of the admin user
- **Password:** API Token
- **Notes:** Comma separated list of admin groups
