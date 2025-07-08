SELECT 
    RACL.ReportID,
    CR.Name as ReportName,
    RC.Name as CategoryName,
    RACL.GroupID,
    G.GroupName as PermissionGroup,
    RACL.Permissions,
    CASE 
        WHEN RACL.Permissions = 1 THEN 'View'
        WHEN RACL.Permissions = 3 THEN 'Edit'
        ELSE CAST(RACL.Permissions AS VARCHAR(10))
    END as PermissionName
FROM tbReportACL RACL
    INNER JOIN tbCustomReport CR ON CR.CustomReportId = RACL.ReportID
    INNER JOIN tbReportCategory RC ON RC.ReportCategoryId = CR.ReportCategoryId
    INNER JOIN tbGroup G ON G.GroupID = RACL.GroupID
ORDER BY 
    RC.Name, CR.Name, G.GroupName



-- Reports with custom permissions - Detailed report
