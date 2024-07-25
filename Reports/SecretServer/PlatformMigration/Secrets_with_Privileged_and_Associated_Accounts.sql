SELECT 
	s.SecretId AS [SecretId]
	,s.SecretName AS [Secret Name]
	,ISNULL(f.FolderPath, 'No folder assigned') AS [Folder Path]
	,srs.ResetSecretId AS [PrivAcct ID]
	,s1.SecretName AS [Priv Acct Name]
	,st.SecretTypeName AS [Template]


FROM tbSecretResetSecrets srs

INNER JOIN tbsecret s ON s.SecretID = srs.SecretId
INNER JOIN tbsecret s1 ON s1.SecretID = srs.ResetSecretId
LEFT JOIN tbfolder f ON s.FolderId = f.FolderID
INNER JOIN tbSecretType st ON s.SecretTypeID = st.SecretTypeID

WHERE (s.Active = 1 AND s.SecretPolicyId IS NULL)

/*
.PURPOSE
Returns a list of secrets with associated privileged accounts. This is useful for comparing privileged account assignments between instances for accuracy, post-migration. 
*/