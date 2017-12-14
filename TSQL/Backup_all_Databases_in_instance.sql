/*

SQL Server Backup script - SQL Server 2008, SQL Server 2008 R2, SQL Server 2012, SQL Server 2014, and SQL Server 2016

You can contact me by e-mail at floris@entermi.nl.

Last updated 1 December, 2017.

Floris van Enter
http://entermi.nl

*/

DECLARE @name VARCHAR(50) -- database name
DECLARE @path VARCHAR(256) -- path for backup files
DECLARE @fileName VARCHAR(256) -- filename for backup
DECLARE @fileDate VARCHAR(20) -- used for file name

-- specify database backup directory
SET @path = 'C:\Program Files\Microsoft SQL Server\MSSQL13.TEST\MSSQL\Backup\'

-- specify filename format
SELECT @fileDate = CONVERT(VARCHAR(20),GETDATE(),112)

DECLARE db_cursor CURSOR READ_ONLY FOR
    SELECT name
    FROM master.dbo.sysdatabases
    WHERE name NOT IN ('tempdb')

OPEN db_cursor
FETCH NEXT FROM db_cursor INTO @name

WHILE @@FETCH_STATUS = 0
BEGIN
   SET @fileName = @path + @name + '_' + @fileDate + '.BAK'
   BACKUP DATABASE @name TO DISK = @fileName

   FETCH NEXT FROM db_cursor INTO @name
END

CLOSE db_cursor
DEALLOCATE db_cursor