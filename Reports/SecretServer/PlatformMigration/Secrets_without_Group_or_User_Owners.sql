SELECT 
	st.SecretTypeName
	,ISNULL(f.FolderPath, 'No folder assigned') AS FolderPath
	,s.secretid
	,s.secretname
	,audit_latest.MaxDate AS LatestViewDate
	,u_audit.DisplayName AS LatestViewUsername
	,s.Created AS Created
	,isnull(s.LastSuccessfulPasswordChangeDate,s.created) as [Password Last Set]
FROM tbSecret s
LEFT JOIN tbSecretType st ON s.SecretTypeId = st.SecretTypeId
LEFT JOIN tbFolder f ON s.FolderId = f.FolderId
LEFT JOIN (
	SELECT SecretID, MAX(DateRecorded) AS MaxDate, UserId
	FROM tbAuditSecret
	WHERE Action = 'VIEW'
	GROUP BY SecretID, UserId
) audit_latest ON s.SecretId = audit_latest.SecretID
LEFT JOIN tbUser u_audit ON audit_latest.UserId = u_audit.UserId
WHERE s.active = 1 
	AND s.secretid NOT IN (
		SELECT s.[SecretId]
		FROM dbo.tbSecretACL acl WITH (NOLOCK)
		JOIN dbo.tbSecret s WITH (NOLOCK) ON s.SecretID = acl.SecretID AND s.Active = 1
		JOIN dbo.tbUserGroup ug WITH (NOLOCK) ON acl.[GroupID] = ug.[GroupID]
		JOIN dbo.tbUser u WITH (NOLOCK) ON ug.[UserID] = u.[UserId] AND u.enabled = 1
		WHERE acl.permissions = 15
	)
