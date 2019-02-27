<#
.SYNOPSIS
Retrieves updates from WMI and installs it.
.DESCRIPTION
This gets all the updates that is published in Software Center and installs them and reboots when necessairy.
Written by Floris van Enter | EnterMI
.PARAMETER preventReboot
Prevent reboot, by default it is False.
.EXAMPLE
Run the updates and prevent reboots
script_install_updates.ps1 -preventReboot $True
.LINK
https://github.com/beakerflo/EnterMI
#>
[CmdletBinding()]
param(
    [boolean]$preventReboot = $False
    )

$updates = Get-WmiObject -Class CCM_SoftwareUpdate -Namespace root\CCM\ClientSDK | Where -FilterScript { $_.EvaluationState -eq "0" }
$reboot = $False
$rebootTimeout = Get-Random -Maximum 120 -Minimum 10

# exit script if no updates are found
 If ( $updates -eq $Null ) {
    Write-Host "No updates found."
    break
}

Write-Host "" # line break
Write-Host "Available Updates:"

$updateNames = $updates | Select -ExpandProperty Name

# display numbered list of update names
ForEach($updateName in $updateNames) {
    Write-Host $updateName
    }

Write-Host "" # line break
Write-Host "Beginning Installation" # shows that updates have started
Write-Host "" # line break

# declare array for failed updates
$failedUpdates = @()

# formats updates by just getting those that are required (ComplianceState=0). Converts updates to WMI so that they can be installed.
ForEach ( $update in $updates ) {
    $f_update = @($update | ForEach-Object { if($_.ComplianceState -eq 0){[WMI]$_.__PATH} })
    $installName = $update | Select Name

    # Installs updates
    $uWmiOutput = ""
    $uWmiOutput = ([wmiclass]'ROOT\ccm\ClientSdk:CCM_SoftwareUpdatesManager').InstallUpdates($f_update)

    # wait until update process is seen, then disappears
     Do {
        $upCheck = ""
        $upCheck = Get-Process | Where -filterscript { $_.ProcessName -eq "wuauclt" }
    } Until ( $upCheck -ne $Null )

    Wait-Process -Name wuauclt
    Start-Sleep -s 2

    # write result
    $s_install_name = "$installName"
    $f_install_name = $s_install_name.substring(7).trim("}")
    $eval_state = ""
    $eval_state = (Get-WmiObject -Class CCM_SoftwareUpdate -Namespace root\CCM\ClientSDK | Where -filterscript { $_.Name -like "*$f_install_name*" }).EvaluationState

    If ( $eval_state -eq "13") {
        $failedUpdates += $f_install_name
    } Else {
        Write-Host "Success: $f_install_name" -ForegroundColor green
        $reboot = $True
    }
}

If ( $failedUpdates -ne $Null ) {
    Write-Host ""
    Write-Host "Failed Updates:"
    ForEach ($failedUpdate in $failedUpdates) {
        Write-Host $failedUpdate -ForegroundColor red
    }
}

Write-Host "" # line break

# determine if there is a pending reboot
$u_reboot = [wmiclass]"\\localhost\root\ccm\ClientSDK:CCM_ClientUtilities"
$u_result = $u_reboot.DetermineIfRebootPending() | Select RebootPending
$u_p_reboot = $u_result.RebootPending

# does check for any pending reboots (eval state 8) and alerts if they are required
If ( ($u_p_reboot -eq $True) -and ($reboot = $True) -and ($preventReboot = $False) ) {
    Write-Host "Reboot Required."
    Write-Host "The server will reboot within $rebootTimeout seconds"
    Start-Sleep -s $rebootTimeout
    Restart-Computer
    } ElseIf ( ($u_p_reboot -eq $True) -and ($reboot = $True) -and ($preventReboot = $True) ) {
    Write-Host "Reboot is Required."
    Write-Host "Please reboot!!!" -ForegroundColor Red
} Else {
    Write-Host "Reboot not Required."
}