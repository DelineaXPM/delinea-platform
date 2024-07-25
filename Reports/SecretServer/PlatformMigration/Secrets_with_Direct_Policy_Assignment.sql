SELECT 
	s.SecretId AS [SecretId]
	,s.SecretName AS [Secret Name]
	,ISNULL(f.FolderPath, 'No folder assigned') AS [Folder Path]
	,sp.SecretPolicyName AS [Policy]

FROM tbSecret s

LEFT JOIN tbfolder f ON s.FolderId = f.FolderID
INNER JOIN tbSecretPolicy sp ON s.SecretPolicyId = sp.SecretPolicyId

WHERE s.Active = 1 AND s.EnableInheritSecretPolicy = 0 AND s.SecretPolicyId IS NOT NULL

/*
.PURPOSE
Returns a list of active secrets with policies directly assigned. Useful for validating successful policy application between instances, post-migration.
*/
