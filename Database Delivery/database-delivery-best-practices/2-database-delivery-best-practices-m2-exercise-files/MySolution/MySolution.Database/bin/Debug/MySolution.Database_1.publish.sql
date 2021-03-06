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
DECLARE	@CurrentVersion int = (	SELECT	TOP 1 CAST (s.[Value] as int)
								FROM	dbo.Settings s
								WHERE	s.[Name] = N'Version');
----Splitting the Name Column
IF (@CurrentVersion < 5)
BEGIN
  CREATE TABLE dbo.tmp_UserNames (ID bigint, [Name] nvarchar(200));

  INSERT	dbo.tmp_UserNames (ID, [Name])
  SELECT	u.UserID, u.[Name]
  FROM		dbo.[User] u;
END

--Extracting a User Status Table
IF (@CurrentVersion < 7)
BEGIN
  CREATE TABLE dbo.tmp_UserStatuses (ID bigint, [Name] nvarchar(50));

  INSERT	dbo.tmp_UserStatuses (ID, [Name])
  SELECT	u.UserID, u.[Status]
  FROM		dbo.[User] u;
END
GO

GO
DECLARE @NewVersion int = 9;--increase it after every changing ???

DECLARE	@CurrentVersion int = (	SELECT	TOP 1 CAST (s.[Value] as int)
								FROM	dbo.Settings s
								WHERE	s.[Name] = N'Version');

--Splitting the Name Column
IF (@CurrentVersion < 5)
BEGIN
  UPDATE u
  SET	FirstName	= LEFT([Name], CHARINDEX(' ', [Name]) - 1),
		LastName	= RIGHT([Name], LEN([Name]) - CHARINDEX(' ', [Name]))
  FROM	dbo.[User] u
		INNER JOIN dbo.tmp_UserNames n ON n.ID = u.UserID;
 
  DROP TABLE dbo.tmp_UserNames;
END

--Extracting a User Status Table
IF (@CurrentVersion < 7)
BEGIN
  INSERT dbo.UserStatus (UserStatusID, Name) 
  VALUES(1, N'Regular'),
		(2, N'Preferred'),
		(3, N'Gold');

  UPDATE	u
  SET		StatusID =	CASE	WHEN s.[Name] = N'Preferred' THEN 2 
								WHEN s.[Name] = N'Gold'	THEN 3 
								ELSE 1 
						END
  FROM		dbo.[User] u
  INNER JOIN dbo.tmp_UserStatuses s ON s.ID = u.UserID;

  DROP TABLE dbo.tmp_UserStatuses;
END


--fill user status table
IF EXISTS (SELECT TOP 1 1 FROM dbo.UserStatus WHERE UserStatusID = 1)
	UPDATE dbo.UserStatus SET Name = 'Bronze' WHERE UserStatusID = 1;
ELSE
	INSERT dbo.UserStatus (UserStatusID, Name) VALUES (1, 'Bronze');

IF EXISTS (SELECT TOP 1 1 FROM dbo.UserStatus WHERE UserStatusID = 2)
	UPDATE dbo.UserStatus SET Name = 'Silver' WHERE UserStatusID = 2;
ELSE
	INSERT dbo.UserStatus (UserStatusID, Name) VALUES (2, 'Silver');

IF EXISTS (SELECT TOP 1 1 FROM dbo.UserStatus WHERE UserStatusID = 3)
	UPDATE dbo.UserStatus SET Name = 'Gold' WHERE UserStatusID = 3
ELSE
	INSERT dbo.UserStatus (UserStatusID, Name) VALUES (3, 'Gold');


IF (EXISTS (SELECT TOP 1 1 FROM dbo.Settings WHERE [Name] = N'Version'))
BEGIN
	UPDATE dbo.Settings
	SET [Value] = @NewVersion
	WHERE [Name] = N'Version';
END
ELSE
BEGIN
	INSERT dbo.Settings ([Name], [Value])
	VALUES (N'Version', @NewVersion);
END
GO

GO
PRINT N'Update complete.';


GO
