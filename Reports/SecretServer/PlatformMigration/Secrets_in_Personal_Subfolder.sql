SELECT 
	s.SecretID AS [SecretId]
	,s.secretname AS [Secret Name]
	,f.folderpath AS [Location]

FROM   tbsecret s 

INNER JOIN tbfolder f ON s.folderid = f.folderid

WHERE s.Active = 1 AND f.FolderPath LIKE '%PERSONAL Folders\%\%'

ORDER  BY created DESC 

/*
.PURPOSE
Identifies any sub-folders containing secrets underneath Personal Folders. These sub-folders are not auto-created and therefore must be created manually on the target instance, pre-migration. 
*/

