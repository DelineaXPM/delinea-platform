SELECT
	st.SecretTypeID AS [Template ID]
	,st.SecretTypeName AS [Template Name]
	,pt.Name AS [Password Changer]

FROM tbSecretType st

INNER JOIN tbPasswordType pt ON st.PasswordTypeId = pt.PasswordTypeId

WHERE st.Active = 1

/*
.PURPOSE
Returns a list of active secret templates with associated password changers mapped. Useful to compare mappings between instances and ensure the password changers match on both built-in and custom templates. 
*/
