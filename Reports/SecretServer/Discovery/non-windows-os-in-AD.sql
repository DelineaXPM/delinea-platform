SELECT
    [c].[ComputerName],
    [c].[DistinguishedName],
    [c].[ComputerVersion]
FROM [tbComputer] [c]
JOIN [tbDiscoverySource] [ds] ON [c].[DiscoverySourceId] = [ds].[DiscoverySourceId]
WHERE
    [c].[ComputerVersion] IS NULL
    OR
    [c].[ComputerVersion] NOT LIKE '%Windows%'
    AND
    [ds].[DiscoverySourceId] == 1 -- Set to the AD/windows discovery source