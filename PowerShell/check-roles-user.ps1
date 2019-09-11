<#
.SYNOPSIS
Queries autorisation table in DB and dumps it in a CSV file
.DESCRIPTION
This retrieves all users/groups and converts it to a cross table to create an overview of the rights. The user running this script needs to have access to the database to be able to query the necessary information. The roles put on the left and vertically. The users are on top and put horizontally.
There is a script which puts users on the left and vertical, see "check-users-role.ps1".
Written by Floris van Enter | EnterMI
.PARAMETER Server
Which database do we have to connect.
.PARAMETER Database
Database containing the specific autorisation table.
.PARAMETER Outputfile
Location and name of the file where the outputs get directed. By default it is; C:\Temp\[SERVERNAME].csv
.PARAMETER Delimiter
Specifies a delimiter to separate the property values. The default is a semicolon (;). Enter a character, such as a comma (,). Enclose it in quotation marks.
.PARAMETER Character
Specifies which character is used to mark the cross table. By default it is; X
.EXAMPLE
Check the roles vs server with different options
.\check-roles-user.ps1 -Server SERVER01 -Database APPDB -Delimiter "," -Character X
.EXAMPLE
check the roles on the server and send it to a specific output-file
.\check-roles-user.ps1 -Server SERVER2 -Database APPDB -OutputFile "C:\Temp\database.csv"
.LINK
https://www.entermi.nl
#>
[CmdletBinding()]
param(
    [Parameter(Position=0, Mandatory=$true)]
    [string]$Server,
    [Parameter(Position=1, Mandatory=$true)]
    [string]$Database,
    [Parameter(Mandatory=$false)]
    [string]$Outputfile="C:\Temp\$Server.csv",
    [Parameter(Mandatory=$false)]
    [string]$Delimiter=";",
    [Parameter(Mandatory=$false)]
    [string]$Character="X"
    )

# Fill in default parameters to avoid to repeat myself with: Invoke-Sqlcmd -ServerInstance $Server -Database $Database
$PSDefaultParameterValues["Invoke-Sqlcmd:ServerInstance"]=$Server
$PSDefaultParameterValues["Invoke-Sqlcmd:Database"]=$Database

$roles = Invoke-Sqlcmd -Query "SELECT DISTINCT [role_name] as rolename FROM [dbo].[Roles] ORDER BY rolename;" | Select-Object -ExpandProperty 'rolename'
$users = Invoke-Sqlcmd -Query "SELECT DISTINCT [user] as username FROM [dbo].[Users];" | Select-Object -ExpandProperty 'username'
$user_role = Invoke-Sqlcmd -Query "SELECT Roles.role_name as [rolename], [user] as username as [username] FROM Roles LEFT OUTER JOIN UserRoles ON Roles.role_id = UserRoles.role_id RIGHT OUTER JOIN Users ON UserRoles.user_id = Users.user_id ORDER BY rolename, username;"
$output = @()

$line = "role_name" + $Delimiter
ForEach ($user in $users) {
    $line += $user + $Delimiter
}
$output += $line

ForEach ($role in $roles) {
    $user_filter = $user_role | Where-Object -Property "rolename" -EQ -Value $role | Select-Object -ExpandProperty 'username'

    $line = $role + $Delimiter
    ForEach ($user in $users) {
        if($user -in $user_filter) {
            $line += $Character + $Delimiter
        } else {
            $line += $Delimiter
        }
    }
    $output += $line
}

$output | Out-File $Outputfile -Force