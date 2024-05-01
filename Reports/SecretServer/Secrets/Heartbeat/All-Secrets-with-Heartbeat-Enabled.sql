/* All Active Secrets with Heartbeat enabled, sorted by folder path */

SELECT
	s.SecretID AS [Secret ID]
	,s.SecretName AS [Secret Name]
	,st.SecretTypeName AS [Template]
	,f.FolderPath AS [Folder Path]
FROM tbSecret s
JOIN tbSecretType st
	ON s.SecretTypeID = st.SecretTypeID
JOIN tbFolder f
	ON s.FolderID = f.FolderID
WHERE s.Active = 1
AND s.LastHeartBeatStatus != 3
AND st.EnableHeartBeat != 0
ORDER BY f.FolderPath ASC
