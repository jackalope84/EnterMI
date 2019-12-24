function Invoke-CommandAsync { 
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
	Invoke-CommandAsync -Computername 'DC01','DC02','FILE01' -ScriptFile '.\testCopy.ps1'
	Example with a file running on three servers simultanously
	.EXAMPLE
	Invoke-CommandAsync -Computername 'FILE01','SQL01' -argumentlist 'notepad' -ScriptBlock { param($proc) Get-Process -Name $proc }
	Example with a scriptblock with parameters running on two servers simultanously
	.EXAMPLE
	Invoke-CommandAsync -Computername (Get-Content .\computers.txt) -ScriptBlock { Get-Process }
	Example with running a scriptblock on several machines in text file
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
		[Parameter(Mandatory=$False, ValueFromPipeline=$False)]
        $ArgumentList = $null,
		[Parameter(Mandatory=$False,
				   ValueFromPipeline=$True)]
		[int]$Throttle = 20
	)

	$Stopwatch = New-Object System.Diagnostics.Stopwatch
    $Stopwatch.start()
	Write-Verbose -Message "Begin Invoke-CommandAsync"
	
	$RunspacePool = [runspacefactory]::CreateRunspacePool(1,$Throttle)
	$RunspacePool.ApartmentState = "MTA"
	$RunspacePool.Open()

	$CodeContainer = {
		Param(
			[string] $Computer,
			[scriptblock] $ScriptBlock = $null,
			[string] $ScriptFile = $null,
			$ArgumentList
		)

		if($ScriptBlock) {
			Write-Verbose -Message "Run Invoke-Command on $Computer with scriptblock"
			return (Invoke-Command -ComputerName $Computer -ScriptBlock $ScriptBlock -ArgumentList (,$ArgumentList))
		} elseif($ScriptFile) {
			Write-Verbose -Message "Run Invoke-Command on $Computer with scriptfile; $ScriptFile"
			return (Invoke-Command -ComputerName $Computer -FilePath $ScriptFile -ArgumentList (,$ArgumentList))
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
			ArgumentList = $ArgumentList
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
		Write-Verbose -Message "Created runspace for $Computer. Elapsed time: $($Stopwatch.Elapsed)"
	}
	Write-Verbose -Message "Created runspaces for all computers. Elapsed time: $($Stopwatch.Elapsed)"
	
	While ($Threads.Invoker.IsCompleted -contains $false) {
        if($stopwatch.Elapsed.Minutes -eq $minutes) {
            Write-Host "Waiting for all threads to complete"
        } else {
            Write-Host "Waiting for all threads to complete. Elapsed time: $($Stopwatch.Elapsed)"
            $minutes = $stopwatch.Elapsed.Minutes
        }
        Start-Sleep -Seconds 3
	}
	Write-Host "All threads are completed, time elapsed: $($Stopwatch.Elapsed)"

	ForEach($Thread in $Threads) {
		$ThreadResults += $Thread.Runspace.EndInvoke($Thread.Invoker)
		$Thread.Runspace.Dispose()
	}

	$RunspacePool.Close()
	$RunspacePool.Dispose()

	Write-Verbose -Message "End Invoke-CommandAsync, time elapsed: $($Stopwatch.Elapsed)"
}