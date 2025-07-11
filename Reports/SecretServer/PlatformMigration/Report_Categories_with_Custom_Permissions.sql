SELECT 
    RCACL.ReportCategoryID,
    RC.Name as CategoryName,
    RCACL.GroupID,
    G.GroupName as PermissionGroup,
    RCACL.Permissions,
    CASE 
        WHEN RCACL.Permissions = 1 THEN 'View'
        WHEN RCACL.Permissions = 3 THEN 'Edit'
        ELSE CAST(RCACL.Permissions AS VARCHAR(10))
    END as PermissionName
FROM tbReportCategoryACL RCACL
    INNER JOIN tbReportCategory RC ON RC.ReportCategoryId = RCACL.ReportCategoryID
    INNER JOIN tbGroup G ON G.GroupID = RCACL.GroupID
ORDER BY 
    RC.Name, G.GroupName 
    
    
-- Report categories with custom permissions - Detailed report
