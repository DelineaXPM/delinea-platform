SELECT
	CASE
		WHEN s.FolderId IS NULL THEN 'No Folder'
		ELSE f.FolderPath
		END AS [Folder Path]
	,s.SecretID AS [SecretId]
	,s.SecretName AS [Secret Name]
	,cl.Name AS [List]
	,li.Category AS [Category]
	,li.Value AS [Option]

FROM tbSecret s

FULL JOIN tbfolder f ON s.FolderId = f.FolderID
INNER JOIN tbSecretItem si ON si.SecretID = s.SecretID
LEFT JOIN tbcategorizedlist AS cl ON CAST(cl.CategorizedListId AS NVARCHAR(50)) = si.ItemValue 
INNER JOIN tbCategorizedListItem li ON cl.CategorizedListId = li.CategorizedListId

WHERE s.Active = 1 AND cl.Active = 1

/*
.PURPOSE
Pulls a list of secrets using categorized lists along with the associated options. Useful to make sure these settings are applied correctly between instances, post-migration. 
*/
