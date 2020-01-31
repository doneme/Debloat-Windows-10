﻿Import-Module -DisableNameChecking $PSScriptRoot\..\lib\restart-dialog.psm1
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\force-mkdir.psm1
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\take-own.psm1

$lineSeparator="`n================================================="

Function Print-Script-Banner($scriptName)
{
   Write-Host "`n>> Executing: $scriptName$lineSeparator"
}

Function Print-Message-With-Banner($msg)
{
   Write-Host "`n>> $msg$lineSeparator"
}

Function Test-KeyExists($regKeyPath) {
    $exists = Get-Item $regKeyPath -EA SilentlyContinue

    if ($exists -ne $null) {
        Return $true
    }

    Return $false
}

Function Get-LoggedUsername() {
    $loggedUser = get-wmiobject -Class Win32_Computersystem | select Username | foreach { -split $_."Username" } 
    $index = $loggedUser.IndexOf('\') + 1
    $loggedUser = $loggedUser.Substring($index)

    return $loggedUser
}

Function Is-BuiltInAdmin() {

    $result = $false

    $loggedUser = Get-LoggedUsername
    if ($loggedUser -like 'Admin*') {
        Write-Debug "Assuming it's the built-in Administrator account: $env:UserName"
        $result = $true
    }

    Return $result
}

Function Check-AdminsRights() {

    if (Is-BuiltInAdmin) {
        Return
    }

    $loggedUser = Get-LoggedUsername
    if (-Not($loggedUser.Equals($env:USERNAME))){
        Write-Host "For these scripts to work properly, the current user *MUST* be in the Administrators group." -BackgroundColor Red
        Write-Host "Script execution aborted" -BackgroundColor Red
        Exit
    }
    
}

Function Remove-CurrentUserAdminGroup() {

    if (Is-BuiltInAdmin) {
        Write-Host "$env:UserName shouldn't be removed from Administrators group - removal skipped"
        Return
    }

    Add-LocalGroupMember -Group Users -Member $env:UserName
    Remove-LocalGroupMember -Group Administrators -Member $env:UserName
}