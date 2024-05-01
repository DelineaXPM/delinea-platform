SELECT 
	c.ComputerName AS 'Host', 
	ca.AccountName AS 'Account Name',
	ST.ScanItemTemplateName AS 'Account Type',
	c.ComputerVersion AS 'Operating System',
	CASE 
		WHEN ca.PasswordLastSet IS NULL then 'Never'
		ELSE CONVERT(nvarchar,ca.PasswordLastSet)
	END AS 'Password Last Set',
	CASE
		WHEN ca.ScanItemTemplateId =13 and ca.IsLocalAdministrator = 1 THEN 'Built-in Administrator'
		WHEN ca.ScanItemTemplateId =13 and ca.IsLocalAdministrator = 0 THEN 'Standard_User'
	END AS 'Account Privilege',
	CASE 
		WHEN ca.ScanItemTemplateId =13 and ca.HasLocalAdminRights = 1 THEN 'Yes'
		WHEN ca.ScanItemTemplateId =13 and ca.HasLocalAdminRights = 0 THEN 'No'
	END AS 'Has Local Admin Rights',
	ou.Path 'Organizational Unit'
FROM 
		tbComputer c
	JOIN 	tbComputerAccount ca 

	ON 
		ca.ComputerID = c.ComputerId

	JOIN tbOrganizationUnit OU

	ON c.OrganizationUnitId = ou.OrganizationUnitId
	JOIN tbScanItemTemplate ST
	on ca.ScanItemTemplateId = ST.ScanItemTemplateId
