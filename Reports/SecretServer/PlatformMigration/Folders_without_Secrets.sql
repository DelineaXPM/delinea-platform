SELECT
	f.FolderPath AS [Folder Path]
	
FROM tbFolder f

WHERE f.FolderId NOT IN
	(
    SELECT s.folderID from tbsecret s
    WHERE s.FolderID = f.FolderID
	)
	
/*
.PURPOSE
Identify empty folders. Sometimes this is expected if it is a parent folder meant to organize sub-folders. 
*/