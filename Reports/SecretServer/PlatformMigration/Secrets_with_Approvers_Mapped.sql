SELECT
       s.secretid AS [SecretId]
       ,s.secretname AS [Secret Name]
	,ISNULL(f.FolderPath, 'No folder assigned') AS [Folder Path]
       ,CASE 
       WHEN g.IsPersonal = 1 THEN u.DisplayName
       WHEN g.IsPersonal = 0 THEN g.GroupName
       ELSE 'Unknown'
       End AS [Approvers]
       ,CASE
       WHEN g.IsPersonal = 1 AND g.DomainId IS NULL THEN 'Local Account'
       WHEN g.IsPersonal = 1 AND g.DomainId IS NOT NULL THEN 'AD Account'
       WHEN g.IsPersonal = 0 AND g.DomainId IS NULL THEN 'Local Group'
       WHEN g.IsPersonal = 0 AND g.DomainId IS NOT NULL THEN 'AD Group'
       ELSE 'Unknown'
       End AS [Approver Type]
       ,u.EmailAddress AS [Email]


FROM tbsecret s

LEFT JOIN tbfolder f on s.folderid = f.folderid
INNER JOIN tbSecretGroupApproval sga on s.SecretID = sga.SecretId
INNER JOIN vGroupDisplayName gdn on sga.GroupId = gdn.GroupId
INNER JOIN tbGroup g on sga.GroupId = g.GroupID
INNER JOIN tbUserGroup ug on g.GroupID = ug.GroupID
INNER JOIN tbuser u on ug.UserID = u.UserId

WHERE s.RequireApprovalForAccess = 1 AND s.Active = 1 AND s.SecretPolicyId IS NULL 

/*
.PURPOSE
Returns a list of active secrets requiring approval, with the approvers mapped. This will help re-establish approvers on secrets with approvals directly enabled and not via policy. 
*/
