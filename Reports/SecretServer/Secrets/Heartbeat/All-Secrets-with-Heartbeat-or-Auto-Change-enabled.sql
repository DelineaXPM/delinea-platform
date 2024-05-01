/* All Active Secrets with Heartbeat or Auto Change enabled, sorted by folder path */

SELECT
	s.SecretID AS [Secret ID]
	,s.SecretName AS [Secret Name]
	,st.SecretTypeName AS [Template]
	,f.FolderPath AS [Folder Path]
	,CASE WHEN s.AutoChangeOnExpiration=1 THEN 'TRUE'
		ELSE 'FALSE' END AS [AutoChange Enabled]
	,CASE WHEN st.EnableHeartBeat !=0 AND s.LastHeartBeatStatus !=3 THEN 'TRUE'
		ELSE 'FALSE' END AS [Heartbeat Enabled]
FROM tbSecret s
JOIN tbSecretType st
	ON s.SecretTypeID = st.SecretTypeID
JOIN tbFolder f
	ON s.FolderID = f.FolderID
WHERE s.Active = 1
AND	(s.SecretID IN
		(SELECT s.SecretID
		 FROM tbSecret s
		 WHERE s.AutoChangeOnExpiration=1)
	 OR s.SecretID IN
		 (SELECT s.SecretID
		  FROM tbSecret s
		  JOIN tbSecretType st
		 	ON s.SecretTypeID = st.SecretTypeID
		  WHERE st.EnableHeartBeat !=0 AND s.LastHeartBeatStatus !=3)
	)
ORDER BY f.FolderPath ASC
