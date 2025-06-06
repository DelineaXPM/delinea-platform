 #Import-Module -Name AWS.Tools.RedshiftDataAPIService



    $accessKey = $args[0]
    $secretKey = $args[1]
    $newpassword = $args[2]
    $database = $args[3]
    $workgroupname = $args[4]
    $username = $args[5]
    $region = $args[6]


try{

$workgroupname | Out-File -FilePath C:\redshift_debug.log
$sql = "alter user $($username) password '$($newpassword)'"

$result = Send-RSDStatement -Database $database -AccessKey $accessKey -SecretKey $secretKey -WorkgroupName $workgroupname -region $region -sql $sql -select *


} catch {
    # Handle errors
    Write-Error "An error occurred while executing the query:"
    Write-Error $_.Exception.Message
}
 