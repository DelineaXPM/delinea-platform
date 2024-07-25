SELECT s.secretid,
    s.SecretName,
    s.secretid as [SecretIDNumber],
    ISNULL(f.FolderPath, N'No folder assigned') as [Folder Path],
    st.secrettypename,
	a.FileName,
	cast(round((a.FileSize/1024.0),2) as decimal(10,2)) as [File Size Kb],
	a.LastModifiedDate
FROM tbSecret AS s
    INNER JOIN tbSecretItem AS i ON i.SecretID = s.SecretID
    INNER JOIN tbFileAttachment a ON i.FileAttachmentId = a.FileAttachmentId
    LEFT JOIN tbFolder f WITH (NOLOCK) ON s.FolderId = f.FolderId
    INNER JOIN tbSecretType st WITH (NOLOCK) ON s.SecretTypeId = st.SecretTypeId
WHERE i.FileAttachmentId IS NOT NULL
    AND s.Active = 1
    AND st.OrganizationId = 1
    AND a.IsDeleted = 0
