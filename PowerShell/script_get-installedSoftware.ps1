    <#
	.SYNOPSIS
        Retrieves a list of all software installed on a Windows computer.
    .DESCRIPTION
        Retrieve all software from several registry keys and put it in one big list.
        Written by Adam the Automator
	.EXAMPLE
		PS> .\ListInstalledSoftware.ps1
        This example retrieves all software installed on the local computer.
    .LINK
        https://adamtheautomator.com/powershell-get-installed-software/
    .NOTES
        This script was adjusted for my personal need. Because of the following function I wanted it as a standalone script;
        Invoke-CommandInRunspace - https://github.com/beakerflo/EnterMI/blob/master/PowerShell/function_Invoke-CommandInRunspace.ps1
        Original author made a very helpful function of the original code below 
	#>
try {
    New-PSDrive -Name HKU -PSProvider Registry -Root Registry::HKEY_USERS | Out-Null
    $UninstallKeys = @(
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall",
        "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
    )
    $UninstallKeys += Get-ChildItem HKU: | Where-Object { $_.Name -match 'S-\d-\d+-(\d+-){1,14}\d+$' } | ForEach-Object {
        "HKU:\$($_.PSChildName)\Software\Microsoft\Windows\CurrentVersion\Uninstall"
    }

    ForEach ($UninstallKey in $UninstallKeys) {
        Write-Verbose -Message "Checking uninstall key [$($UninstallKey)]"
        $friendlyNames = @{
            'DisplayName'    = 'Name'
            'DisplayVersion' = 'Version'
        }
        $SwKeys = Get-ChildItem -Path $UninstallKey -ErrorAction SilentlyContinue | Where-Object { $_.GetValue('DisplayName') }
        if (-not $SwKeys) {
            Write-Verbose -Message "No software keys in uninstall key $UninstallKey"
        } else {
            foreach ($SwKey in $SwKeys) {
                $output = @{ }
                foreach ($ValName in $SwKey.GetValueNames()) {
                    if ($ValName -ne 'Version') {
                        $output.InstallLocation = ''
                        if ($ValName -eq 'InstallLocation' -and 
                            ($SwKey.GetValue($ValName)) -and 
                            (@('C:', 'C:\Windows', 'C:\Windows\System32', 'C:\Windows\SysWOW64') -notcontains $SwKey.GetValue($ValName).TrimEnd('\'))) {
                            $output.InstallLocation = $SwKey.GetValue($ValName).TrimEnd('\')
                        }
                        [string]$ValData = $SwKey.GetValue($ValName)
                        if ($friendlyNames[$ValName]) {
                            $output[$friendlyNames[$ValName]] = $ValData.Trim() ## Some registry values have trailing spaces.
                        } else {
                            $output[$ValName] = $ValData.Trim() ## Some registry values trailing spaces
                        }
                    }
                }
                $output.GUID = ''
                if ($SwKey.PSChildName -match '\b[A-F0-9]{8}(?:-[A-F0-9]{4}){3}-[A-F0-9]{12}\b') {
                    $output.GUID = $SwKey.PSChildName
                }
                New-Object -TypeName PSObject -Prop $output
            }
        }
    }
} catch {
    Write-Error -Message "Error: $($_.Exception.Message) - Line Number: $($_.InvocationInfo.ScriptLineNumber)"
}