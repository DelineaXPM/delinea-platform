
<#
.SYNOPSIS
Script to migrate reports from a source Secret Server tenant to a destination tenant.

.DESCRIPTION
This script automates the migration of reports from one Secret Server tenant to another.
It handles categories, reports, and ensures no duplicates are created in the destination tenant.
The script includes robust logging and error handling to facilitate a smooth migration process.

The script is modularized using functions for better readability and maintainability.

.PARAMETER sourceRootUrl
The root URL of the source Secret Server tenant (e.g., 'source.secretservercloud.com').

.PARAMETER destinationRootUrl
The root URL of the destination Secret Server tenant (e.g., 'destination.secretservercloud.com').

.PARAMETER outputDirectory
The directory where report JSON files and logs will be saved.

.FUNCTIONS

- **Log-Message**
  - Logs messages to both the console and a log file.
  - Parameters:
    - `Message`: The message to log.
    - `Color`: (Optional) The color of the console text.

- **Authenticate-Tenant**
  - Authenticates with a tenant and obtains an access token.
  - Parameters:
    - `tenantName`: A friendly name for the tenant (e.g., 'source' or 'destination').
    - `tokenUrl`: The OAuth2 token URL for the tenant.
  - Returns:
    - A hashtable containing headers with the access token and username.

- **Get-Categories**
  - Fetches all report categories from a tenant.
  - Parameters:
    - `apiUrl`: The API base URL for the tenant.
    - `headers`: The headers containing the access token.

- **Create-Category**
  - Creates a report category in the destination tenant.
  - Parameters:
    - `apiUrl`: The API base URL for the destination tenant.
    - `headers`: The headers containing the access token.
    - `sourceCategory`: The category object from the source tenant.

- **Process-Categories**
  - Processes categories by ensuring all source categories exist in the destination tenant.
  - Parameters:
    - `apiSource`: The API base URL for the source tenant.
    - `apiDestination`: The API base URL for the destination tenant.
    - `headersSource`: The headers containing the access token for the source tenant.
    - `headersDestination`: The headers containing the access token for the destination tenant.
    - `categoryIds`: An array of category IDs to process (empty array for all categories).
  - Returns:
    - A hashtable mapping source category IDs to destination category IDs.

- **Get-AllReports**
  - Fetches all reports from a tenant.
  - Parameters:
    - `apiUrl`: The API base URL for the tenant.
    - `headers`: The headers containing the access token.

- **Get-ReportDetails**
  - Fetches detailed information about a specific report.
  - Parameters:
    - `apiUrl`: The API base URL for the tenant.
    - `headers`: The headers containing the access token.
    - `reportId`: The ID of the report.

- **Save-ReportToFile**
  - Saves report details to a JSON file.
  - Parameters:
    - `reportDetails`: The report details object.
    - `reportId`: The ID of the report.

- **Create-Report**
  - Creates a report in the destination tenant.
  - Parameters:
    - `apiUrl`: The API base URL for the destination tenant.
    - `headers`: The headers containing the access token.
    - `reportData`: The report data to be created.

- **Process-Reports**
  - Processes reports by migrating them from the source to the destination tenant.
  - Parameters:
    - `apiSource`: The API base URL for the source tenant.
    - `apiDestination`: The API base URL for the destination tenant.
    - `headersSource`: The headers containing the access token for the source tenant.
    - `headersDestination`: The headers containing the access token for the destination tenant.
    - `categoryIds`: An array of category IDs to process.
    - `categoryIdMap`: A hashtable mapping source category IDs to destination category IDs.
    - `reportIds`: An array of report IDs to process.

.EXAMPLE
# Run the script with default settings.
.\MigrateReports.ps1

.NOTES
Author: Delinea PS
Date: 9/19/2024
#>

# Customizable Variables
$sourceRootUrl = 'XXX.secretservercloud.com'       # Source tenant root URL (Ensure this is a valid URL)
$destinationRootUrl = 'XXX.secretservercloud.com'  # Destination tenant root URL (Ensure this is a valid URL)
$outputDirectory = 'C:\temp\SQL_Reports'  # Directory for saving report details and logs

# Check if the log file already exists
if (-not (Test-Path -Path $logFilePath)) {
    # Create a new log file if it doesn't exist
    New-Item -Path $logFilePath -ItemType File -Force | Out-Null
    Add-Content -Path $logFilePath -Value "Migration Log - $(Get-Date)"
    Add-Content -Path $logFilePath -Value "----------------------------------------`n"
} else {
    # If the log file exists, just append a new log section header
    Add-Content -Path $logFilePath -Value "`nMigration Log Continued - $(Get-Date)"
    Add-Content -Path $logFilePath -Value "----------------------------------------`n"
}


# Function to log messages to both console and log file
function Log-Message {
    param (
        [string]$Message,
        [ConsoleColor]$Color = [ConsoleColor]::White
    )
    Write-Host $Message -ForegroundColor $Color
    Add-Content -Path $logFilePath -Value $Message
}

# Function to authenticate with a tenant and get an access token
function Authenticate-Tenant {
    param (
        [string]$tenantName,
        [string]$tokenUrl
    )
    $credential = Get-Credential -Message "Enter your username and password for the $tenantName tenant"

    $username = $credential.UserName
    $password = $credential.GetNetworkCredential().Password

    $tokenRequestBody = @{
        grant_type = 'password'
        username   = $username
        password   = $password
    }

    $tokenResponse = Invoke-RestMethod -Method Post -Uri $tokenUrl -Body $tokenRequestBody -ContentType 'application/x-www-form-urlencoded'

    if ($tokenResponse -and $tokenResponse.access_token) {
        $accessToken = $tokenResponse.access_token
        Log-Message "Authentication with $tenantName tenant successful." ([ConsoleColor]::Green)
        return @{
            Headers = @{
                'Authorization' = "Bearer $accessToken"
                'Content-Type'  = 'application/json'
            }
            Username = $username
        }
    } else {
        Log-Message "Failed to authenticate with $tenantName tenant." ([ConsoleColor]::Red)
        Log-Message "Response: $($tokenResponse | ConvertTo-Json -Depth 5)"
        Exit
    }
}

# Function to fetch all categories from a tenant
function Get-Categories {
    param (
        [string]$apiUrl,
        [hashtable]$headers
    )
    $categoriesUrl = "$apiUrl/v1/reports/categories"
    $categories = Invoke-RestMethod -Method Get -Uri $categoriesUrl -Headers $headers
    return $categories
}

# Function to create a category in the destination tenant
function Create-Category {
    param (
        [string]$apiUrl,
        [hashtable]$headers,
        [object]$sourceCategory
    )
    Log-Message "Creating category '$($sourceCategory.name)' in the destination tenant..."
    $createCategoryBody = @{
        data = @{
            reportCategoryName        = $sourceCategory.name
            reportCategoryDescription = $sourceCategory.description
            sortOrder                 = 0  # Adjust as needed
        }
    }
    $createCategoryBodyJson = ConvertTo-Json -InputObject $createCategoryBody -Depth 10

    $createCategoryUrl = "$apiUrl/v1/reports/categories"
    try {
        $createCategoryResponse = Invoke-RestMethod -Method Post -Uri $createCategoryUrl -Headers $headers -Body $createCategoryBodyJson -ContentType 'application/json'

        $destinationCategory = @{
            id          = $createCategoryResponse.data.id
            name        = $createCategoryResponse.data.name
            description = $createCategoryResponse.data.description
        }
        Log-Message "Category '$($sourceCategory.name)' created with ID $($destinationCategory.id)." ([ConsoleColor]::Green)
        return $destinationCategory
    } catch {
        Log-Message "Failed to create category '$($sourceCategory.name)' in the destination tenant." ([ConsoleColor]::Red)
        Log-Message "Error: $_"

        # Capture the response content safely
        if ($_.Exception.Response -and $_.Exception.Response.Content) {
            try {
                $responseContent = $_.Exception.Response.Content.ReadAsStringAsync().Result
                Log-Message "Response Body: $responseContent"
            } catch {
                Log-Message "Unable to read response content."
            }
        } else {
            Log-Message "No response body available."
        }
        Exit
    }
}

# Function to fetch all reports from a tenant
function Get-AllReports {
    param (
        [string]$apiUrl,
        [hashtable]$headers
    )
    $allReports = @()
    $take = 100
    $skip = 0
    $total = 1  # Initialize with a value greater than zero

    while ($skip -lt $total) {
        $reportsUrl = "$apiUrl/v1/reports?skip=$skip&take=$take"
        $response = Invoke-RestMethod -Method Get -Uri $reportsUrl -Headers $headers

        if ($response.success -eq $true -and $response.records) {
            $allReports += $response.records
        } else {
            Log-Message "Failed to fetch reports from '$apiUrl'." ([ConsoleColor]::Red)
            Log-Message "Response: $($response | ConvertTo-Json -Depth 10)"
            break
        }

        $total = $response.total
        $skip += $take
    }

    return $allReports
}

# Function to fetch report details from the source tenant
function Get-ReportDetails {
    param (
        [string]$apiUrl,
        [hashtable]$headers,
        [int]$reportId
    )
    $reportDetailsUrl = "$apiUrl/v1/reports/$reportId"
    try {
        $reportDetailsResponse = Invoke-RestMethod -Method Get -Uri $reportDetailsUrl -Headers $headers
        if ($reportDetailsResponse) {
            return $reportDetailsResponse
        } else {
            Log-Message "Failed to fetch details for report ID ${reportId}." ([ConsoleColor]::Red)
            return $null
        }
    } catch {
        Log-Message "Error fetching details for report ID ${reportId}: $_" ([ConsoleColor]::Red)
        return $null
    }
}

# Function to save report details to a JSON file
function Save-ReportToFile {
    param (
        [object]$reportDetails,
        [int]$reportId
    )
    # Clean the report name to create a valid file name
    $originalReportName = $reportDetails.name
    # Remove invalid characters from the file name
    $invalidChars = [System.IO.Path]::GetInvalidFileNameChars()
    $cleanReportName = $originalReportName -replace '[{0}]' -f ([Regex]::Escape(($invalidChars -join '')))

    $fileName = [IO.Path]::Combine($outputDirectory, "${cleanReportName}_ID${reportId}.json")

    # Convert the report details to JSON with proper encoding
    $jsonSettings = @{
        InputObject = $reportDetails
        Depth       = 10
        Compress    = $false
    }
    $jsonContent = ConvertTo-Json @jsonSettings

    # Write the JSON content to the file with UTF8 encoding without BOM
    [System.IO.File]::WriteAllText($fileName, $jsonContent, [System.Text.Encoding]::UTF8)

    Log-Message "Saved report ID ${reportId} to file '$fileName'."
}

# Function to create a report in the destination tenant
function Create-Report {
    param (
        [string]$apiUrl,
        [hashtable]$headers,
        [object]$reportData
    )
    $bodyJson = ConvertTo-Json -InputObject $reportData -Depth 10

    # Endpoint to create a new report in the destination tenant
    $createReportUrl = "$apiUrl/v1/reports"

    # Create the report in the destination tenant
    Log-Message "Creating report '$($reportData.name)' in the destination tenant..."

    try {
        $createResponse = Invoke-RestMethod -Method Post -Uri $createReportUrl -Headers $headers -Body $bodyJson -ContentType 'application/json'

        Log-Message "Successfully created report '$($reportData.name)' in the destination tenant." ([ConsoleColor]::Green)
    } catch {
        Log-Message "Failed to create report '$($reportData.name)' in the destination tenant." ([ConsoleColor]::Red)
        Log-Message "Error: $_"

        # Capture the response content safely
        if ($_.Exception.Response -and $_.Exception.Response.Content) {
            try {
                $responseContent = $_.Exception.Response.Content.ReadAsStringAsync().Result
                Log-Message "Response Body: $responseContent"

                # Save error details to a file
                $errorFileName = [IO.Path]::Combine($outputDirectory, "Error_${reportData.name}.txt")
                [System.IO.File]::WriteAllText($errorFileName, $responseContent, [System.Text.Encoding]::UTF8)
                Log-Message "Error details saved to '$errorFileName'."
            } catch {
                Log-Message "Unable to read response content."
            }
        } else {
            Log-Message "No response body available."
        }
    }
}

# Function to process categories
function Process-Categories {
    param (
        [string]$apiSource,
        [string]$apiDestination,
        [hashtable]$headersSource,
        [hashtable]$headersDestination,
        [array]$categoryIds
    )
    Log-Message "Fetching categories from the source tenant..."
    $sourceCategories = Get-Categories -apiUrl $apiSource -headers $headersSource
    Log-Message "Number of categories fetched from source tenant: $($sourceCategories.Count)"

    if ($categoryIds.Count -gt 0) {
        # Filter categories based on user input
        $sourceCategories = $sourceCategories | Where-Object { $categoryIds -contains $_.id }
    }

    Log-Message "Fetching categories from the destination tenant..."
    $destinationCategories = Get-Categories -apiUrl $apiDestination -headers $headersDestination
    Log-Message "Number of categories fetched from destination tenant: $($destinationCategories.Count)"

    # Create a hashtable to map source category IDs to destination category IDs
    $categoryIdMap = @{}

    # Ensure that all categories from the source exist in the destination
    foreach ($sourceCategory in $sourceCategories) {
        $destinationCategory = $destinationCategories | Where-Object { $_.name.ToLower() -eq $sourceCategory.name.ToLower() }
        if (-not $destinationCategory) {
            # Category does not exist in destination, create it
            $destinationCategory = Create-Category -apiUrl $apiDestination -headers $headersDestination -sourceCategory $sourceCategory
            # Refresh destination categories
            $destinationCategories = Get-Categories -apiUrl $apiDestination -headers $headersDestination
        } else {
            Log-Message "Category '$($sourceCategory.name)' already exists in the destination tenant." ([ConsoleColor]::Yellow)
        }

        # Add to category ID map
        $categoryIdMap[$sourceCategory.id] = $destinationCategory.id
    }

    return $categoryIdMap
}

# Function to process categories
function Process-Categories {
    param (
        [string]$apiSource,
        [string]$apiDestination,
        [hashtable]$headersSource,
        [hashtable]$headersDestination,
        [array]$categoryIds
    )
    
    Log-Message "Fetching categories from the source tenant..."
    $sourceCategories = Get-Categories -apiUrl $apiSource -headers $headersSource
    Log-Message "Number of categories fetched from source tenant: $($sourceCategories.Count)"

    if ($categoryIds.Count -gt 0) {
        # Filter categories based on user input
        $sourceCategories = $sourceCategories | Where-Object { $categoryIds -contains $_.id }
    }

    Log-Message "Fetching categories from the destination tenant..."
    $destinationCategories = Get-Categories -apiUrl $apiDestination -headers $headersDestination
    Log-Message "Number of categories fetched from destination tenant: $($destinationCategories.Count)"

    # Create a hashtable to map source category IDs to destination category IDs
    $categoryIdMap = @{}

    # Ensure that all categories from the source exist in the destination
    foreach ($sourceCategory in $sourceCategories) {
        $destinationCategory = $destinationCategories | Where-Object { $_.name.ToLower() -eq $sourceCategory.name.ToLower() }
        if (-not $destinationCategory) {
            # Category does not exist in destination, create it
            $destinationCategory = Create-Category -apiUrl $apiDestination -headers $headersDestination -sourceCategory $sourceCategory
            Log-Message "Created new category: $($sourceCategory.name)"
        } else {
            Log-Message "Category '$($sourceCategory.name)' already exists in the destination tenant." ([ConsoleColor]::Yellow)
        }

        # Add to category ID map
        $categoryIdMap[$sourceCategory.id] = $destinationCategory.id
    }

    # Re-query the destination categories to ensure all created categories are included
    Log-Message "Re-fetching categories from the destination tenant after creation..."
    $destinationCategories = Get-Categories -apiUrl $apiDestination -headers $headersDestination

    # Update categoryIdMap with any newly created categories
    foreach ($sourceCategory in $sourceCategories) {
        $destinationCategory = $destinationCategories | Where-Object { $_.name.ToLower() -eq $sourceCategory.name.ToLower() }
        if ($destinationCategory) {
            $categoryIdMap[$sourceCategory.id] = $destinationCategory.id
        }
    }

    return $categoryIdMap
}

# Function to process reports
function Process-Reports {
    param (
        [string]$apiSource,
        [string]$apiDestination,
        [hashtable]$headersSource,
        [hashtable]$headersDestination,
        [array]$categoryIds,
        [hashtable]$categoryIdMap,
        [array]$reportIds
    )
    
    foreach ($reportId in $reportIds) {
        Log-Message "`nProcessing report ID ${reportId}..."

        # Fetch report details from the source tenant
        $reportDetails = Get-ReportDetails -apiUrl $apiSource -headers $headersSource -reportId $reportId
        if (-not $reportDetails) {
            continue
        }

        Log-Message "Downloaded details for report ID ${reportId}: $($reportDetails.name)"

        # Save the report details to a file
        Save-ReportToFile -reportDetails $reportDetails -reportId $reportId

        # Prepare the request body for creating the report in the destination tenant
        # Remove read-only or unnecessary fields
        $reportData = $reportDetails | Select-Object -ExcludeProperty id, systemReport, createdBy, createdDate, modifiedBy, modifiedDate

        # Map the categoryId to the destination categoryId
        $sourceCategoryId = $reportData.categoryId
        if ($categoryIdMap.ContainsKey($sourceCategoryId)) {
            $destinationCategoryId = $categoryIdMap[$sourceCategoryId]
            $reportData.categoryId = [int]$destinationCategoryId
        } else {
            Log-Message "Category ID $sourceCategoryId not found in category ID map. Skipping report." ([ConsoleColor]::Yellow)
            continue
        }

        # Build the request body according to the required format
        $body = @{
            name              = $reportData.name
            description       = $reportData.description
            categoryId        = $reportData.categoryId
            enabled           = $reportData.enabled
            reportSql         = $reportData.reportSql
            chartType         = $reportData.chartType
            is3DReport        = $reportData.is3DReport
            pageSize          = $reportData.pageSize
            useDatabasePaging = $reportData.useDatabasePaging
        }

        # Create the report in the destination tenant
        Create-Report -apiUrl $apiDestination -headers $headersDestination -reportData $body

        Log-Message "Process completed for report ID ${reportId}."
    }

    Log-Message "`nAll reports have been processed."
}


# Build API and token URLs from root URLs
$apiSource = "https://$sourceRootUrl/api"       # Source tenant API URL
$apiDestination = "https://$destinationRootUrl/api"  # Destination tenant API URL

# OAuth2 token endpoints (without the '/api' segment)
$tokenUrlSource = "https://$sourceRootUrl/oauth2/token"
$tokenUrlDestination = "https://$destinationRootUrl/oauth2/token"  # Destination token URL

# Authenticate with the source and destination tenants
$sourceAuth = Authenticate-Tenant -tenantName "source" -tokenUrl $tokenUrlSource
$destinationAuth = Authenticate-Tenant -tenantName "destination" -tokenUrl $tokenUrlDestination

$headersSource = $sourceAuth.Headers
$headersDestination = $destinationAuth.Headers

# Prompt for category processing options
Log-Message ""
Log-Message "Category Processing Options:"
Log-Message "1. Process a single category ID"
Log-Message "2. Process multiple category IDs"
Log-Message "3. Process all categories"
$categoryChoice = Read-Host "Enter your choice (1, 2, or 3)"

switch ($categoryChoice) {
    '1' {
        $categoryIdInput = Read-Host "Enter the category ID to process"
        $categoryIds = @($categoryIdInput.Trim())
    }
    '2' {
        $categoryIdsInput = Read-Host "Enter category IDs separated by commas (e.g., 1,2,3)"
        $categoryIds = $categoryIdsInput -split ',' | ForEach-Object { $_.Trim() }
    }
    '3' {
        $categoryIds = @()  # Empty array signifies all categories
    }
    default {
        Log-Message "Invalid choice. Exiting." ([ConsoleColor]::Red)
        Exit
    }
}

# Process categories and get the category ID map
$categoryIdMap = Process-Categories -apiSource $apiSource -apiDestination $apiDestination -headersSource $headersSource -headersDestination $headersDestination -categoryIds $categoryIds

# Prompt for report processing options
Log-Message ""
Log-Message "Report Processing Options:"
Log-Message "1. Process a single report ID"
Log-Message "2. Process multiple report IDs"
Log-Message "3. Process all reports"
$reportChoice = Read-Host "Enter your choice (1, 2, or 3)"

switch ($reportChoice) {
    '1' {
        $reportIdInput = Read-Host "Enter the report ID to process"
        $reportIds = @($reportIdInput.Trim())
    }
    '2' {
        $reportIdsInput = Read-Host "Enter report IDs separated by commas (e.g., 221,222,223)"
        $reportIds = $reportIdsInput -split ',' | ForEach-Object { $_.Trim() }
    }
    '3' {
        # Fetch all reports from the source tenant
        Log-Message "Fetching all reports from the source tenant..."
        $sourceReports = Get-AllReports -apiUrl $apiSource -Headers $headersSource
        Log-Message "Number of reports fetched from source tenant: $($sourceReports.Count)"

        # Fetch all reports from the destination tenant
        Log-Message "Fetching all reports from the destination tenant..."
        $destinationReports = Get-AllReports -apiUrl $apiDestination -Headers $headersDestination
        Log-Message "Number of reports fetched from destination tenant: $($destinationReports.Count)"

        # Create a list of destination report names for quick lookup (case-insensitive)
        $destinationReportNamesHash = @{}
        $destinationReports.name | ForEach-Object { $destinationReportNamesHash[$_.ToLower()] = $true }

        # Identify reports that need to be migrated
        $reportsToMigrate = $sourceReports | Where-Object { -not $destinationReportNamesHash.ContainsKey($_.name.ToLower()) }

        # Filter reports based on selected categories
        if ($categoryIds.Count -gt 0) {
            $reportsToMigrate = $reportsToMigrate | Where-Object { $categoryIds -contains $_.categoryId }
        }

        # Log the number of reports to migrate
        Log-Message "Number of reports to migrate: $($reportsToMigrate.Count)"

        # Extract the IDs of the reports to process
        $reportIds = $reportsToMigrate.id
    }
    default {
        Log-Message "Invalid choice. Exiting." ([ConsoleColor]::Red)
        Exit
    }
}

if ($reportIds.Count -eq 0) {
    Log-Message "No new reports to migrate." ([ConsoleColor]::Yellow)
    Exit
}

# Process reports
Process-Reports -apiSource $apiSource -apiDestination $apiDestination -headersSource $headersSource -headersDestination $headersDestination -categoryIds $categoryIds -categoryIdMap $categoryIdMap -reportIds $reportIds

# Prompt to delete JSON files
$deleteChoice = Read-Host "Do you want to delete the JSON files saved in '$outputDirectory'? (Y/N)"
if ($deleteChoice -match '^[Yy]$') {
    try {
        Remove-Item -Path "$outputDirectory\*.json" -Force
        Log-Message "All JSON files have been deleted from '$outputDirectory'." ([ConsoleColor]::Green)
    } catch {
        Log-Message "Failed to delete JSON files. Error: $_" ([ConsoleColor]::Red)
    }
} else {
    Log-Message "JSON files were not deleted and remain in '$outputDirectory'."
}

Log-Message "`nMigration process completed. Log file saved at '$logFilePath'."
