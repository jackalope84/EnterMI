<#
.SYNOPSIS
Retrieves information from an online CSV file, import it in a table of an database.

.DESCRIPTION
This download-CsvToSQL.ps1 script uses the SQL Server Powershell module to connect to a SQL Server and import data in a table.
The source of the information gets downloaded from the internet and the CSV - value is ;
Written by Floris van Enter | EnterMI

.PARAMETER sqlServer
a single computer name or an array of computer names. You mayalso provide IP addresses.

.PARAMETER database
The database to put in the information.

.PARAMETER schema
The schema to associate the objects with.
This is an optional parameter; if it is not included, dbo schema will be used.

.PARAMETER table
The table to put in the information. If it does not exist, the table will be created.
This is an optional parameter; if it is not included, export table will be used.

.PARAMETER url
The location of the CSV. It must be an internet location.

.PARAMETER file
The location to store the downloaded CSV data in.

.EXAMPLE
Read a file from a website into the table
download-CsvToSQL.ps1 -sqServer "SQL01" -database "migrate-data" -table "export" -url "http://localhost/data.csv" -file "c:\temp\file.csv"

.LINK
https://github.com/beakerflo/EnterMI
#>
[CmdletBinding()]
param(
    [string]$sqlServer,
    [string]$database,
    [string]$schema = 'dbo',
    [string]$table = 'export',
    [string]$url,
    [string]$file
    )

If (Test-Path $file) {
    Remove-Item $file
    }

if (Get-Module -ListAvailable -Name SqlServer) {
    Write-Verbose "Importing SqlServer"
    Import-Module "sqlps" -DisableNameChecking
} elseif (Get-Module -ListAvailable -Name sqlps) {
    Write-Verbose "Importing sqlps"
    Import-Module "sqlps" -DisableNameChecking
} else {
    Write-Host "Module does not exist"
    Write-Host "This script needs 'SqlServer' or the older 'sqlps'"
    Write-Host "Please install..."
    exit
}

function Run-SqlQuery {
    param(
    [string]$query
    )
    Write-Verbose "execute $query on $sqlServer"
    Invoke-SQLcmd -ServerInstance $sqlServer -Database $database -Query $query
}

# Download CSV file from website
Write-Verbose "Download $url to $file"
(New-Object System.Net.WebClient).DownloadFile($url,$file)

# Clean table to receive results from CSV
Run-SqlQuery -query "TRUNCATE TABLE [$schema].[$table]"

# Read CSV file, import to database and run clean-up stored procedure
Write-Verbose "Import $file to $database.$schema.$table"
Import-Csv -Path $file -Delimiter ";" -header("Kolom1","Kolom2","Kolom3","Kolom4") | Write-SqlTableData -ServerInstance $sqlServer -DatabaseName $database -SchemaName $schema -TableName $table -Force