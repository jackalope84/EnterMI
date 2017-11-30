USE master;
GO

CREATE TABLE [dbo].[#compatibilityLevels](
    [name] [nvarchar](50) NOT NULL,
    [code] [int] NOT NULL)
GO

INSERT INTO [dbo].[#compatibilityLevels]
            ([name],[code])
    VALUES  ('SQL2017',140),
            ('SQL2016',130),
            ('SQL2014',120),
            ('SQL2012',110),
            ('SQL2008',105),
            ('SQL2008',100),
            ('SQL2005',90),
            ('SQL2000',80)

SELECT   db.[name]
        --,db.database_id
        ,usr.[name] AS [owner]
        ,db.[create_date]
        ,CONVERT(varchar(5), db.[compatibility_level]) + ' (' + cl.[name] + ')' AS compatibility_level
        ,[collation_name]
        ,recovery_model_desc
        ,(SELECT TOP (1)
                 [name]
          FROM   [sys].[master_files]
          WHERE  [database_id] = db.[database_id]
          AND    [type] = 0) AS data_file
        ,(SELECT TOP (1)
                 REPLACE([physical_name],'C:\Program Files\Microsoft SQL Server\', 'C:\...\')
          FROM   [sys].[master_files]
          WHERE  [database_id] = db.[database_id]
          AND    [type] = 0) AS data_file_location
        ,(SELECT TOP (1)
                 CONVERT(varchar(16),([size] * 8) / 1024) + ' Mb'
          FROM   [sys].[master_files]
          WHERE  [database_id] = db.[database_id]
          AND    [type] = 0) AS data_file_size
        ,(SELECT TOP (1)
                 [name]
          FROM   [sys].[master_files]
          WHERE  [database_id] = db.[database_id]
          AND    [type] = 1) AS log_file
        ,(SELECT TOP (1)
                 REPLACE([physical_name],'C:\Program Files\Microsoft SQL Server\', 'C:\...\')
          FROM   [sys].[master_files]
          WHERE  [database_id] = db.[database_id]
          AND    [type] = 1) AS log_file_location
        ,(SELECT TOP (1)
                 CONVERT(varchar(16),([size] * 8) / 1024) + ' Mb'
          FROM   [sys].[master_files]
          WHERE  [database_id] = db.[database_id]
          AND    [type] = 1) AS log_file_size
FROM    [sys].[databases] AS db LEFT JOIN
        [sys].[syslogins] AS usr ON db.[owner_sid] = usr.[sid] LEFT JOIN
        [#compatibilityLevels] AS cl ON db.[compatibility_level] = cl.code

DROP TABLE [dbo].[#compatibilityLevels]