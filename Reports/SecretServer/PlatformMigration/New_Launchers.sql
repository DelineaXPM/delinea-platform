SELECT DISTINCT
	a.DateRecorded AS [Date]
	,u.DisplayName AS [Display Name]
	,a.Action AS [Event]
	,lt.Name AS [Launcher]

FROM tbAudit a

INNER JOIN tbUser u ON a.UserId = u.UserId
INNER JOIN tbLauncherType lt ON a.ItemId = lt.LauncherTypeId

WHERE lt.Active = 1 AND (a.AuditTypeID = 4 AND a.Action LIKE '%EATE')

/*
.PURPOSE
Returns a full list of newly created, custom launchers. 
*/
