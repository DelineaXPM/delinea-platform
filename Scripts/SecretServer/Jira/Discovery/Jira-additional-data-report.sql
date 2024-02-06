SELECT ds.name as [Discovery Source],
    MIN(
        CASE
            JSON_VALUE([adata].[value], '$.Name')
            WHEN 'EmailAddress' THEN JSON_VALUE([adata].[value], '$.Value')
        END
    ) AS [Email Address],
    ca.[AccountName] AS [Username],
    MIN(
        CASE
            JSON_VALUE([adata].[value], '$.Name')
            WHEN 'AdminGroups' THEN JSON_VALUE([adata].[value], '$.Value')
        END
    ) AS [Member of Admin Groups]
FROM tbComputerAccount AS ca
    CROSS APPLY OPENJSON (ca.AdditionalData) AS adata
    INNER JOIN tbScanItemTemplate AS s ON s.ScanItemTemplateId = ca.ScanItemTemplateId
    join tbDiscoverySource ds on ca.DiscoverySourceId = ds.DiscoverySourceId
WHERE ds.name = 'Jira Account Discovery'
group by name,
    ca.AccountName