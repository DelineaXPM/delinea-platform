# How to create a scanner to find files that may contain credentials and log results into a file for review

The script runs as part of the discovery computer scan and searches a folder path on each discovered computer for files containing specific tokens. The gathered data is logged to a file for review. No data will be returned to Discovery Network View

***Configurable options***
1) The file types scanned are configurable on line 21
2) The search tokens are on line 1 of the script
3) The folder path to search is configurable on line 3 and should be in UNC format
4) The results file is configurable on line 6 and should be in UNC format

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
