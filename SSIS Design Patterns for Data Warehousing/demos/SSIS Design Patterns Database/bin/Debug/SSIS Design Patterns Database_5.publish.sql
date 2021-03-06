﻿/*
Deployment script for SSISDesignPatterns

This code was generated by a tool.
Changes to this file may cause incorrect behavior and will be lost if
the code is regenerated.
*/

GO
SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, CONCAT_NULL_YIELDS_NULL, QUOTED_IDENTIFIER ON;

SET NUMERIC_ROUNDABORT OFF;


GO
:setvar DatabaseName "SSISDesignPatterns"
:setvar DefaultFilePrefix "SSISDesignPatterns"
:setvar DefaultDataPath "C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\"
:setvar DefaultLogPath "C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\"

GO
:on error exit
GO
/*
Detect SQLCMD mode and disable script execution if SQLCMD mode is not supported.
To re-enable the script after enabling SQLCMD mode, execute the following:
SET NOEXEC OFF; 
*/
:setvar __IsSqlCmdEnabled "True"
GO
IF N'$(__IsSqlCmdEnabled)' NOT LIKE N'True'
    BEGIN
        PRINT N'SQLCMD mode must be enabled to successfully execute this script.';
        SET NOEXEC ON;
    END


GO
USE [$(DatabaseName)];


GO
PRINT N'Creating [DDL].[CreateCUDProcsType1]...';


GO


CREATE PROCEDURE [DDL].[CreateCUDProcsType1]
(   @ProcSchemaName NVARCHAR(255)
  , @ProcName NVARCHAR(255)
  , @TableSchemaName NVARCHAR(255)
  ,	@TableName NVARCHAR(255)
  , @InsertStart BIGINT      -- Set the max value to load
  , @UpdateFrom BIGINT
  , @UpdateThru BIGINT
)
AS
BEGIN

  DECLARE @sqlStatement NVARCHAR(2000)
  DECLARE @crlf NCHAR(2)
  SET @crlf = char(13) + char(10)
  
  -- If the proc already exists, drop it
  IF EXISTS (SELECT [SPECIFIC_SCHEMA]
                  , [SPECIFIC_NAME]
               FROM [INFORMATION_SCHEMA].[ROUTINES]
              WHERE [ROUTINE_TYPE] = 'PROCEDURE'
                AND [SPECIFIC_SCHEMA] = @ProcSchemaName 
                AND [SPECIFIC_NAME] = @ProcName
            )
  BEGIN
    SET @sqlStatement = ''
    SET @sqlStatement = 'DROP PROCEDURE [' + @ProcSchemaName + '].[' + @ProcName + '];'
    EXECUTE sp_executesql @sqlStatement
  END
  
  -- Create the proc
  SET @sqlStatement = ''
  SET @sqlStatement = @sqlStatement + 'CREATE PROCEDURE [' + @ProcSchemaName + '].[' + @ProcName + '] ' + @crlf
  SET @sqlStatement = @sqlStatement + 'AS ' + @crlf
  SET @sqlStatement = @sqlStatement + 'BEGIN ' + @crlf
  SET @sqlStatement = @sqlStatement + ' ' + @crlf

  SET @sqlStatement = @sqlStatement + '  EXEC DML.InsertIntoSourceTable ''' + @TableSchemaName + ''', ''' + @TableName + ''', ' + CAST(@InsertStart AS NVARCHAR) + ' ' + @crlf
  SET @sqlStatement = @sqlStatement + '  EXEC DML.UpdateSourceTableType1  ''' + @TableSchemaName + ''', ''' + @TableName + ''', ' + CAST(@UpdateFrom AS NVARCHAR) + ', ' + CAST(@UpdateThru AS NVARCHAR) + ' ' + @crlf
  SET @sqlStatement = @sqlStatement + ' ' + @crlf
  SET @sqlStatement = @sqlStatement + 'END ' + @crlf

  EXECUTE sp_executesql @sqlStatement

END
GO
PRINT N'Creating [DDL].[CreateCUDProcsType2]...';


GO


CREATE PROCEDURE [DDL].[CreateCUDProcsType2]
(   @ProcSchemaName NVARCHAR(255)
  , @ProcName NVARCHAR(255)
  , @TableSchemaName NVARCHAR(255)
  ,	@TableName NVARCHAR(255)
  , @InsertStart BIGINT      -- Set the max value to load
  , @UpdateFrom BIGINT
  , @UpdateThru BIGINT
)
AS
BEGIN

  DECLARE @sqlStatement NVARCHAR(2000)
  DECLARE @crlf NCHAR(2)
  SET @crlf = char(13) + char(10)
  
  -- If the proc already exists, drop it
  IF EXISTS (SELECT [SPECIFIC_SCHEMA]
                  , [SPECIFIC_NAME]
               FROM [INFORMATION_SCHEMA].[ROUTINES]
              WHERE [ROUTINE_TYPE] = 'PROCEDURE'
                AND [SPECIFIC_SCHEMA] = @ProcSchemaName 
                AND [SPECIFIC_NAME] = @ProcName
            )
  BEGIN
    SET @sqlStatement = ''
    SET @sqlStatement = 'DROP PROCEDURE [' + @ProcSchemaName + '].[' + @ProcName + '];'
    EXECUTE sp_executesql @sqlStatement
  END
  
  -- Create the proc
  SET @sqlStatement = ''
  SET @sqlStatement = @sqlStatement + 'CREATE PROCEDURE [' + @ProcSchemaName + '].[' + @ProcName + '] ' + @crlf
  SET @sqlStatement = @sqlStatement + 'AS ' + @crlf
  SET @sqlStatement = @sqlStatement + 'BEGIN ' + @crlf
  SET @sqlStatement = @sqlStatement + ' ' + @crlf

  SET @sqlStatement = @sqlStatement + '  EXEC DML.InsertIntoSourceTable ''' + @TableSchemaName + ''', ''' + @TableName + ''', ' + CAST(@InsertStart AS NVARCHAR) + ' ' + @crlf
  SET @sqlStatement = @sqlStatement + '  EXEC DML.UpdateSourceTableType2  ''' + @TableSchemaName + ''', ''' + @TableName + ''', ' + CAST(@UpdateFrom AS NVARCHAR) + ', ' + CAST(@UpdateThru AS NVARCHAR) + ' ' + @crlf
  SET @sqlStatement = @sqlStatement + ' ' + @crlf
  SET @sqlStatement = @sqlStatement + 'END ' + @crlf

  EXECUTE sp_executesql @sqlStatement

END
GO
PRINT N'Altering [DDL].[CreateAllObjects]...';


GO

ALTER PROCEDURE [DDL].[CreateAllObjects]
AS
BEGIN

  DECLARE @MaxRows         BIGINT = 100000
  DECLARE @MaxRowsSmall    BIGINT = 10000
  DECLARE @InsertRows      BIGINT = 150000
  DECLARE @UpdateFrom      BIGINT = 1000
  DECLARE @UpdateThru      BIGINT = 5000
  DECLARE @InsertRowsSmall BIGINT = 15000
  DECLARE @UpdateFromSmall BIGINT = 100
  DECLARE @UpdateThruSmall BIGINT = 500

  PRINT 'Creating 01_Trunc_and_Load with ' + FORMAT(@MaxRows, '#,##0') + ' rows'
  EXEC DDL.CreateSourceTable 'Source', '01_Trunc_and_Load', @MaxRows

  PRINT 'Creating 02_SCD_Type_1 with ' + FORMAT(@MaxRows, '#,##0') + ' rows'
  EXEC DDL.CreateSourceTable 'Source', '02_SCD_Type_1', @MaxRowsSmall

  PRINT 'Creating 03_SCD_Type_2 with ' + FORMAT(@MaxRows, '#,##0') + ' rows'
  EXEC DDL.CreateSourceTable 'Source', '03_SCD_Type_2', @MaxRowsSmall

  PRINT 'Creating 04_Set_Based with ' + FORMAT(@MaxRows, '#,##0') + ' rows'
  EXEC DDL.CreateSourceTable 'Source', '04_Set_Based', @MaxRows

  PRINT 'Creating 05_Hashbytes with ' + FORMAT(@MaxRows, '#,##0') + ' rows'
  EXEC DDL.CreateSourceTable 'Source', '05_Hashbytes', @MaxRows

  PRINT 'Creating 06_CDC with ' + FORMAT(@MaxRows, '#,##0') + ' rows'
  EXEC DDL.CreateSourceTable 'Source', '06_CDC', @MaxRows

  PRINT 'Creating 07_Merge with ' + FORMAT(@MaxRows, '#,##0') + ' rows'
  EXEC DDL.CreateSourceTable 'Source', '07_Merge', @MaxRows

  PRINT 'Creating 08_Date_Based with ' + FORMAT(@MaxRows, '#,##0') + ' rows'
  EXEC DDL.CreateSourceTable 'Source', '08_Date_Based', @MaxRows
  
  PRINT 'Creating Target Tables'
  EXEC DDL.CreateTargetTable 'Target', '01_Trunc_and_Load'
  EXEC DDL.CreateTargetTable 'Target', '02_SCD_Type_1'
  EXEC DDL.CreateTargetTable 'Target', '03_SCD_Type_2'
  EXEC DDL.CreateTargetTable 'Target', '04_Set_Based'
  EXEC DDL.CreateTargetTable 'Target', '05_Hashbytes' 
  EXEC DDL.CreateTargetTable 'Target', '06_CDC'
  EXEC DDL.CreateTargetTable 'Target', '07_Merge'
  EXEC DDL.CreateTargetTable 'Target', '08_Date_Based'
  
  PRINT 'Creating ETL Tables'
  EXEC [DDL].[CreateETLTable] '05_Hashbytes'
  
  
  PRINT 'Creating Stored Procedures'
  EXEC [DDL].[CreateCUDProcs] 'CUD', '01_Trunc_and_Load', 'Source', '01_Trunc_and_Load', @InsertRows, @UpdateFrom, @UpdateThru
  EXEC [DDL].[CreateCUDProcsType1] 'CUD', '02_SCD_Type_1',     'Source', '02_SCD_Type_1', @InsertRowsSmall, @UpdateFromSmall, @UpdateThruSmall
  EXEC [DDL].[CreateCUDProcsType2] 'CUD', '03_SCD_Type_2',     'Source', '03_SCD_Type_2', @InsertRowsSmall, @UpdateFromSmall, @UpdateThruSmall
  EXEC [DDL].[CreateCUDProcs] 'CUD', '04_Set_Based' ,     'Source', '04_Set_Based' , @InsertRows, @UpdateFrom, @UpdateThru
  EXEC [DDL].[CreateCUDProcs] 'CUD', '05_Hashbytes' ,     'Source', '05_Hashbytes' , @InsertRows, @UpdateFrom, @UpdateThru
  EXEC [DDL].[CreateCUDProcs] 'CUD', '06_CDC'       ,     'Source', '06_CDC'       , @InsertRows, @UpdateFrom, @UpdateThru
  EXEC [DDL].[CreateCUDProcs] 'CUD', '07_Merge'     ,     'Source', '07_Merge'     , @InsertRows, @UpdateFrom, @UpdateThru
  EXEC [DDL].[CreateCUDProcs] 'CUD', '08_Date_Based',     'Source', '08_Date_Based', @InsertRows, @UpdateFrom, @UpdateThru
 
  
  PRINT 'Done' 

END
GO
PRINT N'Update complete.';


GO
