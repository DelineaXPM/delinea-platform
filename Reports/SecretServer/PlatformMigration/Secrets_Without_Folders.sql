SELECT
	s.SecretId
	,s.SecretName as [Secret]
	,st.SecretTypeName as [Template]
	,
	CASE 
		WHEN s.FolderId IS NULL THEN 'No Folder'
	END AS [Folder]


FROM tbSecret s

INNER JOIN tbSecretType st on s.SecretTypeID = st.SecretTypeID

WHERE s.FolderId IS NULL AND s.Active=1

/*
.PURPOSE
Return a list of active secrets in the root folder. 
*/
