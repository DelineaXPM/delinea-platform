SELECT 
	st.SecretTypeName AS [Secret Type]
	,lt.Name AS [Launcher Type]

FROM tbSecretType st

INNER Join tbSecretTypeLauncher stl ON stl.SecretTypeId = st.SecretTypeID
INNER JOIN tbLauncherType lt ON lt.LauncherTypeId = stl.LauncherTypeId

WHERE st.Active = 1

/*
.PURPOSE
Returns a list of all Secret Templates with associated launcher(s) mapped. Useful to compare between instances to ensure mappings are identical. 
*/