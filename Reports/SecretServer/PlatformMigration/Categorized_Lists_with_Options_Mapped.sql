SELECT
	cl.Name AS [List]
	,li.Category AS [Category]
	,li.Value AS [Option]

FROM tbSecret s

INNER JOIN tbSecretItem si ON si.SecretID = s.SecretID
LEFT JOIN tbcategorizedlist AS cl ON CAST(cl.CategorizedListId AS NVARCHAR(50)) = si.ItemValue 
INNER JOIN tbCategorizedListItem li ON cl.CategorizedListId = li.CategorizedListId

WHERE cl.Active = 1

/*
.PURPOSE
Pull all categorized lists along with their associated options. 
*/
