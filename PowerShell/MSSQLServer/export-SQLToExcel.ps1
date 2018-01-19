<#
.SYNOPSIS
Retrieves information from a SQL server database, save it to excel and mail it.
.DESCRIPTION
This export-SQLToExcel.ps1 script uses the SQL Server Powershell module to connect to a SQL Server and export data to a excel file.
Written by Floris van Enter | EnterMI
.PARAMETER sqlServer
a single computer name or an array of computer names. You mayalso provide IP addresses.
.PARAMETER database
The database to get the information.
.PARAMETER schema
The schema to associate the objects with.
This is an optional parameter; if it is not included, 'dbo' schema will be used.
.PARAMETER table
The table or view to get the data from. If it does not exist, the table will be created.
This is an optional parameter; if it is not included, 'export' table will be used.
.PARAMETER file
The location & name of the excel file to export to.
.PARAMETER template
The location & name of a template excel file to use.
This is an optional parameter; if it is not included, a new excel file will be created
.PARAMETER startRow
The writing starts at this row, default is 1
.PARAMETER startColumn
The writing starts at this column, default is 1
.PARAMETER showExcel
When you want to show excel during operations use this parameter and set it to $Trues
.PARAMETER mailAddress
If you to mail the sheet, fill in an email address
This is an optional parameter; if it is not included, no e-mail will be sent
.PARAMETER mailContents
If you to mail the sheet, fill in an email body
This is an optional parameter; if it is not included, an empty mail will be sent
.EXAMPLE
Read data from the SQL Server, save it in a file and mail it to floris@entermi.nl
download-CsvToSQL.ps1 -sqlServer "SQL01" -database "migrate-data" -table "export" -url "http://localhost/data.csv" -file "c:\temp\file.csv"
.LINK
https://github.com/beakerflo/EnterMI
#>
[CmdletBinding()]
param(
    [string]$sqlServer,
    [string]$database,
    [string]$schema = 'dbo',
    [string]$table = 'export',
    [string]$file,
    [string]$template = $Null,
	[int]$startRow = 1,
    [int]$startColumn = 1,
    [string]$mailAddress = $Null,
    [string]$mailContents = $Null,
    [boolean]$showExcel = $False
    )

# create the file from template which has all necessairy formatting
Copy-Item -Path $xlTemplate -Destination $xlFile -Force

# start excel instance with file
$xl = New-Object -ComObject "Excel.Application"
$wb = $xl.Workbooks.Open($xlFile)
$ws = $wb.Sheets.Item(1)
#$xl.Visible = $True # makes excel visible in development-status

# activate SQL mode and query
Import-Module "sqlps" -DisableNameChecking

$sqlQuery = "SELECT [Kolom1],[Kolom2],[Kolom3],[Kolom4] FROM [inventarisaties].[dbo].[view] ORDER BY [Kolom1] ASC"
$data = Invoke-SQLcmd $sqlQuery -ServerInstance $sqlServer

# walk through the results and fill the excel file
$row = $rowStart
foreach ($line in $data) {
    $col = $colStart
    $cells = $ws.Cells
    $cells.item($row,$col) = $line.Kolom1
    $col++
    $cells.item($row,$col) = $line.Kolom2
    $col++
    $cells.item($row,$col) = $line.Kolom3
    $col++
    $cells.item($row,$col) = $line.Kolom4
    $row++
}

# close excel instances
$wb.Save()
$wb.Close()
$xl.Quit()
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($xl)

# Start Outlook
Start-Process Outlook
$o = New-Object -com Outlook.Application
$mail = $o.CreateItem(0)

# Send an e-mail
$mail.subject = “Hierbij de laatste lijst“
$mail.body = (Get-Content $mail | out-string)
$mail.To = $rcpt
$mail.Bcc = $rcptCC
$mail.Attachments.Add($xlFile)
$mail.Send()

# Cleanup
Start-Sleep -s 16 # give time to send mails, before quitting Outlook
Move-Item ($folder + "Servicedesk-2*.xlsx") $folderA -force
$o.Quit() # quits everything concerning Outlook
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($o)
Start-Process Outlook # only on live-workstation