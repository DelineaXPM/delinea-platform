SELECT DISTINCT
	pta.Date AS [Date]
	,u.DisplayName AS [Display Name]
	,pta.Action AS [Event]
	,pt.Name AS [Password Changer]
	

FROM tbPasswordTypeAudit pta

INNER JOIN tbUser u ON pta.UserId = u.UserId
INNER JOIN tbPasswordType pt ON pta.PasswordTypeId = pt.PasswordTypeId

WHERE pt.Active = 1 AND pta.Action LIKE '%EATE' AND pta.Notes NOT LIKE '%Pass%'

/*
.PURPOSE
Returns a list of all newly created, custom password changers. 
*/
