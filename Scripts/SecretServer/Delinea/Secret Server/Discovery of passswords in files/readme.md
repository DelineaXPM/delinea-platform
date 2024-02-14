# This Guide will create a dependency scanner to find password in specific files

## Configuration
- Login to Secret Server Web UI and go to *** Admin -> Scripts: PowerShell, SQL, SSH ***
- Click on create new and paste the relevant script here.
  - Name: Discovery_PasswordsInFiles
  - Description: It aims to find words such as Username and Password used in the specified files under the specified folder in the script.
  - Category: Dependency
- Open Discovery page from Admin Panel.
- Open the Configuration tab.
- Click Discovery Configuration Options > Extensible Discovery.
- Under Discovery Scanners, Click Configure Discovery Scanners. And open Dependencies tab. Click + Create New Scanner.
  - Name: Discovery_PasswordsInFiles
  - Description: It aims to find words such as Username and Password used in the specified files under the specified folder in the script.
  - Discovery Type: Find Dependencies
  - Base Scanner: PowerShell Discovery
  - Input Template: Windows Computer
  - Output Template: Remote File
  - Related Script
  - Script Arguments: $Target
- Open Discovery page from Admin Panel.
- Open the Discovery Scanner you want to scan.
- Click Scanner Settings.
- Under Find Dependencies, Click Add New Dependency Scanner. Choose the Scanner just created.