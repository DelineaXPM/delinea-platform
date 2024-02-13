$SearchWords = @("Password", "Username", "Pass")
$TargetServer = ($args[0].Split("."))[0]
$Path = \\$TargetServer\c$\TargetFolder #ChangeMe

# Create the results folder if it doesn't exist
$ResultFolder = \\sspm-de.delinea.intra\c$\Discovered_PasswordsInFiles\ #ChangeMe
if (!(Test-Path $ResultFolder)) {
    New-Item -ItemType Directory -Path $ResultFolder | Out-Null
}

# Get the current date and time for the filename
$Date = Get-Date -Format "ddMMyyyy"
$Time = Get-Date -Format "HHmm"

# Generate the filename based on the current date, time and server name
$Filename = "Result_$TargetServer`_$Time-$Date.txt"
$FilePath = Join-Path -Path $ResultFolder -ChildPath $Filename

# Search for each keyword in the files in the specified path
$results = foreach ($sw in $SearchWords) {
    Get-ChildItem -Path $Path -Recurse -Include "*.txt", "*.config", "*.ini" |
    Select-String -Pattern "$sw" |
    Select-Object Path, LineNumber, @{n = 'SearchWord'; e = { $sw } }
}

# Check if there are any results before creating the file
if ($results) {
    $results | Out-File $FilePath -Append
}
else {
    Write-Host "No results found for search terms $($SearchWords -join ", ") in path $Path"
}