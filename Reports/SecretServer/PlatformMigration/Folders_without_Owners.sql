SELECT DISTINCT
	f.FolderID AS [Folder ID]
	,f.FolderPath AS [Folder Path]

FROM vGroupFolderPermissions gfp

INNER JOIN tbUserGroup ug on gfp.GroupId = ug.GroupID
INNER JOIN tbuser u on ug.UserID = u.UserId
INNER JOIN tbFolder f on gfp.FolderId = f.FolderID
INNER JOIN tbGroup g on ug.GroupID = g.GroupID

WHERE u.Enabled = 1 AND f.FolderPath NOT LIKE '\Personal Folders' AND (f.FolderID NOT IN (SELECT gfp2.FolderId FROM vGroupFolderPermissions gfp2 
INNER JOIN tbgroup g2 ON gfp2.GroupId = g2.GroupID
INNER JOIN tbUserGroup ug2 on gfp2.GroupId = ug2.GroupID
INNER JOIN tbuser u2 on ug2.UserID = u2.UserId
WHERE gfp2.OwnerPermission = 1 AND u2.Enabled = 1))

ORDER BY f.FolderID ASC

/*
.PURPOSE
Identify folders without any assigned user or group owner. 
*/