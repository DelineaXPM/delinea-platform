SELECT 
    grouped.[UserDisplayName] [DisplayName],
    ISNULL(f.FolderPath, 'No Folder assigned') [Folder Path],
    grouped.[SecretName] [Secret Name],
    CASE (grouped.[Permissions])
        WHEN 1 THEN 'List'
        WHEN 1 | 2 THEN 'List/View'
        WHEN 1 | 2 | 4 THEN 'List/View/Edit'
        WHEN 1 | 2 | 4 | 8 THEN 'List/View/Edit/Owner'
    END [Permissions],
    IIF(d2.[Domain] IS NULL, grouped.[DisplayName], d2.[Domain] + N'\' + grouped.[DisplayName]) [UserOrGroup],
    grouped.[SecretId]
FROM (
    SELECT 
        s.[SecretId],
        acl.[Permissions] [Permissions],
        s.[SecretName],
        g.[DomainId],
        s.[EnableInheritPermissions],
        u.UserID,
        IIF(g.[IsPersonal] = 1, u.[DisplayName], g.[GroupName]) [DisplayName],
        IIF(d.[Domain] IS NULL, u.[DisplayName], d.[Domain] + N'\' + u.[DisplayName]) [UserDisplayName],
        acl.[GroupID]
    FROM dbo.tbSecretACL acl WITH (NOLOCK)
    JOIN dbo.tbSecret s WITH (NOLOCK) ON s.SecretID = acl.SecretID AND s.Active = 1
    JOIN dbo.tbGroup g WITH (NOLOCK) ON acl.[GroupID] = g.[GroupID] AND (g.[Active] = 1 OR g.[IsPersonal] = 1)
    JOIN dbo.tbUserGroup ug WITH (NOLOCK) ON acl.[GroupID] = ug.[GroupID]
    JOIN dbo.tbUser u WITH (NOLOCK) ON ug.[UserID] = u.[UserId]
    LEFT JOIN dbo.tbDomain d WITH (NOLOCK) ON u.[DomainId] = d.[DomainId]
) grouped
JOIN tbSecret s WITH (NOLOCK) ON grouped.[SecretID] = s.[SecretId] AND s.[Active] = 1
LEFT JOIN tbFolder f WITH (NOLOCK) ON s.[FolderID] = f.[FolderId]
LEFT JOIN dbo.tbDomain d2 WITH (NOLOCK) ON grouped.[DomainId] = d2.[DomainId]
WHERE s.EnableInheritPermissions = 0 
  AND f.FolderPath LIKE '\' + (select PersonalFolderName from tbConfiguration) +'%'  
  AND f.UserId <> grouped.userid
ORDER BY s.[SecretId]
