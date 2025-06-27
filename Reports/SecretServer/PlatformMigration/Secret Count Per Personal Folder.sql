SELECT f.folderid,
    f.FolderPath,
    vdn.DisplayName + ' (' + u.UserName + ') (UserID: ' + CAST(u.UserId AS VARCHAR) + ')' AS UserInfo,
    CASE 
        WHEN u.Enabled = 1 THEN 'Enabled'
        ELSE 'Disabled'
    END AS UserAccountStatus,
    COUNT(s.SecretID) AS ActiveSecretCount
FROM tbFolder f
FULL OUTER JOIN tbUser u ON u.UserId = f.UserId
JOIN vUserDisplayName vdn ON vdn.UserId = u.UserId
LEFT JOIN tbSecret s ON s.FolderId IN (
    SELECT f2.FolderID 
    FROM tbFolder f2 
    WHERE f2.FolderPath LIKE f.FolderPath + '%'
) AND s.Active = 1
WHERE f.IsSystemFolder = 1 
    AND f.UserId IS NOT NULL
GROUP BY 
    f.FolderPath,
    f.FolderID,
    u.UserId,
    u.UserName,
    vdn.DisplayName,
    u.Enabled
ORDER BY UserAccountStatus,ActiveSecretCount desc

/* This report lists all personal folders, the assocaited user's inforamtion, whether the user is enabled, and hte count of active secrets */
