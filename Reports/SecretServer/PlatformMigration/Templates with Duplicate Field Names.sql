	SELECT t.SecretTypeid,secrettypename as [Template],t.Active as [Template Active],sf.SecretFieldID, sf.SecretFieldName,sf.Active as [Field Active]
		FROM tbSecretType t
		JOIN tbSecretField sf ON sf.SecretTypeID = t.SecretTypeID
		LEFT JOIN (
			SELECT SecretTypeID, FieldSlugName
			FROM tbSecretField
			GROUP BY SecretTypeID, FieldSlugName
			HAVING COUNT(*) > 1
		) slug_dups ON slug_dups.SecretTypeID = sf.SecretTypeID AND slug_dups.FieldSlugName = sf.FieldSlugName
		LEFT JOIN (
			SELECT SecretTypeID, SecretFieldName
			FROM tbSecretField
			GROUP BY SecretTypeID, SecretFieldName
			HAVING COUNT(*) > 1
		) name_dups ON name_dups.SecretTypeID = sf.SecretTypeID AND name_dups.SecretFieldName = sf.SecretFieldName
		WHERE slug_dups.FieldSlugName IS NOT NULL OR name_dups.SecretFieldName IS NOT NULL
		order by SecretTypeID
