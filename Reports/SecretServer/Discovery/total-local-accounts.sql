SELECT
    [ou].[DistinguishedName] AS 'OU DN',
    [c].[ComputerName],
    COUNT([ca].[ComputerId]) AS 'Total Local Accounts'
FROM [tbComputer] [c] 
JOIN [tbOrganizationUnit] [ou] ON [c].[OrganizationUnitId] = [ou].[OrganizationUnitId]
LEFT JOIN (SELECT * FROM [tbComputerAccount] [ca] WHERE [ca].[ComputerId] IS NOT NULL) [ca] ON [c].[ComputerId] = [ca].[ComputerId]
GROUP BY
    [ou].[DistinguishedName],
    [c].[ComputerId],
    [c].[ComputerName]
ORDER BY
    [ou].[DistinguishedName],
    [c].[ComputerName]