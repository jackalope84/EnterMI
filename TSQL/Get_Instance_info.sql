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