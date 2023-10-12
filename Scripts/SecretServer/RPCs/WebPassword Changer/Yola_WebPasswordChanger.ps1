# Script usage
# use powershell script for both hearthbeat and password changing.
# parameters to provide in each case are:
# Heartbeat: hb $url $username $password
# Password Change: rpc $url $username $password $newpassword

# Script uses PowerShell Selenium module v 4.0
# This module can be found on: https://github.com/adamdriscoll/selenium-powershell
# As of writing the version used is a pre-release version
# https://github.com/adamdriscoll/selenium-powershell/tree/v4.0.0-preview3


<# Disabled Parameters function to accomodate Secret Server script processing
param(
    [parameter(Mandatory = $true, Position=0)]
    [ValidateSet("hb", "rpc")]
    [ValidateNotNull()]
    [string]$action,
    [parameter(Mandatory = $true, Position=1)]
    [string]$thy_url,
    [parameter(Mandatory = $true, Position=2)]
    [string]$thy_username,
    [parameter(Mandatory = $true, Position=3)]
    [string]$thy_password,
    [parameter(Mandatory = $false, Position=4)]
    [string]$thy_newpassword
)
#>

$action = $args[0]
$thy_url = $args[1]
$thy_username = $args[2]
$thy_password = $args[3]
$thy_newpassword = $args[4]

# Importing Selenium Powershell module
Import-Module -Name "C:\Program Files\WindowsPowerShell\Modules\Selenium\4.0.0\Selenium.psd1"

function Invoke-BrowserStart {
    Write-Output 'Starting Browser for automated login'
    # Start browser in headless mode for RPC and HB
    $Options = New-SeDriverOptions -Browser Chrome -StartURL "$thy_url"
    $Options.AddArgument('headless')
    $Options.AcceptInsecureCertificates = $True
    $options.AddUserProfilePreference('credentials_enable_service', $false)
    $options.AddUserProfilePreference('profile.password_manager_enabled', $false)
    $script:driver = Start-SeDriver -Options $Options
    Wait-SeDriver -Condition TitleContains -Value 'Log In' -Timeout 30 | Out-Null 
}

function Invoke-Login {
    Write-Output 'Performing login process'
    #Login process
    Wait-SeElement -By XPath -Value '//*[@id="login"]/div[1]/button' -Condition ElementToBeClickable | Out-Null 
    $element = Get-SeElement -By XPath -Value '//*[@id="login"]/div[1]/button' -Timeout 30
    Invoke-SeClick -Element $Element
    $element = Get-SeElement -By XPath -Value '//*[@id="email"]' -Timeout 30
    Invoke-SeKeys -Element $Element -Keys $thy_username
    $element = Get-SeElement -By XPath -Value '//*[@id="password"]' -timeout 30
    Invoke-SeKeys -Element $Element -Keys $thy_password
    $Element = Get-SeElement -By XPath -Value '//*[@id="embedded-login-form"]/ul/li[4]/button' -Timeout 30
    Invoke-SeClick -Element $Element
}

function Invoke-CleanUp {
    Write-Output 'Cleaning up browser instances'
    #Close Selenium Driver
    Stop-SeDriver $Driver
}

function Invoke-HB {
    Write-Output 'Starting HB'
    start-sleep -s 5
    $LoginCheck = Get-SeElement -by XPath -Value '//*[@id="page-content"]/div/section/div[2]' -Timeout 10 -ErrorAction SilentlyContinue
    # Checking for Login failed message on web page indicating a failed login.
    if ($logincheck.Text -match 'Login failed') {
        Write-Output 'HB Failed'
        Invoke-CleanUp
        throw 'HB Failed. Check credentials.'
    }
    else {
        Write-Output 'HB success'
    }
}

function Invoke-RPC {
    Write-Output 'Starting RPC'
    # Check for succesful login
    $LoginCheck = Get-SeElement -by XPath -Value '//*[@id="user_menu"]' -Timeout 60 -ErrorAction SilentlyContinue
    if ($logincheck.Displayed -eq $true) {
        Write-Output 'login succesful performing rpc'
        # Navigate to password change URL
        set-seurl "https://my.yola.com/account/profile/"
        Wait-SeDriver -Condition TitleContains -Value 'Edit your account' -Timeout 30 | Out-Null 
        $PasswordChangeCheck = Get-SeElement -By XPath -Value '//*[@id="change_password"]/h2' -Timeout 30
        if ($PasswordChangeCheck.Displayed -eq $true) {
            $element = Get-SeElement -By XPath -Value '//*[@id="id_password"]' -Timeout 30
            Invoke-SeKeys -Element $Element -Keys $thy_password
            $element = Get-SeElement -By XPath -Value '//*[@id="id_new_password"]' -Timeout 30
            Invoke-SeKeys -Element $Element -Keys $thy_newpassword
            $element = Get-SeElement -By XPath -Value '//*[@id="id_confirm_new_password"]' -Timeout 30
            Invoke-SeKeys -Element $Element -Keys $thy_newpassword
            $element = Get-SeElement -By XPath -Value '//*[@id="password_form"]/div[4]/button' -Timeout 30
            Invoke-SeClick -Element $Element
            }
        else {
            Write-Output 'Password change failed.'
            Invoke-CleanUp
            throw 'Page not loaded with password change fields. Check Website.'
        }
        Wait-SeElement -by CssSelector -value '#password_form_messaging' -Timeout 30 -Condition ElementExists | Out-Null
        start-sleep -s 10
        $PasswordChangeSucceedCheck = Get-SeElement -by CssSelector -value '#password_form_messaging' -Timeout 30
        if ($PasswordChangeSucceedCheck.text -match 'Successfully') {
        Write-Output 'Password Change Succeeded'
        }
        else {
            Write-Output 'Password change failed. Check Website.'
            Invoke-CleanUp
            throw 'Password change failed. Check website.'
        }
    }
    else {
        Write-Output 'Incorrect credentials causing RPC to fail.'
        Invoke-CleanUp
        throw 'Incorrect credentials causing RPC to fail. Check credentials.'
    }
}

if ($action -eq 'hb') {
    Invoke-BrowserStart
    Invoke-Login
    Invoke-HB
    Invoke-CleanUp
    Write-Output 'HB Completed'
}
elseif ($action -eq 'rpc') {
    Invoke-BrowserStart
    Invoke-Login
    Invoke-RPC
    Invoke-CleanUp
    Write-Output 'RPC Completed'
}
else {
    Write-Output 'No Action defined. Please define action as per documented parameters'
}