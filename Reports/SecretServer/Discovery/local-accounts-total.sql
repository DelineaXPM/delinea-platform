SELECT
    [ca].[AccountName],
    COUNT([ca].[AccountName]) AS [Total Found]
FROM [tbComputerAccount] [ca]
GROUP BY [ca].[AccountName]
ORDER BY [Total Found] DESC