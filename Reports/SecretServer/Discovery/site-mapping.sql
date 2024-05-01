SELECT 
    [ds].[Name],
    [s].[SiteName],
    [c].[ComputerName],
    [c].[DistinguishedName]
FROM [tbComputer] [c]
LEFT JOIN [tbDiscoverySource] [ds] ON [c].[DiscoverySourceId] = [ds].[DiscoverySourceId]
LEFT JOIN [tbOrganizationUnit] [ou] ON [c].[OrganizationUnitId] = [ou].[OrganizationUnitId]
LEFT JOIN [tbDiscoveryFilter] [df] ON [ou].[DistinguishedName] = [df].[DistinguishedName]
LEFT JOIN [tbSite] [s] ON [df].[SiteId] = [s].[SiteId]
ORDER BY
    [ds].[Name],
    [s].[SiteName],
    [c].[ComputerName]