SELECT 
    U.UserId,
    U.username as [ManagedUser],
    U.DisplayName as [ManagedUserDisplayName],
    G.GroupName as [ManagedBy],
    G.GroupID as [ManagedByGroupId],
    U.Enabled as [UserEnabled],
    U.LastLogin as [UserLastLogin]
FROM [tbEntityOwnerPermission] EOP
    INNER JOIN tbuser U ON U.userid = EOP.OwnedEntityId
    INNER JOIN tbGroup G ON EOP.GroupId = G.GroupID
WHERE 
    EOP.roleid = 14 
    AND U.Enabled = 1
ORDER BY 
    U.username

-- Users with custom ownership - Detailed report
