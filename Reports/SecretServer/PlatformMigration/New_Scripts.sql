SELECT DISTINCT
	a.DateRecorded AS [Date]
	,u.DisplayName AS [Display Name]
	,a.Action AS [Event]
	,sc.Name AS [Script]
	,sct.Name AS [Script Type]
	

FROM tbAudit a

INNER JOIN tbUser u ON a.UserId = u.UserId
INNER JOIN tbScript sc ON a.ItemId = sc.ScriptId
INNER JOIN tbScriptType sct ON sc.ScriptTypeId = sct.ScriptTypeId

WHERE sc.Active = 1 AND (a.AuditTypeID = 5 AND a.Action LIKE '%EATE')

/*
.PURPOSE
Returns a list of all newly created, custom scripts (SQL, PowerShell, and/or Shell script).
*/
