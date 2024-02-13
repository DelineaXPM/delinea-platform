SELECT ds.name as [Discovery Source],
    ca.[AccountName] AS [Username],
    MIN(
        CASE
            JSON_VALUE([adata].[value], '$.Name')
            WHEN 'Groups' THEN JSON_VALUE([adata].[value], '$.Value')
        END
    ) AS [inGroups],
    MIN(
        CASE
            JSON_VALUE([adata].[value], '$.Name')
            WHEN 'Resource' THEN JSON_VALUE([adata].[value], '$.Value')
        END
    ) AS [Account ID]
FROM tbComputerAccount AS ca
    CROSS APPLY OPENJSON (ca.AdditionalData) AS adata
    INNER JOIN tbScanItemTemplate AS s ON s.ScanItemTemplateId = ca.ScanItemTemplateId
    join tbDiscoverySource ds on ca.DiscoverySourceId = ds.DiscoverySourceId
WHERE ds.name = 'Prophecy.io Account Discovery'
group by name,
    ca.AccountName