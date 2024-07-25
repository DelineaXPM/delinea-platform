SELECT
	f.folderpath AS [Location]

FROM   tbfolder f 

WHERE f.FolderPath LIKE '%PERSONAL Folders\%\%'

/*
.PURPOSE
Identifies any sub-folders underneath Personal Folders. These sub-folders are not auto-created and therefore must be created manually on the target instance, pre-migration. 
*/