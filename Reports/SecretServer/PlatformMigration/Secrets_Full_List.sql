SELECT  
	s.SecretId AS [SecretId]
	,s.created AS [Created]
	,ISNULL(f.FolderPath, 'No folder assigned') AS [Folder Path]
	,s.secretname AS [Secret Name]
	,CONCAT(f.folderpath, '\', s.secretname) AS [Concatenated Value]

FROM   tbsecret s 

LEFT JOIN tbfolder f ON s.folderid = f.folderid 

WHERE	s.active = 1

ORDER  BY folderpath ASC 

/*
.PURPOSE
Returns a full list of active secrets. The "Concatenated Value" column is useful for sorting and running a diff between source and destination instances to identify what hasn't migrated or what got duplicated. This is especially useful in instances where duplicates are allowed, the Folder+Secret string helps make the entries more unique. 
*/