SELECT 
    sf.FolderPath,
    vdn.DisplayName + ' (' + u.UserName + ') (UserID: ' + CAST(u.UserId AS VARCHAR) + ')' AS UserInfo,
    CASE 
        WHEN u.Enabled = 1 THEN 'Enabled'
        ELSE 'Disabled'
    END AS AccountStatus,
    s.SecretID,
    s.SecretName,
    st.SecretTypeName,
    s.Created,
    s.LastSuccessfulPasswordChangeDate
FROM tbFolder f
INNER JOIN tbUser u ON u.UserId = f.UserId
JOIN vUserDisplayName vdn ON vdn.UserId = u.UserId
INNER JOIN tbSecret s ON s.FolderId IN (
    SELECT f2.FolderID 
    FROM tbFolder f2 
    WHERE f2.FolderPath LIKE f.FolderPath + '%'
) AND s.Active = 1
INNER JOIN tbFolder sf ON s.FolderId = sf.FolderID
LEFT JOIN tbSecretType st ON s.SecretTypeID = st.SecretTypeID
WHERE f.IsSystemFolder = 1 
    AND f.UserId IS NOT NULL
    AND u.Enabled = 0
ORDER BY vdn.DisplayName, sf.FolderPath, s.SecretName

/*
.PURPOSE
Pulls a list of Active secrets in Personal Folders belonging to Inactive users. These will error on migration as the Personal Folders will not exist for inactive users on the target. 

Either deactivate secrets in this report, or move them to a separate folder, pre-migration. 
*/
