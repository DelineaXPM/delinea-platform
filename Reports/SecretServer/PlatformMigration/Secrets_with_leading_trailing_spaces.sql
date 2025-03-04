select '[' + SecretName+ ']' as [Secret Name in Brackets],s.secretid,s.secretName,f.folderpath
from tbsecret s
LEFT JOIN tbFolder f on s.FolderID = f.FolderID
Where secretname like ' %' or  secretname like '% '
