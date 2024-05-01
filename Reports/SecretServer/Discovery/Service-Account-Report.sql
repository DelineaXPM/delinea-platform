SELECT 
    cd.AccountDomain AS 'Domain',
    o.OrganizationUnitName AS 'Organization Unit',
    o.DistinguishedName AS 'Distinguished Name',
    cd.AccountName AS 'Account',
    c.ComputerName AS 'Host Name',
    cd.DependencyName AS 'Dependency Name',
    sdt.SecretDependencyTypeName AS 'Dependency Type',
    SDTM.SecretDependencyTemplateName AS 'Dependency Template Name',
    CONVERT(VARCHAR(20),c.LastPolledDate,107) AS 'Last Scanned'
FROM 
        tbComputer c
    JOIN    tbComputerDependency cd 
    ON 
        cd.ComputerID = c.ComputerId
    JOIN    tbSecretDependencyType sdt
    ON 
        sdt.SecretDependencyTypeId = cd.SecretDependencyTypeID
        
    JOIN tbSecretDependencyTemplate sdtm
    
    ON  
        cd.ScanItemTemplateId = sdtm.ScanItemTemplateId
    AND 
        cd.SecretDependencyTypeID = sdtm.SecretDependencyTypeId
    JOIN tbOrganizationUnit o
    on c.DiscoverySourceId = o.DiscoverySourceId
    ORDER BY cd.AccountName, o.OrganizationUnitName, o.DistinguishedName asc
