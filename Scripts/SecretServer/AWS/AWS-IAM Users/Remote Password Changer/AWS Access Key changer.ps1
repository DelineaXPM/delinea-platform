<#
.Synopsis
   The script will rotate AWS access keys on a scheduled basis with the help of Secret Server
.DESCRIPTION
   This cmdlet will take input from Secret Server to connect to AWS and generate new access keys per AWS best practices. The old keys will be set
   to inactive, new keys will be pushed to Secret Server via api calls. 
.EXAMPLE
    Using integrated authentication
   New-AccessKeys -AccessKey <myaccesskey> -SecretKey <mySecretKey> -AWSUserName <myAwsUser> -SecretId <mySecretID> -Url <mySecretServerUrl>
.EXAMPLE
    Using Token Authentication
   New-AccessKeys -AccessKey <myAwsAccesskey> -SecretKey <myAwsSecretKey> -AWSUserName <myAwsUser> -SecretId <mySecretID> -Url <mySecretServerUrl> -UserName <mySecretServerUser> -Password <mySecretServerPassword>
.NOTES
   This cmdlet supports authenticating to Secret Server's API via Windows Integrated Authentication and token authentication. Before using Windows Integrated Authentication you'd have to set it
   up in IIS. The AWS access key user will need proper permissions to create, update, and delete keys
#>
function New-AccessKeys {
    param(
        [CmdletBinding(DefaultParameterSetName="win_auth")]
        [Parameter(Mandatory=$true)]
        [string]$AccessKey,
        [Parameter(Mandatory=$true)]
        [string]$SecretKey,
        [parameter(Mandatory=$true)]
        [string]$AWSUserName,
        [parameter(Mandatory=$true)]
        [string]$Url,
        [parameter(Mandatory=$true)]
        [string]$SecretId,
        [parameter(ParameterSetName="win_auth")]
        [switch]$UseDefaultCredentials,
        [parameter(Mandatory=$true,ParameterSetName="token_auth")]
        [string]$UserName,
        [parameter(Mandatory=$true,ParameterSetName="token_auth")]
        [string]$Password
    )
        Begin{
        #set SS url and creds
        if($PSCmdlet.ParameterSetName -eq "token_auth") {
            $api ="$Url/api/v1/secrets/$SecretId"
            $creds = @{
                username = $UserName
                password = $Password
                grant_type = "password"
            }
            #Authenticate to Secret Server
            try {
                $token = (Invoke-RestMethod "$Url/oauth2/token" -Method Post -Body $creds -ErrorAction Stop).access_token
                $headers = @{Authorization="Bearer $token"}
                $params = @{
                    Header = $headers
                    Uri = $api
                    ContentType = "application/json"
                }
            }
            catch {
                throw "Authentication Error $($_.Exception.Message)"
            }
        }
        elseif($PSCmdlet.ParameterSetName -eq "win_auth") {
            $api="$Url/winauthwebservices/api/v1/secrets/$SecretId"
            $params = @{
                Uri = $api
                ContentType = "application/json"
                UseDefaultCredentials=$true
            }
        }
    }
    Process {
        #remove any inactive keys
        try {
            Set-AWSCredentials -AccessKey $AccessKey -SecretKey $SecretKey
            $inactiveKeys= @(Get-IAMAccessKey -UserName $AWSUserName | Where-Object {$_.Status -match 'Inactive'})
            if ($inactiveKeys.length -ne 0){
                $inactiveKeys.foreach({
                    Remove-IAMAccessKey -AccessKeyId $_.AccessKeyId -ErrorAction Stop -Force
                });
            }
            else {
                Write-Debug "No inactive keys"
            }
        }
        catch [Exception] {
            throw "Remove inactive key error: $($_.Exception.Message)"      
        }
        #Create the keys
        try {
            $newKeys = New-IAMAccessKey -UserName $AWSUserName -ErrorAction Stop
        }
        catch {
            throw "Create key error: $($_.Exception.Message)"
        }
        #push the Key to Secret Server
        try {
            $getSecret = Invoke-RestMethod -Method Get @params -ErrorAction Stop
            $getSecret.items[0].itemValue = $($newKeys.AccessKeyId)
            $getSecret.items[1].itemValue = $($newKeys.SecretAccessKey)
            $body = $getSecret | ConvertTo-Json
            Start-Sleep 10
        }
        catch {
            throw "Get secret error $($_.Exception.Message)"
        }
        try {
            Invoke-RestMethod -Method Put -Body $body @params -ErrorAction Stop| Out-Null
        }
        catch {
            #remove the new generated key if there is an error updating the Secret to avoice qouta error
            Start-Sleep 10
            Remove-IAMAccessKey -AccessKeyId $newKeys.AccessKeyId -ErrorAction Stop -Force
            throw "Update secret error $($_.Exception.Message)"
        }
        try {
            #Set the previous access key to inactive
            Start-Sleep 10
            Update-IAMAccessKey -AccessKeyId $AccessKey -Status Inactive -ErrorAction Stop
        }
        catch {
            throw "Set key inactive error: $($_.Exception.Message)"
        }
    }
}

New-AccessKeys -AccessKey $args[0] -SecretKey $args[1] -AWSUserName $args[2] -SecretId $args[3] -Url "https://SSURL" -UseDefaultCredentials
#New-AccessKeys -AccessKey $args[0] -SecretKey $args[1] -AWSUserName $args[2] -SecretId $args[3] -Url "https://SSURL" -UserName $args[4] -Password $args[5]