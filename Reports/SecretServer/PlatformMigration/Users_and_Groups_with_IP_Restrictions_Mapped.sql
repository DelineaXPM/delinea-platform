SELECT
	ipr.IPAddressRangeId AS [Range ID]
	,ipr.Range AS [IP Range]
	,u.UserName [Applied to]
	,CASE WHEN u.UserId = uip.UserId THEN 'Account' END AS [Object Type]

FROM tbIPAddressRange ipr

INNER JOIN tbUserIPAddress uip on ipr.IPAddressRangeId = uip.IPAddressRangeId
INNER JOIN tbUser u on uip.UserId = u.UserId

UNION ALL

SELECT 
	ipr.IPAddressRangeId AS [Range ID]
	,ipr.Range AS [IP Range]
	,g.GroupName
	,CASE WHEN g.groupid = gp.groupid THEN 'Group' END AS [Object Type]

FROM tbIPAddressRange ipr

INNER JOIN tbGroupIPAddress gp on ipr.IPAddressRangeId = gp.IPAddressRangeId
INNER JOIN tbGroup g on gp.GroupId = g.GroupID

/*
.PURPOSE
Returns a list of active users and groups with IP restrictions. These will likely need to be mirrored on the target instance. Note if the target is cloud, Internal IPs will not work.  
*/

