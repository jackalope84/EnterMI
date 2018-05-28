function Invoke-RemoteScript() {
    <#
    .SYNOPSIS
    Runs a local script on one or more remote machines
    .DESCRIPTION
    This function connects via PSRemoting to a server to run a script saved locally.
    Written by Floris van Enter | EnterMI
    .PARAMETER ComputerName
    The name of the computer(s) to query.
    .PARAMETER Scriptfile
    The name of the script to run (with path)
    .PARAMETER Username
    Optional. The name of the user to remote connect
    .PARAMETER Password
    Optional. The password of the user to remote connect
    .EXAMPLE
    Invoke-RemoteScript -ComputerName computerA -Username "AD\AA99BB" -Password "bla bla ww" -Scriptfile ".\test.ps1"
    .EXAMPLE
    Invoke-RemoteScript -ComputerName computerA,computerB,computerC -Scriptfile "c:\temp\test.ps1"
    .LINK
    https://www.entermi.nl
    #>

    [CmdletBinding()]
    Param(
        [Parameter( Mandatory=$True,
                    ValueFromPipeline=$True)]
        [string[]]$ComputerName,
        [Parameter(Mandatory=$True,
                   ValueFromPipeline=$True)]
        [string]$Scriptfile,
        [Parameter(Mandatory=$True,
                   ValueFromPipeline=$True)]
        [string]$Username,
        [Parameter(Mandatory=$True,
                   ValueFromPipeline=$True)]
        [string]$Password
    )

    # Get the correct credential and use it for the computers
    if ($PSBoundParameters.ContainsKey('Username') -and $PSBoundParameters.ContainsKey('Password') ) {
        Write-Verbose "Convert password to SecureString for user $Username and save it as an Credential"
        $pwdString = ConvertTo-SecureString -String $Password -AsPlainText -Force
        $credentials = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $Username, $pwdString
    } elseif ($PSBoundParameters.ContainsKey('Username')) {
        Write-Verbose "Ask password for $Username and save it as an Credential"
        $credentials = Get-Credential -UserName $Username -Message "Enter the password for user: $username"
    } else {
        Write-Verbose "Run the remote script as logged in user: $env:username"
    }

    # Get the correct credential and use it for the computers
    Foreach($computer in $ComputerName) {
        Write-Verbose "Connect with $computer"
        if(Test-Path Variable:\Credentials) {
            Write-Verbose "Connect with $credentials.Username"
            Invoke-Command -ComputerName $Computer -FilePath $Scriptfile -Credential $credentials
        } else {
            Write-Verbose "Connect with Logged On User"
            Invoke-Command -ComputerName $Computer -FilePath $Scriptfile
        }
    }
    Remove-Variable -Name Credentials
}