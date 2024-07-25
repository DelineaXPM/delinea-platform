SELECT DISTINCT
	a.DateRecorded AS [Date]
	,u.DisplayName AS [Display Name]
	,a.Action AS [Event]
	,st.SecretTypeName AS [Template]
	,a.ItemId AS [Template ID]
	,(SELECT count(s.SecretTypeID) FROM tbsecret s WHERE s.SecretTypeID = st.SecretTypeID) AS [Secret Count]

FROM tbAudit a

INNER JOIN tbUser u ON a.UserId = u.UserId
INNER JOIN tbSecretType st ON a.ItemId = st.SecretTypeID

WHERE st.Active = 1 AND (a.AuditTypeID = 3 AND a.Action LIKE '%EATE')

/*
.PURPOSE
Returns a list of all newly created, active custom templates. 
*/
