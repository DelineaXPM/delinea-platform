SELECT
    [s].[SiteName],
    [c].[ComputerName],
    [c].[DistinguishedName],
    [ca].[AccountName]
FROM [tbComputerAccount] [ca]
JOIN [tbComputer] [c] ON [ca].[ComputerId] = [c].[ComputerId]
JOIN [tbDiscoverySource] [ds] ON [c].[DiscoverySourceId] = [ds].[DiscoverySourceId]
JOIN [tbSite] [s] ON [ds].[SiteId] = [s].[SiteId]
WHERE [ca].[AccountName] IN ('Administrator')
ORDER BY
    [s].[SiteName],
    [c].[DistinguishedName],
    [ca].[AccountName]