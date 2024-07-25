SELECT
	s.SecretID AS [SecretId]
	,s.SecretName AS [Secret]
	,ISNULL(f.FolderPath, 'No folder assigned') AS [Folder Path]
	,sd.ServiceName AS [Dependency Name]
	,sdt.SecretDependencyTypeName AS [Dependency Type]
	,sc.ScriptId AS [Script ID]
	,sc.Name AS [Script Name]


FROM tbSecret s

INNER JOIN tbSecretDependency sd ON s.SecretID = sd.SecretId
LEFT JOIN tbFolder f ON s.FolderId = f.FolderID
INNER JOIN tbSecretDependencyType sdt ON sd.SecretDependencyTypeId = sdt.SecretDependencyTypeId
INNER JOIN tbScript sc ON sd.ScriptId = sc.ScriptId

WHERE sd.SecretDependencyTypeId = 7 OR sd.SecretDependencyTypeId = 8 OR sd.SecretDependencyTypeId = 9

/*
.PURPOSE
Returns a list of active secrets with script dependencies. While XML migrations and the migration tool will migrate scripts and associate them as dependencies, the ID changes and the scripts won't run. Use this to identify secrets with scripts, post-migration, and remove/readd them so they have correct IDs. 
*/