SELECT DISTINCT
	pra.Date AS [Date]
	,u.DisplayName AS [Display Name]
	,pra.Action AS [Event]
	,pr.Name AS [Password Requirement]
	

FROM tbPasswordRequirementAudit pra

INNER JOIN tbUser u ON pra.UserId = u.UserId
INNER JOIN tbPasswordRequirement pr ON pra.PasswordRequirementId = pr.PasswordRequirementId

WHERE pra.Action LIKE '%EATE'

/*
.PURPOSE
Returns a list of all newly created, custom password requirements. 
*/
