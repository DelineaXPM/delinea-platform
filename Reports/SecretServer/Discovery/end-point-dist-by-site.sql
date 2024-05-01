SELECT 
    [s].[SiteName],
    COUNT([df].[SiteId]) AS 'Total Servers/Endpoints'
FROM [tbComputer] [c]
LEFT JOIN [tbOrganizationUnit] [ou] ON [c].[OrganizationUnitId] = [ou].[OrganizationUnitId]
LEFT JOIN [tbDiscoveryFilter] [df] ON [ou].[DistinguishedName] = [df].[DistinguishedName]
LEFT JOIN [tbSite] [s] ON [df].[SiteId] = [s].[SiteId]
GROUP BY 
    [s].[SiteName],
    [df].[SiteId]