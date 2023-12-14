
## Notice

 - Ensure you have the necessary permissions to execute scripts. In many cases, the permission to execute scripts is restricted. You can use the native PowerShell cmdlet `Get-ExecutionPolicy` to check whether you have permission to execute scripts using your current account credentials and the native `Set-ExecutionPolicy` cmdlet to specify an execution policy.

- Be cautious when writing custom scripts that could potentially return large data sets. Such scripts could impact performance. Consider ways to improve performance, such as avoiding the use of the PowerShell pipeline for large data collections, using `Export-Csv` instead of `Out-File` where possible, and using the native .NET FileStream function for very large data sets.

- Always test your scripts in a controlled environment before deploying them in a production environment. This can help identify and resolve any issues that might affect the performance or functionality of your systems.

- Be aware that scripts can have a significant impact on your systems and data. Always ensure that your scripts are correct and safe to run. 