SELECT 'Report Version' AS [Item], '1.4.20250627' AS [Value], '' AS [Comment]
UNION ALL

SELECT 'Report Date' AS [Item], 
	CONVERT(VARCHAR, GETDATE(), 101) AS [Value], -- Format: MM/DD/YYYY
	'' AS [Comment]
UNION ALL

SELECT 'Platform Adoption Status' AS [Item], '' AS [Value], '' AS [Comment]
UNION ALL

SELECT '--> Platform Adoption Ready' AS [Item],
	CASE
		WHEN EXISTS (SELECT * FROM tbDomain WHERE DomainTypeId IN (2, 3) AND Active = 1) THEN 'No'
		WHEN (SELECT COUNT(*) FROM tbTeam WHERE Active = 1) > 0 THEN 'No'
		WHEN (SELECT COUNT(*) FROM tbUser WHERE Enabled = 1 AND IsApplicationAccount = 1 AND DomainId IS NOT NULL) > 0 THEN 'No'
		WHEN (SELECT COUNT(*) FROM tbEventSubscription) > 0 THEN 'Possible'
		WHEN (SELECT COUNT(*) FROM tbEventPipelinePolicy) > 0 THEN 'Possible'
		WHEN (SELECT COUNT(*) FROM tbEventSubscription) = 0 AND (SELECT COUNT(*) FROM tbEventPipelinePolicy) = 0 THEN 'Yes'
		ELSE 'Possible'
	END AS [Value],
	CASE
		WHEN (SELECT COUNT(*) FROM tbEventSubscription) > 0 OR (SELECT COUNT(*) FROM tbEventPipelinePolicy) > 0 THEN 'To be Reviewed'
		ELSE ''
	END AS [Comment]
UNION ALL

SELECT '--> UsePlatformSettings' AS [Item],
	CASE
		WHEN EXISTS (SELECT *
					 FROM tbPlatformConfiguration
					 WHERE UsePlatformSettings = 1) THEN 'Enabled'
		ELSE 'Disabled'
	END AS [Value],
	'' AS [Comment]
UNION ALL

SELECT 'Migration Package Size' AS [Item], '' AS [Value], '' AS [Comment]
UNION ALL

SELECT '--> Size' AS [Item], 
	CASE 
		WHEN (SELECT COUNT(SecretID) FROM tbSecret WHERE Active = 1) < 2500 
			AND (SELECT COUNT(*) FROM tbSdkClientAccount WHERE Revoked <> 1) < 2 THEN 'Small'
		WHEN (SELECT COUNT(SecretID) FROM tbSecret WHERE Active = 1) BETWEEN 2501 AND 10000 
			AND (SELECT COUNT(*) FROM tbSdkClientAccount WHERE Revoked <> 1) BETWEEN 3 AND 7 THEN 'Medium'
		WHEN (SELECT COUNT(SecretID) FROM tbSecret WHERE Active = 1) BETWEEN 10001 AND 25000 
			AND (SELECT COUNT(*) FROM tbSdkClientAccount WHERE Revoked <> 1) > 7 THEN 'Large'
		WHEN (SELECT COUNT(SecretID) FROM tbSecret WHERE Active = 1) > 25001
			AND (SELECT COUNT(*) FROM tbSdkClientAccount WHERE Revoked <> 1) > 7 THEN 'Custom'
		WHEN (SELECT COUNT(SecretID) FROM tbSecret WHERE Active = 1) > 10001 THEN 'Large'
		WHEN (SELECT COUNT(SecretID) FROM tbSecret WHERE Active = 1) BETWEEN 2501 AND 10000 THEN 'Medium'
		WHEN (SELECT COUNT(*) FROM tbSdkClientAccount WHERE Revoked <> 1) > 7 THEN 'Large'
		WHEN (SELECT COUNT(*) FROM tbSdkClientAccount WHERE Revoked <> 1) BETWEEN 3 AND 7 THEN 'Medium'
		ELSE 'Small' -- Default if both categories are small
	END AS [Value], '' AS [Comment]
UNION ALL

SELECT 'Directory Services Information' AS [Item], '' AS [Value], '' AS [Comment]
UNION ALL

SELECT '--> Number of Domains', CAST(COUNT(DomainId) AS NVARCHAR(50)) AS [Value], ''
FROM tbDomain d
WHERE d.Active = 1
UNION ALL

SELECT '--> Entra ID-Directory Services' AS [Item],
	CASE 
		WHEN EXISTS (SELECT * FROM tbDomain WHERE DomainTypeId = 3 AND Active = 1) THEN 
			'Yes (' + CAST((SELECT COUNT(*) FROM tbDomain WHERE DomainTypeId = 3 AND Active = 1) AS VARCHAR) + ')'
		ELSE 'No' 
	END AS [Value], '' AS [Comment]
UNION ALL

SELECT '--> Active Directory-Directory Services' AS [Item],
	CASE 
		WHEN EXISTS (SELECT * FROM tbDomain WHERE DomainTypeId = 1 AND Active = 1) THEN 
			'Yes (' + CAST((SELECT COUNT(*) FROM tbDomain WHERE DomainTypeId = 1 AND Active = 1) AS VARCHAR) + ')'
		ELSE 'No' 
	END AS [Value], '' AS [Comment]
UNION ALL

SELECT '--> OpenLDAP-Directory Services' AS [Item],
	CASE 
		WHEN EXISTS (SELECT * FROM tbDomain WHERE DomainTypeId = 2 AND Active = 1) THEN 
			'Yes (' + CAST((SELECT COUNT(*) FROM tbDomain WHERE DomainTypeId = 2 AND Active = 1) AS VARCHAR) + ')'
		ELSE 'No' 
	END AS [Value], '' AS [Comment]
UNION ALL

SELECT 'Core Configuration' AS [Item], '' AS [Value], '' AS [Comment]
UNION ALL

SELECT '--> Secret Server Address' AS [Item], CAST(c.CustomURL AS NVARCHAR(255)) AS [Value], '' AS [Comment]
FROM tbConfiguration c
UNION ALL

SELECT '--> Secret Server Version' AS [Item], 
   CAST(v.VersionNumber AS NVARCHAR(50)) AS [Value], 
   (SELECT CASE 
	   WHEN DATEADD(MONTH, -11, GETDATE()) > v.Upgraded THEN 'Last Upgrade > 11months'
	   WHEN v.VersionNumber < '11.6.000001' THEN 'Upgrade Required'
	   ELSE ''
   END)  AS [Comment]
FROM (
   SELECT TOP 1 v.VersionNumber, v.Upgraded
   FROM tbVersion v
   ORDER BY v.Upgraded DESC, v.VersionNumber DESC
) v
UNION ALL

SELECT '--> Number of Web Servers' AS [Item], CAST(COUNT(NodeId) AS NVARCHAR(50)) AS [Value], '' AS [Comment]
FROM tbNode n
UNION ALL

SELECT '--> Integrated Windows Auth' AS [Item], 
	CAST(CASE 
		WHEN c.IntegratedWindowsAuthentication = 0 THEN 'FALSE' 
		WHEN c.IntegratedWindowsAuthentication = 1 THEN 'TRUE' 
	END AS NVARCHAR(5)) AS [Value], '' AS [Comment]
FROM tbConfiguration c
UNION ALL

SELECT '--> SAML Enabled' AS [Item], 
	CAST(CASE 
		WHEN sc.Enabled = 0 THEN 'FALSE' 
		WHEN sc.Enabled = 1 THEN 'TRUE' 
	END AS NVARCHAR(5)) AS [Value], '' AS [Comment]
FROM tbSamlConfiguration sc
UNION ALL

SELECT '--> Allow Duplicate Secrets', 
	CAST(CASE 
		WHEN c.AllowDuplicateSecretNames = 0 THEN 'FALSE' 
		WHEN c.AllowDuplicateSecretNames = 1 THEN 'TRUE' 
	END AS NVARCHAR(5)), ''
FROM tbConfiguration c
UNION ALL

SELECT '--> Require Folder for Secrets', 
	CAST(CASE 
		WHEN c.RequireFolderForSecret = 0 THEN 'FALSE' 
		WHEN c.RequireFolderForSecret = 1 THEN 'TRUE' 
	END AS NVARCHAR(5)), ''
FROM tbConfiguration c
UNION ALL

SELECT '--> Password Rotation Enabled', 
	CAST(CASE 
		WHEN c.EnablePasswordChanging = 0 THEN 'FALSE' 
		WHEN c.EnablePasswordChanging = 1 THEN 'TRUE' 
	END AS NVARCHAR(5)), ''
FROM tbConfiguration c
UNION ALL

SELECT '--> Heartbeat Globally Enabled', 
	CAST(CASE 
		WHEN c.EnableHeartBeat = 0 THEN 'FALSE' 
		WHEN c.EnableHeartBeat = 1 THEN 'TRUE' 
	END AS NVARCHAR(5)), ''
FROM tbConfiguration c
UNION ALL

SELECT 'Site Information' AS [Item], '' AS [Value], '' AS [Comment]
UNION ALL

SELECT '--> Number of Sites', CAST(COUNT(SiteId) AS NVARCHAR(50)), ''
FROM tbSite si
WHERE si.Active = 1
UNION ALL

SELECT DISTINCT CONCAT('----> Engines in Site ', S.SiteName), 
	CAST(COUNT(EngineId) OVER (PARTITION BY S.SiteName) AS NVARCHAR(50)), ''
FROM tbEngine E
JOIN tbSite S ON S.SiteId = E.SiteId
WHERE E.ActivationStatus = 1
UNION ALL

SELECT 'Users and Groups' AS [Item], '' AS [Value], '' AS [Comment]
UNION ALL

SELECT '--> Number of Active Users in the last 6 months', CAST(COUNT(*) AS NVARCHAR(50)), ''
FROM tbUser u
WHERE u.LastLogin >= DATEADD(MONTH, -6, GETDATE())
UNION ALL

SELECT '--> Number of Automatically Disabled Users', CAST(COUNT(*) AS NVARCHAR(50)) AS [Value], ''
FROM tbUser
WHERE DisabledByAutomaticADUserDisabling = 1
UNION ALL

SELECT '--> Total Number of Users', CAST(COUNT(UserId) AS NVARCHAR(50)), ''
FROM tbUser u
WHERE u.Enabled = 1
UNION ALL

SELECT '--> Domain Users', CAST(COUNT(UserId) AS NVARCHAR(50)), ''
FROM tbUser u
WHERE u.Enabled = 1 AND u.DomainId IS NOT NULL
UNION ALL

SELECT '--> Local Users', CAST(COUNT(UserId) AS NVARCHAR(50)), ''
FROM tbUser u
WHERE u.Enabled = 1 AND u.DomainId IS NULL
UNION ALL

SELECT '--> Total Number of Application Accounts', CAST(COUNT(UserId) AS NVARCHAR(50)), ''
FROM tbUser u
WHERE u.Enabled = 1 AND u.IsApplicationAccount = 1
UNION ALL

SELECT '-->   Local Application Accounts' AS Item, CAST(COUNT(UserId) AS NVARCHAR(50)) AS Value, '' AS Comment
FROM tbUser u 
WHERE u.Enabled = 1 AND u.IsApplicationAccount = 1 AND u.DomainId IS NULL
UNION ALL

SELECT '-->   Domain Application Accounts' AS Item, CAST(COUNT(UserId) AS NVARCHAR(50)) AS Value, '' AS Comment
FROM tbUser u 
WHERE u.Enabled = 1 AND u.IsApplicationAccount = 1 AND u.DomainId IS NOT NULL
UNION ALL

SELECT '--> Total Numbers of Groups' AS [Item], CAST(COUNT(GroupId) AS NVARCHAR(50)) AS [Value], '' AS [Comment]
FROM tbGroup g
WHERE g.Active = 1
UNION ALL

SELECT '-->   Active Directory Groups' AS [Item], CAST(COUNT(GroupId) AS NVARCHAR(50)) AS [Value], '' AS [Comment]
FROM tbGroup g
WHERE g.DomainId IS NOT NULL AND g.Active = 1
UNION ALL

SELECT '-->   Local Groups' AS [Item], CAST(COUNT(GroupId) AS NVARCHAR(50)) AS [Value], '' AS [Comment]
FROM tbGroup g
WHERE g.DomainId IS NULL AND g.Active = 1
UNION ALL

SELECT '-->   Users with custom ownership', CAST(COUNT([userid]) AS NVARCHAR(50)), ''
FROM (
	SELECT DISTINCT userid 
	FROM (
		SELECT U.UserId
			,u.username AS [ManangedUser]
			,g.GroupName AS [Managed By]
		FROM [tbEntityOwnerPermission] EOP
		JOIN tbuser u ON u.userid = eop.OwnedEntityId
		JOIN tbGroup g ON eop.GroupId = g.GroupID
		WHERE roleid = 14 
		AND u.Enabled = 1
	) AS result
) AS result
UNION ALL

SELECT '-->   Groups with custom ownership', 
	   CAST(COUNT(DISTINCT tg.groupid) AS NVARCHAR(50)) AS [Value], 
	   '' AS [Comment]
FROM tbGroupOwnerPermission gop
JOIN tbgroup tg ON tg.GroupID = gop.OwnedGroupId
JOIN tbgroup og ON og.GroupID = gop.GroupId
WHERE tg.Active = 1 
AND og.Active = 1
UNION ALL

SELECT 'Secret Templates' AS [Item], '' AS [Value], '' AS [Comment]
UNION ALL

SELECT '--> Modified Templates', CAST(COUNT(DISTINCT CAST(a.ItemId AS INT)) AS NVARCHAR(50)), ''
FROM tbAudit a
JOIN tbSecretType st ON a.ItemId = st.SecretTypeID
WHERE a.AuditTypeId = 3 AND a.Notes LIKE 'Field%'
UNION ALL

SELECT '--> Custom Templates', CAST(COUNT(*) AS NVARCHAR(50)), ''
FROM tbAudit a
WHERE a.AuditTypeId = 3 AND a.Action LIKE '%EATE'
UNION ALL

SELECT '--> Custom Scripts', CAST(COUNT(*) AS NVARCHAR(50)), ''
FROM tbAudit a
WHERE a.AuditTypeId = 5 AND a.Action LIKE '%EATE'
UNION ALL

SELECT '--> Custom Launchers', CAST(COUNT(*) AS NVARCHAR(50)), ''
FROM tbAudit a
WHERE a.AuditTypeId = 4 AND a.Action LIKE '%EATE'
UNION ALL

SELECT '--> Custom Password Changers', CAST(COUNT(*) AS NVARCHAR(50)), ''
FROM tbPasswordTypeAudit pta
WHERE pta.Action LIKE '%EATE' AND pta.Notes NOT LIKE '%Pass%'
UNION ALL

SELECT '--> Custom Password Requirements', CAST(COUNT(*) AS NVARCHAR(50)), ''
FROM tbPasswordRequirementAudit pra
WHERE pra.Action LIKE '%EATE'
UNION ALL

SELECT '--> Custom Character Sets', CAST(COUNT(*) AS NVARCHAR(50)), ''
FROM tbCharacterSetAudit csa
WHERE csa.Action LIKE '%EATE'
UNION ALL

SELECT 'Secret Policies' AS [Item], '' AS [Value], '' AS [Comment]
UNION ALL

SELECT '--> Number of Policies', CAST(COUNT(SecretPolicyId) AS NVARCHAR(50)), ''
FROM tbSecretPolicy p
WHERE p.Active = 1
UNION ALL

SELECT '--> Direct Secret Policy Assignments', CAST(COUNT(*) AS NVARCHAR(50)), ''
FROM tbSecret s
WHERE s.Active = 1 AND s.SecretPolicyId IS NOT NULL AND s.EnableInheritSecretPolicy = 0
UNION ALL

SELECT '--> Folder Policy Assignments', CAST(COUNT(*) AS NVARCHAR(50)), ''
FROM tbfolder f
JOIN tbSecretPolicy sp ON f.SecretPolicyId = sp.SecretPolicyId
WHERE sp.Active = 1 AND f.EnableInheritSecretPolicy = 0
UNION ALL

SELECT 'Discovery Information' AS [Item], '' AS [Value], '' AS [Comment]
UNION ALL

SELECT '--> Discovery Enabled', 
	CAST(CASE 
		WHEN dc.EnableDiscovery = 0 THEN 'FALSE' 
		WHEN dc.EnableDiscovery = 1 THEN 'TRUE' 
	END AS NVARCHAR(5)), ''
FROM tbDiscoveryConfiguration dc
UNION ALL

SELECT '--> Discovery Sources', CAST(COUNT(DiscoverySourceId) AS NVARCHAR(50)), ''
FROM tbDiscoverySource ds
WHERE ds.Active = 1
UNION ALL

SELECT '--> Discovery Import Rules', CAST(COUNT(DiscoveryImportRuleId) AS NVARCHAR(50)), ''
FROM tbDiscoveryImportRule dr
WHERE dr.Active = 1
UNION ALL

SELECT 'Secret Information' AS [Item], '' AS [Value], '' AS [Comment]
UNION ALL

SELECT '--> Number of Secrets', CAST(COUNT(SecretID) AS NVARCHAR(50)), ''
FROM tbSecret s
WHERE s.Active = 1
UNION ALL

SELECT '--> Secrets in Personal Subfolders', CAST(COUNT(*) AS NVARCHAR(50)), ''
FROM tbSecret s
JOIN tbfolder f ON s.FolderId = f.FolderID
WHERE s.Active = 1 
	AND f.FolderPath LIKE '%'+ (SELECT PersonalFolderName FROM tbConfiguration)+ '\%\%' 
UNION ALL

SELECT '--> Secrets With Files', CAST(COUNT(*) AS NVARCHAR(50)), ''
FROM tbSecretItem si
JOIN tbSecretField sf ON si.SecretFieldID = sf.SecretFieldID
JOIN tbFileAttachment fa ON si.FileAttachmentId = fa.FileAttachmentId
JOIN tbSecret s ON si.SecretID = s.SecretID
WHERE sf.IsFile = 1 AND s.Active = 1
UNION ALL

SELECT '--> Secrets with OTP Codes Added', CAST(COUNT(*) AS NVARCHAR(50)), ''
FROM tbSecret s
JOIN tbFolder f ON s.FolderID = f.FolderID
JOIN tbSecretType t ON s.SecretTypeID = t.SecretTypeID
LEFT JOIN tbSecretOneTimePasswordSettings otp ON otp.SecretId = s.SecretID
WHERE s.Active = 1 AND otp.Enabled = 1
UNION ALL

SELECT '--> Secrets with Hooks' AS [Item],
	CAST(COUNT(DISTINCT sh.SecretId) AS VARCHAR(50)) AS [Value],
	'' AS [Comment]
FROM tbSecretHook sh
JOIN tbSecret s ON sh.SecretId = s.SecretId
WHERE s.Active = 1
UNION ALL

SELECT '-->  Total Count of Hooks' AS [Item],
	CAST((SELECT COUNT(*) FROM tbSecretHook) AS VARCHAR(50)) AS [Value],
	'' AS [Comment]
UNION ALL

SELECT '--> Proxy Features Enabled' AS [Item],
	CASE WHEN EnableRDPProxy = 1 THEN '(RDP)' ELSE '' END +
	CASE WHEN EnableSSHProxy = 1 THEN '(SSH)' ELSE '' END  +
	CASE WHEN EnableSSHProxyRDPTunneling = 1 THEN '(RDP over SSH)' ELSE '' END +
	CASE WHEN (EnableRDPProxy = 0 AND EnableSSHProxy = 0 AND EnableSSHProxyRDPTunneling = 0) THEN 'None' ELSE '' END AS [Value],
	'' AS [Comment]
FROM tbAdminProxyingConfiguration
UNION ALL

SELECT '--> Proxy New Secret By Default Setting' AS [Item],
	CASE WHEN ProxyByDefault = 1 THEN 'ENABLED' ELSE 'DISABLED' END AS [Value],
	'' AS [Comment]
FROM tbAdminProxyingConfiguration
UNION ALL

SELECT CONCAT('--> Site [', s.SiteName, '] Proxy Status') AS [Item],
	CASE WHEN s.EnableProxy = 1 THEN 'SSH: On' ELSE 'SSH: Off' END + 
	CASE WHEN s.EnableRDPProxy = 1 THEN ' | RDP: On' ELSE ' | RDP: Off' END +
	' - ' + CAST(COUNT(e.EngineId) AS VARCHAR(10)) + ' Active Engines' AS [Value],
	'' AS [Comment]
FROM tbSite s
LEFT JOIN tbEngine e ON s.SiteId = e.SiteId AND e.ActivationStatus = 1
WHERE s.EnableProxy = 1 OR s.EnableRDPProxy = 1
GROUP BY s.SiteId, s.SiteName, s.EnableProxy, s.EnableRDPProxy
UNION ALL

SELECT DISTINCT CONCAT('--> Proxied Secrets - Site [', list.SiteName, '] Type - ', list.Type), 
	CAST(COUNT(secretid) OVER (PARTITION BY [Type], Sitename) AS NVARCHAR(50)), ''
FROM (
	SELECT s.Secretid,
		CASE
			WHEN pt.typename LIKE '%activeDirectory%' OR pt.typename LIKE '%WindowsAccount%' THEN 'RDP'
			WHEN pt.typename LIKE '%UnixSSH%' THEN 'Unix/SSH'
			ELSE CONCAT('Other: ', REVERSE(SUBSTRING(REVERSE(PT.TYPENAME), 1, CHARINDEX('.', REVERSE(PT.TYPENAME)) - 1)))
		END AS [Type],
		site.SiteName
	FROM tbSecret s
	JOIN tbSecretType t ON s.SecretTypeID = t.SecretTypeID
	JOIN tbPasswordType pt ON t.PasswordTypeId = pt.PasswordTypeId
	JOIN tbSite site ON site.SiteId = s.SiteId
	WHERE s.IsSSHProxyEnabled = 1 AND s.Active = 1
) list
UNION ALL

SELECT '--> Number of Checkout Enabled Secrets', CAST(COUNT(*) AS NVARCHAR(50)), ''
FROM tbSecret s
WHERE s.CheckoutEnabled = 1 AND s.Active = 1
UNION ALL

SELECT '--> Number of Comment Required Secrets', CAST(COUNT(*) AS NVARCHAR(50)), ''
FROM tbSecret s
WHERE s.RequireViewComment = 1 AND s.Active = 1
UNION ALL

SELECT '--> Secrets Requiring Approval', CAST(COUNT(*) AS NVARCHAR(50)), ''
FROM tbSecret s
WHERE s.RequireApprovalForAccess = 1 OR s.RequireApprovalForAccessForEditors = 1 OR s.RequireApprovalForAccessForOwnersAndApprovers = 1
UNION ALL

SELECT 'Core Setup' AS [Item], '' AS [Value], '' AS [Comment]
UNION ALL

SELECT '--> Event Pipeline Policies', CAST(COUNT(epp.EventPipelinePolicyId) AS NVARCHAR(50)), ''
FROM tbEventPipelinePolicy epp
JOIN tbEventPipelinePolicyMap eppm ON eppm.EventPipelinePolicyId = epp.EventPipelinePolicyId
JOIN tbEventPipeline ep ON eppm.EventPipelineId = ep.EventPipelineId
WHERE epp.Active = 1 AND ep.Active = 1
UNION ALL

SELECT '--> Dependencies', CAST(COUNT(s.SecretId) AS NVARCHAR(50)), ''
FROM tbSecretDependency d
JOIN tbSecret s ON d.SecretId = s.SecretId
WHERE d.Active = 1 AND s.Active = 1
UNION ALL

SELECT '--> Ticketing Systems', CAST(COUNT(ts.TicketSystemId) AS NVARCHAR(50)), ''
FROM tbTicketSystem ts
WHERE ts.Active = 1
UNION ALL

SELECT '--> Workflows', CAST(COUNT(*) AS NVARCHAR(50)), ''
FROM tbWorkflowTemplate
UNION ALL

SELECT '--> Teams', CAST(COUNT(*) AS NVARCHAR(50)), ''
FROM tbTeam
WHERE Active = 1
UNION ALL

SELECT '--> QuantumLocks', CAST(COUNT(*) AS NVARCHAR(50)), ''
FROM tbDoubleLock 
WHERE active = 1
UNION ALL

SELECT '--> Event Subscriptions', CAST(COUNT(*) AS NVARCHAR(50)), ''
FROM tbEventSubscription 
WHERE active = 1
UNION ALL

SELECT '--> Categorized Lists', CAST(COUNT(*) AS NVARCHAR(50)), ''
FROM tbCategorizedList 
WHERE active = 1
UNION ALL

SELECT 'Session Recording' AS [Item], '' AS [Value], '' AS [Comment]
UNION ALL

SELECT '--> Session Recording Enabled', 
	CAST(CASE 
		WHEN c.EnableSessionRecording = 0 THEN 'FALSE' 
		WHEN c.EnableSessionRecording = 1 THEN 'TRUE' 
	END AS NVARCHAR(5)), ''
FROM tbConfiguration c
UNION ALL

SELECT '--> Advanced Session Recording Enabled', 
	CAST(CASE 
		WHEN asr.Enabled = 0 THEN 'FALSE' 
		WHEN asr.Enabled = 1 THEN 'TRUE' 
	END AS NVARCHAR(5)), ''
FROM tbAdvancedSessionRecordingConfiguration asr
UNION ALL

SELECT CONCAT('--> ASR Collection [', lac.Name, '] Agents'), 
	CAST(COUNT(la.LauncherAgentId) AS NVARCHAR(50)), ''
FROM tbLauncherAgentCollection lac
LEFT JOIN tbLauncherAgent la ON lac.LauncherAgentCollectionId = la.LauncherAgentCollectionId AND la.Active = 1
WHERE lac.Active = 1
GROUP BY lac.LauncherAgentCollectionId, lac.Name
UNION ALL

SELECT '--> Recorded Sessions Stored in Database', 
	CAST(COUNT(*) AS NVARCHAR(50)), 
	'Oldest: ' + FORMAT(MIN(StartDate), 'yyyy/MM/dd') + ' | Newest: ' + FORMAT(MAX(StartDate), 'yyyy/MM/dd') AS [Comment]
FROM tbLauncherSession 
WHERE FileSize > 0 AND IsDeleted = 0
UNION ALL

SELECT '--> Total Session Storage Size (MB)', 
	CAST(CAST(ROUND(SUM(CAST(FileSize AS BIGINT)) / 1024.0 / 1024.0, 0) AS INT) AS NVARCHAR(50)), ''
FROM tbLauncherSession 
WHERE FileSize > 0 AND IsDeleted = 0
UNION ALL

SELECT 'Cleanup Items' AS [Item], '' AS [Value], '' AS [Comment]
UNION ALL

SELECT '--> Duplicate Secret Count' AS [Item], CAST(COUNT(*) AS NVARCHAR(50)) AS [Value], '' AS [Comment]
FROM (
	SELECT s.SecretID
	FROM tbSecret s
	JOIN (
		SELECT SecretName, COUNT(SecretName) AS [Total]
		FROM tbSecret t
		WHERE t.Active = 1
		GROUP BY SecretName
		HAVING COUNT(SecretName) > 1
	) t ON s.SecretName = t.SecretName
) AS [Result]
UNION ALL

SELECT '--> Secrets Without Folders' AS [Item], CAST(COUNT(*) AS NVARCHAR(50)) AS [Value], '' AS [Comment]
FROM tbSecret s
WHERE s.FolderId IS NULL AND s.Active = 1
UNION ALL

SELECT '--> Secrets Without Owners' AS [Item], CAST(COUNT(*) AS NVARCHAR(50)) AS [Value], '' AS [Comment]
FROM tbSecret s
WHERE s.active = 1 
   AND s.secretid NOT IN (
	SELECT s.[SecretId]
	FROM dbo.tbSecretACL acl WITH (NOLOCK)
	JOIN dbo.tbSecret s WITH (NOLOCK) ON s.SecretID = acl.SecretID AND s.Active = 1
	JOIN dbo.tbUserGroup ug WITH (NOLOCK) ON acl.[GroupID] = ug.[GroupID]
	JOIN dbo.tbUser u WITH (NOLOCK) ON ug.[UserID] = u.[UserId] AND u.enabled = 1
	WHERE acl.permissions = 15
   )
UNION ALL

SELECT '--> Secrets Using Inactive Templates' AS [Item], CAST(COUNT(*) AS NVARCHAR(50)) AS [Value], '' AS [Comment]
FROM tbSecret s
JOIN tbSecretType st ON s.SecretTypeID = st.SecretTypeID
WHERE st.Active = 0 AND s.Active = 1
UNION ALL

SELECT '--> Secrets in Inactive Personal Folders' AS [Item], CAST(COUNT(*) AS NVARCHAR(50)) AS [Value], '' AS [Comment]
FROM tbSecret s
JOIN tbFolder f ON s.FolderId = f.FolderID
JOIN tbUser u ON f.UserId = u.UserId
WHERE  f.FolderPath LIKE '%'+ (SELECT PersonalFolderName FROM tbConfiguration)+ '\%' 
	AND s.Active = 1 
	AND u.Enabled = 0
UNION ALL

SELECT '--> Folders With Leading or Trailing Spaces' AS [Item], CAST(COUNT(*) AS NVARCHAR(50)) AS [Value], '' AS [Comment]
FROM tbfolder f
WHERE f.FolderName LIKE ' %' OR f.FolderName LIKE '% '
UNION ALL

SELECT '--> Secrets With Leading or Trailing Spaces' AS [Item], CAST(COUNT(*) AS NVARCHAR(50)) AS [Value], '' AS [Comment]
FROM tbSecret s
JOIN tbFolder f ON s.FolderID = f.FolderID
WHERE s.SecretName LIKE ' %' OR s.SecretName LIKE '% ' AND s.Active = 1
UNION ALL

SELECT '--> Folders Without Owners' AS [Item], CAST(COUNT(*) AS NVARCHAR(50)) AS [Value], '' AS [Comment]
FROM tbfolder f
WHERE f.FolderId NOT IN (
	SELECT gsp.FolderId
	FROM vGroupFolderPermissions gsp
	WHERE gsp.OwnerPermission = 1
) AND f.FolderName <> (SELECT PersonalFolderName FROM tbConfiguration)
UNION ALL

SELECT '--> Shared Secrets in Personal Folders' AS [Item], CAST(COUNT(*) AS NVARCHAR(50)) AS [Value], '' AS [Comment]
FROM (
	SELECT s.SecretId
	FROM dbo.tbSecretACL acl WITH (NOLOCK)
	JOIN dbo.tbSecret s WITH (NOLOCK) ON s.SecretID = acl.SecretID AND s.Active = 1
	JOIN dbo.tbGroup g WITH (NOLOCK) ON acl.[GroupID] = g.[GroupID] AND (g.[Active] = 1 OR g.[IsPersonal] = 1)
	JOIN dbo.tbUserGroup ug WITH (NOLOCK) ON acl.[GroupID] = ug.[GroupID]
	JOIN dbo.tbUser u WITH (NOLOCK) ON ug.[UserID] = u.[UserId]
	LEFT JOIN tbFolder f WITH (NOLOCK) ON s.[FolderID] = f.[FolderId]
	WHERE f.FolderPath LIKE '\' + (SELECT PersonalFolderName FROM tbConfiguration) +'%'  
	  AND f.UserId <> ug.UserId
) report
UNION ALL

SELECT 'Reporting' AS [Item], '' AS [Value], '' AS [Comment]
UNION ALL

SELECT '--> Custom SQL Reports', CAST(COUNT(*) AS NVARCHAR(50)), ''
FROM tbCustomReport
WHERE IsStandardReport <> 1
UNION ALL

SELECT '--> SQL Report Schedules', CAST(COUNT(*) AS NVARCHAR(50)), ''
FROM tbSchedule sch
FULL JOIN tbScheduledReport sr ON sr.ScheduleId = sch.ScheduleId
JOIN tbCustomReport rep ON rep.CustomReportId = sr.ReportId
WHERE sch.Active = 1 AND rep.Active = 1
UNION ALL

SELECT '--> SQL Reports or Categories with Custom Permissions', CAST(COUNT(*) AS NVARCHAR(50)), ''
FROM tbReportACL
UNION ALL

SELECT 'SDK' AS [Item], '' AS [Value], '' AS [Comment]
UNION ALL

SELECT '--> Active SDK Accounts', CAST(COUNT(*) AS NVARCHAR(50)), ''
FROM tbSdkClientAccount
WHERE Revoked <> 1
UNION ALL

SELECT '--> SDK Unique Client IPs', CAST(COUNT(DISTINCT IpAddress) AS NVARCHAR(50)), ''
FROM tbSdkClientAccount
UNION ALL

SELECT 'Privilege Manager' AS [Item], '' AS [Value], '' AS [Comment]
UNION ALL

SELECT '--> Privilege Manager Folder Path', f.FolderPath, ''
FROM tbfolder f
WHERE f.FolderId = (
	SELECT TOP 1 a.FolderId
	FROM tbAuditFolder a
	WHERE a.FolderPath = '\Privilege Manager Secrets'
)
UNION ALL

SELECT '--> Privilege Manager Secret Count', CAST(COUNT(s.SecretId) AS NVARCHAR(50)), ''
FROM tbSecret s
WHERE s.FolderId = (
	SELECT TOP 1 a.FolderId
	FROM tbAuditFolder a
	WHERE a.FolderPath = '\Privilege Manager Secrets'
) AND s.Active = 1
UNION ALL

SELECT 'Metadata' AS [Item], '' AS [Value], '' AS [Comment]
UNION ALL

SELECT '--> Metadata Items', CAST(COUNT(*) AS NVARCHAR(50)), ''
FROM tbMetadataItemData mid
