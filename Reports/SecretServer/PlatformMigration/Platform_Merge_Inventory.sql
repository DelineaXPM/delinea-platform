SELECT r.Item AS [Item], r.[Value] AS [Value], r.Comment AS [Comment]
FROM (
    SELECT 1 AS Sec, 1 AS Seq, CAST('Report Name' AS NVARCHAR(4000)) AS Item, CAST('Merge Report' AS NVARCHAR(4000)) AS [Value], CAST('' AS NVARCHAR(4000)) AS Comment

    UNION ALL

    SELECT 1, 2, 'Report Version', '0.1.20261001', ''

    UNION ALL

    SELECT 1, 3, 'Report Date', CONVERT(VARCHAR(10), GETUTCDATE(), 101), 'UTC'

    UNION ALL

    SELECT 1, 4, 'Scope', 'Personal folders excluded', 'All folders and secrets under the personal folders root are skipped'

    UNION ALL

    SELECT 2, 0, 'Instance Information', '', ''

    UNION ALL

    SELECT 2, 1, '--> Secret Server Address', CAST(ISNULL(c.CustomURL, '') AS NVARCHAR(4000)), ''
    FROM tbConfiguration c WITH (NOLOCK)

    UNION ALL

    SELECT 2, 2, '--> Secret Server Version', CAST(v.VersionNumber AS NVARCHAR(50)), ''
    FROM (
        SELECT TOP 1 v1.VersionNumber
        FROM tbVersion v1 WITH (NOLOCK)
        ORDER BY v1.Upgraded DESC, v1.VersionNumber DESC
    ) v

    UNION ALL

    SELECT 2, 3, '--> Number of Web Servers', CAST(COUNT(*) AS NVARCHAR(50)), ''
    FROM tbNode n WITH (NOLOCK)

    UNION ALL

    SELECT 2, 4, '--> Number of Active Sites', CAST(COUNT(*) AS NVARCHAR(50)), ''
    FROM tbSite si WITH (NOLOCK)
    WHERE si.Active = 1

    UNION ALL

    SELECT 2, 5, '--> Number of Active Secrets', CAST(COUNT(*) AS NVARCHAR(50)), ''
    FROM tbSecret s0 WITH (NOLOCK)
    LEFT JOIN (SELECT f.FolderID AS FolderID, f.ParentFolderId AS ParentFolderId, f.EnableInheritPermissions AS EnableInheritPermissions, x.TopName AS TopName, CASE WHEN x.TopName = ISNULL(pc.PersonalFolderName, '') THEN 1 ELSE 0 END AS IsPersonal FROM tbFolder f WITH (NOLOCK) CROSS JOIN tbConfiguration pc WITH (NOLOCK) CROSS APPLY (SELECT LEFT(z.p, CHARINDEX('\', z.p + '\') - 1) AS TopName FROM (SELECT CAST(CASE WHEN LEFT(f.FolderPath, 1) = '\' THEN SUBSTRING(f.FolderPath, 2, 600) ELSE LEFT(f.FolderPath, 600) END AS NVARCHAR(600)) AS p) z) x) m0 ON m0.FolderID = s0.FolderId
    WHERE s0.Active = 1 AND ISNULL(m0.IsPersonal, 0) = 0

    UNION ALL

    SELECT 3, 0, 'Top Level Folders', '', 'Value = active secrets in the folder and everything under it'

    UNION ALL

    SELECT 3, 1, '--> Number of Top Level Folders', CAST(COUNT(*) AS NVARCHAR(50)), ''
    FROM tbFolder f0 WITH (NOLOCK)
    CROSS JOIN tbConfiguration pc0 WITH (NOLOCK)
    WHERE f0.ParentFolderId IS NULL AND f0.FolderName <> ISNULL(pc0.PersonalFolderName, '')

    UNION ALL

    SELECT 3,
           1 + CAST(ROW_NUMBER() OVER (ORDER BY tl.FolderName, tl.FolderID) AS INT),
           '--> ' + ISNULL(tl.FolderName, ''),
           CAST(ISNULL(sc.ActiveSecrets, 0) AS NVARCHAR(50)),
           'Folders not inheriting: ' + CAST(ISNULL(fc.NonInheritingFolders, 0) AS NVARCHAR(20)) + ' | Secrets not inheriting: ' + CAST(ISNULL(sc.NonInheritingSecrets, 0) AS NVARCHAR(20))
    FROM tbFolder tl WITH (NOLOCK)
    CROSS JOIN tbConfiguration pc1 WITH (NOLOCK)
    LEFT JOIN (
        SELECT m1.TopName AS TopName,
               COUNT(*) AS ActiveSecrets,
               SUM(CASE WHEN s1.EnableInheritPermissions = 0 THEN 1 ELSE 0 END) AS NonInheritingSecrets
        FROM tbSecret s1 WITH (NOLOCK)
        INNER JOIN (SELECT f.FolderID AS FolderID, f.ParentFolderId AS ParentFolderId, f.EnableInheritPermissions AS EnableInheritPermissions, x.TopName AS TopName, CASE WHEN x.TopName = ISNULL(pc.PersonalFolderName, '') THEN 1 ELSE 0 END AS IsPersonal FROM tbFolder f WITH (NOLOCK) CROSS JOIN tbConfiguration pc WITH (NOLOCK) CROSS APPLY (SELECT LEFT(z.p, CHARINDEX('\', z.p + '\') - 1) AS TopName FROM (SELECT CAST(CASE WHEN LEFT(f.FolderPath, 1) = '\' THEN SUBSTRING(f.FolderPath, 2, 600) ELSE LEFT(f.FolderPath, 600) END AS NVARCHAR(600)) AS p) z) x) m1 ON m1.FolderID = s1.FolderId
        WHERE s1.Active = 1 AND m1.IsPersonal = 0
        GROUP BY m1.TopName
    ) sc ON sc.TopName = tl.FolderName
    LEFT JOIN (
        SELECT m2.TopName AS TopName, COUNT(*) AS NonInheritingFolders
        FROM (SELECT f.FolderID AS FolderID, f.ParentFolderId AS ParentFolderId, f.EnableInheritPermissions AS EnableInheritPermissions, x.TopName AS TopName, CASE WHEN x.TopName = ISNULL(pc.PersonalFolderName, '') THEN 1 ELSE 0 END AS IsPersonal FROM tbFolder f WITH (NOLOCK) CROSS JOIN tbConfiguration pc WITH (NOLOCK) CROSS APPLY (SELECT LEFT(z.p, CHARINDEX('\', z.p + '\') - 1) AS TopName FROM (SELECT CAST(CASE WHEN LEFT(f.FolderPath, 1) = '\' THEN SUBSTRING(f.FolderPath, 2, 600) ELSE LEFT(f.FolderPath, 600) END AS NVARCHAR(600)) AS p) z) x) m2
        WHERE m2.IsPersonal = 0 AND m2.ParentFolderId IS NOT NULL AND m2.EnableInheritPermissions = 0
        GROUP BY m2.TopName
    ) fc ON fc.TopName = tl.FolderName
    WHERE tl.ParentFolderId IS NULL AND tl.FolderName <> ISNULL(pc1.PersonalFolderName, '')

    UNION ALL

    SELECT 4, 0, 'Active Templates', '', 'Value = active secrets using the template'

    UNION ALL

    SELECT 4,
           CAST(ROW_NUMBER() OVER (ORDER BY st.SecretTypeName, st.SecretTypeID) AS INT),
           '--> ' + st.SecretTypeName,
           CAST(COUNT(*) AS NVARCHAR(50)),
           ''
    FROM tbSecretType st WITH (NOLOCK)
    INNER JOIN tbSecret s2 WITH (NOLOCK) ON s2.SecretTypeID = st.SecretTypeID AND s2.Active = 1
    LEFT JOIN (SELECT f.FolderID AS FolderID, f.ParentFolderId AS ParentFolderId, f.EnableInheritPermissions AS EnableInheritPermissions, x.TopName AS TopName, CASE WHEN x.TopName = ISNULL(pc.PersonalFolderName, '') THEN 1 ELSE 0 END AS IsPersonal FROM tbFolder f WITH (NOLOCK) CROSS JOIN tbConfiguration pc WITH (NOLOCK) CROSS APPLY (SELECT LEFT(z.p, CHARINDEX('\', z.p + '\') - 1) AS TopName FROM (SELECT CAST(CASE WHEN LEFT(f.FolderPath, 1) = '\' THEN SUBSTRING(f.FolderPath, 2, 600) ELSE LEFT(f.FolderPath, 600) END AS NVARCHAR(600)) AS p) z) x) m3 ON m3.FolderID = s2.FolderId
    WHERE st.Active = 1 AND ISNULL(m3.IsPersonal, 0) = 0
    GROUP BY st.SecretTypeID, st.SecretTypeName

    UNION ALL

    SELECT 5, 0, 'Permission Inheritance', '', ''

    UNION ALL

    SELECT 5, 1, '--> Folders Not Inheriting Permissions', CAST(COUNT(*) AS NVARCHAR(50)), 'Excludes top level folders'
    FROM (SELECT f.FolderID AS FolderID, f.ParentFolderId AS ParentFolderId, f.EnableInheritPermissions AS EnableInheritPermissions, x.TopName AS TopName, CASE WHEN x.TopName = ISNULL(pc.PersonalFolderName, '') THEN 1 ELSE 0 END AS IsPersonal FROM tbFolder f WITH (NOLOCK) CROSS JOIN tbConfiguration pc WITH (NOLOCK) CROSS APPLY (SELECT LEFT(z.p, CHARINDEX('\', z.p + '\') - 1) AS TopName FROM (SELECT CAST(CASE WHEN LEFT(f.FolderPath, 1) = '\' THEN SUBSTRING(f.FolderPath, 2, 600) ELSE LEFT(f.FolderPath, 600) END AS NVARCHAR(600)) AS p) z) x) m4
    WHERE m4.IsPersonal = 0 AND m4.ParentFolderId IS NOT NULL AND m4.EnableInheritPermissions = 0

    UNION ALL

    SELECT 5, 2, '--> Secrets Not Inheriting Permissions', CAST(COUNT(*) AS NVARCHAR(50)), 'Active secrets that are in a folder'
    FROM tbSecret s3 WITH (NOLOCK)
    INNER JOIN (SELECT f.FolderID AS FolderID, f.ParentFolderId AS ParentFolderId, f.EnableInheritPermissions AS EnableInheritPermissions, x.TopName AS TopName, CASE WHEN x.TopName = ISNULL(pc.PersonalFolderName, '') THEN 1 ELSE 0 END AS IsPersonal FROM tbFolder f WITH (NOLOCK) CROSS JOIN tbConfiguration pc WITH (NOLOCK) CROSS APPLY (SELECT LEFT(z.p, CHARINDEX('\', z.p + '\') - 1) AS TopName FROM (SELECT CAST(CASE WHEN LEFT(f.FolderPath, 1) = '\' THEN SUBSTRING(f.FolderPath, 2, 600) ELSE LEFT(f.FolderPath, 600) END AS NVARCHAR(600)) AS p) z) x) m5 ON m5.FolderID = s3.FolderId
    WHERE s3.Active = 1 AND s3.EnableInheritPermissions = 0 AND m5.IsPersonal = 0

    UNION ALL

    SELECT 6, 0, 'Custom Password Changers', '', 'Created through the audit trail and assigned to a template with active secrets'

    UNION ALL

    SELECT 7, 0, 'Custom Password Requirements', '', 'Created through the audit trail and assigned to a field on a template with active secrets'

    UNION ALL

    SELECT 8, 0, 'Custom Character Sets', '', 'Not standard, and referenced by a requirement on a template with active secrets'

    UNION ALL

    SELECT 5 + iu.Kind,
           CAST(ROW_NUMBER() OVER (PARTITION BY iu.Kind ORDER BY COALESCE(pt.Name, pr2.Name, cs.Name), iu.Id) AS INT),
           '--> ' + ISNULL(COALESCE(pt.Name, pr2.Name, cs.Name), ''),
           '',
           ''
    FROM (
        SELECT DISTINCT v.Kind AS Kind, v.Id AS Id
        FROM (
            SELECT DISTINCT s5.SecretTypeID AS SecretTypeId
            FROM tbSecret s5 WITH (NOLOCK)
            INNER JOIN tbSecretType st5 WITH (NOLOCK) ON st5.SecretTypeID = s5.SecretTypeID AND st5.Active = 1
            LEFT JOIN (SELECT f.FolderID AS FolderID, f.ParentFolderId AS ParentFolderId, f.EnableInheritPermissions AS EnableInheritPermissions, x.TopName AS TopName, CASE WHEN x.TopName = ISNULL(pc.PersonalFolderName, '') THEN 1 ELSE 0 END AS IsPersonal FROM tbFolder f WITH (NOLOCK) CROSS JOIN tbConfiguration pc WITH (NOLOCK) CROSS APPLY (SELECT LEFT(z.p, CHARINDEX('\', z.p + '\') - 1) AS TopName FROM (SELECT CAST(CASE WHEN LEFT(f.FolderPath, 1) = '\' THEN SUBSTRING(f.FolderPath, 2, 600) ELSE LEFT(f.FolderPath, 600) END AS NVARCHAR(600)) AS p) z) x) m6 ON m6.FolderID = s5.FolderId
            WHERE s5.Active = 1 AND ISNULL(m6.IsPersonal, 0) = 0
        ) ut
        INNER JOIN tbSecretType t WITH (NOLOCK) ON t.SecretTypeID = ut.SecretTypeId
        LEFT JOIN tbSecretField sf WITH (NOLOCK) ON sf.SecretTypeID = ut.SecretTypeId AND sf.Active = 1 AND sf.PasswordRequirementId IS NOT NULL
        LEFT JOIN tbPasswordRequirement pr WITH (NOLOCK) ON pr.PasswordRequirementId = sf.PasswordRequirementId
        LEFT JOIN tbPasswordRequirementRule rl WITH (NOLOCK) ON rl.PasswordRequirementId = pr.PasswordRequirementId
        CROSS APPLY (VALUES (1, t.PasswordTypeId), (2, pr.PasswordRequirementId), (3, pr.AllowedCharacterSetId), (3, rl.CharacterSetId)) v(Kind, Id)
        WHERE v.Id IS NOT NULL
    ) iu
    LEFT JOIN tbPasswordType pt WITH (NOLOCK) ON iu.Kind = 1 AND pt.PasswordTypeId = iu.Id
    LEFT JOIN tbPasswordRequirement pr2 WITH (NOLOCK) ON iu.Kind = 2 AND pr2.PasswordRequirementId = iu.Id
    LEFT JOIN tbCharacterSet cs WITH (NOLOCK) ON iu.Kind = 3 AND cs.CharacterSetId = iu.Id
    WHERE (iu.Kind = 1 AND pt.PasswordTypeId IS NOT NULL
           AND EXISTS (SELECT 1 FROM tbPasswordTypeAudit a1 WITH (NOLOCK) WHERE a1.PasswordTypeId = pt.PasswordTypeId AND a1.Action LIKE '%EATE'))
       OR (iu.Kind = 2 AND pr2.PasswordRequirementId IS NOT NULL
           AND EXISTS (SELECT 1 FROM tbPasswordRequirementAudit a2 WITH (NOLOCK) WHERE a2.PasswordRequirementId = pr2.PasswordRequirementId AND a2.Action LIKE '%EATE'))
       OR (iu.Kind = 3 AND cs.CharacterSetId IS NOT NULL AND cs.IsStandard = 0 AND cs.Active = 1)

    UNION ALL

    SELECT 9, 0, 'Active Scripts', '', 'Comment = script type'

    UNION ALL

    SELECT 9,
           CAST(ROW_NUMBER() OVER (ORDER BY scr.Name, scr.ScriptId) AS INT),
           '--> ' + ISNULL(scr.Name, ''),
           '',
           ISNULL(stp.Name, '')
    FROM tbScript scr WITH (NOLOCK)
    LEFT JOIN tbScriptType stp WITH (NOLOCK) ON stp.ScriptTypeId = scr.ScriptTypeId
    WHERE scr.Active = 1
) r
ORDER BY r.Sec, r.Seq
