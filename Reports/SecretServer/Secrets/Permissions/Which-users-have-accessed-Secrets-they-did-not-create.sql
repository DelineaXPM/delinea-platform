SELECT usercreator.DisplayName AS 'Secret Creator',
    s.SecretName AS 'Secret Name',
    auditview.Action AS 'Action',
    auditview.DateRecorded AS 'Action Date',
    userviewer.DisplayName AS 'Secret Viewer',
    CASE
        WHEN MAX(gsp.ViewPermission) + MAX(gsp.EditPermission) + MAX(gsp.OwnerPermission) >= 3 THEN 'View/Edit/Owner'
        WHEN MAX(gsp.ViewPermission) + MAX(gsp.EditPermission) + MAX(gsp.OwnerPermission) >= 2 THEN 'View/Edit'
        WHEN MAX(gsp.ViewPermission) + MAX(gsp.EditPermission) + MAX(gsp.OwnerPermission) >= 1 THEN 'View'
        ELSE 'None'
    END AS 'Permissions'
    FROM tbAuditSecret auditcreate WITH (NOLOCK)
    INNER JOIN tbSecret s WITH (NOLOCK)
        ON s.SecretID = auditcreate.SecretId
    INNER JOIN vUserDisplayName usercreator WITH (NOLOCK)
        ON usercreator.UserId = auditcreate.UserId
    INNER JOIN tbAuditSecret auditview WITH (NOLOCK)
        ON auditview.[Action] <> 'CREATE' AND s.SecretID = auditview.SecretId
            AND auditview.SecretId = auditcreate.SecretId
            AND auditview.UserId <> auditcreate.UserId
    INNER JOIN vUserDisplayName userviewer WITH (NOLOCK)
        ON userviewer.UserId = auditview.UserId
    INNER JOIN tbUserGroup ug WITH (NOLOCK)
        ON userviewer.UserId = ug.UserID
    LEFT JOIN vGroupSecretPermissions gsp WITH (NOLOCK)
        ON gsp.GroupId = ug.GroupID AND gsp.SecretId = s.SecretId     
    WHERE auditcreate.[Action] = 'CREATE'
    AND auditcreate.UserId = #USER
    AND auditview.DateRecorded >= #STARTDATE
    AND auditview.DateRecorded <= #ENDDATE
    GROUP BY usercreator.DisplayName, s.SecretName, auditview.Action, auditview.DateRecorded,
        userviewer.DisplayName
    ORDER BY 1,2,3,4,5,6
