SELECT
	s.SecretId AS [SecretId]
	,s.created AS [Created]
	,s.secretname AS [Secret Name]
	,ISNULL(f.FolderPath, 'No folder assigned') AS [Folder Path]

FROM   tbsecret s 

LEFT JOIN tbfolder f ON s.folderid = f.folderid 
INNER JOIN tbSecretType st ON s.SecretTypeID = st.SecretTypeID

WHERE st.Active = 0 AND s.Active = 1

ORDER  BY created DESC

/*
.PURPOSE
Returns a list of Active Secrets using Inactive Templates. The templates must be active to be auto-migrated.  
*/