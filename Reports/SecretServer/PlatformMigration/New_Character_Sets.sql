SELECT DISTINCT
	csa.Date AS [Date]
	,u.DisplayName AS [Display Name]
	,csa.Action AS [Event]
	,cs.Name AS [Character Set]
	

FROM tbCharacterSetAudit csa

INNER JOIN tbUser u ON csa.UserId = u.UserId
INNER JOIN tbCharacterSet cs ON csa.CharacterSetId = cs.CharacterSetId

WHERE csa.Action LIKE '%EATE'

/*
.PURPOSE
Returns all newly created, custom character sets. 
*/
