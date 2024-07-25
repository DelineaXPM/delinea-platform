
SELECT 
	f.FolderID AS [Folder ID]
	,f.folderpath AS [Folder Path] 
	,LEN(fs.secrets) - LEN(REPLACE(fs.secrets, ',', ''))+1 AS [Secret_Count]

FROM tbfolder f

INNER JOIN vFolderSecret fs on f.FolderID = fs.folderId 

/*
.PURPOSE
List all folders and give a secret count for each. 
*/