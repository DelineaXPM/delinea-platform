SELECT
	s.SecretId,
	s.SecretName,
	st.SecretTypeName as [SecretTemplate],
	f.FolderPath,
	s.Created
FROM
	tbSecret s
	LEFT JOIN tbSecretType st on st.SecretTypeID = s.SecretTypeID
	LEFT JOIN tbFolder f on f.FolderId=s.FolderId
WHERE
	s.Created > GetDate() -7