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
PRINT N'Altering [DDL].[CreateCUDProcs]...';


GO


ALTER PROCEDURE [DDL].[CreateCUDProcs]
(   @ProcSchemaName NVARCHAR(255)
  , @ProcName NVARCHAR(255)
  , @TableSchemaName NVARCHAR(255)
  ,	@TableName NVARCHAR(255)
  , @InsertStart BIGINT      -- Set the max value to load
  , @UpdateFrom BIGINT
  , @UpdateThru BIGINT
  , @DeleteFrom BIGINT
  , @DeleteThru BIGINT
  , @IncludeType2Change BIT = 0
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
  SET @sqlStatement = @sqlStatement + '  EXEC DML.UpdateSourceTable  ''' + @TableSchemaName + ''', ''' + @TableName + ''', ' + CAST(@UpdateFrom AS NVARCHAR) + ', ' + CAST(@UpdateThru AS NVARCHAR) + ', ' + CAST(@IncludeType2Change AS NVARCHAR) + ' ' + @crlf
  SET @sqlStatement = @sqlStatement + '  EXEC DML.DeleteFromSourceTable ''' + @TableSchemaName + ''', ''' + @TableName + ''', ' + CAST(@DeleteFrom AS NVARCHAR) + ', ' + CAST(@DeleteThru AS NVARCHAR) + ' ' + @crlf
  SET @sqlStatement = @sqlStatement + ' ' + @crlf
  SET @sqlStatement = @sqlStatement + 'END ' + @crlf

  EXECUTE sp_executesql @sqlStatement

END
GO
PRINT N'Refreshing [DDL].[CreateAllObjects]...';


GO
EXECUTE sp_refreshsqlmodule N'[DDL].[CreateAllObjects]';


GO
PRINT N'Update complete.';


GO
