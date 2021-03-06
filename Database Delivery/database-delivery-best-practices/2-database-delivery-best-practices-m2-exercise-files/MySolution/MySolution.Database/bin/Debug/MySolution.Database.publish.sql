﻿/*
Deployment script for vk_migration_test

This code was generated by a tool.
Changes to this file may cause incorrect behavior and will be lost if
the code is regenerated.
*/

GO
SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, CONCAT_NULL_YIELDS_NULL, QUOTED_IDENTIFIER ON;

SET NUMERIC_ROUNDABORT OFF;


GO
:setvar DatabaseName "vk_migration_test"
:setvar DefaultFilePrefix "vk_migration_test"
:setvar DefaultDataPath "C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQL2017DEV\MSSQL\DATA\"
:setvar DefaultLogPath "C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQL2017DEV\MSSQL\DATA\"

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
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET ANSI_NULLS ON,
                ANSI_PADDING ON,
                ANSI_WARNINGS ON,
                ARITHABORT ON,
                CONCAT_NULL_YIELDS_NULL ON,
                QUOTED_IDENTIFIER ON,
                ANSI_NULL_DEFAULT ON,
                CURSOR_DEFAULT LOCAL 
            WITH ROLLBACK IMMEDIATE;
    END


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET PAGE_VERIFY NONE 
            WITH ROLLBACK IMMEDIATE;
    END


GO
ALTER DATABASE [$(DatabaseName)]
    SET TARGET_RECOVERY_TIME = 0 SECONDS 
    WITH ROLLBACK IMMEDIATE;


GO
DECLARE @CurrentVersion int
SELECT	@CurrentVersion = CAST ([Value] as int)
FROM	dbo.Settings
WHERE	[Name] = N'Version'

IF (@CurrentVersion < 5)
BEGIN
  CREATE TABLE dbo.tmp_UserNames (ID bigint, [Name] nvarchar(200))

  INSERT	dbo.tmp_UserNames (ID, [Name])
  SELECT	u.UserID, u.[Name]
  FROM		dbo.[User] u
END

IF (@CurrentVersion < 7)
BEGIN
  CREATE TABLE dbo.tmp_UserStatuses (ID bigint, [Name] nvarchar(50))

  INSERT	dbo.tmp_UserStatuses (ID, [Name])
  SELECT	u.UserID, u.[Status]
  FROM		dbo.[User] u
END
GO

GO
PRINT N'The following operation was generated from a refactoring log file d58e0d06-7806-4eed-a2f0-3fe6e72673d9';

PRINT N'Rename [dbo].[User].[PrimaryEmail] to Email';


GO
EXECUTE sp_rename @objname = N'[dbo].[User].[PrimaryEmail]', @newname = N'Email', @objtype = N'COLUMN';


GO
/*
The column [dbo].[User].[Name] is being dropped, data loss could occur.

The column [dbo].[User].[Status] is being dropped, data loss could occur.

The column [dbo].[User].[FirstName] on table [dbo].[User] must be added, but the column has no default value and does not allow NULL values. If the table contains data, the ALTER script will not work. To avoid this issue you must either: add a default value to the column, mark it as allowing NULL values, or enable the generation of smart-defaults as a deployment option.

The column [dbo].[User].[LastName] on table [dbo].[User] must be added, but the column has no default value and does not allow NULL values. If the table contains data, the ALTER script will not work. To avoid this issue you must either: add a default value to the column, mark it as allowing NULL values, or enable the generation of smart-defaults as a deployment option.

The column [dbo].[User].[StatusID] on table [dbo].[User] must be added, but the column has no default value and does not allow NULL values. If the table contains data, the ALTER script will not work. To avoid this issue you must either: add a default value to the column, mark it as allowing NULL values, or enable the generation of smart-defaults as a deployment option.
*/
GO
PRINT N'Starting rebuilding table [dbo].[User]...';


GO
BEGIN TRANSACTION;

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

SET XACT_ABORT ON;

CREATE TABLE [dbo].[tmp_ms_xx_User] (
    [UserID]    BIGINT         NOT NULL,
    [FirstName] NVARCHAR (100) NOT NULL,
    [LastName]  NVARCHAR (100) NOT NULL,
    [Email]     NVARCHAR (256) NOT NULL,
    [StatusID]  BIGINT         NOT NULL,
    CONSTRAINT [tmp_ms_xx_constraint_PK_User1] PRIMARY KEY CLUSTERED ([UserID] ASC)
);

IF EXISTS (SELECT TOP 1 1 
           FROM   [dbo].[User])
    BEGIN
        INSERT INTO [dbo].[tmp_ms_xx_User] ([UserID], [Email])
        SELECT   [UserID],
                 [Email]
        FROM     [dbo].[User]
        ORDER BY [UserID] ASC;
    END

DROP TABLE [dbo].[User];

EXECUTE sp_rename N'[dbo].[tmp_ms_xx_User]', N'User';

EXECUTE sp_rename N'[dbo].[tmp_ms_xx_constraint_PK_User1]', N'PK_User', N'OBJECT';

COMMIT TRANSACTION;

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;


GO
PRINT N'Creating [dbo].[UserStatus]...';


GO
CREATE TABLE [dbo].[UserStatus] (
    [UserStatusID] BIGINT        NOT NULL,
    [Name]         NVARCHAR (50) NOT NULL,
    CONSTRAINT [PK_UserStatus] PRIMARY KEY CLUSTERED ([UserStatusID] ASC)
);


GO
PRINT N'Creating [dbo].[FK_User_UserStatus]...';


GO
ALTER TABLE [dbo].[User] WITH NOCHECK
    ADD CONSTRAINT [FK_User_UserStatus] FOREIGN KEY ([StatusID]) REFERENCES [dbo].[UserStatus] ([UserStatusID]);


GO
PRINT N'Creating [dbo].[GetUsers]...';


GO
-- =============================================
-- Author:		Vitalii Kudriavtcev
-- Create date: 21 march 2019
-- Description:	get all users data
-- =============================================
CREATE PROCEDURE [dbo].[GetUsers]
AS
BEGIN
	SET NOCOUNT ON;

    SELECT	u.UserID
			, u.FirstName
			, u.LastName
			, u.Email
			, s.[Name] [Status]
	FROM	dbo.[User] u
			INNER JOIN dbo.UserStatus s ON u.StatusID = s.UserStatusID

END
GO
-- Refactoring step to update target server with deployed transaction logs

IF OBJECT_ID(N'dbo.__RefactorLog') IS NULL
BEGIN
    CREATE TABLE [dbo].[__RefactorLog] (OperationKey UNIQUEIDENTIFIER NOT NULL PRIMARY KEY)
    EXEC sp_addextendedproperty N'microsoft_database_tools_support', N'refactoring log', N'schema', N'dbo', N'table', N'__RefactorLog'
END
GO
IF NOT EXISTS (SELECT OperationKey FROM [dbo].[__RefactorLog] WHERE OperationKey = 'd58e0d06-7806-4eed-a2f0-3fe6e72673d9')
INSERT INTO [dbo].[__RefactorLog] (OperationKey) values ('d58e0d06-7806-4eed-a2f0-3fe6e72673d9')

GO

GO
DECLARE @NewVersion int
SET @NewVersion = 9

DECLARE @CurrentVersion int
SELECT @CurrentVersion = CAST (Value as int)
FROM dbo.Settings
WHERE Name = 'Version'

IF (@CurrentVersion < 5)
BEGIN
  UPDATE dbo.[User]
  SET FirstName = LEFT(Name, CHARINDEX(' ', Name) - 1),
	  LastName = RIGHT(Name, LEN(Name) - CHARINDEX(' ', Name))
  FROM dbo.[User] u
  INNER JOIN dbo.tmp_UserNames n ON n.ID = u.UserID
 
  DROP TABLE dbo.tmp_UserNames
END

IF (@CurrentVersion < 7)
BEGIN
  INSERT dbo.UserStatus (UserStatusID, Name) VALUES (1, 'Regular')
  INSERT dbo.UserStatus (UserStatusID, Name) VALUES (2, 'Preferred')
  INSERT dbo.UserStatus (UserStatusID, Name) VALUES (3, 'Gold')

  UPDATE dbo.[User]
  SET StatusID = CASE WHEN s.Name = 'Preferred' THEN 2 WHEN s.Name = 'Gold' THEN 3 ELSE 1 END
  FROM dbo.[User] u
  INNER JOIN dbo.tmp_UserStatuses s ON s.ID = u.UserID

  DROP TABLE dbo.tmp_UserStatuses
END


--fill user status table
IF EXISTS (SELECT TOP 1 1 FROM dbo.UserStatus WHERE UserStatusID = 1)
	UPDATE dbo.UserStatus SET Name = 'Bronze' WHERE UserStatusID = 1
ELSE
	INSERT dbo.UserStatus (UserStatusID, Name) VALUES (1, 'Bronze')

IF EXISTS (SELECT TOP 1 1 FROM dbo.UserStatus WHERE UserStatusID = 2)
	UPDATE dbo.UserStatus SET Name = 'Silver' WHERE UserStatusID = 2
ELSE
	INSERT dbo.UserStatus (UserStatusID, Name) VALUES (2, 'Silver')

IF EXISTS (SELECT TOP 1 1 FROM dbo.UserStatus WHERE UserStatusID = 3)
	UPDATE dbo.UserStatus SET Name = 'Gold' WHERE UserStatusID = 3
ELSE
	INSERT dbo.UserStatus (UserStatusID, Name) VALUES (3, 'Gold')


IF (EXISTS (SELECT TOP 1 1 FROM dbo.Settings WHERE [Name] = N'Version'))
BEGIN
	UPDATE dbo.Settings
	SET [Value] = @NewVersion
	WHERE [Name] = N'Version'
END
ELSE
BEGIN
	INSERT dbo.Settings ([Name], [Value])
	VALUES (N'Version', @NewVersion)
END
GO

GO
PRINT N'Checking existing data against newly created constraints';


GO
USE [$(DatabaseName)];


GO
ALTER TABLE [dbo].[User] WITH CHECK CHECK CONSTRAINT [FK_User_UserStatus];


GO
PRINT N'Update complete.';


GO
