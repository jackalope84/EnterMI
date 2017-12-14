

function Get-MACAddress { 
    <#
	.SYNOPSIS
	 Retrieves MAC-Address
	.DESCRIPTION
	 Retrieves MAC-Address from each IP enabled networkdevice in a computer
	 Written by Floris van Enter | EnterMI
	.PARAMETER ComputerName
	 The name of the computer to query.
	.EXAMPLE
	.\Get-MacAddress -ComputerName 'desktop1'
	.EXAMPLE
	.\Get-MacAddress -ComputerName 'server1','server2','desktop1'
	.LINK
	https://www.entermi.nl
    #>
	[CmdletBinding()]
	Param(
	  [Parameter(Mandatory=$True,
                 ValueFromPipeline=$True)]
	  $ComputerName
    )

    $ComputerName | Foreach { Get-WmiObject -Class "Win32_NetworkAdapterConfiguration" -ComputerName $_.ToString() | Where { $_.IPEnabled -eq $True } | Select PSComputerName, MACAddress, Description }
}