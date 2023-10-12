Configuration

1. The Secret Server Web UI opens and goes to the "Scripts: Powershell, SQL, SSH" section.
2. Click on create new and paste the relevant script here.
	2.1 Name: Discovery_PasswordsInFiles
	2.2 Description: It aims to find words such as Username and Password used in the specified files under the specified folder in the script.
	2.3 Category: Dependency
3. Open Discovery page from Admin Panel.
4. Open the Configuration tab.
5. Click Discovery Configuration Options > Extensible Discovery.
6. Under Discovery Scanners, Click Configure Discovery Scanners. And open Dependencies tab. Click + Create New Scanner.
	6.1 Name: Discovery_PasswordsInFiles
	6.2 Description: It aims to find words such as Username and Password used in the specified files under the specified folder in the script.
	6.3 Discovery Type: Find Dependencies
	6.4 Base Scanner: PowerShell Discovery
	6.5 Input Template: Windows Computer
	6.6 Output Template: Remote File
	6.7 Related Script
	6.8 Script Arguments: $Target
7. Open Discovery page from Admin Panel.
8. Open the Discovery Scanner you want to scan.
9. Click Scanner Settings.
10. Under Find Dependencies, Click Add New Dependency Scanner. Choose the Scanner just created.