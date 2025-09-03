SELECT 
    u.UserName AS Username,
    u.DisplayName AS DisplayName,
    u.EmailAddress AS EmailAddress,
    u.Created AS AccountCreated,
    u.LastLogin AS LastLogin,
    u.DomainId AS DomainId,
    u.AdGuid AS ADGuid,
    CASE 
        WHEN u.IsApplicationAccount = 1 AND u.DomainId IS NULL THEN 'Local Application'
        WHEN u.IsApplicationAccount = 1 AND u.DomainId IS NOT NULL THEN 'Domain Application'
        WHEN (u.IsApplicationAccount = 0 OR u.IsApplicationAccount IS NULL) AND u.DomainId IS NULL THEN 'Local'
        WHEN (u.IsApplicationAccount = 0 OR u.IsApplicationAccount IS NULL) AND u.DomainId IS NOT NULL THEN 'Domain'
        ELSE 'Unknown'
    END AS AccountType
FROM tbUser u
WHERE u.Enabled = 1
ORDER BY u.UserName
