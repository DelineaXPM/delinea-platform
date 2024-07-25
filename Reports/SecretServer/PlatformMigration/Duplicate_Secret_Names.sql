SELECT  
	s.SecretID AS [SecretID]
	,ISNULL(f.FolderPath, 'No folder assigned') AS [Folder Path]
	,s.secretname AS [Secret Name]
	,st.secrettypename AS [Type]

FROM tbsecret s 

JOIN (SELECT  SecretName, COUNT(SecretName) AS [Total] 
	FROM tbsecret t
	WHERE t.active = 1
	GROUP BY SecretName 
	Having COUNT(SecretName) > 1)

t ON s.SecretName = t.SecretName

LEFT JOIN tbfolder f ON s.folderid = f.folderid 
INNER JOIN tbsecrettype st ON s.secrettypeid = st.secrettypeid

WHERE s.active = 1

GROUP BY s.SecretName, f.FolderPath, s.FolderId, s.SecretID, st.secrettypename

/*
.PURPOSE
Returns a list of active secrets with duplicate names. Ideally these will get unique names, pre-migration.  
*/