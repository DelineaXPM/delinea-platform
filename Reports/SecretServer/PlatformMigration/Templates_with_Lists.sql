SELECT 
       st.SecretTypeID AS [Template ID]
       ,st.SecretTypeName AS [Template Name]
       ,sf.SecretFieldName AS [Field Name]
       ,sv.FieldValue AS [List Item]
       
FROM tbSecretType st

INNER JOIN tbSecretField sf ON st.SecretTypeID = sf.SecretTypeID
INNER JOIN tbSecretFieldValue sv ON sf.SecretFieldID = sv.SecretFieldId

WHERE st.Active = 1

/*
.PURPOSE
Returns a list of active templates using lists. These need to be identified so lists can be manually re-mapped during migration. 
*/
