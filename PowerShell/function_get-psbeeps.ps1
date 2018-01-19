function Get-PsBeeps (){

    <#
	.SYNOPSIS
	 Create random beeps
	.DESCRIPTION
	 Beeps random beeps from the console. Press CRTL-C to break.
	 Written by Sten Lootens
	.EXAMPLE
	.\GetPsBeeps()
    #>

    While($true){
        [Console]::Beep(
             (Get-Random -Minimum 200 -Maximum 8000)
            ,500
            )
        }
    }