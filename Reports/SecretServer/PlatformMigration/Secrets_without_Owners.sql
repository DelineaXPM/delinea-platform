SELECT DISTINCT
	s.SecretID AS [SecretID]
	,ISNULL(f.FolderPath, 'No folder assigned') AS [Folder Path]
	,s.SecretName AS [Secret Name]


FROM vGroupSecretPermissions gsp

INNER JOIN tbUserGroup ug ON gsp.GroupId = ug.GroupID
INNER JOIN tbuser u ON ug.UserID = u.UserId
INNER JOIN tbSecret s ON gsp.SecretId = s.SecretId
LEFT JOIN tbFolder f ON s.FolderId = f.FolderID
INNER JOIN tbGroup g ON ug.GroupID = g.GroupID

WHERE s.Active = 1  AND u.Enabled = 1 AND (s.SecretID NOT IN (SELECT gsp2.SecretID FROM vGroupSecretPermissions gsp2 
INNER JOIN tbgroup g2 ON gsp2.GroupId = g2.GroupID
INNER JOIN tbUserGroup ug2 ON gsp2.GroupId = ug2.GroupID
INNER JOIN tbuser u2 ON ug2.UserID = u2.UserId
WHERE gsp2.OwnerPermission = 1 AND u2.Enabled = 1))

ORDER BY s.SecretID ASC

/*
.PURPOSE
Returns a list of active secrets without an owner. 
*/
