SELECT 
    f.FolderPath,
    COALESCE(fu.DisplayName, parent_owner.DisplayName) as [FolderOwner],
    COALESCE(fu.Enabled, parent_owner.Enabled) as [FolderEnabled],
    s.secretid,
    s.SecretName,
    t.SecretTypeName as [Template],
    CASE 
        WHEN (acl.Permissions = 15) then 'Owner'
        WHEN (acl.Permissions = 7) then 'Edit'
        WHEN (acl.Permissions = 3) then 'View'
        WHEN (acl.Permissions = 1) then 'List'
        ELSE concat('Permission ID: ',acl.permissions)
    END as [accessLevel],
    CASE 
        when (g.IsPersonal = 1) Then 'Direct Assignment'
        else g.GroupName 
    end as [Permissions From],
    vdn.Username
FROM tbSecretACL acl WITH (NOLOCK)
JOIN tbSecret s WITH (NOLOCK) ON s.SecretID = acl.SecretID AND s.Active = 1
JOIN tbSecretType t ON t.SecretTypeid = s.SecretTypeID
JOIN tbGroup g WITH (NOLOCK) ON acl.[GroupID] = g.[GroupID] AND (g.[Active] = 1 OR g.[IsPersonal] = 1)
JOIN tbUserGroup ug WITH (NOLOCK) ON acl.[GroupID] = ug.[GroupID]
JOIN tbUser u WITH (NOLOCK) ON ug.[UserID] = u.[UserId]
LEFT JOIN vUserDisplayName vdn ON vdn.UserId = u.UserId
LEFT JOIN tbFolder f WITH (NOLOCK) ON s.[FolderID] = f.[FolderId]
LEFT JOIN tbUser fu WITH (NOLOCK) ON f.[UserId] = fu.[UserId]
LEFT JOIN (
    
    SELECT 
        sub_f.FolderID,
		root_owner.UserId,
        root_owner.DisplayName,
        root_owner.Enabled
    FROM tbFolder sub_f WITH (NOLOCK)
    JOIN tbFolder root_f WITH (NOLOCK) ON (
    
        sub_f.FolderPath LIKE '\' + (SELECT PersonalFolderName FROM tbConfiguration) + '\%' AND
        root_f.FolderPath = '\' + (SELECT PersonalFolderName FROM tbConfiguration) + '\' + 
        SUBSTRING(
            sub_f.FolderPath, 
            LEN((SELECT PersonalFolderName FROM tbConfiguration)) + 3,
            CASE 
                WHEN CHARINDEX('\', sub_f.FolderPath, LEN((SELECT PersonalFolderName FROM tbConfiguration)) + 3) > 0
                THEN CHARINDEX('\', sub_f.FolderPath, LEN((SELECT PersonalFolderName FROM tbConfiguration)) + 3) - LEN((SELECT PersonalFolderName FROM tbConfiguration)) - 3
                ELSE LEN(sub_f.FolderPath) - LEN((SELECT PersonalFolderName FROM tbConfiguration)) - 2
            END
        )
    )
    LEFT JOIN tbUser root_owner WITH (NOLOCK) ON root_f.UserId = root_owner.UserId
    WHERE sub_f.UserId IS NULL
) parent_owner ON f.FolderID = parent_owner.FolderID
WHERE f.FolderPath LIKE '\' + (SELECT PersonalFolderName FROM tbConfiguration) + '%'
and (parent_owner.userid <> u.UserId or fu.userid <>u.userid)
