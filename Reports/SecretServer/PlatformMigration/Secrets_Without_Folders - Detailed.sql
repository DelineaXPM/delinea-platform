SELECT DISTINCT
	s.SecretId AS [Secret ID]
        ,s.SecretName AS [Secret Name]
	,ISNULL(f.FolderPath, 'No folder assigned') as [Folder Path]
        ,st.SecretTypeName AS [Secret Template]
        ,gsp.[Permissions]
        ,gdn.DisplayName AS [Access Group]
	,udn.DisplayName AS [Display Name]
        ,
	CASE gsp.[Inherit Permissions]
            WHEN 'No' THEN 'Secret'
            WHEN 'Yes' THEN (
                CASE f.EnableInheritPermissions
                    WHEN NULL THEN 'Folder'
                    WHEN 1 THEN 'A Parent Folder'
                    WHEN 0 THEN 'Folder'
                END)
        END AS [Permissions On]

FROM tbSecret s WITH (NOLOCK)

INNER JOIN vGroupSecretPermissions gsp ON s.SecretID = gsp.SecretId  
INNER JOIN tbUserGroup ug WITH (NOLOCK) ON gsp.GroupId = ug.GroupId
INNER JOIN tbSecretType st WITH (NOLOCK) ON s.SecretTypeId = st.SecretTypeId
LEFT JOIN tbFolder f WITH (NOLOCK) ON s.FolderId = f.FolderId
INNER JOIN vUserDisplayName udn WITH (NOLOCK) ON udn.UserId = ug.UserId
INNER JOIN tbUser u WITH (NOLOCK) ON u.UserId = ug.UserId
INNER JOIN vGroupDisplayName gdn WITH (NOLOCK) ON gsp.GroupId = gdn.GroupId   

    
WHERE s.Active = 1 AND s.FolderId IS NULL AND gsp.[Permissions] LIKE '%Owner%'
    
ORDER BY 1,2,3,4,5,6,7,8

/*
.PURPOSE
Return list of active secrets in the root folder along with users and/or groups with Owner access. Identifying the owners of secrets in the root folder may help identify where to move the secret.  
*/
