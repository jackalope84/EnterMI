/*

SQL Server Instance information script - SQL Server 2008, SQL Server 2008 R2, SQL Server 2012, SQL Server 2014, and SQL Server 2016

You can contact me by e-mail at floris@entermi.nl.

Last updated 1 December, 2017.

Floris van Enter
http://entermi.nl

*/

SELECT
  SERVERPROPERTY('MachineName') AS ComputerName,
  SERVERPROPERTY('ServerName') AS InstanceName,
  SERVERPROPERTY('Edition') AS Edition,
  SERVERPROPERTY('ProductVersion') AS ProductVersion,
  SERVERPROPERTY('ProductLevel') AS ProductLevel,
  SERVERPROPERTY('EngineEdition') AS EngineEdition,
  SERVERPROPERTY('HadrManagerStatus') AS HadrManagerStatus,
  SERVERPROPERTY('ProductBuild') AS ProductBuild,
  SERVERPROPERTY('ProductLevel') AS ProductLevel;
GO