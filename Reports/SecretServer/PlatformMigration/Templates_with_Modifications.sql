SELECT
	a.DateRecorded AS [Date]
	,a.ItemId AS [Template ID]
	,a.Action AS [Event]
	,st.SecretTypeName AS [Template]
	,a.Notes AS [Notes]

FROM tbAudit a

INNER JOIN tbSecretType st ON a.ItemId = st.SecretTypeID

WHERE (st.Active = 1 AND a.AuditTypeId = 3 AND a.UserId <> 1)
AND NOT EXISTS (SELECT
	b.Action
FROM tbAudit b

WHERE b.itemid = a.itemid AND b.Action LIKE '%EATE')

ORDER BY "Template ID" ASC

/*
.PURPOSE
Returns a list of any built-in, active templates with modifications. Modifications made to built-in templates will need to be mirrored on the target instance, pre-migration. 
*/
