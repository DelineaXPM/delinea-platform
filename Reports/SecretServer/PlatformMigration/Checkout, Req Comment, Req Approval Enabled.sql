SELECT
	s.SecretID,
	ISNULL(f.FolderPath, 'No folder assigned') as [Folder Path],     
	s.SecretName AS [Secret Name],

	CASE
	WHEN s.CheckOutEnabled = 1 THEN 'Require Checkout'
	END AS [Feature]

FROM tbSecret s WITH (NOLOCK)         
	INNER JOIN tbSecretType st WITH (NOLOCK)      
	ON s.SecretTypeId = st.SecretTypeId     
	LEFT JOIN tbFolder f WITH (NOLOCK)      
	ON s.FolderId = f.FolderId     
		
WHERE
	s.Active = 1 
	AND 
	s.CheckOutEnabled = 1

	UNION ALL 
	
SELECT
	s.SecretID,
	ISNULL(f.FolderPath, 'No folder assigned') as [Folder Path],     
	s.SecretName AS [Secret Name],

	CASE
	WHEN s.RequireApprovalForAccess = 1 THEN 'Require Approval'
	END AS [Feature]

FROM tbSecret s WITH (NOLOCK)         
	INNER JOIN tbSecretType st WITH (NOLOCK)      
	ON s.SecretTypeId = st.SecretTypeId     
	LEFT JOIN tbFolder f WITH (NOLOCK)      
	ON s.FolderId = f.FolderId     
		
WHERE
	s.Active = 1 
	AND 
	s.RequireApprovalForAccess = 1

	UNION ALL 

SELECT
	s.SecretID,
	ISNULL(f.FolderPath, 'No folder assigned') as [Folder Path],     
	s.SecretName AS [Secret Name],

	CASE
	WHEN s.RequireViewComment = 1 THEN 'Require Comment'
	END AS [Feature]

FROM tbSecret s WITH (NOLOCK)         
	INNER JOIN tbSecretType st WITH (NOLOCK)      
	ON s.SecretTypeId = st.SecretTypeId     
	LEFT JOIN tbFolder f WITH (NOLOCK)      
	ON s.FolderId = f.FolderId     
		
WHERE
	s.Active = 1 
	AND 
	s.RequireViewComment = 1

ORDER BY SecretID ASC
