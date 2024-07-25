SELECT
	s.SecretID
	,f.FolderPath
	,s.SecretName
FROM tbFolder f

INNER JOIN tbFolderACL fl ON f.FolderID = fl.FolderID
INNER JOIN tbUserGroup ug ON fl.GroupID = ug.GroupID
INNER JOIN tbuser u ON ug.UserID = u.UserId
INNER JOIN tbSecret s ON f.FolderID = s.FolderId

WHERE f.FolderPath LIKE '%Personal Folders\%' AND s.Active = 1 AND u.Enabled = 0

/*
.PURPOSE
Pulls a list of Active secrets in Personal Folders belonging to Inactive users. These will error on migration as the Personal Folders will not exist for inactive users on the target. 

Either deactivate secrets in this report, or move them to a separate folder, pre-migration. 
*/