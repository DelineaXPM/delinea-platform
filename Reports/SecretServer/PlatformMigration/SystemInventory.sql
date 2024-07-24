select inventory.result as [Item],'' as [Comment] from (
SELECT CONCAT('Secret Server Address: ', c.CustomURL) AS [Result] FROM tbConfiguration c
UNION ALL
SELECT CONCAT('Report Version: ', '1.1.20240709') as [Result]
UNION ALL 
SELECT CONCAT('Secret Server Version: ', "Version")
FROM (
        SELECT TOP 1 (v.VersionNumber) AS "Version"
        FROM tbversion v
        ORDER BY Upgraded DESC, v.VersionNumber DESC
    ) AS [Result]
UNION ALL
SELECT CONCAT('Number of Web Servers: ', COUNT(NodeId)) AS [Result] FROM tbNode n
UNION ALL
SELECT CONCAT('Number of Domains: ', COUNT(DomainId)) AS [Result] FROM tbDomain d
	WHERE d.Active = 1
UNION ALL
SELECT CONCAT(
        'Integrated Windows Auth: ',
        CASE
            WHEN c.IntegratedWindowsAuthentication = 0 THEN 'FALSE'
            WHEN c.IntegratedWindowsAuthentication = 1 THEN 'TRUE'
            ELSE NULL
        END
    ) AS [Result]
FROM tbConfiguration c
UNION ALL
SELECT CONCAT(
        'SAML Enabled: ',
        CASE
            WHEN sc.Enabled = 0 THEN 'FALSE'
            WHEN sc.Enabled = 1 THEN 'TRUE'
            ELSE NULL
        END
    ) AS [Result]
FROM tbSamlConfiguration sc
UNION ALL
SELECT CONCAT('Number of Users: ', COUNT(UserId)) AS [Result]
FROM tbuser u
WHERE u.Enabled = 1
UNION ALL
SELECT CONCAT('Number of Domain Users: ', COUNT(UserId)) AS [Result]
FROM tbuser u
WHERE u.Enabled = 1
    AND u.DomainId IS NOT NULL
UNION ALL
SELECT CONCAT('Number of Local Users: ', COUNT(UserId)) AS [Result]
FROM tbuser u
WHERE u.Enabled = 1
    AND u.DomainId IS NULL
UNION ALL
SELECT CONCAT(
        'Number of Application Accounts: ',
        COUNT(UserId)
    ) AS [Result]
FROM tbuser u
WHERE u.Enabled = 1
    AND u.IsApplicationAccount = 1
UNION ALL
SELECT CONCAT(
        'Number of Active Users in the last 6 months: ',
        COUNT(*)
    )
FROM (
        SELECT *
        from tbUser
        where LastLogin >= DATEADD(MONTH, -6, GETDATE())
    ) as [Result]
UNION ALL
SELECT CONCAT('Number of Sites: ', COUNT(SiteId)) AS [Result]
FROM tbSite si
WHERE si.Active = 1
UNION ALL
SELECT DISTINCT CONCAT(
        'Engines in Site ',
        SiteName,
        ':',
        COUNT(EngineId) OVER (PARTITION BY SITENAME)
    )
FROM tbEngine E
    JOIN tbSite S ON S.SiteId = E.SiteId
where E.ActivationStatus = 1
UNION ALL
SELECT CONCAT(
        'Allow Duplicate Secrets: ',
        CASE
            WHEN c.AllowDuplicateSecretNames = 0 THEN 'FALSE'
            WHEN c.AllowDuplicateSecretNames = 1 THEN 'TRUE'
            ELSE NULL
        END
    ) AS [Result]
FROM tbConfiguration c
UNION ALL
SELECT CONCAT(
        'Require Folder for Secrets: ',
        CASE
            WHEN c.RequireFolderForSecret = 0 THEN 'FALSE'
            WHEN c.RequireFolderForSecret = 1 THEN 'TRUE'
            ELSE NULL
        END
    ) AS [Result]
FROM tbConfiguration c
UNION ALL
SELECT CONCAT('Number of Secrets: ', COUNT(SecretID)) AS [Result]
FROM tbSecret s
WHERE s.Active = 1
UNION ALL
SELECT CONCAT('Duplicate Secret Count: ', COUNT(*))
FROM (
        SELECT s.SecretID AS [SecretID],
            ISNULL(f.FolderPath, 'No folder assigned') AS [Folder Path],
            s.secretname AS [Secret Name],
            st.secrettypename AS [Type]
        FROM tbsecret s
            JOIN (
                SELECT SecretName,
                    COUNT(SecretName) AS [Total]
                FROM tbsecret t
                WHERE t.active = 1
                GROUP BY SecretName
                Having COUNT(SecretName) > 1
            ) t ON s.SecretName = t.SecretName
            LEFT JOIN tbfolder f ON s.folderid = f.folderid
            INNER JOIN tbsecrettype st ON s.secrettypeid = st.secrettypeid
        WHERE s.active = 1
        GROUP BY s.SecretName,
            f.FolderPath,
            s.FolderId,
            s.SecretID,
            st.secrettypename
    ) AS [Result]
UNION ALL
SELECT CONCAT('Secrets Without Folders: ', COUNT(*))
FROM (
        SELECT s.SecretId,
            s.SecretName as [Secret],
            st.SecretTypeName as [Template],
            CASE
                WHEN s.FolderId IS NULL THEN 'No Folder'
            END AS [Folder]
        FROM tbSecret s
            INNER JOIN tbSecretType st on s.SecretTypeID = st.SecretTypeID
        WHERE s.FolderId IS NULL
            AND s.Active = 1
    ) AS [Result]
UNION ALL
SELECT CONCAT('Secrets Without Owners: ', COUNT(*))
FROM (
        SELECT DISTINCT s.SecretID AS [SecretID],
            ISNULL(f.FolderPath, 'No folder assigned') AS [Folder Path],
            s.SecretName AS [Secret Name]
        FROM vGroupSecretPermissions gsp
            INNER JOIN tbUserGroup ug ON gsp.GroupId = ug.GroupID
            INNER JOIN tbuser u ON ug.UserID = u.UserId
            INNER JOIN tbSecret s ON gsp.SecretId = s.SecretId
            LEFT JOIN tbFolder f ON s.FolderId = f.FolderID
            INNER JOIN tbGroup g ON ug.GroupID = g.GroupID
        WHERE s.Active = 1
            AND u.Enabled = 1
            AND (
                s.SecretID NOT IN (
                    SELECT gsp2.SecretID
                    FROM vGroupSecretPermissions gsp2
                        INNER JOIN tbgroup g2 ON gsp2.GroupId = g2.GroupID
                        INNER JOIN tbUserGroup ug2 ON gsp2.GroupId = ug2.GroupID
                        INNER JOIN tbuser u2 ON ug2.UserID = u2.UserId
                    WHERE gsp2.OwnerPermission = 1
                        AND u2.Enabled = 1
                )
            )
    ) AS [Result]
UNION ALL
SELECT CONCAT('Secrets Using Inactive Templates: ', COUNT(*))
FROM (
        SELECT s.created AS [Created],
            s.secretname AS [Secret Name],
            ISNULL(f.FolderPath, 'No folder assigned') AS [Folder Path]
        FROM tbsecret s
            LEFT JOIN tbfolder f ON s.folderid = f.folderid
            INNER JOIN tbSecretType st ON s.SecretTypeID = st.SecretTypeID
        WHERE st.Active = 0
            AND s.Active = 1
    ) AS [Result]
UNION ALL
SELECT CONCAT('Secrets in Personal Subfolders: ', COUNT(*))
FROM (
        SELECT s.SecretID AS [ID],
            s.secretname AS [Secret Name],
            f.folderpath AS [Location]
        FROM tbsecret s
            INNER JOIN tbfolder f ON s.folderid = f.folderid
        WHERE s.Active = 1
            AND f.FolderPath LIKE '%PERSONAL Folders\%\%'
    ) AS [Result]
UNION ALL
SELECT CONCAT(
        'Secrets in Inactive Personal Folders: ',
        COUNT(*)
    )
FROM (
        SELECT s.secretid AS [SecretId],
            s.secretname AS [Secret Name],
            f.folderpath AS [Location]
        FROM tbfolder f
            INNER JOIN tbsecret s ON s.FolderId = f.FolderID
            INNER JOIN tbUser u ON f.UserId = u.UserId
        WHERE f.FolderPath LIKE '%PERSONAL Folders\%'
            AND s.Active = 1
            AND u.Enabled = 0
    ) AS [Result]
UNION ALL
SELECT CONCAT('Number of Policies: ', COUNT(SecretPolicyId)) AS [Result]
FROM tbSecretPolicy p
WHERE p.Active = 1
UNION ALL
SELECT CONCAT('Direct Secret Policy Assignments: ', COUNT(*))
FROM (
        SELECT s.SecretId AS [Secret ID],
            s.SecretName AS [Secret Name],
            ISNULL(f.FolderPath, 'No folder assigned') AS [Folder Path],
            sp.SecretPolicyName AS [Policy]
        FROM tbSecret s
            LEFT JOIN tbfolder f ON s.FolderId = f.FolderID
            INNER JOIN tbSecretPolicy sp ON s.SecretPolicyId = sp.SecretPolicyId
        WHERE s.Active = 1
            AND s.EnableInheritSecretPolicy = 0
            AND s.SecretPolicyId IS NOT NULL
    ) AS [Result]
UNION ALL
SELECT CONCAT('Folder Policy Assignments: ', COUNT(*))
FROM (
        SELECT f.FolderId,
            f.FolderPath,
            sp.SecretPolicyName AS [Policy]
        FROM tbfolder f
            
            INNER JOIN tbSecretPolicy sp ON f.SecretPolicyId = sp.SecretPolicyId
        WHERE sp.Active = 1
            AND f.EnableInheritSecretPolicy = 0
            
    ) AS [Result]
UNION ALL
SELECT CONCAT(
        'Discovery Enabled: ',
        CASE
            WHEN dc.EnableDiscovery = 0 THEN 'FALSE'
            WHEN dc.EnableDiscovery = 1 THEN 'TRUE'
            ELSE NULL
        END
    ) AS [Result]
FROM tbDiscoveryConfiguration dc
UNION ALL
SELECT CONCAT(
        'Discovery Sources: ',
        COUNT(DiscoverySourceId)
    )
FROM (
        SELECT ds.DiscoverySourceId
        FROM tbDiscoverySource ds
        WHERE ds.Active = 1
    ) AS [Result]
UNION ALL
SELECT CONCAT(
        'Discovery Import Rules: ',
        COUNT(DiscoveryImportRuleId)
    )
FROM (
        SELECT dr.DiscoveryImportRuleId
        FROM tbDiscoveryImportRule dr
        WHERE dr.Active = 1
    ) AS [Result]
UNION ALL
SELECT CONCAT(
        'Password Rotation Enabled: ',
        CASE
            WHEN c.EnablePasswordChanging = 0 THEN 'FALSE'
            WHEN c.EnablePasswordChanging = 1 THEN 'TRUE'
            ELSE NULL
        END
    ) AS [Result]
FROM tbConfiguration c
UNION ALL
SELECT CONCAT(
        'Heartbeat globally enabled: ',
        (
            SELECT CASE
                    WHEN c.[EnableHeartBeat] = 0 THEN 'FALSE'
                    WHEN c.[EnableHeartBeat] = 1 THEN 'TRUE'
                    ELSE NULL
                END
            FROM [tbConfiguration] c
        )
    ) as [Result]
UNION ALL
SELECT CONCAT(
        'Modified Templates: ',
        COUNT(DISTINCT CAST("Template ID" AS INT))
    )
FROM (
        SELECT a.DateRecorded AS [Date],
            a.ItemId AS [Template ID],
            a.Action AS [Event],
            st.SecretTypeName AS [Template],
            a.Notes AS [Notes]
        FROM tbAudit a
            INNER JOIN tbUser u ON a.UserId = u.UserId
            INNER JOIN tbSecretType st ON a.ItemId = st.SecretTypeID
        WHERE (
                st.Active = 1
                AND a.AuditTypeId = 3
                AND a.Notes LIKE 'Field%'
            )
            AND NOT EXISTS (
                SELECT b.Action
                FROM tbAudit b
                WHERE b.itemid = a.itemid
                    AND b.Action LIKE '%EATE'
            )
    ) AS [Result]
UNION ALL
SELECT CONCAT('Custom Templates: ', COUNT(*))
FROM (
        SELECT DISTINCT a.DateRecorded AS [Date],
            u.DisplayName AS [Display Name],
            a.Action AS [Event],
            st.SecretTypeName AS [Template],
            a.ItemId AS [Template ID]
        FROM tbAudit a
            INNER JOIN tbUser u ON a.UserId = u.UserId
            INNER JOIN tbSecretType st ON a.ItemId = st.SecretTypeID
        WHERE st.Active = 1
            AND (
                a.AuditTypeID = 3
                AND a.Action LIKE '%EATE'
            )
    ) AS [Result]
UNION ALL
SELECT CONCAT('Custom Scripts: ', COUNT(*))
FROM (
        SELECT DISTINCT a.DateRecorded AS [Date],
            u.DisplayName AS [Display Name],
            a.Action AS [Event],
            sc.Name AS [Script],
            sct.Name AS [Script Type]
        FROM tbAudit a
            INNER JOIN tbUser u ON a.UserId = u.UserId
            INNER JOIN tbScript sc ON a.ItemId = sc.ScriptId
            INNER JOIN tbScriptType sct ON sc.ScriptTypeId = sct.ScriptTypeId
        WHERE sc.Active = 1
            AND (
                a.AuditTypeID = 5
                AND a.Action LIKE '%EATE'
            )
    ) AS [Result]
UNION ALL
SELECT CONCAT('Custom Launchers: ', COUNT(*))
FROM (
        SELECT DISTINCT a.DateRecorded AS [Date],
            u.DisplayName AS [Display Name],
            a.Action AS [Event],
            lt.Name AS [Launcher]
        FROM tbAudit a
            INNER JOIN tbUser u ON a.UserId = u.UserId
            INNER JOIN tbLauncherType lt ON a.ItemId = lt.LauncherTypeId
        WHERE lt.Active = 1
            AND (
                a.AuditTypeID = 4
                AND a.Action LIKE '%EATE'
            )
    ) AS [Result]
UNION ALL
SELECT CONCAT('Custom Password Changers: ', COUNT(*))
FROM (
        SELECT DISTINCT pta.Date AS [Date],
            u.DisplayName AS [Display Name],
            pta.Action AS [Event],
            pt.Name AS [Password Changer]
        FROM tbPasswordTypeAudit pta
            INNER JOIN tbUser u ON pta.UserId = u.UserId
            INNER JOIN tbPasswordType pt ON pta.PasswordTypeId = pt.PasswordTypeId
        WHERE pt.Active = 1
            AND pta.Action LIKE '%EATE'
            AND pta.Notes NOT LIKE '%Pass%'
    ) AS [Result]
UNION ALL
SELECT CONCAT('Custom Password Requirements: ', COUNT(*))
FROM (
        SELECT DISTINCT pra.Date AS [Date],
            u.DisplayName AS [Display Name],
            pra.Action AS [Event],
            pr.Name AS [Password Requirement]
        FROM tbPasswordRequirementAudit pra
            INNER JOIN tbUser u ON pra.UserId = u.UserId
            INNER JOIN tbPasswordRequirement pr ON pra.PasswordRequirementId = pr.PasswordRequirementId
        WHERE pra.Action LIKE '%EATE'
    ) AS [Result]
UNION ALL
SELECT CONCAT('Custom Character Sets: ', COUNT(*))
FROM (
        SELECT DISTINCT csa.Date AS [Date],
            u.DisplayName AS [Display Name],
            csa.Action AS [Event],
            cs.Name AS [Character Set]
        FROM tbCharacterSetAudit csa
            INNER JOIN tbUser u ON csa.UserId = u.UserId
            INNER JOIN tbCharacterSet cs ON csa.CharacterSetId = cs.CharacterSetId
        WHERE csa.Action LIKE '%EATE'
    ) AS [Result]
UNION ALL
SELECT CONCAT('Active Secrets With Files: ', COUNT(*))
FROM (
        SELECT [SecretItemID]
        FROM [tbSecretItem] [si]
            JOIN [tbSecretField] [sf] ON [si].[SecretFieldID] = [sf].[SecretFieldID]
            JOIN [tbFileAttachment] [fa] ON [si].[FileAttachmentId] = [fa].[FileAttachmentId]
            join [tbSecret] [s] on [si].[SecretID] = [s].[SecretID]
        WHERE [sf].[IsFile] = 1
            and [s].[Active] = 1
    ) AS [Result]
UNION ALL
SELECT CONCAT('Categorized Lists: ', COUNT(*))
FROM (
        SELECT *
        FROM tbCategorizedList
    ) as [Result]
UNION ALL
SELECT CONCAT('Active SDK Accounts: ', COUNT(*))
FROM (
        SELECT *
        FROM [tbSdkClientAccount]
        WHERE [Revoked] <> 1
    ) as [Result]
UNION ALL
SELECT CONCAT('SDK Unique Client IPs: ', COUNT(*))
FROM (
        select distinct IpAddress
        from tbSdkClientAccount
    ) as [Result]
UNION ALL
SELECT CONCAT('Custom SQL Reports: ', COUNT(*))
FROM (
        SELECT *
        FROM [tbCustomReport]
        WHERE [IsStandardReport] <> 1
    ) as [Result]
UNION ALL
SELECT CONCAT('Event Subscriptions: ', COUNT(*))
FROM (
        SELECT *
        FROM tbEventSubscription
    ) as [Result]
UNION ALL
SELECT CONCAT('Workflows: ', COUNT(*))
FROM (
        SELECT *
        FROM tbWorkflowTemplate
    ) as [Result]
UNION ALL
SELECT CONCAT('Teams: ', COUNT(*))
FROM (
        SELECT *
        FROM tbTeam
        where active = 1
    ) as [Result]
UNION ALL
SELECT CONCAT(
        'Session Recording Enabled: ',
        CASE
            WHEN c.EnableSessionRecording = 0 THEN 'FALSE'
            WHEN c.EnableSessionRecording = 1 THEN 'TRUE'
            ELSE NULL
        END
    ) AS [Result]
FROM tbConfiguration c
UNION ALL
SELECT CONCAT(
        'Advanced Session Recording Enabled: ',
        CASE
            WHEN asr.Enabled = 0 THEN 'FALSE'
            WHEN asr.Enabled = 1 THEN 'TRUE'
            ELSE NULL
        END
    ) AS [Result]
FROM tbAdvancedSessionRecordingConfiguration asr
UNION ALL
SELECT CONCAT(
        'QuantumLocks: ',
        (
            SELECT COUNT(*)
            FROM [tbDoubleLock]
        )
    ) as [Result]
UNION ALL
SELECT CONCAT(
        'Folders with leading or trailing spaces: ',
        COUNT(*)
    )
FROM (
        select foldername,
            FolderPath,
            f.folderid
        from tbfolder f
        Where foldername like ' %'
            or foldername like '% '
    ) AS [Result]
UNION ALL
SELECT CONCAT(
        'Secrets with leading or trailing spaces: ',
        COUNT(*)
    )
FROM (
        select secretname,
            FolderPath
        from tbsecret s
            join tbfolder f on f.FolderID = s.folderid
        Where secretname like ' %'
            or secretname like '% '
    ) AS [Result]
UNION ALL
SELECT CONCAT('Secrets with OTP Codes added: ', COUNT(*))
FROM (
        SELECT f.folderpath,
            SecretName,
            t.SecretTypeName as [Template]
        FROM tbSecret s
            join tbFolder f on f.FolderID = s.FolderId
            join tbSecretType t on t.SecretTypeID = s.SecretTypeID
            left join tbSecretOneTimePasswordSettings otp on otp.SecretId = s.SecretID
        WHERE s.active = 1
            and otp.Enabled = 1
    ) AS [Result]
UNION ALL
SELECT CONCAT(
        'SQL Reports or Categories with Custom Permissions: ',
        COUNT(*)
    )
FROM (
        SELECT *
        FROM [tbReportACL] [ACL]
    ) as [Result]
UNION ALL
SELECT DISTINCT CONCAT('Proxied Secrets - Site [',list.SiteName,'] Type - ', list.type,': ',COUNT(secretid) OVER (PARTITION BY [type], Sitename)    ) as [Resut]
from (
        SELECT s.Secretid,
            s.secretname,
            CASE
                WHEN pt.typename LIKE '%activeDirectory%'
                OR pt.typename LIKE '%WindowsAccount%' THEN 'RDP'
                WHEN pt.typename LIKE '%UnixSSH%' THEN 'Unix/SSH'
                ELSE CONCAT('Other: ',REVERSE(SUBSTRING(REVERSE(PT.TYPENAME), 1, CHARINDEX('.', REVERSE(PT.TYPENAME)) - 1)))
            END AS [Type],
            site.SiteName
        FROM tbsecret s
            JOIN tbSecretType t ON s.SecretTypeID = t.SecretTypeid
            JOIN tbPasswordType pt ON t.PasswordTypeId = pt.PasswordTypeId
            join tbsite site on site.siteid = s.SiteId
        WHERE s.IsSSHProxyEnabled = 1
            AND s.Active = 1
    ) list
UNION ALL
SELECT CONCAT('Folders Without Owners: ', COUNT(*))
FROM (
        SELECT DISTINCT f.folderID,
            f.FolderPath
        FROM vGroupfolderPermissions gsp
            INNER JOIN tbfolder f ON gsp.folderId = f.folderId
        WHERE (
                f.folderID NOT IN (
                    SELECT gsp2.folderID
                    FROM vGroupfolderPermissions gsp2
                        INNER JOIN tbgroup g2 ON gsp2.GroupId = g2.GroupID
                        INNER JOIN tbUserGroup ug2 ON gsp2.GroupId = ug2.GroupID
                        INNER JOIN tbuser u2 ON ug2.UserID = u2.UserId
                    WHERE gsp2.OwnerPermission = 1
                        AND u2.Enabled = 1
                )
                AND f.IsSystemFolder = 0
            )
    ) AS [Result]
UNION ALL
SELECT CONCAT('Metadata items: ', COUNT(*))
FROM (
        SELECT mt.MetadataTypeName,
            CASE
                mt.MetadataTypeId
                WHEN 1 THEN u.DisplayName
                WHEN 2 THEN s.SecretName
                WHEN 3 THEN f.FolderName
                WHEN 4 THEN g.GroupName
            END AS ItemName,
            mfs.MetadataFieldSectionName,
            mf.MetadataFieldName,
            CASE
                mf.MetadataFieldTypeId
                WHEN 1 THEN mid.ValueString
                WHEN 2 THEN IIF(mid.ValueBit = 1, 'TRUE', 'FALSE')
                WHEN 3 THEN CONVERT(VARCHAR(50), mid.ValueNumber)
                WHEN 4 THEN CONVERT(VARCHAR(25), mid.ValueDateTime, 120)
                WHEN 5 THEN (
                    SELECT DisplayName
                    FROM tbUser
                    WHERE UserId = mid.ValueInt
                )
            END AS [ItemValue]
        FROM tbMetadataItemData AS mid
            INNER JOIN tbMetadataType AS mt ON mt.MetadataTypeId = mid.MetadataTypeId
            INNER JOIN tbMetadataField AS mf ON mf.MetadataFieldId = mid.MetadataFieldId
            INNER JOIN tbMetadataFieldSection AS mfs ON mfs.MetadataFieldSectionId = mf.MetadataFieldSectionId
            LEFT JOIN tbFolder AS f ON f.FolderId = mid.ItemId
            LEFT JOIN tbSecret AS s ON s.SecretId = mid.ItemId
            LEFT JOIN tbGroup AS g ON g.GroupId = mid.ItemId
            LEFT JOIN tbUser AS u ON u.UserId = mid.ItemId
    ) AS [Result]
UNION ALL
	SELECT CONCAT('Number of Checkout Enabled Secrets: ', COUNT(s.SecretId)) AS [Result]
	FROM tbsecret S
	WHERE s.CheckoutEnabled = 1 and S.active = 1
UNION ALL
	SELECT CONCAT('Number of Comment Required Secrets: ', COUNT(s.SecretId)) AS [Result]
	FROM tbsecret S
	WHERE s.RequireViewComment = 1 and S.active = 1
UNION ALL
select Concat('Secrets requiring approval: ',count(secretid)) as result from (select f.folderpath,s.secretid,s.secretname,st.SecretTypeName as [Template],RequireApprovalForAccess,RequireApprovalForAccessForEditors,RequireApprovalForAccessForOwnersAndApprovers  from tbsecret s
join tbfolder f on f.folderid = s.folderid
join tbSecretType st on st.SecretTypeID = s.SecretTypeID
where RequireApprovalForAccess = 1 or RequireApprovalForAccessForEditors =1 or RequireApprovalForAccessForOwnersAndApprovers =1 ) d
UNION ALL
	SELECT concat('Ticketing Systems: ',count(ts.TicketSystemId)) as restult	FROM tbTicketSystem  ts
	WHERE ts.active = 1
UNION ALL
SELECT concat('Privilege manager folder path: ',folderpath) as result from tbfolder where folderid = (select top 1 folderid FROM tbAuditFolder a where folderpath = '\Privilege Manager Secrets') 
union all
SELECT concat('Privilege manager secret count: ',count(secretid)) as result from tbsecret s where folderid = (select top 1 folderid FROM tbAuditFolder a where folderpath = '\Privilege Manager Secrets') and s.active = 1
UNION ALL
Select concat('Depenencies: ',count(secretid)) as result
from (select folderpath
	,s.secretid
	,s.secretname
	,dt.SecretDependencyTemplateName as [Type]
	,case 
		WHEN d.SecretDependencyStatus = 1 THEN 'Sucess'
		WHEN d.SecretDependencyStatus = 0 THEN 'Failed'
		WHEN  d.SecretDependencyStatus is null THEN 'Not Run'
		End as [Dep Status]
	,ServiceName
	,MachineName
	,ps.SecretName as [RunAsSecret]
	,ps.Active as [RunAs Secret Active] 
from tbSecretDependency d
join tbsecret s on d.SecretId = s.secretid
join tbfolder f on s.FolderId = f.FolderID
join tbsecret ps on d.SecretId = ps.secretid
full outer join tbSecretDependencyTemplate dt on d.SecretDependencyTemplateId = dt.SecretDependencyTemplateId
where d.Active =1 and s.Active =1 ) depend
UNION ALL
Select concat('Event Pipeline Policies: ',count(EventPipelinePolicyid)) as result 
FROM (SELECT epp.EventPipelinePolicyId,
    epp.EventPipelinePolicyName AS [Pipeline Policy Name],
    isnull(epp.EventPipelinePolicyDescription,'') AS [Pipeline Policy Description],
CASE
        WHEN epp.EventEntityTypeId = 1 THEN 'UserType'
        WHEN epp.EventEntityTypeId = 10001 THEN 'SecretType'
        ELSE concat('Unknown:', epp.EventEntityTypeId)
    END AS [Type],
    Count(Ep.EventPipelineName) AS [Pipelines assigned],
CASE
        WHEN runs.count > 1 then cast (runs.count AS VARCHAR)
        ELSE 'Never Run'
    END AS [Lifetime Run Count]
FROM tbEventPipelinePolicy epp
    JOIN tbEventPipelinePolicyMap eppm ON eppm.EventPipelinePolicyId = epp.EventPipelinePolicyId
    JOIN tbEventPipeline ep ON eppm.EventPipelineId = ep.EventPipelineId
    FULL OUTER JOIN (
        SELECT EventPipelinePolicyID,
            count(EventPipelinePolicyID) AS count
        FROM tbEventPipelinePolicyRun
        GROUP BY EventPipelinePolicyID
    ) runs ON runs.EventPipelinePolicyId = epp.EventPipelinePolicyId
WHERE epp.Active = 1
    AND ep.Active = 1
GROUP BY epp.EventPipelinePolicyId,
    epp.EventPipelinePolicyName,
    epp.EventPipelinePolicyDescription,
    epp.EventEntityTypeId,
    runs.count) as result

) inventory
