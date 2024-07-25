SELECT    ISNULL(fp.FolderPath, 'No folder assigned')  as [Folder Path]   
			,s.SecretName as [Name] 
			,s.SecretID as [id]  
			,s.EnableInheritSecretPolicy AS [Inheriting Policy]
			,sp.SecretPolicyName
			,sp.SecretPolicyID        
			,CASE WHEN NULLIF(sp.SecretPolicyDescription,'') IS NULL THEN '' ELSE LEFT(sp.SecretPolicyDescription, 75) + CASE WHEN LEN(sp.SecretPolicyDescription) > 75 THEN '...' ELSE '' END END AS [Policy Description]
			 ,'secret' as [Type]
			 FROM tbSecret s WITH (NOLOCK)         
			 INNER JOIN tbSecretType st WITH (NOLOCK)      
				ON s.SecretTypeId = st.SecretTypeId     
			 LEFT JOIN vFolderPath fp WITH (NOLOCK)      
				ON s.FolderId = fp.FolderId     
			 LEFT JOIN tbFolder f WITH (NOLOCK)      
				ON s.FolderId = f.FolderId   
			 JOIN tbSecretPolicy sp WITH (NOLOCK)
				ON sp.SecretPolicyId = s.SecretPolicyId  
			 WHERE     
			 s.Active = 1 AND s.EnableInheritSecretPolicy = 0
			 AND s.SecretPolicyId IS NOT NULL	
			 		 
UNION 
SELECT    ISNULL(fp.FolderPath, 'No folder assigned') as [Path]    
			,f.FolderName as[Name]
			,f.folderid as [id]
			,f.EnableInheritSecretPolicy AS [Inheriting Policy] 
			,sp.SecretPolicyName,
			sp.SecretPolicyId
			,CASE WHEN NULLIF(sp.SecretPolicyDescription,'') IS NULL THEN '' ELSE LEFT(sp.SecretPolicyDescription, 75) + CASE WHEN LEN(sp.SecretPolicyDescription) > 75 THEN '...' ELSE '' END END AS [Policy Description]
			,'Folder' as [Type]
			FROM vFolderPath fp WITH (NOLOCK)    
			 LEFT JOIN tbFolder f WITH (NOLOCK)      
				ON f.FolderId = fp.FolderId   
			 JOIN tbSecretPolicy sp WITH (NOLOCK)
				ON sp.SecretPolicyId = f.SecretPolicyId  
			 WHERE     		 
			f.EnableInheritSecretPolicy  = 0
			 ORDER BY 1, 2, 3
			 
/*
.PURPOSE
Returns all Direct Policy assignments and Defines the
assignment type
*/