SELECT 
	isnull(Domain,ds.Name) AS 'Discovery Source / Domain'
	,c.ComputerName AS 'Computer Name'
	,ca.AccountName AS 'Account Name'
	,'Last Successful Scan' =
		CASE 
			WHEN (SELECT COUNT(*) FROM tbComputerScanLog WHERE Success = 1 AND tbComputerScanLog.ComputerId = c.ComputerId) = 0 THEN CONVERT(DATETIME, '1754')
			ELSE (SELECT TOP 1 ScanDate FROM tbComputerScanLog WHERE Success = 1 AND tbComputerScanLog.ComputerId = c.ComputerId ORDER BY ComputerScanLogId DESC)
		END
FROM tbComputer c
	INNER JOIN tbDiscoverySource ds on c.DiscoverySourceId = ds.DiscoverySourceId
	LEFT JOIN tbDomain d ON d.DomainId = ds.DomainId
	LEFT JOIN tbComputerAccount ca ON ca.ComputerId = c.ComputerId
	LEFT JOIN tbSecret s ON s.ComputerAccountId = ca.ComputerAccountId
WHERE ds.Active = 1
	AND ((d.EnableDiscovery is null) OR (d.EnableDiscovery = 1))
	AND (SELECT COUNT(*) FROM tbComputerScanLog WHERE tbComputerScanLog.ComputerId = c.ComputerId AND Success = 1) > 0
	AND s.ComputerAccountId IS NULL
GROUP BY isnull(Domain,ds.Name), c.ComputerName, c.ComputerId, ca.AccountName
	HAVING COUNT(ca.AccountName) > 0
ORDER BY
		1,2,3 ASC