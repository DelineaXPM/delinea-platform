SELECT DISTINCT
    f.FolderID       AS [Folder ID],
    f.FolderPath     AS [Folder Path]
FROM vGroupFolderPermissions gfp
INNER JOIN tbUserGroup ug 
    ON gfp.GroupId = ug.GroupID
INNER JOIN tbUser u 
    ON ug.UserID   = u.UserId
INNER JOIN tbFolder f 
    ON gfp.FolderId = f.FolderID
INNER JOIN tbGroup g 
    ON ug.GroupID  = g.GroupID
WHERE 
    u.Enabled = 1
    AND f.issystemfolder = 0
    AND f.FolderID NOT IN (
        SELECT gfp2.FolderId
        FROM vGroupFolderPermissions gfp2
        INNER JOIN tbGroup     g2  ON gfp2.GroupId = g2.GroupID
        INNER JOIN tbUserGroup ug2 ON gfp2.GroupId = ug2.GroupID
        INNER JOIN tbUser      u2  ON ug2.UserID   = u2.UserId
        WHERE gfp2.OwnerPermission = 1
          AND u2.Enabled = 1
    )
ORDER BY 
    f.FolderID ASC

/*
.PURPOSE
Identify folders without any owners. 
*/
