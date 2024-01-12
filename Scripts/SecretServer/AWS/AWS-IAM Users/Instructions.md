 # AWS Connector Base Instructions

This connectore provides the following functions  

- Discovery of Local Accounts
- Remote Password Changing users
- Heartbeats to verify that user credentials are still valid

Follow the Steps below to complete the base setup for the Connector

This connector utilizes a Service Account alond with its Access Key and Secret. This flow is typically used for server-to-server API requests where the application itself needs to authenticate and interact with AWS APIs.
​
### Prerequisites

- Access to a AWS instance with administrative privileges. The administrattive privilleges may be replace with a lower security level, but these permissions must allow the Service Account to View and Manage all userss, biew all froup memberships and view all permission policiy assignments 
- Installation of AWS Tools PowerShell module intsall on all Secret Server Distributed Engines.  For more information on AWS Tools click[here](https://www.powershellgallery.com/packages/AWS.Tools.IdentityManagement/4.1.483)

## Create AWS Service Account
- Cunsult your AWS Administrator to create a user to be used as the Service Account.
- Document the Accesss Key and Secret Key.  
- Assign the persions detailed in the [Prerequisites Section](#prerequisites)



## Creating secret template for AWS Accounts 

### AWS User Account Template

The following steps are required to create the Secret Template for ServiceNow Users:

- Log in to the Delinea Secret Server (If you have not already done so)
- Navigate to Admin / Secret Templates
- Click on Create / Import Template
- Click on Import.
- Cpoy and Paste the XML in the [AWS User Advanced.xml File](./Templates/AWS%20User%20Advanced%20Template.xml)
- Click on Save
- This completes the creation of the User Account template

### AWS Service Account Template

The following steps are required to create the Secret Template for ServiceNow Privileged Account:

- Log in to the Delinea Secret Server (If you have not already done so)
- Navigate to Admin / Secret Templates
- Click on Create / Import Template
- Click on Import.
- Cpoy and Paste the XML in the [AWS Service Account Advanced Privileged Template.xml File](./Templates/AWS%20Service%20Account%20Advanced%20Template.xml)
- Click on Save
- This completes the creation of the Privileged Account template


## Create secret in Secret Server for the AWS Service Account
 
- Log in to the Delinea Secret Server (If you have not already done so)
- Navigate to Secrets
- Click on Create Secret
- Select the AWS Service Account template created in the earlier step [Above](#aws-service-account-template).
- Fill out the required fields with the information from the application registration
    - Secret Name (for example AWS Service Account )
    - The following field values are as created in the [Prerequisites Section](#prerequisites)
    `- Username 
    - Access Key
    - Secret Key
  - Admin-Criteria  - Cooma Seperted List of AWS Policies used to determine Admin Accounts (Policy Name=Policy arn
      example: Admin Access=arn:aws:iam::aws:policy/AdministratorAccess","Service-accounts,Custom Access=arn:aws:iam::aws:policy/CustomAccess" 
  - SVC-Account-Criteria Cooma Seperted List of AWS Groups used to determine Service Accounts 
        example:  Service-Accounts1,ServiceAccounts2
  - Click Create Secret
  - This completes the creation of a secret in Secret Server for the ServiceNow Priviled Account

## Next Steps

Once the tasks above are completed you can now proceed to creat a [Discovery Scanner](./Discovery/readme.md) and/or a [Remote Password Changer](./Remote%20Password%20Changer/readme.md)