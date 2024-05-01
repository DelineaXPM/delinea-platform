/*  Domain accounts discovered in Secret Server that are not managed in Secret Server  */

/*  To filter the results to only a specific OU, uncomment out the
AND ou.Path = 'SpecificOU\SpecificOU'
line and change SpecificOU\SpecificOU to the folder path for the OU to filter  */

/*  To include a specific OU and its sub-OUs, uncomment out the AND ou.Path line
and edit it to
AND ou.Path CONTAINS 'SpecificOU\SpecificOU'
and change SpecificOU\SpecificOU to the folder path for the OU to filter  */

SELECT
	isnull(Domain,ds.Name) AS 'Discovery Source / Domain'
	,ou.Path
	,ca.AccountName AS 'Account Name'
FROM tbComputerAccount ca
	INNER JOIN tbDiscoverySource ds on ca.DiscoverySourceId = ds.DiscoverySourceId
	LEFT JOIN tbDomain d ON d.DomainId = ds.DomainId
	LEFT JOIN tbOrganizationUnit ou ON ou.OrganizationUnitId = ca.OrganizationUnitId
	LEFT JOIN tbSecret s ON s.ComputerAccountId = ca.ComputerAccountId
WHERE ds.Active = 1
	AND ((d.EnableDiscovery is null) OR (d.EnableDiscovery = 1))
	AND s.ComputerAccountId IS NULL
	AND ca.OrganizationUnitId IS NOT NULL
/*	AND ou.Path = 'SpecificOU\SpecificOU'  */
GROUP BY isnull(Domain,ds.Name), ou.Path, ca.AccountName
	HAVING COUNT(ca.AccountName) > 0
ORDER BY
	1,2,3 ASC