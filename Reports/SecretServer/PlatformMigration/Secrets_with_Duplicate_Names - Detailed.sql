SELECT DISTINCT
	s.SecretId
        ,s.SecretName AS [Secret Name]
	,ISNULL(f.FolderPath, N'No folder assigned') as [Folder Path]
        ,st.SecretTypeName AS [Secret Template]
        	
        ,gdn.DisplayName AS 'Access Group'
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
JOIN (SELECT  SecretName, COUNT(SecretName) as [Total] 
	FROM tbsecret t
	WHERE t.active = 1
	GROUP BY SecretName 
	Having COUNT(SecretName) > 1)

t ON s.SecretName = t.SecretName
    
WHERE s.Active = 1 AND gsp.[Permissions] LIKE '%Owner%'
    
ORDER BY 1,2,3,4,5,6,7

/*
.PURPOSE
Returns a list of secrets with duplicate names along with who has ownership of the duplicate secret. This may be useful in determining which secret is authoritative, or who to contact to rename it to something unique. If a secret has multiple owners, or a group owner with multiple people, it will be listed multiple times. Do not use this report to get a count of duplicate secrets.  
*/