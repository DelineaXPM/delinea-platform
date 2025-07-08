SELECT 
    MID.ItemId,
    CASE 
        WHEN S.SecretName IS NOT NULL THEN 'Secret'
        WHEN F.FolderPath IS NOT NULL THEN 'Folder'
        ELSE 'Unknown'
    END as ItemType,
    COALESCE(S.SecretName, F.FolderPath) as ItemName,
    MID.CreateUserId,
    U.Username as CreatedByUser,
    MID.CreateDateTime,
    CASE 
        WHEN MID.ValueString IS NOT NULL THEN MID.ValueString
        WHEN MID.ValueBit IS NOT NULL THEN CAST(MID.ValueBit AS VARCHAR(10))
        WHEN MID.ValueNumber IS NOT NULL THEN CAST(MID.ValueNumber AS VARCHAR(50))
        WHEN MID.ValueDateTime IS NOT NULL THEN CAST(MID.ValueDateTime AS VARCHAR(50))
        WHEN MID.ValueInt IS NOT NULL THEN CAST(MID.ValueInt AS VARCHAR(50))
        ELSE 'No Value'
    END as DisplayValue,
    CASE 
        WHEN MID.ValueString IS NOT NULL THEN 'String'
        WHEN MID.ValueBit IS NOT NULL THEN 'Boolean'
        WHEN MID.ValueNumber IS NOT NULL THEN 'Number'
        WHEN MID.ValueDateTime IS NOT NULL THEN 'DateTime'
        WHEN MID.ValueInt IS NOT NULL THEN 'Integer'
        ELSE 'Unknown'
    END as ValueType,
    MID.ContainsPersonalInformation,
    MID.LastModifiedDate
FROM tbMetadataItemData MID
    LEFT JOIN tbUser U ON U.UserId = MID.CreateUserId
    LEFT JOIN tbSecret S ON S.SecretID = MID.ItemId
    LEFT JOIN tbFolder F ON F.FolderId = MID.ItemId
ORDER BY 
    ItemType, COALESCE(S.SecretName, F.FolderPath), MID.CreateDateTime 
    
    
-- Metadata Items - Detailed report
