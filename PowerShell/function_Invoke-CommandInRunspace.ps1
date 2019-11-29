function Invoke-CommandInRunspace { 
	<#
	.SYNOPSIS
	Invoke a command on multiple computers asynchronously
	.DESCRIPTION
	To save time run a command on several computers at the same time
	Written by Floris van Enter | EnterMI
	.PARAMETER ComputerName
	The name of the computer(s) to run the code on.
	.PARAMETER ScriptBlock
	The block of code to run against the machines
	.PARAMETER ScriptFile
	The scriptfile to run against the machines
	.PARAMETER Throttle
	How many threads can run simultaniously
	.EXAMPLE
	Invoke-CommandInRunspace -Computername 'DC01','DC02','FILE01' -ScriptFile '.\testCopy.ps1'
	.EXAMPLE
	Invoke-CommandInRunspace -Computername 'FILE01','SQL01','MAIL01' -ScriptBlock { Get-Process }
	.LINK
	https://www.entermi.nl
	.NOTES
	This function does nothing with any error handling. So if you write bad code and pass it to the parameters with you will not get the red text. It will just fail.
	In the future I want to add the error stream of the runspaces. Here I help myself with some notes to have a quick start;
	* In $Thread(s).Runspace you can find the property 'HadErrors' to check if there were any errors.
	* Check $Thread(s).Runspace.Streams to get to Error, Verbose etc.

	Tip: Catch the result of this function in a variable so you can check what comes from which computer without having to run it again.
	#>
	[CmdletBinding()]
	Param(
		[Parameter(Mandatory=$True,
				   ValueFromPipeline=$True)]
		[string[]]$ComputerName,
		[Parameter(Mandatory=$False,
				   ValueFromPipeline=$False)]
		[striptblock]$ScriptBlock = $null,
		[Parameter(Mandatory=$False,
				   ValueFromPipeline=$False)]
		[sring]$ScriptFile = $null,
		[Parameter(Mandatory=$False,
				   ValueFromPipeline=$True)]
		[int]$Throttle = 20
	)

	$Stopwatch = New-Object System.Diagnostics.Stopwatch
    $Stopwatch.start()
	Write-Verbose -Message "Begin Invoke-CommandInRunspace"
	
	$RunspacePool = [runspacefactory]::CreateRunspacePool(1,$Throttle)
	$RunspacePool.ApartmentState = "MTA"
	$RunspacePool.Open()

	$CodeContainer = {
		Param(
			[string] $Computer,
			[scriptblock] $ScriptBlock = $null,
			[string] $ScriptFile = $null
		)

		if($ScriptBlock) {
			Write-Verbose -Message "Run Invoke-Command on $Computer with scriptblock"
			return (Invoke-Command -ComputerName $Computer -ScriptBlock $ScriptBlock)
		} elseif($ScriptFile) {
			Write-Verbose -Message "Run Invoke-Command on $Computer with scriptfile; $ScriptFile"
			return (Invoke-Command -ComputerName $Computer -FilePath $ScriptFile)
		} else {
			return $null
		}
	}

	$Threads = @()

	ForEach ($Computer in $ComputerName) {
        $ParamContainer = @{
            Computer = $Computer
            ScriptBlock = $ScriptBlock
            ScriptFile = $ScriptFile
        }

		$RunspaceObject = [PSCustomObject]@{
			Runspace = [PowerShell]::Create()
			Invoker = $null
		}
		$RunspaceObject.Runspace.RunspacePool = $RunspacePool
		$RunspaceObject.Runspace.AddScript($CodeContainer) | Out-Null
		$RunspaceObject.Runspace.AddParameters($ParamContainer) | Out-Null
		$RunspaceObject.Invoker = $RunspaceObject.Runspace.BeginInvoke()

		$Threads += $RunspaceObject
		Write-Verbose -Message "Finished creating runspace for $Computer. Elapsed time: $($Stopwatch.Elapsed)"
	}
	Write-Verbose -Message "Finished creating runspaces for all computers. Elapsed time: $($Stopwatch.Elapsed)"
	
	While ($Threads.Invoker.IsCompleted -contains $false) {
		Write-Host "Waiting for all threads to complete"
		Start-Sleep -Seconds 3
	}
	Write-Host "All threads are completed, time elapsed: $($Stopwatch.Elapsed)"

	ForEach($Thread in $Threads) {
		$ThreadResults += $Thread.Runspace.EndInvoke($Thread.Invoker)
		$Thread.Runspace.Dispose()
	}

	$RunspacePool.Close()
	$RunspacePool.Dispose()

	Write-Verbose -Message "End Invoke-CommandInRunspace, time elapsed: $($Stopwatch.Elapsed)"
}