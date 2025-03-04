select '[' + foldername+ ']' as [Folder Name in Brackets],FolderPath,f.FolderID
from tbfolder f
Where foldername like ' %' or  foldername like '% '
