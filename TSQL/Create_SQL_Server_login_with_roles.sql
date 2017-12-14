/*

Create SQL Server service login with roles - SQL Server 2008, SQL Server 2008 R2, SQL Server 2012, SQL Server 2014, and SQL Server 2016

For a specific application create an account with minimal rights to run with a custom role.

You can contact me by e-mail at floris@entermi.nl.

Last updated 1 December, 2017.

Floris van Enter
http://entermi.nl
*/

USE [master]
GO

/* For security reasons the login is created disabled and with a random password. */
CREATE LOGIN [ServiceAccountName] WITH PASSWORD=N'QbMFvznXm//yhwwk/xsZfwwL/fVRieg5piIWvdnwECI=', DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english], CHECK_EXPIRATION=OFF, CHECK_POLICY=ON;
GO
ALTER LOGIN [ServiceAccountName] DISABLE;
GO

-- Create a custom role for the rights
CREATE SERVER ROLE SomeCustomRoleName AUTHORIZATION sysadmin;
GO

-- Give specific rights on the server to the role;
GRANT VIEW ANY DEFINITION TO SomeCustomRoleName;
GRANT ALTER TRACE TO SomeCustomRoleName;
GRANT VIEW SERVER STATE TO SomeCustomRoleName;
GO

USE [msdb];
GO

CREATE USER [ServiceAccountName] FOR LOGIN [ServiceAccountName] WITH DEFAULT_SCHEMA=[dbo]
GO

EXEC sp_addrolemember @rolename = 'db_datareader',  @membername = 'ServiceAccountName'
EXEC sp_addrolemember @rolename = 'SQLAgentReaderRole', @membername = 'ServiceAccountName'
GO

Use [master];
GO

DECLARE @dbname		VARCHAR(50)
DECLARE @statement	NVARCHAR(max)

DECLARE db_cursor CURSOR
	LOCAL FAST_FORWARD
	FOR SELECT	[name]
		FROM	[dbo].[sysdatabases]
		WHERE	[name] NOT IN ('master', 'msdb','tempdb', 'model')

OPEN db_cursor
	FETCH NEXT FROM db_cursor INTO @dbname
	WHILE @@FETCH_STATUS = 0
		BEGIN
			SELECT @statement = 'USE ' + @dbname  + ';' +
								'CREATE USER [ServiceAccountName] FOR LOGIN [ServiceAccountName];' +
								'EXEC sp_addrolemember @rolename = ''someRole'', @membername = ''ServiceAccountName'';' +
								'GRANT VIEW DATABASE STATE TO ServiceAccountName;'

			EXEC sp_executesql @statement

			FETCH NEXT FROM db_cursor INTO @dbname
		END

CLOSE db_cursor
DEALLOCATE db_cursor

Use [tempdb];
GO

CREATE USER [ServiceAccountName] FOR LOGIN [ServiceAccountName];
EXEC sp_addrolemember @rolename = 'db_owner', @membername = 'ServiceAccountName';

Use [master];
ALTER SERVER ROLE [SomeCustomRoleName] ADD MEMBER [ServiceAccountName]
GO