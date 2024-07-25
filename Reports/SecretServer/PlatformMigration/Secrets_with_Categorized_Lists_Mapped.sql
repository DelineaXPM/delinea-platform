SELECT
	ISNULL(f.FolderPath, 'No folder assigned') AS [Folder Path]
	,s.SecretID AS [SecretId]
	,s.SecretName AS [Secret Name]
	,cl.Name AS [List]

FROM tbSecret s

LEFT JOIN tbfolder f ON s.FolderId = f.FolderID
INNER JOIN tbSecretItem si ON si.SecretID = s.SecretID
LEFT JOIN tbcategorizedlist AS cl ON CAST(cl.CategorizedListId AS NVARCHAR(50)) = si.ItemValue

WHERE s.Active = 1 AND cl.Active = 1

/*
.PURPOSE
Pulls a list of secrets using categorized lists. Useful to identify this usecase pre-migration and to make sure these settings are applied correctly between instances, post-migration. 
*/