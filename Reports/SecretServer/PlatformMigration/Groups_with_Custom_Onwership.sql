SELECT 
    tg.GroupID,
    tg.GroupName as [ManagedGroup],
    og.GroupName as [ManagedBy],
    og.GroupID as [ManagedByGroupId],
    tg.Active as [GroupActive]
FROM tbGroupOwnerPermission gop
    INNER JOIN tbgroup tg ON tg.GroupID = gop.OwnedGroupId
    INNER JOIN tbgroup og ON og.GroupID = gop.GroupId
WHERE 
    tg.Active = 1 
    AND og.Active = 1
ORDER BY 
    tg.GroupName
    
 -- Groups with custom ownership - Detailed report
