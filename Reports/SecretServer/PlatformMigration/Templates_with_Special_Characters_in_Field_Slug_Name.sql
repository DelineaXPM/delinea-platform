SELECT 
	st.SecretTypeName AS [Template]
	,sf.SecretFieldName AS [Field]
	,sf.FieldSlugName AS [Slug Name]

FROM tbSecretType st

INNER JOIN tbSecretField sf ON st.SecretTypeID = sf.SecretTypeID

WHERE sf.FieldSlugName like '%[^a-Z0-9-]%'

/*
.PURPOSE
Return all secret templates containing a slug name with a special character, other than a dash.
Old versions of Secret Server allowed other characters in the slug name, these will get stripped out and replcaed with a dash upon template migration.
Remove slug field names with special characters other than a dash, pre-migration.
*/
