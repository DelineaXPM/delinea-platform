SELECT
	'[' + s.SecretName + ']' AS [Secret Name in Brackets]
	,s.SecretID
	,s.SecretName
	,f.FolderPath

FROM tbSecret s

LEFT JOIN tbFolder f ON s.FolderID = f.FolderID

WHERE (s.SecretName LIKE ' %' OR s.SecretName LIKE '% ')
	AND s.Active = 1

/*
.PURPOSE
Identify active secrets whose names start or end with a space. Clean these up pre-migration.
*/
