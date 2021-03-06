USE [master]
GO
/****** Object:  Database [Admin]    Script Date: 8/17/2021 3:06:17 PM ******/
CREATE DATABASE [Admin]
 CONTAINMENT = NONE
ON  PRIMARY 
( NAME = N'Admin', FILENAME = N'/var/opt/mssql/data/Admin.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
LOG ON 
( NAME = N'Admin_log', FILENAME = N'/var/opt/mssql/data/Admin_log.ldf' , SIZE = 73728KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
--WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO
--ALTER DATABASE [Admin] SET COMPATIBILITY_LEVEL = 150
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [Admin].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [Admin] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [Admin] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [Admin] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [Admin] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [Admin] SET ARITHABORT OFF 
GO
ALTER DATABASE [Admin] SET AUTO_CLOSE ON 
GO
ALTER DATABASE [Admin] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [Admin] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [Admin] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [Admin] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [Admin] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [Admin] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [Admin] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [Admin] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [Admin] SET  ENABLE_BROKER 
GO
ALTER DATABASE [Admin] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [Admin] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [Admin] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [Admin] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [Admin] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [Admin] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [Admin] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [Admin] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [Admin] SET  MULTI_USER 
GO
ALTER DATABASE [Admin] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [Admin] SET DB_CHAINING OFF 
GO
ALTER DATABASE [Admin] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [Admin] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [Admin] SET DELAYED_DURABILITY = DISABLED 
GO
--ALTER DATABASE [Admin] SET ACCELERATED_DATABASE_RECOVERY = OFF  
--GO
ALTER DATABASE [Admin] SET QUERY_STORE = OFF
GO
USE [Admin]
GO
/****** Object:  Table [dbo].[CycleStatus]    Script Date: 8/17/2021 3:06:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
USE [Admin]
GO
/****** Object:  Schema [edw]    Script Date: 8/20/2021 4:26:47 PM ******/
CREATE SCHEMA [edw]
GO
/****** Object:  Schema [history]    Script Date: 8/20/2021 4:26:47 PM ******/
CREATE SCHEMA [history]
GO
/****** Object:  Schema [import]    Script Date: 8/20/2021 4:26:47 PM ******/
CREATE SCHEMA [import]
GO
/****** Object:  Schema [MD]    Script Date: 8/20/2021 4:26:48 PM ******/
CREATE SCHEMA [MD]
GO
/****** Object:  Schema [org]    Script Date: 8/20/2021 4:26:48 PM ******/
CREATE SCHEMA [org]
GO
/****** Object:  Schema [Testsch]    Script Date: 8/20/2021 4:26:48 PM ******/
CREATE SCHEMA [Testsch]
GO
/****** Object:  UserDefinedTableType [dbo].[AppUrlMappingTableParm]    Script Date: 8/20/2021 4:26:48 PM ******/
CREATE TYPE [dbo].[AppUrlMappingTableParm] AS TABLE(
	[RowNo] [int] NOT NULL,
	[CompanyID] [int] NOT NULL,
	[AppOrUrl] [nvarchar](200) NOT NULL,
	[DisplayName] [nvarchar](100) NOT NULL,
	[Activity] [nvarchar](100) NOT NULL,
	[IsWindows] [bit] NULL,
	[IsLinux] [bit] NULL,
	[IsMac] [bit] NULL,
	[UrlMatchStrategy] [nvarchar](100) NULL,
	[UrlMatchContent] [nvarchar](100) NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL
)
GO
/****** Object:  UserDefinedTableType [dbo].[UserCustomFieldTableParm]    Script Date: 9/9/2021 5:03:53 PM ******/
CREATE TYPE [dbo].[UserCustomFieldTableParm] AS TABLE(
	[RowNo] [int] NOT NULL,
	[CompanyID] [int] NOT NULL,
	[CustomFieldID] [int] NOT NULL,
	[CustomFieldName] [nvarchar](100) NOT NULL,
	[UserEmail] [nvarchar](255) NOT NULL,
	[TextValue] [nvarchar](200) NULL,
	[NumericValue] [float] NULL,
	[BooleanValue] [bit] NULL,
	[ModifiedBy] [nvarchar](200) NOT NULL
)
GO
/****** Object:  UserDefinedTableType [dbo].[UserTableParm2]    Script Date: 9/9/2021 5:03:53 PM ******/
CREATE TYPE [dbo].[UserTableParm2] AS TABLE(
	[RowNo] [int] NOT NULL,
	[CompanyID] [int] NOT NULL,
	[UserID] [int] NULL,
	[ExternalUserID] [nvarchar](50) NULL,
	[TeamID] [int] NULL,
	[DepartmentID] [int] NULL,
	[JobFamilyActivityOverrideProfileID] [int] NULL,
	[VendorID] [int] NULL,
	[LocationID] [int] NOT NULL,
	[WorkScheduleID] [int] NOT NULL,
	[UserEmail] [nvarchar](255) NOT NULL,
	[FirstName] [nvarchar](100) NOT NULL,
	[LastName] [nvarchar](100) NOT NULL,
	[JobTitle] [nvarchar](100) NULL,
	[IsFullTimeEmployee] [bit] NOT NULL,
	[IsActivityCollectionOn] [bit] NULL,
	[IsManager] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[UserDomainID1] [int] NULL,
	[UserName1] [nvarchar](128) NULL,
	[DomainName1] [nvarchar](128) NULL,
	[UserDomainID2] [int] NULL,
	[UserName2] [nvarchar](128) NULL,
	[DomainName2] [nvarchar](128) NULL,
	[RequiresVueAccess] [bit] NULL
)
GO
/****** Object:  UserDefinedFunction [dbo].[fn_diagramobjects]    Script Date: 8/20/2021 4:26:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

	CREATE FUNCTION [dbo].[fn_diagramobjects]() 
	RETURNS int
	WITH EXECUTE AS N'dbo'
	AS
	BEGIN
		declare @id_upgraddiagrams		int
		declare @id_sysdiagrams			int
		declare @id_helpdiagrams		int
		declare @id_helpdiagramdefinition	int
		declare @id_creatediagram	int
		declare @id_renamediagram	int
		declare @id_alterdiagram 	int 
		declare @id_dropdiagram		int
		declare @InstalledObjects	int

		select @InstalledObjects = 0

		select 	@id_upgraddiagrams = object_id(N'dbo.sp_upgraddiagrams'),
			@id_sysdiagrams = object_id(N'dbo.sysdiagrams'),
			@id_helpdiagrams = object_id(N'dbo.sp_helpdiagrams'),
			@id_helpdiagramdefinition = object_id(N'dbo.sp_helpdiagramdefinition'),
			@id_creatediagram = object_id(N'dbo.sp_creatediagram'),
			@id_renamediagram = object_id(N'dbo.sp_renamediagram'),
			@id_alterdiagram = object_id(N'dbo.sp_alterdiagram'), 
			@id_dropdiagram = object_id(N'dbo.sp_dropdiagram')

		if @id_upgraddiagrams is not null
			select @InstalledObjects = @InstalledObjects + 1
		if @id_sysdiagrams is not null
			select @InstalledObjects = @InstalledObjects + 2
		if @id_helpdiagrams is not null
			select @InstalledObjects = @InstalledObjects + 4
		if @id_helpdiagramdefinition is not null
			select @InstalledObjects = @InstalledObjects + 8
		if @id_creatediagram is not null
			select @InstalledObjects = @InstalledObjects + 16
		if @id_renamediagram is not null
			select @InstalledObjects = @InstalledObjects + 32
		if @id_alterdiagram  is not null
			select @InstalledObjects = @InstalledObjects + 64
		if @id_dropdiagram is not null
			select @InstalledObjects = @InstalledObjects + 128
		
		return @InstalledObjects 
	END
	
GO
/****** Object:  UserDefinedFunction [dbo].[GetHostNameFromUrl]    Script Date: 8/20/2021 4:26:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[GetHostNameFromUrl] (@Url nvarchar(4000))
RETURNS NVARCHAR(400)

AS
BEGIN
   

	--set @Url = 'http://www.DomainUrl.com/abc/xyz?a=1&b=2'

	--set @Url = 'www.DomainUrl.com/abc/xyz?a=1&b=2'

	 --set @Url = 'www.DomainUrl.com'

	declare @Dot int
	declare @Slash int

	set @Dot = CHARINDEX('.', @URL)
	set @Slash = CHARINDEX('/', @URL)

	WHILE @Slash > 0 AND @Slash < @Dot
	BEGIN
		SET @URL = SUBSTRING(@URL,@Slash+1, LEN(@URL))
		set @Dot = CHARINDEX('.', @URL)
		set @Slash = CHARINDEX('/', @URL)
	END

	IF @Slash > 0 
	BEGIN
		SET @URL = LEFT(@URL, @Slash-1)
	END

		--select @Url UrlString

	RETURN @URL -- HostName

END;

GO
/****** Object:  Table [history].[ModuleLicenseLineItemHistory]    Script Date: 8/20/2021 4:26:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [history].[ModuleLicenseLineItemHistory](
	[CompanyID] [int] NOT NULL,
	[ModuleLicenseLineItemID] [int] NOT NULL,
	[LicenseTypeID] [int] NOT NULL,
	[Quantity] [int] NOT NULL,
	[PONumber] [nvarchar](500) NOT NULL,
	[StartDate] [datetime2](7) NOT NULL,
	[EndDate] [datetime2](7) NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[SysStartTimeUTC] [datetime2](7) NOT NULL,
	[SysEndTimeUTC] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [org].[ModuleLicenseLineItem]    Script Date: 8/20/2021 4:26:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [org].[ModuleLicenseLineItem](
	[CompanyID] [int] NOT NULL,
	[ModuleLicenseLineItemID] [int] IDENTITY(1,1) NOT NULL,
	[LicenseTypeID] [int] NOT NULL,
	[Quantity] [int] NOT NULL,
	[PONumber] [nvarchar](500) NOT NULL,
	[StartDate] [datetime2](7) NOT NULL,
	[EndDate] [datetime2](7) NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[SysStartTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[SysEndTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
 CONSTRAINT [PK_ModuleLicenseLineItem] PRIMARY KEY CLUSTERED 
(
	[CompanyID] ASC,
	[ModuleLicenseLineItemID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([SysStartTimeUTC], [SysEndTimeUTC])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON ( HISTORY_TABLE = [history].[ModuleLicenseLineItemHistory] )
)
GO
/****** Object:  Table [history].[IntegrationCycleErrorsHistory]    Script Date: 8/20/2021 4:26:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [history].[IntegrationCycleErrorsHistory](
	[CycleErrorId] [int] NOT NULL,
	[AccountId] [nvarchar](50) NOT NULL,
	[TimeStamp] [datetimeoffset](7) NOT NULL,
	[CycleId] [nvarchar](50) NOT NULL,
	[CycleName] [nvarchar](100) NOT NULL,
	[StepId] [nvarchar](50) NOT NULL,
	[StepName] [nvarchar](100) NOT NULL,
	[StepType] [smallint] NOT NULL,
	[TransactionId] [nvarchar](50) NOT NULL,
	[Message] [nvarchar](1000) NOT NULL,
	[Details] [nvarchar](max) NOT NULL,
	[SysStartTimeUTC] [datetime2](7) NOT NULL,
	[SysEndTimeUTC] [datetime2](7) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [org].[IntegrationCycleErrors]    Script Date: 8/20/2021 4:26:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [org].[IntegrationCycleErrors](
	[CycleErrorId] [int] IDENTITY(1,1) NOT NULL,
	[AccountId] [nvarchar](50) NOT NULL,
	[TimeStamp] [datetimeoffset](7) NOT NULL,
	[CycleId] [nvarchar](50) NOT NULL,
	[CycleName] [nvarchar](100) NOT NULL,
	[StepId] [nvarchar](50) NOT NULL,
	[StepName] [nvarchar](100) NOT NULL,
	[StepType] [smallint] NOT NULL,
	[TransactionId] [nvarchar](50) NOT NULL,
	[Message] [nvarchar](1000) NOT NULL,
	[Details] [nvarchar](max) NOT NULL,
	[SysStartTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[SysEndTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
 CONSTRAINT [PK_IntegrationCycleErrors] PRIMARY KEY CLUSTERED 
(
	[CycleErrorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([SysStartTimeUTC], [SysEndTimeUTC])
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON ( HISTORY_TABLE = [history].[IntegrationCycleErrorsHistory] )
)
GO
/****** Object:  Table [history].[ActivitySpecHistory]    Script Date: 8/20/2021 4:26:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [history].[ActivitySpecHistory](
	[CompanyID] [int] NOT NULL,
	[ActivitySpecID] [int] NOT NULL,
	[ActivitySpecName] [nvarchar](500) NOT NULL,
	[ActivitySpecDescription] [nvarchar](500) NULL,
	[IsCore] [bit] NOT NULL,
	[IsSystemDefined] [bit] NOT NULL,
	[IsWorkCategory] [bit] NOT NULL,
	[IsDefault] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[SysStartTimeUTC] [datetime2](7) NOT NULL,
	[SysEndTimeUTC] [datetime2](7) NOT NULL,
	[IsEditable] [bit] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [org].[ActivitySpec]    Script Date: 8/20/2021 4:26:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [org].[ActivitySpec](
	[CompanyID] [int] NOT NULL,
	[ActivitySpecID] [int] IDENTITY(100,1) NOT NULL,
	[ActivitySpecName] [nvarchar](500) NOT NULL,
	[ActivitySpecDescription] [nvarchar](500) NULL,
	[IsCore] [bit] NOT NULL,
	[IsSystemDefined] [bit] NOT NULL,
	[IsWorkCategory] [bit] NOT NULL,
	[IsDefault] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[SysStartTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[SysEndTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
	[IsEditable] [bit] NOT NULL,
 CONSTRAINT [PK_ActivitySpec] PRIMARY KEY CLUSTERED 
(
	[CompanyID] ASC,
	[ActivitySpecID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UC_ActivitySpecName] UNIQUE NONCLUSTERED 
(
	[CompanyID] ASC,
	[ActivitySpecName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([SysStartTimeUTC], [SysEndTimeUTC])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON ( HISTORY_TABLE = [history].[ActivitySpecHistory] )
)
GO
/****** Object:  Table [history].[ApplicationSettingsHistory]    Script Date: 8/20/2021 4:26:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [history].[ApplicationSettingsHistory](
	[CompanyID] [int] NOT NULL,
	[IsAnonymousMode] [bit] NOT NULL,
	[AnonymousModeDeptSizeLimit] [int] NOT NULL,
	[IsUnaccountedTimeEditable] [bit] NOT NULL,
	[CurrentTimestamp] [timestamp] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[SysStartTimeUTC] [datetime2](7) NOT NULL,
	[SysEndTimeUTC] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [org].[ApplicationSettings]    Script Date: 8/20/2021 4:26:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [org].[ApplicationSettings](
	[CompanyID] [int] NOT NULL,
	[IsAnonymousMode] [bit] NOT NULL,
	[AnonymousModeDeptSizeLimit] [int] NOT NULL,
	[IsUnaccountedTimeEditable] [bit] NOT NULL,
	[CurrentTimestamp] [timestamp] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[SysStartTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[SysEndTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
 CONSTRAINT [PK_ApplicationSettings] PRIMARY KEY CLUSTERED 
(
	[CompanyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([SysStartTimeUTC], [SysEndTimeUTC])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON ( HISTORY_TABLE = [history].[ApplicationSettingsHistory] )
)
GO
/****** Object:  Table [history].[AppSpecHistory]    Script Date: 8/20/2021 4:26:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [history].[AppSpecHistory](
	[CompanyID] [int] NOT NULL,
	[AppSpecID] [int] NOT NULL,
	[ActivitySpecID] [int] NULL,
	[AppExeName] [nvarchar](200) NOT NULL,
	[AppDisplayName] [nvarchar](200) NULL,
	[AppDescription] [nvarchar](512) NULL,
	[IsActive] [bit] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[SysStartTimeUTC] [datetime2](7) NOT NULL,
	[SysEndTimeUTC] [datetime2](7) NOT NULL,
	[MergePriority] [bit] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [org].[AppSpec]    Script Date: 8/20/2021 4:26:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [org].[AppSpec](
	[CompanyID] [int] NOT NULL,
	[AppSpecID] [int] IDENTITY(100,1) NOT NULL,
	[ActivitySpecID] [int] NULL,
	[AppExeName] [nvarchar](200) NOT NULL,
	[AppDisplayName] [nvarchar](200) NULL,
	[AppDescription] [nvarchar](512) NULL,
	[IsActive] [bit] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[SysStartTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[SysEndTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
	[MergePriority] [bit] NOT NULL,
 CONSTRAINT [PK_AppSpec] PRIMARY KEY CLUSTERED 
(
	[CompanyID] ASC,
	[AppSpecID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([SysStartTimeUTC], [SysEndTimeUTC])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON ( HISTORY_TABLE = [history].[AppSpecHistory] )
)
GO
/****** Object:  Table [history].[ReportCatalogExclusiveHistory]    Script Date: 8/20/2021 4:26:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [history].[ReportCatalogExclusiveHistory](
	[CompanyID] [int] NOT NULL,
	[ReportID] [int] NOT NULL,
	[IsAvailable] [bit] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[SysStartTimeUTC] [datetime2](7) NOT NULL,
	[SysEndTimeUTC] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [org].[ReportCatalogExclusive]    Script Date: 8/20/2021 4:26:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [org].[ReportCatalogExclusive](
	[CompanyID] [int] NOT NULL,
	[ReportID] [int] NOT NULL,
	[IsAvailable] [bit] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[SysStartTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[SysEndTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
 CONSTRAINT [PK_ReportCatalogExclusive] PRIMARY KEY CLUSTERED 
(
	[CompanyID] ASC,
	[ReportID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([SysStartTimeUTC], [SysEndTimeUTC])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON ( HISTORY_TABLE = [history].[ReportCatalogExclusiveHistory] )
)
GO
/****** Object:  Table [history].[AppSpecPlatformHistory]    Script Date: 8/20/2021 4:26:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [history].[AppSpecPlatformHistory](
	[CompanyID] [int] NOT NULL,
	[AppSpecPlatformID] [int] NOT NULL,
	[AppSpecID] [int] NOT NULL,
	[PlatformID] [int] NOT NULL,
	[AppVersion] [nvarchar](512) NOT NULL,
	[DisplayName] [nvarchar](200) NULL,
	[IsSystemDiscovered] [bit] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[SysStartTimeUTC] [datetime2](7) NOT NULL,
	[SysEndTimeUTC] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [org].[AppSpecPlatform]    Script Date: 8/20/2021 4:26:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [org].[AppSpecPlatform](
	[CompanyID] [int] NOT NULL,
	[AppSpecPlatformID] [int] IDENTITY(100,1) NOT NULL,
	[AppSpecID] [int] NOT NULL,
	[PlatformID] [int] NOT NULL,
	[AppVersion] [nvarchar](512) NOT NULL,
	[DisplayName] [nvarchar](200) NULL,
	[IsSystemDiscovered] [bit] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[SysStartTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[SysEndTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
 CONSTRAINT [PK_AppSpecPlatform] PRIMARY KEY CLUSTERED 
(
	[CompanyID] ASC,
	[AppSpecPlatformID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UC_AppSpecPlatform_Version] UNIQUE NONCLUSTERED 
(
	[CompanyID] ASC,
	[AppSpecID] ASC,
	[PlatformID] ASC,
	[AppVersion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([SysStartTimeUTC], [SysEndTimeUTC])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON ( HISTORY_TABLE = [history].[AppSpecPlatformHistory] )
)
GO
/****** Object:  Table [history].[DeviceHistory]    Script Date: 8/20/2021 4:26:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [history].[DeviceHistory](
	[CompanyID] [int] NOT NULL,
	[DeviceID] [int] NOT NULL,
	[DeviceName] [nvarchar](200) NOT NULL,
	[DeviceDetails] [nvarchar](200) NULL,
	[IsActive] [bit] NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[SysStartTimeUTC] [datetime2](7) NOT NULL,
	[SysEndTimeUTC] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [org].[Device]    Script Date: 8/20/2021 4:26:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [org].[Device](
	[CompanyID] [int] NOT NULL,
	[DeviceID] [int] IDENTITY(100,1) NOT NULL,
	[DeviceName] [nvarchar](200) NOT NULL,
	[DeviceDetails] [nvarchar](200) NULL,
	[IsActive] [bit] NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[SysStartTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[SysEndTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
 CONSTRAINT [PK_Device] PRIMARY KEY CLUSTERED 
(
	[CompanyID] ASC,
	[DeviceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UC_DeviceName] UNIQUE NONCLUSTERED 
(
	[CompanyID] ASC,
	[DeviceName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([SysStartTimeUTC], [SysEndTimeUTC])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON ( HISTORY_TABLE = [history].[DeviceHistory] )
)
GO
/****** Object:  Table [history].[UserDeviceHistory]    Script Date: 8/20/2021 4:26:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [history].[UserDeviceHistory](
	[CompanyID] [int] NOT NULL,
	[DeviceID] [int] NOT NULL,
	[UserID] [int] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[SysStartTimeUTC] [datetime2](7) NOT NULL,
	[SysEndTimeUTC] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [org].[UserDevice]    Script Date: 8/20/2021 4:26:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [org].[UserDevice](
	[CompanyID] [int] NOT NULL,
	[DeviceID] [int] NOT NULL,
	[UserID] [int] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[SysStartTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[SysEndTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
 CONSTRAINT [PK_UserDevice] PRIMARY KEY CLUSTERED 
(
	[CompanyID] ASC,
	[DeviceID] ASC,
	[UserID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([SysStartTimeUTC], [SysEndTimeUTC])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON ( HISTORY_TABLE = [history].[UserDeviceHistory] )
)
GO
/****** Object:  Table [history].[UsersHistory]    Script Date: 8/20/2021 4:26:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [history].[UsersHistory](
	[CompanyID] [int] NOT NULL,
	[UserID] [int] NOT NULL,
	[DepartmentID] [int] NULL,
	[UserActivityOverrideProfileID] [int] NULL,
	[JobFamilyActivityOverrideProfileID] [int] NULL,
	[LocationID] [int] NOT NULL,
	[VendorID] [int] NULL,
	[ExternalUserID] [nvarchar](100) NULL,
	[UserEmail] [nvarchar](255) NOT NULL,
	[FirstName] [nvarchar](100) NOT NULL,
	[LastName] [nvarchar](100) NOT NULL,
	[JobTitle] [nvarchar](100) NULL,
	[SisenseId] [nvarchar](100) NULL,
	[Auth0Id] [nvarchar](100) NULL,
	[IsFullTimeEmployee] [bit] NOT NULL,
	[IsActivityCollectionOn] [bit] NOT NULL,
	[WorkScheduleID] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[SysStartTimeUTC] [datetime2](7) NOT NULL,
	[SysEndTimeUTC] [datetime2](7) NOT NULL,
	[TeamID] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [org].[Users]    Script Date: 8/20/2021 4:26:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [org].[Users](
	[CompanyID] [int] NOT NULL,
	[UserID] [int] IDENTITY(100,1) NOT NULL,
	[DepartmentID] [int] NULL,
	[UserActivityOverrideProfileID] [int] NULL,
	[JobFamilyActivityOverrideProfileID] [int] NULL,
	[LocationID] [int] NOT NULL,
	[VendorID] [int] NULL,
	[ExternalUserID] [nvarchar](100) NULL,
	[UserEmail] [nvarchar](255) NOT NULL,
	[FirstName] [nvarchar](100) NOT NULL,
	[LastName] [nvarchar](100) NOT NULL,
	[JobTitle] [nvarchar](100) NULL,
	[SisenseId] [nvarchar](100) NULL,
	[Auth0Id] [nvarchar](100) NULL,
	[IsFullTimeEmployee] [bit] NOT NULL,
	[IsActivityCollectionOn] [bit] NOT NULL,
	[WorkScheduleID] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[SysStartTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[SysEndTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
	[TeamID] [int] NULL,
 CONSTRAINT [PK_Users] PRIMARY KEY CLUSTERED 
(
	[CompanyID] ASC,
	[UserID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [CK_UserEmail] UNIQUE NONCLUSTERED 
(
	[CompanyID] ASC,
	[UserEmail] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([SysStartTimeUTC], [SysEndTimeUTC])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON ( HISTORY_TABLE = [history].[UsersHistory] )
)
GO
/****** Object:  View [org].[View_UserDevice]    Script Date: 8/20/2021 4:26:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [org].[View_UserDevice]
    AS

select 
	ud.CompanyID, ud.UserID,
	u.FirstName, u.LastName,
	d.DeviceID, d.DeviceName,
	ud.ModifiedBy, ud.SysStartTimeUTC, ud.SysEndTimeUTC  
from [org].UserDevice ud
	left join [org].Users u on u.Companyid = ud.Companyid and u.UserId = ud.UserId
	left join [org].Device d on d.Companyid = ud.Companyid and d.DeviceId = ud.DeviceID

GO
/****** Object:  Table [history].[UserEmailHistory]    Script Date: 9/9/2021 5:03:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [history].[UserEmailHistory](
	[CompanyID] [int] NOT NULL,
	[UserID] [int] NOT NULL,
	[ID] [int] NOT NULL,
	[UserAdditionalEmail] [nvarchar](255) NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[SysStartTimeUTC] [datetime2](7) NOT NULL,
	[SysEndTimeUTC] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [org].[UserEmail]    Script Date: 9/9/2021 5:03:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [org].[UserEmail](
	[CompanyID] [int] NOT NULL,
	[UserID] [int] NOT NULL,
	[ID] [int] IDENTITY(100,1) NOT NULL,
	[UserAdditionalEmail] [nvarchar](255) NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[SysStartTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[SysEndTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
 CONSTRAINT [PK_UserEmail] PRIMARY KEY CLUSTERED 
(
	[CompanyID] ASC,
	[UserID] ASC,
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UC_UserAdditionalEmail] UNIQUE NONCLUSTERED 
(
	[CompanyID] ASC,
	[UserID] ASC,
	[UserAdditionalEmail] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([SysStartTimeUTC], [SysEndTimeUTC])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON ( HISTORY_TABLE = [history].[UserEmailHistory] )
)
GO
/****** Object:  View [org].[View_UserDeviceHistory]    Script Date: 9/9/2021 5:03:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [org].[View_UserDeviceHistory]
    AS 

select 
	ud.CompanyID, ud.UserID,
	u.FirstName, u.LastName,
	d.DeviceID, d.DeviceName,
	ud.ModifiedBy, ud.SysStartTimeUTC, ud.SysEndTimeUTC  
from [history].UserDeviceHistory ud
	left join [org].Users u on u.Companyid = ud.Companyid and u.UserId = ud.UserId
	left join [org].Device d on d.Companyid = ud.Companyid and d.DeviceId = ud.DeviceID


GO
/****** Object:  Table [history].[UserDomainHistory]    Script Date: 8/20/2021 4:26:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [history].[UserDomainHistory](
	[CompanyID] [int] NOT NULL,
	[UserDomainID] [int] NOT NULL,
	[UserID] [int] NOT NULL,
	[UserName] [nvarchar](128) NOT NULL,
	[DomainName] [nvarchar](128) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[SysStartTimeUTC] [datetime2](7) NOT NULL,
	[SysEndTimeUTC] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [org].[UserDomain]    Script Date: 8/20/2021 4:26:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [org].[UserDomain](
	[CompanyID] [int] NOT NULL,
	[UserDomainID] [int] IDENTITY(100,1) NOT NULL,
	[UserID] [int] NOT NULL,
	[UserName] [nvarchar](128) NOT NULL,
	[DomainName] [nvarchar](128) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[SysStartTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[SysEndTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
 CONSTRAINT [PK_UserDomain] PRIMARY KEY CLUSTERED 
(
	[CompanyID] ASC,
	[UserDomainID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UC_UserName_DomainName] UNIQUE NONCLUSTERED 
(
	[CompanyID] ASC,
	[UserName] ASC,
	[DomainName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([SysStartTimeUTC], [SysEndTimeUTC])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON ( HISTORY_TABLE = [history].[UserDomainHistory] )
)
GO
/****** Object:  View [org].[View_UserDomain]    Script Date: 8/20/2021 4:26:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [org].[View_UserDomain]
    AS 

select 
	ud.CompanyID, ud.UserID,
	u.FirstName, u.LastName,
	ud.UserDomainID, ud.UserName, ud.DomainName, ud.IsActive,
	ud.ModifiedBy, ud.SysStartTimeUTC, ud.SysEndTimeUTC  
from org.UserDomain	ud
	left join org.Users u on u.Companyid = ud.Companyid and u.UserId = ud.UserId

 

GO
/****** Object:  Table [history].[CompanyHistory]    Script Date: 8/20/2021 4:26:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [history].[CompanyHistory](
	[TenantID] [int] NOT NULL,
	[CompanyID] [int] NOT NULL,
	[CompanyName] [nvarchar](512) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[SysStartTimeUTC] [datetime2](7) NOT NULL,
	[SysEndTimeUTC] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [org].[Company]    Script Date: 8/20/2021 4:26:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [org].[Company](
	[TenantID] [int] NOT NULL,
	[CompanyID] [int] IDENTITY(1,1) NOT NULL,
	[CompanyName] [nvarchar](512) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[SysStartTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[SysEndTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
 CONSTRAINT [PK_Company] PRIMARY KEY CLUSTERED 
(
	[TenantID] ASC,
	[CompanyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UC_CompanyName] UNIQUE NONCLUSTERED 
(
	[CompanyID] ASC,
	[CompanyName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([SysStartTimeUTC], [SysEndTimeUTC])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON ( HISTORY_TABLE = [history].[CompanyHistory] )
)
GO
/****** Object:  View [org].[View_UserDomainHistory]    Script Date: 8/20/2021 4:26:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [org].[View_UserDomainHistory]
    AS 

select 
	ud.CompanyID, ud.UserID,
	u.FirstName, u.LastName,
	ud.UserDomainID, ud.UserName, ud.DomainName, ud.IsActive,
	ud.ModifiedBy, ud.SysStartTimeUTC, ud.SysEndTimeUTC
from [history].UserDomainHistory	ud
	left join [org].Users u on u.Companyid = ud.Companyid and u.UserId = ud.UserId

GO
/****** Object:  Table [history].[UserPermissionHistory]    Script Date: 8/20/2021 4:26:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [history].[UserPermissionHistory](
	[CompanyID] [int] NOT NULL,
	[Entity] [nvarchar](50) NOT NULL,
	[Permission] [nvarchar](50) NOT NULL,
	[UserID] [int] NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[SysStartTimeUTC] [datetime2](7) NOT NULL,
	[SysEndTimeUTC] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [org].[UserPermission]    Script Date: 8/20/2021 4:26:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [org].[UserPermission](
	[CompanyID] [int] NOT NULL,
	[Entity] [nvarchar](50) NOT NULL,
	[Permission] [nvarchar](50) NOT NULL,
	[UserID] [int] NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[SysStartTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[SysEndTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
 CONSTRAINT [PK_UserPermission] PRIMARY KEY CLUSTERED 
(
	[CompanyID] ASC,
	[Entity] ASC,
	[Permission] ASC,
	[UserID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([SysStartTimeUTC], [SysEndTimeUTC])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON ( HISTORY_TABLE = [history].[UserPermissionHistory] )
)
GO
/****** Object:  View [org].[View_UserPermission]    Script Date: 8/20/2021 4:26:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [org].[View_UserPermission]
   AS 

select 
	up.CompanyId, up.UserId,
	u.FirstName, u.LastName,
	up.Entity, up.Permission,
	up.ModifiedBy, up.SysStartTimeUTC, up.SysEndTimeUTC  
from org.userpermission	up
	left join org.Users u on u.Companyid = up.Companyid and u.UserId = up.UserId

 

GO
/****** Object:  View [org].[View_UserPermissionHistory]    Script Date: 8/20/2021 4:26:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [org].[View_UserPermissionHistory]
AS 

select
	up.CompanyID, up.UserID,
	u.FirstName, u.LastName,
	up.Entity, up.Permission,
	up.ModifiedBy, up.SysStartTimeUTC, up.SysEndTimeUTC
from history.UserPermissionHistory	up
	left join org.Users u on u.Companyid = up.Companyid and u.UserId = up.UserId

GO
/****** Object:  Table [history].[WebAppSpecHistory]    Script Date: 8/20/2021 4:26:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [history].[WebAppSpecHistory](
	[CompanyID] [int] NOT NULL,
	[WebAppSpecID] [int] NOT NULL,
	[WebAppName] [nvarchar](200) NOT NULL,
	[WebAppDisplayName] [nvarchar](200) NOT NULL,
	[WebAppUrl] [nvarchar](300) NOT NULL,
	[WebAppVersion] [nvarchar](50) NULL,
	[WebAppDescription] [nvarchar](512) NULL,
	[ActivitySpecID] [int] NULL,
	[UrlMatchStrategy] [int] NULL,
	[UrlMatchContent] [nvarchar](200) NULL,
	[IsSystemDiscovered] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[SysStartTimeUTC] [datetime2](7) NOT NULL,
	[SysEndTimeUTC] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [org].[WebAppSpec]    Script Date: 8/20/2021 4:26:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [org].[WebAppSpec](
	[CompanyID] [int] NOT NULL,
	[WebAppSpecID] [int] IDENTITY(100,1) NOT NULL,
	[WebAppName] [nvarchar](200) NOT NULL,
	[WebAppDisplayName] [nvarchar](200) NOT NULL,
	[WebAppUrl] [nvarchar](300) NOT NULL,
	[WebAppVersion] [nvarchar](50) NULL,
	[WebAppDescription] [nvarchar](512) NULL,
	[ActivitySpecID] [int] NULL,
	[UrlMatchStrategy] [int] NULL,
	[UrlMatchContent] [nvarchar](200) NULL,
	[IsSystemDiscovered] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[SysStartTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[SysEndTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
 CONSTRAINT [PK_WebAppSpec] PRIMARY KEY CLUSTERED 
(
	[CompanyID] ASC,
	[WebAppSpecID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [CK_Unique_WebAppURL] UNIQUE NONCLUSTERED 
(
	[CompanyID] ASC,
	[WebAppUrl] ASC,
	[UrlMatchStrategy] ASC,
	[UrlMatchContent] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([SysStartTimeUTC], [SysEndTimeUTC])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON ( HISTORY_TABLE = [history].[WebAppSpecHistory] )
)
GO
/****** Object:  View [org].[View_GetAppMappings]    Script Date: 8/20/2021 4:26:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE    VIEW [org].[View_GetAppMappings]
   AS 

 select w.CompanyID, w.WebAppSpecID as ID,w.WebAppUrl as ApplicationOrUrl,w.WebAppDisplayName as DisplayName,
	w.UrlMatchContent ,w.UrlMatchStrategy as UrlPattern,w.ActivitySpecID,
	 CASE WHEN  a.IsCore is null then Cast (0 as bit) else a.IsCore end as IsCore
	,
	 CASE WHEN  a.IsWorkCategory is null then Cast (0 as bit) else a.IsWorkCategory end as IsWorkCategory
	,
	a.ActivitySpecName as ActivityName,
	 Cast(1 as bit) as IsWebApp, cast(null as bit) as  RemoteAccess,
	 Case
	  When a.IsWorkCategory=0 or a.IsWorkCategory is null
	 then 'Private' 
	 else 'Work'
	 end  as Category,

	 Case 
	 When w.ActivitySpecID is not null
	 then 'Mapped'
	 else 'UnMapped' end as Status
	from org.WebAppSpec w

	
Left join org.ActivitySpec a on a.ActivitySpecID=w.ActivitySpecID and w.CompanyID=a.CompanyID
union all

select app.CompanyID, app.AppSpecID as ID,app.AppExeName as ApplicationOrUrl ,app.AppDisplayName as DisplayName ,
'' as UrlMatchContent,'' as UrlPattern,act.ActivitySpecID,
 CASE WHEN  act.IsCore is null then Cast (0 as bit) else act.IsCore end as IsWorkCategory
	,
	 CASE WHEN  act.IsWorkCategory is null then Cast (0 as bit) else act.IsWorkCategory end as IsWorkCategory
	,
act.ActivitySpecName  as ActivityName,
cast(0 as bit) as IsWebApp,app.MergePriority as RemoteAccess,
 Case
	  When act.IsWorkCategory=0 or act.IsWorkCategory is null
	 then 'Private' 
	 else 'Work'
	 end  as Category,

	 Case 
	 When app.ActivitySpecID is not null
	 then 'Mapped'
	 else 'UnMapped' end as Status
from org.AppSpec app
Left join org.ActivitySpec act on act.ActivitySpecID=app.ActivitySpecID and act.CompanyID=app.CompanyID

 

GO
/****** Object:  View [org].[View_ActivitySpecHistory]    Script Date: 8/20/2021 4:26:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [org].[View_ActivitySpecHistory]
    AS 
    
SELECT        a.CompanyID, a.ActivitySpecID, a.ActivitySpecName, a.ActivitySpecDescription, a.IsDefault, a.IsCore, a.IsSystemDefined, a.IsWorkCategory, a.ModifiedBy, a.SysStartTimeUTC, a.SysEndTimeUTC
FROM            org.ActivitySpec a
UNION
SELECT        ah.CompanyID, ah.ActivitySpecID, ah.ActivitySpecName, ah.ActivitySpecDescription, ah.IsDefault, ah.IsCore, ah.IsSystemDefined, ah.IsWorkCategory, ah.ModifiedBy, ah.SysStartTimeUTC, ah.SysEndTimeUTC
FROM          history. ActivitySpecHistory ah


GO
/****** Object:  Table [history].[DepartmentHistory]    Script Date: 8/20/2021 4:26:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [history].[DepartmentHistory](
	[CompanyID] [int] NOT NULL,
	[DepartmentID] [int] NOT NULL,
	[DepartmentCode] [nvarchar](20) NULL,
	[DepartmentName] [nvarchar](100) NOT NULL,
	[DepartmentDescription] [nvarchar](500) NULL,
	[DepartmentOwnerID] [int] NULL,
	[IsEmployeeActivityVisible] [bit] NULL,
	[IsActive] [bit] NOT NULL,
	[CurrentTimestamp] [timestamp] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[SysStartTimeUTC] [datetime2](7) NOT NULL,
	[SysEndTimeUTC] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [org].[Department]    Script Date: 8/20/2021 4:26:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [org].[Department](
	[CompanyID] [int] NOT NULL,
	[DepartmentID] [int] IDENTITY(100,1) NOT NULL,
	[DepartmentCode] [nvarchar](20) NULL,
	[DepartmentName] [nvarchar](100) NOT NULL,
	[DepartmentDescription] [nvarchar](500) NULL,
	[DepartmentOwnerID] [int] NULL,
	[IsEmployeeActivityVisible] [bit] NULL,
	[IsActive] [bit] NOT NULL,
	[CurrentTimestamp] [timestamp] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[SysStartTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[SysEndTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
 CONSTRAINT [PK_Department] PRIMARY KEY CLUSTERED 
(
	[CompanyID] ASC,
	[DepartmentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UC_DepartmentName] UNIQUE NONCLUSTERED 
(
	[CompanyID] ASC,
	[DepartmentName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([SysStartTimeUTC], [SysEndTimeUTC])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON ( HISTORY_TABLE = [history].[DepartmentHistory] )
)
GO
/****** Object:  View [org].[View_Department]    Script Date: 8/20/2021 4:26:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [org].[View_Department]
   
AS 

select d.CompanyID,
   d.DepartmentID, d.DepartmentName, d.DepartmentCode,d.IsEmployeeActivityVisible,
    d.DepartmentOwnerID as [OwnerID], 
   u.FirstName as [OwnerFirstName], 
   u.LastName as [OwnerLastName], 
   d.ModifiedBy, d.SysStartTimeUTC, d.SysEndTimeUTC   
from [org].Department d 
   left join [org].Users u on u.CompanyId = d.CompanyId and u.UserID = d.DepartmentOwnerID
 

GO
/****** Object:  View [org].[View_DepartmentHistory]    Script Date: 8/20/2021 4:26:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [org].[View_DepartmentHistory]
    AS 

select d.CompanyID,
   d.DepartmentID, d.DepartmentName, d.DepartmentCode,d.IsEmployeeActivityVisible,
    d.DepartmentOwnerID as [OwnerID], 
   u.FirstName as [OwnerFirstName], 
   u.LastName as [OwnerLastName], 
   d.ModifiedBy, d.SysStartTimeUTC, d.SysEndTimeUTC  
from [history].DepartmentHistory d 
   left join [org].Users u on u.CompanyId = d.CompanyId and u.UserID = d.DepartmentOwnerID

GO
/****** Object:  Table [history].[IntegrationProductCatalogHistory]    Script Date: 8/20/2021 4:26:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [history].[IntegrationProductCatalogHistory](
	[IntegrationProductId] [int] NOT NULL,
	[IntegrationProductName] [nvarchar](512) NOT NULL,
	[IntegrationProductDescription] [nvarchar](4000) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[SysStartTimeUTC] [datetime2](7) NOT NULL,
	[SysEndTimeUTC] [datetime2](7) NOT NULL,
	[IntegrationProductCode] [nvarchar](100) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [org].[IntegrationProductCatalog]    Script Date: 8/20/2021 4:26:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [org].[IntegrationProductCatalog](
	[IntegrationProductId] [int] IDENTITY(1,1) NOT NULL,
	[IntegrationProductName] [nvarchar](512) NOT NULL,
	[IntegrationProductDescription] [nvarchar](4000) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[SysStartTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[SysEndTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
	[IntegrationProductCode] [nvarchar](100) NULL,
 CONSTRAINT [PK_IntegrationProductCatalog] PRIMARY KEY CLUSTERED 
(
	[IntegrationProductId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UC_IntegrationProductCatalog_IntegrationProductCode] UNIQUE NONCLUSTERED 
(
	[IntegrationProductCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UC_IntegrationProductCatalog_IntegrationProductName] UNIQUE NONCLUSTERED 
(
	[IntegrationProductName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([SysStartTimeUTC], [SysEndTimeUTC])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON ( HISTORY_TABLE = [history].[IntegrationProductCatalogHistory] )
)
GO
/****** Object:  Table [history].[HolidayHistory]    Script Date: 8/20/2021 4:26:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [history].[HolidayHistory](
	[CompanyID] [int] NOT NULL,
	[HolidayID] [int] NOT NULL,
	[HolidayName] [nvarchar](100) NOT NULL,
	[HolidayDateFrom] [datetimeoffset](7) NOT NULL,
	[HolidayDateTo] [datetimeoffset](7) NULL,
	[IsActive] [bit] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[SysStartTimeUTC] [datetime2](7) NOT NULL,
	[SysEndTimeUTC] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [org].[Holiday]    Script Date: 8/20/2021 4:26:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [org].[Holiday](
	[CompanyID] [int] NOT NULL,
	[HolidayID] [int] IDENTITY(1,1) NOT NULL,
	[HolidayName] [nvarchar](100) NOT NULL,
	[HolidayDateFrom] [datetimeoffset](7) NOT NULL,
	[HolidayDateTo] [datetimeoffset](7) NULL,
	[IsActive] [bit] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[SysStartTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[SysEndTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
 CONSTRAINT [PK_Holiday] PRIMARY KEY CLUSTERED 
(
	[CompanyID] ASC,
	[HolidayID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UC_HolidayName] UNIQUE NONCLUSTERED 
(
	[CompanyID] ASC,
	[HolidayName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([SysStartTimeUTC], [SysEndTimeUTC])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON ( HISTORY_TABLE = [history].[HolidayHistory] )
)
GO
/****** Object:  Table [history].[ReportCatalogGeneralHistory]    Script Date: 8/20/2021 4:26:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [history].[ReportCatalogGeneralHistory](
	[ReportID] [int] NOT NULL,
	[ReportCode] [nvarchar](100) NOT NULL,
	[ExternalSourceId] [int] NOT NULL,
	[ExternalReportId] [nvarchar](255) NOT NULL,
	[ReportCategoryId] [int] NOT NULL,
	[ReportName] [nvarchar](255) NOT NULL,
	[ReportDescription] [nvarchar](1024) NOT NULL,
	[ReportPath] [nvarchar](255) NOT NULL,
	[ReportHelpContextId] [nvarchar](100) NULL,
	[Permission] [nvarchar](500) NOT NULL,
	[ReportOrderId] [int] NOT NULL,
	[AnalyticsArea] [int] NOT NULL,
	[IsSystemDefined] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[PublishedDate] [datetime] NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[SysStartTimeUTC] [datetime2](7) NOT NULL,
	[SysEndTimeUTC] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [org].[ReportCatalogGeneral]    Script Date: 8/20/2021 4:26:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [org].[ReportCatalogGeneral](
	[ReportID] [int] IDENTITY(1,1) NOT NULL,
	[ReportCode] [nvarchar](100) NOT NULL,
	[ExternalSourceId] [int] NOT NULL,
	[ExternalReportId] [nvarchar](255) NOT NULL,
	[ReportCategoryId] [int] NOT NULL,
	[ReportName] [nvarchar](255) NOT NULL,
	[ReportDescription] [nvarchar](1024) NOT NULL,
	[ReportPath] [nvarchar](255) NOT NULL,
	[ReportHelpContextId] [nvarchar](100) NULL,
	[Permission] [nvarchar](500) NOT NULL,
	[ReportOrderId] [int] NOT NULL,
	[AnalyticsArea] [int] NOT NULL,
	[IsSystemDefined] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[PublishedDate] [datetime] NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[SysStartTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[SysEndTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
 CONSTRAINT [PK_ReportCatalogGeneral] PRIMARY KEY CLUSTERED 
(
	[ReportID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UC_ReportCatalogGeneral_ExternalSourceId_ExternalReportId] UNIQUE NONCLUSTERED 
(
	[ExternalSourceId] ASC,
	[ExternalReportId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UC_ReportCatalogGeneral_ReportCode] UNIQUE NONCLUSTERED 
(
	[ReportCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([SysStartTimeUTC], [SysEndTimeUTC])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON ( HISTORY_TABLE = [history].[ReportCatalogGeneralHistory] )
)
GO
/****** Object:  Table [history].[TestFlywayHistory]    Script Date: 8/20/2021 4:26:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [history].[TestFlywayHistory](
	[TestID] [int] NOT NULL,
	[TestData] [nvarchar](100) NOT NULL,
	[TestValue] [int] NOT NULL,
	[SysStartTimeUTC] [datetime2](7) NOT NULL,
	[SysEndTimeUTC] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [org].[TestFlyway]    Script Date: 8/20/2021 4:26:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [org].[TestFlyway](
	[TestID] [int] IDENTITY(0,1) NOT NULL,
	[TestData] [nvarchar](100) NOT NULL,
	[TestValue] [int] NOT NULL,
	[SysStartTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[SysEndTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
 CONSTRAINT [PK_TestFlway] PRIMARY KEY CLUSTERED 
(
	[TestID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([SysStartTimeUTC], [SysEndTimeUTC])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON ( HISTORY_TABLE = [history].[TestFlywayHistory] )
)
GO
/****** Object:  Table [history].[HolidayLocationHistory]    Script Date: 8/20/2021 4:26:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [history].[HolidayLocationHistory](
	[CompanyID] [int] NOT NULL,
	[HolidayID] [int] NOT NULL,
	[LocationID] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[SysStartTimeUTC] [datetime2](7) NOT NULL,
	[SysEndTimeUTC] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [org].[HolidayLocation]    Script Date: 8/20/2021 4:26:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [org].[HolidayLocation](
	[CompanyID] [int] NOT NULL,
	[HolidayID] [int] NOT NULL,
	[LocationID] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[SysStartTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[SysEndTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
 CONSTRAINT [PK_HolidayLocation] PRIMARY KEY CLUSTERED 
(
	[CompanyID] ASC,
	[LocationID] ASC,
	[HolidayID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([SysStartTimeUTC], [SysEndTimeUTC])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON ( HISTORY_TABLE = [history].[HolidayLocationHistory] )
)
GO
/****** Object:  View [org].[View_TestFlyway]    Script Date: 8/20/2021 4:26:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [org].[View_TestFlyway]
AS 

	select s.*
	from TestFlyway s 
  

GO
/****** Object:  Table [history].[JobFamilyActivityOverrideProfileHistory]    Script Date: 8/20/2021 4:26:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [history].[JobFamilyActivityOverrideProfileHistory](
	[CompanyID] [int] NOT NULL,
	[JobFamilyActivityOverrideProfileID] [int] NOT NULL,
	[JobFamilyName] [nvarchar](100) NOT NULL,
	[JobGradeLevel] [nvarchar](50) NULL,
	[JobFamilyDescription] [nvarchar](200) NULL,
	[IsActive] [bit] NOT NULL,
	[CurrentTimestamp] [timestamp] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[SysStartTimeUTC] [datetime2](7) NOT NULL,
	[SysEndTimeUTC] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [org].[JobFamilyActivityOverrideProfile]    Script Date: 8/20/2021 4:26:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [org].[JobFamilyActivityOverrideProfile](
	[CompanyID] [int] NOT NULL,
	[JobFamilyActivityOverrideProfileID] [int] IDENTITY(1,1) NOT NULL,
	[JobFamilyName] [nvarchar](100) NOT NULL,
	[JobGradeLevel] [nvarchar](50) NULL,
	[JobFamilyDescription] [nvarchar](200) NULL,
	[IsActive] [bit] NOT NULL,
	[CurrentTimestamp] [timestamp] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[SysStartTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[SysEndTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
 CONSTRAINT [PK_JobFamilyActivityOverrideProfile] PRIMARY KEY CLUSTERED 
(
	[CompanyID] ASC,
	[JobFamilyActivityOverrideProfileID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UC_JobFamilyName] UNIQUE NONCLUSTERED 
(
	[CompanyID] ASC,
	[JobFamilyName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([SysStartTimeUTC], [SysEndTimeUTC])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON ( HISTORY_TABLE = [history].[JobFamilyActivityOverrideProfileHistory] )
)
GO
/****** Object:  View [org].[UserAuditLog]    Script Date: 8/20/2021 4:26:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [org].[UserAuditLog]
    AS SELECT * FROM [org].[Users]

GO
/****** Object:  View [org].[View_AppSpecHistory]    Script Date: 8/20/2021 4:26:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [org].[View_AppSpecHistory]
    AS

Select 
     app.CompanyID,
     app.AppSpecID,
     app.AppExeName,
	app.MergePriority,
     app.AppDisplayName,
     app.AppDescription,
     act.ActivitySpecID,
     act.ActivitySpecName,
     app.ModifiedBy, app.SysStartTimeUTC, app.SysEndTimeUTC
from [org].AppSpec app
   left join [org].ActivitySpec act on act.CompanyId = app.CompanyId and act.ActivitySpecId = app.ActivitySpecId
  
UNION

Select 
     apph.CompanyID,
     apph.AppSpecID,
     apph.AppExeName,
	apph.MergePriority,
     apph.AppDisplayName,
     apph.AppDescription,
     act.ActivitySpecID,
     act.ActivitySpecName,
     apph.ModifiedBy, apph.SysStartTimeUTC, apph.SysEndTimeUTC
from [history].AppSpecHistory apph
   left join [org].ActivitySpec act on act.CompanyId = apph.CompanyId and act.ActivitySpecId = apph.ActivitySpecId
GO
/****** Object:  Table [history].[JobFamilyActivitySpecHistory]    Script Date: 8/20/2021 4:26:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [history].[JobFamilyActivitySpecHistory](
	[CompanyID] [int] NOT NULL,
	[JobFamilyActivityOverrideProfileID] [int] NOT NULL,
	[ActivitySpecID] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[SysStartTimeUTC] [datetime2](7) NOT NULL,
	[SysEndTimeUTC] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [org].[JobFamilyActivitySpec]    Script Date: 8/20/2021 4:26:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [org].[JobFamilyActivitySpec](
	[CompanyID] [int] NOT NULL,
	[JobFamilyActivityOverrideProfileID] [int] IDENTITY(100,1) NOT NULL,
	[ActivitySpecID] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[SysStartTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[SysEndTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
 CONSTRAINT [PK_JobFamilyActivitySpec] PRIMARY KEY CLUSTERED 
(
	[CompanyID] ASC,
	[JobFamilyActivityOverrideProfileID] ASC,
	[ActivitySpecID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([SysStartTimeUTC], [SysEndTimeUTC])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON ( HISTORY_TABLE = [history].[JobFamilyActivitySpecHistory] )
)
GO
/****** Object:  View [org].[View_GetAdminUsers]    Script Date: 8/20/2021 4:26:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create   View [org].[View_GetAdminUsers]

AS
select distinct	up.CompanyId, up.UserID,u.FirstName, u.LastName,up.Entity   from org.Users u
left join org.userpermission up  on u.Companyid = up.Companyid and u.UserId = up.UserId
where up.Entity='Admin' 

union all

select distinct 	uph.CompanyID, uph.UserID,uh.FirstName, uh.LastName,uph.Entity from history.UsersHistory uh
left join history.UserPermissionHistory	uph on uh.Companyid = uph.Companyid and uh.UserId = uph.UserId
where uph.Entity='Admin' 

GO
/****** Object:  Table [history].[JobFamilyWebAppSpecOverrideHistory]    Script Date: 8/20/2021 4:26:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [history].[JobFamilyWebAppSpecOverrideHistory](
	[CompanyID] [int] NOT NULL,
	[WebAppSpecID] [int] NOT NULL,
	[JobFamilyActivityOverrideProfileID] [int] NOT NULL,
	[ActivitySpecID] [int] NOT NULL,
	[IsCore] [bit] NULL,
	[IsWorkCategory] [bit] NULL,
	[IsActive] [bit] NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[SysStartTimeUTC] [datetime2](7) NOT NULL,
	[SysEndTimeUTC] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [org].[JobFamilyWebAppSpecOverride]    Script Date: 8/20/2021 4:26:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [org].[JobFamilyWebAppSpecOverride](
	[CompanyID] [int] NOT NULL,
	[WebAppSpecID] [int] NOT NULL,
	[JobFamilyActivityOverrideProfileID] [int] NOT NULL,
	[ActivitySpecID] [int] NOT NULL,
	[IsCore] [bit] NULL,
	[IsWorkCategory] [bit] NULL,
	[IsActive] [bit] NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[SysStartTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[SysEndTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
 CONSTRAINT [PK_JobFamilyWebAppSpecOverride] PRIMARY KEY CLUSTERED 
(
	[CompanyID] ASC,
	[WebAppSpecID] ASC,
	[JobFamilyActivityOverrideProfileID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([SysStartTimeUTC], [SysEndTimeUTC])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON ( HISTORY_TABLE = [history].[JobFamilyWebAppSpecOverrideHistory] )
)
GO
/****** Object:  View [org].[View_JobFamilyAppSpecOverrideHistory]    Script Date: 8/20/2021 4:26:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [org].[View_JobFamilyAppSpecOverrideHistory]
AS   

select 
   o.CompanyId,
   o.IsCore,
   o.IsWorkCategory,
   o.JobFamilyActivityOverrideProfileID as [ProfileID],
   w.WebAppSpecID,
   w.WebAppName,
   w.WebAppDisplayName,
   p.JobFamilyName as [ProfileName],
   actO.ActivitySpecID as [ActivityID],
   actO.ActivitySpecName as [ActivitySpecName],
   actW.ActivitySpecID as [WebAppSpecActivityID],
   actW.ActivitySpecName as [WebAppSpecActivitySpecName],
   o.ModifiedBy, o.SysStartTimeUTC, o.SysEndTimeUTC

from [org].JobFamilyWebAppSpecOverride o
   left join  [org].ActivitySpec actW on actW.CompanyId = o.CompanyId and actW.ActivitySpecID = o.ActivitySpecID
   left join  [org].WebAppSpec w on w.CompanyId = o.CompanyId and w.WebAppSpecID = o.WebAppSpecID
   left join  [org].ActivitySpec actO on actO.CompanyId = w.CompanyId and actO.ActivitySpecID = w.ActivitySpecID
   left join  [org].JobFamilyActivityOverrideProfile p on p.CompanyId = o.CompanyId and p.JobFamilyActivityOverrideProfileID = o.JobFamilyActivityOverrideProfileID

   UNION 

   select 
   oh.CompanyId,
   oh.IsCore,
   oh.IsWorkCategory,
   oh.JobFamilyActivityOverrideProfileID as [ProfileID],
   w.WebAppSpecID,
   w.WebAppName,
   w.WebAppDisplayName,
   p.JobFamilyName as [ProfileName],
   actO.ActivitySpecID as [ActivityID],
   actO.ActivitySpecName as [ActivitySpecName],
   actW.ActivitySpecID as [WebAppSpecActivityID],
   actW.ActivitySpecName as [WebAppSpecActivitySpecName],
   oh.ModifiedBy, oh.SysStartTimeUTC, oh.SysEndTimeUTC

from [history].JobFamilyWebAppSpecOverrideHistory oh
   left join  [org].ActivitySpec actW on actW.CompanyId = oh.CompanyId and actW.ActivitySpecID = oh.ActivitySpecID
   left join  [org].WebAppSpec w on w.CompanyId = oh.CompanyId and w.WebAppSpecID = oh.WebAppSpecID
   left join  [org].ActivitySpec actO on actO.CompanyId = w.CompanyId and actO.ActivitySpecID = w.ActivitySpecID
   left join  [org].JobFamilyActivityOverrideProfile p on p.CompanyId = oh.CompanyId and p.JobFamilyActivityOverrideProfileID = oh.JobFamilyActivityOverrideProfileID

GO
/****** Object:  Table [history].[UserActivityOverrideProfileHistory]    Script Date: 8/20/2021 4:26:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [history].[UserActivityOverrideProfileHistory](
	[CompanyID] [int] NOT NULL,
	[UserActivityOverrideProfileID] [int] NOT NULL,
	[ProfileName] [nvarchar](100) NOT NULL,
	[ProfileDescription] [nvarchar](300) NULL,
	[IsActive] [bit] NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[SysStartTimeUTC] [datetime2](7) NOT NULL,
	[SysEndTimeUTC] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [org].[UserActivityOverrideProfile]    Script Date: 8/20/2021 4:26:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [org].[UserActivityOverrideProfile](
	[CompanyID] [int] NOT NULL,
	[UserActivityOverrideProfileID] [int] IDENTITY(100,1) NOT NULL,
	[ProfileName] [nvarchar](100) NOT NULL,
	[ProfileDescription] [nvarchar](300) NULL,
	[IsActive] [bit] NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[SysStartTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[SysEndTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
 CONSTRAINT [PK_UserActivityOverrideProfile] PRIMARY KEY CLUSTERED 
(
	[CompanyID] ASC,
	[UserActivityOverrideProfileID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UC_UserActivityOverrideProfileName] UNIQUE NONCLUSTERED 
(
	[CompanyID] ASC,
	[ProfileName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([SysStartTimeUTC], [SysEndTimeUTC])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON ( HISTORY_TABLE = [history].[UserActivityOverrideProfileHistory] )
)
GO
/****** Object:  View [org].[View_UserActivityOverrideProfileHistory]    Script Date: 8/20/2021 4:26:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [org].[View_UserActivityOverrideProfileHistory]
    AS 


Select 
    p.CompanyId,
    p.UserActivityOverrideProfileID,
    p.ProfileDescription,
    p.ModifiedBy, p.SysStartTimeUTC, p.SysEndTimeUTC
from [org].UserActivityOverrideProfile p
 

   UNION

Select 
    ph.CompanyId,
    ph.UserActivityOverrideProfileID,
    ph.ProfileDescription,
    ph.ModifiedBy, ph.SysStartTimeUTC, ph.SysEndTimeUTC
from [history].UserActivityOverrideProfileHistory ph
 




GO
/****** Object:  Table [history].[JobFamilyAppSpecOverrideHistory]    Script Date: 8/20/2021 4:26:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [history].[JobFamilyAppSpecOverrideHistory](
	[CompanyID] [int] NOT NULL,
	[AppSpecID] [int] NOT NULL,
	[JobFamilyActivityOverrideProfileID] [int] NOT NULL,
	[ActivitySpecID] [int] NOT NULL,
	[IsCore] [bit] NULL,
	[IsWorkCategory] [bit] NULL,
	[IsActive] [bit] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[SysStartTimeUTC] [datetime2](7) NOT NULL,
	[SysEndTimeUTC] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [org].[JobFamilyAppSpecOverride]    Script Date: 8/20/2021 4:26:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [org].[JobFamilyAppSpecOverride](
	[CompanyID] [int] NOT NULL,
	[AppSpecID] [int] NOT NULL,
	[JobFamilyActivityOverrideProfileID] [int] NOT NULL,
	[ActivitySpecID] [int] NOT NULL,
	[IsCore] [bit] NULL,
	[IsWorkCategory] [bit] NULL,
	[IsActive] [bit] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[SysStartTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[SysEndTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
 CONSTRAINT [PK_JobFamilyAppSpecOverride] PRIMARY KEY CLUSTERED 
(
	[CompanyID] ASC,
	[AppSpecID] ASC,
	[JobFamilyActivityOverrideProfileID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([SysStartTimeUTC], [SysEndTimeUTC])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON ( HISTORY_TABLE = [history].[JobFamilyAppSpecOverrideHistory] )
)
GO
/****** Object:  Table [history].[UserAppSpecOverrideHistory]    Script Date: 8/20/2021 4:26:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [history].[UserAppSpecOverrideHistory](
	[CompanyID] [int] NOT NULL,
	[AppSpecID] [int] NOT NULL,
	[UserActivityOverrideProfileID] [int] NOT NULL,
	[ActivitySpecID] [int] NOT NULL,
	[IsCore] [bit] NULL,
	[IsWorkCategory] [bit] NULL,
	[IsActive] [bit] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[SysStartTimeUTC] [datetime2](7) NOT NULL,
	[SysEndTimeUTC] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [org].[UserAppSpecOverride]    Script Date: 8/20/2021 4:26:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [org].[UserAppSpecOverride](
	[CompanyID] [int] NOT NULL,
	[AppSpecID] [int] NOT NULL,
	[UserActivityOverrideProfileID] [int] NOT NULL,
	[ActivitySpecID] [int] NOT NULL,
	[IsCore] [bit] NULL,
	[IsWorkCategory] [bit] NULL,
	[IsActive] [bit] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[SysStartTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[SysEndTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
 CONSTRAINT [PK_UserAppSpecOverride] PRIMARY KEY CLUSTERED 
(
	[CompanyID] ASC,
	[AppSpecID] ASC,
	[UserActivityOverrideProfileID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([SysStartTimeUTC], [SysEndTimeUTC])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON ( HISTORY_TABLE = [history].[UserAppSpecOverrideHistory] )
)
GO
/****** Object:  View [org].[View_UserAppSpecOverrideHistory]    Script Date: 8/20/2021 4:26:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [org].[View_UserAppSpecOverrideHistory]
    AS 

    
select 
   o.CompanyId,
   o.IsCore,
   o.IsWorkCategory,
   a.AppSpecID,
   a.AppExeName,
   a.AppDisplayName,
   p.UserActivityOverrideProfileID as [ProfileID],
   p.ProfileName,
   actO.ActivitySpecID as [ActivityID],
   actO.ActivitySpecName as [ActivitySpecName],
   actA.ActivitySpecID as [AppSpecActivityID],
   actA.ActivitySpecName as [AppSpecActivitySpecName],
   o.ModifiedBy, o.SysStartTimeUTC, o.SysEndTimeUTC

from [org].UserAppSpecOverride o
   left join [org]. ActivitySpec actA on actA.CompanyId = o.CompanyId and actA.ActivitySpecID = o.ActivitySpecID
   left join [org]. AppSpec a on a.CompanyId = o.CompanyId and a.AppSpecID = o.AppSpecID
   left join [org]. ActivitySpec actO on actO.CompanyId = a.CompanyId and actO.ActivitySpecID = a.ActivitySpecID
   left join [org]. UserActivityOverrideProfile p on p.CompanyId = o.CompanyId and p.UserActivityOverrideProfileID = o.UserActivityOverrideProfileID

   UNION 

select 
   oh.CompanyId,
   oh.IsCore,
   oh.IsWorkCategory,
   a.AppSpecID,
   a.AppExeName,
   a.AppDisplayName,
   p.UserActivityOverrideProfileID as [ProfileID],
   p.ProfileName,
   actO.ActivitySpecID as [ActivityID],
   actO.ActivitySpecName as [ActivitySpecName],
   actA.ActivitySpecID as [AppSpecActivityID],
   actA.ActivitySpecName as [AppSpecActivitySpecName],
   oh.ModifiedBy, oh.SysStartTimeUTC, oh.SysEndTimeUTC

from [history].UserAppSpecOverrideHistory oh
   left join [org].ActivitySpec actA on actA.CompanyId = oh.CompanyId and actA.ActivitySpecID = oh.ActivitySpecID
   left join [org].AppSpec a on a.CompanyId = oh.CompanyId and a.AppSpecID = oh.AppSpecID
   left join [org].ActivitySpec actO on actO.CompanyId = a.CompanyId and actO.ActivitySpecID = a.ActivitySpecID
   left join [org]. UserActivityOverrideProfile p on p.CompanyId = oh.CompanyId and p.UserActivityOverrideProfileID = oh.UserActivityOverrideProfileID



GO
/****** Object:  View [org].[View_UserChangeLog]    Script Date: 8/20/2021 4:26:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [org].[View_UserChangeLog] AS
WITH T AS (
    SELECT 
	       CompanyID, 
	       UserID,
           LAG(ExternalUserID) OVER (PARTITION BY UserID ORDER BY SysStartTimeUTC, SysEndTimeUTC) AS Prev_ExternalUserID, ExternalUserID,
           LAG(FirstName) OVER (PARTITION BY UserID ORDER BY SysStartTimeUTC, SysEndTimeUTC) AS Prev_FirstName, FirstName,
           LAG(LastName) OVER (PARTITION BY UserID ORDER BY SysStartTimeUTC, SysEndTimeUTC) AS Prev_LastName, LastName,
           LAG(UserEmail) OVER (PARTITION BY UserID ORDER BY SysStartTimeUTC, SysEndTimeUTC) AS Prev_Email, UserEmail,
           LAG(JobTitle) OVER (PARTITION BY UserID ORDER BY SysStartTimeUTC, SysEndTimeUTC) AS Prev_JobTitle, JobTitle,
           LAG(IsFullTimeEmployee) OVER (PARTITION BY UserID ORDER BY SysStartTimeUTC, SysEndTimeUTC) AS Prev_IsFullTimeEmployee, IsFullTimeEmployee,
           LAG(IsActivityCollectionOn) OVER (PARTITION BY UserID ORDER BY SysStartTimeUTC, SysEndTimeUTC) AS Prev_IsIsActivityCollectionOn, IsActivityCollectionOn,
           LAG(IsActive) OVER (PARTITION BY UserID ORDER BY SysStartTimeUTC, SysEndTimeUTC) AS Prev_IsIsActive, IsActive,
     --      LAG(DepartmentID) OVER (PARTITION BY UserID ORDER BY SysStartTimeUTC, SysEndTimeUTC) AS Prev_Dept, DepartmentID,
     --      LAG(ReportsToID) OVER (PARTITION BY UserID ORDER BY SysStartTimeUTC, SysEndTimeUTC) AS Prev_ReportsTo, ReportsToID,
     --      LAG(WorkScheduleID) OVER (PARTITION BY UserID ORDER BY SysStartTimeUTC, SysEndTimeUTC) AS Prev_WorkSchedule, WorkScheduleID,
     --      LAG(VendorID) OVER (PARTITION BY UserID ORDER BY SysStartTimeUTC, SysEndTimeUTC) AS Prev_Vendor, VendorID,
		   --LAG(UserActivityOverrideProfileID) OVER (PARTITION BY UserID ORDER BY SysStartTimeUTC, SysEndTimeUTC) AS Prev_UserActivityOverrideProfile, UserActivityOverrideProfileID,
		   --LAG(JobFamilyActivityOverrideProfileID) OVER (PARTITION BY UserID ORDER BY SysStartTimeUTC, SysEndTimeUTC) AS Prev_JobFamilyActivityOverrideProfile, JobFamilyActivityOverrideProfileID,
    --      DepartmentID,
		   ModifiedBy,
           SysStartTimeUTC,
           SysEndTimeUTC
    FROM org.Users FOR SYSTEM_TIME ALL
   	 
   -- WHERE CompanyID = 1 and UserId = 99
)
SELECT
       T.CompanyId,
       T.UserId,
       C.Property,
       C.PreviousValue,
       C.CurrentValue,
	   T.ModifiedBy,
	   T.SysStartTimeUTC as ModifiedOn
  --     T.SysEndTimeUTC 
FROM T
    CROSS APPLY
    (
        VALUES
		    ('ExternalUserID', T.ExternalUserID, T.Prev_ExternalUserID)
            ,('FirstName', T.FirstName, T.Prev_FirstName)
            ,('LastName', T.LastName, T.Prev_LastName)
		    ,('Email', T.UserEmail, T.Prev_Email)
		    ,('JobTitle', T.JobTitle, T.Prev_JobTitle)
		    ,('IsFullTimeEmployee', Cast(T.IsFullTimeEmployee as CHAR(1)), CAST(T.Prev_IsFullTimeEmployee as CHAR(1)))
		    ,('IsActivityCollectionOn', Cast(T.IsActivityCollectionOn as VARCHAR(1)), CAST(T.Prev_IsIsActivityCollectionOn as CHAR(1)))
		    ,('IsActive', Cast(T.IsActive as VARCHAR(1)), CAST(T.Prev_IsIsActive as CHAR(1)))
			--,('Dept', CAST(T.DepartmentID  AS VARCHAR(10)), CAST(T.Prev_Dept AS VARCHAR(10)))
			--,('WorkSchedule', CAST(T.WorkScheduleID  AS VARCHAR(10)), CAST(T.Prev_WorkSchedule AS VARCHAR(10)))
			--,('ReportsTo', CAST(T.ReportsToID  AS VARCHAR(10)), CAST(T.Prev_ReportsTo AS VARCHAR(10)))
			--,('Vendor', CAST(T.VendorID  AS VARCHAR(10)), CAST(T.Prev_Vendor AS VARCHAR(10)))
			--,('UserActivityOverrideProfile', CAST(T.UserActivityOverrideProfileID  AS VARCHAR(10)), CAST(T.Prev_UserActivityOverrideProfile AS VARCHAR(10)))
			--,('JobFamilyActivityOverrideProfile', CAST(T.JobFamilyActivityOverrideProfileID  AS VARCHAR(10)), CAST(T.Prev_JobFamilyActivityOverrideProfile AS VARCHAR(10)))
    ) AS C (Property, CurrentValue, PreviousValue)

WHERE EXISTS
(
    SELECT CurrentValue 
    EXCEPT 
    SELECT C.PreviousValue
)
GO
/****** Object:  Table [history].[IntegrationAppCatalogHistory]    Script Date: 8/20/2021 4:26:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [history].[IntegrationAppCatalogHistory](
	[IntegrationAppId] [int] NOT NULL,
	[IntegrationProductId] [int] NOT NULL,
	[IntegrationAppName] [nvarchar](512) NOT NULL,
	[IntegrationAppDescription] [nvarchar](4000) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[SysStartTimeUTC] [datetime2](7) NOT NULL,
	[SysEndTimeUTC] [datetime2](7) NOT NULL,
	[IntegrationAppCode] [nvarchar](100) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [org].[IntegrationAppCatalog]    Script Date: 8/20/2021 4:26:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [org].[IntegrationAppCatalog](
	[IntegrationAppId] [int] IDENTITY(1,1) NOT NULL,
	[IntegrationProductId] [int] NOT NULL,
	[IntegrationAppName] [nvarchar](512) NOT NULL,
	[IntegrationAppDescription] [nvarchar](4000) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[SysStartTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[SysEndTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
	[IntegrationAppCode] [nvarchar](100) NULL,
 CONSTRAINT [PK_IntegrationAppCatalog] PRIMARY KEY CLUSTERED 
(
	[IntegrationAppId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UC_IntegrationAppCatalog_IntegrationAppCode] UNIQUE NONCLUSTERED 
(
	[IntegrationAppCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UC_IntegrationAppCatalog_IntegrationAppName] UNIQUE NONCLUSTERED 
(
	[IntegrationAppName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([SysStartTimeUTC], [SysEndTimeUTC])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON ( HISTORY_TABLE = [history].[IntegrationAppCatalogHistory] )
)
GO
/****** Object:  Table [history].[LocationHistory]    Script Date: 8/20/2021 4:26:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [history].[LocationHistory](
	[CompanyID] [int] NOT NULL,
	[LocationID] [int] NOT NULL,
	[LocationName] [nvarchar](100) NOT NULL,
	[City] [nvarchar](100) NOT NULL,
	[Country] [nvarchar](100) NULL,
	[Statoid] [nvarchar](100) NULL,
	[LocationExtra] [nvarchar](200) NULL,
	[IsActive] [bit] NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[SysStartTimeUTC] [datetime2](7) NOT NULL,
	[SysEndTimeUTC] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [org].[Location]    Script Date: 8/20/2021 4:26:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [org].[Location](
	[CompanyID] [int] NOT NULL,
	[LocationID] [int] IDENTITY(100,1) NOT NULL,
	[LocationName] [nvarchar](100) NOT NULL,
	[City] [nvarchar](100) NOT NULL,
	[Country] [nvarchar](100) NULL,
	[Statoid] [nvarchar](100) NULL,
	[LocationExtra] [nvarchar](200) NULL,
	[IsActive] [bit] NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[SysStartTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[SysEndTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
 CONSTRAINT [PK_Location] PRIMARY KEY CLUSTERED 
(
	[CompanyID] ASC,
	[LocationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [CK_LocationName] UNIQUE NONCLUSTERED 
(
	[CompanyID] ASC,
	[LocationName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([SysStartTimeUTC], [SysEndTimeUTC])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON ( HISTORY_TABLE = [history].[LocationHistory] )
)
GO
/****** Object:  Table [history].[TeamHistory]    Script Date: 8/20/2021 4:26:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [history].[TeamHistory](
	[CompanyID] [int] NOT NULL,
	[TeamID] [int] NOT NULL,
	[ManagerID] [int] NULL,
	[TeamName] [nvarchar](200) NULL,
	[TeamDescription] [nvarchar](500) NULL,
	[IsEmployeeActivityVisible] [bit] NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[SysStartTimeUTC] [datetime2](7) NOT NULL,
	[SysEndTimeUTC] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [org].[Team]    Script Date: 8/20/2021 4:26:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [org].[Team](
	[CompanyID] [int] NOT NULL,
	[TeamID] [int] IDENTITY(100,1) NOT NULL,
	[ManagerID] [int] NULL,
	[TeamName] [nvarchar](200) NULL,
	[TeamDescription] [nvarchar](500) NULL,
	[IsEmployeeActivityVisible] [bit] NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[SysStartTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[SysEndTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
 CONSTRAINT [PK_Team] PRIMARY KEY CLUSTERED 
(
	[CompanyID] ASC,
	[TeamID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UC_TeamName] UNIQUE NONCLUSTERED 
(
	[CompanyID] ASC,
	[TeamName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([SysStartTimeUTC], [SysEndTimeUTC])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON ( HISTORY_TABLE = [history].[TeamHistory] )
)
GO
/****** Object:  Table [org].[UserProvisionState]    Script Date: 9/9/2021 5:04:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [org].[UserProvisionState](
	[CompanyID] [int] NOT NULL,
	[UserEmail] [nvarchar](200) NOT NULL,
	[ExternalSysID] [int] NOT NULL,
	[State] [int] NOT NULL,
	[ErrorMessage] [nvarchar](200) NULL,
	[ErrorStackTrace] [nvarchar](max) NULL,
	[ModifiedBy] [nvarchar](100) NULL,
	[ModifiedOn] [smalldatetime] NULL,
 CONSTRAINT [PK_UserProvisionState] PRIMARY KEY CLUSTERED 
(
	[CompanyID] ASC,
	[UserEmail] ASC,
	[ExternalSysID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  View [org].[View_UserProvision]    Script Date: 8/20/2021 4:26:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [org].[View_UserProvision] as
Select  usr.FirstName + ' ' + usr.LastName as 'Worker',
      usr.UserEmail,
      CASE WHEN usr.IsActivityCollectionOn = 1 THEN 'ON' ELSE 'OFF' END AS ActivityCollection,
      CASE WHEN usr.IsActive = 1 THEN 'Active' ELSE 'InActive' END AS IsActive,
usr.CompanyID,
usr.UserID,
Case When emp.UserID is not null then 'Enabled' else 'Disabled' end ActivityAccess,
Case When adm.UserID is not null then 'Yes' else 'No' end IsAdmin,
usr.SysStartTimeUTC as 'Date user was added',
usr.IsActivityCollectionOn,
usr.DepartmentID,
dept.DepartmentName,
usr.LocationID,
loc.LocationName,
team.TeamName,
team.ManagerID,
team.TeamID,
man.FirstName + ' ' + man.LastName as 'ManagerName',
CASE WHEN sis.SisenseState = 0 THEN 'InProcess' WHEN sis.SisenseState = 1 THEN 'Provisioned' WHEN sis.SisenseState = 2 THEN 'Updated' WHEN sis.SisenseState = 3 THEN 'Error' ELSE 'Unknown' END AS SisenseStatus,
CASE WHEN auth.Auth0State = 0 THEN 'InProcess' WHEN auth.Auth0State = 1 THEN 'Provisioned' WHEN auth.Auth0State = 2 THEN 'Updated' WHEN auth.Auth0State = 3 THEN 'Error' ELSE 'Unknown' END AS Auth0Status,
CASE WHEN can.CanopyState = 0 THEN 'InProcess' WHEN can.CanopyState = 1 THEN 'Provisioned' WHEN can.CanopyState = 2 THEN 'Updated' WHEN can.CanopyState = 3 THEN 'Error' ELSE 'Unknown' END AS CanopyStatus

From org.Users usr 
Left Outer JOIN org.Department dept
On (usr.CompanyID = dept.CompanyID and usr.DepartmentID = dept.DepartmentID)
Left Outer JOIN org.Location loc
On (usr.CompanyID = loc.CompanyID and usr.LocationID = loc.LocationID)
Left Outer JOIN org.Team team
On (usr.CompanyID = loc.CompanyID and usr.TeamID = team.TeamID)
Left Outer JOIN org.Users man
On (team.CompanyID = man.CompanyID and team.ManagerID = man.UserID)
Left outer join (Select Distinct CompanyID, UserID FROM org.UserPermission WHere Entity = 'Employees') emp
On (usr.CompanyID = emp.CompanyID and usr.UserID = emp.UserID)
Left outer join (Select Distinct CompanyID, UserID FROM org.UserPermission WHere Entity = 'Admin') adm
On (usr.CompanyID = adm.CompanyID and usr.UserID = adm.UserID)
Left outer join (select CompanyID, UserEmail, State as SisenseState from [org].[UserProvisionState] Where ExternalSysID = 1) sis
On (usr.CompanyID = sis.CompanyID and usr.UserEmail = sis.UserEmail)
Left outer join (select CompanyID, UserEmail, State as Auth0State from [org].[UserProvisionState] Where ExternalSysID = 0) auth
On (usr.CompanyID = auth.CompanyID and usr.UserEmail = auth.UserEmail)
Left outer join (select CompanyID, UserEmail, State as CanopyState from [org].[UserProvisionState] Where ExternalSysID = 2) can
On (usr.CompanyID = can.CompanyID and usr.UserEmail = can.UserEmail)
---Where usr.Useremail like '%milind.kadbane@sapience.net%'

GO
/****** Object:  Table [history].[UserWebAppSpecOverrideHistory]    Script Date: 8/20/2021 4:26:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [history].[UserWebAppSpecOverrideHistory](
	[CompanyID] [int] NOT NULL,
	[UserActivityOverrideProfileID] [int] NOT NULL,
	[WebAppSpecID] [int] NOT NULL,
	[ActivitySpecID] [int] NOT NULL,
	[IsCore] [bit] NULL,
	[IsWorkCategory] [bit] NULL,
	[IsActive] [bit] NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[SysStartTimeUTC] [datetime2](7) NOT NULL,
	[SysEndTimeUTC] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [org].[UserWebAppSpecOverride]    Script Date: 8/20/2021 4:26:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [org].[UserWebAppSpecOverride](
	[CompanyID] [int] NOT NULL,
	[UserActivityOverrideProfileID] [int] NOT NULL,
	[WebAppSpecID] [int] NOT NULL,
	[ActivitySpecID] [int] NOT NULL,
	[IsCore] [bit] NULL,
	[IsWorkCategory] [bit] NULL,
	[IsActive] [bit] NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[SysStartTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[SysEndTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
 CONSTRAINT [PK_UserWebAppSpecOverride] PRIMARY KEY CLUSTERED 
(
	[CompanyID] ASC,
	[WebAppSpecID] ASC,
	[UserActivityOverrideProfileID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([SysStartTimeUTC], [SysEndTimeUTC])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON ( HISTORY_TABLE = [history].[UserWebAppSpecOverrideHistory] )
)
GO
/****** Object:  View [org].[View_UserWebAppSpecOverrideHistory]    Script Date: 8/20/2021 4:26:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [org].[View_UserWebAppSpecOverrideHistory]
    AS

select 
   o.CompanyId,
   o.IsCore,
   o.IsWorkCategory,
   p.UserActivityOverrideProfileID as [ProfileID],
   p.ProfileName,
   actO.ActivitySpecID as [ActivityID],
   actO.ActivitySpecName as [ActivitySpecName],
   w.WebAppSpecID,
   w.WebAppName,
   w.WebAppDisplayName,
   actW.ActivitySpecID as [WebAppSpecActivityID],
   actW.ActivitySpecName as [WebAppSpecActivitySpecName],
   o.ModifiedBy, o.SysStartTimeUTC, o.SysEndTimeUTC

from [org].UserWebAppSpecOverride o
   left join [org].ActivitySpec actW on actW.CompanyId = o.CompanyId and actW.ActivitySpecID = o.ActivitySpecID
   left join [org].WebAppSpec w on w.CompanyId = o.CompanyId and w.WebAppSpecID = o.WebAppSpecID
   left join [org].ActivitySpec actO on actO.CompanyId = w.CompanyId and actO.ActivitySpecID = w.ActivitySpecID
   left join [org].UserActivityOverrideProfile p on p.CompanyId = o.CompanyId and p.UserActivityOverrideProfileID = o.UserActivityOverrideProfileID

   UNION 

   select 
   oh.CompanyId,
   oh.IsCore,
   oh.IsWorkCategory,
   p.UserActivityOverrideProfileID as [ProfileID],
   p.ProfileName,
   actO.ActivitySpecID as [ActivityID],
   actO.ActivitySpecName as [ActivitySpecName],
   w.WebAppSpecID,
   w.WebAppName,
   w.WebAppDisplayName,
   actW.ActivitySpecID as [WebAppSpecActivityID],
   actW.ActivitySpecName as [WebAppSpecActivitySpecName],
   oh.ModifiedBy, oh.SysStartTimeUTC, oh.SysEndTimeUTC

from [history].UserWebAppSpecOverrideHistory oh
   left join [org].ActivitySpec actW on actW.CompanyId = oh.CompanyId and actW.ActivitySpecID = oh.ActivitySpecID
   left join [org].WebAppSpec w on w.CompanyId = oh.CompanyId and w.WebAppSpecID = oh.WebAppSpecID
   left join [org].ActivitySpec actO on actO.CompanyId = w.CompanyId and actO.ActivitySpecID = w.ActivitySpecID
   left join [org].UserActivityOverrideProfile p on p.CompanyId = oh.CompanyId and p.UserActivityOverrideProfileID = oh.UserActivityOverrideProfileID

GO
/****** Object:  View [org].[View_WebAppSpecHistory]    Script Date: 8/20/2021 4:26:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [org].[View_WebAppSpecHistory]
 AS

Select 
     webapp.CompanyID,
     webapp.WebAppSpecID,
     webapp.WebAppName,
     webapp.WebAppDisplayName,
     webapp.WebAppUrl,
     webapp.WebAppDescription,
     webapp.UrlMatchStrategy,
     case 
        when webapp.UrlMatchStrategy = 1 then 'ExactMatch'
        when webapp.UrlMatchStrategy = 2 then 'StartsWith'
        when webapp.UrlMatchStrategy = 3 then 'Contains'
     end  as UrlMatchStrategyName,
     webapp.UrlMatchContent,
     webapp.IsSystemDiscovered,
     act.ActivitySpecID,
     act.ActivitySpecName,
     webapp.ModifiedBy, webapp.SysStartTimeUTC, webapp.SysEndTimeUTC
from [org].WebAppSpec webapp
   left join [org].ActivitySpec act on act.CompanyId = webapp.CompanyId and act.ActivitySpecId = webapp.ActivitySpecId
  
UNION

Select 
     webapph.CompanyID,
     webapph.WebAppSpecID,
     webapph.WebAppName,
     webapph.WebAppDisplayName,
     webapph.WebAppUrl,
     webapph.WebAppDescription,
     webapph.UrlMatchStrategy,
      case 
        when webapph.UrlMatchStrategy = 1 then 'ExactMatch'
        when webapph.UrlMatchStrategy = 2 then 'StartsWith'
        when webapph.UrlMatchStrategy = 3 then 'Contains'
     end  as UrlMatchStrategyName,
     webapph.UrlMatchContent,
     webapph.IsSystemDiscovered,
     act.ActivitySpecID,
     act.ActivitySpecName,
     webapph.ModifiedBy, webapph.SysStartTimeUTC, webapph.SysEndTimeUTC
from [history].WebAppSpecHistory webapph
   left join [org].ActivitySpec act on act.CompanyId = webapph.CompanyId and act.ActivitySpecId = webapph.ActivitySpecId
GO
/****** Object:  View [org].[ViewJobFamilyAppSpecOverrideHistory]    Script Date: 8/20/2021 4:26:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [org].[ViewJobFamilyAppSpecOverrideHistory]
    AS 

select 
   o.CompanyId,
   o.IsCore,
   o.IsWorkCategory,
   o.JobFamilyActivityOverrideProfileID as [ProfileID],
   a.AppSpecID,
   a.AppExeName,
   a.AppDisplayName,
   p.JobFamilyName as [ProfileName],   
   actO.ActivitySpecID as [ActivityID],
   actO.ActivitySpecName as [ActivitySpecName],
   actA.ActivitySpecID as [AppSpecActivityID],
   actA.ActivitySpecName as [AppSpecActivitySpecName],
   o.ModifiedBy, o.SysStartTimeUTC, o.SysEndTimeUTC

from [org].JobFamilyAppSpecOverride o
   left join [org].ActivitySpec actA on actA.CompanyId = o.CompanyId and actA.ActivitySpecID = o.ActivitySpecID
   left join [org].AppSpec a on a.CompanyId = o.CompanyId and a.AppSpecID = o.AppSpecID
   left join [org].ActivitySpec actO on actO.CompanyId = a.CompanyId and actO.ActivitySpecID = a.ActivitySpecID
   left join [org].JobFamilyActivityOverrideProfile p on p.CompanyId = o.CompanyId and p.JobFamilyActivityOverrideProfileID = o.JobFamilyActivityOverrideProfileID

   UNION 

select 
   oh.CompanyId,
   oh.IsCore,
   oh.IsWorkCategory,
   oh.JobFamilyActivityOverrideProfileID as [ProfileID],
   a.AppSpecID,
   a.AppExeName,
   a.AppDisplayName,
   p.JobFamilyName as [ProfileName],
   actO.ActivitySpecID as [ActivityID],
   actO.ActivitySpecName as [ActivitySpecName],
   actA.ActivitySpecID as [AppSpecActivityID],
   actA.ActivitySpecName as [AppSpecActivitySpecName],
   oh.ModifiedBy, oh.SysStartTimeUTC, oh.SysEndTimeUTC

from [history].JobFamilyAppSpecOverrideHistory oh
   left join [org].ActivitySpec actA on actA.CompanyId = oh.CompanyId and actA.ActivitySpecID = oh.ActivitySpecID
   left join [org].AppSpec a on a.CompanyId = oh.CompanyId and a.AppSpecID = oh.AppSpecID
   left join [org].ActivitySpec actO on actO.CompanyId = a.CompanyId and actO.ActivitySpecID = a.ActivitySpecID
   left join [org].JobFamilyActivityOverrideProfile p on p.CompanyId = oh.CompanyId and p.JobFamilyActivityOverrideProfileID = oh.JobFamilyActivityOverrideProfileID




GO
/****** Object:  Table [history].[ReportUserFavoritesHistory]    Script Date: 8/20/2021 4:26:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [history].[ReportUserFavoritesHistory](
	[CompanyID] [int] NOT NULL,
	[UserID] [int] NOT NULL,
	[ReportId] [int] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[SysStartTimeUTC] [datetime2](7) NOT NULL,
	[SysEndTimeUTC] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [org].[ReportUserFavorites]    Script Date: 8/20/2021 4:26:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [org].[ReportUserFavorites](
	[CompanyID] [int] NOT NULL,
	[UserID] [int] NOT NULL,
	[ReportId] [int] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[SysStartTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[SysEndTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
 CONSTRAINT [PK_ReportUserFavorites] PRIMARY KEY CLUSTERED 
(
	[CompanyID] ASC,
	[UserID] ASC,
	[ReportId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([SysStartTimeUTC], [SysEndTimeUTC])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON ( HISTORY_TABLE = [history].[ReportUserFavoritesHistory] )
)
GO
/****** Object:  Table [history].[IntegrationCompanyProvisionHistory]    Script Date: 8/20/2021 4:26:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [history].[IntegrationCompanyProvisionHistory](
	[CompanyId] [int] NOT NULL,
	[IsActive] [bit] NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[SysStartTimeUTC] [datetime2](7) NOT NULL,
	[SysEndTimeUTC] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [org].[IntegrationCompanyProvision]    Script Date: 8/20/2021 4:26:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [org].[IntegrationCompanyProvision](
	[CompanyId] [int] NOT NULL,
	[IsActive] [bit] NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[SysStartTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[SysEndTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
 CONSTRAINT [PK_IntegrationCompanyProvision] PRIMARY KEY CLUSTERED 
(
	[CompanyId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([SysStartTimeUTC], [SysEndTimeUTC])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON ( HISTORY_TABLE = [history].[IntegrationCompanyProvisionHistory] )
)
GO
/****** Object:  Table [history].[PermissionHistory]    Script Date: 8/20/2021 4:26:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [history].[PermissionHistory](
	[Entity] [nvarchar](50) NOT NULL,
	[Permission] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](100) NULL,
	[IsActive] [bit] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[SysStartTimeUTC] [datetime2](7) NOT NULL,
	[SysEndTimeUTC] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [org].[Permission]    Script Date: 8/20/2021 4:26:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [org].[Permission](
	[Entity] [nvarchar](50) NOT NULL,
	[Permission] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](100) NULL,
	[IsActive] [bit] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[SysStartTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[SysEndTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
 CONSTRAINT [PK_Permission] PRIMARY KEY CLUSTERED 
(
	[Entity] ASC,
	[Permission] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([SysStartTimeUTC], [SysEndTimeUTC])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON ( HISTORY_TABLE = [history].[PermissionHistory] )
)
GO
/****** Object:  Table [history].[PlatformHistory]    Script Date: 8/20/2021 4:26:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [history].[PlatformHistory](
	[CompanyID] [int] NOT NULL,
	[PlatformID] [int] NOT NULL,
	[PlatformName] [nvarchar](255) NOT NULL,
	[PlatformVersion] [nvarchar](100) NULL,
	[PlatformDescription] [nvarchar](512) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[SysStartTimeUTC] [datetime2](7) NOT NULL,
	[SysEndTimeUTC] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [org].[Platform]    Script Date: 8/20/2021 4:27:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [org].[Platform](
	[CompanyID] [int] NOT NULL,
	[PlatformID] [int] IDENTITY(1,1) NOT NULL,
	[PlatformName] [nvarchar](255) NOT NULL,
	[PlatformVersion] [nvarchar](100) NULL,
	[PlatformDescription] [nvarchar](512) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[SysStartTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[SysEndTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
 CONSTRAINT [PK_PlatformType] PRIMARY KEY CLUSTERED 
(
	[CompanyID] ASC,
	[PlatformID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [CK_PlatformNameVersion] UNIQUE NONCLUSTERED 
(
	[CompanyID] ASC,
	[PlatformName] ASC,
	[PlatformVersion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([SysStartTimeUTC], [SysEndTimeUTC])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON ( HISTORY_TABLE = [history].[PlatformHistory] )
)
GO
/****** Object:  Table [history].[IntegrationProductProvisionHistory]    Script Date: 8/20/2021 4:27:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [history].[IntegrationProductProvisionHistory](
	[CompanyId] [int] NOT NULL,
	[IntegrationProductId] [int] NOT NULL,
	[IsActive] [bit] NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[SysStartTimeUTC] [datetime2](7) NOT NULL,
	[SysEndTimeUTC] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [org].[IntegrationProductProvision]    Script Date: 8/20/2021 4:27:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [org].[IntegrationProductProvision](
	[CompanyId] [int] NOT NULL,
	[IntegrationProductId] [int] NOT NULL,
	[IsActive] [bit] NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[SysStartTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[SysEndTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
 CONSTRAINT [PK_IntegrationProductProvision] PRIMARY KEY CLUSTERED 
(
	[CompanyId] ASC,
	[IntegrationProductId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([SysStartTimeUTC], [SysEndTimeUTC])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON ( HISTORY_TABLE = [history].[IntegrationProductProvisionHistory] )
)
GO
/****** Object:  Table [history].[ReportCategoryHistory]    Script Date: 8/20/2021 4:27:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [history].[ReportCategoryHistory](
	[ReportCategoryID] [int] NOT NULL,
	[ReportCategoryName] [nvarchar](255) NOT NULL,
	[ReportCategoryDescription] [nvarchar](1024) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[SysStartTimeUTC] [datetime2](7) NOT NULL,
	[SysEndTimeUTC] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [org].[ReportCategory]    Script Date: 8/20/2021 4:27:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [org].[ReportCategory](
	[ReportCategoryID] [int] IDENTITY(1,1) NOT NULL,
	[ReportCategoryName] [nvarchar](255) NOT NULL,
	[ReportCategoryDescription] [nvarchar](1024) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[SysStartTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[SysEndTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
 CONSTRAINT [PK_ReportCategory] PRIMARY KEY CLUSTERED 
(
	[ReportCategoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UC_ReportCategory_ReportCategoryName] UNIQUE NONCLUSTERED 
(
	[ReportCategoryName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([SysStartTimeUTC], [SysEndTimeUTC])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON ( HISTORY_TABLE = [history].[ReportCategoryHistory] )
)
GO
/****** Object:  View [org].[View_UserTree]    Script Date: 8/20/2021 4:27:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [org].[View_UserTree] 
AS

WITH UserList
AS (
	SELECT k.CompanyID
		,k1.UserID Parent
		,k1.FirstName + ' ' + k1.LastName ParentName
		,k.UserID Child
		,k.FirstName + ' ' + k.LastName ChildName
		,'' DepartmentIds
	FROM (
		SELECT U.CompanyID
			,U.UserID
			,U.UserEmail
			,U.FirstName
			,U.LastName
			,T.ManagerID
			,T.TeamName
		FROM org.Users U
		JOIN org.Team T ON (U.TeamId = T.TeamID)
		WHERE U.IsActive = 1
			AND U.TeamID IS NOT NULL
		) k
	INNER JOIN org.Users k1 ON k.CompanyID = k1.CompanyID
		AND k.ManagerID = k1.UserID
		AND k1.IsActive = 1
	)
	,UserHierarchy
AS (
	SELECT s.CompanyID
		,Parent UserID
		,ParentName
		,Child JoinUserID
		,ChildName
		,1 AS TreeLevel
	FROM UserList s
	WHERE s.Parent <> s.Child	
	UNION ALL	
	SELECT d.CompanyID
		,d.UserID
		,s.ParentName
		,s.Child
		,s.ChildName
		,d.TreeLevel + 1
	FROM UserHierarchy AS d
	INNER JOIN UserList s ON d.CompanyID = s.CompanyID
		AND d.JoinUserID = s.Parent
	WHERE s.Parent <> s.Child
	)

SELECT *
FROM UserHierarchy


GO
/****** Object:  Table [history].[TenantHistory]    Script Date: 8/20/2021 4:27:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [history].[TenantHistory](
	[TenantID] [int] NOT NULL,
	[TenantName] [nvarchar](255) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[SysStartTimeUTC] [datetime2](7) NOT NULL,
	[SysEndTimeUTC] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [org].[Tenant]    Script Date: 8/20/2021 4:27:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [org].[Tenant](
	[TenantID] [int] IDENTITY(1,1) NOT NULL,
	[TenantName] [nvarchar](255) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[SysStartTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[SysEndTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
 CONSTRAINT [PK_Tenant] PRIMARY KEY CLUSTERED 
(
	[TenantID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([SysStartTimeUTC], [SysEndTimeUTC])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON ( HISTORY_TABLE = [history].[TenantHistory] )
)
GO
/****** Object:  Table [history].[IntegrationAppProvisionHistory]    Script Date: 8/20/2021 4:27:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [history].[IntegrationAppProvisionHistory](
	[CompanyId] [int] NOT NULL,
	[IntegrationAppId] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[SysStartTimeUTC] [datetime2](7) NOT NULL,
	[SysEndTimeUTC] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [org].[IntegrationAppProvision]    Script Date: 8/20/2021 4:27:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [org].[IntegrationAppProvision](
	[CompanyId] [int] NOT NULL,
	[IntegrationAppId] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[SysStartTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[SysEndTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
 CONSTRAINT [PK_IntegrationAppProvision] PRIMARY KEY CLUSTERED 
(
	[CompanyId] ASC,
	[IntegrationAppId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([SysStartTimeUTC], [SysEndTimeUTC])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON ( HISTORY_TABLE = [history].[IntegrationAppProvisionHistory] )
)
GO
/****** Object:  Table [history].[CustomFieldHistory]    Script Date: 8/20/2021 4:27:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [history].[CustomFieldHistory](
	[CustomFieldID] [int] NOT NULL,
	[CompanyID] [int] NOT NULL,
	[EntityID] [int] NOT NULL,
	[DataTypeID] [tinyint] NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[Description] [nvarchar](300) NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[IsNullable] [bit] NOT NULL,
	[SysStartTimeUTC] [datetime2](7) NOT NULL,
	[SysEndTimeUTC] [datetime2](7) NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [org].[CustomField]    Script Date: 8/20/2021 4:27:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [org].[CustomField](
	[CustomFieldID] [int] IDENTITY(1,1) NOT NULL,
	[CompanyID] [int] NOT NULL,
	[EntityID] [int] NOT NULL,
	[DataTypeID] [tinyint] NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[Description] [nvarchar](300) NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[IsNullable] [bit] NOT NULL,
	[SysStartTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[SysEndTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
 CONSTRAINT [PK_CustomFieldID] PRIMARY KEY CLUSTERED 
(
	[CustomFieldID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([SysStartTimeUTC], [SysEndTimeUTC])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON ( HISTORY_TABLE = [history].[CustomFieldHistory] )
)
GO
/****** Object:  Table [history].[SettingsCategoryHistory]    Script Date: 8/20/2021 4:27:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [history].[SettingsCategoryHistory](
	[CategoryID] [int] NOT NULL,
	[CategoryName] [nvarchar](4000) NOT NULL,
	[CategoryDescription] [nvarchar](4000) NOT NULL,
	[IsVisible] [bit] NOT NULL,
	[IsReadOnly] [bit] NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[SysStartTimeUTC] [datetime2](7) NOT NULL,
	[SysEndTimeUTC] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [org].[SettingsCategory]    Script Date: 8/20/2021 4:27:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [org].[SettingsCategory](
	[CategoryID] [int] IDENTITY(1,1) NOT NULL,
	[CategoryName] [nvarchar](4000) NOT NULL,
	[CategoryDescription] [nvarchar](4000) NOT NULL,
	[IsVisible] [bit] NOT NULL,
	[IsReadOnly] [bit] NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[SysStartTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[SysEndTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
 CONSTRAINT [PK_SettingsCategory] PRIMARY KEY CLUSTERED 
(
	[CategoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UC_SettingsCategory] UNIQUE NONCLUSTERED 
(
	[CategoryName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([SysStartTimeUTC], [SysEndTimeUTC])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON ( HISTORY_TABLE = [history].[SettingsCategoryHistory] )
)
GO
/****** Object:  Table [history].[VendorHistory]    Script Date: 8/20/2021 4:27:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [history].[VendorHistory](
	[CompanyID] [int] NOT NULL,
	[VendorID] [int] NOT NULL,
	[VendorName] [nvarchar](100) NOT NULL,
	[VendorContact] [nvarchar](100) NULL,
	[IsActive] [bit] NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[SysStartTimeUTC] [datetime2](7) NOT NULL,
	[SysEndTimeUTC] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [org].[Vendor]    Script Date: 8/20/2021 4:27:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [org].[Vendor](
	[CompanyID] [int] NOT NULL,
	[VendorID] [int] IDENTITY(100,1) NOT NULL,
	[VendorName] [nvarchar](100) NOT NULL,
	[VendorContact] [nvarchar](100) NULL,
	[IsActive] [bit] NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[SysStartTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[SysEndTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
 CONSTRAINT [PK_Vendor] PRIMARY KEY CLUSTERED 
(
	[CompanyID] ASC,
	[VendorID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [CK_VendorName] UNIQUE NONCLUSTERED 
(
	[CompanyID] ASC,
	[VendorName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([SysStartTimeUTC], [SysEndTimeUTC])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON ( HISTORY_TABLE = [history].[VendorHistory] )
)
GO
/****** Object:  Table [history].[WorkScheduleHistory]    Script Date: 8/20/2021 4:27:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [history].[WorkScheduleHistory](
	[CompanyID] [int] NOT NULL,
	[WorkScheduleID] [int] NOT NULL,
	[WorkScheduleName] [nvarchar](100) NOT NULL,
	[WorkScheduleDescription] [nvarchar](300) NULL,
	[IsDefault] [bit] NOT NULL,
	[WorkWeekTotalHours] [float] NOT NULL,
	[IsWorkWeekCustom] [bit] NOT NULL,
	[StartDay] [int] NULL,
	[IsMonWorkDay] [bit] NULL,
	[IsTuesWorkDay] [bit] NULL,
	[IsWedWorkDay] [bit] NULL,
	[IsThuWorkDay] [bit] NULL,
	[IsFriWorkDay] [bit] NULL,
	[IsSatWorkDay] [bit] NULL,
	[IsSunWorkDay] [bit] NULL,
	[ReportDataStartTime] [time](7) NULL,
	[ReportDataEndTime] [time](7) NULL,
	[ReportNonWorkDayActivityAsWork] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[SysStartTimeUTC] [datetime2](7) NOT NULL,
	[SysEndTimeUTC] [datetime2](7) NOT NULL,
	[Capacity] [float] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [org].[WorkSchedule]    Script Date: 8/20/2021 4:27:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [org].[WorkSchedule](
	[CompanyID] [int] NOT NULL,
	[WorkScheduleID] [int] IDENTITY(100,1) NOT NULL,
	[WorkScheduleName] [nvarchar](100) NOT NULL,
	[WorkScheduleDescription] [nvarchar](300) NULL,
	[IsDefault] [bit] NOT NULL,
	[WorkWeekTotalHours] [float] NOT NULL,
	[IsWorkWeekCustom] [bit] NOT NULL,
	[StartDay] [int] NULL,
	[IsMonWorkDay] [bit] NULL,
	[IsTuesWorkDay] [bit] NULL,
	[IsWedWorkDay] [bit] NULL,
	[IsThuWorkDay] [bit] NULL,
	[IsFriWorkDay] [bit] NULL,
	[IsSatWorkDay] [bit] NULL,
	[IsSunWorkDay] [bit] NULL,
	[ReportDataStartTime] [time](7) NULL,
	[ReportDataEndTime] [time](7) NULL,
	[ReportNonWorkDayActivityAsWork] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[SysStartTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[SysEndTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
	[Capacity] [float] NULL,
 CONSTRAINT [PK_WorkSchedule] PRIMARY KEY CLUSTERED 
(
	[CompanyID] ASC,
	[WorkScheduleID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UC_WorkScheduleName] UNIQUE NONCLUSTERED 
(
	[CompanyID] ASC,
	[WorkScheduleName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([SysStartTimeUTC], [SysEndTimeUTC])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON ( HISTORY_TABLE = [history].[WorkScheduleHistory] )
)
GO
/****** Object:  View [org].[View_GetUser]    Script Date: 8/20/2021 4:27:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [org].[View_GetUser]
AS 
select u.CompanyID,
       u.UserID, u.FirstName,  u.LastName, u.UserEmail, u.ExternalUserID, u.JobTitle, 
       (u.FirstName + ' ' + u.LastName) as [UserFullName],
       u.IsActivityCollectionOn, u.IsFullTimeEmployee, u.IsActive,
       u.SisenseId, 
       d.DepartmentID, d.DepartmentName, 
	   loc.LocationID, loc.LocationName,
       t.TeamID, t.TeamName,
       mgr.UserID as ManagerUserID, 
       (mgr.FirstName + ' ' + mgr.LastName) as ManagerName,
       jao.JobFamilyActivityOverrideProfileID, jao.JobFamilyName as JobFamilyActivityOverrideProfileName,
	   uao.UserActivityOverrideProfileID, uao.ProfileName as UserActivityOverrideProfileName,
	   v.VendorID, v.VendorName,
	   w.WorkScheduleID, w.WorkScheduleName,
       u.ModifiedBy, u.SysStartTimeUTC, u.SysEndTimeUTC  
from [org].Users u 
   left join  [org].Department d on d.CompanyId = u.CompanyId and d.DepartmentId = u.DepartmentId
   left join  [org].Team t on t.CompanyId = u.CompanyId and t.TeamID = u.TeamID
   left join  [org].Users mgr on mgr.CompanyId = u.CompanyId and mgr.UserID = t.ManagerID
   left join  [org].UserActivityOverrideProfile uao on uao.CompanyId = u.CompanyId and uao.UserActivityOverrideProfileID = u.UserActivityOverrideProfileID
   left join  [org].JobFamilyActivityOverrideProfile jao on jao.CompanyId = u.CompanyId and jao.JobFamilyActivityOverrideProfileID = u.JobFamilyActivityOverrideProfileID
   left join  [org].WorkSchedule w on w.CompanyId = u.CompanyId and w.WorkScheduleID = u.WorkScheduleID
   left join  [org].Vendor v on v.CompanyId = u.CompanyId and v.VendorID = u.VendorID
   left join  [org].[Location] loc on loc.CompanyId = u.CompanyId and loc.LocationID = u.LocationID
   

GO
/****** Object:  View [org].[View_GetUserHistory]    Script Date: 8/20/2021 4:27:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [org].[View_GetUserHistory]
AS 
    
select u.CompanyID,
       u.UserID, u.FirstName,  u.LastName, u.UserEmail, u.ExternalUserID, u.JobTitle, 
       (u.FirstName + ' ' + u.LastName) as [UserFullName],
       u.IsActivityCollectionOn, u.IsFullTimeEmployee, u.IsActive,
       u.SisenseId,
       d.DepartmentID, d.DepartmentName, 
	   loc.LocationID, loc.LocationName,
       t.TeamID, t.TeamName,
       mgr.UserID as ManagerUserID, 
       (mgr.FirstName + ' ' + mgr.LastName) as ManagerName,
       jao.JobFamilyActivityOverrideProfileID, jao.JobFamilyName as JobFamilyActivityOverrideProfileName,
	   uao.UserActivityOverrideProfileID, uao.ProfileName as UserActivityOverrideProfileName,
       v.VendorID, v.VendorName,
	   w.WorkScheduleID, w.WorkScheduleName,
       u.ModifiedBy, u.SysStartTimeUTC, u.SysEndTimeUTC  
from [history].UsersHistory u 
   left join [org].Department d on d.CompanyId = u.CompanyId and d.DepartmentId = u.DepartmentId
     JOIN (
   select CompanyID, TeamID, TeamName,ManagerID, max(SysStartTimeUTC) SysStartTimeUTC from
    (select CompanyID, TeamID, TeamName,ManagerID, SysStartTimeUTC from org.Team
    union
    select CompanyID, TeamID, TeamName,ManagerID, max(SysStartTimeUTC) from history.TeamHistory group by CompanyID, TeamID, TeamName,ManagerID
    ) team
group by CompanyID, TeamID, TeamName,ManagerID)t  on t.CompanyId = u.CompanyId and t.TeamID = u.TeamID
  -- left join [org].Team t on t.CompanyId = u.CompanyId and t.TeamID = u.TeamID
   left join [org].Users mgr on mgr.CompanyId = u.CompanyId and mgr.UserID = t.ManagerID
   left join [org].UserActivityOverrideProfile uao on uao.CompanyId = u.CompanyId and uao.UserActivityOverrideProfileID = u.UserActivityOverrideProfileID
   left join [org].JobFamilyActivityOverrideProfile jao on jao.CompanyId = u.CompanyId and jao.JobFamilyActivityOverrideProfileID = u.JobFamilyActivityOverrideProfileID
   left join [org].WorkSchedule w on w.CompanyId = u.CompanyId and w.WorkScheduleID = u.WorkScheduleID
   left join [org].Vendor v on v.CompanyId = u.CompanyId and v.VendorID = u.VendorID
   left join [org].[Location] loc on loc.CompanyId = u.CompanyId and loc.LocationID = u.LocationID


GO
/****** Object:  Table [history].[UserCustomFieldHistory]    Script Date: 8/20/2021 4:27:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [history].[UserCustomFieldHistory](
	[CompanyID] [int] NOT NULL,
	[UserID] [int] NOT NULL,
	[CustomFieldID] [int] NOT NULL,
	[StringValue] [nvarchar](500) NULL,
	[DateValue] [datetimeoffset](7) NULL,
	[NumericValue] [float] NULL,
	[BooleanValue] [bit] NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[SysStartTimeUTC] [datetime2](7) NOT NULL,
	[SysEndTimeUTC] [datetime2](7) NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [org].[UserCustomField]    Script Date: 8/20/2021 4:27:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [org].[UserCustomField](
	[CompanyID] [int] NOT NULL,
	[UserID] [int] NOT NULL,
	[CustomFieldID] [int] NOT NULL,
	[StringValue] [nvarchar](500) NULL,
	[DateValue] [datetimeoffset](7) NULL,
	[NumericValue] [float] NULL,
	[BooleanValue] [bit] NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[SysStartTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[SysEndTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
 CONSTRAINT [PK_UserCustomField] PRIMARY KEY CLUSTERED 
(
	[CompanyID] ASC,
	[UserID] ASC,
	[CustomFieldID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([SysStartTimeUTC], [SysEndTimeUTC])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON ( HISTORY_TABLE = [history].[UserCustomFieldHistory] )
)
GO
/****** Object:  Table [history].[SettingsHistory]    Script Date: 8/20/2021 4:27:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [history].[SettingsHistory](
	[SettingID] [int] NOT NULL,
	[CategoryID] [int] NOT NULL,
	[AvailableFor] [tinyint] NOT NULL,
	[SettingName] [nvarchar](4000) NOT NULL,
	[DisplayName] [nvarchar](4000) NOT NULL,
	[SettingDescription] [nvarchar](4000) NOT NULL,
	[DefaultValue] [nvarchar](1000) NOT NULL,
	[IsVisible] [bit] NOT NULL,
	[IsReadOnly] [bit] NOT NULL,
	[DataTypeID] [tinyint] NOT NULL,
	[DataValidationExpression] [nvarchar](4000) NULL,
	[DataValidationMessage] [nvarchar](4000) NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[SysStartTimeUTC] [datetime2](7) NOT NULL,
	[SysEndTimeUTC] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [org].[Settings]    Script Date: 8/20/2021 4:27:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [org].[Settings](
	[SettingID] [int] IDENTITY(1,1) NOT NULL,
	[CategoryID] [int] NOT NULL,
	[AvailableFor] [tinyint] NOT NULL,
	[SettingName] [nvarchar](4000) NOT NULL,
	[DisplayName] [nvarchar](4000) NOT NULL,
	[SettingDescription] [nvarchar](4000) NOT NULL,
	[DefaultValue] [nvarchar](1000) NOT NULL,
	[IsVisible] [bit] NOT NULL,
	[IsReadOnly] [bit] NOT NULL,
	[DataTypeID] [tinyint] NOT NULL,
	[DataValidationExpression] [nvarchar](4000) NULL,
	[DataValidationMessage] [nvarchar](4000) NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[SysStartTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[SysEndTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
 CONSTRAINT [PK_Settings] PRIMARY KEY CLUSTERED 
(
	[SettingID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UC_SettingName] UNIQUE NONCLUSTERED 
(
	[SettingName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([SysStartTimeUTC], [SysEndTimeUTC])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON ( HISTORY_TABLE = [history].[SettingsHistory] )
)
GO
/****** Object:  Table [org].[DashboardChangeLog]    Script Date: 8/20/2021 4:27:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [org].[DashboardChangeLog](
	[CompanyID] [int] NOT NULL,
	[ChangeLogId] [int] IDENTITY(100,1) NOT NULL,
	[EntityId] [int] NOT NULL,
	[EntityDisplayName] [nvarchar](500) NOT NULL,
	[PreviousValue] [nvarchar](500) NULL,
	[CurrentValue] [nvarchar](500) NULL,
	[RefPropertyPreviousId] [int] NULL,
	[RefPropertyCurrentId] [int] NULL,
	[RefEntityId] [nvarchar](20) NULL,
	[RefEntityName] [nvarchar](500) NULL,
	[RefPropertyChangeType] [int] NULL,
	[EntityChangeAction] [int] NOT NULL,
	[ModifiedBy] [nvarchar](500) NOT NULL,
	[ModifiedOn] [datetime2](7) NULL,
	[PropertySettingID] [int] NULL,
	[EntitySettingID] [int] NULL,
 CONSTRAINT [PK_Changelog] PRIMARY KEY CLUSTERED 
(
	[CompanyID] ASC,
	[ChangeLogId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [org].[View_AdminChangeLog]    Script Date: 8/20/2021 4:27:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [org].[View_AdminChangeLog]
AS
SELECT
    D.CompanyID
    ,S2.DisplayName AS [Entity Type]
    ,D.[EntityDisplayName] AS [Entity Name]
    ,S1.DisplayName AS [Property Name]
    ,CASE
    WHEN D.EntityChangeAction=1 THEN 'Add'
    WHEN D.EntityChangeAction=2 THEN 'Update'
    WHEN D.EntityChangeAction=3 THEN 'Delete'
    END
     AS [Change Type]
    ,D.PreviousValue AS [Previous Value]
    ,D.CurrentValue AS [New Value]
    ,D.ModifiedBy AS [Changes Made By]
    ,D.ModifiedOn AS [Modified Date]
    ,C1.CategoryName AS [Property Category]
    ,C2.CategoryName AS [Setting Category]
    ,C1.CategoryDescription AS [Property Category Description]
    ,C2.CategoryDescription AS [Setting Category Description]
FROM [org].[DashboardChangeLog] D
LEFT OUTER JOIN [org].[Settings] S1 ON D.PropertySettingID = S1.SettingID
LEFT OUTER JOIN [org].[Settings] S2 ON D.EntitySettingID = S2.SettingID
LEFT OUTER JOIN [org].[SettingsCategory] C1 ON C1.CategoryID=S1.CategoryID
LEFT OUTER JOIN [org].[SettingsCategory] C2 ON C2.CategoryID=S2.CategoryID


GO
/****** Object:  View [org].[View_TeamHistory]    Script Date: 8/20/2021 4:27:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE    VIEW [org].[View_TeamHistory]
    AS 

select th.CompanyID,
       th.TeamID,
       th.TeamName, 
       th.TeamDescription, 
       th.ManagerID as [ManagerID], 
       (u.FirstName + ' ' + u.LastName) as ManagerName, 
       th.ModifiedBy, th.SysStartTimeUTC, th.SysEndTimeUTC  
from [history].TeamHistory th 
   left join [org].Users u on u.CompanyId = th.CompanyId and u.UserID = th.ManagerID
   
  UNION
   
select t.CompanyID,
       t.TeamID,
       t.TeamName, 
       t.TeamDescription, 
       t.ManagerID as [ManagerID], 
       (u.FirstName + ' ' + u.LastName) as ManagerName, 
       t.ModifiedBy, t.SysStartTimeUTC, t.SysEndTimeUTC  
from [org].Team t 
   left join [org].Users u on u.CompanyId = t.CompanyId and u.UserID = t.ManagerID



GO
/****** Object:  View [org].[View_UserHistory]    Script Date: 8/20/2021 4:27:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [org].[View_UserHistory]
AS 

 

select u.CompanyID,
       u.UserID, u.FirstName,  u.LastName, u.UserEmail, u.ExternalUserID, u.JobTitle, u.UserName,
       (u.FirstName + ' ' + u.LastName) as [UserFullName],
       u.IsActivityCollectionOn, u.IsFullTimeEmployee, u.IsActive,
       u.SisenseId, 
       d.DepartmentID, d.DepartmentName, 
       loc.LocationID, loc.LocationName,
       t.TeamID, t.TeamName,
       mgr.UserID as ManagerUserID, 
       (mgr.FirstName + ' ' + mgr.LastName) as ManagerName,
       jao.JobFamilyActivityOverrideProfileID, jao.JobFamilyName as JobFamilyActivityOverrideProfileName,
       uao.UserActivityOverrideProfileID, uao.ProfileName as UserActivityOverrideProfileName,
       v.VendorID, v.VendorName,
       w.WorkScheduleID, w.WorkScheduleName,
       u.ModifiedBy, u.SysStartTimeUTC, u.SysEndTimeUTC  
from Users u 
   left join Department d on d.CompanyId = u.CompanyId and d.DepartmentId = u.DepartmentId
   left join Team t on t.CompanyId = u.CompanyId and t.TeamID = u.TeamID
   left join Users mgr on mgr.CompanyId = u.CompanyId and mgr.UserID = t.ManagerID
   left join UserActivityOverrideProfile uao on uao.CompanyId = u.CompanyId and uao.UserActivityOverrideProfileID = u.UserActivityOverrideProfileID
   left join JobFamilyActivityOverrideProfile jao on jao.CompanyId = u.CompanyId and jao.JobFamilyActivityOverrideProfileID = u.UserActivityOverrideProfileID
   left join WorkSchedule w on w.CompanyId = u.CompanyId and w.WorkScheduleID = u.WorkScheduleID
   left join Vendor v on v.CompanyId = u.CompanyId and v.VendorID = u.VendorID
   left join [Location] loc on loc.CompanyId = u.CompanyId and loc.LocationID = u.LocationID
   
   UNION

 

select uh.CompanyID,
       uh.UserID, uh.FirstName,  uh.LastName, uh.UserEmail, uh.ExternalUserID, uh.JobTitle, uh.UserName,
       (uh.FirstName + ' ' + uh.LastName) as [UserFullName],
       uh.IsActivityCollectionOn, uh.IsFullTimeEmployee, uh.IsActive,
       uh.SisenseId, 
       d.DepartmentID, d.DepartmentName, 
       loc.LocationID, loc.LocationName,
       t.TeamID, t.TeamName,
       mgr.UserID as ManagerUserID, 
       (mgr.FirstName + ' ' + mgr.LastName) as ManagerName,
       jao.JobFamilyActivityOverrideProfileID, jao.JobFamilyName as JobFamilyActivityOverrideProfileName,
       uao.UserActivityOverrideProfileID, uao.ProfileName as UserActivityOverrideProfileName,
       v.VendorID, v.VendorName,
       w.WorkScheduleID, w.WorkScheduleName,
       uh.ModifiedBy, uh.SysStartTimeUTC, uh.SysEndTimeUTC  
from UsersHistory uh 
   left join Department d on d.CompanyId = uh.CompanyId and d.DepartmentId = uh.DepartmentId
   left join Team t on t.CompanyId = uh.CompanyId and t.TeamID = uh.TeamID
   left join Users mgr on mgr.CompanyId = uh.CompanyId and mgr.UserID = t.ManagerID
   left join UserActivityOverrideProfile uao on uao.CompanyId = uh.CompanyId and uao.UserActivityOverrideProfileID = uh.UserActivityOverrideProfileID
   left join JobFamilyActivityOverrideProfile jao on jao.CompanyId = uh.CompanyId and jao.JobFamilyActivityOverrideProfileID = uh.UserActivityOverrideProfileID
   left join WorkSchedule w on w.CompanyId = uh.CompanyId and w.WorkScheduleID = uh.WorkScheduleID
   left join Vendor v on v.CompanyId = uh.CompanyId and v.VendorID = uh.VendorID
   left join [Location] loc on loc.CompanyId = uh.CompanyId and loc.LocationID = uh.LocationID
GO
/****** Object:  View [org].[View_AppSpecPlatformHistory]    Script Date: 8/20/2021 4:27:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [org].[View_AppSpecPlatformHistory]
    AS 

select 
     asp.CompanyID,
     asp.AppSpecPlatformID,
     asp.DisplayName,
     asp.AppVersion,
     spec.AppSpecID,
     spec.AppDisplayName,
     p.PlatformID,
     p.PlatformName,
     p.PlatformVersion,
     asp.ModifiedBy, asp.SysStartTimeUTC, asp.SysEndTimeUTC

from  org.AppSpecPlatform asp
    join [org].AppSpec spec on spec.CompanyId = asp.CompanyId and spec.AppSpecId = asp.AppSpecID
    join [org].[Platform] p on p.CompanyId = asp.CompanyId and p.PlatformID = asp.PlatformID

    UNION

select 
     asph.CompanyID,
     asph.AppSpecPlatformID,
     asph.DisplayName,
     asph.AppVersion,
     spec.AppSpecID,
     spec.AppDisplayName,
     p.PlatformID,
     p.PlatformName,
     p.PlatformVersion,
     asph.ModifiedBy, asph.SysStartTimeUTC, asph.SysEndTimeUTC

from history.AppSpecPlatformHistory asph
    join [org].AppSpec spec on spec.CompanyId = asph.CompanyId and spec.AppSpecId = asph.AppSpecID
    join [org].[Platform] p on p.CompanyId = asph.CompanyId and p.PlatformID = asph.PlatformID
GO
/****** Object:  Table [history].[DataTypeHistory]    Script Date: 8/20/2021 4:27:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [history].[DataTypeHistory](
	[DataTypeID] [tinyint] NOT NULL,
	[DataTypeName] [nvarchar](4000) NOT NULL,
	[DisplayName] [nvarchar](4000) NOT NULL,
	[DataTypeDescription] [nvarchar](4000) NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[SysStartTimeUTC] [datetime2](7) NOT NULL,
	[SysEndTimeUTC] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [org].[DataType]    Script Date: 8/20/2021 4:27:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [org].[DataType](
	[DataTypeID] [tinyint] IDENTITY(1,1) NOT NULL,
	[DataTypeName] [nvarchar](4000) NOT NULL,
	[DisplayName] [nvarchar](4000) NOT NULL,
	[DataTypeDescription] [nvarchar](4000) NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[SysStartTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[SysEndTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
 CONSTRAINT [PK_DataType] PRIMARY KEY CLUSTERED 
(
	[DataTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UC_DataType] UNIQUE NONCLUSTERED 
(
	[DataTypeName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([SysStartTimeUTC], [SysEndTimeUTC])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON ( HISTORY_TABLE = [history].[DataTypeHistory] )
)
GO
/****** Object:  View [org].[View_UserProvisionold]    Script Date: 8/20/2021 4:27:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create    VIEW [org].[View_UserProvisionold] as 
select
  *,
  CASE WHEN SisenseState = 0 THEN 'InProcess' WHEN SisenseState = 1 THEN 'Provisioned' WHEN SisenseState = 2 THEN 'Updated' WHEN SisenseState = 3 THEN 'Error' ELSE 'Unknown' END AS SisenseStatus,
  CASE WHEN Auth0State = 0 THEN 'InProcess' WHEN Auth0State = 1 THEN 'Provisioned' WHEN Auth0State = 2 THEN 'Updated' WHEN Auth0State = 3 THEN 'Error' ELSE 'Unknown' END AS Auth0Status,
  CASE WHEN CanopyState = 0 THEN 'InProcess' WHEN CanopyState = 1 THEN 'Provisioned' WHEN CanopyState = 2 THEN 'Updated' WHEN CanopyState = 3 THEN 'Error' ELSE 'Unknown' END AS CanopyStatus
from
  (
    SELECT
      U.FirstName + ' ' + U.LastName as 'Worker',
      U.UserEmail,
      CASE WHEN U.IsActivityCollectionOn = 1 THEN 'ON' ELSE 'OFF' END AS ActivityCollection,
      CASE WHEN U.IsActive = 1 THEN 'Active' ELSE 'InActive' END AS IsActive,
      "ActivityAccess" = (
        select
          case when EXISTS (
            select
              1
            from
              [org].[UserPermission] AS UP
            where
              UP.UserID = U.UserID
              AND CompanyID = U.CompanyID
              AND Entity = 'Employee'
          ) then 'Enabled' else 'Disabled' end
      ),
      "IsAdmin" = (
        select
          case when EXISTS (
            select
              1
            from
              [org].[UserPermission] AS UP
            where
              UP.UserID = U.UserID
              AND CompanyID = U.CompanyID
              AND Entity = 'Admin'
          ) then 'Yes' else 'No' end
      ),
      U.SysStartTimeUTC as 'Date user was added',
      U.IsActivityCollectionOn,
      U.DepartmentID,
      Dept.DepartmentName,
      U.LocationID,
      Loc.LocationName,
      "SisenseState" = (
        SELECT
          top 1 UPS.State
        from
          [org].[UserProvisionState] AS UPS
        WHERE
          UPS.UserEmail = U.UserEmail
          AND UPS.ExternalSysID = 1
      ),
      Auth0State = (
        SELECT
          top 1 UPS.State
        from
          [org].[UserProvisionState] AS UPS
        WHERE
          UPS.UserEmail = U.UserEmail
          AND UPS.ExternalSysID = 0
      ),
      CanopyState = (
        SELECT
          top 1 UPS.State
        from
          [org].[UserProvisionState] AS UPS
        WHERE
          UPS.UserEmail = U.UserEmail
          AND UPS.ExternalSysID = 2
      )
    FROM
      "org".Users AS U
      INNER JOIN "org"."Department" AS Dept ON Dept.DepartmentID = U.DepartmentID
      INNER JOIN "org"."Location" AS Loc ON Loc.LocationID = U.LocationID
  ) as TempTable
GO
/****** Object:  Table [history].[CompanySettingsHistory]    Script Date: 8/20/2021 4:27:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [history].[CompanySettingsHistory](
	[CompanyID] [int] NOT NULL,
	[SettingID] [int] NOT NULL,
	[SettingValue] [nvarchar](4000) NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[SysStartTimeUTC] [datetime2](7) NOT NULL,
	[SysEndTimeUTC] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [org].[CompanySettings]    Script Date: 8/20/2021 4:27:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [org].[CompanySettings](
	[CompanyID] [int] NOT NULL,
	[SettingID] [int] NOT NULL,
	[SettingValue] [nvarchar](4000) NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[SysStartTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[SysEndTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
 CONSTRAINT [PK_CompanySettings] PRIMARY KEY CLUSTERED 
(
	[CompanyID] ASC,
	[SettingID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([SysStartTimeUTC], [SysEndTimeUTC])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON ( HISTORY_TABLE = [history].[CompanySettingsHistory] )
)
GO
/****** Object:  Table [history].[IntegrationCycleStatusHistory]    Script Date: 8/20/2021 4:27:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [history].[IntegrationCycleStatusHistory](
	[CycleStatusId] [int] NOT NULL,
	[CompanyId] [int] NOT NULL,
	[CycleId] [nvarchar](50) NOT NULL,
	[IntegrationSourceName] [nvarchar](50) NOT NULL,
	[StartTime] [datetimeoffset](7) NOT NULL,
	[EndTime] [datetimeoffset](7) NULL,
	[Status] [smallint] NOT NULL,
	[SysStartTimeUTC] [datetime2](7) NOT NULL,
	[SysEndTimeUTC] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [org].[IntegrationCycleStatus]    Script Date: 8/20/2021 4:27:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [org].[IntegrationCycleStatus](
	[CycleStatusId] [int] IDENTITY(1,1) NOT NULL,
	[CompanyId] [int] NOT NULL,
	[CycleId] [nvarchar](50) NOT NULL,
	[IntegrationSourceName] [nvarchar](50) NOT NULL,
	[StartTime] [datetimeoffset](7) NOT NULL,
	[EndTime] [datetimeoffset](7) NULL,
	[Status] [smallint] NOT NULL,
	[SysStartTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[SysEndTimeUTC] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
 CONSTRAINT [PK_IntegrationCycleStatus] PRIMARY KEY CLUSTERED 
(
	[CycleStatusId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([SysStartTimeUTC], [SysEndTimeUTC])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON ( HISTORY_TABLE = [history].[IntegrationCycleStatusHistory] )
)
GO
/****** Object:  View [org].[View_VueUsageInfo]    Script Date: 8/20/2021 4:27:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   View [org].[View_VueUsageInfo]
AS 

 

SELECT Cast(SysStartTimeUTC as  Date) Date, COUNT(*) AS ActiveInactiveCount,CAst(1 As bit) as IsActive ,CompanyID
FROM  org.Users u 
Group By  Cast(SysStartTimeUTC as  Date),CompanyID
  union 
select  Cast(SysStartTimeUTC as  Date) Date,COUNT(*) AS ActiveInactiveCount,CAst(0 As bit) as IsActive,CompanyID
from history.Usershistory h
where h.userId not in (select u.UserId from org.Users u )
Group By  Cast(SysStartTimeUTC as  Date),CompanyID

GO
/****** Object:  View [org].[View_OrgUserDeviceHistory]    Script Date: 8/20/2021 4:27:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE    VIEW [org].[View_OrgUserDeviceHistory]
    AS

select 
	ud.CompanyID, ud.UserID,
	u.FirstName, u.LastName,
	d.DeviceID, d.DeviceName,
	ud.ModifiedBy, ud.SysStartTimeUTC, ud.SysEndTimeUTC  
from [org].UserDevice ud
	left join [org].Users u on u.Companyid = ud.Companyid and u.UserId = ud.UserId
	left join [org].Device d on d.Companyid = ud.Companyid and d.DeviceId = ud.DeviceID

	union all

	select 
	ud.CompanyID, ud.UserID,
	u.FirstName, u.LastName,
	d.DeviceID, d.DeviceName,
	ud.ModifiedBy, ud.SysStartTimeUTC, ud.SysEndTimeUTC  
from [history].UserDeviceHistory ud
	left join [org].Users u on u.Companyid = ud.Companyid and u.UserId = ud.UserId
	left join [org].Device d on d.Companyid = ud.Companyid and d.DeviceId = ud.DeviceID

GO
/****** Object:  View [org].[View_OrgUserDomainHistory]    Script Date: 8/20/2021 4:27:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW  [org].[View_OrgUserDomainHistory]
 AS
 select 
	ud.CompanyID, ud.UserID,
	u.FirstName, u.LastName,
	ud.UserDomainID, ud.UserName, ud.DomainName, ud.IsActive,
	ud.ModifiedBy, ud.SysStartTimeUTC, ud.SysEndTimeUTC  
from org.UserDomain	ud
	left join org.Users u on u.Companyid = ud.Companyid and u.UserId = ud.UserId
	union all
	select 
	ud.CompanyID, ud.UserID,
	u.FirstName, u.LastName,
	ud.UserDomainID, ud.UserName, ud.DomainName, ud.IsActive,
	ud.ModifiedBy, ud.SysStartTimeUTC, ud.SysEndTimeUTC
from [history].UserDomainHistory	ud
	left join [org].Users u on u.Companyid = ud.Companyid and u.UserId = ud.UserId

GO
/****** Object:  View [org].[View_OrgUserHistory]    Script Date: 8/20/2021 4:27:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW  [org].[View_OrgUserHistory]
 AS

 select u.CompanyID,
       u.UserID, u.FirstName,  u.LastName, u.UserEmail, u.ExternalUserID, u.JobTitle, 
       (u.FirstName + ' ' + u.LastName) as [UserFullName],
       u.IsActivityCollectionOn, u.IsFullTimeEmployee, u.IsActive,
       u.SisenseId, 
       d.DepartmentID, d.DepartmentName, 
	   loc.LocationID, loc.LocationName,
       t.TeamID, t.TeamName,
       mgr.UserID as ManagerUserID, 
       (mgr.FirstName + ' ' + mgr.LastName) as ManagerName,
       jao.JobFamilyActivityOverrideProfileID, jao.JobFamilyName as JobFamilyActivityOverrideProfileName,
	   uao.UserActivityOverrideProfileID, uao.ProfileName as UserActivityOverrideProfileName,
	   v.VendorID, v.VendorName,
	   w.WorkScheduleID, w.WorkScheduleName,
       u.ModifiedBy, u.SysStartTimeUTC, u.SysEndTimeUTC  
from [org].Users u 
   left join  [org].Department d on d.CompanyId = u.CompanyId and d.DepartmentId = u.DepartmentId
   left join  [org].Team t on t.CompanyId = u.CompanyId and t.TeamID = u.TeamID
   left join  [org].Users mgr on mgr.CompanyId = u.CompanyId and mgr.UserID = t.ManagerID
   left join  [org].UserActivityOverrideProfile uao on uao.CompanyId = u.CompanyId and uao.UserActivityOverrideProfileID = u.UserActivityOverrideProfileID
   left join  [org].JobFamilyActivityOverrideProfile jao on jao.CompanyId = u.CompanyId and jao.JobFamilyActivityOverrideProfileID = u.JobFamilyActivityOverrideProfileID
   left join  [org].WorkSchedule w on w.CompanyId = u.CompanyId and w.WorkScheduleID = u.WorkScheduleID
   left join  [org].Vendor v on v.CompanyId = u.CompanyId and v.VendorID = u.VendorID
   left join  [org].[Location] loc on loc.CompanyId = u.CompanyId and loc.LocationID = u.LocationID

   union all

   select u.CompanyID,
       u.UserID, u.FirstName,  u.LastName, u.UserEmail, u.ExternalUserID, u.JobTitle, 
       (u.FirstName + ' ' + u.LastName) as [UserFullName],
       u.IsActivityCollectionOn, u.IsFullTimeEmployee, u.IsActive,
       u.SisenseId,
       d.DepartmentID, d.DepartmentName, 
	   loc.LocationID, loc.LocationName,
       t.TeamID, t.TeamName,
       mgr.UserID as ManagerUserID, 
       (mgr.FirstName + ' ' + mgr.LastName) as ManagerName,
       jao.JobFamilyActivityOverrideProfileID, jao.JobFamilyName as JobFamilyActivityOverrideProfileName,
	   uao.UserActivityOverrideProfileID, uao.ProfileName as UserActivityOverrideProfileName,
       v.VendorID, v.VendorName,
	   w.WorkScheduleID, w.WorkScheduleName,
       u.ModifiedBy, u.SysStartTimeUTC, u.SysEndTimeUTC  
from [history].UsersHistory u 
   left join [org].Department d on d.CompanyId = u.CompanyId and d.DepartmentId = u.DepartmentId
   left join [org].Team t on t.CompanyId = u.CompanyId and t.TeamID = u.TeamID
   left join [org].Users mgr on mgr.CompanyId = u.CompanyId and mgr.UserID = t.ManagerID
   left join [org].UserActivityOverrideProfile uao on uao.CompanyId = u.CompanyId and uao.UserActivityOverrideProfileID = u.UserActivityOverrideProfileID
   left join [org].JobFamilyActivityOverrideProfile jao on jao.CompanyId = u.CompanyId and jao.JobFamilyActivityOverrideProfileID = u.JobFamilyActivityOverrideProfileID
   left join [org].WorkSchedule w on w.CompanyId = u.CompanyId and w.WorkScheduleID = u.WorkScheduleID
   left join [org].Vendor v on v.CompanyId = u.CompanyId and v.VendorID = u.VendorID
   left join [org].[Location] loc on loc.CompanyId = u.CompanyId and loc.LocationID = u.LocationID

GO
/****** Object:  View [org].[View_OrgUserPermissionHistory]    Script Date: 8/20/2021 4:27:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [org].[View_OrgUserPermissionHistory]
 AS
select 
	up.CompanyId, up.UserId,
	u.FirstName, u.LastName,
	up.Entity, up.Permission,
	up.ModifiedBy, up.SysStartTimeUTC, up.SysEndTimeUTC  
from org.userpermission	up
	left join org.Users u on u.Companyid = up.Companyid and u.UserId = up.UserId

union all

select
	up.CompanyID, up.UserID,
	u.FirstName, u.LastName,
	up.Entity, up.Permission,
	up.ModifiedBy, up.SysStartTimeUTC, up.SysEndTimeUTC
from history.UserPermissionHistory	up
	left join org.Users u on u.Companyid = up.Companyid and u.UserId = up.UserId

GO
/****** Object:  Table [dbo].[flyway_schema_history]    Script Date: 8/20/2021 4:27:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[flyway_schema_history](
	[installed_rank] [int] NOT NULL,
	[version] [nvarchar](50) NULL,
	[description] [nvarchar](200) NULL,
	[type] [nvarchar](20) NOT NULL,
	[script] [nvarchar](1000) NOT NULL,
	[checksum] [int] NULL,
	[installed_by] [nvarchar](100) NOT NULL,
	[installed_on] [datetime] NOT NULL,
	[execution_time] [int] NOT NULL,
	[success] [bit] NOT NULL,
 CONSTRAINT [flyway_schema_history_pk] PRIMARY KEY CLUSTERED 
(
	[installed_rank] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[flyway_schema_history_devops_test]    Script Date: 8/20/2021 4:27:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[flyway_schema_history_devops_test](
	[installed_rank] [int] NOT NULL,
	[version] [nvarchar](50) NULL,
	[description] [nvarchar](200) NULL,
	[type] [nvarchar](20) NOT NULL,
	[script] [nvarchar](1000) NOT NULL,
	[checksum] [int] NULL,
	[installed_by] [nvarchar](100) NOT NULL,
	[installed_on] [datetime] NOT NULL,
	[execution_time] [int] NOT NULL,
	[success] [bit] NOT NULL,
 CONSTRAINT [flyway_schema_history_devops_test_pk] PRIMARY KEY CLUSTERED 
(
	[installed_rank] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[flyway_schema_history_hotfix]    Script Date: 9/9/2021 5:04:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[flyway_schema_history_hotfix](
	[installed_rank] [int] NOT NULL,
	[version] [nvarchar](50) NULL,
	[description] [nvarchar](200) NULL,
	[type] [nvarchar](20) NOT NULL,
	[script] [nvarchar](1000) NOT NULL,
	[checksum] [int] NULL,
	[installed_by] [nvarchar](100) NOT NULL,
	[installed_on] [datetime] NOT NULL,
	[execution_time] [int] NOT NULL,
	[success] [bit] NOT NULL,
 CONSTRAINT [flyway_schema_history_hotfix_pk] PRIMARY KEY CLUSTERED 
(
	[installed_rank] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[flyway_schema_history_init]    Script Date: 9/9/2021 5:04:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[flyway_schema_history_init](
	[installed_rank] [int] NOT NULL,
	[version] [nvarchar](50) NULL,
	[description] [nvarchar](200) NULL,
	[type] [nvarchar](20) NOT NULL,
	[script] [nvarchar](1000) NOT NULL,
	[checksum] [int] NULL,
	[installed_by] [nvarchar](100) NOT NULL,
	[installed_on] [datetime] NOT NULL,
	[execution_time] [int] NOT NULL,
	[success] [bit] NOT NULL,
 CONSTRAINT [flyway_schema_history_init_pk] PRIMARY KEY CLUSTERED 
(
	[installed_rank] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[flyway_schema_history_integrations]    Script Date: 8/20/2021 4:27:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[flyway_schema_history_integrations](
	[installed_rank] [int] NOT NULL,
	[version] [nvarchar](50) NULL,
	[description] [nvarchar](200) NULL,
	[type] [nvarchar](20) NOT NULL,
	[script] [nvarchar](1000) NOT NULL,
	[checksum] [int] NULL,
	[installed_by] [nvarchar](100) NOT NULL,
	[installed_on] [datetime] NOT NULL,
	[execution_time] [int] NOT NULL,
	[success] [bit] NOT NULL,
 CONSTRAINT [flyway_schema_history_integrations_pk] PRIMARY KEY CLUSTERED 
(
	[installed_rank] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[flyway_schema_history_reports]    Script Date: 8/20/2021 4:27:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[flyway_schema_history_reports](
	[installed_rank] [int] NOT NULL,
	[version] [nvarchar](50) NULL,
	[description] [nvarchar](200) NULL,
	[type] [nvarchar](20) NOT NULL,
	[script] [nvarchar](1000) NOT NULL,
	[checksum] [int] NULL,
	[installed_by] [nvarchar](100) NOT NULL,
	[installed_on] [datetime] NOT NULL,
	[execution_time] [int] NOT NULL,
	[success] [bit] NOT NULL,
 CONSTRAINT [flyway_schema_history_reports_pk] PRIMARY KEY CLUSTERED 
(
	[installed_rank] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[flyway_schema_history_reports_hotfix]    Script Date: 8/20/2021 4:27:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[flyway_schema_history_reports_hotfix](
	[installed_rank] [int] NOT NULL,
	[version] [nvarchar](50) NULL,
	[description] [nvarchar](200) NULL,
	[type] [nvarchar](20) NOT NULL,
	[script] [nvarchar](1000) NOT NULL,
	[checksum] [int] NULL,
	[installed_by] [nvarchar](100) NOT NULL,
	[installed_on] [datetime] NOT NULL,
	[execution_time] [int] NOT NULL,
	[success] [bit] NOT NULL,
 CONSTRAINT [flyway_schema_history_reports_hotfix_pk] PRIMARY KEY CLUSTERED 
(
	[installed_rank] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ImportActivityCategory]    Script Date: 8/20/2021 4:27:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ImportActivityCategory](
	[CompanyID] [int] NOT NULL,
	[ActivityCategoryName] [nvarchar](255) NOT NULL,
	[IsCore] [bit] NOT NULL,
	[PushedInMaster] [bit] NOT NULL,
	[DateUploaded] [smalldatetime] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ImportAddDomain]    Script Date: 8/20/2021 4:27:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ImportAddDomain](
	[CompanyID] [int] NOT NULL,
	[UserEmail] [nvarchar](255) NOT NULL,
	[DomainName] [nvarchar](255) NOT NULL,
	[DomainUserID] [nvarchar](255) NOT NULL,
	[PushedInMaster] [bit] NULL,
	[DateUploaded] [smalldatetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ImportAppActivity]    Script Date: 8/20/2021 4:27:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ImportAppActivity](
	[CompanyID] [float] NULL,
	[ExeName] [nvarchar](255) NULL,
	[ActivityCategoryName] [nvarchar](255) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ImportAppActivityCategory]    Script Date: 8/20/2021 4:27:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ImportAppActivityCategory](
	[CompanyID] [int] NOT NULL,
	[ExeName] [nvarchar](255) NOT NULL,
	[ActivityCategoryName] [nvarchar](255) NOT NULL,
	[AppDisplayName] [nvarchar](200) NOT NULL,
	[PushedInMaster] [bit] NOT NULL,
	[DateUploaded] [smalldatetime] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ImportDepartment]    Script Date: 8/20/2021 4:27:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ImportDepartment](
	[CompanyID] [int] NOT NULL,
	[DepartmentCode] [nvarchar](255) NOT NULL,
	[DepartmentName] [nvarchar](255) NULL,
	[ManagerEmail] [nvarchar](255) NULL,
	[PushedInMaster] [bit] NOT NULL,
	[DateUploaded] [smalldatetime] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ImportDepartmentHistory]    Script Date: 8/20/2021 4:27:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ImportDepartmentHistory](
	[CompanyID] [float] NULL,
	[UserEmail] [nvarchar](255) NULL,
	[DepartmentCode] [nvarchar](255) NULL,
	[IsManager] [bit] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ImportEmployeeTitle]    Script Date: 8/20/2021 4:27:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ImportEmployeeTitle](
	[CompanyID] [int] NOT NULL,
	[EmployeeTitleCode] [nvarchar](255) NOT NULL,
	[EmployeeTitle] [nvarchar](255) NOT NULL,
	[PushedInMaster] [bit] NOT NULL,
	[DateUploaded] [smalldatetime] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ImportJobData]    Script Date: 8/20/2021 4:27:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ImportJobData](
	[CompanyID] [float] NULL,
	[UserEmail] [nvarchar](255) NULL,
	[JobFamily] [nvarchar](255) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ImportLocation]    Script Date: 8/20/2021 4:27:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ImportLocation](
	[CompanyID] [int] NOT NULL,
	[LocationName] [nvarchar](255) NOT NULL,
	[Country] [nvarchar](255) NOT NULL,
	[Region] [nvarchar](255) NULL,
	[State] [nvarchar](255) NULL,
	[City] [nvarchar](255) NULL,
	[PushedInMaster] [bit] NOT NULL,
	[DateUploaded] [smalldatetime] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ImportmultipleDomain]    Script Date: 8/20/2021 4:27:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ImportmultipleDomain](
	[CompanyID] [int] NOT NULL,
	[UserEmail] [nvarchar](255) NOT NULL,
	[DomainName] [nvarchar](255) NOT NULL,
	[DomainUserID] [nvarchar](255) NOT NULL,
	[PushedInMaster] [bit] NULL,
	[DateUploaded] [smalldatetime] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ImportUserDepartment]    Script Date: 8/20/2021 4:27:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ImportUserDepartment](
	[CompanyID] [int] NOT NULL,
	[UserEmail] [nvarchar](255) NOT NULL,
	[DepartmentCode] [nvarchar](255) NOT NULL,
	[IsManager] [bit] NOT NULL,
	[PushedInMaster] [bit] NOT NULL,
	[DateUploaded] [smalldatetime] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ImportUserJobFamily]    Script Date: 8/20/2021 4:27:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ImportUserJobFamily](
	[CompanyID] [int] NOT NULL,
	[UserEmail] [nvarchar](255) NOT NULL,
	[JobFamily] [nvarchar](255) NOT NULL,
	[PushedInMaster] [bit] NOT NULL,
	[DateUploaded] [smalldatetime] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ImportUsers]    Script Date: 8/20/2021 4:27:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ImportUsers](
	[CompanyID] [int] NOT NULL,
	[FirstName] [nvarchar](255) NOT NULL,
	[MiddleName] [nvarchar](255) NULL,
	[LastName] [nvarchar](255) NULL,
	[UserEmail] [nvarchar](255) NOT NULL,
	[EmployeeCode] [nvarchar](255) NULL,
	[ReportsToUserEmail] [nvarchar](255) NOT NULL,
	[Location] [nvarchar](255) NOT NULL,
	[EmployeeTitleCode] [nvarchar](255) NOT NULL,
	[DomainName] [nvarchar](255) NOT NULL,
	[DomainUserID] [nvarchar](255) NOT NULL,
	[JobTitle] [nvarchar](255) NOT NULL,
	[PushedInMaster] [bit] NOT NULL,
	[DateUploaded] [smalldatetime] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ImportWebAppActivityCategory]    Script Date: 8/20/2021 4:27:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ImportWebAppActivityCategory](
	[CompanyID] [int] NOT NULL,
	[AppName] [nvarchar](255) NOT NULL,
	[WebAppUrlDomain] [nvarchar](255) NOT NULL,
	[ActivityCategoryName] [nvarchar](255) NOT NULL,
	[UrlMatchStrategy] [int] NULL,
	[PushedInMaster] [bit] NOT NULL,
	[DateUploaded] [smalldatetime] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MSSQL_TemporalHistoryFor_1237683557]    Script Date: 8/20/2021 4:27:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MSSQL_TemporalHistoryFor_1237683557](
	[CompanyID] [int] NOT NULL,
	[ManagerID] [int] NOT NULL,
	[TeamName] [nvarchar](200) NULL,
	[TeamDescription] [nvarchar](500) NULL,
	[IsEmployeeActivityVisible] [bit] NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[SysStartTimeUTC] [datetime2](7) NOT NULL,
	[SysEndTimeUTC] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[sysdiagrams]    Script Date: 8/20/2021 4:27:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sysdiagrams](
	[name] [sysname] NOT NULL,
	[principal_id] [int] NOT NULL,
	[diagram_id] [int] IDENTITY(1,1) NOT NULL,
	[version] [int] NULL,
	[definition] [varbinary](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[diagram_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UK_principal_name] UNIQUE NONCLUSTERED 
(
	[principal_id] ASC,
	[name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Versions]    Script Date: 8/20/2021 4:27:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Versions](
	[Component] [nvarchar](100) NOT NULL,
	[Version] [nvarchar](50) NOT NULL,
	[ModifiedOn] [datetimeoffset](7) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Dim_User]    Script Date: 8/20/2021 4:27:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE EXTERNAL TABLE [edw].[Dim_User]
(
	[ID] [int] NOT NULL,
	[CompanyID] [int] NOT NULL,
	[DomainUserID] [nvarchar](128) NOT NULL,
	[DomainName] [nvarchar](128) NOT NULL,
	[EmployeeCode] [nvarchar](255) NOT NULL,
	[UserEmail] [nvarchar](255) NOT NULL,
	[FirstName] [nvarchar](255) NOT NULL,
	[MiddleName] [nvarchar](255) NULL,
	[LastName] [nvarchar](255) NOT NULL,
	[DateCreated] [smalldatetime] NOT NULL,
	[DateDeleted] [smalldatetime] NULL,
	[IsActive] [bit] NOT NULL,
	[CurrentTimestamp] [timestamp] NOT NULL,
	[ReportsToDimUserID] [int] NULL,
	[Dim_LocationID] [int] NULL,
	[Dim_EmployeeTitleID] [int] NULL,
	[WeekWorkHours] [real] NULL,
	[WeekWorkDays] [real] NULL
)
WITH (DATA_SOURCE = [eds_Dev_EDW])
GO
/****** Object:  Table [history].[UserProvisionStatusHistory]    Script Date: 9/9/2021 5:04:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [history].[UserProvisionStatusHistory](
	[CompanyID] [int] NOT NULL,
	[UserEmail] [nvarchar](200) NOT NULL,
	[ExternalSysID] [int] NOT NULL,
	[State] [int] NOT NULL,
	[ErrorMessage] [nvarchar](200) NULL,
	[ErrorStackTrace] [nvarchar](max) NULL,
	[SysStartTimeUTC] [datetime2](7) NOT NULL,
	[SysEndTimeUTC] [datetime2](7) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [history].[Users]    Script Date: 9/9/2021 5:04:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [history].[Users](
	[CompanyID] [int] NOT NULL,
	[UserID] [int] NOT NULL,
	[DepartmentID] [int] NULL,
	[UserActivityOverrideProfileID] [int] NULL,
	[JobFamilyActivityOverrideProfileID] [int] NULL,
	[LocationID] [int] NOT NULL,
	[VendorID] [int] NULL,
	[ExternalUserID] [nvarchar](100) NULL,
	[UserEmail] [nvarchar](255) NOT NULL,
	[FirstName] [nvarchar](100) NOT NULL,
	[LastName] [nvarchar](100) NOT NULL,
	[JobTitle] [nvarchar](100) NULL,
	[SisenseId] [nvarchar](100) NULL,
	[Auth0Id] [nvarchar](100) NULL,
	[IsFullTimeEmployee] [bit] NOT NULL,
	[IsActivityCollectionOn] [bit] NOT NULL,
	[WorkScheduleID] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[SysStartTimeUTC] [datetime2](7) NOT NULL,
	[SysEndTimeUTC] [datetime2](7) NOT NULL,
	[TeamID] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [import].[OrgUser]    Script Date: 8/20/2021 4:27:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [import].[OrgUser](
	[OrgUserID] [int] IDENTITY(100,1) NOT NULL,
	[CompanyID] [int] NOT NULL,
	[EmployeeID] [nvarchar](100) NULL,
	[FirstName] [nvarchar](100) NOT NULL,
	[LastName] [nvarchar](100) NOT NULL,
	[Email] [nvarchar](150) NOT NULL,
	[ManagerEmail] [nvarchar](150) NULL,
	[JobTitle] [nvarchar](100) NULL,
	[JobFamily] [nvarchar](100) NULL,
	[Location] [nvarchar](150) NOT NULL,
	[Department] [nvarchar](150) NOT NULL,
	[IsUserDepartmentOwner] [bit] NULL,
	[IsActivityCollected] [bit] NOT NULL,
	[IsContractor] [bit] NULL,
	[Vendor] [nvarchar](150) NULL,
	[CreateVueLogin] [bit] NULL,
	[DomainId1] [nvarchar](100) NULL,
	[DomainName1] [nvarchar](100) NULL,
	[DomainId2] [nvarchar](100) NULL,
	[DomainName2] [nvarchar](100) NULL,
 CONSTRAINT [PK_Device] PRIMARY KEY CLUSTERED 
(
	[OrgUserID] ASC,
	[CompanyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [MD].[ActivityCategory]    Script Date: 8/20/2021 4:27:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE EXTERNAL TABLE [MD].[ActivityCategory]
(
	[CompanyID] [int] NOT NULL,
	[ActivityCategoryGroupID] [int] NOT NULL,
	[ActivityCategoryID] [int] NOT NULL,
	[ActivityCategoryTypeID] [smallint] NOT NULL,
	[PlatformTypeID] [smallint] NOT NULL,
	[ActivityCategoryGroupName] [nvarchar](1000) NOT NULL,
	[ActivityCategoryName] [nvarchar](1000) NOT NULL,
	[IsCore] [bit] NOT NULL,
	[IsSystemDefined] [bit] NOT NULL,
	[IsConfigurable] [bit] NOT NULL,
	[IsGlobal] [bit] NOT NULL,
	[DateCreated] [smalldatetime] NOT NULL,
	[DateDeleted] [smalldatetime] NULL,
	[IsActive] [bit] NOT NULL
)
WITH (DATA_SOURCE = [eds_Dev_MAD])
GO
/****** Object:  Table [MD].[AppActivityCategoryMap]    Script Date: 8/20/2021 4:27:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE EXTERNAL TABLE [MD].[AppActivityCategoryMap]
(
	[CompanyID] [int] NOT NULL,
	[ActivityCategoryGroupID] [int] NOT NULL,
	[ActivityCategoryID] [int] NOT NULL,
	[AppName] [nvarchar](1000) NOT NULL,
	[AppVersion] [nvarchar](1000) NOT NULL,
	[PlatformTypeID] [smallint] NOT NULL,
	[IsApplication] [bit] NOT NULL,
	[DefaultPurpose] [tinyint] NOT NULL,
	[WebApp] [nvarchar](512) NOT NULL,
	[CanOverride] [bit] NOT NULL,
	[UrlMatching] [tinyint] NOT NULL,
	[DateCreated] [smalldatetime] NOT NULL,
	[DateDeleted] [smalldatetime] NULL,
	[IsActive] [bit] NOT NULL
)
WITH (DATA_SOURCE = [eds_Dev_MAD])
GO
/****** Object:  Table [MD].[AppMaster]    Script Date: 8/20/2021 4:27:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE EXTERNAL TABLE [MD].[AppMaster]
(
	[CompanyID] [int] NOT NULL,
	[AppID] [int] NOT NULL,
	[PlatformTypeID] [smallint] NOT NULL,
	[ExeName] [nvarchar](2048) NOT NULL,
	[AppName] [nvarchar](2048) NOT NULL,
	[AppVersion] [nvarchar](512) NOT NULL,
	[IsApplication] [bit] NOT NULL,
	[IsOffline] [bit] NOT NULL,
	[CurrentTimestamp] [timestamp] NULL
)
WITH (DATA_SOURCE = [eds_Dev_MAD])
GO
/****** Object:  Table [MD].[Company]    Script Date: 8/20/2021 4:27:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE EXTERNAL TABLE [MD].[Company]
(
	[CompanyID] [int] NOT NULL,
	[TenantID] [int] NOT NULL,
	[CompanyName] [nvarchar](512) NOT NULL,
	[DateCreated] [smalldatetime] NOT NULL,
	[DateActivated] [smalldatetime] NULL,
	[DateDeleted] [smalldatetime] NULL,
	[CurrentTimestamp] [timestamp] NOT NULL
)
WITH (DATA_SOURCE = [eds_Dev_MAD])
GO
/****** Object:  Table [MD].[Department]    Script Date: 8/20/2021 4:27:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE EXTERNAL TABLE [MD].[Department]
(
	[CompanyID] [int] NOT NULL,
	[DepartmentID] [int] NOT NULL,
	[DepartmentCode] [nvarchar](255) NULL,
	[DepartmentName] [nvarchar](255) NOT NULL,
	[ParentDepartmentID] [int] NULL,
	[ManagerUserID] [int] NOT NULL,
	[DateCreated] [smalldatetime] NOT NULL,
	[DateActivated] [smalldatetime] NULL,
	[DateDeleted] [smalldatetime] NULL,
	[IsActive] [bit] NOT NULL,
	[CurrentTimestamp] [timestamp] NOT NULL
)
WITH (DATA_SOURCE = [eds_Dev_MAD])
GO
/****** Object:  Table [MD].[Device]    Script Date: 8/20/2021 4:27:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE EXTERNAL TABLE [MD].[Device]
(
	[CompanyID] [int] NOT NULL,
	[DeviceID] [int] NOT NULL,
	[DeviceName] [nvarchar](512) NOT NULL,
	[DateCreated] [smalldatetime] NOT NULL,
	[DateDeleted] [smalldatetime] NULL,
	[IsActive] [bit] NOT NULL,
	[CurrentTimestamp] [timestamp] NOT NULL
)
WITH (DATA_SOURCE = [eds_Dev_MAD])
GO
/****** Object:  Table [MD].[EmployeeTitle]    Script Date: 8/20/2021 4:27:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE EXTERNAL TABLE [MD].[EmployeeTitle]
(
	[CompanyID] [int] NOT NULL,
	[EmployeeTitleID] [int] NOT NULL,
	[EmployeeTitleCode] [nvarchar](255) NOT NULL,
	[EmployeeTitle] [nvarchar](512) NOT NULL,
	[DateCreated] [smalldatetime] NOT NULL,
	[DateDeleted] [smalldatetime] NULL,
	[IsActive] [bit] NOT NULL,
	[CurrentTimestamp] [timestamp] NOT NULL
)
WITH (DATA_SOURCE = [eds_Dev_MAD])
GO
/****** Object:  Table [MD].[Location]    Script Date: 8/20/2021 4:27:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE EXTERNAL TABLE [MD].[Location]
(
	[CompanyID] [int] NOT NULL,
	[LocationID] [int] NOT NULL,
	[LocationName] [nvarchar](512) NOT NULL,
	[Country] [nvarchar](512) NOT NULL,
	[Region] [nvarchar](200) NULL,
	[State] [nvarchar](200) NULL,
	[City] [nvarchar](200) NULL,
	[CurrentTimestamp] [timestamp] NOT NULL
)
WITH (DATA_SOURCE = [eds_Dev_MAD])
GO
/****** Object:  Table [MD].[PlatformType]    Script Date: 8/20/2021 4:27:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE EXTERNAL TABLE [MD].[PlatformType]
(
	[CompanyID] [int] NOT NULL,
	[PlatformTypeID] [smallint] NOT NULL,
	[PlatformName] [nvarchar](255) NOT NULL,
	[PlatformTypeDescription] [nvarchar](512) NOT NULL,
	[DateCreated] [smalldatetime] NOT NULL,
	[CurrentTimestamp] [timestamp] NOT NULL
)
WITH (DATA_SOURCE = [eds_Dev_MAD])
GO
/****** Object:  Table [MD].[Tenant]    Script Date: 8/20/2021 4:27:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE EXTERNAL TABLE [MD].[Tenant]
(
	[TenantID] [int] NOT NULL,
	[TenantName] [nvarchar](512) NOT NULL,
	[DateCreated] [smalldatetime] NOT NULL,
	[DateActivated] [smalldatetime] NULL,
	[DateDeleted] [smalldatetime] NULL,
	[CurrentTimestamp] [timestamp] NOT NULL
)
WITH (DATA_SOURCE = [eds_Dev_MAD])
GO
/****** Object:  Table [MD].[UserDepartmentHistory]    Script Date: 8/20/2021 4:27:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE EXTERNAL TABLE [MD].[UserDepartmentHistory]
(
	[CompanyID] [int] NOT NULL,
	[DepartmentID] [int] NOT NULL,
	[UserID] [int] NOT NULL,
	[StartDate] [smalldatetime] NOT NULL,
	[EndDate] [smalldatetime] NULL,
	[IsManager] [bit] NOT NULL,
	[IsCurrent] [bit] NOT NULL
)
WITH (DATA_SOURCE = [eds_Dev_MAD])
GO
/****** Object:  Table [MD].[UserDomain]    Script Date: 8/20/2021 4:27:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE EXTERNAL TABLE [MD].[UserDomain]
(
	[CompanyID] [int] NOT NULL,
	[UserID] [int] NOT NULL,
	[DomainUserID] [nvarchar](128) NOT NULL,
	[DomainName] [nvarchar](128) NOT NULL,
	[DateDeleted] [smalldatetime] NULL,
	[IsActive] [bit] NOT NULL,
	[CurrentTimestamp] [timestamp] NOT NULL
)
WITH (DATA_SOURCE = [eds_Dev_MAD])
GO
/****** Object:  Table [MD].[Users]    Script Date: 8/20/2021 4:27:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE EXTERNAL TABLE [MD].[Users]
(
	[CompanyID] [int] NOT NULL,
	[UserID] [int] NOT NULL,
	[EmployeeCode] [nvarchar](128) NOT NULL,
	[UserEmail] [nvarchar](255) NOT NULL,
	[FirstName] [nvarchar](255) NOT NULL,
	[MiddleName] [nvarchar](255) NULL,
	[LastName] [nvarchar](255) NULL,
	[JobFamilyID] [int] NOT NULL,
	[LocationID] [int] NOT NULL,
	[ReportsToUserID] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[ModifiedBy] [int] NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[SysStartTimeUTC] [datetime2](7) NOT NULL,
	[SysEndTimeUTC] [datetime2](7) NOT NULL
)
WITH (DATA_SOURCE = [eds_Dev_MAD])
GO
/****** Object:  Table [org].[AppMetrics]    Script Date: 8/20/2021 4:27:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [org].[AppMetrics](
	[CompanyID] [int] NOT NULL,
	[AppSpecID] [int] NOT NULL,
	[WebAppSpecID] [int] NOT NULL,
	[NumberOfUsers_Short] [decimal](9, 1) NULL,
	[NumberOfUsers_Medium] [decimal](9, 1) NULL,
	[NumberOfUsers_Long] [decimal](9, 1) NULL,
	[DailyAverage_Short] [decimal](9, 2) NULL,
	[DailyAverage_Medium] [decimal](9, 2) NULL,
	[DailyAverage_Long] [decimal](9, 2) NULL,
 CONSTRAINT [pk_CompanyAppID] PRIMARY KEY CLUSTERED 
(
	[CompanyID] ASC,
	[AppSpecID] ASC,
	[WebAppSpecID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [org].[LicenseCounts]    Script Date: 8/20/2021 4:27:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [org].[LicenseCounts](
	[CompanyID] [int] NOT NULL,
	[Year] [int] NOT NULL,
	[Month] [int] NOT NULL,
	[AverageUsage] [decimal](9, 2) NOT NULL,
 CONSTRAINT [PK_LicenseCounts] PRIMARY KEY CLUSTERED 
(
	[CompanyID] ASC,
	[Year] ASC,
	[Month] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [org].[LicenseType]    Script Date: 8/20/2021 4:27:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [org].[LicenseType](
	[LicenseTypeID] [int] IDENTITY(1,1) NOT NULL,
	[LicenseTypeName] [nvarchar](500) NOT NULL,
	[LicenseTypeDescription] [nvarchar](500) NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[CreatedDateTime] [datetime2](7) NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
 CONSTRAINT [PK_LicenseType] PRIMARY KEY CLUSTERED 
(
	[LicenseTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UC_LicenseType] UNIQUE NONCLUSTERED 
(
	[LicenseTypeName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [org].[ModuleLicenseLineItem_old]    Script Date: 8/20/2021 4:27:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [org].[ModuleLicenseLineItem_old](
	[CompanyID] [int] NOT NULL,
	[ModuleLicenseLineItemID] [int] IDENTITY(1,1) NOT NULL,
	[LicenseTypeID] [int] NOT NULL,
	[Quantity] [int] NOT NULL,
	[PONumber] [nvarchar](500) NOT NULL,
	[StartDate] [datetime2](7) NOT NULL,
	[EndDate] [datetime2](7) NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[CreatedDateTime] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[flyway_schema_history] ADD  DEFAULT (getdate()) FOR [installed_on]
GO
ALTER TABLE [dbo].[flyway_schema_history_devops_test] ADD  DEFAULT (getdate()) FOR [installed_on]
GO
ALTER TABLE [dbo].[flyway_schema_history_hotfix] ADD  DEFAULT (getdate()) FOR [installed_on]
GO
ALTER TABLE [dbo].[flyway_schema_history_init] ADD  DEFAULT (getdate()) FOR [installed_on]
GO
ALTER TABLE [dbo].[flyway_schema_history_integrations] ADD  DEFAULT (getdate()) FOR [installed_on]
GO
ALTER TABLE [dbo].[flyway_schema_history_reports] ADD  DEFAULT (getdate()) FOR [installed_on]
GO
ALTER TABLE [dbo].[flyway_schema_history_reports_hotfix] ADD  DEFAULT (getdate()) FOR [installed_on]
GO
ALTER TABLE [dbo].[ImportActivityCategory] ADD  CONSTRAINT [DF_ImportActivityCategory_PushedInMaster]  DEFAULT ((0)) FOR [PushedInMaster]
GO
ALTER TABLE [dbo].[ImportActivityCategory] ADD  CONSTRAINT [DF_ImportActivityCategory_DateUploaded]  DEFAULT (getutcdate()) FOR [DateUploaded]
GO
ALTER TABLE [dbo].[ImportAddDomain] ADD  DEFAULT ((0)) FOR [PushedInMaster]
GO
ALTER TABLE [dbo].[ImportAddDomain] ADD  DEFAULT (getutcdate()) FOR [DateUploaded]
GO
ALTER TABLE [dbo].[ImportAppActivityCategory] ADD  CONSTRAINT [DF_ImportAppActivityCategory_PushedInMaster]  DEFAULT ((0)) FOR [PushedInMaster]
GO
ALTER TABLE [dbo].[ImportAppActivityCategory] ADD  CONSTRAINT [DF_ImportAppActivityCategory_DateUploaded]  DEFAULT (getutcdate()) FOR [DateUploaded]
GO
ALTER TABLE [dbo].[ImportDepartment] ADD  CONSTRAINT [DF_ImportDepartment_PushedInMaster]  DEFAULT ((0)) FOR [PushedInMaster]
GO
ALTER TABLE [dbo].[ImportDepartment] ADD  CONSTRAINT [DF_ImportDepartment_DateUploaded]  DEFAULT (getutcdate()) FOR [DateUploaded]
GO
ALTER TABLE [dbo].[ImportEmployeeTitle] ADD  CONSTRAINT [DF_ImportEmployeeTitle_PushedInMaster]  DEFAULT ((0)) FOR [PushedInMaster]
GO
ALTER TABLE [dbo].[ImportEmployeeTitle] ADD  CONSTRAINT [DF_ImportEmployeeTitle_DateUploaded]  DEFAULT (getutcdate()) FOR [DateUploaded]
GO
ALTER TABLE [dbo].[ImportLocation] ADD  CONSTRAINT [DF_ImportLocation_PushedInMaster]  DEFAULT ((0)) FOR [PushedInMaster]
GO
ALTER TABLE [dbo].[ImportLocation] ADD  CONSTRAINT [DF_ImportLocation_DateUploaded]  DEFAULT (getutcdate()) FOR [DateUploaded]
GO
ALTER TABLE [dbo].[ImportmultipleDomain] ADD  DEFAULT ((1)) FOR [PushedInMaster]
GO
ALTER TABLE [dbo].[ImportUserDepartment] ADD  CONSTRAINT [DF_ImportUserDepartment_IsManager]  DEFAULT ((0)) FOR [IsManager]
GO
ALTER TABLE [dbo].[ImportUserDepartment] ADD  CONSTRAINT [DF_ImportUserDepartment_PushedInMaster]  DEFAULT ((0)) FOR [PushedInMaster]
GO
ALTER TABLE [dbo].[ImportUserDepartment] ADD  CONSTRAINT [DF_ImportUserDepartment_DateUploaded]  DEFAULT (getutcdate()) FOR [DateUploaded]
GO
ALTER TABLE [dbo].[ImportUserJobFamily] ADD  CONSTRAINT [DF_ImportUserJobFamily_PushedInMaster]  DEFAULT ((0)) FOR [PushedInMaster]
GO
ALTER TABLE [dbo].[ImportUserJobFamily] ADD  CONSTRAINT [DF_ImportUserJobFamily_DateUploaded]  DEFAULT (getutcdate()) FOR [DateUploaded]
GO
ALTER TABLE [dbo].[ImportUsers] ADD  CONSTRAINT [DF_ImportUsers_PushedInMaster]  DEFAULT ((0)) FOR [PushedInMaster]
GO
ALTER TABLE [dbo].[ImportUsers] ADD  CONSTRAINT [DF_ImportUsers_DateUploaded]  DEFAULT (getutcdate()) FOR [DateUploaded]
GO
ALTER TABLE [dbo].[ImportWebAppActivityCategory] ADD  DEFAULT ((3)) FOR [UrlMatchStrategy]
GO
ALTER TABLE [dbo].[ImportWebAppActivityCategory] ADD  CONSTRAINT [DF_ImportWebAppActivityCategory_PushedInMaster]  DEFAULT ((0)) FOR [PushedInMaster]
GO
ALTER TABLE [dbo].[ImportWebAppActivityCategory] ADD  CONSTRAINT [DF_ImportWebAppActivityCategory_DateUploaded]  DEFAULT (getutcdate()) FOR [DateUploaded]
GO
ALTER TABLE [dbo].[Versions] ADD  DEFAULT (getutcdate()) FOR [ModifiedOn]
GO
ALTER TABLE [org].[ActivitySpec] ADD  CONSTRAINT [DF_ActivitySpec_IsCore]  DEFAULT ((0)) FOR [IsCore]
GO
ALTER TABLE [org].[ActivitySpec] ADD  CONSTRAINT [DF_ActivitySpec_IsSystemDefined]  DEFAULT ((0)) FOR [IsSystemDefined]
GO
ALTER TABLE [org].[ActivitySpec] ADD  CONSTRAINT [DF_ActivitySpec_IsWorkCategory]  DEFAULT ((0)) FOR [IsWorkCategory]
GO
ALTER TABLE [org].[ActivitySpec] ADD  CONSTRAINT [DF_ActivitySpec_IsDefault]  DEFAULT ((0)) FOR [IsDefault]
GO
ALTER TABLE [org].[ActivitySpec] ADD  CONSTRAINT [DF_ActivitySpec_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [org].[ActivitySpec] ADD  DEFAULT ('System') FOR [ModifiedBy]
GO
ALTER TABLE [org].[ActivitySpec] ADD  CONSTRAINT [DF_ActivitySpec_SysStartTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysStartTimeUTC]
GO
ALTER TABLE [org].[ActivitySpec] ADD  CONSTRAINT [DF_ActivitySpe_SysEndTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysEndTimeUTC]
GO
ALTER TABLE [org].[ActivitySpec] ADD  CONSTRAINT [DF_ActivitySpec_IsEditable]  DEFAULT ((1)) FOR [IsEditable]
GO
ALTER TABLE [org].[ApplicationSettings] ADD  DEFAULT ((0)) FOR [IsAnonymousMode]
GO
ALTER TABLE [org].[ApplicationSettings] ADD  DEFAULT ((25)) FOR [AnonymousModeDeptSizeLimit]
GO
ALTER TABLE [org].[ApplicationSettings] ADD  DEFAULT ((1)) FOR [IsUnaccountedTimeEditable]
GO
ALTER TABLE [org].[ApplicationSettings] ADD  DEFAULT ('System') FOR [ModifiedBy]
GO
ALTER TABLE [org].[ApplicationSettings] ADD  CONSTRAINT [DF_ApplicationSettings_SysStartTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysStartTimeUTC]
GO
ALTER TABLE [org].[ApplicationSettings] ADD  CONSTRAINT [DF_ApplicationSettings_SysEndTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysEndTimeUTC]
GO
ALTER TABLE [org].[AppSpec] ADD  CONSTRAINT [DF_AppSpec_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [org].[AppSpec] ADD  DEFAULT ('System') FOR [ModifiedBy]
GO
ALTER TABLE [org].[AppSpec] ADD  CONSTRAINT [DF_AppSpec_SysStartTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysStartTimeUTC]
GO
ALTER TABLE [org].[AppSpec] ADD  CONSTRAINT [DF_AppSpec_SysEndTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysEndTimeUTC]
GO
ALTER TABLE [org].[AppSpec] ADD  DEFAULT ((1)) FOR [MergePriority]
GO
ALTER TABLE [org].[AppSpecPlatform] ADD  DEFAULT ('NA') FOR [AppVersion]
GO
ALTER TABLE [org].[AppSpecPlatform] ADD  DEFAULT ((0)) FOR [IsSystemDiscovered]
GO
ALTER TABLE [org].[AppSpecPlatform] ADD  DEFAULT ('System') FOR [ModifiedBy]
GO
ALTER TABLE [org].[AppSpecPlatform] ADD  CONSTRAINT [DF_AppSpecPlatform_SysStartTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysStartTimeUTC]
GO
ALTER TABLE [org].[AppSpecPlatform] ADD  CONSTRAINT [DF_AppSpecPlatform_SysEndTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysEndTimeUTC]
GO
ALTER TABLE [org].[Company] ADD  CONSTRAINT [DF_Company_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [org].[Company] ADD  CONSTRAINT [DF_Company_SysStartTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysStartTimeUTC]
GO
ALTER TABLE [org].[Company] ADD  CONSTRAINT [DF_Company_SysEndTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysEndTimeUTC]
GO
ALTER TABLE [org].[CompanySettings] ADD  CONSTRAINT [DF_CompanySettings_ModifiedBy]  DEFAULT ('System') FOR [ModifiedBy]
GO
ALTER TABLE [org].[CompanySettings] ADD  CONSTRAINT [DF_CompanySettings_SysStartTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysStartTimeUTC]
GO
ALTER TABLE [org].[CompanySettings] ADD  CONSTRAINT [DF_CompanySettings_SysEndTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysEndTimeUTC]
GO
ALTER TABLE [org].[CustomField] ADD  DEFAULT ('System') FOR [ModifiedBy]
GO
ALTER TABLE [org].[CustomField] ADD  DEFAULT ((1)) FOR [IsNullable]
GO
ALTER TABLE [org].[CustomField] ADD  CONSTRAINT [DF_CustomField_SysStartTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysStartTimeUTC]
GO
ALTER TABLE [org].[CustomField] ADD  CONSTRAINT [DF_CustomField_SysEndTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysEndTimeUTC]
GO
ALTER TABLE [org].[DataType] ADD  CONSTRAINT [DF_DataType_ModifiedBy]  DEFAULT ('System') FOR [ModifiedBy]
GO
ALTER TABLE [org].[DataType] ADD  CONSTRAINT [DF_DataType_SysStartTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysStartTimeUTC]
GO
ALTER TABLE [org].[DataType] ADD  CONSTRAINT [DF_DataType_SysEndTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysEndTimeUTC]
GO
ALTER TABLE [org].[Department] ADD  DEFAULT ((0)) FOR [IsActive]
GO
ALTER TABLE [org].[Department] ADD  DEFAULT ('System') FOR [ModifiedBy]
GO
ALTER TABLE [org].[Department] ADD  CONSTRAINT [DF_Department_SysStartTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysStartTimeUTC]
GO
ALTER TABLE [org].[Department] ADD  CONSTRAINT [DF_Department_SysEndTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysEndTimeUTC]
GO
ALTER TABLE [org].[Device] ADD  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [org].[Device] ADD  DEFAULT ('System') FOR [ModifiedBy]
GO
ALTER TABLE [org].[Device] ADD  CONSTRAINT [DF_Device_SysStartTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysStartTimeUTC]
GO
ALTER TABLE [org].[Device] ADD  CONSTRAINT [DF_Device_SysEndTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysEndTimeUTC]
GO
ALTER TABLE [org].[Holiday] ADD  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [org].[Holiday] ADD  DEFAULT ('System') FOR [ModifiedBy]
GO
ALTER TABLE [org].[Holiday] ADD  CONSTRAINT [DF_Holiday_SysStartTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysStartTimeUTC]
GO
ALTER TABLE [org].[Holiday] ADD  CONSTRAINT [DF_Holiday_SysEndTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysEndTimeUTC]
GO
ALTER TABLE [org].[HolidayLocation] ADD  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [org].[HolidayLocation] ADD  DEFAULT ('System') FOR [ModifiedBy]
GO
ALTER TABLE [org].[HolidayLocation] ADD  CONSTRAINT [DF_HolidayLocation_SysStartTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysStartTimeUTC]
GO
ALTER TABLE [org].[HolidayLocation] ADD  CONSTRAINT [DF_HolidayLocation_SysEndTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysEndTimeUTC]
GO
ALTER TABLE [org].[IntegrationAppCatalog] ADD  CONSTRAINT [DF_IntegrationAppCatalog_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [org].[IntegrationAppCatalog] ADD  CONSTRAINT [DF_IntegrationAppCatalog_SysStartTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysStartTimeUTC]
GO
ALTER TABLE [org].[IntegrationAppCatalog] ADD  CONSTRAINT [DF_IntegrationAppCatalog_SysEndTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysEndTimeUTC]
GO
ALTER TABLE [org].[IntegrationAppProvision] ADD  CONSTRAINT [DF_IntegrationAppProvision_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [org].[IntegrationAppProvision] ADD  CONSTRAINT [DF_IntegrationAppProvision_SysStartTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysStartTimeUTC]
GO
ALTER TABLE [org].[IntegrationAppProvision] ADD  CONSTRAINT [DF_IntegrationAppProvision_SysEndTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysEndTimeUTC]
GO
ALTER TABLE [org].[IntegrationCompanyProvision] ADD  CONSTRAINT [DF_IntegrationCompanyProvision_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [org].[IntegrationCompanyProvision] ADD  CONSTRAINT [DF_IntegrationCompanyProvision_SysStartTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysStartTimeUTC]
GO
ALTER TABLE [org].[IntegrationCompanyProvision] ADD  CONSTRAINT [DF_IntegrationCompanyProvision_SysEndTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysEndTimeUTC]
GO
ALTER TABLE [org].[IntegrationCycleErrors] ADD  CONSTRAINT [DF_IntegrationCycleErrors_SysStartTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysStartTimeUTC]
GO
ALTER TABLE [org].[IntegrationCycleErrors] ADD  CONSTRAINT [DF_IntegrationCycleErrors_SysEndTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysEndTimeUTC]
GO
ALTER TABLE [org].[IntegrationCycleStatus] ADD  CONSTRAINT [DF_IntegrationCycleStatus_Status]  DEFAULT ((0)) FOR [Status]
GO
ALTER TABLE [org].[IntegrationCycleStatus] ADD  CONSTRAINT [DF_IntegrationCycleStatus_SysStartTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysStartTimeUTC]
GO
ALTER TABLE [org].[IntegrationCycleStatus] ADD  CONSTRAINT [DF_IntegrationCycleStatus_SysEndTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysEndTimeUTC]
GO
ALTER TABLE [org].[IntegrationProductCatalog] ADD  CONSTRAINT [DF_IntegrationProductCatalog_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [org].[IntegrationProductCatalog] ADD  CONSTRAINT [DF_IntegrationProductCatalog_SysStartTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysStartTimeUTC]
GO
ALTER TABLE [org].[IntegrationProductCatalog] ADD  CONSTRAINT [DF_IntegrationProductCatalog_SysEndTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysEndTimeUTC]
GO
ALTER TABLE [org].[IntegrationProductProvision] ADD  CONSTRAINT [DF_IntegrationProductProvision_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [org].[IntegrationProductProvision] ADD  CONSTRAINT [DF_IntegrationProductProvision_SysStartTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysStartTimeUTC]
GO
ALTER TABLE [org].[IntegrationProductProvision] ADD  CONSTRAINT [DF_IntegrationProductProvision_SysEndTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysEndTimeUTC]
GO
ALTER TABLE [org].[JobFamilyActivityOverrideProfile] ADD  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [org].[JobFamilyActivityOverrideProfile] ADD  DEFAULT ('System') FOR [ModifiedBy]
GO
ALTER TABLE [org].[JobFamilyActivityOverrideProfile] ADD  CONSTRAINT [DF_JobFamilyActivityOverrideProfile_SysStartTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysStartTimeUTC]
GO
ALTER TABLE [org].[JobFamilyActivityOverrideProfile] ADD  CONSTRAINT [DF_JobFamilyActivityOverrideProfile_SysEndTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysEndTimeUTC]
GO
ALTER TABLE [org].[JobFamilyActivitySpec] ADD  CONSTRAINT [DF_JobFamilyActivitySpec_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [org].[JobFamilyActivitySpec] ADD  DEFAULT ('System') FOR [ModifiedBy]
GO
ALTER TABLE [org].[JobFamilyActivitySpec] ADD  CONSTRAINT [DF_JobFamilyActivitySpec_SysStartTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysStartTimeUTC]
GO
ALTER TABLE [org].[JobFamilyActivitySpec] ADD  CONSTRAINT [DF_JobFamilyActivitySpec_SysEndTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysEndTimeUTC]
GO
ALTER TABLE [org].[JobFamilyAppSpecOverride] ADD  CONSTRAINT [DF_JobFamilyAppSpecOverride_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [org].[JobFamilyAppSpecOverride] ADD  DEFAULT ('System') FOR [ModifiedBy]
GO
ALTER TABLE [org].[JobFamilyAppSpecOverride] ADD  CONSTRAINT [DF_JobFamilyAppSpecOverride_SysStartTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysStartTimeUTC]
GO
ALTER TABLE [org].[JobFamilyAppSpecOverride] ADD  CONSTRAINT [DF_JobFamilyAppSpecOverride_SysEndTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysEndTimeUTC]
GO
ALTER TABLE [org].[JobFamilyWebAppSpecOverride] ADD  CONSTRAINT [DF_JobFamilyWebAppSpecOverride_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [org].[JobFamilyWebAppSpecOverride] ADD  DEFAULT ('System') FOR [ModifiedBy]
GO
ALTER TABLE [org].[JobFamilyWebAppSpecOverride] ADD  CONSTRAINT [DF_JobFamilyWebAppSpecOverride_SysStartTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysStartTimeUTC]
GO
ALTER TABLE [org].[JobFamilyWebAppSpecOverride] ADD  CONSTRAINT [DF_JobFamilyWebAppSpecOverride_SysEndTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysEndTimeUTC]
GO
ALTER TABLE [org].[LicenseType] ADD  CONSTRAINT [DF_LicenseType_ModifiedBy]  DEFAULT ('System') FOR [ModifiedBy]
GO
ALTER TABLE [org].[LicenseType] ADD  CONSTRAINT [DF_LicenseType_CreatedDateTime]  DEFAULT (sysutcdatetime()) FOR [CreatedDateTime]
GO
ALTER TABLE [org].[Location] ADD  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [org].[Location] ADD  DEFAULT ('System') FOR [ModifiedBy]
GO
ALTER TABLE [org].[Location] ADD  CONSTRAINT [DF_Location_SysStartTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysStartTimeUTC]
GO
ALTER TABLE [org].[Location] ADD  CONSTRAINT [DF_Location_SysEndTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysEndTimeUTC]
GO
ALTER TABLE [org].[ModuleLicenseLineItem] ADD  CONSTRAINT [DF_ModuleLicenseLineItem_ModifiedBy]  DEFAULT ('System') FOR [ModifiedBy]
GO
ALTER TABLE [org].[ModuleLicenseLineItem] ADD  CONSTRAINT [DF_ModuleLicenseLineItem_SysStartTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysStartTimeUTC]
GO
ALTER TABLE [org].[ModuleLicenseLineItem] ADD  CONSTRAINT [DF_ModuleLicenseLineItem_SysEndTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysEndTimeUTC]
GO
ALTER TABLE [org].[Permission] ADD  CONSTRAINT [DF_Permission_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [org].[Permission] ADD  DEFAULT ('System') FOR [ModifiedBy]
GO
ALTER TABLE [org].[Permission] ADD  CONSTRAINT [DF_Permission_SysStartTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysStartTimeUTC]
GO
ALTER TABLE [org].[Permission] ADD  CONSTRAINT [DF_Permission_SysEndTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysEndTimeUTC]
GO
ALTER TABLE [org].[Platform] ADD  CONSTRAINT [DF_Platform_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [org].[Platform] ADD  DEFAULT ('System') FOR [ModifiedBy]
GO
ALTER TABLE [org].[Platform] ADD  CONSTRAINT [DF_PlatformType_SysStartTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysStartTimeUTC]
GO
ALTER TABLE [org].[Platform] ADD  CONSTRAINT [DF_PlatformType_SysEndTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysEndTimeUTC]
GO
ALTER TABLE [org].[ReportCatalogExclusive] ADD  CONSTRAINT [DF_ReportCatalogExclusive_IsAvailable]  DEFAULT ((1)) FOR [IsAvailable]
GO
ALTER TABLE [org].[ReportCatalogExclusive] ADD  CONSTRAINT [DF_ReportCatalogExclusive_ModifiedBy]  DEFAULT ('System') FOR [ModifiedBy]
GO
ALTER TABLE [org].[ReportCatalogExclusive] ADD  CONSTRAINT [DF_ReportCatalogExclusive_SysStartTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysStartTimeUTC]
GO
ALTER TABLE [org].[ReportCatalogExclusive] ADD  CONSTRAINT [DF_ReportCatalogExclusive_SysEndTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysEndTimeUTC]
GO
ALTER TABLE [org].[ReportCatalogGeneral] ADD  CONSTRAINT [DF_ReportCatalogGeneral_IsActive]  DEFAULT ((0)) FOR [IsActive]
GO
ALTER TABLE [org].[ReportCatalogGeneral] ADD  CONSTRAINT [DF_ReportCatalogGeneral_PublishedDate]  DEFAULT (getutcdate()) FOR [PublishedDate]
GO
ALTER TABLE [org].[ReportCatalogGeneral] ADD  CONSTRAINT [DF_ReportCatalogGeneral_ModifiedBy]  DEFAULT ('System') FOR [ModifiedBy]
GO
ALTER TABLE [org].[ReportCatalogGeneral] ADD  CONSTRAINT [DF_ReportCatalogGeneral_SysStartTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysStartTimeUTC]
GO
ALTER TABLE [org].[ReportCatalogGeneral] ADD  CONSTRAINT [DF_ReportCatalogGeneral_SysEndTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysEndTimeUTC]
GO
ALTER TABLE [org].[ReportCategory] ADD  CONSTRAINT [DF_ReportCategory_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [org].[ReportCategory] ADD  CONSTRAINT [DF_ReportCategory_ModifiedBy]  DEFAULT ('System') FOR [ModifiedBy]
GO
ALTER TABLE [org].[ReportCategory] ADD  CONSTRAINT [DF_ReportCategory_SysStartTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysStartTimeUTC]
GO
ALTER TABLE [org].[ReportCategory] ADD  CONSTRAINT [DF_ReportCategory_SysEndTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysEndTimeUTC]
GO
ALTER TABLE [org].[ReportUserFavorites] ADD  CONSTRAINT [DF_ReportUserFavorites_ModifiedBy]  DEFAULT ('System') FOR [ModifiedBy]
GO
ALTER TABLE [org].[ReportUserFavorites] ADD  CONSTRAINT [DF_ReportUserFavorites_SysStartTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysStartTimeUTC]
GO
ALTER TABLE [org].[ReportUserFavorites] ADD  CONSTRAINT [DF_ReportUserFavorites_SysEndTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysEndTimeUTC]
GO
ALTER TABLE [org].[Settings] ADD  CONSTRAINT [DF_Settings_IsVisible]  DEFAULT ((1)) FOR [IsVisible]
GO
ALTER TABLE [org].[Settings] ADD  CONSTRAINT [DF_Settings_IsReadOnly]  DEFAULT ((0)) FOR [IsReadOnly]
GO
ALTER TABLE [org].[Settings] ADD  CONSTRAINT [DF_Settings_ModifiedBy]  DEFAULT ('System') FOR [ModifiedBy]
GO
ALTER TABLE [org].[Settings] ADD  CONSTRAINT [DF_Settings_SysStartTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysStartTimeUTC]
GO
ALTER TABLE [org].[Settings] ADD  CONSTRAINT [DF_Settings_SysEndTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysEndTimeUTC]
GO
ALTER TABLE [org].[SettingsCategory] ADD  CONSTRAINT [DF_SettingsCategory_IsVisible]  DEFAULT ((1)) FOR [IsVisible]
GO
ALTER TABLE [org].[SettingsCategory] ADD  CONSTRAINT [DF_SettingsCategory_IsReadOnly]  DEFAULT ((0)) FOR [IsReadOnly]
GO
ALTER TABLE [org].[SettingsCategory] ADD  CONSTRAINT [DF_SettingsCategory_ModifiedBy]  DEFAULT ('System') FOR [ModifiedBy]
GO
ALTER TABLE [org].[SettingsCategory] ADD  CONSTRAINT [DF_SettingsCategory_SysStartTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysStartTimeUTC]
GO
ALTER TABLE [org].[SettingsCategory] ADD  CONSTRAINT [DF_SettingsCategory_SysEndTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysEndTimeUTC]
GO
ALTER TABLE [org].[Team] ADD  DEFAULT ('System') FOR [ModifiedBy]
GO
ALTER TABLE [org].[Team] ADD  CONSTRAINT [DF_Team_SysStartTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysStartTimeUTC]
GO
ALTER TABLE [org].[Team] ADD  CONSTRAINT [DF_Team_SysEndTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysEndTimeUTC]
GO
ALTER TABLE [org].[Tenant] ADD  CONSTRAINT [DF_Tenant_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [org].[Tenant] ADD  DEFAULT ('System') FOR [ModifiedBy]
GO
ALTER TABLE [org].[Tenant] ADD  CONSTRAINT [DF_Tenant_SysStartTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysStartTimeUTC]
GO
ALTER TABLE [org].[Tenant] ADD  CONSTRAINT [DF_Tenant_SysEndTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysEndTimeUTC]
GO
ALTER TABLE [org].[TestFlyway] ADD  CONSTRAINT [TestFlyway_TestValue]  DEFAULT ((0)) FOR [TestValue]
GO
ALTER TABLE [org].[UserActivityOverrideProfile] ADD  CONSTRAINT [DF_UserActivityOverrideProfile_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [org].[UserActivityOverrideProfile] ADD  DEFAULT ('System') FOR [ModifiedBy]
GO
ALTER TABLE [org].[UserActivityOverrideProfile] ADD  CONSTRAINT [DF_UserActivityOverrideProfile_SysStartTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysStartTimeUTC]
GO
ALTER TABLE [org].[UserActivityOverrideProfile] ADD  CONSTRAINT [DF_UserActivityOverrideProfile_SysEndTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysEndTimeUTC]
GO
ALTER TABLE [org].[UserAppSpecOverride] ADD  CONSTRAINT [DF_UserAppSpecOverride_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [org].[UserAppSpecOverride] ADD  DEFAULT ('System') FOR [ModifiedBy]
GO
ALTER TABLE [org].[UserAppSpecOverride] ADD  CONSTRAINT [DF_UserAppSpecOverride_SysStartTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysStartTimeUTC]
GO
ALTER TABLE [org].[UserAppSpecOverride] ADD  CONSTRAINT [DF_UserAppSpecOverride_SysEndTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysEndTimeUTC]
GO
ALTER TABLE [org].[UserCustomField] ADD  DEFAULT ('System') FOR [ModifiedBy]
GO
ALTER TABLE [org].[UserCustomField] ADD  CONSTRAINT [DF_UserCustomField_SysStartTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysStartTimeUTC]
GO
ALTER TABLE [org].[UserCustomField] ADD  CONSTRAINT [DF_UserCustomField_SysEndTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysEndTimeUTC]
GO
ALTER TABLE [org].[UserDevice] ADD  DEFAULT ('System') FOR [ModifiedBy]
GO
ALTER TABLE [org].[UserDevice] ADD  CONSTRAINT [DF_UserDevice_SysStartTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysStartTimeUTC]
GO
ALTER TABLE [org].[UserDevice] ADD  CONSTRAINT [DF_UserDevice_SysEndTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysEndTimeUTC]
GO
ALTER TABLE [org].[UserDomain] ADD  DEFAULT ('System') FOR [ModifiedBy]
GO
ALTER TABLE [org].[UserDomain] ADD  CONSTRAINT [DF_UserDomain_SysStartTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysStartTimeUTC]
GO
ALTER TABLE [org].[UserDomain] ADD  CONSTRAINT [DF_UserDomain_SysEndTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysEndTimeUTC]
GO
ALTER TABLE [org].[UserEmail] ADD  DEFAULT ('System') FOR [ModifiedBy]
GO
ALTER TABLE [org].[UserEmail] ADD  CONSTRAINT [DF_UserEmail_SysStartTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysStartTimeUTC]
GO
ALTER TABLE [org].[UserEmail] ADD  CONSTRAINT [DF_UserEmail_SysEndTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysEndTimeUTC]
GO
ALTER TABLE [org].[UserPermission] ADD  DEFAULT ('System') FOR [ModifiedBy]
GO
ALTER TABLE [org].[UserPermission] ADD  CONSTRAINT [DF_UserPermissions_SysStartTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysStartTimeUTC]
GO
ALTER TABLE [org].[UserPermission] ADD  CONSTRAINT [DF_UserPermissions_SysEndTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysEndTimeUTC]
GO
ALTER TABLE [org].[UserProvisionState] ADD  DEFAULT ((0)) FOR [State]
GO
ALTER TABLE [org].[Users] ADD  DEFAULT ((1)) FOR [IsFullTimeEmployee]
GO
ALTER TABLE [org].[Users] ADD  DEFAULT ((1)) FOR [IsActivityCollectionOn]
GO
ALTER TABLE [org].[Users] ADD  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [org].[Users] ADD  DEFAULT ('System') FOR [ModifiedBy]
GO
ALTER TABLE [org].[Users] ADD  CONSTRAINT [DF_Users_SysStartTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysStartTimeUTC]
GO
ALTER TABLE [org].[Users] ADD  CONSTRAINT [DF_Users_SysEndTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysEndTimeUTC]
GO
ALTER TABLE [org].[UserWebAppSpecOverride] ADD  CONSTRAINT [DF_UserWebAppSpecOverride_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [org].[UserWebAppSpecOverride] ADD  DEFAULT ('System') FOR [ModifiedBy]
GO
ALTER TABLE [org].[UserWebAppSpecOverride] ADD  CONSTRAINT [DF_UserWebAppSpecOverride_SysStartTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysStartTimeUTC]
GO
ALTER TABLE [org].[UserWebAppSpecOverride] ADD  CONSTRAINT [DF_UserWebAppSpecOverride_SysEndTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysEndTimeUTC]
GO
ALTER TABLE [org].[Vendor] ADD  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [org].[Vendor] ADD  DEFAULT ('System') FOR [ModifiedBy]
GO
ALTER TABLE [org].[Vendor] ADD  CONSTRAINT [DF_Vendor_SysStartTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysStartTimeUTC]
GO
ALTER TABLE [org].[Vendor] ADD  CONSTRAINT [DF_Vendor_SysEndTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysEndTimeUTC]
GO
ALTER TABLE [org].[WebAppSpec] ADD  DEFAULT ((0)) FOR [UrlMatchStrategy]
GO
ALTER TABLE [org].[WebAppSpec] ADD  DEFAULT ((1)) FOR [IsSystemDiscovered]
GO
ALTER TABLE [org].[WebAppSpec] ADD  CONSTRAINT [DF_WebAppSpec_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [org].[WebAppSpec] ADD  DEFAULT ('System') FOR [ModifiedBy]
GO
ALTER TABLE [org].[WebAppSpec] ADD  CONSTRAINT [DF_WebAppSpec_SysStartTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysStartTimeUTC]
GO
ALTER TABLE [org].[WebAppSpec] ADD  CONSTRAINT [DF_WebAppSpec_SysEndTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysEndTimeUTC]
GO
ALTER TABLE [org].[WorkSchedule] ADD  DEFAULT ((1)) FOR [IsDefault]
GO
ALTER TABLE [org].[WorkSchedule] ADD  CONSTRAINT [DF_WorkSchedule_WorkWeekTotalHours]  DEFAULT ((40.0)) FOR [WorkWeekTotalHours]
GO
ALTER TABLE [org].[WorkSchedule] ADD  DEFAULT ((0)) FOR [IsWorkWeekCustom]
GO
ALTER TABLE [org].[WorkSchedule] ADD  CONSTRAINT [DF__WorkScheduleName__ReportNonWorkDayActivityAsWork]  DEFAULT ((1)) FOR [ReportNonWorkDayActivityAsWork]
GO
ALTER TABLE [org].[WorkSchedule] ADD  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [org].[WorkSchedule] ADD  DEFAULT ('System') FOR [ModifiedBy]
GO
ALTER TABLE [org].[WorkSchedule] ADD  CONSTRAINT [DF_WorkSchedule_SysStartTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysStartTimeUTC]
GO
ALTER TABLE [org].[WorkSchedule] ADD  CONSTRAINT [DF_WorkSchedule_SysEndTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysEndTimeUTC]
GO
ALTER TABLE [org].[AppSpec]  WITH NOCHECK ADD  CONSTRAINT [FK_AppSpec_ActivitySpec] FOREIGN KEY([CompanyID], [ActivitySpecID])
REFERENCES [org].[ActivitySpec] ([CompanyID], [ActivitySpecID])
GO
ALTER TABLE [org].[AppSpec] CHECK CONSTRAINT [FK_AppSpec_ActivitySpec]
GO
ALTER TABLE [org].[AppSpecPlatform]  WITH NOCHECK ADD  CONSTRAINT [FK_AppSpecPlatform_AppSpec] FOREIGN KEY([CompanyID], [AppSpecID])
REFERENCES [org].[AppSpec] ([CompanyID], [AppSpecID])
GO
ALTER TABLE [org].[AppSpecPlatform] CHECK CONSTRAINT [FK_AppSpecPlatform_AppSpec]
GO
ALTER TABLE [org].[AppSpecPlatform]  WITH NOCHECK ADD  CONSTRAINT [FK_AppSpecPlatform_PlatformSpec] FOREIGN KEY([CompanyID], [PlatformID])
REFERENCES [org].[Platform] ([CompanyID], [PlatformID])
GO
ALTER TABLE [org].[AppSpecPlatform] CHECK CONSTRAINT [FK_AppSpecPlatform_PlatformSpec]
GO
ALTER TABLE [org].[Company]  WITH NOCHECK ADD  CONSTRAINT [FK_Company_Tenant] FOREIGN KEY([TenantID])
REFERENCES [org].[Tenant] ([TenantID])
GO
ALTER TABLE [org].[Company] CHECK CONSTRAINT [FK_Company_Tenant]
GO
ALTER TABLE [org].[CompanySettings]  WITH NOCHECK ADD  CONSTRAINT [FK_CompanySettings_SettingID] FOREIGN KEY([SettingID])
REFERENCES [org].[Settings] ([SettingID])
GO
ALTER TABLE [org].[CompanySettings] CHECK CONSTRAINT [FK_CompanySettings_SettingID]
GO
ALTER TABLE [org].[CustomField]  WITH NOCHECK ADD  CONSTRAINT [FK_CustomField_DataTypeID] FOREIGN KEY([DataTypeID])
REFERENCES [org].[DataType] ([DataTypeID])
GO
ALTER TABLE [org].[CustomField] CHECK CONSTRAINT [FK_CustomField_DataTypeID]
GO
ALTER TABLE [org].[CustomField]  WITH NOCHECK ADD  CONSTRAINT [FK_CustomField_EnityID] FOREIGN KEY([EntityID])
REFERENCES [org].[Settings] ([SettingID])
GO
ALTER TABLE [org].[CustomField] CHECK CONSTRAINT [FK_CustomField_EnityID]
GO
ALTER TABLE [org].[DashboardChangeLog]  WITH NOCHECK ADD  CONSTRAINT [FK_DashboardChangeLog_EntitySettingID] FOREIGN KEY([EntitySettingID])
REFERENCES [org].[Settings] ([SettingID])
GO
ALTER TABLE [org].[DashboardChangeLog] CHECK CONSTRAINT [FK_DashboardChangeLog_EntitySettingID]
GO
ALTER TABLE [org].[DashboardChangeLog]  WITH NOCHECK ADD  CONSTRAINT [FK_DashboardChangeLog_PropertySettingID] FOREIGN KEY([PropertySettingID])
REFERENCES [org].[Settings] ([SettingID])
GO
ALTER TABLE [org].[DashboardChangeLog] CHECK CONSTRAINT [FK_DashboardChangeLog_PropertySettingID]
GO
ALTER TABLE [org].[Department]  WITH NOCHECK ADD  CONSTRAINT [FK_DepartmentOwner_User] FOREIGN KEY([CompanyID], [DepartmentOwnerID])
REFERENCES [org].[Users] ([CompanyID], [UserID])
GO
ALTER TABLE [org].[Department] CHECK CONSTRAINT [FK_DepartmentOwner_User]
GO
ALTER TABLE [org].[HolidayLocation]  WITH NOCHECK ADD  CONSTRAINT [FK_HolidayLocation_Holiday] FOREIGN KEY([CompanyID], [HolidayID])
REFERENCES [org].[Holiday] ([CompanyID], [HolidayID])
GO
ALTER TABLE [org].[HolidayLocation] CHECK CONSTRAINT [FK_HolidayLocation_Holiday]
GO
ALTER TABLE [org].[HolidayLocation]  WITH NOCHECK ADD  CONSTRAINT [FK_HolidayLocation_Location] FOREIGN KEY([CompanyID], [LocationID])
REFERENCES [org].[Location] ([CompanyID], [LocationID])
GO
ALTER TABLE [org].[HolidayLocation] CHECK CONSTRAINT [FK_HolidayLocation_Location]
GO
ALTER TABLE [org].[IntegrationAppCatalog]  WITH NOCHECK ADD  CONSTRAINT [FK_IntegrationAppCatalog_IntegrationProductId] FOREIGN KEY([IntegrationProductId])
REFERENCES [org].[IntegrationProductCatalog] ([IntegrationProductId])
GO
ALTER TABLE [org].[IntegrationAppCatalog] CHECK CONSTRAINT [FK_IntegrationAppCatalog_IntegrationProductId]
GO
ALTER TABLE [org].[IntegrationAppProvision]  WITH NOCHECK ADD  CONSTRAINT [FK_IntegrationAppProvision_IntegrationAppId] FOREIGN KEY([IntegrationAppId])
REFERENCES [org].[IntegrationAppCatalog] ([IntegrationAppId])
GO
ALTER TABLE [org].[IntegrationAppProvision] CHECK CONSTRAINT [FK_IntegrationAppProvision_IntegrationAppId]
GO
ALTER TABLE [org].[IntegrationProductProvision]  WITH NOCHECK ADD  CONSTRAINT [FK_IntegrationProductProvision_IntegrationProductId] FOREIGN KEY([IntegrationProductId])
REFERENCES [org].[IntegrationProductCatalog] ([IntegrationProductId])
GO
ALTER TABLE [org].[IntegrationProductProvision] CHECK CONSTRAINT [FK_IntegrationProductProvision_IntegrationProductId]
GO
ALTER TABLE [org].[JobFamilyActivitySpec]  WITH NOCHECK ADD  CONSTRAINT [FK_JobFamilyActivitySpec_ActivitySpec] FOREIGN KEY([CompanyID], [ActivitySpecID])
REFERENCES [org].[ActivitySpec] ([CompanyID], [ActivitySpecID])
GO
ALTER TABLE [org].[JobFamilyActivitySpec] CHECK CONSTRAINT [FK_JobFamilyActivitySpec_ActivitySpec]
GO
ALTER TABLE [org].[JobFamilyActivitySpec]  WITH NOCHECK ADD  CONSTRAINT [FK_JobFamilyActivitySpec_JobFamily] FOREIGN KEY([CompanyID], [JobFamilyActivityOverrideProfileID])
REFERENCES [org].[JobFamilyActivityOverrideProfile] ([CompanyID], [JobFamilyActivityOverrideProfileID])
GO
ALTER TABLE [org].[JobFamilyActivitySpec] CHECK CONSTRAINT [FK_JobFamilyActivitySpec_JobFamily]
GO
ALTER TABLE [org].[JobFamilyAppSpecOverride]  WITH NOCHECK ADD  CONSTRAINT [FK_JobFamilyAppSpecOverride_ActivitySpec] FOREIGN KEY([CompanyID], [ActivitySpecID])
REFERENCES [org].[ActivitySpec] ([CompanyID], [ActivitySpecID])
GO
ALTER TABLE [org].[JobFamilyAppSpecOverride] CHECK CONSTRAINT [FK_JobFamilyAppSpecOverride_ActivitySpec]
GO
ALTER TABLE [org].[JobFamilyAppSpecOverride]  WITH NOCHECK ADD  CONSTRAINT [FK_JobFamilyAppSpecOverride_AppSpec] FOREIGN KEY([CompanyID], [AppSpecID])
REFERENCES [org].[AppSpec] ([CompanyID], [AppSpecID])
GO
ALTER TABLE [org].[JobFamilyAppSpecOverride] CHECK CONSTRAINT [FK_JobFamilyAppSpecOverride_AppSpec]
GO
ALTER TABLE [org].[JobFamilyAppSpecOverride]  WITH NOCHECK ADD  CONSTRAINT [FK_JobFamilyAppSpecOverride_JobFamilyAppSpecOverrideProfile] FOREIGN KEY([CompanyID], [JobFamilyActivityOverrideProfileID])
REFERENCES [org].[JobFamilyActivityOverrideProfile] ([CompanyID], [JobFamilyActivityOverrideProfileID])
GO
ALTER TABLE [org].[JobFamilyAppSpecOverride] CHECK CONSTRAINT [FK_JobFamilyAppSpecOverride_JobFamilyAppSpecOverrideProfile]
GO
ALTER TABLE [org].[JobFamilyWebAppSpecOverride]  WITH NOCHECK ADD  CONSTRAINT [FK_JobFamilyWebAppSpecOverride_ActivitySpec] FOREIGN KEY([CompanyID], [ActivitySpecID])
REFERENCES [org].[ActivitySpec] ([CompanyID], [ActivitySpecID])
GO
ALTER TABLE [org].[JobFamilyWebAppSpecOverride] CHECK CONSTRAINT [FK_JobFamilyWebAppSpecOverride_ActivitySpec]
GO
ALTER TABLE [org].[JobFamilyWebAppSpecOverride]  WITH NOCHECK ADD  CONSTRAINT [FK_JobFamilyWebAppSpecOverride_JobFamilyWebAppSpecOverrideProfile] FOREIGN KEY([CompanyID], [JobFamilyActivityOverrideProfileID])
REFERENCES [org].[JobFamilyActivityOverrideProfile] ([CompanyID], [JobFamilyActivityOverrideProfileID])
GO
ALTER TABLE [org].[JobFamilyWebAppSpecOverride] CHECK CONSTRAINT [FK_JobFamilyWebAppSpecOverride_JobFamilyWebAppSpecOverrideProfile]
GO
ALTER TABLE [org].[JobFamilyWebAppSpecOverride]  WITH NOCHECK ADD  CONSTRAINT [FK_JobFamilyWebAppSpecOverride_WebAppSpec] FOREIGN KEY([CompanyID], [WebAppSpecID])
REFERENCES [org].[WebAppSpec] ([CompanyID], [WebAppSpecID])
GO
ALTER TABLE [org].[JobFamilyWebAppSpecOverride] CHECK CONSTRAINT [FK_JobFamilyWebAppSpecOverride_WebAppSpec]
GO
ALTER TABLE [org].[ModuleLicenseLineItem]  WITH NOCHECK ADD  CONSTRAINT [FK_ModuleLicenseLineItem_LicenseType] FOREIGN KEY([LicenseTypeID])
REFERENCES [org].[LicenseType] ([LicenseTypeID])
GO
ALTER TABLE [org].[ModuleLicenseLineItem] CHECK CONSTRAINT [FK_ModuleLicenseLineItem_LicenseType]
GO
ALTER TABLE [org].[ReportCatalogExclusive]  WITH NOCHECK ADD  CONSTRAINT [FK_ReportCatalogExclusive_ReportCatalogGeneral] FOREIGN KEY([ReportID])
REFERENCES [org].[ReportCatalogGeneral] ([ReportID])
GO
ALTER TABLE [org].[ReportCatalogExclusive] CHECK CONSTRAINT [FK_ReportCatalogExclusive_ReportCatalogGeneral]
GO
ALTER TABLE [org].[ReportCatalogGeneral]  WITH NOCHECK ADD  CONSTRAINT [FK_ReportCatalogGeneral_ReportCategory] FOREIGN KEY([ReportCategoryId])
REFERENCES [org].[ReportCategory] ([ReportCategoryID])
GO
ALTER TABLE [org].[ReportCatalogGeneral] CHECK CONSTRAINT [FK_ReportCatalogGeneral_ReportCategory]
GO
ALTER TABLE [org].[ReportUserFavorites]  WITH NOCHECK ADD  CONSTRAINT [FK_ReportUserFavorites_ReportCatalogGeneral] FOREIGN KEY([ReportId])
REFERENCES [org].[ReportCatalogGeneral] ([ReportID])
GO
ALTER TABLE [org].[ReportUserFavorites] CHECK CONSTRAINT [FK_ReportUserFavorites_ReportCatalogGeneral]
GO
ALTER TABLE [org].[ReportUserFavorites]  WITH NOCHECK ADD  CONSTRAINT [FK_ReportUserFavorites_Users] FOREIGN KEY([CompanyID], [UserID])
REFERENCES [org].[Users] ([CompanyID], [UserID])
GO
ALTER TABLE [org].[ReportUserFavorites] CHECK CONSTRAINT [FK_ReportUserFavorites_Users]
GO
ALTER TABLE [org].[Settings]  WITH NOCHECK ADD  CONSTRAINT [FK_Settings_CategoryID] FOREIGN KEY([CategoryID])
REFERENCES [org].[SettingsCategory] ([CategoryID])
GO
ALTER TABLE [org].[Settings] CHECK CONSTRAINT [FK_Settings_CategoryID]
GO
ALTER TABLE [org].[Settings]  WITH NOCHECK ADD  CONSTRAINT [FK_Settings_DataTypeID] FOREIGN KEY([DataTypeID])
REFERENCES [org].[DataType] ([DataTypeID])
GO
ALTER TABLE [org].[Settings] CHECK CONSTRAINT [FK_Settings_DataTypeID]
GO
ALTER TABLE [org].[Team]  WITH NOCHECK ADD  CONSTRAINT [FK_Team_Manager] FOREIGN KEY([CompanyID], [ManagerID])
REFERENCES [org].[Users] ([CompanyID], [UserID])
GO
ALTER TABLE [org].[Team] CHECK CONSTRAINT [FK_Team_Manager]
GO
ALTER TABLE [org].[UserAppSpecOverride]  WITH NOCHECK ADD  CONSTRAINT [FK_UserAppSpecOverride_ActivitySpec] FOREIGN KEY([CompanyID], [ActivitySpecID])
REFERENCES [org].[ActivitySpec] ([CompanyID], [ActivitySpecID])
GO
ALTER TABLE [org].[UserAppSpecOverride] CHECK CONSTRAINT [FK_UserAppSpecOverride_ActivitySpec]
GO
ALTER TABLE [org].[UserAppSpecOverride]  WITH NOCHECK ADD  CONSTRAINT [FK_UserAppSpecOverride_AppSpec] FOREIGN KEY([CompanyID], [AppSpecID])
REFERENCES [org].[AppSpec] ([CompanyID], [AppSpecID])
GO
ALTER TABLE [org].[UserAppSpecOverride] CHECK CONSTRAINT [FK_UserAppSpecOverride_AppSpec]
GO
ALTER TABLE [org].[UserAppSpecOverride]  WITH NOCHECK ADD  CONSTRAINT [FK_UserAppSpecOverride_UserActivityOverrideProfile] FOREIGN KEY([CompanyID], [UserActivityOverrideProfileID])
REFERENCES [org].[UserActivityOverrideProfile] ([CompanyID], [UserActivityOverrideProfileID])
GO
ALTER TABLE [org].[UserAppSpecOverride] CHECK CONSTRAINT [FK_UserAppSpecOverride_UserActivityOverrideProfile]
GO
ALTER TABLE [org].[UserCustomField]  WITH NOCHECK ADD  CONSTRAINT [FK_UserCustomField_CustomFieldID] FOREIGN KEY([CustomFieldID])
REFERENCES [org].[CustomField] ([CustomFieldID])
GO
ALTER TABLE [org].[UserCustomField] CHECK CONSTRAINT [FK_UserCustomField_CustomFieldID]
GO
ALTER TABLE [org].[UserCustomField]  WITH NOCHECK ADD  CONSTRAINT [FK_UserCustomField_UserID] FOREIGN KEY([CompanyID], [UserID])
REFERENCES [org].[Users] ([CompanyID], [UserID])
GO
ALTER TABLE [org].[UserCustomField] CHECK CONSTRAINT [FK_UserCustomField_UserID]
GO
ALTER TABLE [org].[UserDevice]  WITH NOCHECK ADD  CONSTRAINT [FK_DeviceUserDevice] FOREIGN KEY([CompanyID], [DeviceID])
REFERENCES [org].[Device] ([CompanyID], [DeviceID])
GO
ALTER TABLE [org].[UserDevice] CHECK CONSTRAINT [FK_DeviceUserDevice]
GO
ALTER TABLE [org].[UserDevice]  WITH NOCHECK ADD  CONSTRAINT [FK_UserDeviceUser] FOREIGN KEY([CompanyID], [UserID])
REFERENCES [org].[Users] ([CompanyID], [UserID])
ON DELETE CASCADE
GO
ALTER TABLE [org].[UserDevice] CHECK CONSTRAINT [FK_UserDeviceUser]
GO
ALTER TABLE [org].[UserDomain]  WITH NOCHECK ADD  CONSTRAINT [FK_DomainUser] FOREIGN KEY([CompanyID], [UserID])
REFERENCES [org].[Users] ([CompanyID], [UserID])
ON DELETE CASCADE
GO
ALTER TABLE [org].[UserDomain] CHECK CONSTRAINT [FK_DomainUser]
GO
ALTER TABLE [org].[UserEmail]  WITH CHECK ADD  CONSTRAINT [FK_UserEmail_Users] FOREIGN KEY([CompanyID], [UserID])
REFERENCES [org].[Users] ([CompanyID], [UserID])
GO
ALTER TABLE [org].[UserEmail] CHECK CONSTRAINT [FK_UserEmail_Users]
GO
ALTER TABLE [org].[UserPermission]  WITH NOCHECK ADD  CONSTRAINT [FK_UserPermission] FOREIGN KEY([Entity], [Permission])
REFERENCES [org].[Permission] ([Entity], [Permission])
GO
ALTER TABLE [org].[UserPermission] CHECK CONSTRAINT [FK_UserPermission]
GO
ALTER TABLE [org].[UserPermission]  WITH NOCHECK ADD  CONSTRAINT [FK_UserPermissionsUser] FOREIGN KEY([CompanyID], [UserID])
REFERENCES [org].[Users] ([CompanyID], [UserID])
ON DELETE CASCADE
GO
ALTER TABLE [org].[UserPermission] CHECK CONSTRAINT [FK_UserPermissionsUser]
GO
ALTER TABLE [org].[Users]  WITH NOCHECK ADD  CONSTRAINT [FK_User_Department] FOREIGN KEY([CompanyID], [DepartmentID])
REFERENCES [org].[Department] ([CompanyID], [DepartmentID])
GO
ALTER TABLE [org].[Users] CHECK CONSTRAINT [FK_User_Department]
GO
ALTER TABLE [org].[Users]  WITH NOCHECK ADD  CONSTRAINT [FK_User_JobFamilyActivityOverrideProfileID] FOREIGN KEY([CompanyID], [JobFamilyActivityOverrideProfileID])
REFERENCES [org].[JobFamilyActivityOverrideProfile] ([CompanyID], [JobFamilyActivityOverrideProfileID])
GO
ALTER TABLE [org].[Users] CHECK CONSTRAINT [FK_User_JobFamilyActivityOverrideProfileID]
GO
ALTER TABLE [org].[Users]  WITH NOCHECK ADD  CONSTRAINT [FK_User_Location] FOREIGN KEY([CompanyID], [LocationID])
REFERENCES [org].[Location] ([CompanyID], [LocationID])
GO
ALTER TABLE [org].[Users] CHECK CONSTRAINT [FK_User_Location]
GO
ALTER TABLE [org].[Users]  WITH NOCHECK ADD  CONSTRAINT [FK_User_Team] FOREIGN KEY([CompanyID], [TeamID])
REFERENCES [org].[Team] ([CompanyID], [TeamID])
GO
ALTER TABLE [org].[Users] CHECK CONSTRAINT [FK_User_Team]
GO
ALTER TABLE [org].[Users]  WITH NOCHECK ADD  CONSTRAINT [FK_User_UserActivityOverrideProfile] FOREIGN KEY([CompanyID], [UserActivityOverrideProfileID])
REFERENCES [org].[UserActivityOverrideProfile] ([CompanyID], [UserActivityOverrideProfileID])
GO
ALTER TABLE [org].[Users] CHECK CONSTRAINT [FK_User_UserActivityOverrideProfile]
GO
ALTER TABLE [org].[Users]  WITH NOCHECK ADD  CONSTRAINT [FK_User_Vendor] FOREIGN KEY([CompanyID], [VendorID])
REFERENCES [org].[Vendor] ([CompanyID], [VendorID])
GO
ALTER TABLE [org].[Users] CHECK CONSTRAINT [FK_User_Vendor]
GO
ALTER TABLE [org].[Users]  WITH NOCHECK ADD  CONSTRAINT [FK_User_WorkSchedule] FOREIGN KEY([CompanyID], [WorkScheduleID])
REFERENCES [org].[WorkSchedule] ([CompanyID], [WorkScheduleID])
GO
ALTER TABLE [org].[Users] CHECK CONSTRAINT [FK_User_WorkSchedule]
GO
ALTER TABLE [org].[UserWebAppSpecOverride]  WITH NOCHECK ADD  CONSTRAINT [FK_UserWebAppSpecOverride_ActivitySpec] FOREIGN KEY([CompanyID], [ActivitySpecID])
REFERENCES [org].[ActivitySpec] ([CompanyID], [ActivitySpecID])
GO
ALTER TABLE [org].[UserWebAppSpecOverride] CHECK CONSTRAINT [FK_UserWebAppSpecOverride_ActivitySpec]
GO
ALTER TABLE [org].[UserWebAppSpecOverride]  WITH NOCHECK ADD  CONSTRAINT [FK_UserWebAppSpecOverride_UserActivityOverrideProfile] FOREIGN KEY([CompanyID], [UserActivityOverrideProfileID])
REFERENCES [org].[UserActivityOverrideProfile] ([CompanyID], [UserActivityOverrideProfileID])
GO
ALTER TABLE [org].[UserWebAppSpecOverride] CHECK CONSTRAINT [FK_UserWebAppSpecOverride_UserActivityOverrideProfile]
GO
ALTER TABLE [org].[UserWebAppSpecOverride]  WITH NOCHECK ADD  CONSTRAINT [FK_UserWebAppSpecOverride_WebAppSpec] FOREIGN KEY([CompanyID], [WebAppSpecID])
REFERENCES [org].[WebAppSpec] ([CompanyID], [WebAppSpecID])
GO
ALTER TABLE [org].[UserWebAppSpecOverride] CHECK CONSTRAINT [FK_UserWebAppSpecOverride_WebAppSpec]
GO
ALTER TABLE [org].[WebAppSpec]  WITH NOCHECK ADD  CONSTRAINT [FK_WebAppSpec_ActivitySpec] FOREIGN KEY([CompanyID], [ActivitySpecID])
REFERENCES [org].[ActivitySpec] ([CompanyID], [ActivitySpecID])
GO
ALTER TABLE [org].[WebAppSpec] CHECK CONSTRAINT [FK_WebAppSpec_ActivitySpec]
GO
ALTER TABLE [org].[ActivitySpec]  WITH NOCHECK ADD  CONSTRAINT [CK_ActivitySpecName_Empty] CHECK  ((len(Trim([ActivitySpecName]))>(0)))
GO
ALTER TABLE [org].[ActivitySpec] CHECK CONSTRAINT [CK_ActivitySpecName_Empty]
GO
ALTER TABLE [org].[AppSpec]  WITH NOCHECK ADD  CONSTRAINT [CK_AppSpec_AppDisplayName_Empty] CHECK  ((len(Trim([AppDisplayName]))>(0)))
GO
ALTER TABLE [org].[AppSpec] CHECK CONSTRAINT [CK_AppSpec_AppDisplayName_Empty]
GO
ALTER TABLE [org].[AppSpec]  WITH NOCHECK ADD  CONSTRAINT [CK_AppSpec_AppExeName_Empty] CHECK  ((len(Trim([AppExeName]))>(0)))
GO
ALTER TABLE [org].[AppSpec] CHECK CONSTRAINT [CK_AppSpec_AppExeName_Empty]
GO
ALTER TABLE [org].[Company]  WITH NOCHECK ADD  CONSTRAINT [Check_Blank_Company_CompanyName] CHECK  ((len(Trim([CompanyName]))>(0)))
GO
ALTER TABLE [org].[Company] CHECK CONSTRAINT [Check_Blank_Company_CompanyName]
GO
ALTER TABLE [org].[Holiday]  WITH NOCHECK ADD  CONSTRAINT [Check_Blank_HolidayName] CHECK  ((len(Trim([HolidayName]))>(0)))
GO
ALTER TABLE [org].[Holiday] CHECK CONSTRAINT [Check_Blank_HolidayName]
GO
ALTER TABLE [org].[Tenant]  WITH NOCHECK ADD  CONSTRAINT [Check_Blank_TenantName] CHECK  ((len(Trim([TenantName]))>(0)))
GO
ALTER TABLE [org].[Tenant] CHECK CONSTRAINT [Check_Blank_TenantName]
GO
ALTER TABLE [org].[WebAppSpec]  WITH NOCHECK ADD  CONSTRAINT [CK_Blank_WebAppSpec_WebAppDisplayName] CHECK  ((len(Trim([WebAppDisplayName]))>(0)))
GO
ALTER TABLE [org].[WebAppSpec] CHECK CONSTRAINT [CK_Blank_WebAppSpec_WebAppDisplayName]
GO
ALTER TABLE [org].[WebAppSpec]  WITH NOCHECK ADD  CONSTRAINT [CK_Blank_WebAppSpec_WebAppName] CHECK  ((len(Trim([WebAppName]))>(0)))
GO
ALTER TABLE [org].[WebAppSpec] CHECK CONSTRAINT [CK_Blank_WebAppSpec_WebAppName]
GO
ALTER TABLE [org].[WebAppSpec]  WITH NOCHECK ADD  CONSTRAINT [CK_Blank_WebAppSpec_WebAppUrl] CHECK  ((len(Trim([WebAppUrl]))>(0)))
GO
ALTER TABLE [org].[WebAppSpec] CHECK CONSTRAINT [CK_Blank_WebAppSpec_WebAppUrl]
GO
ALTER TABLE [org].[WorkSchedule]  WITH NOCHECK ADD  CONSTRAINT [CK_StartTime_EndTime_Sync] CHECK  ((NOT ([ReportDataStartTime] IS NOT NULL AND [ReportDataEndTime] IS NULL)))
GO
ALTER TABLE [org].[WorkSchedule] CHECK CONSTRAINT [CK_StartTime_EndTime_Sync]
GO
ALTER TABLE [org].[WorkSchedule]  WITH NOCHECK ADD  CONSTRAINT [CK_WorkScheduleName_Empty] CHECK  ((len(Trim([WorkScheduleName]))>(0)))
GO
ALTER TABLE [org].[WorkSchedule] CHECK CONSTRAINT [CK_WorkScheduleName_Empty]
GO
/****** Object:  StoredProcedure [dbo].[BulkUpsertAppUrlMappings]    Script Date: 8/20/2021 4:27:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE      PROCEDURE [dbo].[BulkUpsertAppUrlMappings]
 
	@appUrlMappingsParm [dbo].[AppUrlMappingTableParm] READONLY,
	-- output counters
--	@activitySpecInsertCount INT OUTPUT,
    @appSpecInsertCount INT OUTPUT,
    @appSpecUpdateCount INT OUTPUT,
	@appSpecPlatformInsertCount INT OUTPUT, 
	@appSpecPlatformUpdateCount INT OUTPUT,
	@webAppSpecInsertCount INT OUTPUT,
	@webAppSpecUpdateCount INT OUTPUT
  
AS
BEGIN
    DECLARE @rowNo int  
	DECLARE @appOrUrl nvarchar(200)
	DECLARE @displayName nvarchar(100)
	DECLARE @activity nvarchar(100)	
	DECLARE @isWindows bit 
	DECLARE @isLinux bit 
	DECLARE @isMac bit 
	DECLARE @urlMatchStrategyText nvarchar(100)  
	DECLARE @urlMatchContent nvarchar(100)  
	DECLARE @modifiedBy nvarchar(100)
	
   	DECLARE @companyID int
	DECLARE @appSpecId int 
	DECLARE @webappSpecId int 	
	DECLARE @activitySpecId int
	DECLARE @appSpecPlatformId int 

	DECLARE @appUrlCount int = 0
	DECLARE @Idx int = 0

	DECLARE @rowIssues TABLE (
		RowNo int, 
		Message varchar(30)
	)

    SET NOCOUNT ON;
	
	-- load TVP into temp table for processing
	SELECT * INTO #appUrlMappings FROM @appUrlMappingsParm
	SET @appUrlCount = @@ROWCOUNT


	---------------------------------------------
	--       TRY / CATCH Transaction
	-----------------------------------------------
	BEGIN TRY  
	    BEGIN TRANSACTION Upsert;

	--	SET @activitySpecInsertCount = 0 
		SET @appSpecInsertCount = 0 
		SET @appSpecUpdateCount = 0 
		SET @appSpecPlatformInsertCount = 0 
		SET @appSpecPlatformUpdateCount = 0
		SET @webAppSpecInsertCount = 0 
		SET @webAppSpecUpdateCount = 0 

		--------------------------------------------------------
		-- Main loop
		---------------------------------------------------
		WHILE (@Idx < @appUrlCount)
		BEGIN
	
			SET @Idx = @Idx + 1

			-- Load a row into parameters
			SELECT 
				@rowNo = currRow.RowNo,
				@companyID = currRow.CompanyID,
			    @appOrUrl = currRow.AppOrUrl,
				@displayName = currRow.DisplayName,
			    @activity = currRow.Activity,
			    @isWindows = currRow.IsWindows, 
				@isLinux = currRow.IsLinux, 
				@isMac = currRow.IsMac, 
				@urlMatchStrategyText = LOWER(currRow.UrlMatchStrategy), 
				@urlMatchContent = currRow.UrlMatchContent,
				@modifiedBy = currRow.ModifiedBy	
			FROM #appUrlMappings currRow  
			WHERE RowNo = @Idx 
				
		--	PRINT 'Processing: ' + 'RowNo: ' + CAST(@rowNo as varchar) + ' Idx ' +  CAST(@Idx as varchar) + ' - ' + @appOrUrl 
         
			 --------------------------------------------------
			-- 1. Find ActivitySpec,  if not found, then track and continue loop
			--------------------------------------------
			SELECT @activitySpecId = ActivitySpecId
			FROM org.ActivitySpec 
			WHERE LTRIM(RTRIM(ActivitySpecName)) =  LTRIM(RTRIM(@activity))
         
			if (@@ROWCOUNT = 0)
			BEGIN
			    INSERT INTO @rowIssues (RowNo, Message) VALUES(@rowNo, 'Activity not found')  
				CONTINUE;
			END
		
			--------------------------------------------------
			--   2a. Upsert WebAppSpec
			--------------------------------------------
			DECLARE @urlMatchStrategy int
			IF (LOWER(LTRIM(RTRIM(@urlMatchStrategyText))) = 'domain') SET @urlMatchStrategy = 1
			IF (LOWER(LTRIM(RTRIM(@urlMatchStrategyText))) = 'starts with') SET @urlMatchStrategy = 2
			IF (LOWER(LTRIM(RTRIM(@urlMatchStrategyText))) = 'contains') SET @urlMatchStrategy = 3

			IF (@urlMatchStrategyText IS NOT NULL AND LEN(LTRIM(RTRIM(@urlMatchStrategyText))) > 0)
			BEGIN
				SELECT @webappSpecId = WebAppSpecID
				FROM org.WebAppSpec
				WHERE CompanyID = @companyID AND LOWER(WebAppUrl) = LOWER(@appOrUrl)

				-- INSERT
				IF (@@ROWCOUNT = 0)
				BEGIN
					INSERT INTO org.WebAppSpec(
						CompanyID, ActivitySpecID,
						WebAppName, WebAppDisplayName, WebAppUrl, 
						UrlMatchStrategy, UrlMatchContent,
						IsSystemDiscovered, ModifiedBy)
					VALUES(
						@companyID, @activitySpecId,
						@displayName, @displayName, @appOrUrl, 
						@urlMatchStrategy, @urlMatchContent,
						0, @modifiedBy)
											
					SELECT @webappSpecId = WebAppSpecID
					FROM org.WebAppSpec 
					WHERE CompanyID = @companyID and LOWER(WebAppUrl) = LOWER(@appOrUrl)

					SET @webAppSpecInsertCount = @webAppSpecInsertCount + 1
				END

				-- UPDATE
				ELSE
				BEGIN         
					UPDATE org.WebAppSpec WITH(HOLDLOCK) 
					SET 
						WebAppName = @displayName,
						WebAppDisplayName = @displayName,
						WebAppUrl = @appOrUrl,
						UrlMatchStrategy = @urlMatchStrategy,
						UrlMatchContent = @urlMatchContent,
						ActivitySpecID = @activitySpecId,
						ModifiedBy = @modifiedBy
 					WHERE CompanyId = @companyID AND WebAppSpecID = @webAppSpecId

					SET @webAppSpecUpdateCount = @webAppSpecUpdateCount + 1
				END		
			END
	  
		    --------------------------------------------------
			--   2b. Application - Upsert AppSpec
			--------------------------------------------
			ELSE
			BEGIN
				IF (@isWindows = 1 or @isLinux = 1 or @isMac = 1)
				BEGIN
					SELECT @appSpecId = AppSpecID
					FROM org.AppSpec 
					WHERE CompanyID = @companyID AND LOWER(AppExeName) = LOWER(@appOrUrl)

					-- INSERT
					IF (@@ROWCOUNT = 0)
					BEGIN
						INSERT INTO org.AppSpec(
							CompanyID, ActivitySpecID,
							AppExeName, AppDisplayName, 
							ModifiedBy)
						VALUES
							(@companyID, @activitySpecId,
							@appOrUrl,@displayName, 
							@modifiedBy)
											
						SELECT @appSpecId = AppSpecID
						FROM org.AppSpec 
						WHERE CompanyID = @companyID AND LOWER(AppExeName) = LOWER(@appOrUrl)

						SET @appSpecInsertCount = @appSpecInsertCount + 1
					END
					-- UPDATE
					ELSE
					BEGIN         
						UPDATE org.AppSpec WITH(HOLDLOCK) 
						SET 
							ActivitySpecID = @activitySpecId,
							AppExeName = @appOrUrl,
							AppDisplayName = @displayName,
							ModifiedBy = @modifiedBy
 						WHERE CompanyId = @companyID AND appSpecID = @appSpecId

						SET @appSpecUpdateCount = @appSpecUpdateCount + 1
					END	
				END
			
				--------------------------------------------
				--   3. AppPSec -> AppSpecPlatform 
				--------------------------------------------

				-- for upserting AppSpecPlatform
				DECLARE @windowsPlatformId int
				SELECT @windowsPlatformId = PlatformID
				FROM org.Platform 
				WHERE CompanyID = @companyID AND LTRIM(RTRIM(PlatformName)) like  '%windows%'

				DECLARE @linuxPlatformId int
				SELECT @linuxPlatformId = PlatformID
				FROM org.Platform 
				WHERE CompanyID = @companyID AND LTRIM(RTRIM(PlatformName)) like '%linux%'

				DECLARE @macPlatformId int
				SELECT @macPlatformId = PlatformID
				FROM org.Platform 
				WHERE CompanyID = @companyID AND LTRIM(RTRIM(PlatformName)) like '%mac%'

				-------- Windows ------------
				if (@isWindows = 1) 		  	
				BEGIN
					SELECT @appSpecPlatformID = AppSpecPlatformID
					FROM org.AppSpecPlatform
					WHERE CompanyID = @companyID 
						AND AppSpecID = @appSpecId
						AND PlatformID = @windowsPlatformId
				 
					IF (@@ROWCOUNT = 0)
					BEGIN
						INSERT INTO org.AppSpecPlatform(
							CompanyID, AppSpecID, PlatformID,
							AppVersion, DisplayName, 
							IsSystemDiscovered, ModifiedBy)
						VALUES
							(@companyID, @appSpecId, @windowsPlatformId,
							'NA', @displayName, 
							0, @modifiedBy)                      
					END
					ELSE
					BEGIN	
						UPDATE org.AppSpecPlatform WITH(HOLDLOCK)
						SET
							AppVersion = 'NA',
							DisplayName = @displayName,
							ModifiedBy = @modifiedBy
						WHERE CompanyID = @companyID AND AppSpecPlatformID = @appSpecPlatformId							
					END
				END    

				-------- Linux --------
				if (@isLinux = 1) 		  	
				BEGIN
					SELECT @appSpecPlatformID = AppSpecPlatformID
					FROM org.AppSpecPlatform
					WHERE CompanyID = @companyID 
						AND AppSpecID = @appSpecId
						AND PlatformID = @linuxPlatformId
				 
					IF (@@ROWCOUNT = 0)
					BEGIN
						INSERT INTO org.AppSpecPlatform(
							CompanyID, AppSpecID, PlatformID,
							AppVersion, DisplayName, 
							IsSystemDiscovered, ModifiedBy)
						VALUES
							(@companyID, @appSpecId, @linuxPlatformId,
							'NA', @displayName, 
							0, @modifiedBy)
					END
					ELSE
					BEGIN	
						UPDATE org.AppSpecPlatform
						SET
							AppVersion = 'NA',
							DisplayName = @displayName,
							ModifiedBy = @modifiedBy	
						WHERE CompanyID = @companyID AND AppSpecPlatformID = @appSpecPlatformId							
					END
				END  
				------------- Mac ---------------
				if (@isMac = 1) 		  	
				BEGIN
					SELECT @appSpecPlatformID = AppSpecPlatformID
					FROM org.AppSpecPlatform
					WHERE CompanyID = @companyID 
						AND AppSpecID = @appSpecId
						AND PlatformID = @macPlatformId
				 
					IF (@@ROWCOUNT = 0)
					BEGIN
						INSERT INTO org.AppSpecPlatform(
							CompanyID, AppSpecID, PlatformID,
							AppVersion, DisplayName, 
							IsSystemDiscovered, ModifiedBy)
						VALUES
							(@companyID, @appSpecId, @macPlatformId,
							'NA', @displayName, 
							0, @modifiedBy)
					END
					ELSE
					BEGIN	
						UPDATE org.AppSpecPlatform
						SET
							AppVersion = 'NA',
							DisplayName = @displayName,
							ModifiedBy = @modifiedBy	
						WHERE CompanyID = @companyID AND AppSpecPlatformID = @appSpecPlatformId							
					END
				END    


			END
		END; -- end loop
	    
		COMMIT TRANSACTION Upsert;
	
	select * from @rowIssues

	END TRY  
	
	BEGIN CATCH  
    -- Execute error retrieval routine.  
    -- EXECUTE usp_GetErrorInfo; 
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION Upsert;
		THROW; 
    END CATCH;		
END

GO
/****** Object:  StoredProcedure [dbo].[BulkUpsertUser2]    Script Date: 8/20/2021 4:27:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE      PROCEDURE [dbo].[BulkUpsertUser2]

	@usersParm [dbo].[UserTableParm2] READONLY,
	@integrationSource INT,
	-- output counters
	@userInsertCount INT OUTPUT,
	@userUpdateCount INT OUTPUT,
	@userDomainInsertCount INT OUTPUT,
	@userDomainDeleteCount INT OUTPUT,
    @userPermissionInsertCount INT OUTPUT,
    @userPermissionDeleteCount INT OUTPUT
	
AS
BEGIN
    DECLARE @rowNo int  
   	DECLARE @CompanyID int
	DECLARE @userID int
	DECLARE @externalUserID nvarchar(50)
	DECLARE @teamID int
	DECLARE @departmentID int
	DECLARE @jobFamilyID int
	DECLARE @vendorID int	
	DECLARE @locationID int
	DECLARE @WorkScheduleID int
	DECLARE @userEmail nvarchar(255) 
	DECLARE @firstName nvarchar(100) 
	DECLARE @lastName nvarchar(100) 
	DECLARE @jobTitle nvarchar(100) 
	DECLARE @isFullTimeEmployee bit 
	DECLARE @isActivityCollectionOn bit 
	DECLARE @isManager bit 
	DECLARE @isActive bit 
	DECLARE @modifiedBy nvarchar(100) 
	DECLARE @userDomainID1 int 
	DECLARE @userName1 nvarchar(128) 
	DECLARE @domainName1 nvarchar(128) 
    DECLARE @userDomainID2 int 
	DECLARE @userName2 nvarchar(128)  
	DECLARE @domainName2 nvarchar(128) 
	DECLARE @requiresVueAccess bit
	
	declare @UserCount int = 0
	declare @Idx int = 0
	
	-- Integration Source enum
	declare @sourceCSV int = 10
	declare @sourceAD int = 20
	-- declare @sourceWorkDay int = 30

	DECLARE @employeePermissions nvarchar(128)
	SET @employeePermissions = 'Employees:Read|Employees:Write'
	DECLARE @userPermissions nvarchar(128)
	DECLARE @pipe char(1)

	DECLARE @current_JobFamilyId int
	DECLARE @current_VendorId int
	DECLARE @current_LocationId int
	DECLARE @current_IsActivityCollectionOn bit
	DECLARE @current_IsFullTimeEmployee bit
	DECLARE @current_Jobtitle nvarchar(100)

    SET NOCOUNT ON;

	-- table to collect inserted User info 
	CREATE table #UserInsertResults(
	   CompanyID int not null,
       RowNo int not null,
	   UserID int not null,
	   UserEmail nvarchar(255) not null,   
	   FirstName nvarchar(100) not null,  
	   LastName nvarchar(100) not null,  
	   IsManager bit not null,
	   UserPermissions nvarchar(128) not null
    ); 


	SELECT * INTO #users from @usersParm
	set @UserCount = @@ROWCOUNT
			  
	BEGIN TRY  
	    BEGIN TRANSACTION Upsert;

		SET @userInsertCount = 0 
    	SET @userUpdateCount = 0 
		SET @userDomainInsertCount = 0 
		SET @userDomainDeleteCount = 0 
		SET @userPermissionInsertCount = 0 
		SET @userPermissionDeleteCount = 0 

		--------------------------------------------------------
		-- Main loop
		---------------------------------------------------
		WHILE (@Idx < @UserCount)
		BEGIN
	
			SET @Idx = @Idx + 1

			SELECT 
				@rowNo = u.RowNo,
				@companyID = u.CompanyID,
			    @userID = u.UserID,
				@teamID = u.TeamID,
				@departmentID = u.DepartmentID,
				@vendorID = u.VendorID,
				@locationID = u.LocationID,
				@jobFamilyID = u.JobFamilyActivityOverrideProfileID,
				@workScheduleID = u.WorkScheduleID,
				@userEmail = u.UserEmail,
				@firstName = u.FirstName,
				@lastName = u.LastName,
				@externalUserID = u.ExternalUserID,
				@jobTitle = u.JobTitle,
				@isActivityCollectionOn = u.IsActivityCollectionOn,
				@isFullTimeEmployee = u.IsFullTimeEmployee,
				@isManager = u.IsManager,
				@isActive = u.IsActive,
				@modifiedBy = u.ModifiedBy,
				@userName1 = u.UserName1,
				@domainName1 = u.DomainName1,
				@userName2 = u.UserName2,
				@domainName2 = u.DomainName2,
				@requiresVueAccess = u.RequiresVueAccess
			FROM #users u  
			WHERE
				u.RowNo = @Idx 
				
		--	PRINT 'Processing: ' + 'RowNo: ' + CAST(@rowNo as varchar) + ' Idx ' +  CAST(@Idx as varchar) + ' - ' + @userEmail 
			
		--------------------------------------------------
		--   1. Upsert Users
		--------------------------------------------

		--select @userID = u.UserID
		--from org.Users u
		--where CompanyID = @companyId 
		--	and Lower(UserEmail) = Lower(@userEmail)

		-- Try to select current user ID and properties that cannot be updated with null values
		(SELECT @userID = UserID, 
				@current_JobFamilyId = JobFamilyActivityOverrideProfileID, 
				@current_LocationId = LocationID,
		        @current_VendorId = VendorID,
				@current_IsFullTimeEmployee = IsFullTimeEmployee,
		        @current_IsActivityCollectionOn = IsActivityCollectionOn,
				@current_Jobtitle = JobTitle
		    FROM org.Users 
			WHERE CompanyID = @companyId 
				AND Lower(UserEmail) = Lower(@userEmail)) 

            --------------------------------------
            -- UPDATE existing user
			--------------------------------------
			if (@@ROWCOUNT > 0)  -- User exists, UPDATE
			BEGIN
		        -- for AD integration, retain current values 
			   if (@integrationSource = @sourceAD)
		       BEGIN
					set @jobFamilyID = @current_JobFamilyId
					set @vendorID = @current_VendorId
					set @isFullTimeEmployee = @current_IsFullTimeEmployee
					set @isActivityCollectionOn = @current_IsActivityCollectionOn
                    if (@jobTitle is null or LTRIM(RTRIM(@jobtitle)) = '')
					begin
						set @jobTitle = @current_JobTitle
					end
					if (@locationID is null)
					begin
						set @locationID = @current_locationId
					end
			    END
				          
				UPDATE org.Users WITH(HOLDLOCK) 
				SET 
					TeamID = @teamID,
					DepartmentID = @departmentID,
					VendorID = @vendorID,
					LocationID = @locationID,
					JobFamilyActivityOverrideProfileID = @jobFamilyID,
				--	WorkScheduleID = @workScheduleID,
					FirstName = @firstName,
					LastName = @lastName,
					ExternalUserID = @externalUserID,
					JobTitle = @jobTitle,
					IsActivityCollectionOn = @isActivityCollectionOn,
					IsFullTimeEmployee = @isFullTimeEmployee,
					ModifiedBy = @modifiedBy
				-- Upload does not yet support user status-ing 
 				--	IsActive = true
				WHERE CompanyId = @companyID AND UserID = @userID

				SET @userUpdateCount = @userUpdateCount + 1
			END

       	    --------------------------------------
            -- INSERT new user
			--------------------------------------
			ELSE
			BEGIN

			   if (@isActivityCollectionOn is null)
				begin
					set @isActivityCollectionOn = 0
				end
				
				INSERT INTO org.Users (
					CompanyID, UserEmail,
					FirstName, LastName, JobTitle, ExternalUserID,
					DepartmentID, TeamID, 
					JobFamilyActivityOverrideProfileID,
					LocationID, VendorID, WorkScheduleID,
					IsFullTimeEmployee,
					IsActivityCollectionOn,
					IsActive,
					ModifiedBy
					)
				VALUES (
					@companyID, @userEmail,
					@firstName, @lastName, @jobTitle, @externalUserID,
					@departmentID, @teamID, 
					@jobFamilyID,
					@locationID, @vendorID,	@workScheduleID,
					@isFullTimeEmployee,
					@isActivityCollectionOn,
					@isActive,
					@modifiedBy
					)

	     		SET @userInsertCount = @userInsertCount + 1

				select @userID =  UserID 
					FROM org.Users 
					WHERE CompanyID = @companyId 
						AND Lower(UserEmail) = Lower(@userEmail)

				set @userPermissions = ''
				set @pipe = ''

				IF (@integrationSource= @sourceCSV)
				BEGIN
					IF @requiresVueAccess = 1
					   BEGIN
						   set @userPermissions = @employeePermissions
						   set @pipe = '|'
					   END
					IF (@isManager = 1)
					   set @userPermissions = @userPermissions + @pipe + 'Manager:Read'
				END

				INSERT INTO #UserInsertResults
				    (RowNo, CompanyId, UserID, UserEmail, FirstName, LastName, IsManager, UserPermissions)
				VALUES
				   (@rowNo, @CompanyID, @userID, @userEmail, @firstName, @lastName, @isManager, @userPermissions)
			--	PRINT  'UserID: ' + CAST(@userID as varchar)
			END

		---------------------------------------------
		--   2. Upsert UserDomains
		--------------------------------------------
	   
		--	 print 'Deleted ' + CAST(@userDomainDeleteCount as varchar) + ' UserDomain(s)'

		 -- User Domain 1
		--	print 'UserDomain2 input: ' + CAST(@userName1 as varchar) + '/' + CAST(@domainName1 as varchar) 

		-- If user domain (domain/username) does not exist, then INSERT
		     IF LEN(RTRIM(ISNULL(@userName1, ''))) > 0  AND LEN(RTRIM(ISNULL(@domainName1, ''))) > 0
			    AND NOT EXISTS(
			        SELECT UserDomainID FROM org.UserDomain 
					WHERE CompanyID = @companyID AND UserID = @userID
						AND LOWER(UserName) = LOWER(TRIM(@userName1))
						AND LOWER(DomainName) = LOWER(TRIM(@domainName1)))
			 BEGIN
		  		INSERT INTO org.UserDomain (CompanyID, UserID, UserName, DomainName, IsActive, ModifiedBy)
				VALUES (@companyID, @userID, @userName1, @domainName1, 1, @modifiedBy)

				SET @userDomainInsertCount = @userDomainInsertCount + 1
				print 'Inserted ' + CAST(@userName1 as varchar) + '/' + CAST(@domainName1 as varchar) + 'into UserDomain(s)'
			 END

		 -- User Domain 2
		--	print 'UserDomain2 input: ' + CAST(@userName2 as varchar) + '/' + CAST(@domainName2 as varchar) 
		     IF LEN(RTRIM(ISNULL(@userName2, ''))) > 0  AND LEN(RTRIM(ISNULL(@domainName2, ''))) > 0
			    AND NOT EXISTS(
					SELECT UserDomainID FROM org.UserDomain 
					WHERE CompanyID = @companyID  AND UserID = @userID
						AND LOWER(UserName) = LOWER(TRIM(@userName2))
						AND LOWER(DomainName) = LOWER(TRIM(@domainName2)))
			 BEGIN
		  		INSERT INTO org.UserDomain (CompanyID, UserID, UserName, DomainName, IsActive, ModifiedBy)
				VALUES (@companyID, @userID, @userName2, @domainName2, 1, @modifiedBy)

				SET @userDomainInsertCount = @userDomainInsertCount + 1
				print 'Inserted ' + CAST(@userName1 as varchar) + '/' + CAST(@domainName1 as varchar) + 'into UserDomain(s)'
			 END

		--------------------------------------------
		--   3. Upsert UserPermissions
		--------------------------------------------
		   -- for now, permissions are only provisioning in CSV integrations
			if (@integrationSource = @sourceCSV)
			BEGIN
				 DELETE FROM org.UserPermission WHERE CompanyID = @companyID AND UserID = @userID
					AND Entity NOT IN ('Admin','Report Writer')---This is a Hot Fix added For Bug 52139
				
				 SET @userPermissionDeleteCount = @userPermissionDeleteCount + @@ROWCOUNT
				 IF @requiresVueAccess = 1
				 BEGIN
					INSERT INTO org.UserPermission(CompanyID, UserID, Entity, Permission, ModifiedBy)
					VALUES(@companyID, @userID, 'Employees', 'Read', @modifiedBy)

					SET @userPermissionInsertCount = @userPermissionInsertCount  + 1
					INSERT INTO org.UserPermission(CompanyID, UserID, Entity, Permission, ModifiedBy)
					VALUES(@companyID, @userID, 'Employees', 'Write', @modifiedBy)

					SET @userPermissionInsertCount = @userPermissionInsertCount  + 1
				 END	
			
				ELSE IF @requiresVueAccess=0 ---This is a Hot Fix added For Bug 52139
					BEGIN 
				
						DELETE FROM org.UserPermission WHERE CompanyID = @companyID AND UserID = @userID
						 SET @userPermissionDeleteCount = @userPermissionDeleteCount + @@ROWCOUNT
				
					END			 
		
				-- Add manager permission if user is a manager
				 IF @isManager = 1
				 BEGIN
					INSERT INTO org.UserPermission(CompanyID, UserID, Entity, Permission, ModifiedBy)
					VALUES(@companyID, @userID, 'Manager', 'Read', @modifiedBy)

					SET @userPermissionInsertCount = @userPermissionInsertCount  + 1		
				 END
			END	
			
		END; -- end loop
	    
		COMMIT TRANSACTION Upsert;
	
		SELECT * from #UserInsertResults
	END TRY  
	
	BEGIN CATCH  
    -- Execute error retrieval routine.  
    -- EXECUTE usp_GetErrorInfo; 
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION Upsert;
		THROW; 
    END CATCH;		
END

GO
/****** Object:  StoredProcedure [dbo].[BulkUpsertUserCustomFields]    Script Date: 9/9/2021 5:04:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE      PROCEDURE [dbo].[BulkUpsertUserCustomFields]
    
	@userCustomFields [dbo].[UserCustomFieldTableParm] READONLY,
	-- output counters
	@insertCount INT OUTPUT,
	@updateCount INT OUTPUT
		
AS
BEGIN
    DECLARE @rowNo int  
	DEClARE @companyId int
	DEClARE @userId int
	DECLARE @customFieldID int
	DECLARE @customFieldName nvarchar(100)
	DECLARE @userEmail nvarchar(255) 
	DECLARE @textValue nvarchar(100) 
	DECLARE @numericValue float 
	DECLARE @boolValue bit
	DECLARE @modifiedBy [nvarchar](200) 

	DECLARE @userCustomFieldCount int = 0
	DECLARE @Idx int = 0
	DECLARE @curr_userEmail nvarchar(255) = ''
 
    SET NOCOUNT ON;

	set @userCustomFieldCount = (select count(*) from @userCustomFields)
			  
	BEGIN TRY  
	    BEGIN TRANSACTION Upsert;

		SET @Idx = 0;
		SET @insertCount = 0 
    	SET @updateCount = 0 
		    	    
		--------------------------------------------------------
		-- Main loop
		---------------------------------------------------
		WHILE (@Idx < @userCustomFieldCount)
		BEGIN
			SET @Idx = @Idx + 1

			SELECT 
				@rowNo = ucf.RowNo,
				@companyId = ucf.CompanyID,
				@customFieldId = ucf.CustomFieldID,
				@customFieldName = ucf.CustomFieldName,
			    @userEmail = ucf.UserEmail,
				@textValue = ucf.TextValue,
				@numericValue = ucf.NumericValue,
				@boolValue = ucf.BooleanValue,
				@modifiedBy = ucf.ModifiedBy
			FROM @userCustomFields ucf  
			WHERE ucf.RowNo = @Idx 
				
		--	PRINT 'Processing: ' + 'RowNo: ' + CAST(@rowNo as varchar) + ' Idx ' +  CAST(@Idx as varchar) + ' - ' + @userEmail 
			
			if (@curr_userEmail <> @userEmail)
			begin
				(SELECT @userId = UserID
					FROM org.Users 
					WHERE CompanyID = @companyId 
						AND Lower(UserEmail) = Lower(@userEmail)) 
			end

			set @curr_userEmail = @userEmail
		--------------------------------------------
		--  Upsert 
		--------------------------------------------
		 	
            ------------------------------------------------
            -- UPDATE existing user custom fields if exists
			------------------------------------------------
			IF exists (
			    SELECT  CustomFieldID
				FROM org.UserCustomField 
				WHERE CompanyID = @companyId 
					AND UserID = @userId
					AND CustomFieldID = @customFieldId)
			BEGIN
				UPDATE org.UserCustomField WITH(HOLDLOCK) 
				SET 
					StringValue = @textValue,
					NumericValue = @numericValue,
					BooleanValue = @boolValue,
					ModifiedBy = @modifiedBy
				WHERE CompanyID = @companyId  
				      AND UserID = @userId 
					  AND CustomFieldID = @customFieldId

				SET @updateCount = @updateCount + 1
			END

       	    --------------------------------------
            -- INSERT new user custom field
			--------------------------------------
			ELSE
			BEGIN  				
				INSERT INTO org.UserCustomField (
					CompanyID, UserID, CustomFieldID, 
					StringValue, NumericValue, BooleanValue, ModifiedBy)
				VALUES (
					@companyID, @userID, @customFieldID,
					@textValue, @numericValue, @boolValue, @modifiedBy)

	     		SET @insertCount = @insertCount + 1

			--	PRINT  'User: ' + CAST(@userID as varchar)
			END

			
		END; -- end loop
	    
		COMMIT TRANSACTION Upsert;
	
	END TRY  
	
	BEGIN CATCH  
    -- Execute error retrieval routine.  
    -- EXECUTE usp_GetErrorInfo; 
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION Upsert;
		THROW; 
    END CATCH;		
END

GO
/****** Object:  StoredProcedure [dbo].[GetAppMappings]    Script Date: 9/9/2021 5:04:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE   PROCEDURE [dbo].[GetAppMappings]
(
  @companyID INT
 ,@page int = 1
 ,@pageSize int = 0
 ,@orderBy int
 ,@sortBy nvarchar(200)='ID'
 ,@usageDuration int 
 ,@iswebApp bit --True/False/Null(should return All Apps/WebApps)
 ,@IsRemote bit --True/False(Should return all Apps/WebApps with false)/Null(should return All Apps/WebApps)
 ,@searchBy nvarchar(200)--DisplayName/Null
 ,@isMapped bit--Mappped/UnMapped/Null--status Column
 ,@isWork bit--true/false/null Category column
 ,@activityIds nvarchar(100)--comma seperated activityIds
 ,@overrideIds nvarchar(100)-- ID(APPID/WebAPPID) NOT IN overrideIds 
 ,@TotalCount INT OUTPUT
)
As 
SET NOCOUNT ON

BEGIN
	DECLARE @localCompanyID INT, @counter INT, @AppSpecID INT, @WebAppSpecID INT,@appUsageDuration INT, @rowCount INT, @str_ProfileNames NVARCHAR(500), @strSQL NVARCHAR(4000), @strSQLCount  NVARCHAR(4000)
	DECLARE  @Result AS INT
	DECLARE @offset INT
    DECLARE @newsize INT
	DECLARE @skipRows int = (@page - 1) * @pageSize;

	SET @localCompanyID = @CompanyID
	SET @appUsageDuration=@usageDuration


	--**********************Get WebAppSpecs for company*********************
	Select w.CompanyID, w.WebAppSpecID as ID,w.WebAppUrl as ApplicationOrUrl,w.WebAppDisplayName as DisplayName,
		w.UrlMatchContent ,
		case 
			when w.UrlMatchStrategy=1 then 'Domain'
			when w.UrlMatchStrategy=2 then 'StartsWith'
			when w.UrlMatchStrategy=3 then 'Contains'
		else ''
		end	as UrlPattern,		
		case 
			when w.UrlMatchStrategy=1 then 2
			when w.UrlMatchStrategy=2 then 3
			when w.UrlMatchStrategy=3 then 1
		else ''
		end	as UrlPatternSort,			
		w.ActivitySpecID, 
		a.IsCore,
		a.IsWorkCategory,
		a.ActivitySpecName as ActivityName,
		 Cast(1 as bit) as IsWebApp,
		 cast(null as bit) as  RemoteAccess,
		Case
		When a.IsWorkCategory=0 or a.IsWorkCategory is null
		then 'Private' 
		else 'Work'
		end  as Category,

		 Case 
		 When w.ActivitySpecID is not null
		 then 'Mapped'
		 else 'UnMapped' end as Status,
		Case
		  When @appUsageDuration=1   then  M.NumberOfUsers_Short
		  When @appUsageDuration=2 then  M.NumberOfUsers_Medium
		  else M.NumberOfUsers_Long 
		 end  as Users,
		Case 
		  When @appUsageDuration=1   then M.DailyAverage_Short
		  When @appUsageDuration=2 then M.DailyAverage_Medium
		  else M.DailyAverage_Long
		end  as DailyAverage,
	
		o.JobFamilyName as JobFamilyOverrides,
		u.ProfileName as MappingOverrides	
		INTO #webAppBase

		from org.WebAppSpec w
	Left join org.ActivitySpec a on a.ActivitySpecID=w.ActivitySpecID and w.CompanyID=a.CompanyID
	Left join org.AppMetrics M on M.WebAppSpecID=w.WebAppSpecID and M.CompanyID=w.CompanyID
	Left join (SELECT ja.JobFamilyName,jw.WebAppSpecID FROM org.JobFamilyWebAppSpecOverride jw 
				Left join  org.JobFamilyActivityOverrideProfile ja on ja.JobFamilyActivityOverrideProfileID=jw.JobFamilyActivityOverrideProfileID and ja.CompanyID=jw.CompanyID
				WHERE jw.CompanyID=@localCompanyID  AND WebAppSpecID IN
					(SELECT WebAppSpecID FROM org.JobFamilyWebAppSpecOverride	WHERE CompanyID=@localCompanyID 
					  GROUP BY WebAppSpecID HAVING COUNT(1) = 1))o on w.WebAppSpecID=o.WebAppSpecID
	Left join (SELECT ua.ProfileName,uw.WebAppSpecID FROM org.UserWebAppSpecOverride uw 
				Left join  org.UserActivityOverrideProfile ua on ua.UserActivityOverrideProfileID=uw.UserActivityOverrideProfileID and ua.CompanyID=uw.CompanyID
				WHERE uw.CompanyID=@localCompanyID  AND WebAppSpecID IN
					(SELECT WebAppSpecID FROM org.UserWebAppSpecOverride	WHERE CompanyID=@localCompanyID 
					  GROUP BY WebAppSpecID HAVING COUNT(1) = 1))u on w.WebAppSpecID=u.WebAppSpecID			

	WHERE w.CompanyID=@localCompanyID 
    OPTION(RECOMPILE) 

	ALTER TABLE #webAppBase ALTER COLUMN JobFamilyOverrides NVARCHAR(500)
	ALTER TABLE #webAppBase ALTER COLUMN MappingOverrides NVARCHAR(500)


	--******** THOSE WebApps WITH MULTIPLE JobFamily Overrides
	DECLARE @JobFamilyWebAppSpecOverride TABLE (ID INT, WebAppSpecID INT)
	INSERT INTO @JobFamilyWebAppSpecOverride (ID, WebAppSpecID)
	SELECT ROW_NUMBER() OVER(ORDER BY WebAppSpecID) ID, WebAppSpecID FROM org.JobFamilyWebAppSpecOverride WHERE CompanyID=@localCompanyID GROUP BY WebAppSpecID HAVING COUNT(1) >1

	SET @counter=1
	WHILE (@counter <= (SELECT MAX(ID) FROM @JobFamilyWebAppSpecOverride))
	BEGIN
		SET @str_ProfileNames=''
		SELECT @WebAppSpecID = WebAppSpecID FROM @JobFamilyWebAppSpecOverride WHERE ID=@counter

		SELECT @str_ProfileNames=COALESCE(@str_ProfileNames + ', ', '') + JobFamilyName FROM org.JobFamilyWebAppSpecOverride a
		JOIN org.JobFamilyActivityOverrideProfile b ON a.CompanyID = b.CompanyID AND a.JobFamilyActivityOverrideProfileID = b.JobFamilyActivityOverrideProfileID
		WHERE a.CompanyID=@localCompanyID AND WebAppSpecID = @WebAppSpecID

		UPDATE #webAppBase
		SET JobFamilyOverrides = SUBSTRING(@str_ProfileNames, 3, LEN(@str_ProfileNames))
		WHERE CompanyID=@localCompanyID AND ID=@WebAppSpecID

		SET @counter=@counter+1
	END


	--********* THOSE WebApps WITH MULTIPLE User Overrides
	DECLARE @UserWebAppSpecOverride TABLE (ID INT, WebAppSpecID INT)
	INSERT INTO @UserWebAppSpecOverride (ID, WebAppSpecID)
	SELECT ROW_NUMBER() OVER(ORDER BY WebAppSpecID) ID, WebAppSpecID FROM org.UserWebAppSpecOverride WHERE CompanyID=@localCompanyID GROUP BY WebAppSpecID HAVING COUNT(1) >1

	SET @counter=1
	WHILE (@counter <= (SELECT MAX(ID) FROM @UserWebAppSpecOverride))
	BEGIN
		SET @str_ProfileNames=''
		SELECT @WebAppSpecID = WebAppSpecID FROM @UserWebAppSpecOverride WHERE ID=@counter

		SELECT @str_ProfileNames=COALESCE(@str_ProfileNames + ', ', '') + ProfileName FROM org.UserWebAppSpecOverride a
		JOIN org.UserActivityOverrideProfile b ON a.CompanyID = b.CompanyID AND a.UserActivityOverrideProfileID = b.UserActivityOverrideProfileID
		WHERE a.CompanyID=@localCompanyID AND WebAppSpecID = @WebAppSpecID

		UPDATE #webAppBase
		SET MappingOverrides = SUBSTRING(@str_ProfileNames, 3, LEN(@str_ProfileNames))
		WHERE CompanyID=@localCompanyID AND ID=@WebAppSpecID

		SET @counter=@counter+1
	END


	--***********************Get AppSpecs for company******************
	select app.CompanyID, app.AppSpecID as ID,app.AppExeName as ApplicationOrUrl ,app.AppDisplayName as DisplayName ,
	Cast(null as nvarchar) as UrlMatchContent,Cast(null as nvarchar) as UrlPattern,Cast(null as int)UrlPatternSort,act.ActivitySpecID,act.IsCore,act.IsWorkCategory,
	act.ActivitySpecName  as ActivityName,cast(0 as bit) as IsWebApp,app.MergePriority as RemoteAccess,
	 Case
		  When act.IsWorkCategory=0 or act.IsWorkCategory is null
		 then 'Private' 
		 else 'Work'
		 end  as Category,

		 Case 
		 When app.ActivitySpecID is not null
		 then 'Mapped'
		 else 'UnMapped' end as Status,
	   Case
		  When @appUsageDuration=1   then  M.NumberOfUsers_Short
		  When @appUsageDuration=2 then  M.NumberOfUsers_Medium
		  else M.NumberOfUsers_Long 
		 end  as Users,
		Case 
		  When @appUsageDuration=1   then M.DailyAverage_Short
		  When @appUsageDuration=2 then M.DailyAverage_Medium
		  else M.DailyAverage_Long
		end  as DailyAverage,	
	   o.JobFamilyName as JobFamilyOverrides,
	   u.ProfileName as MappingOverrides
		INTO #appSpecBase
	from org.AppSpec app
	Left join org.ActivitySpec act on act.ActivitySpecID=app.ActivitySpecID and act.CompanyID=app.CompanyID
	Left join org.AppMetrics M on M.AppSpecId=app.AppSpecID and M.CompanyID=app.CompanyID
	Left join (SELECT ja.JobFamilyName,jao.AppSpecID FROM org.JobFamilyAppSpecOverride jao 
				Left join  org.JobFamilyActivityOverrideProfile ja on ja.JobFamilyActivityOverrideProfileID=jao.JobFamilyActivityOverrideProfileID and ja.CompanyID=jao.CompanyID
				WHERE jao.CompanyID=@localCompanyID  AND AppSpecID IN
					(SELECT AppSpecID FROM org.JobFamilyAppSpecOverride	WHERE CompanyID=@localCompanyID 
					  GROUP BY AppSpecID HAVING COUNT(1) = 1))o on app.AppSpecID=o.AppSpecID

	Left join (SELECT uap.ProfileName,ua.AppSpecID FROM org.UserAppSpecOverride ua 
				Left join  org.UserActivityOverrideProfile uap on ua.UserActivityOverrideProfileID=uap.UserActivityOverrideProfileID and ua.CompanyID=uap.CompanyID
				WHERE ua.CompanyID=@localCompanyID 
				 AND 
				AppSpecID IN
				(SELECT AppSpecID FROM org.UserAppSpecOverride	WHERE CompanyID=@localCompanyID  GROUP BY AppSpecID HAVING COUNT(1) = 1))u on app.AppSpecID=u.AppSpecID
	WHERE app.CompanyID=@localCompanyID  
	
	
	OPTION(RECOMPILE) 

	ALTER TABLE #appSpecBase ALTER COLUMN JobFamilyOverrides NVARCHAR(500)
	ALTER TABLE #appSpecBase ALTER COLUMN MappingOverrides NVARCHAR(500)


	--******** THOSE Apps WITH MULTIPLE JobFamily Overrides
	DECLARE @JobFamilyAppSpecOverride TABLE (ID INT, AppSpecID INT)
	INSERT INTO @JobFamilyAppSpecOverride (ID, AppSpecID)
	SELECT ROW_NUMBER() OVER(ORDER BY AppSpecID) ID, AppSpecID FROM org.JobFamilyAppSpecOverride WHERE CompanyID=@localCompanyID GROUP BY AppSpecID HAVING COUNT(1) >1

	SET @counter=1
	WHILE (@counter <= (SELECT MAX(ID) FROM @JobFamilyAppSpecOverride))
	BEGIN
		SET @str_ProfileNames=''
		SELECT @AppSpecID = AppSpecID FROM @JobFamilyAppSpecOverride WHERE ID=@counter

		SELECT @str_ProfileNames=COALESCE(@str_ProfileNames + ', ', '') + JobFamilyName FROM org.JobFamilyAppSpecOverride a
		JOIN org.JobFamilyActivityOverrideProfile b ON a.CompanyID = b.CompanyID AND a.JobFamilyActivityOverrideProfileID = b.JobFamilyActivityOverrideProfileID
		WHERE a.CompanyID=@localCompanyID AND AppSpecID = @AppSpecID

		UPDATE #appSpecBase
		SET JobFamilyOverrides = SUBSTRING(@str_ProfileNames, 3, LEN(@str_ProfileNames))
		WHERE CompanyID=@localCompanyID AND ID=@AppSpecID

		SET @counter=@counter+1
	END


	--******** THOSE Apps WITH MULTIPLE User O verrides
	DECLARE @UserAppSpecOverride TABLE (ID INT, AppSpecID INT)
	INSERT INTO @UserAppSpecOverride (ID, AppSpecID)
	SELECT ROW_NUMBER() OVER(ORDER BY AppSpecID) ID, AppSpecID FROM org.UserAppSpecOverride WHERE CompanyID=@localCompanyID GROUP BY AppSpecID HAVING COUNT(1) >1

	SET @counter=1
	WHILE (@counter <= (SELECT MAX(ID) FROM @UserAppSpecOverride))
	BEGIN
		SET @str_ProfileNames=''
		SELECT @AppSpecID = AppSpecID FROM @UserAppSpecOverride WHERE ID=@counter

		SELECT @str_ProfileNames=COALESCE(@str_ProfileNames + ', ', '') + ProfileName FROM org.UserAppSpecOverride a
		JOIN org.UserActivityOverrideProfile b ON a.CompanyID = b.CompanyID AND a.UserActivityOverrideProfileID = b.UserActivityOverrideProfileID
		WHERE a.CompanyID=@localCompanyID AND AppSpecID = @AppSpecID

		UPDATE #appSpecBase
		SET MappingOverrides = SUBSTRING(@str_ProfileNames, 3, LEN(@str_ProfileNames))
		WHERE CompanyID=@localCompanyID AND ID=@AppSpecID

		SET @counter=@counter+1
	END


	--******** BUILD @strSQL string
	SET @strSQL = 
	'SELECT * FROM 
		(SELECT * FROM #webAppBase
		UNION ALL
		SELECT * FROM #appSpecBase) results 
	WHERE 1=1'
	+ CASE WHEN @iswebApp IS NULL THEN '' WHEN @iswebApp=1 THEN ' AND IsWebApp=1' WHEN @iswebApp=0 THEN ' AND IsWebApp=0' END
	+ CASE WHEN @IsRemote IS NULL THEN '' WHEN @IsRemote=1 THEN ' AND RemoteAccess=1' WHEN @IsRemote=0 THEN ' AND RemoteAccess=0' END
	+ CASE WHEN @searchBy IS NULL THEN '' ELSE ' AND DisplayName LIKE ''%' + @searchBy + '%''' END
	+ CASE WHEN @isMapped IS NULL THEN '' WHEN @isMapped=1 THEN ' AND Status=''Mapped''' WHEN @isMapped=0 THEN ' AND Status=''UnMapped''' END
	+ CASE WHEN @isWork IS NULL THEN '' WHEN @isWork=1 THEN ' AND IsWorkCategory=1' WHEN @isWork=0 THEN ' AND IsWorkCategory=0' END
	+ CASE WHEN @activityIds = '' THEN '' ELSE ' AND ActivitySpecID IN (' + @activityIds + ')' END
	+ ' ORDER BY ' + CASE @sortBy WHEN 'MergePriority' THEN 'RemoteAccess' WHEN 'UrlPattern' THEN 'UrlPatternSort' ELSE @sortBy END + CASE @orderBy WHEN 1 THEN ' DESC' ELSE ' ASC' END
	+ ' OFFSET ' + CAST(@skipRows AS varchar(10)) + ' ROWS'
	+ ' FETCH NEXT ' + CAST(@pageSize AS varchar(10)) + ' ROWS ONLY'


	+ '	SELECT @TotalCount=COUNT(1) FROM 
		(SELECT * FROM #webAppBase
		UNION ALL
		SELECT * FROM #appSpecBase) results 
	WHERE 1=1'
	+ CASE WHEN @iswebApp IS NULL THEN '' WHEN @iswebApp=1 THEN ' AND IsWebApp=1' WHEN @iswebApp=0 THEN ' AND IsWebApp=0' END
	+ CASE WHEN @IsRemote IS NULL THEN '' WHEN @IsRemote=1 THEN ' AND RemoteAccess=1' WHEN @IsRemote=0 THEN ' AND RemoteAccess=0' END
	+ CASE WHEN @searchBy IS NULL THEN '' ELSE ' AND DisplayName LIKE ''%' + @searchBy + '%''' END
	+ CASE WHEN @isMapped IS NULL THEN '' WHEN @isMapped=1 THEN ' AND Status=''Mapped''' WHEN @isMapped=0 THEN ' AND Status=''UnMapped''' END
	+ CASE WHEN @isWork IS NULL THEN '' WHEN @isWork=1 THEN ' AND IsWorkCategory=1' WHEN @isWork=0 THEN ' AND IsWorkCategory=0' END
	+ CASE WHEN @activityIds = '' THEN '' ELSE ' AND ActivitySpecID IN (' + @activityIds + ')' END 
	

    --******** OUTPUT 
	EXEC sp_executesql @strSQL, N'@TotalCount int OUT', @TotalCount = @rowCount OUT;
 	--SELECT @rowCount TotalRows; 
	SET @TotalCount = @rowCount

	DROP TABLE #webAppBase
	DROP TABLE #appSpecBase

END

GO
/****** Object:  StoredProcedure [dbo].[sp_alterdiagram]    Script Date: 8/20/2021 4:27:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

	CREATE PROCEDURE [dbo].[sp_alterdiagram]
	(
		@diagramname 	sysname,
		@owner_id	int	= null,
		@version 	int,
		@definition 	varbinary(max)
	)
	WITH EXECUTE AS 'dbo'
	AS
	BEGIN
		set nocount on
	
		declare @theId 			int
		declare @retval 		int
		declare @IsDbo 			int
		
		declare @UIDFound 		int
		declare @DiagId			int
		declare @ShouldChangeUID	int
	
		if(@diagramname is null)
		begin
			RAISERROR ('Invalid ARG', 16, 1)
			return -1
		end
	
		execute as caller;
		select @theId = DATABASE_PRINCIPAL_ID();	 
		select @IsDbo = IS_MEMBER(N'db_owner'); 
		if(@owner_id is null)
			select @owner_id = @theId;
		revert;
	
		select @ShouldChangeUID = 0
		select @DiagId = diagram_id, @UIDFound = principal_id from dbo.sysdiagrams where principal_id = @owner_id and name = @diagramname 
		
		if(@DiagId IS NULL or (@IsDbo = 0 and @theId <> @UIDFound))
		begin
			RAISERROR ('Diagram does not exist or you do not have permission.', 16, 1);
			return -3
		end
	
		if(@IsDbo <> 0)
		begin
			if(@UIDFound is null or USER_NAME(@UIDFound) is null) -- invalid principal_id
			begin
				select @ShouldChangeUID = 1 ;
			end
		end

		-- update dds data			
		update dbo.sysdiagrams set definition = @definition where diagram_id = @DiagId ;

		-- change owner
		if(@ShouldChangeUID = 1)
			update dbo.sysdiagrams set principal_id = @theId where diagram_id = @DiagId ;

		-- update dds version
		if(@version is not null)
			update dbo.sysdiagrams set version = @version where diagram_id = @DiagId ;

		return 0
	END
	
GO
/****** Object:  StoredProcedure [dbo].[sp_creatediagram]    Script Date: 8/20/2021 4:27:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

	CREATE PROCEDURE [dbo].[sp_creatediagram]
	(
		@diagramname 	sysname,
		@owner_id		int	= null, 	
		@version 		int,
		@definition 	varbinary(max)
	)
	WITH EXECUTE AS 'dbo'
	AS
	BEGIN
		set nocount on
	
		declare @theId int
		declare @retval int
		declare @IsDbo	int
		declare @userName sysname
		if(@version is null or @diagramname is null)
		begin
			RAISERROR (N'E_INVALIDARG', 16, 1);
			return -1
		end
	
		execute as caller;
		select @theId = DATABASE_PRINCIPAL_ID(); 
		select @IsDbo = IS_MEMBER(N'db_owner');
		revert; 
		
		if @owner_id is null
		begin
			select @owner_id = @theId;
		end
		else
		begin
			if @theId <> @owner_id
			begin
				if @IsDbo = 0
				begin
					RAISERROR (N'E_INVALIDARG', 16, 1);
					return -1
				end
				select @theId = @owner_id
			end
		end
		-- next 2 line only for test, will be removed after define name unique
		if EXISTS(select diagram_id from dbo.sysdiagrams where principal_id = @theId and name = @diagramname)
		begin
			RAISERROR ('The name is already used.', 16, 1);
			return -2
		end
	
		insert into dbo.sysdiagrams(name, principal_id , version, definition)
				VALUES(@diagramname, @theId, @version, @definition) ;
		
		select @retval = @@IDENTITY 
		return @retval
	END
	
GO
/****** Object:  StoredProcedure [dbo].[sp_dropdiagram]    Script Date: 8/20/2021 4:27:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

	CREATE PROCEDURE [dbo].[sp_dropdiagram]
	(
		@diagramname 	sysname,
		@owner_id	int	= null
	)
	WITH EXECUTE AS 'dbo'
	AS
	BEGIN
		set nocount on
		declare @theId 			int
		declare @IsDbo 			int
		
		declare @UIDFound 		int
		declare @DiagId			int
	
		if(@diagramname is null)
		begin
			RAISERROR ('Invalid value', 16, 1);
			return -1
		end
	
		EXECUTE AS CALLER;
		select @theId = DATABASE_PRINCIPAL_ID();
		select @IsDbo = IS_MEMBER(N'db_owner'); 
		if(@owner_id is null)
			select @owner_id = @theId;
		REVERT; 
		
		select @DiagId = diagram_id, @UIDFound = principal_id from dbo.sysdiagrams where principal_id = @owner_id and name = @diagramname 
		if(@DiagId IS NULL or (@IsDbo = 0 and @UIDFound <> @theId))
		begin
			RAISERROR ('Diagram does not exist or you do not have permission.', 16, 1)
			return -3
		end
	
		delete from dbo.sysdiagrams where diagram_id = @DiagId;
	
		return 0;
	END
	
GO
/****** Object:  StoredProcedure [dbo].[sp_helpdiagramdefinition]    Script Date: 8/20/2021 4:27:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

	CREATE PROCEDURE [dbo].[sp_helpdiagramdefinition]
	(
		@diagramname 	sysname,
		@owner_id	int	= null 		
	)
	WITH EXECUTE AS N'dbo'
	AS
	BEGIN
		set nocount on

		declare @theId 		int
		declare @IsDbo 		int
		declare @DiagId		int
		declare @UIDFound	int
	
		if(@diagramname is null)
		begin
			RAISERROR (N'E_INVALIDARG', 16, 1);
			return -1
		end
	
		execute as caller;
		select @theId = DATABASE_PRINCIPAL_ID();
		select @IsDbo = IS_MEMBER(N'db_owner');
		if(@owner_id is null)
			select @owner_id = @theId;
		revert; 
	
		select @DiagId = diagram_id, @UIDFound = principal_id from dbo.sysdiagrams where principal_id = @owner_id and name = @diagramname;
		if(@DiagId IS NULL or (@IsDbo = 0 and @UIDFound <> @theId ))
		begin
			RAISERROR ('Diagram does not exist or you do not have permission.', 16, 1);
			return -3
		end

		select version, definition FROM dbo.sysdiagrams where diagram_id = @DiagId ; 
		return 0
	END
	
GO
/****** Object:  StoredProcedure [dbo].[sp_helpdiagrams]    Script Date: 8/20/2021 4:27:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

	CREATE PROCEDURE [dbo].[sp_helpdiagrams]
	(
		@diagramname sysname = NULL,
		@owner_id int = NULL
	)
	WITH EXECUTE AS N'dbo'
	AS
	BEGIN
		DECLARE @user sysname
		DECLARE @dboLogin bit
		EXECUTE AS CALLER;
			SET @user = USER_NAME();
			SET @dboLogin = CONVERT(bit,IS_MEMBER('db_owner'));
		REVERT;
		SELECT
			[Database] = DB_NAME(),
			[Name] = name,
			[ID] = diagram_id,
			[Owner] = USER_NAME(principal_id),
			[OwnerID] = principal_id
		FROM
			sysdiagrams
		WHERE
			(@dboLogin = 1 OR USER_NAME(principal_id) = @user) AND
			(@diagramname IS NULL OR name = @diagramname) AND
			(@owner_id IS NULL OR principal_id = @owner_id)
		ORDER BY
			4, 5, 1
	END
	
GO
/****** Object:  StoredProcedure [dbo].[sp_renamediagram]    Script Date: 8/20/2021 4:27:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

	CREATE PROCEDURE [dbo].[sp_renamediagram]
	(
		@diagramname 		sysname,
		@owner_id		int	= null,
		@new_diagramname	sysname
	
	)
	WITH EXECUTE AS 'dbo'
	AS
	BEGIN
		set nocount on
		declare @theId 			int
		declare @IsDbo 			int
		
		declare @UIDFound 		int
		declare @DiagId			int
		declare @DiagIdTarg		int
		declare @u_name			sysname
		if((@diagramname is null) or (@new_diagramname is null))
		begin
			RAISERROR ('Invalid value', 16, 1);
			return -1
		end
	
		EXECUTE AS CALLER;
		select @theId = DATABASE_PRINCIPAL_ID();
		select @IsDbo = IS_MEMBER(N'db_owner'); 
		if(@owner_id is null)
			select @owner_id = @theId;
		REVERT;
	
		select @u_name = USER_NAME(@owner_id)
	
		select @DiagId = diagram_id, @UIDFound = principal_id from dbo.sysdiagrams where principal_id = @owner_id and name = @diagramname 
		if(@DiagId IS NULL or (@IsDbo = 0 and @UIDFound <> @theId))
		begin
			RAISERROR ('Diagram does not exist or you do not have permission.', 16, 1)
			return -3
		end
	
		-- if((@u_name is not null) and (@new_diagramname = @diagramname))	-- nothing will change
		--	return 0;
	
		if(@u_name is null)
			select @DiagIdTarg = diagram_id from dbo.sysdiagrams where principal_id = @theId and name = @new_diagramname
		else
			select @DiagIdTarg = diagram_id from dbo.sysdiagrams where principal_id = @owner_id and name = @new_diagramname
	
		if((@DiagIdTarg is not null) and  @DiagId <> @DiagIdTarg)
		begin
			RAISERROR ('The name is already used.', 16, 1);
			return -2
		end		
	
		if(@u_name is null)
			update dbo.sysdiagrams set [name] = @new_diagramname, principal_id = @theId where diagram_id = @DiagId
		else
			update dbo.sysdiagrams set [name] = @new_diagramname where diagram_id = @DiagId
		return 0
	END
	
GO
/****** Object:  StoredProcedure [dbo].[sp_upgraddiagrams]    Script Date: 8/20/2021 4:27:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

	CREATE PROCEDURE [dbo].[sp_upgraddiagrams]
	AS
	BEGIN
		IF OBJECT_ID(N'dbo.sysdiagrams') IS NOT NULL
			return 0;
	
		CREATE TABLE dbo.sysdiagrams
		(
			name sysname NOT NULL,
			principal_id int NOT NULL,	-- we may change it to varbinary(85)
			diagram_id int PRIMARY KEY IDENTITY,
			version int,
	
			definition varbinary(max)
			CONSTRAINT UK_principal_name UNIQUE
			(
				principal_id,
				name
			)
		);


		/* Add this if we need to have some form of extended properties for diagrams */
		/*
		IF OBJECT_ID(N'dbo.sysdiagram_properties') IS NULL
		BEGIN
			CREATE TABLE dbo.sysdiagram_properties
			(
				diagram_id int,
				name sysname,
				value varbinary(max) NOT NULL
			)
		END
		*/

		IF OBJECT_ID(N'dbo.dtproperties') IS NOT NULL
		begin
			insert into dbo.sysdiagrams
			(
				[name],
				[principal_id],
				[version],
				[definition]
			)
			select	 
				convert(sysname, dgnm.[uvalue]),
				DATABASE_PRINCIPAL_ID(N'dbo'),			-- will change to the sid of sa
				0,							-- zero for old format, dgdef.[version],
				dgdef.[lvalue]
			from dbo.[dtproperties] dgnm
				inner join dbo.[dtproperties] dggd on dggd.[property] = 'DtgSchemaGUID' and dggd.[objectid] = dgnm.[objectid]	
				inner join dbo.[dtproperties] dgdef on dgdef.[property] = 'DtgSchemaDATA' and dgdef.[objectid] = dgnm.[objectid]
				
			where dgnm.[property] = 'DtgSchemaNAME' and dggd.[uvalue] like N'_EA3E6268-D998-11CE-9454-00AA00A3F36E_' 
			return 2;
		end
		return 1;
	END
	
GO
/****** Object:  StoredProcedure [dbo].[sproc_AddImported_App_ActivityCategory]    Script Date: 8/20/2021 4:27:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sproc_AddImported_App_ActivityCategory]

(
	@CompanyID INT, 
	@Debug tinyint = 0
)
AS 
BEGIN
    SET NOCOUNT ON
	SET DATEFIRST 1


		DECLARE  @ExceptionMessage NVARCHAR(4000) = '',
			@ExceptionSeverity INT = 0,
			@ExceptionState INT = 0,
			@ErrorValidation NVARCHAR(MAX) = '',
			@Step NVARCHAR(4000) = ''


	CREATE TABLE #ImportAppActivityCategory (
		[ID] [integer] identity(1,1) NOT NULL,
		[ExeName] [nvarchar](255) NOT NULL,
		[ActivityCategoryName] [nvarchar](255) NOT NULL,
		[AppDisplayName] [nvarchar](255) NOT NULL
		
	
	)

	DECLARE @CountOfRows int = 0, @CurrentRowID int = 0, @CountOfDuplicateDepartments int = 0, @MaxDepartmentIdForCompany int = 0, @PlatformID int = 0
	DECLARE @ExeName [nvarchar](255),
			@ActivityCategoryName [nvarchar](255),
			@ActivityCategoryID int,
			@AppDisplayName [nvarchar](255)

	INSERT INTO #ImportAppActivityCategory (ExeName, ActivityCategoryName, AppDisplayName)

	SELECT TRIM(i.ExeName), TRIM(i.ActivityCategoryName), TRIM(i.AppDisplayName)
	from dbo.ImportAppActivityCategory i
	where
		i.CompanyID = @CompanyID and i.PushedInMaster = 0

	set @CountOfRows = @@ROWCOUNT

	

	----================ Start Validate Data =======================

	if (@CountOfRows = 0)
	begin

		select 'Nothing To Add' EmptyImport
		return

	end

	-- Check Dup Rows

	SELECT i.ExeName, COUNT(1) DupRows INTO #DupRows
	FROM #ImportAppActivityCategory i
	GROUP BY i.ExeName
	HAVING
		COUNT(1) > 1

	
	if ( @@ROWCOUNT > 0 )
	begin
		
		set @ErrorValidation = @ErrorValidation + 'One or more Duplicate Rows in AppActivityCategoryImport' + CHAR(10)
		
		select 'Duplicate Rows' 'Duplicate Rows'
		select * from #DupRows DuplicateRows
	

	end 

	-- Validate Exe Names

	SELECT * INTO #InvalidExeNames
	FROM #ImportAppActivityCategory d 
	WHERE d.ExeName NOT LIKE '%_._%' 

	IF (@@ROWCOUNT > 0)
	BEGIN
	
		set @ErrorValidation = @ErrorValidation + ' One or more exe names are invalid ' + CHAR(10)
		
		select 'Invalid Exe Names' 'Invalid Exe Names'
		select * from #InvalidExeNames 
		
	
	END	

	-- Validate if Activity Categories exist

	SELECT * INTO #NonAvailableActivityCategories
	FROM #ImportAppActivityCategory i
	WHERE
	NOT EXISTS 
	(
		SELECT 1 FROM [org].ActivitySpec u
		WHERE
			u.CompanyID = @CompanyID and u.ActivitySpecName = i.ActivityCategoryName
	)

	
	IF (@@ROWCOUNT > 0)
	BEGIN
	
		SET @ErrorValidation = @ErrorValidation + ' One or more Activity Categories are not found' + CHAR(10)
		
		SELECT 'Unavailable Activity Categories' 'Unavailable Activity Categories'
		SELECT * FROM #NonAvailableActivityCategories 
		
	
	END	

	----================ End Validate Data =======================

	IF (@ErrorValidation <> '')
	BEGIN

		--PRINT @ErrorValidation
		RAISERROR (
				@ErrorValidation,
				16,
				16    
			);
		
		RETURN

	END
	
	ELSE
	
	BEGIN -- ( Validation Passes )

		
		BEGIN TRAN TranUpsert
		BEGIN TRY

		WHILE (@CurrentRowID < @CountOfRows)
		BEGIN
		
			SET @CurrentRowID = @CurrentRowID + 1

			SELECT  @ExeName = i.ExeName, @ActivityCategoryName = i.ActivityCategoryName, @AppDisplayName = i.AppDisplayName
			FROM	#ImportAppActivityCategory i 
			WHERE	i.ID = @CurrentRowID

			SELECT @ActivityCategoryID = u.ActivitySpecID
			FROM [org].ActivitySpec u
			WHERE
				u.CompanyID = @CompanyID and u.ActivityspecName = @ActivityCategoryName


				IF NOT EXISTS 
				(
					SELECT 1 FROM [org].AppSpec l WHERE l.CompanyID = @CompanyID and l.AppExeName = @ExeName
					----and l.IsApplication = 1
				)

				BEGIN
				

				INSERT INTO [org].[AppSpec]
				([CompanyID] ,[ActivitySpecID] ,[AppExeName] ,[AppDisplayName] ,[AppDescription] ,[IsActive] ,[ModifiedBy] ,[MergePriority])
				VALUES
				(@CompanyID, @ActivityCategoryID, @ExeName, @AppDisplayName, @ExeName, 1, 'System', 0)

					
				END
				ELSE BEGIN -- Update



					UPDATE d 
					SET
					
						d.ActivitySpecID = @ActivityCategoryID,
						d.AppDisplayName = @AppDisplayName
											
					FROM [org].[AppSpec] d 
					WHERE 
						d.CompanyID = @CompanyID and d.AppExeName = @ExeName ----and d.IsApplication = 1

				END

				UPDATE l 
				set
					l.PushedInMaster = 1
				FROM [dbo].[ImportAppActivityCategory] l 
				WHERE 
					l.CompanyID = @CompanyID and l.ExeName = @ExeName

		END


		SELECT @PlatformID = u.PlatformID
			FROM [org].[Platform] u
			WHERE
				u.CompanyID = @CompanyID and u.PlatformName ='Windows'



		INSERT INTO [org].[AppSpecPlatform]
           ([CompanyID] ,[AppSpecID] ,[PlatformID],[AppVersion] ,[DisplayName] ,[IsSystemDiscovered], ModifiedBy)

		SELECT a.CompanyID, a.AppSpecID, @PlatformID, '0.0.0.0' AppVersion, null, 0, 'System'
		FROM [org].[AppSpec] a 
		WHERE a.CompanyID = @CompanyID and LOWER(a.AppExeName) like '%.exe' and not exists 
		(
			SELECT 1 from [org].[AppSpecPlatform] d where a.CompanyID = d.CompanyID and a.AppSpecID = d.AppSpecID and d.AppVersion ='0.0.0.0'
		)

		SELECT @PlatformID = u.PlatformID
		FROM [org].[Platform] u
		WHERE
			u.CompanyID = @CompanyID and u.PlatformName ='Windows'

		
		INSERT INTO [org].[AppSpecPlatform]
           ([CompanyID] ,[AppSpecID] ,[PlatformID],[AppVersion] ,[DisplayName] ,[IsSystemDiscovered], ModifiedBy)

		SELECT a.CompanyID, a.AppSpecID, @PlatformID, '0.0.0.0' AppVersion, null, 0, 'System'
		FROM [org].[AppSpec] a 
		WHERE a.CompanyID = @CompanyID and LOWER(a.AppExeName) like '%.app' and not exists 
		(
			SELECT 1 from [org].[AppSpecPlatform] d where a.CompanyID = d.CompanyID and a.AppSpecID = d.AppSpecID and d.AppVersion ='0.0.0.0'
		)

	


		COMMIT TRAN TranUpsert
		END TRY
		BEGIN CATCH
		 
			ROLLBACK TRAN TranUpsert 

			SELECT 
				@ExceptionMessage = ERROR_MESSAGE(),
				@ExceptionSeverity = ERROR_SEVERITY(),
				@ExceptionState = ERROR_STATE();
			RAISERROR (
					@ExceptionMessage,
					@ExceptionSeverity,
					@ExceptionState    
				);
		 
		END CATCH	

		select 'List of Rows added successfully' AddSuccess

		select i.ActivityCategoryName, i.ExeName
		from dbo.ImportAppActivityCategory i
		where
			i.CompanyID = @CompanyID and i.PushedInMaster = 1


		select 'List of Failed To Add Rows' AddFailed

		select i.ActivityCategoryName, i.ExeName
		from dbo.ImportAppActivityCategory i
		where
			i.CompanyID = @CompanyID and i.PushedInMaster = 0

	END

	DROP TABLE #DupRows
	DROP TABLE #ImportAppActivityCategory

END

GO
/****** Object:  StoredProcedure [dbo].[sproc_AddImported_WebApp_ActivityCategory]    Script Date: 8/20/2021 4:27:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE   PROCEDURE [dbo].[sproc_AddImported_WebApp_ActivityCategory]

(
	@CompanyID INT, 
	@Debug tinyint = 0
)
AS 
BEGIN
    SET NOCOUNT ON
	SET DATEFIRST 1


		DECLARE  @ExceptionMessage NVARCHAR(4000) = '',
			@ExceptionSeverity INT = 0,
			@ExceptionState INT = 0,
			@ErrorValidation NVARCHAR(MAX) = '',
			@Step NVARCHAR(4000) = ''


	CREATE TABLE #ImportWebAppActivityCategory (
		[ID] [integer] identity(1,1) NOT NULL,
		[AppName] [nvarchar](255) NOT NULL,
		[WebAppUrlDomain] [nvarchar](255) NOT NULL,
		[ActivityCategoryName] [nvarchar](255) NOT NULL,
		[UrlMatchStrategy] int,
		[IsUpdate] int
	)

	DECLARE @CountOfRows int = 0, @CurrentRowID int = 0, @CountOfDuplicateDepartments int = 0, @MaxDepartmentIdForCompany int = 0
	DECLARE @AppName [nvarchar](255), @WebAppUrlDomain [nvarchar] (255),
			@ActivityCategoryName [nvarchar](255),
			@ActivityCategoryID int,
			@UrlMatchStrategy int,
			@IsUpdate int

	INSERT INTO #ImportWebAppActivityCategory (AppName, WebAppUrlDomain, ActivityCategoryName, UrlMatchStrategy, IsUpdate)

	SELECT TRIM(i.AppName), TRIM(i.WebAppUrlDomain), TRIM(i.ActivityCategoryName), UrlMatchStrategy, PushedInMaster
	from dbo.ImportWebAppActivityCategory i
	where
		i.CompanyID = @CompanyID and i.PushedInMaster = 0

	set @CountOfRows = @@ROWCOUNT

	

	----================ Start Validate Data =======================

	if (@CountOfRows = 0)
	begin

		select 'Nothing To Add' EmptyImport
		return

	end

	-- Check Dup Rows

	SELECT  i.WebAppUrlDomain, COUNT(1) DupRows INTO #DupRows
	FROM #ImportWebAppActivityCategory i
	GROUP BY  i.WebAppUrlDomain
	HAVING
		COUNT(1) > 1

	
	if ( @@ROWCOUNT > 0 )
	begin
		

		set @ErrorValidation = @ErrorValidation + 'One or more Duplicate Rows in AppActivityCategoryImport' + CHAR(10)
		
		select 'Duplicate Rows' 'Duplicate Rows'
		select * from #DupRows DuplicateRows
	

	end 



	
	-- Validate if Activity Categories exist

	SELECT * INTO #NonAvailableActivityCategories
	FROM #ImportWebAppActivityCategory i
	WHERE
	NOT EXISTS 
	(
		SELECT 1 FROM [org].ActivitySpec u
		WHERE
			u.CompanyID = @CompanyID and u.ActivitySpecName = i.ActivityCategoryName
	)

	
	IF (@@ROWCOUNT > 0)
	BEGIN
	
		SET @ErrorValidation = @ErrorValidation + ' One or more Activity Categories are not found' + CHAR(10)
		
		SELECT 'Unavailable Activity Categories' 'Unavailable Activity Categories'
		SELECT * FROM #NonAvailableActivityCategories 
		
	
	END	

	----================ End Validate Data =======================

	IF (@ErrorValidation <> '')
	BEGIN

		--PRINT @ErrorValidation
		RAISERROR (
				@ErrorValidation,
				16,
				16    
			);
		
		RETURN

	END
	
	ELSE
	
	BEGIN -- ( Validation Passes )

		
		BEGIN TRAN TranUpsert
		BEGIN TRY

		WHILE (@CurrentRowID < @CountOfRows)
		BEGIN
		
			SET @CurrentRowID = @CurrentRowID + 1

			SELECT  @AppName = i.AppName, @WebAppUrlDomain = i.WebAppUrlDomain, @ActivityCategoryName = i.ActivityCategoryName, @UrlMatchStrategy = i.UrlMatchStrategy, @IsUpdate = i.IsUpdate
			FROM	#ImportWebAppActivityCategory i 
			WHERE	i.ID = @CurrentRowID

			SELECT @ActivityCategoryID = u.ActivitySpecID
			FROM [org].ActivitySpec u
			WHERE
				u.CompanyID = @CompanyID and u.ActivitySpecName = @ActivityCategoryName
				


			IF NOT EXISTS 
			(
				SELECT 1 FROM [org].WebAppSpec l 
				WHERE 
					l.CompanyID = @CompanyID and
					 LOWER(l.WebAppUrl) = LOWER(@WebAppUrlDomain)
			)

			BEGIN

				Select	@CompanyID, @AppName, @AppName, @WebAppUrlDomain,  @ActivityCategoryID, @UrlMatchStrategy, @WebAppUrlDomain
				
			INSERT INTO [org].[WebAppSpec]
			           ([CompanyID]
			           ,[WebAppName]
			           ,[WebAppDisplayName]
			           ,[WebAppUrl]
			           ,[WebAppVersion]
			           ,[WebAppDescription]
			           ,[ActivitySpecID]
			           ,[UrlMatchStrategy]
			           ,[UrlMatchContent]
			           ,[IsSystemDiscovered]
			           ,[IsActive]
			           ,[ModifiedBy])
			     VALUES
			           (@CompanyID, @AppName, @AppName, @WebAppUrlDomain, 'All', '', @ActivityCategoryID, @UrlMatchStrategy, @WebAppUrlDomain, 1, 1, 'System')
				

				UPDATE l 
				set
					l.PushedInMaster = 1
				FROM [dbo].[ImportWebAppActivityCategory] l 
				WHERE 
					l.CompanyID = @CompanyID and l.AppName = @AppName and l.WebAppUrlDomain = @WebAppUrlDomain

					
				END
				ELSE BEGIN -- Update

					UPDATE d 
					SET
					
						d.[ActivitySpecID] = @ActivityCategoryID,
						d.[UrlMatchStrategy] = @UrlMatchStrategy
											
					FROM [org].[WebAppSpec] d 
					WHERE 
						d.CompanyID = @CompanyID
						 and d.WebAppUrl = @WebAppUrlDomain
				
				UPDATE l 
				set
					l.PushedInMaster = 0
				FROM [dbo].[ImportWebAppActivityCategory] l 
				WHERE 
					l.CompanyID = @CompanyID and l.WebAppUrlDomain = @WebAppUrlDomain



				END

				



		end

		commit tran TranUpsert
		end try
		begin catch
		 
			Rollback tran TranUpsert 

			SELECT 
				@ExceptionMessage = ERROR_MESSAGE(),
				@ExceptionSeverity = ERROR_SEVERITY(),
				@ExceptionState = ERROR_STATE();
			RAISERROR (
					@ExceptionMessage,
					@ExceptionSeverity,
					@ExceptionState    
				);
		 
		end catch	

		select 'List of WebApps inserted successfully' AddSuccess

		select i.ActivityCategoryName, i.AppName, i.WebAppUrlDomain
		from dbo.ImportWebAppActivityCategory i
		where
			i.CompanyID = @CompanyID and i.PushedInMaster = 1


		select 'List of WebApps updated succesfully' AddFailed

		select i.ActivityCategoryName, i.AppName, i.WebAppUrlDomain
		from dbo.ImportWebAppActivityCategory i
		where
			i.CompanyID = @CompanyID and i.PushedInMaster = 0

	end

	drop table #DupRows
	drop table #ImportWebAppActivityCategory

END

GO
/****** Object:  StoredProcedure [dbo].[sproc_AddImportedActivityCategory]    Script Date: 8/20/2021 4:27:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sproc_AddImportedActivityCategory]

(
	@CompanyID INT, 
	@Debug tinyint = 0
)
AS 
BEGIN
    SET NOCOUNT ON
	SET DATEFIRST 1


DECLARE 
		@ExceptionMessage NVARCHAR(4000) = '',
		@ExceptionSeverity INT = 0,
		@ExceptionState INT = 0,
		@ErrorValidation NVARCHAR(MAX) = '',
		@Step NVARCHAR(4000) = ''


	CREATE TABLE #ImportActivityCategory (
		[ID] [integer] identity(1,1) NOT NULL,
		[ActivityCategoryName] [nvarchar](255) NOT NULL,
		[IsCore] bit NOT NULL
	
	)

	DECLARE @CountOfRows int = 0, @CurrentRowID int = 0, @CountOfDuplicateActivityCategory int = 0,@MaxActivityCategoryIdForCompany int = 0, @ActivityCategoryGroupID int = 1

	DECLARE @ActivityCategoryName [nvarchar](255),
			@IsCore [nvarchar](255) ,
			@Region [nvarchar](255) ,
			@State [nvarchar](255) ,
			@City [nvarchar](255) 

	-- Check if PlatformType is created, else create
	IF NOT EXISTS (select 1 from [org].[Platform] p where p.CompanyID = @CompanyID and p.[PlatformName] = 'Windows')
	BEGIN

		INSERT INTO [org].[Platform](CompanyID, PlatformName, [PlatformVersion], PlatformDescription, IsActive, ModifiedBy)
		VALUES (@CompanyID, 'Windows', 'Windows', 'All Windows', 1, 'System')

	END

	IF NOT EXISTS (select 1 from [org].[Platform]  p where p.CompanyID = @CompanyID and p.[PlatformName] = 'Linux')
	BEGIN

		INSERT INTO [org].[Platform](CompanyID, PlatformName, [PlatformVersion], PlatformDescription, IsActive, ModifiedBy)
		VALUES (@CompanyID, 'Linux', 'Linux', 'Ubuntu', 1, 'System')

	END
	

	INSERT INTO #ImportActivityCategory (ActivityCategoryName, IsCore)

	select TRIM(i.ActivityCategoryName), i.IsCore
	from dbo.ImportActivityCategory i
	where
		i.CompanyID = @CompanyID and i.PushedInMaster = 0

	set @CountOfRows = @@ROWCOUNT

	----================ Start Validate Data =======================

	if (@CountOfRows = 0)
	begin

		select 'Nothing To Add' EmptyImport
		return

	end

	-- Check Dup Rows

	UPDATE i
	SET
		i.ActivityCategoryName = 'Meetings' 
	FROM #ImportActivityCategory i
	WHERE
		i.ActivityCategoryName = 'Meeting'

	select ActivityCategoryName, count(1) DupRows into #DupRows
	from #ImportActivityCategory l
	group by ActivityCategoryName
	having
		count(1) > 1

	IF ( @@ROWCOUNT > 0 )
	BEGIN

	SET @ErrorValidation = @ErrorValidation + 'One or more Duplicate Rows Found' + CHAR(10)
		
		SELECT 'Duplicate Rows' 'Duplicate Rows'
		SELECT * FROM #DupRows DuplicateRows

	END 

	----================ End Validate Data =======================

	IF (@ErrorValidation <> '')
	BEGIN

		--PRINT @ErrorValidation
		RAISERROR (
				@ErrorValidation,
				16,
				16    
			);
		
		RETURN

	END
	
	ELSE
	
	BEGIN -- ( Validation Passes )

		----SELECT @MaxActivityCategoryIdForCompany = ISNULL(MAX(l.ActivityCategoryID), 0)
		----FROM  [MD].[ActivityCategory] l WHERE l.CompanyID = @CompanyID

		
			
		BEGIN TRAN TranUpsert
		BEGIN TRY

		---IF @MaxActivityCategoryIdForCompany = 0
		---BEGIN
		---
		---	-- Add Meeting as Default
		---	INSERT INTO [MD].[ActivityCategory]
		---				   (	
		---						[CompanyID]
		---						,[ActivityCategoryGroupID]
		---					   ,[ActivityCategoryID]
		---					   ,[ActivityCategoryTypeID]
		---					   ,[PlatformTypeID]
		---					   ,[ActivityCategoryGroupName]
		---					   ,[ActivityCategoryName]
		---					   ,[IsCore]
		---					   ,[IsSystemDefined]
		---					   ,[IsConfigurable]
		---					   ,[IsGlobal]
		---					   ,[DateCreated]
		---					   ,[IsActive]	
		---					)
		---
		---			values (@CompanyID, @ActivityCategoryGroupID, 5, 1, 1, 'Global',
		---				'Meetings', 0, 1, 1, 1, GETUTCDATE(), 1)
		---
		---
		---
		---			-- Add Miscellaneous as Default
		---	INSERT INTO [MD].[ActivityCategory]
		---				   (	
		---						[CompanyID]
		---						,[ActivityCategoryGroupID]
		---					   ,[ActivityCategoryID]
		---					   ,[ActivityCategoryTypeID]
		---					   ,[PlatformTypeID]
		---					   ,[ActivityCategoryGroupName]
		---					   ,[ActivityCategoryName]
		---					   ,[IsCore]
		---					   ,[IsSystemDefined]
		---					   ,[IsConfigurable]
		---					   ,[IsGlobal]
		---					   ,[DateCreated]
		---					   ,[IsActive]	
		---					)
		---
		---			values (@CompanyID, @ActivityCategoryGroupID, 100, 1, 1, 'Global',
		---				'Miscellaneous', 0, 1, 1, 1, GETUTCDATE(), 1)
		---
		---END
		SET IDENTITY_INSERT [org].[ActivitySpec] ON	
		

		IF NOT EXISTS (SELECT ActivitySpecID FROM [org].[ActivitySpec] WHERE CompanyID=@CompanyID AND ActivitySpecID = -1)
		BEGIN
			INSERT INTO [org].[ActivitySpec] ([CompanyID], [ActivitySpecID], [ActivitySpecName], [ActivitySpecDescription], [IsCore], [IsSystemDefined], [IsWorkCategory], [IsDefault], [IsActive], [ModifiedBy])
			VALUES(@CompanyID, -1, 'Private', null, 0, 1, 0, 0, 1, 'System')
		END

		IF NOT EXISTS (SELECT ActivitySpecID FROM [org].[ActivitySpec] WHERE CompanyID=@CompanyID AND ActivitySpecID = 5)
		BEGIN
			INSERT INTO [org].[ActivitySpec] ([CompanyID], [ActivitySpecID], [ActivitySpecName], [ActivitySpecDescription], [IsCore], [IsSystemDefined], [IsWorkCategory], [IsDefault], [IsActive], [ModifiedBy])
			VALUES(@CompanyID, 5, 'Meetings', null, 0, 1, 1, 0, 1, 'System')
		END

		IF NOT EXISTS (SELECT ActivitySpecID FROM [org].[ActivitySpec] WHERE CompanyID=@CompanyID AND ActivitySpecID = 100)
		BEGIN
			INSERT INTO [org].[ActivitySpec] ([CompanyID], [ActivitySpecID], [ActivitySpecName], [ActivitySpecDescription], [IsCore], [IsSystemDefined], [IsWorkCategory], [IsDefault], [IsActive], [ModifiedBy])
			VALUES(@CompanyID, 100, 'Miscellaneous', null, 0, 1, 1, 0, 1, 'System')
		END

			SET IDENTITY_INSERT [org].[ActivitySpec] OFF


		WHILE (@CurrentRowID < @CountOfRows)
		begin
		
			set @CurrentRowID = @CurrentRowID + 1

			select  @ActivityCategoryName = i.ActivityCategoryName, @IsCore = i.IsCore
			from	#ImportActivityCategory i 
			where i.ID = @CurrentRowID

			
				IF NOT EXISTS 
				(
					select 1 from [org].[ActivitySpec] l where l.CompanyID = @CompanyID and l.ActivitySpecName = @ActivityCategoryName
				)

				begin
				
					---set @MaxActivityCategoryIdForCompany = @MaxActivityCategoryIdForCompany + 1
					---
					---if (@MaxActivityCategoryIdForCompany = 5) -- Skip by 1..5 is reserved for Meeting
					---SET
					---	@MaxActivityCategoryIdForCompany = 6
					---
					---if (@MaxActivityCategoryIdForCompany = 100) -- Skip by 1..5 is reserved for Meeting
					---SET
					---	@MaxActivityCategoryIdForCompany = 101


					INSERT INTO [org].[ActivitySpec]
						   (	
								[CompanyID]
								,[ActivitySpecName]
							   ,[ActivitySpecDescription]
							   ,[IsCore]
							   ,[IsSystemDefined]
							   ,[IsWorkCategory]
							   ,[IsDefault]
							   ,[IsActive]
							   ,[ModifiedBy]
							)
	
					values (@CompanyID, @ActivityCategoryName, @ActivityCategoryName, @IsCore, 0, 1,
						1, 1, 'System')
					
			
				end
				else begin -- Update, ActivityCategory exists

					update l 
					set
					
						l.IsCore = @IsCore,
						l.IsActive = 1
				
					from [org].[ActivitySpec] l 
					where 
						l.CompanyID = @CompanyID and l.ActivitySpecName = @ActivityCategoryName

				end

				update l 
				set
					l.PushedInMaster = 1
				from [dbo].[ImportActivityCategory] l 
				where 
					l.CompanyID = @CompanyID and l.ActivityCategoryName = @ActivityCategoryName

			
		END

		COMMIT TRAN TranUpsert
		END TRY
		BEGIN CATCH
		 
		ROLLBACK TRAN TranUpsert 

		SELECT 
			@ExceptionMessage = ERROR_MESSAGE(),
			@ExceptionSeverity = ERROR_SEVERITY(),
			@ExceptionState = ERROR_STATE();
			RAISERROR (
					@ExceptionMessage,
					@ExceptionSeverity,
					@ExceptionState    
				);
			 	
		END CATCH	

		select 'List of successfully Added ActivityCategory' AddSuccess

		select i.ActivityCategoryName, i.IsCore
		from dbo.ImportActivityCategory i
		where
			i.CompanyID = @CompanyID and i.PushedInMaster = 1

		select 'List of Failed To Add ActivityCategory' AddFailed

		select i.ActivityCategoryName, i.IsCore
		from dbo.ImportActivityCategory i
		where
			i.CompanyID = @CompanyID and i.PushedInMaster = 0

	end

	drop table #DupRows
	drop table #ImportActivityCategory

END

GO
/****** Object:  StoredProcedure [dbo].[sproc_AddImportedDepartments]    Script Date: 8/20/2021 4:27:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sproc_AddImportedDepartments]

(
	@CompanyID INT, 
	@Debug tinyint = 0
)
AS 
BEGIN
    SET NOCOUNT ON
	SET DATEFIRST 1


		DECLARE  @ExceptionMessage NVARCHAR(4000) = '',
			@ExceptionSeverity INT = 0,
			@ExceptionState INT = 0,
			@ErrorValidation NVARCHAR(MAX) = '',
			@Step NVARCHAR(4000) = ''


	CREATE TABLE #ImportDepartments (
		[ID] [integer] identity(1,1) NOT NULL,
		[DepartmentCode] [nvarchar](255) NOT NULL,
		[DepartmentName] [nvarchar](255) NULL,
		[ManagerEmail] [nvarchar](255) NULL,
	
	)

	DECLARE @CountOfRows int = 0, @CurrentRowID int = 0, @CountOfDuplicateDepartments int = 0, @MaxDepartmentIdForCompany int = 0, @IsActive int = 1
	DECLARE @DepartmentCode [nvarchar](255),
			@DepartmentName [nvarchar](255),
			@ManagerEmail [nvarchar](255),
			@ManagerUserID int


	INSERT INTO #ImportDepartments (DepartmentCode, DepartmentName, ManagerEmail)

	SELECT i.DepartmentCode, i.DepartmentName, i.ManagerEmail
	from dbo.ImportDepartment i
	where
		i.CompanyID = @CompanyID and i.PushedInMaster = 0

	set @CountOfRows = @@ROWCOUNT

	

	----================ Start Validate Data =======================

	if (@CountOfRows = 0)
	begin

		select 'Nothing To Add' EmptyImport
		return

	end

	-- Check Dup Rows

	select DepartmentCode, count(1) DupRows into #DupRows
	from #ImportDepartments l
	group by DepartmentCode
	having
		count(1) > 1

	
	if ( @@ROWCOUNT > 0 )
	begin
		
		set @ErrorValidation = @ErrorValidation + 'One or more Duplicate Rows found' + CHAR(10)
		
		select 'Duplicate Rows' 'Duplicate Rows'
		select * from #DupRows DuplicateRows
	

	end 

	-- Check if Manager email exists

	SELECT * INTO #ManagersNotUsers
	FROM #ImportDepartments d WHERE 
		NOT EXISTS (SELECT 1 FROM org.Users u WHERE u.CompanyID = @CompanyID and u.UserEmail = d.ManagerEmail)

	IF (@@ROWCOUNT > 0)
	BEGIN
	
		set @ErrorValidation = @ErrorValidation + ' One or more managers do not exist as Users ' + CHAR(10)
		
		select 'Managers Not as Users' 'Managers Not Users'
		select * from #ManagersNotUsers ManagersNotUsers
	
	
	END	

	-- check if email is valid

	SELECT * INTO #InvalidEmailIdsForManagers
	FROM #ImportDepartments d 
	WHERE d.ManagerEmail NOT LIKE '%_@__%.__%' 

	IF (@@ROWCOUNT > 0)
	BEGIN
	
		set @ErrorValidation = @ErrorValidation + ' One or more managers have invalid email ids ' + CHAR(10)
		
		select 'Invalid EmaildIds for Managers' 'Invalid Email Ids For Managers'
		select * from #InvalidEmailIdsForManagers 
		
	
	END	

	----================ End Validate Data =======================

	IF (@ErrorValidation <> '')
	BEGIN

		--PRINT @ErrorValidation
		RAISERROR (
				@ErrorValidation,
				16,
				16    
			);
		
		RETURN

	END
	
	ELSE
	
	BEGIN -- ( Validation Passes )

		----select @MaxDepartmentIdForCompany = ISNULL(MAX(l.DepartmentID), 0)
		----from  [MD].[Department] l where l.CompanyID = @CompanyID

		begin tran TranUpsert
		begin try


		while (@CurrentRowID < @CountOfRows)
		begin
		
			set @CurrentRowID = @CurrentRowID + 1

			select  @DepartmentCode = i.DepartmentCode, @DepartmentName = i.DepartmentName, 
					@ManagerEmail = i.ManagerEmail 
			from	#ImportDepartments i 
			where i.ID = @CurrentRowID

			SELECT @ManagerUserID = u.UserID
			FROM [org].Users u
			WHERE
				u.CompanyID = @CompanyID and u.UserEmail = @ManagerEmail

		
				if not exists 
				(
					select 1 from [org].Department l where l.CompanyID = @CompanyID and l.DepartmentCode = @DepartmentCode
				)

				begin
				
					set @MaxDepartmentIdForCompany = @MaxDepartmentIdForCompany + 1
					INSERT INTO [org].Department
						   ([CompanyID]
						   ,[DepartmentCode]
						   ,[DepartmentName]
						   ,[DepartmentDescription]
						   ,[DepartmentOwnerID]
						   ,IsEmployeeActivityVisible
						   ,IsActive
						   ,ModifiedBy)
	
					values (@CompanyID, @DepartmentCode, @DepartmentName, @DepartmentName, @ManagerUserID, null, @IsActive, 'System')

					
				END
				ELSE BEGIN -- Update, Department exists

					update d 
					set
					
						d.DepartmentName = @DepartmentName,
						d.DepartmentOwnerID = @ManagerUserID
					
					from [org].Department d 
					where 
						d.CompanyID = @CompanyID and d.DepartmentCode = @DepartmentCode

				end


				-- Do we need this?
				-- Prevent User in Multiple departments

					--IF EXISTS (SELECT 1 FROM [md].[UserDepartmentHistory] h WHERE h.CompanyID = @CompanyID
					--	AND h.UserID = @ManagerUserID and h.EndDate IS NOT NULL)
					--BEGIN
					
					--	UPDATE h 
					--	SET
					--		h.EndDate = DATEADD(DAY, -1, GETUTCDATE())
					--		,h.IsCurrent = 0							
					--	FROM  [md].[UserDepartmentHistory] h
					--	WHERE h.CompanyID = @CompanyID AND h.UserID = @ManagerUserID and h.EndDate IS NOT NULL

					--END 

					-- Remove Previous Department manager
					--IF EXISTS (SELECT 1 FROM [md].[UserDepartmentHistory] h WHERE h.CompanyID = @CompanyID
					-- h.DepartmentID = @MaxDepartmentIdForCompany
					--AND h.EndDate IS NULL)

					--UPDATE h 
					--SET
					--	h.IsManager = 0
					--FROM  [md].[UserDepartmentHistory] h
					--WHERE h.CompanyID = @CompanyID AND h.DepartmentID = @MaxDepartmentIdForCompany and h.IsManager = 1 and h.UserID <> @ManagerUserID and h.EndDate IS NULL

					-- Add or Promote user as Department manager

					----IF EXISTS ( SELECT 1 FROM [md].[UserDepartmentHistory] h WHERE h.CompanyID = @CompanyID
					----	AND h.UserID = @ManagerUserID and h.DepartmentID = @MaxDepartmentIdForCompany )
					----BEGIN
					----
					----	UPDATE h 
					----	SET
					----		h.IsManager = 1
					----		,h.IsCurrent = 0
					----		,h.EndDate = NULL							
					----	FROM  [md].[UserDepartmentHistory] h
					----	WHERE h.CompanyID = @CompanyID AND h.DepartmentID = @MaxDepartmentIdForCompany AND  h.UserID = @ManagerUserID 
					----
					----END 
					---ELSE 
					---BEGIN
					---	
					---		INSERT INTO [MD].[UserDepartmentHistory]
					---	   ([CompanyID] ,[DepartmentID] ,[UserID] ,[StartDate] ,[EndDate] ,[IsManager] ,[IsCurrent])
					---	    
					---		VALUES
					---		   ( @CompanyID, @MaxDepartmentIdForCompany, @ManagerUserID, GETUTCDATE(), NULL, 1, 1 )

					---END

				UPDATE l 
				SET
					l.PushedInMaster = 1
				FROM [dbo].[ImportDepartment] l 
				WHERE 
					l.CompanyID = @CompanyID and l.DepartmentCode = @DepartmentCode

			
		END

		 COMMIT TRAN TranUpsert
			 END TRY
			 BEGIN CATCH
		 
					ROLLBACK TRAN TranUpsert 

					SELECT 
						@ExceptionMessage = ERROR_MESSAGE(),
						@ExceptionSeverity = ERROR_SEVERITY(),
						@ExceptionState = ERROR_STATE();
					RAISERROR (
							@ExceptionMessage,
							@ExceptionSeverity,
							@ExceptionState    
						);
		 
			 end catch	

		select 'List of Departments added successfully' AddSuccess

		select i.DepartmentCode, i.DepartmentName, i.ManagerEmail
		from dbo.ImportDepartment i
		where
			i.CompanyID = @CompanyID and i.PushedInMaster = 1


		select 'List of Failed To Add Departments' AddFailed

		select i.DepartmentCode, i.DepartmentName, i.ManagerEmail
		from dbo.ImportDepartment i
		where
			i.CompanyID = @CompanyID and i.PushedInMaster = 0

	end

	drop table #DupRows
	drop table #ImportDepartments

END

GO
/****** Object:  StoredProcedure [dbo].[sproc_AddImportedEmployeeTitle]    Script Date: 8/20/2021 4:27:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sproc_AddImportedEmployeeTitle]
(
	@CompanyID INT, 
	@Debug tinyint = 0
)
AS 
BEGIN
    SET NOCOUNT ON
	SET DATEFIRST 1


	DECLARE  @ExceptionMessage NVARCHAR(4000) = '',
	@ExceptionSeverity INT = 0,
	@ExceptionState INT = 0,
	@ErrorValidation NVARCHAR(MAX) = '',
	@Step NVARCHAR(4000) = ''


	CREATE TABLE #ImportEmployeeTitles (
		[ID] [integer] identity(1,1) NOT NULL,
		[EmployeeTitleCode] [nvarchar](255) NOT NULL,
		EmployeeTitle [nvarchar](255) NOT NULL,
	
	)

	DECLARE @CountOfRows int = 0, @CurrentRowID int = 0, @CountOfDuplicateLocations int = 0, @MaxTitleIDForCompany int = 0
	DECLARE @EmployeeTitleCode [nvarchar](255),
			@EmployeeTitle [nvarchar](255) 
			

	INSERT INTO #ImportEmployeeTitles (EmployeeTitleCode, EmployeeTitle)

	select i.EmployeeTitleCode, i.EmployeeTitle
	from dbo.ImportEmployeeTitle i
	where
		i.CompanyID = @CompanyID and i.PushedInMaster = 0

	set @CountOfRows = @@ROWCOUNT

		----================ Start Validate Data =======================

	if (@CountOfRows = 0)
	begin

		select 'Nothing To Add' EmptyImport
		return

	end

		-- Check Dup Rows

	select l.EmployeeTitleCode, count(1) DupRows into #DupRows
	from #ImportEmployeeTitles l
	group by l.EmployeeTitleCode
	having
		count(1) > 1

	if ( @@ROWCOUNT > 0 )
	begin
		
		set @ErrorValidation = @ErrorValidation + 'One or more Duplicate Rows found' + CHAR(10)
		
		select 'Duplicate Rows' 'Duplicate Rows'
		select * from #DupRows DuplicateRows
	

	end 

		----================ End Validate Data =======================

	IF (@ErrorValidation <> '')
	BEGIN

		--PRINT @ErrorValidation
		RAISERROR (
				@ErrorValidation,
				16,
				16    
			);
		
		RETURN

	END
	
	ELSE
	
	BEGIN -- ( Validation Passes )

		select @MaxTitleIDForCompany = ISNULL(MAX(l.EmployeeTitleID), 0)
		from  [MD].[EmployeeTitle] l where l.CompanyID = @CompanyID


		BEGIN TRAN TranUpsert
		BEGIN TRY


		WHILE (@CurrentRowID < @CountOfRows)
		BEGIN
		
			set @CurrentRowID = @CurrentRowID + 1

			select  @EmployeeTitleCode = i.EmployeeTitleCode, @EmployeeTitle = i.EmployeeTitle
			from	#ImportEmployeeTitles i 
			where i.ID = @CurrentRowID

		
				if not exists 
				(
					select 1 from [org].[JobFamilyActivityOverrideProfile] l where l.CompanyID = @CompanyID and l.JobFamilyName = @EmployeeTitleCode
				)

				BEGIN
				
					set @MaxTitleIDForCompany = @MaxTitleIDForCompany + 1
					INSERT INTO [org].[JobFamilyActivityOverrideProfile]
						   ([CompanyID]
						   ,[JobFamilyName]
						   ,[JobFamilyDescription]
						   ,[IsActive]
						   ,[ModifiedBy]
						    )
	
					values (@CompanyID, @EmployeeTitleCode, @EmployeeTitle, 1, 'System')

				END
				ELSE BEGIN -- Update, Location exists

					update l 
					set
					
						l.JobFamilyDescription = @EmployeeTitle
					from [org].[JobFamilyActivityOverrideProfile] l 
					where 
						l.CompanyID = @CompanyID and l.JobFamilyName = @EmployeeTitleCode

				end

				update l 
				set
					l.PushedInMaster = 1
				from [dbo].[ImportEmployeeTitle] l 
				where 
					l.CompanyID = @CompanyID and l.EmployeeTitleCode = @EmployeeTitleCode

			
		end

		COMMIT TRAN TranUpsert
		END TRY
		BEGIN CATCH
		 
			ROLLBACK TRAN TranUpsert 

	
			SELECT 
					@ExceptionMessage = ERROR_MESSAGE(),
					@ExceptionSeverity = ERROR_SEVERITY(),
					@ExceptionState = ERROR_STATE();
				RAISERROR (
						@ExceptionMessage,
						@ExceptionSeverity,
						@ExceptionState    
					);
		 
		 
		END CATCH	

		select 'List of Successfully Added Rows' AddSuccess

		select i.EmployeeTitleCode, i.EmployeeTitle
		from dbo.ImportEmployeeTitle i
		where
			i.CompanyID = @CompanyID and i.PushedInMaster = 1

		select 'List of Failed To Add Rows' AddFailed

		select i.EmployeeTitleCode, i.EmployeeTitle
		from dbo.ImportEmployeeTitle i
		where
			i.CompanyID = @CompanyID and i.PushedInMaster = 0

	end

	drop table #DupRows
	drop table #ImportEmployeeTitles

END

GO
/****** Object:  StoredProcedure [dbo].[sproc_AddImportedLocations]    Script Date: 8/20/2021 4:27:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sproc_AddImportedLocations]

(
	@CompanyID INT, 
	@Debug tinyint = 0
)
AS 
BEGIN
    SET NOCOUNT ON
	SET DATEFIRST 1

	DECLARE 
		@ExceptionMessage NVARCHAR(4000) = '',
		@ExceptionSeverity INT = 0,
		@ExceptionState INT = 0,
		@ErrorValidation NVARCHAR(MAX) = '',
		@Step NVARCHAR(4000) = ''

	CREATE TABLE #ImportLocations (
		[ID] [integer] identity(1,1) NOT NULL,
		[LocationName] [nvarchar](255) NOT NULL,
		[Country] [nvarchar](255) NULL,
		[Region] [nvarchar](255) NULL,
		[State] [nvarchar](255) NULL,
		[City] [nvarchar](255) NULL,
	
	)

	DECLARE @CountOfRows int = 0, @CurrentRowID int = 0, @CountOfDuplicateLocations int = 0, @MaxLocationIdForCompany int = 0
	DECLARE @LocationName [nvarchar](255),
			@Country [nvarchar](255) ,
			@Region [nvarchar](255) ,
			@State [nvarchar](255) ,
			@City [nvarchar](255) 


	INSERT INTO #ImportLocations (LocationName, Country, Region, State, City)

	SELECT i.LocationName, i.Country, i.Region, i.State, i.City
	from dbo.ImportLocation i
	where
		i.CompanyID = @CompanyID and i.PushedInMaster = 0

	set @CountOfRows = @@ROWCOUNT

	----================ Start Validate Data =======================

	if (@CountOfRows = 0)
	begin

		select 'Nothing To Add' EmptyImport
		return

	end

	-- Check Dup Rows

	select LocationName, count(1) DupRows into #DupRows
	from #ImportLocations l
	group by LocationName
	having
		count(1) > 1

	if ( @@ROWCOUNT > 0 )
	begin

	set @ErrorValidation = @ErrorValidation + 'One or more Duplicate Rows Found' + CHAR(10)
		
		select 'Duplicate Rows' 'Duplicate Rows'
		select * from #DupRows DuplicateRows

	end 

	----================ End Validate Data =======================

	IF (@ErrorValidation <> '')
	BEGIN

		--PRINT @ErrorValidation
		RAISERROR (
				@ErrorValidation,
				16,
				16    
			);
		
		RETURN

	END
	
	ELSE
	
	BEGIN -- ( Validation Passes )

		select @MaxLocationIdForCompany = ISNULL(MAX(l.LocationID), 0)
		from  [MD].[Location] l where l.CompanyID = @CompanyID

		BEGIN TRAN LocUpsert
		BEGIN TRY

		WHILE (@CurrentRowID < @CountOfRows)
		BEGIN
		
			SET @CurrentRowID = @CurrentRowID + 1

			select  @LocationName = i.LocationName, @Country = i.Country, 
					@Region = i.Region, @State = i.State, @City = i.City 
			from	#ImportLocations i 
			WHERE i.ID = @CurrentRowID

				if not exists 
				(
					select 1 from [org].[Location] l where l.CompanyID = @CompanyID and l.LocationName = @LocationName
				)

				BEGIN

				----SET IDENTITY_INSERT [org].[Location] ON		
				
					set @MaxLocationIdForCompany = @MaxLocationIdForCompany + 1
					INSERT INTO [Org].[Location]
						   ([CompanyID]
						   ---,[LocationID]
						   ,[LocationName]
						   ,[City]
						   ,[Country]
						   ,[Statoid]
						   ,[LocationExtra]
						   ,[IsActive]
						   ,[MOdifiedBy])
	
					values (@CompanyID-----, @MaxLocationIdForCompany
					, @LocationName, @City, @Country, @State, @Region, 1, 'System')


					-----SET IDENTITY_INSERT [org].[Location] OFF	

				end
				else begin -- Update, Location exists

					update l 
					set
					
						l.[Country] = @Country,
						l.[Statoid] = @State,
						l.[City] = @City,
						l.[LocationExtra] = @Region
				
					from [org].[Location] l 
					where 
						l.CompanyID = @CompanyID and l.LocationName = @LocationName

				end

				update l 
				set
					l.PushedInMaster = 1
				from [dbo].[ImportLocation] l 
				where 
					l.CompanyID = @CompanyID and l.LocationName = @LocationName

			
		end

		COMMIT TRAN LocUpsert
		END TRY
		BEGIN CATCH
		 
			ROLLBACK TRAN LocUpsert 

	
			SELECT 
				@ExceptionMessage = ERROR_MESSAGE(),
				@ExceptionSeverity = ERROR_SEVERITY(),
				@ExceptionState = ERROR_STATE();
				RAISERROR (
						@ExceptionMessage,
						@ExceptionSeverity,
						@ExceptionState    
					);
		 
		END CATCH	

		select 'List of Rows added successfully' AddSuccess

		select i.LocationName, i.Country, i.Region, i.State, i.City
		from dbo.ImportLocation i
		where
			i.CompanyID = @CompanyID and i.PushedInMaster = 1

		select 'List of Failed To Add Rows' AddFailed

		select i.LocationName, i.Country, i.Region, i.State, i.City
		from dbo.ImportLocation i
		where
			i.CompanyID = @CompanyID and i.PushedInMaster = 0

	end

	drop table #DupRows
	drop table #ImportLocations

END

GO
/****** Object:  StoredProcedure [dbo].[sproc_AddImportedUsers]    Script Date: 8/20/2021 4:27:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE    PROCEDURE [dbo].[sproc_AddImportedUsers]

(
	@CompanyID INT, 
	@Debug tinyint = 0
)
AS 
BEGIN
    SET NOCOUNT ON
	SET DATEFIRST 1

			DECLARE  @ExceptionMessage NVARCHAR(4000) = '',
			@ExceptionSeverity INT = 0,
			@ExceptionState INT = 0,
			@ErrorValidation NVARCHAR(MAX) = '',
			@Step NVARCHAR(4000) = '',

			@IsActive INT = 1;


	CREATE TABLE #ImportUsers (
		[ID] [int] identity(1,1) NOT NULL,
		[FirstName] [nvarchar](255) NOT NULL,
		[MiddleName] [nvarchar](255) NULL,
		[LastName] [nvarchar](255) NULL,
		[UserEmail] [nvarchar](255) NOT NULL,
		[EmployeeCode] [nvarchar](255) NULL,
		[ReportsToUserEmail] [nvarchar](255) NULL,
		[Location] [nvarchar](255) NOT NULL,
		[EmployeeTitleCode] [nvarchar](255) NOT NULL,
		[DomainName] [nvarchar](255) NOT NULL,
		[DomainUserID] [nvarchar](255) NOT NULL,
		[JobTitle] [nvarchar](255) NOT NULL,
		[ReportsToUserID] [INT] NOT NULL DEFAULT (1),
	)


	DECLARE @CountOfRows int = 0, @CurrentRowID int = 0, @CountOfDuplicateUsers int = 0, @MaxUserIdForCompany int = 0, @JobFamilyID int = 0, @LocationID int =0, @MDomain_Userid int =0 ,@WorkScheduleID int = 0
	DECLARE @FirstName [nvarchar](255),
			@MiddleName [nvarchar](255) ,
			@LastName [nvarchar](255) ,
			@UserEmail [nvarchar](255) ,
			@EmployeeCode [nvarchar](255) ,
			@ReportsToUserEmail [nvarchar](255),
			@Location [nvarchar](255) ,
			@EmployeeTitleCode [nvarchar](255) ,
			@DomainName [nvarchar](255) ,
			@DomainUserID [nvarchar](255) ,
			@JobTitle [nvarchar](255)


			---- Select * from dbo.ImportUsers

	INSERT INTO #ImportUsers (FirstName, MiddleName, LastName, UserEmail, EmployeeCode, ReportsToUserEmail, Location, EmployeeTitleCode, DomainName, DomainUserID, JobTitle)

	SELECT TRIM(i.FirstName), TRIM(i.MiddleName), TRIM(i.LastName), TRIM(i.UserEmail), TRIM(i.EmployeeCode), TRIM(i.ReportsToUserEmail), TRIM(i.Location), TRIM(i.EmployeeTitleCode), TRIM(i.DomainName), TRIM(i.DomainUserID), TRIM(i.JobTitle)
	FROM dbo.ImportUsers i
	WHERE
		i.CompanyID = @CompanyID and i.PushedInMaster = 0 --and i.UserEmail like '%_@__%.__%' 

	set @CountOfRows = @@ROWCOUNT


		----================ Start Validate Data =======================

	if (@CountOfRows = 0)
	begin

		select 'Nothing To Add' EmptyImport
		return

	end

	-- Check Dup Rows

	SELECT UserEmail, count(1) DupRows into #DupRows
	FROM #ImportUsers l
	GROUP BY UserEmail
	HAVING
		count(1) > 1

	if ( @@ROWCOUNT > 0 )
	BEGIN
		
		set @ErrorValidation = @ErrorValidation + 'One or more Duplicate UserEmail Rows found' + CHAR(10)
		
		select 'Duplicate UserEmail Rows' 'Duplicate UserEmail Rows'
		SELECT * FROM #DupRows DuplicateRows
	

	END 

	SELECT EmployeeCode, count(1) DupRows into #DupEmpCodeRows
	FROM #ImportUsers l
	WHERE
		l.EmployeeCode IS NOT NULL
	GROUP BY EmployeeCode
	HAVING
		count(1) > 1

	if ( @@ROWCOUNT > 0 )
	BEGIN
		
		set @ErrorValidation = @ErrorValidation + 'One or more Duplicate EmpCode Rows found' + CHAR(10)
		
		select 'Duplicate EmpCode Rows' 'Duplicate EmpCode Rows'
		SELECT * FROM #DupEmpCodeRows DuplicateEmpCodeRows
	

	END 


	-- check if email is valid

	SELECT * INTO #InvalidEmailIds
	FROM #ImportUsers d 
	WHERE d.UserEmail NOT LIKE '%_@_%._%' OR d.ReportsToUserEmail NOT LIKE '%_@_%._%' 

	IF (@@ROWCOUNT > 0)
	BEGIN
	
		set @ErrorValidation = @ErrorValidation + ' One or more user or ReportsTo have invalid email ids ' + CHAR(10)
		
		select 'Invalid EmailIds for Users Or ReportsTo' 'Invalid EmailIds for Users Or ReportsTo'
		SELECT * FROM #InvalidEmailIds 
	
	END	
	
	--====================

	IF (@ErrorValidation <> '')
	BEGIN

		--PRINT @ErrorValidation
		RAISERROR (
				@ErrorValidation,
				16,
				16    
			);
		
		RETURN

	END
	
		ELSE
	
	BEGIN -- ( Validation Passes )

			SELECT @MaxUserIdForCompany = ISNULL(MAX(l.UserID), 0)
			from  [org].[Users] l where l.CompanyID = @CompanyID


			BEGIN TRAN TranUpsert
			BEGIN TRY

			while (@CurrentRowID < @CountOfRows)
			begin



						---- Varaible assighnment
						set @CurrentRowID = @CurrentRowID + 1

						select  @FirstName = i.FirstName, @MiddleName = i.MiddleName, @LastName = i.LastName, @UserEmail = i.UserEmail, 
									@EmployeeCode = i.EmployeeCode, @ReportsToUserEmail = i.ReportsToUserEmail, @Location = i.Location,
								@EmployeeTitleCode = i.EmployeeTitleCode, @DomainName = i.DomainName, @DomainUserID = i.DomainUserID
								, @JobTitle = i.JobTitle
						from	#ImportUsers i 
						where i.ID = @CurrentRowID


						 -------Default WorkSchedule
						if not exists 
						(
							select 1 from [org].[WorkSchedule] l where l.CompanyID = @CompanyID and	l.WorkScheduleName = 'Regular Schedule'
						)
						begin
									
							
							
							select	@CompanyID as CompanyID
							,'Regular Schedule' as WorkScheduleName
		 					,'Company regular work week' as WorkScheduleDescription
		 					,1 as IsDefault
		 					,40 WorkWeekTotalHours
		 					,0 IsWorkWeekCustom
		 					,0 IsSunWorkDay
		 					,1 IsMonWorkDay
		 					,1 IsTueWorkDay
		 					,1 IsWedWorkDay
		 					,1 IsThuWorkDay
		 					,1 IsFriWorkDay
		 					,0 IsSatWorkDay
		 					,1 ReportNonWorkDayActivityAsWork
		 					,1 IsActive
		 					,'System' as ModifiedBy INTO #TempWorkSchedule
							From [org].[Company] a WHere a.CompanyID = @CompanyID
							
							
							INSERT INTO [org].[WorkSchedule]([CompanyID],[WorkScheduleName],[WorkScheduleDescription],[IsDefault],[WorkWeekTotalHours],[IsWorkWeekCustom],[IsSunWorkDay],[IsMonWorkDay],[IsTuesWorkDay],[IsWedWorkDay],[IsThuWorkDay],[IsFriWorkDay],[IsSatWorkDay],[ReportNonWorkDayActivityAsWork],[IsActive],[ModifiedBy])
		 					select b.CompanyID,b.WorkScheduleName,b.WorkScheduleDescription,b.IsDefault,b.WorkWeekTotalHours,b.IsWorkWeekCustom,b.IsSunWorkDay
							,b.IsMonWorkDay,b.IsTueWorkDay,b.IsWedWorkDay,b.IsThuWorkDay,b.IsFriWorkDay,b.IsSatWorkDay,b.ReportNonWorkDayActivityAsWork,b.IsActive,b.ModifiedBy
							FROM #TempWorkSchedule b
							
									
								
						end
									
						select @WorkScheduleID = l.WorkScheduleID
						from  [org].[WorkSchedule] l where l.CompanyID = @CompanyID and l.WorkScheduleName = 'Regular Schedule'




					    -------Start of EMployee Title Addition
						if not exists 
						(
							select 1 from [org].[JobFamilyActivityOverrideProfile] l where l.CompanyID = @CompanyID and	l.JobFamilyName = @EmployeeTitleCode
						)
						begin
									
									
							INSERT INTO [org].[JobFamilyActivityOverrideProfile]
							   ([CompanyID]
							   ,[JobFamilyName]
							   ,[JobFamilyDescription]
							   ,[IsActive]
							   ,[ModifiedBy]
							    )
	
						values (@CompanyID, @EmployeeTitleCode, @EmployeeTitleCode, 1, 'System')
								
						end
									
						select @JobFamilyID = l.JobFamilyActivityOverrideProfileID
						from  [org].[JobFamilyActivityOverrideProfile] l where l.CompanyID = @CompanyID and l.JobFamilyName =	@EmployeeTitleCode


						----------Start of Location
						---
						---			
						---if not exists 
						---(
						---	select 1 from [org].[Location] l where l.CompanyID = @CompanyID and l.LocationName = @Location
						---)
						---BEGIN
						---
						---
						---INSERT INTO [Org].[Location]
						---	   ([CompanyID]
						---	   ,[LocationName]
						---	   ,[City]
						---	   ,[Country]
						---	   ,[Statoid]
						---	   ,[LocationExtra]
						---	   ,[IsActive]
						---	   ,[MOdifiedBy])
						---
						---values (@CompanyID, @Location, @City, @Country, @State, @Region, 1, 'System')
						---
						---
						---END
						
						SELECT @LocationID = l.LocationID
						FROM  [org].[Location] l WHERE l.CompanyID = @CompanyID and l.LocationName =	@Location


						-------Start of Users
						
		
						IF NOT EXISTS 
						(
							SELECT 1 FROM [org].[Users] l where l.CompanyID = @CompanyID and l.UserEmail = @UserEmail
						
						)
			
						begin

						set @MaxUserIdForCompany = @MaxUserIdForCompany + 1
								--Select @MaxUserIdForCompany as maxuserid


								INSERT INTO [org].[Users]
									([CompanyID],[DepartmentID],[UserActivityOverrideProfileID],[JobFamilyActivityOverrideProfileID],[LocationID]
									,[VendorID],[ExternalUserID],[UserEmail],[FirstName],[LastName],[JobTitle],[SisenseId],[Auth0Id],[IsFullTimeEmployee]
									,[IsActivityCollectionOn],[WorkScheduleID],[IsActive],[ModifiedBy],[TeamID])
								VALUES
									(@CompanyID, null, null, @JobFamilyID, @LocationID, null, null, @UserEmail, @FirstName, @LastName, @JobTitle, null,null , 1,
									1, @WorkScheduleID, 1, 'System', null)
						

						SELECT @MDomain_Userid = l.UserID
						FROM  [org].[Users] l WHERE l.CompanyID = @CompanyID and l.UserEmail =	@UserEmail

						INSERT INTO [org].[UserDomain]([CompanyID], [UserID], [UserName], [DomainName], [IsActive], [ModifiedBy])
						VALUES
						(@CompanyID, @MDomain_Userid, @DomainUserID, @DomainName, @IsActive, 'System')		


						END
						ELSE BEGIN


						UPDATE l 
							SET
							
	
								l.[FirstName] = @FirstName,
								l.[LastName] = @LastName,
								l.[JobFamilyActivityOverrideProfileID] = @JobFamilyID,
								l.LocationID = @LocationID,
								l.JobTitle = @JobTitle,
								l.ModifiedBy = 'System'			
							FROM [org].[Users] l 
							WHERE 
								l.CompanyID = @CompanyID and l.UserEmail = @UserEmail
				


						END	

			UPDATE l 
			SET
				l.PushedInMaster = 1
			FROM [dbo].[ImportUsers] l 
			WHERE 
				l.CompanyID = @CompanyID and l.UserEmail = @UserEmail

			
			END -- While Loop

			--- TeamID Population

			Select Distinct CompanyID, ReportsToUserEmail into #Team From [dbo].[ImportUsers] Where CompanyID = @CompanyID
			 
			Alter table #Team
			ADD DimUserID int,
			FirstName nvarchar(100),
			LastName  nvarchar(100),
			IsTeam int default(0)

			UPDATE T1
			SET T1.DimUserID = T2.UserID
			,T1.FirstName = T2.FirstName
			,T1.LastName = T2.LastName
			,T1.IsTeam = 0
			FROM #Team T1, org.users T2
			WHERE T1.CompanyID = T2.CompanyID AND T1.ReportsToUserEmail =  T2.UserEmail

			UPDATE T1
			SET T1.IsTeam = 1
			FROM #Team T1, [org].[Team] T2
			WHERE T1.CompanyID = T2.CompanyID AND CONCAT(SUBSTRING(T1.ReportsToUserEmail,0,charindex('@',T1.ReportsToUserEmail,0)),' Team') =  T2.TeamName
			


			INSERT INTO [org].[Team]
			([CompanyID], [ManagerID], [TeamName], [TeamDescription], [IsEmployeeActivityVisible], [ModifiedBy])
			Select CompanyID, DimUserID, CONCAT(SUBSTRING(ReportsToUserEmail,0,charindex('@',ReportsToUserEmail,0)),' Team'), null, 1, 'System' From #Team
			Where IsTeam = 0

			--- TeamID population on User Table
			
			Select CompanyID, UserEmail, ReportsToUserEmail INTO #ReportsToDetails From [dbo].[ImportUsers] Where CompanyID = @CompanyID


			ALTER Table #ReportsToDetails
			ADD TeamID int

			UPDATE T1
			SET T1.TeamID = T2.TeamID
			FROM #ReportsToDetails T1, org.Team T2
			WHERE T1.CompanyID = T2.CompanyID AND CONCAT(SUBSTRING(ReportsToUserEmail,0,charindex('@',ReportsToUserEmail,0)),' Team') =  T2.TeamName


			UPDATE T1
			SET T1.TeamID = T2.TeamID
			FROM [org].[Users] T1, #ReportsToDetails T2
			WHERE T1.CompanyID = T2.CompanyID AND T1.UserEMail = T2.UserEMail		


		COMMIT TRAN TranUpsert
		END TRY
		BEGIN CATCH
		 
			ROLLBACK TRAN TranUpsert 

			SELECT 
				@ExceptionMessage = ERROR_MESSAGE(),
				@ExceptionSeverity = ERROR_SEVERITY(),
				@ExceptionState = ERROR_STATE();
			RAISERROR (
				@ExceptionMessage,
				@ExceptionSeverity,
				@ExceptionState    
				);
		 
		END CATCH	

		select 'List of successfully Added Users' AddSuccess

		select i.FirstName, i.MiddleName, i.LastName, i.UserEmail, i.EmployeeCode, i.ReportsToUserEmail, i.Location, i.EmployeeTitleCode, i.DomainName, i.DomainUserID
		from dbo.ImportUsers i
		where
			i.CompanyID = @CompanyID and i.PushedInMaster = 1

		select 'List of Failed To Add Users' AddFailed

		select i.FirstName, i.MiddleName, i.LastName, i.UserEmail, i.EmployeeCode, i.ReportsToUserEmail, i.Location, i.EmployeeTitleCode, i.DomainName, i.DomainUserID
		from dbo.ImportUsers i
		where
			i.CompanyID = @CompanyID and i.PushedInMaster = 0

		select 'List of Invalid emailid' AddFailed
		select i.FirstName, i.MiddleName, i.LastName, i.UserEmail, i.EmployeeCode, i.ReportsToUserEmail, i.Location, i.EmployeeTitleCode, i.DomainName, i.DomainUserID
		from dbo.ImportUsers i
		where
		i.CompanyID = @CompanyID and i.PushedInMaster = 0 and i.UserEmail NOt like '%_@__%.__%' 



		END

END

GO
/****** Object:  StoredProcedure [dbo].[sproc_AddImportmultipleDomain]    Script Date: 8/20/2021 4:27:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sproc_AddImportmultipleDomain]

(
	@CompanyID INT, 
	@Debug tinyint = 0
)
AS 
BEGIN
    SET NOCOUNT ON
	SET DATEFIRST 1

			DECLARE  @ExceptionMessage NVARCHAR(4000) = '',
			@ExceptionSeverity INT = 0,
			@ExceptionState INT = 0,
			@ErrorValidation NVARCHAR(MAX) = '',
			@Step NVARCHAR(4000) = '',
			@IsActive INT = 1;


			CREATE TABLE #ImportmultipleDomain (
		[ID] [int] identity(1,1) NOT NULL,
		[UserEmail] [nvarchar](255) NOT NULL,
		[DomainName] [nvarchar](128) NOT NULL,
		[DomainUserID] [nvarchar](128) NOT NULL
		)


		DECLARE @CountOfRows int = 0, @CurrentRowID int = 0, @CountOfDuplicateUsers int = 0, @MaxUserIdForCompany int = 0, @userid int = 0
	DECLARE @UserEmail [nvarchar](255) ,
			@DomainName [nvarchar](128) ,
			@DomainUserID [nvarchar](128) 


			

	INSERT INTO #ImportmultipleDomain (UserEmail, DomainName, DomainUserID)

	SELECT TRIM(i.UserEmail), TRIM(i.DomainName), TRIM(i.DomainUserID)
	FROM [dbo].[ImportAddDomain] i
	WHERE
		i.CompanyID = @CompanyID and i.PushedInMaster = 0 --and i.UserEmail like '%_@__%.__%' 

	set @CountOfRows = @@ROWCOUNT


		----================ Start Validate Data =======================

	if (@CountOfRows = 0)
	begin
	
		select 'Nothing To Add' EmptyImport
		return
	
	end
	

	----check if email is valid

	SELECT * INTO #InvalidEmailIds
	FROM #ImportmultipleDomain d 
	WHERE d.UserEmail NOT LIKE '%_@_%._%'  
	
	IF (@@ROWCOUNT > 0)
	BEGIN
	
		set @ErrorValidation = @ErrorValidation + ' One or more user or ReportsTo have invalid email ids ' + CHAR(10)
		
		select 'Invalid EmailIds for Users Or ReportsTo' 'Invalid EmailIds for Users Or ReportsTo'
		SELECT * FROM #InvalidEmailIds 
	
	END	


	IF (@ErrorValidation <> '')
	BEGIN
	
		--PRINT @ErrorValidation
		RAISERROR (
				@ErrorValidation,
				16,
				16    
			);
		
		RETURN
	
	END
	
		ELSE
	
	BEGIN
	
		BEGIN TRAN TranUpsert
			BEGIN TRY

			while (@CurrentRowID < @CountOfRows)
			begin

				---- Varaible assighnment
						set @CurrentRowID = @CurrentRowID + 1

				

						select  @UserEmail = TRIM(i.UserEmail), @DomainName = i.DomainName, @DomainUserID = i.DomainUserID
						from	#ImportmultipleDomain i 
						where i.ID = @CurrentRowID

			
						
						IF NOT EXISTS 
						(
							SELECT 1 FROM [org].[UserDomain] l where l.CompanyID = @CompanyID and l.UserName = @DomainUserID and l.DomainName = @DomainName
						
						)
						
						begin
							
						
						
				
						SELECT @Userid = l.UserID
						FROM  [org].[Users] l WHERE l.CompanyID = @CompanyID and l.UserEmail =	TRIM(@UserEmail)
					

						INSERT INTO [org].[UserDomain]([CompanyID], [UserID], [UserName], [DomainName], [IsActive], [ModifiedBy])
						VALUES
						(@CompanyID, @Userid, @DomainUserID, @DomainName, @IsActive, 'System')


							UPDATE l 
						SET
						l.PushedInMaster = 1
						FROM [dbo].[ImportAddDomain]  l 
						WHERE 
						l.CompanyID = @CompanyID and l.UserEmail = @UserEmail and l.DomainUserID = @DomainUserID

					
						END
						



						END

		
		COMMIT TRAN TranUpsert
		END TRY
		BEGIN CATCH
		
			ROLLBACK TRAN TranUpsert 
		
			SELECT 
				@ExceptionMessage = ERROR_MESSAGE(),
				@ExceptionSeverity = ERROR_SEVERITY(),
				@ExceptionState = ERROR_STATE();
			RAISERROR (
				@ExceptionMessage,
				@ExceptionSeverity,
				@ExceptionState    
				);
		 
		END CATCH	


		select 'List of successfully Added Domain' AddSuccess

		select i.UserEmail, i.DomainName, i.DomainUserID
		from [dbo].[ImportAddDomain] i
		where
			i.CompanyID = @CompanyID and i.PushedInMaster = 1

		select 'List of Failed To Add Domain' AddFailed

		select i.UserEmail, i.DomainName, i.DomainUserID
		from [dbo].[ImportAddDomain] i
		where
			i.CompanyID = @CompanyID and i.PushedInMaster = 0

		select 'List of Invalid emailid' AddFailed
		select i.UserEmail, i.DomainName, i.DomainUserID
		from [dbo].[ImportAddDomain] i
		where
		i.CompanyID = @CompanyID and i.PushedInMaster = 0 and i.UserEmail NOt like '%_@__%.__%' 

	END

END


GO
/****** Object:  StoredProcedure [dbo].[sproc_AddImportUserDepartment]    Script Date: 8/20/2021 4:27:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sproc_AddImportUserDepartment]

(
	@CompanyID INT, 
	@Debug tinyint = 0
)
AS 
BEGIN
    SET NOCOUNT ON
	SET DATEFIRST 1


	DECLARE 
		@ExceptionMessage NVARCHAR(4000) = '',
		@ExceptionSeverity INT = 0,
		@ExceptionState INT = 0,
		@ErrorValidation NVARCHAR(MAX) = '',
		@Step NVARCHAR(4000) = '',
		@IsActive INT = 1;


	CREATE TABLE #ImportUserDepartment (
			[ID] [integer] identity(1,1) NOT NULL,
			[UserEmail] [nvarchar](255) NOT NULL,
			[DepartmentCode] [nvarchar](255) NOT NULL,
			[IsManager] [INt] NOT NULL
			)


	DECLARE @CountOfRows int = 0, @CurrentRowID int = 0, @CountOfDuplicateUsers int = 0, @UserId int = 0, @DepartmentID int = 0
		DECLARE @UserEmail [nvarchar](255),
			@DepartmentCode [nvarchar](255),
			@DepartmentName [nvarchar](255),
			@IsManager [int]

	INSERT INTO #ImportUserDepartment (UserEmail, DepartmentCode, IsManager)

		SELECT TRIM(i.UserEmail), TRIM(i.DepartmentCode), i.[IsManager]
		from dbo.ImportUserDepartment i
		where
			i.CompanyID = @CompanyID and i.PushedInMaster = 0 and i.UserEmail like '%_@_%._%' 

	set @CountOfRows = @@ROWCOUNT

	----================ Start Validate Data =======================

	if (@CountOfRows = 0)
	begin

		select 'Nothing To Add' EmptyImport
		return

	end

	----- Check Dup Rows
	---
	---select l.DepartmentCode, count(1) DupRows into #DupRows
	---from #ImportUserDepartment l
	---group by DepartmentCode
	---having
	---	count(1) > 1
	---
	---
	---if ( @@ROWCOUNT > 0 )
	---begin
	---	
	---	set @ErrorValidation = @ErrorValidation + 'One or more Duplicate Rows found' + CHAR(10)
	---	
	---	select 'Duplicate Rows' 'Duplicate Rows'
	---	select * from #DupRows DuplicateRows
	---
	---
	---end 

	
	-- Check if User email exists

	SELECT * INTO #UsersDoNotExists
	FROM #ImportUserDepartment d WHERE 
		NOT EXISTS (SELECT 1 FROM org.Users u WHERE u.CompanyID = @CompanyID and u.UserEmail = d.UserEmail)

	IF (@@ROWCOUNT > 0)
	BEGIN
	
		set @ErrorValidation = @ErrorValidation + ' One or more Users do not exist  ' + CHAR(10)
		
		select 'Users Do not exist' 'Users Do not exist'
		select * from #UsersDoNotExists ManagersNotUsers
	
	
	END	

	-- Check if Department Exists

	SELECT * INTO #DepartmentsDoNotExist
	FROM #ImportUserDepartment d WHERE 
		NOT EXISTS (SELECT 1 FROM org.Department u WHERE u.CompanyID = @CompanyID and u.DepartmentCode = d.DepartmentCode)

	IF (@@ROWCOUNT > 0)
	BEGIN
	
		set @ErrorValidation = @ErrorValidation + ' One or more Departments Do not Exist  ' + CHAR(10)
		
		select 'Departments Do not Exist' 'Departments Do not Exist '
		select * from #DepartmentsDoNotExist DepartmentsDoNotExist
	
	
	END	
	


	----================ End Validate Data =======================

	IF (@ErrorValidation <> '')
	BEGIN

		--PRINT @ErrorValidation
		RAISERROR (
				@ErrorValidation,
				16,
				16    
			);
		
		RETURN

	END
	
	ELSE
	
	BEGIN -- ( Validation Passes )

		begin tran TranUpsert
		begin try
			
			while (@CurrentRowID < @CountOfRows)
			begin

			
				set @CurrentRowID = @CurrentRowID + 1

				select  @UserEmail = i.UserEmail, @DepartmentCode = i.DepartmentCode,  @IsManager = IsManager
				from	#ImportUserDepartment i 
				where i.ID = @CurrentRowID

	

					
							SELECT @UserId = l.UserID
							from  [org].[Users] l where l.CompanyID = @CompanyID and l.UserEmail = @UserEmail
						
							select @DepartmentID = l.DepartmentID
							from  [org].[Department] l where l.CompanyID = @CompanyID and l.DepartmentCode = @DepartmentCode
						

										UPDATE u 
										SET
											u.DepartmentID = @DepartmentID
										FROM [org].[Users] u
										WHERE
										u.CompanyID = @CompanyID AND u.UserID = @UserId



										update l 
										set
										l.PushedInMaster = 1
										from [dbo].[ImportUserDepartment] l 
										where 
										l.CompanyID = @CompanyID and l.UserEmail = @UserEmail

							  
					END

				
					---BEGIN
					---
					---
					---	UPDATE u 
					---	SET
					---		u.IsManager = @IsManager
					---	FROM [MD].[UserDepartmentHistory] u
					---	WHERE
					---		u.CompanyID = @CompanyID AND u.DepartmentID = @DepartmentID AND u.UserID = @UserId
					---
					---END


		
		
		COMMIT TRAN TranUpsert
		
		END TRY
		
		BEGIN CATCH
		 
			ROLLBACK TRAN TranUpsert 

			SELECT 
				@ExceptionMessage = ERROR_MESSAGE(),
				@ExceptionSeverity = ERROR_SEVERITY(),
				@ExceptionState = ERROR_STATE();
			RAISERROR (
					@ExceptionMessage,
					@ExceptionSeverity,
					@ExceptionState    
				);
		 
		END CATCH	

		
		select 'List of successfully Updated Department' AddSuccess

		select i.UserEmail, i.DepartmentCode, i.IsManager
		from dbo.ImportUserDepartment i
		where
			i.CompanyID = @CompanyID and i.PushedInMaster = 1

		select 'List of Failed To Updated Department' AddFailed

		select i.UserEmail, i.DepartmentCode, i.IsManager
		from dbo.ImportUserDepartment i
		where
			i.CompanyID = @CompanyID and i.PushedInMaster = 0


		select 'Department not Updated for Below User' AddSuccess

		select i.UserEmail, i.UserID
		from [org].[Users] i
		where
			i.CompanyID = @CompanyID and i.DepartmentID is null

	end


	
	drop table if Exists #DupRows

END

GO
/****** Object:  StoredProcedure [dbo].[sproc_AddInitialDataForNewCompany]    Script Date: 8/20/2021 4:27:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





 CREATE          PROCEDURE [dbo].[sproc_AddInitialDataForNewCompany]

(
	@CompanyID INT, 
	@Debug tinyint = 0
)
AS 
BEGIN
    SET NOCOUNT ON
	SET DATEFIRST 1


		DECLARE  @ExceptionMessage NVARCHAR(4000) = '',
			@ExceptionSeverity INT = 0,
			@ExceptionState INT = 0,
			@ErrorValidation NVARCHAR(MAX) = '',
			@Step NVARCHAR(4000) = '',

			@PrivateActivity INT = -1,
			@MeetingActivity INT =  5,
			@MiscellActivity INT = -100,
			@OffPcApp INT = 0,
			@UnknownApp INT =  -1,
			@OutlookMeetApp INT = -2,
			@NotApplicableApp INT =  -3
			
	----================ Inserting Data on Master Table =======================
	----------------------------------------------------------------------------
	begin tran a
	begin try

		IF NOT EXISTS
	    (SELECT * FROM [org].[ActivityCategoryType] m 
                   WHERE m.CompanyID = @CompanyID)

		BEGIN
		INSERT INTO [org].[ActivityCategoryType]([CompanyID],[ActivityCategoryTypeID],[ActivityCategoryTypeName],[ActivityCategoryTypeDescription],[DateCreated])
		VALUES (@CompanyID, 1,'ALL','For All',GETDATE())
		END	


	commit tran a
	end try
	begin catch
		
		rollback tran a
	
	    SELECT 
				@ExceptionMessage = ERROR_MESSAGE(),
				@ExceptionSeverity = ERROR_SEVERITY(),
				@ExceptionState = ERROR_STATE();
			RAISERROR (
					@ExceptionMessage,
					@ExceptionSeverity,
					@ExceptionState    
				);
	  
	end catch
	-----------------------------------------------------------------------------------
	---------------------------------Platform Type Details-----------------------------


	begin tran a
	begin try

		IF NOT EXISTS
	    (SELECT * FROM [org].[PlatformType] m 
                   WHERE m.CompanyID = @CompanyID
						and m.PlatformTypeID = 1)

		BEGIN
		INSERT INTO [org].[PlatformType]([CompanyID],[PlatformTypeID],[PlatformName],[PlatformTypeDescription],[DateCreated])
		VALUES(@CompanyID, 1, 'Windows', 'All Windows',GETDATE())
		END	


	commit tran a
	end try
	begin catch
		
		rollback tran a
	
	    SELECT 
				@ExceptionMessage = ERROR_MESSAGE(),
				@ExceptionSeverity = ERROR_SEVERITY(),
				@ExceptionState = ERROR_STATE();
			RAISERROR (
					@ExceptionMessage,
					@ExceptionSeverity,
					@ExceptionState    
				);
	  
	end catch


	begin tran a
	begin try

		IF NOT EXISTS
	    (SELECT * FROM [org].[PlatformType] m 
                   WHERE m.CompanyID = @CompanyID
						and m.PlatformTypeID = 2)

		BEGIN
		INSERT INTO [org].[PlatformType]([CompanyID],[PlatformTypeID],[PlatformName],[PlatformTypeDescription],[DateCreated])
		VALUES(@CompanyID, 2, 'Linux', 'Ubuntu',GETDATE())
		END	


	commit tran a
	end try
	begin catch
		
		rollback tran a
	
	    SELECT 
				@ExceptionMessage = ERROR_MESSAGE(),
				@ExceptionSeverity = ERROR_SEVERITY(),
				@ExceptionState = ERROR_STATE();
			RAISERROR (
					@ExceptionMessage,
					@ExceptionSeverity,
					@ExceptionState    
				);
	  
	end catch


	-----------------------------------------------------------------------------------
	-------------------Adding Default Activity Category Details------------------------



	---Private
	begin tran a
	begin try

		IF NOT EXISTS
	    (SELECT * FROM [org].[ActivityCategory] m 
                   WHERE m.CompanyID = @CompanyID
                   AND m.ActivityCategoryID = -1)

		BEGIN
		INSERT INTO [org].[ActivityCategory]([CompanyID],[ActivityCategoryGroupID],[ActivityCategoryID],[ActivityCategoryTypeID],[PlatformTypeID],[ActivityCategoryGroupName]
											,[ActivityCategoryName],[IsCore],[IsSystemDefined],[IsConfigurable],[IsGlobal],[DateCreated],[DateDeleted],[IsActive])
		VALUES(@CompanyID, 1, -1, 1, 1, '', 'Private', 0, 1, 0, 1, GETDATE(), null, 1)
		END	


	commit tran a
	end try
	begin catch
		
		rollback tran a
	
	    SELECT 
				@ExceptionMessage = ERROR_MESSAGE(),
				@ExceptionSeverity = ERROR_SEVERITY(),
				@ExceptionState = ERROR_STATE();
			RAISERROR (
					@ExceptionMessage,
					@ExceptionSeverity,
					@ExceptionState    
				);
	  
	end catch

---Meetings
	begin tran a
	begin try

		IF NOT EXISTS
	    (SELECT * FROM [org].[ActivityCategory] m 
                   WHERE m.CompanyID = @CompanyID
                   AND m.ActivityCategoryID = 5)

		BEGIN
		INSERT INTO [org].[ActivityCategory]([CompanyID],[ActivityCategoryGroupID],[ActivityCategoryID],[ActivityCategoryTypeID],[PlatformTypeID],[ActivityCategoryGroupName]
											,[ActivityCategoryName],[IsCore],[IsSystemDefined],[IsConfigurable],[IsGlobal],[DateCreated],[DateDeleted],[IsActive])
		VALUES(@CompanyID, 1, 5, 1, 1, '', 'Meetings', 0, 1, 1, 1, GETDATE(), null, 1)
		END	


	commit tran a
	end try
	begin catch
		
		rollback tran a
	
	    SELECT 
				@ExceptionMessage = ERROR_MESSAGE(),
				@ExceptionSeverity = ERROR_SEVERITY(),
				@ExceptionState = ERROR_STATE();
			RAISERROR (
					@ExceptionMessage,
					@ExceptionSeverity,
					@ExceptionState    
				);
	  
	end catch	
	

---Miscellaneous
	begin tran a
	begin try

		IF NOT EXISTS
	    (SELECT * FROM [org].[ActivityCategory] m 
                   WHERE m.CompanyID = @CompanyID
                   AND m.ActivityCategoryID = 100)

		BEGIN
		INSERT INTO [org].[ActivityCategory]([CompanyID],[ActivityCategoryGroupID],[ActivityCategoryID],[ActivityCategoryTypeID],[PlatformTypeID],[ActivityCategoryGroupName]
											,[ActivityCategoryName],[IsCore],[IsSystemDefined],[IsConfigurable],[IsGlobal],[DateCreated],[DateDeleted],[IsActive])
		VALUES(@CompanyID, 1, 100, 1, 1, '', 'Miscellaneous', 0, 1, 1, 1, GETDATE(), null, 1)
		END	


	commit tran a
	end try
	begin catch
		
		rollback tran a
	
	    SELECT 
				@ExceptionMessage = ERROR_MESSAGE(),
				@ExceptionSeverity = ERROR_SEVERITY(),
				@ExceptionState = ERROR_STATE();
			RAISERROR (
					@ExceptionMessage,
					@ExceptionSeverity,
					@ExceptionState    
				);
	  
	end catch	
	

	-----------------------------------------------------------------------------------
	-------------------Adding Default Application Master Details-----------------------

	---Off-PC
	begin tran a
	begin try
	  
		IF NOT EXISTS
	    (SELECT * FROM [org].[AppMaster] m 
                   WHERE m.CompanyID = @CompanyID
                   AND m.AppID = 0)
		BEGIN
		INSERT INTO [org].[AppMaster]([CompanyID],[AppID],[PlatformTypeID],[ExeName],[AppName],[AppVersion],[IsApplication],[IsOffline])
		VALUES (@CompanyID, 0 , 1 , '', 'Off-PC', '', 0 , 1)
		END	

	commit tran a
	end try
	begin catch
		
		rollback tran a
	
	    SELECT 
				@ExceptionMessage = ERROR_MESSAGE(),
				@ExceptionSeverity = ERROR_SEVERITY(),
				@ExceptionState = ERROR_STATE();
			RAISERROR (
					@ExceptionMessage,
					@ExceptionSeverity,
					@ExceptionState    
				);
	  
	end catch
	---Unknown
	begin tran a
	begin try
		
		IF NOT EXISTS
	    (SELECT * FROM [org].[AppMaster] m 
                   WHERE m.CompanyID = @CompanyID
                   AND m.AppID = -1)
		BEGIN
		INSERT INTO [org].[AppMaster]([CompanyID],[AppID],[PlatformTypeID],[ExeName],[AppName],[AppVersion],[IsApplication],[IsOffline])
		VALUES (@CompanyID, -1 , 1 , '', 'Unknown', '', 1 , 0)
		END	
	
	commit tran a
	end try
	begin catch
	
	rollback tran a

	SELECT 
				@ExceptionMessage = ERROR_MESSAGE(),
				@ExceptionSeverity = ERROR_SEVERITY(),
				@ExceptionState = ERROR_STATE();
			RAISERROR (
					@ExceptionMessage,
					@ExceptionSeverity,
					@ExceptionState    
				);
  

	end catch
	---Outlook Meetings
	begin tran a
	begin try
	
		IF NOT EXISTS
	    (SELECT * FROM [org].[AppMaster] m 
                   WHERE m.CompanyID = @CompanyID
                   AND m.AppID = -2)
		BEGIN
		INSERT INTO [org].[AppMaster]([CompanyID],[AppID],[PlatformTypeID],[ExeName],[AppName],[AppVersion],[IsApplication],[IsOffline])
		VALUES (@CompanyID, -2 , 1 , '', 'Outlook Meetings', '', 0 , 1)
		END		

	commit tran a
	end try
	begin catch
	
	rollback tran a

	 
   SELECT 
				@ExceptionMessage = ERROR_MESSAGE(),
				@ExceptionSeverity = ERROR_SEVERITY(),
				@ExceptionState = ERROR_STATE();
			RAISERROR (
					@ExceptionMessage,
					@ExceptionSeverity,
					@ExceptionState    
				);
  

	end catch
	---Not Applicable
	begin tran a
	begin try
	
		IF NOT EXISTS
	    (SELECT * FROM [org].[AppMaster] m 
                   WHERE m.CompanyID = @CompanyID
                   AND m.AppID = -3)
		BEGIN
		INSERT INTO [org].[AppMaster]([CompanyID],[AppID],[PlatformTypeID],[ExeName],[AppName],[AppVersion],[IsApplication],[IsOffline])
		VALUES (@CompanyID, -3 , 1 , 'Not Applicable', 'Not Applicable', 'Not Applicable', 0 , 1)
		END		

	commit tran a
	end try
	begin catch
	
	rollback tran a

	 
    SELECT 
				@ExceptionMessage = ERROR_MESSAGE(),
				@ExceptionSeverity = ERROR_SEVERITY(),
				@ExceptionState = ERROR_STATE();
			RAISERROR (
					@ExceptionMessage,
					@ExceptionSeverity,
					@ExceptionState    
				);
  

	end catch

END
GO
/****** Object:  StoredProcedure [dbo].[sproc_DeleteUser]    Script Date: 8/20/2021 4:27:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sproc_DeleteUser]
(
     @CompanyID int
	,@Useremail varchar(50)
)
AS
BEGIN

    SET NOCOUNT ON

		DECLARE  @ExceptionMessage NVARCHAR(4000) = '',
			@ExceptionSeverity INT = 0,
			@ExceptionState INT = 0,
			@ErrorValidation NVARCHAR(MAX) = '',
			@Step NVARCHAR(4000) = ''


		Declare @UserId int, @TeamID int, @TeamCount int = 0

			---Select Userid of employee
			SELECT @UserId = UserID from Org.Users Where CompanyID = @CompanyID and Useremail = @Useremail	
	
			Select @TeamID = TeamID from [org].[Team] Where ManagerID = @UserId

			Select @TeamCount = count(*) from Org.Users Where TeamID = @TeamID

				if ( @UserId is null )
				BEGIN
				
				set @ErrorValidation = @ErrorValidation + 'No Record Found' + CHAR(10)
				
				select 'No Record Found For :   ' + @Useremail
				SELECT @Useremail
		
				END 

				if ( @TeamCount > 0 ) 
						BEGIN

				set @ErrorValidation = @ErrorValidation + 'User Found under his Team' + CHAR(10)
										
				END

				ELSE
			BEGIN	
					
					IF (@ErrorValidation <> '')
					BEGIN

					--PRINT @ErrorValidation
					RAISERROR (
							@ErrorValidation,
							16,
							16    
						);
					
					RETURN

					END

					BEGIN TRAN TranUpsert
					BEGIN TRY



					-----Deletion of UserDomain
						Delete from [org].[UserDomain]  Where companyID = @CompanyID and UserID = @UserId
					-----Select TeamID
						Select @TeamID = TeamID From [org].[Team] WHere CompanyID = @CompanyID and ManagerID = @UserId

					-----Update the Reports To User ID
						Select UserID UserID, UserEMail as UpdateTeamOfBelowUser  from [org].[Users] WHere CompanyID = @CompanyID and TeamID = @TeamID and UserID <> @UserId
					
					-----Update null Team ID
						Update [org].[Users]
						Set TeamID = Null WHere CompanyID = @CompanyID and TeamID = @TeamID

					-----Deletion of TeamDetails
						Delete from [org].[Team] WHere CompanyID = @CompanyID and ManagerID = @UserId

					-----Update null for Department and Job Family
						Update [org].[Department] Set DepartmentOwnerID = null Where CompanyID = @CompanyID and DepartmentOwnerID = @UserId
						Update [org].[Users] Set DepartmentID = null, JobFamilyActivityOverrideProfileID = null Where CompanyID = @CompanyID and UserID = @UserId

					------Delete user Permission
						Delete from [org].[UserPermission] Where companyID = @CompanyID and UserID = @UserId
					
					-----Deletion of user	
						Delete from [org].[Users] Where companyID = @CompanyID and UserID = @UserId
				

				COMMIT TRAN TranUpsert
		END TRY
		BEGIN CATCH
		 
			ROLLBACK TRAN TranUpsert 

			SELECT 
				@ExceptionMessage = ERROR_MESSAGE(),
				@ExceptionSeverity = ERROR_SEVERITY(),
				@ExceptionState = ERROR_STATE();
			RAISERROR (
				@ExceptionMessage,
				@ExceptionSeverity,
				@ExceptionState    
				);
		 
		END CATCH	




	END


	SET NOCOUNT OFF
END

GO
/****** Object:  StoredProcedure [dbo].[sproc_EnableDisableConstraints]    Script Date: 8/20/2021 4:27:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sproc_EnableDisableConstraints]

	@enable_constraints bit
	,@schemaname nvarchar(1000)

AS 
BEGIN


	BEGIN TRAN A
	BEGIN TRY

		--Don't change anything below this line.
		DECLARE @schema_name SYSNAME
		DECLARE @table_name  SYSNAME

		DECLARE table_cursor CURSOR FOR
		SELECT
			schemas.name,
			tables.name
		FROM
			sys.tables
			INNER JOIN sys.schemas ON tables.schema_id = schemas.schema_id
		WHERE
			schemas.Name = @schemaname

		OPEN table_cursor
		FETCH NEXT FROM table_cursor INTO @schema_name, @table_name

		DECLARE @cmd varchar(200) 
		WHILE @@FETCH_STATUS = 0
		BEGIN

			--select @schema_name, @table_name

			SET @cmd = 'ALTER TABLE ' + QUOTENAME(@schema_name) + '.' + QUOTENAME(@table_name) + ' '
			SET @cmd = @cmd + (CASE WHEN @enable_constraints = 1 THEN 'CHECK' ELSE 'NOCHECK' END) + ' CONSTRAINT ALL'

			-- PRINT @cmd
			EXEC( @cmd )

			FETCH NEXT FROM table_cursor INTO @schema_name, @table_name
		END

		CLOSE table_cursor
		DEALLOCATE table_cursor

	COMMIT TRAN A

		if (@enable_constraints = 0)
		begin
			PRINT 'Success:: Disable Constraints'
		end
		else begin
			PRINT 'Success:: Enable Constraints'
		end
	
	END TRY

	BEGIN CATCH
		
		ROLLBACK TRAN A
		PRINT 'Error: changes rolled back'
		DECLARE @ErrorStr NVARCHAR(4000)
		SET @ErrorStr  ='ERROR: ERR_NO: ' + CONVERT(VARCHAR(20),ERROR_NUMBER()) + ', ERR_MSG: '  + ERROR_MESSAGE()
			RAISERROR (@ErrorStr , -- Message text.
			   16, -- Severity,
			   1); -- State.
	END CATCH



END


GO
/****** Object:  StoredProcedure [dbo].[sproc_GetAppMappings]    Script Date: 8/20/2021 4:27:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE    PROCEDURE [dbo].[sproc_GetAppMappings]
(
  @companyID INT
 ,@page int = 1
 ,@pageSize int = 0
 ,@orderBy int=0
 ,@sortBy nvarchar(200)='ID'
 ,@iswebApp bit --True/False/Null(should return All Apps/WebApps)
 ,@IsRemote bit --True/False(Should return all Apps/WebApps with false)/Null(should return All Apps/WebApps)
 ,@searchBy nvarchar(200)--DisplayName/Null
 ,@isMapped bit--Mappped/UnMapped/Null--status Column
 ,@isWork bit--true/false/null Category column
 ,@isCore bit--true/false/null Category column
 ,@activityIds nvarchar(100)--comma seperated activityIds
 ,@overrideIds nvarchar(1000)-- ID(APPID/WebAPPID) NOT IN overrideIds 
 ,@TotalCount INT OUTPUT
)
As 
SET NOCOUNT ON

BEGIN
	DECLARE @localCompanyID INT, @counter INT, @AppSpecID INT, @WebAppSpecID INT,@appUsageDuration INT, @rowCount INT, @str_ProfileNames NVARCHAR(500), @strSQL NVARCHAR(4000), @strSQLCount  NVARCHAR(4000)
	DECLARE  @Result AS INT
	DECLARE @offset INT
    DECLARE @newsize INT
	DECLARE @skipRows int = (@page - 1) * @pageSize;

	SET @localCompanyID = @CompanyID	

	--**********************Get WebAppSpecs for company*********************
	Select w.CompanyID, w.WebAppSpecID as ID,w.WebAppUrl as ApplicationOrUrl,w.WebAppDisplayName as DisplayName,
		w.UrlMatchContent ,
		case 
			when w.UrlMatchStrategy=1 then 'Domain'
			when w.UrlMatchStrategy=2 then 'StartsWith'
			when w.UrlMatchStrategy=3 then 'Contains'
		else ''
		end	as UrlPattern,		
		case 
			when w.UrlMatchStrategy=1 then 2
			when w.UrlMatchStrategy=2 then 3
			when w.UrlMatchStrategy=3 then 1
		else ''
		end	as UrlPatternSort,			
		w.ActivitySpecID, 
		Case When a.IsCore is null then 0
		else a.IsCore
		end IsCore	
		
		,
		Case when	a.IsWorkCategory is null then 0
		else a.isWorkCategory 
		End IsWorkCategory,
		a.ActivitySpecName as ActivityName,
		 Cast(1 as bit) as IsWebApp,
		 cast(null as bit) as  RemoteAccess,
		Case
		When a.IsWorkCategory=0 or a.IsWorkCategory is null
		then 'Private' 
		else 'Work'
		end  as Category,

		 Case 
		 When w.ActivitySpecID is not null
		 then 'Mapped'
		 else 'UnMapped' end as Status,
	
	
		o.JobFamilyName as JobFamilyOverrides,
		u.ProfileName as MappingOverrides	
		INTO #webAppBase

		from org.WebAppSpec w
	Left join org.ActivitySpec a on a.ActivitySpecID=w.ActivitySpecID and w.CompanyID=a.CompanyID	
	Left join (SELECT ja.JobFamilyName,jw.WebAppSpecID FROM org.JobFamilyWebAppSpecOverride jw 
				Left join  org.JobFamilyActivityOverrideProfile ja on ja.JobFamilyActivityOverrideProfileID=jw.JobFamilyActivityOverrideProfileID and ja.CompanyID=jw.CompanyID
				WHERE jw.CompanyID=@localCompanyID  AND WebAppSpecID IN
					(SELECT WebAppSpecID FROM org.JobFamilyWebAppSpecOverride	WHERE CompanyID=@localCompanyID 
					  GROUP BY WebAppSpecID HAVING COUNT(1) = 1))o on w.WebAppSpecID=o.WebAppSpecID
	Left join (SELECT ua.ProfileName,uw.WebAppSpecID FROM org.UserWebAppSpecOverride uw 
				Left join  org.UserActivityOverrideProfile ua on ua.UserActivityOverrideProfileID=uw.UserActivityOverrideProfileID and ua.CompanyID=uw.CompanyID
				WHERE uw.CompanyID=@localCompanyID  AND WebAppSpecID IN
					(SELECT WebAppSpecID FROM org.UserWebAppSpecOverride	WHERE CompanyID=@localCompanyID 
					  GROUP BY WebAppSpecID HAVING COUNT(1) = 1))u on w.WebAppSpecID=u.WebAppSpecID			

	WHERE w.CompanyID=@localCompanyID 
    OPTION(RECOMPILE) 

	ALTER TABLE #webAppBase ALTER COLUMN JobFamilyOverrides NVARCHAR(500)
	ALTER TABLE #webAppBase ALTER COLUMN MappingOverrides NVARCHAR(500)


	--******** THOSE WebApps WITH MULTIPLE JobFamily Overrides
	DECLARE @JobFamilyWebAppSpecOverride TABLE (ID INT, WebAppSpecID INT)
	INSERT INTO @JobFamilyWebAppSpecOverride (ID, WebAppSpecID)
	SELECT ROW_NUMBER() OVER(ORDER BY WebAppSpecID) ID, WebAppSpecID FROM org.JobFamilyWebAppSpecOverride WHERE CompanyID=@localCompanyID GROUP BY WebAppSpecID HAVING COUNT(1) >1

	SET @counter=1
	WHILE (@counter <= (SELECT MAX(ID) FROM @JobFamilyWebAppSpecOverride))
	BEGIN
		SET @str_ProfileNames=''
		SELECT @WebAppSpecID = WebAppSpecID FROM @JobFamilyWebAppSpecOverride WHERE ID=@counter

		SELECT @str_ProfileNames=COALESCE(@str_ProfileNames + ', ', '') + JobFamilyName FROM org.JobFamilyWebAppSpecOverride a
		JOIN org.JobFamilyActivityOverrideProfile b ON a.CompanyID = b.CompanyID AND a.JobFamilyActivityOverrideProfileID = b.JobFamilyActivityOverrideProfileID
		WHERE a.CompanyID=@localCompanyID AND WebAppSpecID = @WebAppSpecID

		UPDATE #webAppBase
		SET JobFamilyOverrides = SUBSTRING(@str_ProfileNames, 3, LEN(@str_ProfileNames))
		WHERE CompanyID=@localCompanyID AND ID=@WebAppSpecID

		SET @counter=@counter+1
	END


	--********* THOSE WebApps WITH MULTIPLE User Overrides
	DECLARE @UserWebAppSpecOverride TABLE (ID INT, WebAppSpecID INT)
	INSERT INTO @UserWebAppSpecOverride (ID, WebAppSpecID)
	SELECT ROW_NUMBER() OVER(ORDER BY WebAppSpecID) ID, WebAppSpecID FROM org.UserWebAppSpecOverride WHERE CompanyID=@localCompanyID GROUP BY WebAppSpecID HAVING COUNT(1) >1

	SET @counter=1
	WHILE (@counter <= (SELECT MAX(ID) FROM @UserWebAppSpecOverride))
	BEGIN
		SET @str_ProfileNames=''
		SELECT @WebAppSpecID = WebAppSpecID FROM @UserWebAppSpecOverride WHERE ID=@counter

		SELECT @str_ProfileNames=COALESCE(@str_ProfileNames + ', ', '') + ProfileName FROM org.UserWebAppSpecOverride a
		JOIN org.UserActivityOverrideProfile b ON a.CompanyID = b.CompanyID AND a.UserActivityOverrideProfileID = b.UserActivityOverrideProfileID
		WHERE a.CompanyID=@localCompanyID AND WebAppSpecID = @WebAppSpecID

		UPDATE #webAppBase
		SET MappingOverrides = SUBSTRING(@str_ProfileNames, 3, LEN(@str_ProfileNames))
		WHERE CompanyID=@localCompanyID AND ID=@WebAppSpecID

		SET @counter=@counter+1
	END


	--***********************Get AppSpecs for company******************
	select app.CompanyID, app.AppSpecID as ID,app.AppExeName as ApplicationOrUrl ,app.AppDisplayName as DisplayName ,
	Cast(null as nvarchar) as UrlMatchContent,Cast(null as nvarchar) as UrlPattern,Cast(null as int)UrlPatternSort,act.ActivitySpecID
	,
	Case When act.IsCore is null then 0
		else act.IsCore
		end IsCore		
	,
	Case When act.IsWorkCategory is null then 0
		else act.IsWorkCategory
		end IsWorkCategory
	,
	act.ActivitySpecName  as ActivityName,cast(0 as bit) as IsWebApp,app.MergePriority as RemoteAccess,
	 Case
		  When act.IsWorkCategory=0 or act.IsWorkCategory is null
		 then 'Private' 
		 else 'Work'
		 end  as Category,

		 Case 
		 When app.ActivitySpecID is not null
		 then 'Mapped'
		 else 'UnMapped' end as Status,
	
	   o.JobFamilyName as JobFamilyOverrides,
	   u.ProfileName as MappingOverrides
		INTO #appSpecBase
	from org.AppSpec app
	Left join org.ActivitySpec act on act.ActivitySpecID=app.ActivitySpecID and act.CompanyID=app.CompanyID
	Left join (SELECT ja.JobFamilyName,jao.AppSpecID FROM org.JobFamilyAppSpecOverride jao 
				Left join  org.JobFamilyActivityOverrideProfile ja on ja.JobFamilyActivityOverrideProfileID=jao.JobFamilyActivityOverrideProfileID and ja.CompanyID=jao.CompanyID
				WHERE jao.CompanyID=@localCompanyID  AND AppSpecID IN
					(SELECT AppSpecID FROM org.JobFamilyAppSpecOverride	WHERE CompanyID=@localCompanyID 
					  GROUP BY AppSpecID HAVING COUNT(1) = 1))o on app.AppSpecID=o.AppSpecID

	Left join (SELECT uap.ProfileName,ua.AppSpecID FROM org.UserAppSpecOverride ua 
				Left join  org.UserActivityOverrideProfile uap on ua.UserActivityOverrideProfileID=uap.UserActivityOverrideProfileID and ua.CompanyID=uap.CompanyID
				WHERE ua.CompanyID=@localCompanyID 
				 AND 
				AppSpecID IN
				(SELECT AppSpecID FROM org.UserAppSpecOverride	WHERE CompanyID=@localCompanyID  GROUP BY AppSpecID HAVING COUNT(1) = 1))u on app.AppSpecID=u.AppSpecID
	WHERE app.CompanyID=@localCompanyID  
	
	
	OPTION(RECOMPILE) 

	ALTER TABLE #appSpecBase ALTER COLUMN JobFamilyOverrides NVARCHAR(500)
	ALTER TABLE #appSpecBase ALTER COLUMN MappingOverrides NVARCHAR(500)


	--******** THOSE Apps WITH MULTIPLE JobFamily Overrides
	DECLARE @JobFamilyAppSpecOverride TABLE (ID INT, AppSpecID INT)
	INSERT INTO @JobFamilyAppSpecOverride (ID, AppSpecID)
	SELECT ROW_NUMBER() OVER(ORDER BY AppSpecID) ID, AppSpecID FROM org.JobFamilyAppSpecOverride WHERE CompanyID=@localCompanyID GROUP BY AppSpecID HAVING COUNT(1) >1

	SET @counter=1
	WHILE (@counter <= (SELECT MAX(ID) FROM @JobFamilyAppSpecOverride))
	BEGIN
		SET @str_ProfileNames=''
		SELECT @AppSpecID = AppSpecID FROM @JobFamilyAppSpecOverride WHERE ID=@counter

		SELECT @str_ProfileNames=COALESCE(@str_ProfileNames + ', ', '') + JobFamilyName FROM org.JobFamilyAppSpecOverride a
		JOIN org.JobFamilyActivityOverrideProfile b ON a.CompanyID = b.CompanyID AND a.JobFamilyActivityOverrideProfileID = b.JobFamilyActivityOverrideProfileID
		WHERE a.CompanyID=@localCompanyID AND AppSpecID = @AppSpecID

		UPDATE #appSpecBase
		SET JobFamilyOverrides = SUBSTRING(@str_ProfileNames, 3, LEN(@str_ProfileNames))
		WHERE CompanyID=@localCompanyID AND ID=@AppSpecID

		SET @counter=@counter+1
	END


	--******** THOSE Apps WITH MULTIPLE User O verrides
	DECLARE @UserAppSpecOverride TABLE (ID INT, AppSpecID INT)
	INSERT INTO @UserAppSpecOverride (ID, AppSpecID)
	SELECT ROW_NUMBER() OVER(ORDER BY AppSpecID) ID, AppSpecID FROM org.UserAppSpecOverride WHERE CompanyID=@localCompanyID GROUP BY AppSpecID HAVING COUNT(1) >1

	SET @counter=1
	WHILE (@counter <= (SELECT MAX(ID) FROM @UserAppSpecOverride))
	BEGIN
		SET @str_ProfileNames=''
		SELECT @AppSpecID = AppSpecID FROM @UserAppSpecOverride WHERE ID=@counter

		SELECT @str_ProfileNames=COALESCE(@str_ProfileNames + ', ', '') + ProfileName FROM org.UserAppSpecOverride a
		JOIN org.UserActivityOverrideProfile b ON a.CompanyID = b.CompanyID AND a.UserActivityOverrideProfileID = b.UserActivityOverrideProfileID
		WHERE a.CompanyID=@localCompanyID AND AppSpecID = @AppSpecID

		UPDATE #appSpecBase
		SET MappingOverrides = SUBSTRING(@str_ProfileNames, 3, LEN(@str_ProfileNames))
		WHERE CompanyID=@localCompanyID AND ID=@AppSpecID

		SET @counter=@counter+1
	END


	--******** BUILD @strSQL string
	SET @strSQL = 
	'SELECT * FROM 
		(SELECT * FROM #webAppBase
		UNION ALL
		SELECT * FROM #appSpecBase) results 
	WHERE 1=1'
	+ CASE WHEN @iswebApp IS NULL THEN '' WHEN @iswebApp=1 THEN ' AND IsWebApp=1' WHEN @iswebApp=0 THEN ' AND IsWebApp=0' END
	+ CASE WHEN @IsRemote IS NULL THEN '' WHEN @IsRemote=1 THEN ' AND RemoteAccess=1' WHEN @IsRemote=0 THEN ' AND RemoteAccess=0' END
    + CASE WHEN @searchBy = '' THEN '' ELSE ' AND (DisplayName LIKE ''%' + @searchBy + '%'' Or  ApplicationOrUrl LIKE ''%' + @searchBy + '%'')' END
	+ CASE WHEN @isMapped IS NULL THEN '' WHEN @isMapped=1 THEN ' AND Status=''Mapped''' WHEN @isMapped=0 THEN ' AND Status=''UnMapped''' END
	+ CASE WHEN @isWork IS NULL THEN '' WHEN @isWork=1 THEN ' AND IsWorkCategory=1' WHEN @isWork=0 THEN ' AND IsWorkCategory=0' END
	+ CASE WHEN @isCore IS NULL THEN '' WHEN @isCore=1 THEN ' AND IsCore=1' WHEN @isCore=0 THEN ' AND IsCore=0' END
	+ CASE WHEN @activityIds = '' THEN '' ELSE ' AND ActivitySpecID IN (' + @activityIds + ')' END	
	+Case When @overrideIds='' Then '' Else ' AND ID NOT IN ('+@overrideIds+')'END
	+ ' ORDER BY ' + CASE @sortBy WHEN 'MergePriority' THEN 'RemoteAccess' WHEN 'UrlPattern' THEN 'UrlPatternSort' ELSE @sortBy END + CASE @orderBy WHEN 1 THEN ' DESC' ELSE ' ASC' END
	+ ' OFFSET ' + CAST(@skipRows AS varchar(10)) + ' ROWS'
	+ ' FETCH NEXT ' + CAST(@pageSize AS varchar(10)) + ' ROWS ONLY'

	+ '	SELECT @TotalCount=COUNT(1) FROM 
		(SELECT * FROM #webAppBase
		UNION ALL
		SELECT * FROM #appSpecBase) results 
	WHERE 1=1'
	+ CASE WHEN @iswebApp IS NULL THEN '' WHEN @iswebApp=1 THEN ' AND IsWebApp=1' WHEN @iswebApp=0 THEN ' AND IsWebApp=0' END
	+ CASE WHEN @IsRemote IS NULL THEN '' WHEN @IsRemote=1 THEN ' AND RemoteAccess=1' WHEN @IsRemote=0 THEN ' AND RemoteAccess=0' END
	+ CASE WHEN @searchBy  = '' THEN '' ELSE ' AND (DisplayName LIKE ''%' + @searchBy + '%'' Or  ApplicationOrUrl LIKE ''%' + @searchBy + '%'')' END
	+ CASE WHEN @isMapped IS NULL THEN '' WHEN @isMapped=1 THEN ' AND Status=''Mapped''' WHEN @isMapped=0 THEN ' AND Status=''UnMapped''' END
	+ CASE WHEN @isWork IS NULL THEN '' WHEN @isWork=1 THEN ' AND IsWorkCategory=1' WHEN @isWork=0 THEN ' AND IsWorkCategory=0' END
	+ CASE WHEN @isCore IS NULL THEN '' WHEN @isCore=1 THEN ' AND IsCore=1' WHEN @isCore=0 THEN ' AND IsCore=0' END
	+ CASE WHEN @activityIds = '' THEN '' ELSE ' AND ActivitySpecID IN (' + @activityIds + ')' END	
	+Case When @overrideIds='' Then '' Else ' AND ID NOT IN ('+@overrideIds+')'END

    --******** OUTPUT 
	EXEC sp_executesql @strSQL, N'@TotalCount int OUT', @TotalCount = @rowCount OUT;
 	
	 --SELECT @rowCount TotalRows; 
	 SET @TotalCount =@rowCount
	DROP TABLE #webAppBase
	DROP TABLE #appSpecBase

END
GO
/****** Object:  StoredProcedure [dbo].[sproc_GetAppMappingsTest]    Script Date: 8/20/2021 4:27:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--exec [dbo].[sproc_GetAppMappings]

--  @companyID = 1
-- ,@page  = 1
-- ,@pageSize  = 0
-- ,@orderBy =0
-- ,@sortBy ='ID'
-- ,@usageDuration = 20 
-- ,@iswebApp = 1
-- ,@IsRemote = 1
-- ,@searchBy = ''
-- ,@isMapped = 1
-- ,@isWork = 1
-- ,@activityIds = ''
-- ,@overrideIds = ''
-- ,@TotalCount = 0

--As 
--SET NOCOUNT ON


CREATE    PROCEDURE [dbo].[sproc_GetAppMappingsTest]
(
  @companyID INT
 ,@page int = 1
 ,@pageSize int = 0
 ,@orderBy int=0
 ,@sortBy nvarchar(200)='ID'
 ,@usageDuration int 
 ,@iswebApp bit --True/False/Null(should return All Apps/WebApps)
 ,@IsRemote bit --True/False(Should return all Apps/WebApps with false)/Null(should return All Apps/WebApps)
 ,@searchBy nvarchar(200)--DisplayName/Null
 ,@isMapped bit--Mappped/UnMapped/Null--status Column
 ,@isWork bit--true/false/null Category column
 ,@activityIds nvarchar(100)--comma seperated activityIds
 ,@overrideIds nvarchar(100)-- ID(APPID/WebAPPID) NOT IN overrideIds 
 ,@TotalCount INT OUTPUT
)
As 
SET NOCOUNT ON

BEGIN
	DECLARE @localCompanyID INT, @counter INT, @AppSpecID INT, @WebAppSpecID INT,@appUsageDuration INT, @rowCount INT, @str_ProfileNames NVARCHAR(500), @strSQL NVARCHAR(4000), @strSQLCount  NVARCHAR(4000)
	DECLARE  @Result AS INT
	DECLARE @offset INT
    DECLARE @newsize INT
	DECLARE @skipRows int = (@page - 1) * @pageSize;

	SET @localCompanyID = @CompanyID
	SET @appUsageDuration=@usageDuration


	--**********************Get WebAppSpecs for company*********************
	Select w.CompanyID, w.WebAppSpecID as ID,w.WebAppUrl as ApplicationOrUrl,w.WebAppDisplayName as DisplayName,
		w.UrlMatchContent ,
		case 
			when w.UrlMatchStrategy=1 then 'Domain'
			when w.UrlMatchStrategy=2 then 'StartsWith'
			when w.UrlMatchStrategy=3 then 'Contains'
		else ''
		end	as UrlPattern,		
		case 
			when w.UrlMatchStrategy=1 then 2
			when w.UrlMatchStrategy=2 then 3
			when w.UrlMatchStrategy=3 then 1
		else ''
		end	as UrlPatternSort,			
		w.ActivitySpecID, 
		Case When a.IsCore is null then 0
		else a.IsCore
		end IsCore	
		
		,
		Case when	a.IsWorkCategory is null then 0
		else a.isWorkCategory 
		End IsWorkCategory,
		a.ActivitySpecName as ActivityName,
		 Cast(1 as bit) as IsWebApp,
		 cast(null as bit) as  RemoteAccess,
		Case
		When a.IsWorkCategory=0 or a.IsWorkCategory is null
		then 'Private' 
		else 'Work'
		end  as Category,

		 Case 
		 When w.ActivitySpecID is not null
		 then 'Mapped'
		 else 'UnMapped' end as Status,
		Case
		  When @appUsageDuration=1   then  M.NumberOfUsers_Short
		  When @appUsageDuration=2 then  M.NumberOfUsers_Medium
		  else M.NumberOfUsers_Long 
		 end  as Users,
		Case 
		  When @appUsageDuration=1   then M.DailyAverage_Short
		  When @appUsageDuration=2 then M.DailyAverage_Medium
		  else M.DailyAverage_Long
		end  as DailyAverage,
	
		o.JobFamilyName as JobFamilyOverrides,
		u.ProfileName as MappingOverrides	
		INTO #webAppBase

		from org.WebAppSpec w
	Left join org.ActivitySpec a on a.ActivitySpecID=w.ActivitySpecID and w.CompanyID=a.CompanyID
	Left join org.AppMetrics M on M.WebAppSpecID=w.WebAppSpecID and M.CompanyID=w.CompanyID
	Left join (SELECT ja.JobFamilyName,jw.WebAppSpecID FROM org.JobFamilyWebAppSpecOverride jw 
				Left join  org.JobFamilyActivityOverrideProfile ja on ja.JobFamilyActivityOverrideProfileID=jw.JobFamilyActivityOverrideProfileID and ja.CompanyID=jw.CompanyID
				WHERE jw.CompanyID=@localCompanyID  AND WebAppSpecID IN
					(SELECT WebAppSpecID FROM org.JobFamilyWebAppSpecOverride	WHERE CompanyID=@localCompanyID 
					  GROUP BY WebAppSpecID HAVING COUNT(1) = 1))o on w.WebAppSpecID=o.WebAppSpecID
	Left join (SELECT ua.ProfileName,uw.WebAppSpecID FROM org.UserWebAppSpecOverride uw 
				Left join  org.UserActivityOverrideProfile ua on ua.UserActivityOverrideProfileID=uw.UserActivityOverrideProfileID and ua.CompanyID=uw.CompanyID
				WHERE uw.CompanyID=@localCompanyID  AND WebAppSpecID IN
					(SELECT WebAppSpecID FROM org.UserWebAppSpecOverride	WHERE CompanyID=@localCompanyID 
					  GROUP BY WebAppSpecID HAVING COUNT(1) = 1))u on w.WebAppSpecID=u.WebAppSpecID			

	WHERE w.CompanyID=@localCompanyID 
    OPTION(RECOMPILE) 

	ALTER TABLE #webAppBase ALTER COLUMN JobFamilyOverrides NVARCHAR(500)
	ALTER TABLE #webAppBase ALTER COLUMN MappingOverrides NVARCHAR(500)


	--******** THOSE WebApps WITH MULTIPLE JobFamily Overrides
	DECLARE @JobFamilyWebAppSpecOverride TABLE (ID INT, WebAppSpecID INT)
	INSERT INTO @JobFamilyWebAppSpecOverride (ID, WebAppSpecID)
	SELECT ROW_NUMBER() OVER(ORDER BY WebAppSpecID) ID, WebAppSpecID FROM org.JobFamilyWebAppSpecOverride WHERE CompanyID=@localCompanyID GROUP BY WebAppSpecID HAVING COUNT(1) >1

	SET @counter=1
	WHILE (@counter <= (SELECT MAX(ID) FROM @JobFamilyWebAppSpecOverride))
	BEGIN
		SET @str_ProfileNames=''
		SELECT @WebAppSpecID = WebAppSpecID FROM @JobFamilyWebAppSpecOverride WHERE ID=@counter

		SELECT @str_ProfileNames=COALESCE(@str_ProfileNames + ', ', '') + JobFamilyName FROM org.JobFamilyWebAppSpecOverride a
		JOIN org.JobFamilyActivityOverrideProfile b ON a.CompanyID = b.CompanyID AND a.JobFamilyActivityOverrideProfileID = b.JobFamilyActivityOverrideProfileID
		WHERE a.CompanyID=@localCompanyID AND WebAppSpecID = @WebAppSpecID

		UPDATE #webAppBase
		SET JobFamilyOverrides = SUBSTRING(@str_ProfileNames, 3, LEN(@str_ProfileNames))
		WHERE CompanyID=@localCompanyID AND ID=@WebAppSpecID

		SET @counter=@counter+1
	END


	--********* THOSE WebApps WITH MULTIPLE User Overrides
	DECLARE @UserWebAppSpecOverride TABLE (ID INT, WebAppSpecID INT)
	INSERT INTO @UserWebAppSpecOverride (ID, WebAppSpecID)
	SELECT ROW_NUMBER() OVER(ORDER BY WebAppSpecID) ID, WebAppSpecID FROM org.UserWebAppSpecOverride WHERE CompanyID=@localCompanyID GROUP BY WebAppSpecID HAVING COUNT(1) >1

	SET @counter=1
	WHILE (@counter <= (SELECT MAX(ID) FROM @UserWebAppSpecOverride))
	BEGIN
		SET @str_ProfileNames=''
		SELECT @WebAppSpecID = WebAppSpecID FROM @UserWebAppSpecOverride WHERE ID=@counter

		SELECT @str_ProfileNames=COALESCE(@str_ProfileNames + ', ', '') + ProfileName FROM org.UserWebAppSpecOverride a
		JOIN org.UserActivityOverrideProfile b ON a.CompanyID = b.CompanyID AND a.UserActivityOverrideProfileID = b.UserActivityOverrideProfileID
		WHERE a.CompanyID=@localCompanyID AND WebAppSpecID = @WebAppSpecID

		UPDATE #webAppBase
		SET MappingOverrides = SUBSTRING(@str_ProfileNames, 3, LEN(@str_ProfileNames))
		WHERE CompanyID=@localCompanyID AND ID=@WebAppSpecID

		SET @counter=@counter+1
	END


	--***********************Get AppSpecs for company******************
	select app.CompanyID, app.AppSpecID as ID,app.AppExeName as ApplicationOrUrl ,app.AppDisplayName as DisplayName ,
	Cast(null as nvarchar) as UrlMatchContent,Cast(null as nvarchar) as UrlPattern,Cast(null as int)UrlPatternSort,act.ActivitySpecID
	,
	Case When act.IsCore is null then 0
		else act.IsCore
		end IsCore		
	,
	Case When act.IsWorkCategory is null then 0
		else act.IsWorkCategory
		end IsWorkCategory
	,
	act.ActivitySpecName  as ActivityName,cast(0 as bit) as IsWebApp,app.MergePriority as RemoteAccess,
	 Case
		  When act.IsWorkCategory=0 or act.IsWorkCategory is null
		 then 'Private' 
		 else 'Work'
		 end  as Category,

		 Case 
		 When app.ActivitySpecID is not null
		 then 'Mapped'
		 else 'UnMapped' end as Status,
	   Case
		  When @appUsageDuration=1   then  M.NumberOfUsers_Short
		  When @appUsageDuration=2 then  M.NumberOfUsers_Medium
		  else M.NumberOfUsers_Long 
		 end  as Users,
		Case 
		  When @appUsageDuration=1   then M.DailyAverage_Short
		  When @appUsageDuration=2 then M.DailyAverage_Medium
		  else M.DailyAverage_Long
		end  as DailyAverage,	
	   o.JobFamilyName as JobFamilyOverrides,
	   u.ProfileName as MappingOverrides
		INTO #appSpecBase
	from org.AppSpec app
	Left join org.ActivitySpec act on act.ActivitySpecID=app.ActivitySpecID and act.CompanyID=app.CompanyID
	Left join org.AppMetrics M on M.AppSpecId=app.AppSpecID and M.CompanyID=app.CompanyID
	Left join (SELECT ja.JobFamilyName,jao.AppSpecID FROM org.JobFamilyAppSpecOverride jao 
				Left join  org.JobFamilyActivityOverrideProfile ja on ja.JobFamilyActivityOverrideProfileID=jao.JobFamilyActivityOverrideProfileID and ja.CompanyID=jao.CompanyID
				WHERE jao.CompanyID=@localCompanyID  AND AppSpecID IN
					(SELECT AppSpecID FROM org.JobFamilyAppSpecOverride	WHERE CompanyID=@localCompanyID 
					  GROUP BY AppSpecID HAVING COUNT(1) = 1))o on app.AppSpecID=o.AppSpecID

	Left join (SELECT uap.ProfileName,ua.AppSpecID FROM org.UserAppSpecOverride ua 
				Left join  org.UserActivityOverrideProfile uap on ua.UserActivityOverrideProfileID=uap.UserActivityOverrideProfileID and ua.CompanyID=uap.CompanyID
				WHERE ua.CompanyID=@localCompanyID 
				 AND 
				AppSpecID IN
				(SELECT AppSpecID FROM org.UserAppSpecOverride	WHERE CompanyID=@localCompanyID  GROUP BY AppSpecID HAVING COUNT(1) = 1))u on app.AppSpecID=u.AppSpecID
	WHERE app.CompanyID=@localCompanyID  
	
	
	OPTION(RECOMPILE) 

	ALTER TABLE #appSpecBase ALTER COLUMN JobFamilyOverrides NVARCHAR(500)
	ALTER TABLE #appSpecBase ALTER COLUMN MappingOverrides NVARCHAR(500)


	--******** THOSE Apps WITH MULTIPLE JobFamily Overrides
	DECLARE @JobFamilyAppSpecOverride TABLE (ID INT, AppSpecID INT)
	INSERT INTO @JobFamilyAppSpecOverride (ID, AppSpecID)
	SELECT ROW_NUMBER() OVER(ORDER BY AppSpecID) ID, AppSpecID FROM org.JobFamilyAppSpecOverride WHERE CompanyID=@localCompanyID GROUP BY AppSpecID HAVING COUNT(1) >1

	SET @counter=1
	WHILE (@counter <= (SELECT MAX(ID) FROM @JobFamilyAppSpecOverride))
	BEGIN
		SET @str_ProfileNames=''
		SELECT @AppSpecID = AppSpecID FROM @JobFamilyAppSpecOverride WHERE ID=@counter

		SELECT @str_ProfileNames=COALESCE(@str_ProfileNames + ', ', '') + JobFamilyName FROM org.JobFamilyAppSpecOverride a
		JOIN org.JobFamilyActivityOverrideProfile b ON a.CompanyID = b.CompanyID AND a.JobFamilyActivityOverrideProfileID = b.JobFamilyActivityOverrideProfileID
		WHERE a.CompanyID=@localCompanyID AND AppSpecID = @AppSpecID

		UPDATE #appSpecBase
		SET JobFamilyOverrides = SUBSTRING(@str_ProfileNames, 3, LEN(@str_ProfileNames))
		WHERE CompanyID=@localCompanyID AND ID=@AppSpecID

		SET @counter=@counter+1
	END


	--******** THOSE Apps WITH MULTIPLE User O verrides
	DECLARE @UserAppSpecOverride TABLE (ID INT, AppSpecID INT)
	INSERT INTO @UserAppSpecOverride (ID, AppSpecID)
	SELECT ROW_NUMBER() OVER(ORDER BY AppSpecID) ID, AppSpecID FROM org.UserAppSpecOverride WHERE CompanyID=@localCompanyID GROUP BY AppSpecID HAVING COUNT(1) >1

	SET @counter=1
	WHILE (@counter <= (SELECT MAX(ID) FROM @UserAppSpecOverride))
	BEGIN
		SET @str_ProfileNames=''
		SELECT @AppSpecID = AppSpecID FROM @UserAppSpecOverride WHERE ID=@counter

		SELECT @str_ProfileNames=COALESCE(@str_ProfileNames + ', ', '') + ProfileName FROM org.UserAppSpecOverride a
		JOIN org.UserActivityOverrideProfile b ON a.CompanyID = b.CompanyID AND a.UserActivityOverrideProfileID = b.UserActivityOverrideProfileID
		WHERE a.CompanyID=@localCompanyID AND AppSpecID = @AppSpecID

		UPDATE #appSpecBase
		SET MappingOverrides = SUBSTRING(@str_ProfileNames, 3, LEN(@str_ProfileNames))
		WHERE CompanyID=@localCompanyID AND ID=@AppSpecID

		SET @counter=@counter+1
	END


	--******** BUILD @strSQL string
	SET @strSQL = 
	'SELECT * FROM 
		(SELECT * FROM #webAppBase
		UNION ALL
		SELECT * FROM #appSpecBase) results 
	WHERE 1=1'
	+ CASE WHEN @iswebApp IS NULL THEN '' WHEN @iswebApp=1 THEN ' AND IsWebApp=1' WHEN @iswebApp=0 THEN ' AND IsWebApp=0' END
	+ CASE WHEN @IsRemote IS NULL THEN '' WHEN @IsRemote=1 THEN ' AND RemoteAccess=1' WHEN @IsRemote=0 THEN ' AND RemoteAccess=0' END
	+ CASE WHEN @searchBy IS NULL THEN '' ELSE ' AND DisplayName LIKE ''%' + @searchBy + '%''' END
	+ CASE WHEN @isMapped IS NULL THEN '' WHEN @isMapped=1 THEN ' AND Status=''Mapped''' WHEN @isMapped=0 THEN ' AND Status=''UnMapped''' END
	+ CASE WHEN @isWork IS NULL THEN '' WHEN @isWork=1 THEN ' AND IsWorkCategory=1' WHEN @isWork=0 THEN ' AND IsWorkCategory=0' END
	+ CASE WHEN @activityIds = '' THEN '' ELSE ' AND ActivitySpecID IN (' + @activityIds + ')' END	
	+Case When @overrideIds='' Then '' Else ' AND ID NOT IN ('+@overrideIds+')'END
	+ ' ORDER BY ' + CASE @sortBy WHEN 'MergePriority' THEN 'RemoteAccess' WHEN 'UrlPattern' THEN 'UrlPatternSort' ELSE @sortBy END + CASE @orderBy WHEN 1 THEN ' DESC' ELSE ' ASC' END
	+ ' OFFSET ' + CAST(@skipRows AS varchar(10)) + ' ROWS'
	+ ' FETCH NEXT ' + CAST(@pageSize AS varchar(10)) + ' ROWS ONLY'
	+ '	SELECT @TotalCount=COUNT(1) FROM 
		(SELECT * FROM #webAppBase
		UNION ALL
		SELECT * FROM #appSpecBase) results 
	WHERE 1=1'
	+ CASE WHEN @iswebApp IS NULL THEN '' WHEN @iswebApp=1 THEN ' AND IsWebApp=1' WHEN @iswebApp=0 THEN ' AND IsWebApp=0' END
	+ CASE WHEN @IsRemote IS NULL THEN '' WHEN @IsRemote=1 THEN ' AND RemoteAccess=1' WHEN @IsRemote=0 THEN ' AND RemoteAccess=0' END
	+ CASE WHEN @searchBy IS NULL THEN '' ELSE ' AND DisplayName LIKE ''%' + @searchBy + '%''' END
	+ CASE WHEN @isMapped IS NULL THEN '' WHEN @isMapped=1 THEN ' AND Status=''Mapped''' WHEN @isMapped=0 THEN ' AND Status=''UnMapped''' END
	+ CASE WHEN @isWork IS NULL THEN '' WHEN @isWork=1 THEN ' AND IsWorkCategory=1' WHEN @isWork=0 THEN ' AND IsWorkCategory=0' END
	+ CASE WHEN @activityIds = '' THEN '' ELSE ' AND ActivitySpecID IN (' + @activityIds + ')' END	
	+Case When @overrideIds='' Then '' Else ' AND ID NOT IN ('+@overrideIds+')'END

    --******** OUTPUT 
	EXEC sp_executesql @strSQL, N'@TotalCount int OUT', @TotalCount = @rowCount OUT;
 	
	 --SELECT @rowCount TotalRows; 
	 SET @TotalCount =@rowCount

	DROP TABLE #webAppBase
	DROP TABLE #appSpecBase

END
GO
/****** Object:  StoredProcedure [dbo].[sproc_GetDailyActiveUserCounts]    Script Date: 8/20/2021 4:27:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--USE [Admin]
--GO
--/****** Object:  StoredProcedure [dbo].[sproc_VueUsageInfo]    Script Date: 2021-04-22 4:38:36 PM ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO

CREATE     PROCEDURE [dbo].[sproc_GetDailyActiveUserCounts]
(
     @companyID int
	,@startDate Datetime,
	 @endDate Datetime
)
AS
BEGIN

	DECLARE @CurrentDate AS DATETIME,@dailyUsage INT
	SET @CurrentDate = @StartDate
	CREATE TABLE #temp
	(
	   UsageDate DateTime,
	   UsageCount int
	)

	WHILE (@CurrentDate < @EndDate)
	BEGIN
		Insert into #temp (UsageDate,UsageCount) 
			(select @CurrentDate, count(*) 
			from org.Users  
			FOR SYSTEM_TIME AS OF  @CurrentDate 
			WHERE IsActive=1 and CompanyId=@companyID)

		SET @CurrentDate = convert(varchar(30), dateadd(day,1, @CurrentDate), 101);
	END

	 SELECT 	
		DATEPART(MONTH, UsageDate) as [Month], 
		SUM(UsageCount)/DAY(EOMONTH(UsageDate))  as [Value]
	FROM #temp 
	GROUP BY 
		DATEPART(YEAR, UsageDate), 
		DATEPART(MONTH, UsageDate),
		DAY(EOMONTH(UsageDate))
	
END
GO
/****** Object:  StoredProcedure [dbo].[sproc_GetUsersExport]    Script Date: 8/20/2021 4:27:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE     PROCEDURE [dbo].[sproc_GetUsersExport]

(
	@companyID INT,
	@searchBy  nvarchar(200)='',
	@jobFamilyIds  nvarchar(200)='',--comma Seperated
	@departmentIds  nvarchar(200)='',--commaSeperated
	@isActive bit=1,
	@reportToIds  nvarchar(200)='',
	@isActivityCollectionOn bit=null,
	@isAdmin bit=null,
	@isEmployee bit=null,
	@isReportWriter bit=null
)

AS 
BEGIN

DECLARE @localCompanyID INT,@strSQL NVARCHAR(4000),@adminRole nvarchar(25) = 'False',@biRole nvarchar(25) = 'False',@employeeAccess nvarchar(25) = 'False',@ListToPivot nvarchar(max)
SET @localCompanyID = @companyID


-- ********** #UserDomain **********
SELECT UserID, UserName, DomainName INTO #UserDomain FROM org.UserDomain 
WHERE CompanyID=@localCompanyID AND UserID IN
	(SELECT UserID FROM org.UserDomain
	WHERE CompanyID=@localCompanyID
	GROUP BY UserID HAVING COUNT(1) = 1)

---******************#UserCustomField**********************

DECLARE @PivotSql NVARCHAR(MAX)

CREATE TABLE #CField (CustomFieldName  VARCHAR(1000) )
INSERT INTO #CField
SELECT distinct c.[Name] as CustomFieldName  From org.CustomField c  
inner join org.Settings s on s.SettingId=c.EntityId
where c.CompanyId=@localCompanyID and s.SettingName='Users'

Select @ListToPivot= STUFF((SELECT DISTINCT ', '+QUOTENAME(CustomFieldName) FROM #CField FOR XML PATH ('')),1,2,'')

if @ListToPivot is null
BEGIN 
SET @PivotSql= N'SELECT *  Into ##TempPivot from( 					
					SELECT uc.UserID as UserIdWithCustomField, c.Name as CustomFieldName, 
					COALESCE(uc.StringValue,STR(uc.NumericValue,18,2),
					case when uc.BooleanValue = 1 then ''Yes'' 
				         when uc.BooleanValue = 0 then ''No'' 
						  else null end ) as CustomValue
					from org.UserCustomField uc 
					inner join  org.CustomField c on c.CompanyID='+ CAST(@localCompanyID AS NVARCHAR(1000)) + '   and c.CustomFieldID=uc.CustomFieldID
						where uc.CompanyID='+ CAST(@localCompanyID AS NVARCHAR(1000)) + ' 
					) t'
END

ELSE 
BEGIN

SET @PivotSql= N'SELECT *  Into ##TempPivot from( 					
					SELECT uc.UserID as UserIdWithCustomField, c.Name as CustomFieldName, 
					COALESCE(uc.StringValue,STR(uc.NumericValue,18,2),
					case when uc.BooleanValue = 1 then ''Yes'' 
				         when uc.BooleanValue = 0 then ''No'' 
						  else null end ) as CustomValue
					from org.UserCustomField uc 
					inner join  org.CustomField c on c.CompanyID='+ CAST(@localCompanyID AS NVARCHAR(1000)) + '   and c.CustomFieldID=uc.CustomFieldID
						where uc.CompanyID='+ CAST(@localCompanyID AS NVARCHAR(1000)) + ' 
					) t 
					PIVOT ( Max(CustomValue)  For CustomFieldName in ('+@ListToPivot+' ) ) pt '

END



PRINT @PivotSql
Exec(@PivotSql);
--Select * Into #UserCustomFields from ##TempPivot
DROP TABLE #CField
--DROP TABLE ##TempPivot


-- *********************** BASE QUERY, POPULATING #Base ***********************
SELECT distinct
 u.CompanyID,
       u.UserID , 
	   u.FirstName ,  u.LastName, u.UserEmail, u.ExternalUserID, u.JobTitle,    
       u.IsActivityCollectionOn, 
	   case when  u.IsFullTimeEmployee =0 then 'True' else 'False' end as [IsContractor]	   
	   ,u.DepartmentId,
       d.DepartmentName,  loc.LocationName,   mgr.UserID as ManagerID,     
       (mgr.FirstName + ' ' + mgr.LastName) as ManagerName,mgr.UserEmail as ManagerEmail,u.IsActive,
      jao.JobFamilyActivityOverrideProfileID,
	   jao.JobFamilyName as JobFamilyActivityOverrideProfileName,
       uao.ProfileName as UserActivityOverrideProfileName, v.VendorName,   
       IsDepartmentOwner = case  when d2.departmentId IS NULL then 'False' else 'True' end ,
	   IsAdmin = case when Admn.UserID IS NULL then 'False' else 'True' end,
	   VuePortalAccess = case when Emp.UserID IS NULL then 'False' else 'True' end,
	   IsReportWriter = case when BI.UserID IS NULL then 'False' else 'True' end,
	   ud.DomainName DomainName1, ud.UserName UserName1,
	   CAST(NULL as nvarchar(100)) DomainName2,
	   CAST(NULL as nvarchar(100)) UserName2,
	   uc.*
	
	  
INTO #base
FROM [org].Users u  
   LEFT JOIN  [org].Department d on d.CompanyId = u.CompanyId and d.DepartmentId = u.DepartmentId
   LEFT JOIN  [org].Department d2 on d2.CompanyId = u.CompanyId and d2.DepartmentOwnerId = u.UserId
   LEFT JOIN  [org].Team t on t.CompanyId = u.CompanyId and t.TeamID = u.TeamID
   LEFT JOIN  [org].Users mgr on mgr.CompanyId = u.CompanyId and mgr.UserID = t.ManagerID
   LEFT JOIN  [org].UserActivityOverrideProfile uao on uao.CompanyId = u.CompanyId and uao.UserActivityOverrideProfileID = u.UserActivityOverrideProfileID
   LEFT JOIN  [org].JobFamilyActivityOverrideProfile jao on jao.CompanyId = u.CompanyId and jao.JobFamilyActivityOverrideProfileID = u.JobFamilyActivityOverrideProfileID
   LEFT JOIN  [org].Vendor v on v.CompanyId = u.CompanyId and v.VendorID = u.VendorID
   LEFT JOIN  [org].[Location] loc on loc.CompanyId = u.CompanyId and loc.LocationID = u.LocationID
   LEFT JOIN (SELECT distinct UserID from org.UserPermission where CompanyID=@localCompanyID    AND Entity='Admin') Admn ON u.UserID = Admn.UserID
   LEFT JOIN (SELECT distinct UserID from org.UserPermission where CompanyID=@localCompanyID     AND Entity='Employees') Emp ON u.UserID = Emp.UserID
   LEFT JOIN (SELECT distinct UserID from org.UserPermission where CompanyID=@localCompanyID     AND Entity='Report Writer') BI ON u.UserID = BI.UserID
   LEFT JOIN #UserDomain ud ON u.UserID = ud.UserID
   LEFT JOIN ##TempPivot uc on u.UserID=uc.UserIdWithCustomField
   WHERE u.CompanyID=@localCompanyID  and u.IsActive=@isActive

OPTION(RECOMPILE) 

--*********** THOSE USERS WITH MULTIPLE USER DOMAINS *************

--****** Domain 1 ******
UPDATE #base
SET DomainName1=ud1.DomainName,
	UserName1=ud1.UserName
FROM
(SELECT ROW_NUMBER() OVER(PARTITION BY UserID ORDER BY UserID) DomainNumber, 
UserID, UserName, DomainName  FROM org.UserDomain 
WHERE CompanyID=@localCompanyID AND UserID IN
	(SELECT UserID FROM org.UserDomain
	WHERE CompanyID=@localCompanyID
	GROUP BY UserID HAVING COUNT(1) >1) -- IN (2,3)
) ud1
JOIN #base  ON ud1.UserID = #base.userID
WHERE DomainNumber=1

--****** Domain 2 ******
UPDATE #base
SET  DomainName2 = ud2.DomainName,	UserName2 = ud2.UserName
FROM
(SELECT ROW_NUMBER() OVER(PARTITION BY UserID ORDER BY UserID) DomainNumber, 
UserID, UserName, DomainName  FROM org.UserDomain 
WHERE CompanyID=@localCompanyID AND UserID IN
	(SELECT UserID FROM org.UserDomain
	WHERE CompanyID=@localCompanyID
	GROUP BY UserID HAVING COUNT(1)>1) -- IN (2,3)
) ud2
JOIN #base ON ud2.UserID = #base.userID
WHERE DomainNumber=2

	--******** BUILD @strSQL string
SET @adminRole=  Case @isAdmin When 1 then 'True' When 0 THEN 'False' ELSE NULL End
SET @biRole=Case  @isReportWriter When 1 then 'True' When 0 THEN 'False' ELSE NULL End
SET @employeeAccess=Case  @isEmployee When 1 then 'True' When 0 THEN 'False' ELSE NULL End


if @ListToPivot is null or @ListToPivot=''
BEGIN 

ALTER table #base drop column UserIdWithCustomField,CustomFieldName,CustomValue

END



SET @strSQL= 'SELECT * FROM #base  WHERE 1=1'
			+ CASE WHEN @jobFamilyIds = '' THEN '' ELSE ' AND JobFamilyActivityOverrideProfileID IN (' + @jobFamilyIds + ')' END	
			+ CASE WHEN @departmentIds = '' THEN '' ELSE ' AND DepartmentId IN (' + @departmentIds + ')' END	
			+ CASE WHEN @reportToIds = '' THEN '' ELSE ' AND ManagerID IN (' + @reportToIds + ')' END	
			+ CASE WHEN @isActivityCollectionOn is NULL THEN ''  ELSE ' AND IsActivityCollectionOn =' + CAST(@isActivityCollectionOn AS CHAR(1)) + '' END	
			+ CASE WHEN @searchBy='' THEN '' ELSE  ' AND (FirstName LIKE ''%' + @searchBy + '%'' Or  LastName LIKE ''%' + @searchBy + '%'' or UserEmail Like ''%' + @searchBy + '%'')' END
			+ CASE WHEN @adminRole is NULL THEN '' ELSE  ' AND IsAdmin= '''+@adminRole+'''' END
			+ CASE WHEN @employeeAccess is NULL THEN '' ELSE  ' AND   VuePortalAccess= ''' + @employeeAccess + '''' END
			+ CASE WHEN @biRole is NULL THEN '' ELSE  ' AND  IsReportWriter= ''' + @biRole + ''' ' END			
			+' order by FirstName '
   --******** OUTPUT ***

EXEC sp_executesql  @strSQL
	print @strSQL



DROP TABLE #base
DROP TABLE #UserDomain
DROP TABLE ##TempPivot
END


GO
/****** Object:  StoredProcedure [dbo].[sproc_MigrateMADDataToAdmin]    Script Date: 8/20/2021 4:27:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




 CREATE   PROCEDURE [dbo].[sproc_MigrateMADDataToAdmin]
(

		@TenantName nvarchar(1000)
		,@CompanyName nvarchar(1000)
	
)
AS
BEGIN
			
			       declare @AdminTenantID AS INT
						   ,@AdminCompanyID AS INT
						   ,@MadCompanyID AS INT
						   ,@WorkScheduleID AS INT
				


            
		---- Tenant
		Select * into #Tenant from [MD].[Tenant] Where [TenantName] = @TenantName


		MERGE [dbo].[Tenant] T
		USING #Tenant S
		ON (S.[TenantName] = T.[TenantName])
		WHEN MATCHED 
		     THEN UPDATE
		     SET    T.[IsActive] = CASE WHEN S.DateDeleted IS NULL THEN 1 ELSE 0 end 
		WHEN NOT MATCHED BY TARGET
		THEN INSERT ([TenantName],[IsActive],[ModifiedBy])
		     VALUES (S.[TenantName], CASE WHEN S.DateDeleted IS NULL THEN 1 ELSE 0 END , 'System') ;
		
		Select @AdminTenantID = [TenantID] FROM [dbo].[Tenant] WHere [TenantName] = @TenantName

		--- Company
		Select * into #Company from [MD].[Company] Where [CompanyName] = @CompanyName

		MERGE [dbo].[Company] T
		USING #Company S
		ON (S.[CompanyName] = T.[CompanyName])
		WHEN MATCHED 
		     THEN UPDATE
		     SET    T.[IsActive] = CASE WHEN S.DateDeleted IS NULL THEN 1 ELSE 0 end 
		WHEN NOT MATCHED BY TARGET
		THEN INSERT ([TenantID],[CompanyName],[IsActive],[ModifiedBy])
		     VALUES (@AdminTenantID, [CompanyName],CASE WHEN S.DateDeleted IS NULL THEN 1 ELSE 0 end,'System') ;

		Select @AdminCompanyID = [CompanyID] FROM [dbo].[Company] WHere [CompanyName] = @CompanyName
		
		Select @MadCompanyID = [CompanyID] FROM [MD].[Company] WHere [CompanyName] = @CompanyName
		
		--- Department
		
		Select * into #Department from [MD].[Department] Where [CompanyID] = @MadCompanyID


		MERGE [dbo].[Department] T
		USING #Department S
		ON (T.[CompanyID] = @AdminCompanyID AND S.[DepartmentName] = T.[DepartmentName])
		WHEN NOT MATCHED BY TARGET
		THEN INSERT ([CompanyID],[DepartmentCode],[DepartmentName],[DepartmentDescription],[DepartmentOwnerID],[IsEmployeeActivityVisible],[IsActive],[ModifiedBy])
		VALUES (@AdminCompanyID,SUBSTRING([DepartmentCode],1,20),[DepartmentName],null,null,null,IsActive,'System');
		
		
		--- Location
		Select * into #Location from [MD].[Location] Where [CompanyID] = @MadCompanyID
		
		
		MERGE [dbo].[Location] T
		USING #Location S
		ON (T.[CompanyID] = @AdminCompanyID AND S.LocationName = T.LocationName )
		WHEN MATCHED 
		THEN UPDATE
		SET    T.[City] = CASE WHEN S.[City] IS NULL THEN S.[LocationName] ELSE S.[City] end
		WHEN NOT MATCHED BY TARGET
		THEN INSERT ([CompanyID],[LocationName],[City],[Country],[Statoid],[LocationExtra],[IsActive],[ModifiedBy])
		VALUES (@AdminCompanyID,S.[LocationName],CASE WHEN S.[City] is NULL THEN S.[LocationName] else S.[City] END,S.[Country],S.[State],null,1,'System') ;
		
		--- EmployeeTitle
		Select * into #EmployeeTitle from [MD].[EmployeeTitle] Where [CompanyID] = @MadCompanyID

		MERGE [dbo].[JobFamilyActivityOverrideProfile] T
		USING #EmployeeTitle S
		ON (T.[CompanyID] = @AdminCompanyID AND T.[JobFamilyName] = S.[EmployeeTitle])
		WHEN NOT MATCHED BY TARGET
		THEN INSERT ([CompanyID],[JobFamilyName],[IsActive],[ModifiedBy])
		VALUES (@AdminCompanyID,EmployeeTitle,IsActive,'System');

		--- User
		
			
		Drop table If Exists #Users

			Select a.*,b.LocationName,c.DomainUserID,c.DomainName,d.LocationID as adminLocationID,e.JobFamilyActivityOverrideProfileID,f.EmployeeTitleCode into #Users
				from [MD].[Users] a
				LEFT join [MD].[Location] b
				ON a.CompanyID = b.CompanyID AND a.LocationID = b.LocationID
				LEFT join [MD].[EmployeeTitle] f
				ON a.CompanyID = f.CompanyID AND a.JobFamilyID = f.EmployeeTitleID
				LEFT join [MD].[UserDomain] c
				ON a.CompanyID = c.CompanyID AND a.UserID = c.UserID
				LEFT JOIN (Select * from [dbo].[Location] Where [CompanyID] = @AdminCompanyID) d
				ON(b.LocationName = d.LocationName)
				LEFT JOIN (Select * from [dbo].[JobFamilyActivityOverrideProfile] Where [CompanyID] = @AdminCompanyID) e
				ON(f.EmployeeTitle = e.JobFamilyName)
				Where a.CompanyID = @MadCompanyID



		 if not exists(select 1 from [dbo].[WorkSchedule]
               where CompanyID = @AdminCompanyID and WorkScheduleName = 'Regular Schedule') 
		 begin
		 INSERT INTO [dbo].[WorkSchedule]([CompanyID],[WorkScheduleName],[WorkScheduleDescription],[IsDefault],[WorkWeekTotalHours],[IsWorkWeekCustom],[IsSunWorkDay],[IsMonWorkDay],[IsTuesWorkDay],[IsWedWorkDay],[IsThuWorkDay],[IsFriWorkDay],[IsSatWorkDay],[ReportNonWorkDayActivityAsWork],[IsActive],[ModifiedBy])
		 	select @AdminCompanyID
		 	,'Regular Schedule' as WorkScheduleName
		 			,'Company regular work week' as WorkScheduleDescription
		 			,1 as IsDefault
		 			,40 WorkWeekTotalHours
		 			,0 IsWorkWeekCustom
		 			,0 IsSunWorkDay
		 			,1 IsMonWorkDay
		 			,1 IsTueWorkDay
		 			,1 IsWedWorkDay
		 			,1 IsThuWorkDay
		 			,1 IsFriWorkDay
		 			,0 IsSatWorkDay
		 			,0 ReportNonWorkDayActivityAsWork
		 			,1 IsActive
		 			,'System' as ModifiedBy
		 end
		 
		 Select @WorkScheduleID = WorkScheduleID FROM [dbo].[WorkSchedule] Where [CompanyID] = @AdminCompanyID
		  --- Mapping Department Details

		 Select a.CompanyID,a.UserID,a.DepartmentID,b.DepartmentName,c.DepartmentID AdminDepartmentID INTO #DeptHist
			From [MD].[UserDepartmentHistory] a
			INNER JOIN [MD].[Department] b
			on(a.CompanyID = b.CompanyID  AND a.DepartmentID = b.DepartmentID AND a.CompanyID = @MadCompanyID)
			INNER JOIN [dbo].[Department] c
			on(c.CompanyID = @AdminCompanyID AND b.DepartmentName = c.DepartmentName )

		ALter table #Users
		Add departmentID INT

		 UPDATE T1
		 SET T1.departmentID = T2.AdminDepartmentID 
		 FROM #Users T1, #DeptHist T2
		 WHERE T1.[CompanyID] = @MadCompanyID AND T1.UserId = T2.UserId


		 
		 MERGE [dbo].[Users] T
		 USING #Users S
		 ON (T.[CompanyID] = @AdminCompanyID AND LOWER(S.[UserEmail]) = LOWER(T.[UserEmail]))
		 WHEN NOT MATCHED BY TARGET
		 THEN INSERT ([CompanyID],[DepartmentID],[LocationID],[UserEmail],[FirstName],[LastName],[UserName],JobFamilyActivityOverrideProfileID,[JobTitle],[WorkScheduleID],[IsActive],[ModifiedBy])
		 VALUES (@AdminCompanyID,departmentID,adminLocationID,[UserEmail],[FirstName],[LastName],CONCAT(LEFT([FirstName], 1),[LastName]),JobFamilyActivityOverrideProfileID,EmployeeTitleCode,@WorkScheduleID,[IsActive],'System') ;
		 
		 
		 Alter Table #Users
		 ADD AdminUserID INT
		 
		 UPDATE T1
		 SET T1.AdminUserID = T2.UserID 
		 FROM #Users T1, [dbo].[Users] T2
		 WHERE T1.[CompanyID] = @MadCompanyID AND T1.UserEmail = T2.UserEmail
		 
		


		  
		 --- UserDomain
		 MERGE [dbo].[UserDomain] T
		 USING #Users S
		 ON (T.[CompanyID] = @AdminCompanyID AND LOWER(S.DomainUserID) = LOWER(T.[UserName]))
		 WHEN NOT MATCHED BY TARGET
		 THEN INSERT ([CompanyID],[UserID],[UserName],[DomainName],[IsActive],[ModifiedBy])
		 VALUES (@AdminCompanyID,s.AdminUserID,s.DomainUserID,s.DomainName,1,'System') ;
		 
		 
		 --- Platform
		 Select * into #Platform from [MD].[PlatformType] Where [CompanyID] = @MadCompanyID
		 
		 MERGE [dbo].[Platform] T
		 USING #Platform S
		 ON (T.[CompanyID] = @AdminCompanyID AND LOWER(S.[PlatformName]) = LOWER(T.[PlatformName]))
		 WHEN NOT MATCHED BY TARGET
		 THEN INSERT ([CompanyID],[PlatformName],[PlatformVersion],[PlatformDescription],[IsActive],[ModifiedBy])
		 VALUES (@AdminCompanyID,[PlatformName],null,[PlatformTypeDescription],1,'System') ;
		 
		 
		  --- Team and ReportsTo
		 
		 Select a.adminUserID,a.UserEmail,a.ReportsToUserID,b.adminUserID as ReportsToID INTO #ReportTo
		 FROM  #Users a
		 INNER join #Users b
		 On (a.ReportsToUserID = b.UserID)
		 
		 
		 Select Distinct ReportsToID INTO #Team FROM #ReportTo
		 ALTER TABLE #Team ADD id INT IDENTITY(1,1) 
		 ALTER TABLE #Team ADD TeamName nVarchar(15)
		 
		 Update #Team
		 SET TeamName = CONCAT('Team',id)

		 MERGE [dbo].[Team] T
		 USING #Team S
		 ON (T.[CompanyID] = @AdminCompanyID AND T.ManagerID = S.ReportsToID)
		 WHEN NOT MATCHED BY TARGET
		 THEN INSERT ([CompanyID],[ManagerID],[TeamName],[ModifiedBy])
		 VALUES (@AdminCompanyID,ReportsToID,TeamName,'System');
		 
		 
		 UPDATE T1
		 SET T1.ReportsToID = T2.ReportsToID 
		 FROM [dbo].[Users] T1, #ReportTo T2
		 WHERE T1.[CompanyID] = @AdminCompanyID AND T1.UserID = T2.adminUserID
		 


		--- ActivityCategory
		Select * into #ActivityCategory from [MD].[ActivityCategory] Where [CompanyID] = @MadCompanyID
		
		
		 MERGE [dbo].[ActivitySpec] T
		 USING #ActivityCategory S
		 ON (T.[CompanyID] = @AdminCompanyID AND T.ActivitySpecName = S.ActivityCategoryName)
		 WHEN NOT MATCHED BY TARGET
		 THEN INSERT ([CompanyID],[ActivitySpecName],[ActivitySpecDescription],[IsCore],[IsSystemDefined],[IsWorkCategory],[IsDefault],[IsActive],[ModifiedBy])
		 VALUES (@AdminCompanyID,ActivityCategoryName,null,[IsCore],[IsSystemDefined],[IsConfigurable],0,[IsActive],'System');

		--- Exe

	  	Select L.CompanyID, L.ExeName, L.AppName, L.ActivityCategoryName, m.ActivitySpecID INTO #Exebase FROM 			
		(Select k.CompanyID, k.ExeName, k.AppName, k.ActivityCategoryName
		, ROW_NUMBER() OVER(Partition by CompanyID,ExeName ORDER BY AppName) AS Row_Number
		 FROM
				(Select a.CompanyID,a.ExeName, a.AppName,c.ActivityCategoryName
				FROM [MD].[AppMaster] a
				INNER JOIN [MD].[AppActivityCategoryMap] b
				ON(a.CompanyID = b.CompanyID AND a.EXEName = b.AppName)
				INNER JOIN [MD].[ActivityCategory] c
				ON(a.CompanyID = c.CompanyID AND b.ActivityCategoryID = c.ActivityCategoryID)
				WHere LOWER(a.EXEName) Like '%.exe' and a.CompanyID = 1) k ) L
		INNER JOIN [dbo].[ActivitySpec] m
		ON(L.ActivityCategoryName = m.ActivitySpecName And m.CompanyID = @AdminCompanyID)
		Where Row_Number = 1
	
	
		MERGE [dbo].[AppSpec] T
		 USING #Exebase S
		 ON (T.[CompanyID] = @AdminCompanyID AND T.AppExeName = S.ExeName)
		 WHEN NOT MATCHED BY TARGET
		 THEN INSERT ([CompanyID],[ActivitySpecID],[AppExeName],[AppDisplayName],[AppDescription],[IsActive],[ModifiedBy])
		 VALUES (@AdminCompanyID,ActivitySpecID,ExeName,AppName,null,1,'System');


		--- AppVersion 
		Select a.CompanyID, a.AppSpecID,c.PlatformID as PlatformID, b.AppVersion,a.AppDisplayName as DisplayName,0 as IsSystemDiscovered,'System' as ModifiedBY INTO #AppVersion from  
		[dbo].[AppSpec] a
		INNER JOIN (Select * from [MD].[AppMaster] WHere CompanyID = 1 and AppVersion <> '' ) b
		On(a.CompanyID = 337 ---@AdminCompanyID
		   AND b.CompanyID = 1---@MadCompanyID
		   AND LOWER(a.AppExeName) = LOWER(b.ExeName))
		INNER JOIN [dbo].[Platform] c
		On(a.CompanyID = c.CompanyID AND c.PlatformName = 'Windows')


		Select * INTO #AppVersionBase from  
		(Select CompanyID, AppSpecID, PlatformID, AppVersion, DisplayName, IsSystemDiscovered, ModifiedBY
		, ROW_NUMBER() OVER(Partition by AppSpecID, AppVersion ORDER BY DisplayName) AS Row_Number
		 FROM #AppVersion) k
		 WHere k.Row_Number = 1



		MERGE [dbo].[AppSpecPlatform] T
		 USING #AppVersionBase S
		 ON (T.[CompanyID] = @AdminCompanyID AND T.AppSpecID = S.AppSpecID AND T.AppVersion = S.AppVersion )
		 WHEN NOT MATCHED BY TARGET
		 THEN INSERT ([CompanyID],[AppSpecID],[PlatformID],[AppVersion],[DisplayName],[IsSystemDiscovered],[ModifiedBy])
		 VALUES (@AdminCompanyID,[AppSpecID],[PlatformID],[AppVersion],SUBSTRING([DisplayName],1,28),[IsSystemDiscovered],[ModifiedBy]);



	Drop table if Exists #ReportTo
	Drop table if Exists #Users
	Drop table if Exists #Team
	Drop table if Exists #Platform
	Drop table if Exists #Location
	DROP table if Exists #Exebase
	DROP table if Exists #Exebase
	DROP table if Exists #EmployeeTitle


END

GO
/****** Object:  StoredProcedure [dbo].[sproc_PurgeAdminDataForCompany]    Script Date: 8/20/2021 4:27:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create      PROCEDURE [dbo].[sproc_PurgeAdminDataForCompany]

	@CompanyID int,
	@TimeOutLimit int = 240,
	@DbName nvarchar(100),
	@TableId int = -1, -- -1: do not add table id
	@TableName nvarchar(100),
	@FilterColumn nvarchar(100),
	@FilterColumn1 nvarchar(100) = '',
	@CompareAllFilters bit = 0,
	@Debug tinyint = 100
	
	--WITH ENCRYPTION						
AS 
BEGIN
	SET NOCOUNT ON
	DECLARE 
		 @ErrorStr varchar(8000) 
		,@FromDate date, @ToDate date
		,@BatchCount int = 0
		,@DelCount int = 0
		,@RetentionPeriod int = 120
		,@DayBatchSize int = 30
		,@BatchLimit int = 100 -- Max Batches
		,@RetentionParam nvarchar(100)
		,@RetentionDate date	
		,@Table nvarchar(100) =  @TableName + case @TableId when -1 then '' else convert(nvarchar, @TableId) end
		,@FilterCondition nvarchar(4000) = ''
		,@LogName nvarchar(4000) = 'sproc_PurgeAdminDataForCompany, Table => ' +  @DbName + '.org.'+ @TableName, @LogDesc nvarchar(4000) = '', @ProcStartTime datetime = GetDate()
		,@ElapsedTimeInMins int = 0

	

	if (@RetentionParam = '')
	begin
		return; -- Invalid Table for Cleanup
	end

	if (@FilterColumn1 <> '')
	begin

		if (@CompareAllFilters = 0)
		begin

			set @FilterColumn =  ' IsNull(' + @FilterColumn + ',' + @FilterColumn1 + ') '
			
		end
		else begin
			set @FilterColumn = ' ( case when ' + @FilterColumn + ' > '  + @FilterColumn1 + ' then ' + @FilterColumn + ' else ' + @FilterColumn1 + ' end ) '
		end	
	end	

	declare @RootOrgs table (Idx int identity(1,1), CompanyID int, RetentionPeriod int, [BatchSize] int
		, BatchLimit int)
	
	declare @CompanyIdx int = 0, @CompanyCount int = 0 

	set @CompanyCount = @@ROWCOUNT

	
	if (@Debug = 100)

		select * from @RootOrgs

	-- Find Min and Max Date for the range to be deleted -- , @MaxDate = MAX(a.' + @FilterColumn + ')
	declare  @sqlInitRange nvarchar(max) = ' select @FromDate = MIN(' + @FilterColumn + ')
		from ' + 'org.'+ @Table + ' a 
		where 
			a.CompanyID = @CompanyID '

	-- purge records before @ToDate (and eventually before @RetentionDate)
	declare @sqlPurge nvarchar(max) = ' delete a from ' + 'org.[' + @Table + '] a 
		where 
			a.CompanyID = @CompanyID '
	
	if (@Debug = 99)
	begin
		
		print '@sqlInitRange => ' + @sqlInitRange
		print '----------------'
		print '----------------'
		print '@sqlPurge => ' + @sqlPurge

	end
	
	if (@Debug = 100)
	begin
		
		set @LogDesc = 'Company Count for Purge, => ' + convert(varchar, @CompanyCount)

		--INSERT INTO [dbo].[SapTraceLog] ([CompanyID] ,[LDate] ,[Name] ,[LogDesc] ,[ETInMS])
		--VALUES (@CompanyID, GetDate(), @LogName , @LogDesc,  DATEDIFF(second, @ProcStartTime, GetDate()))
		select @LogDesc 'Log Details'

	end

	

	
		begin try

			set @BatchCount = 0
			set @DelCount = -1
	
			if (@Debug = 100)
			begin
				set @LogDesc = 'Begin Cleanup, ElapsedTimeInMins => ' + convert(varchar, @ElapsedTimeInMins)

				--INSERT INTO [dbo].[SapTraceLog] ([CompanyID] ,[LDate] ,[Name] ,[LogDesc] ,[ETInMS])
				--VALUES (@CompanyID, GetDate(), @LogName , @LogDesc,  DATEDIFF(second, @ProcStartTime, GetDate()))

				select @LogDesc 'Log Details'
			end

	
			if (@FromDate IS NULL)
				set @FromDate = '2000-01-01'

			if (@Debug = 100)
			begin
				set @LogDesc = 'Init, RetentionDate => ' + IsNull(convert(varchar, @RetentionDate, 120), 'NULL')
					+ ', FromDate => ' + IsNull(convert(varchar, @FromDate, 120), 'NULL')

				
				
				select @LogDesc 'LogDesc'

			end

	
			print 'SQLPurge =>' + @sqlPurge 

			set @LogDesc = ' CompanyID = ' + IsNull(convert(varchar, @CompanyID), '') 
			
			select @LogDesc 'LogDesc'


			exec sp_executesql @sqlPurge, N'@CompanyID int, @FromDate Date, @ToDate Date, @DelCount int out'
			, @CompanyID, @FromDate, @ToDate, @DelCount out

			set @LogDesc = ' DelCount = ' + IsNull(convert(varchar, @DelCount), '') 
				--+ ' ' + ', BatchCount = ' + IsNull(convert(varchar, @BatchCount), '')

			select @LogDesc 'LogDesc'

		
	
			-- Log RowsDeleted if required..
				
		end try
		begin catch

			SELECT  @ErrorStr  ='ERROR: sproc_PurgeAdminDataForCompany 1: ' + @Table +  ', RootOrg => ' +  CONVERT(VARCHAR(20),@CompanyID) + ' ' + ERROR_MESSAGE()
				RAISERROR (@ErrorStr , -- Message text.
					18, -- Severity,
					3); -- State.
	
		end catch

	--END

	IF (@DEBUG = 1)
	BEGIN		
		select 'sproc_PurgeAdminDataForCompany END'
	END	

	if (@Debug = 100)
	BEGIN
		set @LogDesc = 'Cleanup End' 
		select @LogDesc 'Log Details'
	END					
	
	SET NOCOUNT OFF
END


GO
/****** Object:  StoredProcedure [dbo].[sproc_PurgeDataForCompany]    Script Date: 8/20/2021 4:27:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE     PROCEDURE [dbo].[sproc_PurgeDataForCompany]

	@CompanyID int,
	@TimeOutLimit int = 240,
	@Portal NVARCHAR(1000) = '',
	@Debug tinyint = 100
AS 
BEGIN
	SET NOCOUNT ON

	--declare  @PurgeTables table ( TableName nvarchar(1000)) 
	--insert into @PurgeTables (TableName)
	
	--values ('Users'),
	--('Company')

	declare @Error nvarchar(1000) = ''
	declare @DBServerName nvarchar(1000) = ''

	set  @DBServerName = @@SERVERNAME

	if (@DBServerName = '%' + @Portal + '%')
	begin

		set @Error = 'This is not ' + @Portal +' Portal. Script will not run.' 
		RAISERROR(@Error, 16, 16)
	
		RETURN
	end


	BEGIN TRAN A
	BEGIN TRY

	
		DECLARE table_cursor CURSOR FOR
		SELECT
			tables.name
		FROM
			sys.tables
			INNER JOIN sys.schemas ON tables.schema_id = schemas.schema_id
			INNER JOIN sys.columns ON tables.object_id = columns.object_id
		WHERE
			schemas.Name = 'org' and columns.name = 'CompanyID'
	
		

		DECLARE @TableName NVARCHAR(1000), @FilterColumn NVARCHAR(50)
     
  
		---- PRINT '-------- Table data deletion cursor --------';  
  
		--DECLARE table_cursor CURSOR FOR   
		--SELECT TableName
		--FROM @PurgeTables  
	  
		OPEN table_cursor  
  
		FETCH NEXT FROM table_cursor   
		INTO @TableName
  
		WHILE @@FETCH_STATUS = 0  
		BEGIN  

			select 'Table To purge => ' + @TableName

			exec [dbo].[sproc_PurgeAdminDataForCompany] @CompanyID = @CompanyID, @DbName = 'Admin', @TableName = @TableName, @FilterColumn = 'xyz'

			FETCH NEXT FROM table_cursor   
			INTO @TableName
  
     
		END

		CLOSE table_cursor
		DEALLOCATE table_cursor  


	COMMIT TRAN A

		PRINT 'Success:: PurgeData'
	
	END TRY

	BEGIN CATCH
		
		ROLLBACK TRAN A
		


		PRINT 'Error: changes rolled back'
		SET @Error  ='ERROR: ERR_NO: ' + CONVERT(VARCHAR(20),ERROR_NUMBER()) + ', ERR_MSG: '  + ERROR_MESSAGE()
			RAISERROR (@Error , -- Message text.
			   16, -- Severity,
			   1); -- State.

		CLOSE table_cursor
		DEALLOCATE table_cursor  

	END CATCH
	

	SET NOCOUNT OFF

END


GO
/****** Object:  StoredProcedure [dbo].[sproc_TenantTeardown]    Script Date: 8/20/2021 4:27:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sproc_TenantTeardown] 
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	DECLARE @Tables TABLE(ID INT IDENTITY(1,1), TableName VARCHAR(50), HasHistory bit)
	DECLARE @InactiveTenants TABLE(ID INT IDENTITY(1,1), TenantID INT, CompanyID INT)
	DECLARE @TableRowCount INT
	DECLARE @TearDownRowCount INT
	DECLARE @ID INT
	DECLARE @TableID INT
	DECLARE @TableName VARCHAR(50)
	DECLARE @HasHistory BIT
	DECLARE @Sql NVARCHAR(MAX)
	DECLARE @TenantID INT
	DECLARE @CompanyID INT
	DECLARE @VarCharTenants VARCHAR(5000) = ''
	DECLARE @VarCharCompanyID VARCHAR(10)

	Insert Into @InactiveTenants (TenantID, CompanyID)
		SELECT t.TenantID, c.CompanyID
		From org.Tenant AS t
		LEFT JOIN org.Company AS c ON t.TenantID = c.TenantID
		Where t.IsActive = 0

	SET @TearDownRowCount = @@ROWCOUNT

	If @TearDownRowCount = 0
		BEGIN
			RETURN
		END

	SELECT @VarCharTenants = STRING_AGG(TenantID, ',') FROM @InactiveTenants;

	Insert Into @Tables (TableName, HasHistory)
		Values
			('AppMetrics', 0),
			('AppSpecPlatform', 1),
			('JobFamilyAppSpecOverride', 1),
			('LicenseCounts', 0),
			('ReportCatalogExclusive', 1),
			('ReportUserFavorites', 1),
			('UserAppSpecOverride', 1),
			('UserDevice', 1),
			('UserDomain', 1),
			('UserWebAppSpecOverride', 1),
			('AppSpec', 1),
			('HolidayLocation', 1),
			('JobFamilyActivitySpec', 1),
			('JobFamilyWebAppSpecOverride', 1),
			('UserPermission', 1),
			('Users', 1),
			('WebAppSpec', 1),
			('ActivitySpec', 1),
			('ApplicationSettings', 1),
			('Department', 1),
			('Device', 1),
			('Holiday', 1),
			('JobFamilyActivityOverrideProfile', 1),
			('Location', 1),
			('Platform', 1),
			('Team', 1),
			('UserActivityOverrideProfile', 1),
			('Vendor', 1),
			('WorkSchedule', 1),
			('CompanySettings',1),
			('DashboardChangeLog',0),
			('ModuleLicenseLineItem',1),
			('UserProvisionState',0),
			('Company', 1)

	SET @TableRowCount = @@ROWCOUNT
	SET @ID = 0

	WHILE @ID < @TearDownRowCount
		BEGIN
			SET @ID = @ID + 1

			SELECT @TenantID = TenantID, @CompanyID = CompanyID
			FROM @InactiveTenants
			WHERE ID = @ID
			IF @CompanyID IS NULL CONTINUE
			SET @VarCharCompanyID = CAST(@CompanyID AS VARCHAR(10))
			BEGIN TRANSACTION
				Update org.Team Set ManagerID = NULL Where CompanyID = @CompanyID
				Update org.Department Set DepartmentOwnerID = NULL Where CompanyID = @CompanyID
				Update org.Users Set DepartmentID = NULL, UserActivityOverrideProfileID = NULL, JobFamilyActivityOverrideProfileID = NULL, VendorID = NULL, TeamID = NULL Where CompanyID = @CompanyID
			COMMIT TRANSACTION
			SET @TableID = 0
			WHILE @TableID < @TableRowCount
				BEGIN
					BEGIN TRANSACTION
						SET @TableID = @TableID + 1
						SELECT @TableName = TableName, @HasHistory = HasHistory
						FROM @Tables
						WHERE ID = @TableID
						IF @HasHistory = 1
							BEGIN
								SET @Sql = 'ALTER TABLE org.' + @TableName + ' SET(SYSTEM_VERSIONING = OFF)'
								EXEC sp_executesql @Sql
							END
						SET @Sql = 'Delete From org.' + @TableName + ' Where CompanyID = ' + @VarCharCompanyID
						EXEC sp_executesql @Sql
						IF @HasHistory = 1
							BEGIN
								SET @Sql = 'DELETE FROM history.' + @TableName + 'History WITH(TABLOCKX) Where CompanyID = ' + @VarCharCompanyID
								EXEC sp_executesql @Sql
								SET @Sql = 'ALTER TABLE org.' + @TableName + ' SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = history.' + @TableName + 'History))'
								EXEC sp_executesql @Sql
							END
					COMMIT TRANSACTION
				END
		END
		BEGIN TRANSACTION
			ALTER TABLE org.Tenant SET (SYSTEM_VERSIONING = OFF)
			SET @Sql = 'DELETE FROM org.Tenant Where TenantID IN (' + @VarCharTenants + ')'
			EXEC sp_executesql @Sql
			SET @Sql = 'DELETE FROM history.TenantHistory WITH(TABLOCKX) Where TenantID In (' + @VarCharTenants + ')' 
			EXEC sp_executesql @Sql
			ALTER TABLE org.Tenant SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = history.TenantHistory))
		COMMIT TRANSACTION
END

GO
/****** Object:  StoredProcedure [dbo].[sproc_TestFlyway]    Script Date: 8/20/2021 4:27:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      <Author, , Name>
-- Create Date: <Create Date, , >
-- Description: <Description, , >
-- =============================================
CREATE   PROCEDURE [dbo].[sproc_TestFlyway]
    

AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON
	
	select top 10 * from [dbo].TestFlyway

	set nocount off
END

GO
/****** Object:  StoredProcedure [dbo].[sproc_UnmappedWebAppDetails]    Script Date: 8/20/2021 4:27:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


 

CREATE     PROCEDURE [dbo].[sproc_UnmappedWebAppDetails]
(
        @CompanyID int

 

)
AS
BEGIN

 

            --- WebApp 
            Drop table if Exists #UnmappedDetails;
             
            Select k.*, l.UrlmatchContent UrlmatchContentStartWith,m.UrlmatchContent UrlmatchContentContains, 1 as IsActive INTO #UnmappedDetails
            FROM
            (Select a.*,  b.UrlMatchContent
            FROM [org].[AppMetrics] a with (nolock)
            Left outer join [org].[WebAppSpec] b with (nolock) On (a.CompanyID = b.CompanyID and a.WebAppSpecID = b.WebAppSpecID)
            Where a.AppSpecID = 0 and UrlMatchStrategy = 0 ) k
            Left Outer join
            (Select CompanyID, UrlmatchContent From [org].[WebAppSpec] with (nolock) WHERE IsActive=1 AND UrlMatchStrategy=2) l
            ON (k.CompanyID = l.CompanyID AND charindex (l.UrlMatchContent,k.UrlMatchContent)=1)
            Left Outer join
            (Select CompanyID, UrlmatchContent From [org].[WebAppSpec] with (nolock) WHERE IsActive=1 AND UrlMatchStrategy=3) m
            ON (k.CompanyID = m.CompanyID AND charindex (m.UrlMatchContent,k.UrlMatchContent) > 0) 
            and k.CompanyID = @CompanyID

 

            Update #UnmappedDetails
            SET IsActive = 0
            Where UrlmatchContentStartWith Is not null OR UrlmatchContentContains is not null
            
            ---App 
            Drop table if Exists #UnmappedAppDetails;

 

            Select a.CompanyID, a.AppSpecID, a.WebAppSpecID, a.NumberOfUsers_Short, a.NumberOfUsers_Medium, a.NumberOfUsers_Long,
            a.DailyAverage_Short, a.DailyAverage_Medium, a.DailyAverage_Long, b.AppExeName, b.IsActive INTO #UnmappedAppDetails from  
            [org].[AppMetrics] a with (nolock)
            Left outer join [org].[AppSpec] b with (nolock) On(a.CompanyID = b.CompanyID and a.AppSpecID = b.AppSpecID)
            Where WebAppSpecID = 0 and ActivitySpecID is null

 


            ---App and WebApp Selection
            Select CompanyID, AppSpecID, WebAppSpecID, NumberOfUsers_Short, NumberOfUsers_Medium, NumberOfUsers_Long,
            DailyAverage_Short, DailyAverage_Medium, DailyAverage_Long, UrlMatchContent, Isactive
            from #UnmappedDetails Where Isactive = 1 and CompanyID = @CompanyID
            UNION ALL
            Select CompanyID, AppSpecID, WebAppSpecID, NumberOfUsers_Short, NumberOfUsers_Medium, NumberOfUsers_Long,
            DailyAverage_Short, DailyAverage_Medium, DailyAverage_Long, AppExeName, IsActive
            from #UnmappedAppDetails WHere IsActive = 1 and CompanyID = @CompanyID
 
             
            
END

 


GO
/****** Object:  StoredProcedure [dbo].[sproc_VueUsageInfo]    Script Date: 8/20/2021 4:27:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE     PROCEDURE [dbo].[sproc_VueUsageInfo]
(
     @companyID int
	,@startDate Datetime,
	 @endDate Datetime
)
AS
BEGIN

DECLARE @CurrentDate AS DATETIME,@dailyUsage INT
SET @CurrentDate = @StartDate
CREATE TABLE #temp
(
   UsageDate DateTime,
   UsageCount int
)

WHILE (@CurrentDate < @EndDate)
BEGIN
Insert into #temp (UsageDate,UsageCount) select @CurrentDate, count(*) from org.Users  FOR SYSTEM_TIME AS OF  @CurrentDate WHERE IsActive=1 and CompanyId=@companyID

 SET @CurrentDate = convert(varchar(30), dateadd(day,1, @CurrentDate), 101);
END

 SELECT 	DATEPART(MONTH, UsageDate) as [Month], SUM(UsageCount)/DAY(EOMONTH(UsageDate))  as [Value]
    FROM #temp 
    GROUP BY DATEPART(YEAR, UsageDate),DATEPART(MONTH, UsageDate),DAY(EOMONTH(UsageDate))
	
END
GO
/****** Object:  StoredProcedure [MD].[sproc_DeleteUser]    Script Date: 8/20/2021 4:27:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [MD].[sproc_DeleteUser]
(
     @CompanyID int
	,@Useremail varchar(50)
)
AS
BEGIN

    SET NOCOUNT ON

	declare @UserId int, @TeamID int

	---Select Userid of employee
	SELECT @UserId = UserID from Org.Users Where CompanyID = @CompanyID and Useremail = @Useremail	
	

	-----Deletion of UserDomain
		Delete from [org].[UserDomain]  Where companyID = @CompanyID and UserID = @UserId
	-----Select TeamID
		Select @TeamID = TeamID From [org].[Team] WHere CompanyID = @CompanyID and ManagerID = @UserId

	-----Update the Reports To User ID
		Select UserID UserID, UserEMail as UpdateTeamOfBelowUser  from [org].[Users] WHere CompanyID = @CompanyID and TeamID = @TeamID
	
	-----Update null Team ID
		Update [org].[Users]
		Set TeamID = Null WHere CompanyID = @CompanyID and TeamID = @TeamID

	-----Deletion of TeamDetails
		Delete from [org].[Team] WHere CompanyID = @CompanyID and ManagerID = @UserId

	-----Update null for Department and Job Family
		Update [org].[Department] Set DepartmentOwnerID = null Where CompanyID = @CompanyID and DepartmentOwnerID = @UserId
		Update [org].[Users] Set DepartmentID = null, JobFamilyActivityOverrideProfileID = null Where CompanyID = @CompanyID and UserID = @UserId
	
	-----Deletion of user	
		Delete from [org].[Users] Where companyID = @CompanyID and UserID = @UserId

	SET NOCOUNT OFF
END
GO
/****** Object:  StoredProcedure [org].[sproc_ChangeLog_DeptsTeams]    Script Date: 8/20/2021 4:27:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE     PROCEDURE [org].[sproc_ChangeLog_DeptsTeams]

As 
SET NOCOUNT ON

BEGIN
	DECLARE @companyID INT, @DeptID INT, @TeamID INT, @counter INT, @Teamcounter INT=1, @Deptcounter INT=1, @EntityID INT, @EntityName varchar(100), @DeptEntitySettingID INT, @TeamEntitySettingID INT, @DeptName nvarchar(200), @TeamName nvarchar(200), @PropertySettingID INT, @PreviousValue nvarchar(500), @CurrentValue nvarchar(500), @ModifiedOn datetime, @ModifiedBy nvarchar(500), @LastProcessedTime datetime
	DECLARE @DeptName1 nvarchar(200), @EmpActivityVisible1 BIT, @DeptOwner1 INT, @TeamName1 nvarchar(200), @TeamDesc1 nvarchar(500), @TeamMgr1 INT
	DECLARE @DeptName2 nvarchar(200), @EmpActivityVisible2 BIT, @DeptOwner2 INT, @TeamName2 nvarchar(200), @TeamDesc2 nvarchar(500), @TeamMgr2 INT

	SELECT @LastProcessedTime=CAST(DefaultValue AS datetime) FROM org.Settings WHERE SettingName='DashboardChageLog_LastProcessedTime'

	SELECT @DeptEntitySettingID=SettingID FROM org.Settings WHERE SettingName='Department'
	SELECT @TeamEntitySettingID=SettingID FROM org.Settings WHERE SettingName='Team'

	-- ################################################### DEPARTMENT #########################################################

	--**** NEW DEPT ****
	INSERT INTO org.DashboardChangeLog (CompanyID, EntityId, EntityDisplayName, EntityChangeAction, ModifiedBy, ModifiedOn, EntitySettingID)
	select distinct d.CompanyID, d.DepartmentID, d.DepartmentName, 1, ModifiedBy, d.SysStartTimeUTC, @DeptEntitySettingID
	from org.Department d
	LEFT JOIN (select distinct CompanyID, DepartmentID from history.DepartmentHistory where SysEndTimeUTC > @LastProcessedTime) ud ON d.CompanyID=ud.CompanyID AND d.DepartmentID=ud.DepartmentID
	WHERE d.SysStartTimeUTC > @LastProcessedTime AND ud.DepartmentID IS NULL

	--**** DELETED DEPT ****
	INSERT INTO org.DashboardChangeLog (CompanyID, EntityId, EntityDisplayName, EntityChangeAction, ModifiedBy, ModifiedOn, EntitySettingID)
	select distinct ud.CompanyID, ud.DepartmentID, ud.DepartmentName, 3, ud.ModifiedBy, ModifiedOn, @DeptEntitySettingID
	from (select CompanyID, DepartmentID, DepartmentName, MAX(ModifiedBy) ModifiedBy, MAX(SysEndTimeUTC) ModifiedOn from history.DepartmentHistory where SysEndTimeUTC > @LastProcessedTime group by CompanyID, DepartmentID, DepartmentName) ud
	LEFT JOIN org.Department d ON d.CompanyID=ud.CompanyID AND d.DepartmentID=ud.DepartmentID
	WHERE d.DepartmentID IS NULL


	--**** UPDATED DEPT ****
	SELECT ROW_NUMBER() OVER(ORDER BY DepartmentID) ID, * INTO #dept FROM
	(SELECT DISTINCT dh.CompanyID, dh.DepartmentID, dh.DepartmentName FROM history.DepartmentHistory dh
	JOIN org.Department d ON dh.CompanyID = d.CompanyID AND dh.DepartmentID = d.DepartmentID
	WHERE dh.SysEndTimeUTC > @LastProcessedTime) a

	WHILE (@Deptcounter) <= (SELECT MAX(ID) FROM #dept)
	BEGIN
		SELECT @companyID=CompanyID, @DeptID=DepartmentID, @DeptName=DepartmentName FROM #dept WHERE ID=@Deptcounter

			select ROW_NUMBER() OVER(ORDER BY DepartmentID) ID, * INTO #DeptUnion
			from
			(
			select dh.CompanyID, dh.DepartmentID, dh.DepartmentName, dh.IsEmployeeActivityVisible, dh.DepartmentOwnerID, dh.ModifiedBy, dh.SysStartTimeUTC
			from history.DepartmentHistory dh
			where dh.CompanyID=@companyID AND dh.DepartmentID=@DeptID AND dh.SysEndTimeUTC > @LastProcessedTime
			UNION
			select d.CompanyID, d.DepartmentID, d.DepartmentName, d.IsEmployeeActivityVisible, d.DepartmentOwnerID, ModifiedBy, SysStartTimeUTC
			from org.Department d
			JOIN (select distinct CompanyID, DepartmentID from history.DepartmentHistory where SysEndTimeUTC > @LastProcessedTime) dh ON d.CompanyID = dh.CompanyID AND d.DepartmentID=dh.DepartmentID
			WHERE d.CompanyID=@companyID AND d.DepartmentID=@DeptID
			) results

			set @counter=1

			WHILE (@counter) <= (select max(ID) from #DeptUnion)
			BEGIN
				select @DeptName1=DepartmentName, @EmpActivityVisible1=IsEmployeeActivityVisible, @DeptOwner1=DepartmentOwnerID
				from #DeptUnion where ID=@counter

				select @ModifiedBy=ModifiedBy, @ModifiedOn=SysStartTimeUTC, @DeptName2=DepartmentName, @EmpActivityVisible2=IsEmployeeActivityVisible, @DeptOwner2=DepartmentOwnerID
				from #DeptUnion where ID=@counter+1

				--If changeLog does not have create event, if original create record is since last processed time, create the original creation record
				IF NOT EXISTS (SELECT 1 FROM org.DashboardChangeLog WHERE EntitySettingID=@DeptEntitySettingID and EntityChangeAction=1 and CompanyID=@companyID and EntityId=@DeptID)
				 BEGIN
					IF EXISTS (SELECT 1 FROM (SELECT TOP 1 * FROM org.Department FOR SYSTEM_TIME ALL WHERE CompanyID=@companyID and DepartmentID=@DeptID ORDER BY sysEndTimeUTC) base WHERE SysEndTimeUTC > @LastProcessedTime)
							
					INSERT INTO org.DashboardChangeLog (CompanyID, EntityId, EntityDisplayName, EntityChangeAction, ModifiedBy, ModifiedOn, EntitySettingID)
					SELECT TOP 1 CompanyID, DepartmentID, DepartmentName, 1, ModifiedBy, SysStartTimeUTC, @DeptEntitySettingID 
					FROM org.Department FOR SYSTEM_TIME ALL WHERE CompanyID=@companyID and DepartmentID=@DeptID ORDER BY sysEndTimeUTC
				 END

				-- Dept Name
				IF (@DeptName1 <> @DeptName2)
				 BEGIN
					SELECT @PropertySettingID=SettingID FROM org.Settings WHERE SettingName='DepartmentName'

					INSERT INTO org.DashboardChangeLog (CompanyID, EntityId, EntityDisplayName, PreviousValue, CurrentValue, EntityChangeAction, ModifiedOn, ModifiedBy, PropertySettingID, EntitySettingID)
					VALUES (@companyID, @DeptID, @DeptName, @DeptName1, @DeptName2, 2, @ModifiedOn, @ModifiedBy, @PropertySettingID, @DeptEntitySettingID)
				 END

				-- Is Employee Activity Visible
				IF (COALESCE(CAST(@EmpActivityVisible1 as INT),3) <> COALESCE(CAST(@EmpActivityVisible2 as INT),3))
				 BEGIN
					SELECT @PropertySettingID=SettingID FROM org.Settings WHERE SettingName='IsEmployeeActivityVisible'

					INSERT INTO org.DashboardChangeLog (CompanyID, EntityId, EntityDisplayName, PreviousValue, CurrentValue, EntityChangeAction, ModifiedOn, ModifiedBy, PropertySettingID, EntitySettingID)
					VALUES (@companyID, @DeptID, @DeptName, @EmpActivityVisible1, @EmpActivityVisible2, 2, @ModifiedOn, @ModifiedBy, @PropertySettingID, @DeptEntitySettingID)
				 END

				-- Department Owner
				IF (COALESCE(@DeptOwner1,0) <> COALESCE(@DeptOwner2,0))
				 BEGIN
					SELECT @PropertySettingID=SettingID FROM org.Settings WHERE SettingName='DepartmentOwner'
					SELECT @PreviousValue=FirstName + ' ' + LastName FROM org.Users WHERE CompanyID=@companyID AND UserID=@DeptOwner1
					SELECT @CurrentValue=FirstName + ' ' + LastName FROM org.Users WHERE CompanyID=@companyID AND UserID=@DeptOwner2

					INSERT INTO org.DashboardChangeLog (CompanyID, EntityId, EntityDisplayName, PreviousValue, CurrentValue, RefPropertyPreviousId, RefPropertyCurrentId, EntityChangeAction, ModifiedOn, ModifiedBy, PropertySettingID, EntitySettingID)
					VALUES (@companyID, @DeptID, @DeptName, @PreviousValue, @CurrentValue, @DeptOwner1, @DeptOwner2, 2, @ModifiedOn, @ModifiedBy, @PropertySettingID, @DeptEntitySettingID)
				 END

				--increment counter			 
				SET @counter=@counter+1
			END

			drop table #DeptUnion

		SET @Deptcounter=@Deptcounter+1
	END

	DROP TABLE #dept


	-- ################################################### Teams #########################################################

	--**** NEW Team ****
	INSERT INTO org.DashboardChangeLog (CompanyID, EntityId, EntityDisplayName, EntityChangeAction, ModifiedBy, ModifiedOn, EntitySettingID)
	select distinct t.CompanyID, t.TeamID, t.TeamName, 1, ModifiedBy, t.SysStartTimeUTC, @TeamEntitySettingID
	from org.Team t
	LEFT JOIN (select distinct CompanyID, TeamID from history.TeamHistory where SysEndTimeUTC > @LastProcessedTime) ut ON t.CompanyID=ut.CompanyID AND t.TeamID=ut.TeamID
	WHERE t.SysStartTimeUTC > @LastProcessedTime AND ut.TeamID IS NULL

	--**** DELETED Team ****
	INSERT INTO org.DashboardChangeLog (CompanyID, EntityId, EntityDisplayName, EntityChangeAction, ModifiedBy, ModifiedOn, EntitySettingID)
	select distinct ut.CompanyID, ut.TeamID, ut.TeamName, 3, ut.ModifiedBy, ModifiedOn, @TeamEntitySettingID
	from (select CompanyID, TeamID, TeamName, MAX(ModifiedBy) ModifiedBy, MAX(SysEndTimeUTC) ModifiedOn from history.TeamHistory where SysEndTimeUTC > @LastProcessedTime group by CompanyID, TeamID, TeamName) ut
	LEFT JOIN org.Team t ON t.CompanyID=ut.CompanyID AND t.TeamID = ut.TeamID
	WHERE t.TeamID IS NULL


	--**** UPDATED Teams ****
	SELECT ROW_NUMBER() OVER(ORDER BY TeamID) ID, * INTO #team FROM
	(SELECT DISTINCT th.CompanyID, th.TeamID, th.TeamName FROM history.TeamHistory th
	JOIN org.Team t ON th.CompanyID = t.CompanyID AND th.TeamID = t.TeamID
	WHERE th.SysEndTimeUTC > @LastProcessedTime) a

	WHILE (@Teamcounter) <= (SELECT MAX(ID) FROM #team)
	BEGIN
		SELECT @companyID=CompanyID, @TeamID=TeamID, @TeamName=TeamName FROM #team WHERE ID=@Teamcounter

			select ROW_NUMBER() OVER(ORDER BY TeamID) ID, * INTO #TeamUnion
			from
			(
			select th.CompanyID, th.TeamID, th.TeamName, th.TeamDescription, th.ManagerID, th.ModifiedBy, th.SysStartTimeUTC
			from history.TeamHistory th
			where th.CompanyID=@companyID AND th.TeamID=@TeamID AND th.SysEndTimeUTC > @LastProcessedTime
			UNION
			select t.CompanyID, t.TeamID, t.TeamName, t.TeamDescription, t.ManagerID, ModifiedBy, SysStartTimeUTC
			from org.Team t
			JOIN (select distinct CompanyID, TeamID from history.TeamHistory where SysEndTimeUTC > @LastProcessedTime) th ON t.CompanyID =th.CompanyID AND t.TeamID = th.TeamID
			WHERE t.CompanyID=@companyID AND t.TeamID=@TeamID
			) results

			set @counter=1

			WHILE (@counter) <= (select max(ID) from #TeamUnion)
			BEGIN
				select @TeamName1=TeamName, @TeamDesc1=TeamDescription, @TeamMgr1=ManagerID
				from #TeamUnion where ID=@counter

				select @ModifiedBy=ModifiedBy, @ModifiedOn=SysStartTimeUTC, @TeamName2=TeamName, @TeamDesc2=TeamDescription, @TeamMgr2=ManagerID
				from #TeamUnion where ID=@counter+1

				--If changeLog does not have create event, if original create record is since last processed time, create the original creation record
				IF NOT EXISTS (SELECT 1 FROM org.DashboardChangeLog WHERE EntitySettingID=@TeamEntitySettingID and EntityChangeAction=1 and CompanyID=@companyID and EntityId=@TeamID)
				 BEGIN
					IF EXISTS (SELECT 1 FROM (SELECT TOP 1 * FROM org.Team FOR SYSTEM_TIME ALL WHERE CompanyID=@companyID and TeamID=@TeamID ORDER BY sysEndTimeUTC) base WHERE SysEndTimeUTC > @LastProcessedTime)
							
					INSERT INTO org.DashboardChangeLog (CompanyID, EntityId, EntityDisplayName, EntityChangeAction, ModifiedBy, ModifiedOn, EntitySettingID)
					SELECT TOP 1 CompanyID, TeamID, TeamName, 1, ModifiedBy, SysStartTimeUTC, @TeamEntitySettingID 
					FROM org.Team FOR SYSTEM_TIME ALL WHERE CompanyID=@companyID and TeamID=@TeamID ORDER BY sysEndTimeUTC
				 END

				-- Team Name
				IF (COALESCE(@TeamName1,'') <> COALESCE(@TeamName2,''))
				 BEGIN
					SELECT @PropertySettingID=SettingID FROM org.Settings WHERE SettingName='TeamName'

					INSERT INTO org.DashboardChangeLog (CompanyID, EntityId, EntityDisplayName, PreviousValue, CurrentValue, EntityChangeAction, ModifiedOn, ModifiedBy, PropertySettingID, EntitySettingID)
					VALUES (@companyID, @TeamID, @TeamName, @TeamName1, @TeamName2, 2, @ModifiedOn, @ModifiedBy, @PropertySettingID, @TeamEntitySettingID)
				 END

				-- Team Desc
				IF (COALESCE(@TeamDesc1,'') <> COALESCE(@TeamDesc2,''))
				 BEGIN
					SELECT @PropertySettingID=SettingID FROM org.Settings WHERE SettingName='TeamDescription'

					INSERT INTO org.DashboardChangeLog (CompanyID, EntityId, EntityDisplayName, PreviousValue, CurrentValue, EntityChangeAction, ModifiedOn, ModifiedBy, PropertySettingID, EntitySettingID)
					VALUES (@companyID, @TeamID, @TeamName, @TeamDesc1, @TeamDesc2, 2, @ModifiedOn, @ModifiedBy, @PropertySettingID, @TeamEntitySettingID)
				 END

				-- Manager
				IF (COALESCE(@TeamMgr1,0) <> COALESCE(@TeamMgr2,0))
				 BEGIN
					SELECT @PropertySettingID=SettingID FROM org.Settings WHERE SettingName='TeamManager'
					SELECT @PreviousValue=FirstName + ' ' + LastName FROM org.Users WHERE CompanyID=@companyID AND UserID=@TeamMgr1
					SELECT @CurrentValue=FirstName + ' ' + LastName FROM org.Users WHERE CompanyID=@companyID AND UserID=@TeamMgr2

					INSERT INTO org.DashboardChangeLog (CompanyID, EntityId, EntityDisplayName, PreviousValue, CurrentValue, RefPropertyPreviousId, RefPropertyCurrentId, EntityChangeAction, ModifiedOn, ModifiedBy, PropertySettingID, EntitySettingID)
					VALUES (@companyID, @TeamID, @TeamName, @PreviousValue, @CurrentValue, @TeamMgr1, @TeamMgr2, 2, @ModifiedOn, @ModifiedBy, @PropertySettingID, @TeamEntitySettingID)
				 END

				--increment counter			 
				SET @counter=@counter+1
			END

			drop table #TeamUnion

		SET @Teamcounter=@Teamcounter+1
	END

	DROP TABLE #team
END


GO
/****** Object:  StoredProcedure [org].[sproc_ChangeLog_Mappings]    Script Date: 8/20/2021 4:27:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE     PROCEDURE [org].[sproc_ChangeLog_Mappings]

As 
SET NOCOUNT ON

BEGIN
	DECLARE @companyID INT, @AppSpecID INT, @WebAppSpecID INT, @AppExeName nvarchar(200), @WebAppUrl nvarchar(300), @counter INT, @AppSpecCounter INT=1, @WebAppSpecCounter INT=1, @EntityID INT, @EntityName varchar(100), @EntitySettingID INT, @PropertySettingID INT, @PreviousValue nvarchar(500), @CurrentValue nvarchar(500), @ModifiedOn datetime, @ModifiedBy nvarchar(500), @LastProcessedTime datetime
	DECLARE @AppDisplayName1 nvarchar(200), @AppActivitySpecID1 int, @AppMergePriority1 bit, @WebAppDisplayName1 nvarchar(200), @URLMatchStrategy1 int, @URLMatchContent1 nvarchar(200), @IsSystemDiscovered1 bit, @WebAppActivitySpecID1 int
	DECLARE @AppDisplayName2 nvarchar(200), @AppActivitySpecID2 int, @AppMergePriority2 bit, @WebAppDisplayName2 nvarchar(200), @URLMatchStrategy2 int, @URLMatchContent2 nvarchar(200), @IsSystemDiscovered2 bit, @WebAppActivitySpecID2 int

	SELECT @LastProcessedTime=CAST(DefaultValue AS datetime) FROM org.Settings WHERE SettingName='DashboardChageLog_LastProcessedTime'

	SELECT @EntitySettingID=SettingID FROM org.Settings WHERE SettingName='Mapping'


	--**** NEW WEB APPS ****
	INSERT INTO org.DashboardChangeLog (CompanyID, EntityId, EntityDisplayName, EntityChangeAction, ModifiedBy, ModifiedOn, EntitySettingID)
	SELECT DISTINCT app.CompanyID, app.WebAppSpecID, app.WebAppUrl, 1, ModifiedBy, app.SysStartTimeUTC, @EntitySettingID
	FROM org.WebAppSpec app
	LEFT JOIN (select distinct CompanyID, WebAppSpecID from history.WebAppSpecHistory where SysEndTimeUTC > @LastProcessedTime) hist ON app.CompanyID=hist.CompanyID AND app.WebAppSpecID=hist.WebAppSpecID
	WHERE app.SysStartTimeUTC > @LastProcessedTime AND hist.WebAppSpecID IS NULL


	--**** DELETED WEB APPS ****
	INSERT INTO org.DashboardChangeLog (CompanyID, EntityId, EntityDisplayName, EntityChangeAction, ModifiedBy, ModifiedOn, EntitySettingID)
	SELECT DISTINCT hist.CompanyID, hist.WebAppSpecID, hist.WebAppUrl, 3, hist.ModifiedBy, ModifiedOn, @EntitySettingID
	FROM (select CompanyID, WebAppSpecID, WebAppUrl, MAX(ModifiedBy) ModifiedBy, MAX(SysEndTimeUTC) ModifiedOn from history.WebAppSpecHistory where SysEndTimeUTC > @LastProcessedTime group by CompanyID, WebAppSpecID, WebAppUrl) hist
	LEFT JOIN org.WebAppSpec app ON app.CompanyID=hist.CompanyID AND app.WebAppSpecID=hist.WebAppSpecID
	WHERE app.WebAppSpecID IS NULL


	--**** UPDATED WEB APPS ****
	SELECT ROW_NUMBER() OVER(ORDER BY WebAppSpecID) ID, * INTO #webapp FROM
	(SELECT DISTINCT hist.CompanyID, hist.WebAppSpecID, hist.WebAppUrl FROM history.WebAppSpecHistory hist
	JOIN org.WebAppSpec asp ON hist.CompanyID = asp.CompanyID AND asp.WebAppSpecID = hist.WebAppSpecID
	WHERE hist.SysEndTimeUTC > @LastProcessedTime) a

	WHILE (@WebAppSpecCounter) <= (SELECT MAX(ID) FROM #webapp)
	BEGIN
		SELECT @companyID=CompanyID, @WebAppSpecID=WebAppSpecID, @WebAppUrl=WebAppUrl FROM #webapp WHERE ID=@WebAppSpecCounter

			select ROW_NUMBER() OVER(ORDER BY WebAppSpecID) ID, * INTO #WebAppSpecUnion
			from
			(
			select hist.CompanyID, hist.WebAppSpecID, hist.WebAppDisplayName, hist.UrlMatchStrategy, hist.UrlMatchContent, hist.IsSystemDiscovered, hist.ActivitySpecID, hist.ModifiedBy, hist.SysStartTimeUTC
			from history.WebAppSpecHistory hist
			where hist.CompanyID=@companyID AND hist.WebAppSpecID=@WebAppSpecID AND hist.SysEndTimeUTC > @LastProcessedTime
			UNION
			select asp.CompanyID, asp.WebAppSpecID, asp.WebAppDisplayName, asp.UrlMatchStrategy, asp.UrlMatchContent, asp.IsSystemDiscovered, asp.ActivitySpecID, ModifiedBy, SysStartTimeUTC
			from org.WebAppSpec asp
			JOIN (select distinct CompanyID, WebAppSpecID from history.WebAppSpecHistory where SysEndTimeUTC > @LastProcessedTime) hist ON asp.CompanyID = hist.CompanyID AND asp.WebAppSpecID = hist.webAppSpecID
			WHERE asp.CompanyID=@companyID AND asp.WebAppSpecID=@WebAppSpecID
			) results

			SET @counter=1

			WHILE (@counter) <= (select max(ID)-1 from #WebAppSpecUnion)
			BEGIN
				select @WebAppDisplayName1=WebAppDisplayName, @URLMatchStrategy1=UrlMatchStrategy, @URLMatchContent1=UrlMatchContent, @IsSystemDiscovered1=IsSystemDiscovered, @WebAppActivitySpecID1=ActivitySpecID
				from #WebAppSpecUnion where ID=@counter

				select @ModifiedBy=ModifiedBy, @ModifiedOn=SysStartTimeUTC, @WebAppDisplayName2=WebAppDisplayName, @URLMatchStrategy2=UrlMatchStrategy, @URLMatchContent2=UrlMatchContent, @IsSystemDiscovered2=IsSystemDiscovered, @WebAppActivitySpecID2=ActivitySpecID
				from #WebAppSpecUnion where ID=@counter+1

				--If changeLog does not have create event, if original create record is since last processed time, create the original creation record
				IF NOT EXISTS (SELECT 1 FROM org.DashboardChangeLog WHERE EntitySettingID=@EntitySettingID and EntityChangeAction=1 and CompanyID=@companyID and EntityId=@WebAppSpecID)
				 BEGIN
					IF EXISTS (SELECT 1 FROM (SELECT TOP 1 * FROM org.WebAppSpec FOR SYSTEM_TIME ALL WHERE CompanyID=@companyID and WebAppSpecID=@WebAppSpecID ORDER BY sysEndTimeUTC) base WHERE SysEndTimeUTC > @LastProcessedTime)
							
					INSERT INTO org.DashboardChangeLog (CompanyID, EntityId, EntityDisplayName, EntityChangeAction, ModifiedBy, ModifiedOn, EntitySettingID)
					SELECT TOP 1 CompanyID, WebAppSpecID, WebAppName, 1, ModifiedBy, SysStartTimeUTC, @EntitySettingID 
					FROM org.WebAppSpec FOR SYSTEM_TIME ALL WHERE CompanyID=@companyID and WebAppSpecID=@WebAppSpecID ORDER BY sysEndTimeUTC
				 END

				IF (@WebAppDisplayName1 <> @WebAppDisplayName2)
				 BEGIN
					SELECT @PropertySettingID=SettingID FROM org.Settings WHERE SettingName='WebAppDisplayName'

					INSERT INTO org.DashboardChangeLog (CompanyID, EntityId, EntityDisplayName, PreviousValue, CurrentValue, EntityChangeAction, ModifiedOn, ModifiedBy, PropertySettingID, EntitySettingID)
					VALUES (@companyID, @WebAppSpecID, @WebAppUrl, @WebAppDisplayName1, @WebAppDisplayName2 , 2, @ModifiedOn, @ModifiedBy, @PropertySettingID, @EntitySettingID)
				 END

				IF (COALESCE(@URLMatchStrategy1,0) <> COALESCE(@URLMatchStrategy2,0))
				 BEGIN
					SELECT @PropertySettingID=SettingID FROM org.Settings WHERE SettingName='UrlMatchStrategy'

					INSERT INTO org.DashboardChangeLog (CompanyID, EntityId, EntityDisplayName, PreviousValue, CurrentValue, EntityChangeAction, ModifiedOn, ModifiedBy, PropertySettingID, EntitySettingID)
					VALUES (@companyID, @WebAppSpecID, @WebAppUrl, @URLMatchStrategy1, @URLMatchStrategy2 , 2, @ModifiedOn, @ModifiedBy, @PropertySettingID, @EntitySettingID)
				 END

				IF (COALESCE(@URLMatchContent1,'') <> COALESCE(@URLMatchContent2,''))
				 BEGIN
					SELECT @PropertySettingID=SettingID FROM org.Settings WHERE SettingName='UrlMatchContent'

					INSERT INTO org.DashboardChangeLog (CompanyID, EntityId, EntityDisplayName, PreviousValue, CurrentValue, EntityChangeAction, ModifiedOn, ModifiedBy, PropertySettingID, EntitySettingID)
					VALUES (@companyID, @WebAppSpecID, @WebAppUrl, @URLMatchContent1, @URLMatchContent2 , 2, @ModifiedOn, @ModifiedBy, @PropertySettingID, @EntitySettingID)
				 END

				IF (COALESCE(@IsSystemDiscovered1,3) <> COALESCE(@IsSystemDiscovered2,3))
				 BEGIN
					SELECT @PropertySettingID=SettingID FROM org.Settings WHERE SettingName='IsSystemDiscovered'

					INSERT INTO org.DashboardChangeLog (CompanyID, EntityId, EntityDisplayName, PreviousValue, CurrentValue, EntityChangeAction, ModifiedOn, ModifiedBy, PropertySettingID, EntitySettingID)
					VALUES (@companyID, @WebAppSpecID, @WebAppUrl, @IsSystemDiscovered1, @IsSystemDiscovered2 , 2, @ModifiedOn, @ModifiedBy, @PropertySettingID, @EntitySettingID)
				 END

				IF (COALESCE(@WebAppActivitySpecID1,0) <> COALESCE(@WebAppActivitySpecID2,0))
				 BEGIN
					SELECT @PropertySettingID=SettingID FROM org.Settings WHERE SettingName='WebAppActivity'
					SELECT @PreviousValue=ActivitySpecName FROM org.ActivitySpec WHERE CompanyID=@companyID AND ActivitySpecID=@WebAppActivitySpecID1
					SELECT @CurrentValue=ActivitySpecName FROM org.ActivitySpec WHERE CompanyID=@companyID AND ActivitySpecID=@WebAppActivitySpecID2

					INSERT INTO org.DashboardChangeLog (CompanyID, EntityId, EntityDisplayName, PreviousValue, CurrentValue, EntityChangeAction, ModifiedOn, ModifiedBy, PropertySettingID, EntitySettingID)
					VALUES (@companyID, @WebAppSpecID, @WebAppUrl, @PreviousValue, @CurrentValue , 2, @ModifiedOn, @ModifiedBy, @PropertySettingID, @EntitySettingID)
				 END

				--increment counter			 
				SET @counter=@counter+1
			END

			drop table #WebAppSpecUnion

		SET @WebAppSpecCounter=@WebAppSpecCounter+1
	END

	DROP TABLE #webapp


	--**** NEW APPS ****
	INSERT INTO org.DashboardChangeLog (CompanyID, EntityId, EntityDisplayName, EntityChangeAction, ModifiedBy, ModifiedOn, EntitySettingID)
	SELECT DISTINCT app.CompanyID, app.AppSpecID, app.AppExeName, 1, ModifiedBy, app.SysStartTimeUTC, @EntitySettingID
	FROM org.AppSpec app
	LEFT JOIN (select distinct CompanyID, AppSpecID from history.AppSpecHistory where SysEndTimeUTC > @LastProcessedTime) hist ON app.CompanyID=hist.CompanyID AND app.AppSpecID=hist.AppSpecID
	WHERE app.SysStartTimeUTC > @LastProcessedTime AND hist.AppSpecID IS NULL

	--**** DELETED APPS ****
	INSERT INTO org.DashboardChangeLog (CompanyID, EntityId, EntityDisplayName, EntityChangeAction, ModifiedBy, ModifiedOn, EntitySettingID)
	SELECT DISTINCT hist.CompanyID, hist.AppSpecID, hist.AppExeName, 3, hist.ModifiedBy, ModifiedOn, @EntitySettingID
	FROM (select CompanyID, AppSpecID, AppExeName, MAX(ModifiedBy) ModifiedBy, MAX(SysEndTimeUTC) ModifiedOn from history.AppSpecHistory where SysEndTimeUTC > @LastProcessedTime group by CompanyID, AppSpecID, AppExeName) hist
	LEFT JOIN org.AppSpec app ON app.CompanyID=hist.CompanyID AND app.AppSpecID=hist.AppSpecID
	WHERE app.AppSpecID IS NULL


	--**** UPDATED APPS ****
	SELECT ROW_NUMBER() OVER(ORDER BY AppSpecID) ID, * INTO #app FROM
	(SELECT DISTINCT hist.CompanyID, hist.AppSpecID, hist.AppExeName FROM history.AppSpecHistory hist
	JOIN org.AppSpec asp ON hist.CompanyID = asp.CompanyID AND asp.AppSpecID = hist.AppSpecID
	WHERE hist.SysEndTimeUTC > @LastProcessedTime) a

	WHILE (@AppSpecCounter) <= (SELECT MAX(ID) FROM #app)
	BEGIN
		SELECT @companyID=CompanyID, @AppSpecID=AppSpecID, @AppExeName=AppExeName FROM #app WHERE ID=@AppSpecCounter

			select ROW_NUMBER() OVER(ORDER BY AppSpecID) ID, * INTO #AppSpecUnion
			from
			(
			select hist.CompanyID, hist.AppSpecID, hist.AppDisplayName, hist.ActivitySpecID, hist.MergePriority, hist.ModifiedBy, hist.SysStartTimeUTC
			from history.AppSpecHistory hist
			where hist.CompanyID=@companyID AND hist.AppSpecID=@AppSpecID AND hist.SysEndTimeUTC > @LastProcessedTime
			UNION
			select asp.CompanyID, asp.AppSpecID, asp.AppDisplayName, asp.ActivitySpecID, asp.MergePriority, ModifiedBy, SysStartTimeUTC
			from org.AppSpec asp
			JOIN (select distinct CompanyID, AppSpecID from history.AppSpecHistory where SysEndTimeUTC > @LastProcessedTime) hist ON asp.CompanyID = hist.CompanyID AND asp.AppSpecID = hist.AppSpecID
			WHERE asp.CompanyID=@companyID AND asp.AppSpecID=@AppSpecID
			) results

			SET @counter=1

			WHILE (@counter) <= (select max(ID)-1 from #AppSpecUnion)
			BEGIN
				select @AppDisplayName1=AppDisplayName, @AppActivitySpecID1=ActivitySpecID, @AppMergePriority1=MergePriority
				from #AppSpecUnion where ID=@counter

				select @ModifiedBy=ModifiedBy, @ModifiedOn=SysStartTimeUTC, @AppDisplayName2=AppDisplayName, @AppActivitySpecID2=ActivitySpecID, @AppMergePriority2=MergePriority
				from #AppSpecUnion where ID=@counter+1

				--If changeLog does not have create event, if original create record is since last processed time, create the original creation record
				IF NOT EXISTS (SELECT 1 FROM org.DashboardChangeLog WHERE EntitySettingID=@EntitySettingID and EntityChangeAction=1 and CompanyID=@companyID and EntityId=@AppSpecID)
				 BEGIN
					IF EXISTS (SELECT 1 FROM (SELECT TOP 1 * FROM org.AppSpec FOR SYSTEM_TIME ALL WHERE CompanyID=@companyID and AppSpecID=@AppSpecID ORDER BY sysEndTimeUTC) base WHERE SysEndTimeUTC > @LastProcessedTime)
							
					INSERT INTO org.DashboardChangeLog (CompanyID, EntityId, EntityDisplayName, EntityChangeAction, ModifiedBy, ModifiedOn, EntitySettingID)
					SELECT TOP 1 CompanyID, AppSpecID, AppExeName, 1, ModifiedBy, SysStartTimeUTC, @EntitySettingID 
					FROM org.AppSpec FOR SYSTEM_TIME ALL WHERE CompanyID=@companyID and AppSpecID=@AppSpecID ORDER BY sysEndTimeUTC
				 END

				IF (COALESCE(@AppDisplayName1,'') <> COALESCE(@AppDisplayName2,''))
				 BEGIN
					SELECT @PropertySettingID=SettingID FROM org.Settings WHERE SettingName='AppDisplayName'

					INSERT INTO org.DashboardChangeLog (CompanyID, EntityId, EntityDisplayName, PreviousValue, CurrentValue, EntityChangeAction, ModifiedOn, ModifiedBy, PropertySettingID, EntitySettingID)
					VALUES (@companyID, @AppSpecID, @AppExeName, @AppDisplayName1, @AppDisplayName2, 2, @ModifiedOn, @ModifiedBy, @PropertySettingID, @EntitySettingID)
				 END

				IF (COALESCE(@AppActivitySpecID1,0) <> COALESCE(@AppActivitySpecID2,0))
				 BEGIN
					SELECT @PropertySettingID=SettingID FROM org.Settings WHERE SettingName='Activity'
					SELECT @PreviousValue=ActivitySpecName FROM org.ActivitySpec WHERE CompanyID=@companyID AND ActivitySpecID=@AppActivitySpecID1
					SELECT @CurrentValue=ActivitySpecName FROM org.ActivitySpec WHERE CompanyID=@companyID AND ActivitySpecID=@AppActivitySpecID2

					INSERT INTO org.DashboardChangeLog (CompanyID, EntityId, EntityDisplayName, PreviousValue, CurrentValue, EntityChangeAction, ModifiedOn, ModifiedBy, PropertySettingID, EntitySettingID)
					VALUES (@companyID, @AppSpecID, @AppExeName, @PreviousValue, @CurrentValue, 2, @ModifiedOn, @ModifiedBy, @PropertySettingID, @EntitySettingID)
				 END

				 IF (@AppMergePriority1 <> @AppMergePriority2)
				  BEGIN
					SELECT @PropertySettingID=SettingID FROM org.Settings WHERE SettingName='MergePriority'

					INSERT INTO org.DashboardChangeLog (CompanyID, EntityId, EntityDisplayName, PreviousValue, CurrentValue, EntityChangeAction, ModifiedOn, ModifiedBy, PropertySettingID, EntitySettingID)
					VALUES (@companyID, @AppSpecID, @AppExeName, @AppMergePriority1, @AppMergePriority2, 2, @ModifiedOn, @ModifiedBy, @PropertySettingID, @EntitySettingID)
				  END
				--increment counter			 
				SET @counter=@counter+1
			END

			drop table #AppSpecUnion

		SET @AppSpecCounter=@AppSpecCounter+1
	END

	DROP TABLE #app
END


GO
/****** Object:  StoredProcedure [org].[sproc_ChangeLog_Users]    Script Date: 8/20/2021 4:27:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE     PROCEDURE [org].[sproc_ChangeLog_Users]

As 
SET NOCOUNT ON

BEGIN
	DECLARE @companyID INT, @UserID INT, @counter INT, @Usercounter INT=1, @EntityID INT, @EntityName varchar(100), @EntitySettingID INT, @DeptEntitySettingID INT, @TeamEntitySettingID INT, @Fullname nvarchar(200), @PropertySettingID INT, @PreviousValue nvarchar(500), @CurrentValue nvarchar(500), @ModifiedOn datetime, @ModifiedBy nvarchar(500), @LastProcessedTime datetime
	DECLARE @Fname1 nvarchar(100), @Lname1 nvarchar(100), @Email1 nvarchar(155), @EmployeeID1 nvarchar(100), @JobTitle1 nvarchar(100), @ActivityCollection1 bit, @WorkerType1 bit, @IsActive1 bit, @VendorID1 INT, @TeamID1 INT, @WorkScheduleID1 INT, @JobFamOverride1 INT, @UserOverrrideID1 INT, @DeptID1 INT
	DECLARE @Fname2 nvarchar(200), @Lname2 nvarchar(200), @Email2 nvarchar(255), @EmployeeID2 nvarchar(200), @JobTitle2 nvarchar(200), @ActivityCollection2 bit, @WorkerType2 bit, @IsActive2 bit, @VendorID2 INT, @TeamID2 INT, @WorkScheduleID2 INT, @JobFamOverride2 INT, @UserOverrrideID2 INT, @DeptID2 INT
	DECLARE @UserName1 nvarchar(200), @UserName2 nvarchar(200), @UserDomainID nvarchar(200), @DomainName1 nvarchar(200), @DomainName2 nvarchar(200), @UserDomainID1 INT, @UserDomainID2 INT

	SELECT @LastProcessedTime=CAST(DefaultValue AS datetime) FROM org.Settings WHERE SettingName='DashboardChageLog_LastProcessedTime'

	SELECT @EntitySettingID=SettingID FROM org.Settings WHERE SettingName='Users'
	SELECT @DeptEntitySettingID=SettingID FROM org.Settings WHERE SettingName='Department'
	SELECT @TeamEntitySettingID=SettingID FROM org.Settings WHERE SettingName='Team'

	--################################################################ Users ###############################################################

	--**** NEW USERS ****
	INSERT INTO org.DashboardChangeLog (CompanyID, EntityId, EntityDisplayName, EntityChangeAction, ModifiedBy, ModifiedOn, EntitySettingID)
	select distinct u.CompanyID, u.UserID, FirstName + ' ' + LastName FullName, 1, ModifiedBy, u.SysStartTimeUTC, @EntitySettingID
	from org.Users u 
	LEFT JOIN (select distinct CompanyID, UserID from history.UsersHistory where SysEndTimeUTC > @LastProcessedTime) uh ON u.CompanyID=uh.CompanyID AND u.UserID=uh.UserID
	WHERE u.SysStartTimeUTC > @LastProcessedTime AND uh.UserID IS NULL

	--**** DELETED USERS ****
	INSERT INTO org.DashboardChangeLog (CompanyID, EntityId, EntityDisplayName, EntityChangeAction, ModifiedBy, ModifiedOn, EntitySettingID)
	select distinct uh.CompanyID, uh.UserID, uh.FullName, 3, uh.ModifiedBy, ModifiedOn, @EntitySettingID
	from (select CompanyID, UserID, MAX(FirstName + ' ' + LastName) FullName, MAX(ModifiedBy) ModifiedBy, MAX(SysEndTimeUTC) ModifiedOn from history.UsersHistory where SysEndTimeUTC > @LastProcessedTime group by CompanyID, UserID) uh
	LEFT JOIN org.Users u ON u.CompanyID=uh.CompanyID AND u.UserID=uh.UserID
	WHERE u.UserID IS NULL

	--**** UPDATED USERS ****
	SELECT ROW_NUMBER() OVER(ORDER BY UserID) ID, * INTO #users FROM
	(SELECT DISTINCT uh.CompanyID, uh.UserID, uh.FirstName + ' ' + uh.LastName Fullname FROM history.UsersHistory uh
	JOIN org.Users u ON uh.CompanyID = u.CompanyID AND uh.UserID = u.UserID
	WHERE uh.SysEndTimeUTC > @LastProcessedTime) a

	WHILE (@Usercounter) <= (SELECT MAX(ID) FROM #users)
	BEGIN
		SELECT @companyID=CompanyID, @UserID=UserID, @Fullname=Fullname FROM #users WHERE ID=@Usercounter
	
			select ROW_NUMBER() OVER(ORDER BY UserID) ID, * INTO #jim
			from
			(
			select uh.CompanyID, uh.UserID, uh.UserActivityOverrideProfileID, uh.JobFamilyActivityOverrideProfileID, uh.DepartmentID, uh.VendorID, uh.ExternalUserID, uh.UserEmail, uh.FirstName, uh.LastName, uh.JobTitle, uh.IsFullTimeEmployee, uh.IsActivityCollectionOn, uh.WorkScheduleID, uh.IsActive, uh.TeamID, uh.ModifiedBy, uh.SysStartTimeUTC
			from history.UsersHistory uh
			where uh.CompanyID=@companyID AND uh.UserID=@UserID AND uh.SysEndTimeUTC > @LastProcessedTime
			UNION
			select u.CompanyID, u.UserID, UserActivityOverrideProfileID, JobFamilyActivityOverrideProfileID, DepartmentID, VendorID, ExternalUserID, UserEmail, FirstName, LastName, JobTitle, IsFullTimeEmployee, IsActivityCollectionOn, WorkScheduleID, IsActive, TeamID, ModifiedBy, SysStartTimeUTC
			from org.users u
			JOIN (select distinct CompanyID, UserID from history.UsersHistory where SysEndTimeUTC > @LastProcessedTime) uh ON u.CompanyID = uh.CompanyID AND u.UserID=uh.UserID
			WHERE u.CompanyID=@companyID AND u.UserID=@UserID
			) results

			set @counter=1

			WHILE (@counter) <= (select max(ID) from #jim)
			BEGIN
				select @UserOverrrideID1=UserActivityOverrideProfileID, @JobFamOverride1=JobFamilyActivityOverrideProfileID, @DeptID1=DepartmentID, @VendorID1=VendorID, @EmployeeID1=ExternalUserID, @Email1=UserEmail, @Fname1=FirstName, @Lname1=LastName, @JobTitle1=JobTitle, @ActivityCollection1=IsActivityCollectionOn, @WorkScheduleID1=WorkScheduleID, @WorkerType1=IsFullTimeEmployee, @IsActive1=IsActive, @TeamID1=TeamID
				from #jim where ID=@counter

				select @ModifiedBy=ModifiedBy, @ModifiedOn=SysStartTimeUTC, @UserOverrrideID2=UserActivityOverrideProfileID, @JobFamOverride2=JobFamilyActivityOverrideProfileID, @DeptID2=DepartmentID, @VendorID2=VendorID, @EmployeeID2=ExternalUserID, @Email2=UserEmail, @Fname2=FirstName, @Lname2=LastName, @JobTitle2=JobTitle, @ActivityCollection2=IsActivityCollectionOn, @WorkScheduleID2=WorkScheduleID, @WorkerType2=IsFullTimeEmployee, @IsActive2=IsActive, @TeamID2=TeamID
				from #jim where ID=@counter+1

				--If changeLog does not have create event, if original create record is since last processed time, create the original creation record
				IF NOT EXISTS (SELECT 1 FROM org.DashboardChangeLog WHERE EntitySettingID=@EntitySettingID and EntityChangeAction=1 and CompanyID=@companyID and EntityId=@UserID)
				 BEGIN
					IF EXISTS (SELECT 1 FROM (SELECT TOP 1 * FROM org.Users FOR SYSTEM_TIME ALL WHERE CompanyID=@companyID and UserID=@UserID ORDER BY sysEndTimeUTC) base WHERE SysEndTimeUTC > @LastProcessedTime)
							
					INSERT INTO org.DashboardChangeLog (CompanyID, EntityId, EntityDisplayName, EntityChangeAction, ModifiedBy, ModifiedOn, EntitySettingID)
					SELECT TOP 1 CompanyID, UserID, FirstName + ' ' + LastName, 1, ModifiedBy, SysStartTimeUTC, @EntitySettingID 
					FROM org.Users FOR SYSTEM_TIME ALL WHERE CompanyID=@companyID and UserID=@UserID ORDER BY sysEndTimeUTC
				 END

				-- JobFamOverride
				IF (COALESCE(@JobFamOverride1,0) <> COALESCE(@JobFamOverride2,0)) 
				 BEGIN
					SELECT @PropertySettingID=SettingID FROM org.Settings WHERE SettingName='JobFamilyActivityProfile'
					SELECT @PreviousValue=JobFamilyName FROM org.JobFamilyActivityOverrideProfile WHERE JobFamilyActivityOverrideProfileID=@JobFamOverride1
					SELECT @CurrentValue=JobFamilyName FROM org.JobFamilyActivityOverrideProfile WHERE JobFamilyActivityOverrideProfileID=@JobFamOverride2

					INSERT INTO org.DashboardChangeLog (CompanyID, EntityId, EntityDisplayName, PreviousValue, CurrentValue, EntityChangeAction, ModifiedOn, ModifiedBy, PropertySettingID, EntitySettingID)
					VALUES (@companyID, @UserID, @Fullname, @PreviousValue, @CurrentValue, 2, @ModifiedOn, @ModifiedBy, @PropertySettingID, @EntitySettingID)
				 END

				-- UserOverrride
				IF (COALESCE(@UserOverrrideID1,0) <> COALESCE(@UserOverrrideID2,0)) 
				 BEGIN
					SELECT @PropertySettingID=SettingID FROM org.Settings WHERE SettingName='UserActivityProfile'
					SELECT @PreviousValue=ProfileName FROM org.UserActivityOverrideProfile WHERE UserActivityOverrideProfileID=@UserOverrrideID1
					SELECT @CurrentValue=ProfileName FROM org.UserActivityOverrideProfile WHERE UserActivityOverrideProfileID=@UserOverrrideID2

					INSERT INTO org.DashboardChangeLog (CompanyID, EntityId, EntityDisplayName, PreviousValue, CurrentValue, EntityChangeAction, ModifiedOn, ModifiedBy, PropertySettingID, EntitySettingID)
					VALUES (@companyID, @UserID, @Fullname, @PreviousValue, @CurrentValue, 2, @ModifiedOn, @ModifiedBy, @PropertySettingID, @EntitySettingID)
				 END

				-- First Name
				IF (@Fname1 <> @Fname2)
				 BEGIN
					SELECT @PropertySettingID=SettingID FROM org.Settings WHERE SettingName='FirstName'

					INSERT INTO org.DashboardChangeLog (CompanyID, EntityId, EntityDisplayName, PreviousValue, CurrentValue, EntityChangeAction, ModifiedOn, ModifiedBy, PropertySettingID, EntitySettingID)
					VALUES (@companyID, @UserID, @Fullname, @Fname1, @Fname2, 2, @ModifiedOn, @ModifiedBy, @PropertySettingID, @EntitySettingID)
				 END

				-- Last Name
				IF (@Lname1 <> @Lname2)
				 BEGIN
					SELECT @PropertySettingID=SettingID FROM org.Settings WHERE SettingName='LastName'

					INSERT INTO org.DashboardChangeLog (CompanyID, EntityId, EntityDisplayName, PreviousValue, CurrentValue, EntityChangeAction, ModifiedOn, ModifiedBy, PropertySettingID, EntitySettingID)
					VALUES (@companyID, @UserID, @Fullname, @Lname1, @Lname2, 2, @ModifiedOn, @ModifiedBy, @PropertySettingID, @EntitySettingID)
				 END

				 -- Vendor
				 IF (COALESCE(@VendorID1,0) <> COALESCE(@VendorID2,0))
				  BEGIN
					SELECT @PropertySettingID=SettingID FROM org.Settings WHERE SettingName='Vendor'
					SELECT @PreviousValue=VendorName FROM org.Vendor WHERE VendorID=@VendorID1
					SELECT @CurrentValue=VendorName FROM org.Vendor WHERE VendorID=@VendorID2

					INSERT INTO org.DashboardChangeLog (CompanyID, EntityId, EntityDisplayName, PreviousValue, CurrentValue, EntityChangeAction, ModifiedOn, ModifiedBy, PropertySettingID, EntitySettingID)
					VALUES (@companyID, @UserID, @Fullname, @PreviousValue, @CurrentValue, 2, @ModifiedOn, @ModifiedBy, @PropertySettingID, @EntitySettingID)
				  END

				 -- Department
				 IF (COALESCE(@DeptID1,0) <> COALESCE(@DeptID2,0))
				  BEGIN
					-- User entity
					SELECT @PropertySettingID=SettingID FROM org.Settings WHERE SettingName='DepartmentID'
					SELECT @PreviousValue=DepartmentName FROM org.Department WHERE DepartmentID=@DeptID1
					SELECT @CurrentValue=DepartmentName FROM org.Department WHERE DepartmentID=@DeptID2

					INSERT INTO org.DashboardChangeLog (CompanyID, EntityId, EntityDisplayName, PreviousValue, CurrentValue, EntityChangeAction, ModifiedOn, ModifiedBy, PropertySettingID, EntitySettingID)
					VALUES (@companyID, @UserID, @Fullname, @PreviousValue, @CurrentValue, 2, @ModifiedOn, @ModifiedBy, @PropertySettingID, @EntitySettingID)

					-- Dept entity
					SELECT @PropertySettingID=SettingID FROM org.Settings WHERE SettingName='DepartmentMember'

					-- added to Dept
					IF (@DeptID2 IS NOT NULL)
					 BEGIN
						SELECT @EntityName=DepartmentName FROM org.Department WHERE CompanyID=@companyID AND DepartmentID=@DeptID2
						INSERT INTO org.DashboardChangeLog (CompanyID, EntityId, EntityDisplayName, CurrentValue, RefEntityId, RefEntityName, RefPropertyChangeType, EntityChangeAction, ModifiedOn, ModifiedBy, PropertySettingID, EntitySettingID)
						VALUES (@companyID, @DeptID2, @EntityName, @Fullname, @UserID, 'Department Member', 1, 2, @ModifiedOn, @ModifiedBy, @PropertySettingID, @DeptEntitySettingID)
					 END
					
					-- removed from Dept
					IF (@DeptID1 IS NOT NULL)
					 BEGIN
						SELECT @EntityName=DepartmentName FROM org.Department WHERE CompanyID=@companyID AND DepartmentID=@DeptID1
						INSERT INTO org.DashboardChangeLog (CompanyID, EntityId, EntityDisplayName, CurrentValue, RefEntityId, RefEntityName, RefPropertyChangeType, EntityChangeAction, ModifiedOn, ModifiedBy, PropertySettingID, EntitySettingID)
						VALUES (@companyID, @DeptID1, @EntityName, @Fullname, @UserID, 'Department Member', 3, 2, @ModifiedOn, @ModifiedBy, @PropertySettingID, @DeptEntitySettingID)
					 END
				  END

				-- EmployeeID
				IF (COALESCE(@EmployeeID1,'') <> COALESCE(@EmployeeID2,''))
				 BEGIN
					SELECT @PropertySettingID=SettingID FROM org.Settings WHERE SettingName='EmployeeID'

					INSERT INTO org.DashboardChangeLog (CompanyID, EntityId, EntityDisplayName, PreviousValue, CurrentValue, EntityChangeAction, ModifiedOn, ModifiedBy, PropertySettingID, EntitySettingID)
					VALUES (@companyID, @UserID, @Fullname, @EmployeeID1, @EmployeeID2, 2, @ModifiedOn, @ModifiedBy, @PropertySettingID, @EntitySettingID)	 
				 END

				-- Email
				IF (@Email1 <> @Email2)
				 BEGIN
					SELECT @PropertySettingID=SettingID FROM org.Settings WHERE SettingName='UserEmail'

					INSERT INTO org.DashboardChangeLog (CompanyID, EntityId, EntityDisplayName, PreviousValue, CurrentValue, EntityChangeAction, ModifiedOn, ModifiedBy, PropertySettingID, EntitySettingID)
					VALUES (@companyID, @UserID, @Fullname, @Email1, @Email2, 2, @ModifiedOn, @ModifiedBy, @PropertySettingID, @EntitySettingID)	 
				 END

				-- Job title
				IF (COALESCE(@JobTitle1,'') <> COALESCE(@JobTitle2,''))
				 BEGIN
					SELECT @PropertySettingID=SettingID FROM org.Settings WHERE SettingName='JobTitle'

					INSERT INTO org.DashboardChangeLog (CompanyID, EntityId, EntityDisplayName, PreviousValue, CurrentValue, EntityChangeAction, ModifiedOn, ModifiedBy, PropertySettingID, EntitySettingID)
					VALUES (@companyID, @UserID, @Fullname, @JobTitle1, @JobTitle2, 2, @ModifiedOn, @ModifiedBy, @PropertySettingID, @EntitySettingID)	 
				 END

				 -- Activity Collection
				IF (@ActivityCollection1 <> @ActivityCollection2)
				 BEGIN
					SELECT @PropertySettingID=SettingID FROM org.Settings WHERE SettingName='Activity Collection'

					INSERT INTO org.DashboardChangeLog (CompanyID, EntityId, EntityDisplayName, PreviousValue, CurrentValue, EntityChangeAction, ModifiedOn, ModifiedBy, PropertySettingID, EntitySettingID)
					VALUES (@companyID, @UserID, @Fullname, CAST(@ActivityCollection1 as varchar(5)), CAST(@ActivityCollection2 as varchar(5)), 2, @ModifiedOn, @ModifiedBy, @PropertySettingID, @EntitySettingID)	 
				 END

				 -- Work schedule
				 IF (COALESCE(@WorkScheduleID1,0) <> COALESCE(@WorkScheduleID2,0))
				  BEGIN
					SELECT @PropertySettingID=SettingID FROM org.Settings WHERE SettingName='WorkSchedule'
					SELECT @PreviousValue=WorkScheduleName FROM org.WorkSchedule WHERE WorkScheduleID=@WorkScheduleID1
					SELECT @CurrentValue=WorkScheduleName FROM org.WorkSchedule WHERE WorkScheduleID=@WorkScheduleID2

					INSERT INTO org.DashboardChangeLog (CompanyID, EntityId, EntityDisplayName, PreviousValue, CurrentValue, EntityChangeAction, ModifiedOn, ModifiedBy, PropertySettingID, EntitySettingID)
					VALUES (@companyID, @UserID, @Fullname, @PreviousValue, @CurrentValue, 2, @ModifiedOn, @ModifiedBy, @PropertySettingID, @EntitySettingID)
				  END

				 -- Worker Type
				IF (@WorkerType1 <> @WorkerType2)
				 BEGIN
					SELECT @PropertySettingID=SettingID FROM org.Settings WHERE SettingName='WorkerType'

					INSERT INTO org.DashboardChangeLog (CompanyID, EntityId, EntityDisplayName, PreviousValue, CurrentValue, EntityChangeAction, ModifiedOn, ModifiedBy, PropertySettingID, EntitySettingID)
					VALUES (@companyID, @UserID, @Fullname, CAST(@WorkerType1 as varchar(5)), CAST(@WorkerType2 as varchar(5)), 2, @ModifiedOn, @ModifiedBy, @PropertySettingID, @EntitySettingID)	 
				 END

				 -- IsActive
				IF (@IsActive1 <> @IsActive2)
				 BEGIN
					SELECT @PropertySettingID=SettingID FROM org.Settings WHERE SettingName='IsActive'

					INSERT INTO org.DashboardChangeLog (CompanyID, EntityId, EntityDisplayName, PreviousValue, CurrentValue, EntityChangeAction, ModifiedOn, ModifiedBy, PropertySettingID, EntitySettingID)
					VALUES (@companyID, @UserID, @Fullname, CAST(@IsActive1 as varchar(5)), CAST(@IsActive2 as varchar(5)), 2, @ModifiedOn, @ModifiedBy, @PropertySettingID, @EntitySettingID)	 
				 END

				 -- Team
				IF (COALESCE(@TeamID1,0) <> COALESCE(@TeamID2,0))
				 BEGIN
					SELECT @PropertySettingID=SettingID FROM org.Settings WHERE SettingName='Manager'
					SELECT @PreviousValue=FirstName + ' ' + LastName FROM org.Team t JOIN org.Users u ON t.CompanyID=u.CompanyID AND t.ManagerID=u.UserID WHERE t.TeamID=@TeamID1
					SELECT @CurrentValue=FirstName + ' ' + LastName FROM org.Team t JOIN org.Users u ON t.CompanyID=u.CompanyID AND t.ManagerID=u.UserID WHERE t.TeamID=@TeamID2

					INSERT INTO org.DashboardChangeLog (CompanyID, EntityId, EntityDisplayName, PreviousValue, CurrentValue, EntityChangeAction, ModifiedOn, ModifiedBy, PropertySettingID, EntitySettingID)
					VALUES (@companyID, @UserID, @Fullname, @PreviousValue, @CurrentValue, 2, @ModifiedOn, @ModifiedBy, @PropertySettingID, @EntitySettingID)	 

					-- Team entity
					SELECT @PropertySettingID=SettingID FROM org.Settings WHERE SettingName='TeamMember'

					-- added to Team
					IF (@TeamID2 IS NOT NULL)
					 BEGIN
						SELECT @EntityName=TeamName FROM org.Team WHERE CompanyID=@companyID AND TeamID=@TeamID2
						INSERT INTO org.DashboardChangeLog (CompanyID, EntityId, EntityDisplayName, CurrentValue, RefEntityId, RefEntityName, RefPropertyChangeType, EntityChangeAction, ModifiedOn, ModifiedBy, PropertySettingID, EntitySettingID)
						VALUES (@companyID, @TeamID2, COALESCE(@EntityName,''), @Fullname, @UserID, 'Team Member', 1, 2, @ModifiedOn, @ModifiedBy, @PropertySettingID, @TeamEntitySettingID)
					 END
					-- removed from Team
					IF (@TeamID1 IS NOT NULL)
					 BEGIN
						SELECT @EntityName=TeamName FROM org.Team WHERE CompanyID=@companyID AND TeamID=@TeamID1
						INSERT INTO org.DashboardChangeLog (CompanyID, EntityId, EntityDisplayName, CurrentValue, RefEntityId, RefEntityName, RefPropertyChangeType, EntityChangeAction, ModifiedOn, ModifiedBy, PropertySettingID, EntitySettingID)
						VALUES (@companyID, @TeamID1, COALESCE(@EntityName,''), @Fullname, @UserID, 'Team Member', 3, 2, @ModifiedOn, @ModifiedBy, @PropertySettingID, @TeamEntitySettingID)
					 END
				 END

				--increment counter			 
				SET @counter=@counter+1
			END

			drop table #jim

		SET @Usercounter=@Usercounter+1
	END

	DROP TABLE #users


	--################################################################ User Domain ###############################################################
	SET @Usercounter = 1

	--**** NEW User Domain ****
	INSERT INTO org.DashboardChangeLog (CompanyID, EntityId, EntityDisplayName, RefEntityId, RefEntityName, RefPropertyChangeType, EntityChangeAction, ModifiedBy, ModifiedOn, EntitySettingID)
	SELECT DISTINCT u.CompanyID, u.UserID, FirstName + ' ' + LastName FullName, ud.UserDomainID, 'UserDomain', 1, 2, ud.ModifiedBy, ud.SysStartTimeUTC, @EntitySettingID
	FROM org.UserDomain ud 
	JOIN org.Users u ON ud.CompanyID = u.CompanyID AND ud.UserID=u.UserID
	LEFT JOIN (select distinct CompanyID, UserDomainID from history.UserDomainHistory where SysEndTimeUTC > @LastProcessedTime) udh ON ud.CompanyID=udh.CompanyID AND ud.UserDomainID=udh.UserDomainID
	WHERE ud.SysStartTimeUTC > @LastProcessedTime AND udh.UserDomainID IS NULL

	--***** DELETED User Domain ****
	INSERT INTO org.DashboardChangeLog (CompanyID, EntityId, EntityDisplayName, RefEntityId, RefEntityName, RefPropertyChangeType, EntityChangeAction, ModifiedBy, ModifiedOn, EntitySettingID)
	SELECT DISTINCT u.CompanyID, u.UserID, FullName, udh.UserDomainID, 'UserDomain', 3, 2, udh.ModifiedBy, ModifiedOn, @EntitySettingID
	FROM (select CompanyID, UserID, UserDomainID, MAX(ModifiedBy) ModifiedBy, MAX(SysEndTimeUTC) ModifiedOn from history.UserDomainHistory where SysEndTimeUTC > @LastProcessedTime group by CompanyID, UserID, UserDomainID) udh
	JOIN (select CompanyID, UserID, MAX(FirstName + ' ' + LastName) FullName FROM history.UsersHistory GROUP BY CompanyID, UserID) u ON udh.CompanyID = u.CompanyID AND udh.UserID = u.UserID
	LEFT JOIN org.UserDomain ud ON udh.CompanyID=ud.CompanyID AND udh.UserDomainID=ud.UserDomainID
	WHERE ud.UserDomainID IS NULL

	--**** UPDATED User Domain ****
	select ROW_NUMBER() OVER(ORDER BY UserID) ID, * INTO #userDomain 
	from  (SELECT DISTINCT ud.CompanyID, ud.UserID, ud.UserDomainID, users.FirstName + ' ' + users.LastName Fullname
			FROM history.UserDomainHistory ud 
			JOIN org.UserDomain u ON ud.CompanyID = u.CompanyID AND ud.UserID = u.UserID AND ud.UserDomainID = u.UserDomainID
			JOIN org.users users ON ud.CompanyID=users.CompanyID AND ud.UserID=users.UserID
			WHERE ud.SysEndTimeUTC > @LastProcessedTime) a


	WHILE (@Usercounter) <= (SELECT MAX(ID) FROM #userDomain)
	BEGIN
		SELECT @companyID=CompanyID, @UserID=UserID, @UserDomainID=UserDomainID, @Fullname=Fullname FROM #userDomain WHERE ID=@Usercounter

			select ROW_NUMBER() OVER(ORDER BY UserID) ID, * INTO #Hst_UserDomain
			from
			(
			select hist.CompanyID, hist.UserDomainID, hist.UserID, hist.UserName, hist.DomainName, hist.ModifiedBy, hist.SysStartTimeUTC
			from history.UserDomainHistory hist
			where hist.CompanyID=@companyID AND hist.UserID=@UserID AND hist.UserDomainID=@UserDomainID AND hist.SysEndTimeUTC > @LastProcessedTime
			UNION
			select u.CompanyID, u.UserDomainID, u.UserID, UserName, DomainName,  ModifiedBy, SysStartTimeUTC
			from org.UserDomain u
			JOIN (select distinct CompanyID, UserID, UserDomainID from history.UserDomainHistory where SysEndTimeUTC > @LastProcessedTime) uh ON u.CompanyID = uh.CompanyID AND u.UserID=uh.UserID AND u.UserDomainID = uh.UserDomainID
			WHERE u.CompanyID=@companyID AND u.UserID=@UserID AND u.UserDomainID=@UserDomainID
			) results

			set @counter=1

			WHILE (@counter) <= (select max(ID)-1 from #Hst_UserDomain)
			BEGIN
				select @UserName1=UserName, @DomainName1=DomainName, @UserDomainID1=UserDomainID, @ModifiedBy=ModifiedBy
				from #Hst_UserDomain where ID=@counter

				select @ModifiedBy=ModifiedBy, @ModifiedOn=SysStartTimeUTC, @UserName2=UserName, @DomainName2=DomainName, @UserDomainID2=UserDomainID, @ModifiedBy=ModifiedBy
				from #Hst_UserDomain where ID=@counter+1

				IF (@UserName1 <> @UserName2)
				 BEGIN
					SELECT @PropertySettingID=SettingID FROM org.Settings WHERE SettingName='UserName'

					INSERT INTO org.DashboardChangeLog (CompanyID, EntityId, EntityDisplayName, PreviousValue, CurrentValue, EntityChangeAction, ModifiedOn, ModifiedBy, PropertySettingID, EntitySettingID, RefEntityId, RefEntityName)
					VALUES (@companyID, @UserID, @Fullname, @UserName1, @UserName2, 2, @ModifiedOn, @ModifiedBy, @PropertySettingID, @EntitySettingID, @UserDomainID2, 'UserDomain')
				 END


				IF (@DomainName1 <> @DomainName2)
				 BEGIN
					SELECT @PropertySettingID=SettingID FROM org.Settings WHERE SettingName='DomainName'

					INSERT INTO org.DashboardChangeLog (CompanyID, EntityId, EntityDisplayName, PreviousValue, CurrentValue, EntityChangeAction, ModifiedOn, ModifiedBy, PropertySettingID, EntitySettingID, RefEntityId, RefEntityName)
					VALUES (@companyID, @UserID, @Fullname, @DomainName1, @DomainName2, 2, @ModifiedOn, @ModifiedBy, @PropertySettingID, @EntitySettingID, @UserDomainID2, 'UserDomain')
				 END

				SET @counter=@counter+1
			END

			drop table #Hst_UserDomain

		SET @Usercounter=@Usercounter+1
	END
	
	drop table #userDomain


	--################################################################ User Permission ###############################################################

	--***** DELETED User Permission ****
	INSERT INTO org.DashboardChangeLog (CompanyID, EntityId, EntityDisplayName, RefEntityId, RefEntityName, RefPropertyChangeType, EntityChangeAction, ModifiedBy, ModifiedOn, EntitySettingID)
	SELECT DISTINCT u.CompanyID, u.UserID, FullName, uph.Entity + '-' + uph.Permission, 'UserPermission', 3, 2, uph.ModifiedBy, ModifiedOn, @EntitySettingID
	FROM (select CompanyID, UserID, Entity, Permission, MAX(ModifiedBy) ModifiedBy, MAX(SysEndTimeUTC) ModifiedOn from history.UserPermissionHistory where SysEndTimeUTC > @LastProcessedTime group by CompanyID, UserID, Entity, Permission) uph
	JOIN (select CompanyID, UserID, MAX(FirstName + ' ' + LastName) FullName FROM history.UsersHistory GROUP BY CompanyID, UserID) u ON uph.CompanyID = u.CompanyID AND uph.UserID = u.UserID
	LEFT JOIN org.UserPermission up ON uph.CompanyID=up.CompanyID AND uph.UserID=up.UserID AND uph.Entity = up.Entity AND uph.Permission = up.Permission
	WHERE up.UserID IS NULL

	--**** NEW User Permission ****
	INSERT INTO org.DashboardChangeLog (CompanyID, EntityId, EntityDisplayName, RefEntityId, RefEntityName, RefPropertyChangeType, EntityChangeAction, ModifiedBy, ModifiedOn, EntitySettingID)
	SELECT DISTINCT u.CompanyID, u.UserID, FirstName + ' ' + LastName FullName, up.Entity + '-' + up.Permission, 'UserPermission', 1, 2, up.ModifiedBy, u.SysStartTimeUTC, @EntitySettingID
	FROM org.UserPermission up 
	JOIN org.Users u ON up.CompanyID = u.CompanyID AND up.UserID=u.UserID
	LEFT JOIN (select distinct CompanyID, UserID, Entity, Permission from history.UserPermissionHistory where SysEndTimeUTC > @LastProcessedTime) uph ON up.CompanyID=uph.CompanyID AND up.UserID=uph.UserID AND up.Entity = uph.Entity AND up.Permission = uph.Permission
	WHERE up.SysStartTimeUTC > @LastProcessedTime AND uph.UserID IS NULL

END



GO
/****** Object:  StoredProcedure [org].[sproc_GetReports]    Script Date: 8/20/2021 4:27:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE
	
 PROCEDURE [org].[sproc_GetReports] (
	@companyID INT
	,@userID INT
	,@analyticsArea INT
	,@searchText NVARCHAR(200) = NULL
	,@reportCategoryName NVARCHAR(200) = NULL
	)
AS
SET NOCOUNT ON

BEGIN
	DECLARE @deploymentModeCategoryID INT
		,@dataVisibilitySettingID INT
	DECLARE @dataVisibilityWorkerLevelOption INT = 0
	DECLARE @dataVisibilityDepartmentLevelOption INT = 1
	DECLARE @UserPermission VARCHAR(4) = 'E'
	DECLARE @strSQL NVARCHAR(4000)
	DECLARE @strSQLCondition NVARCHAR(4000)
	DECLARE @strSQLResult NVARCHAR(MAX)
	DECLARE @adminUser BIT = 0
	DECLARE @UserDepartmentID INT
	DECLARE @UserTeamID INT
	DECLARE @IsOrgMode BIT = 0
	DECLARE @IsWorkerMode BIT = 0

	IF @analyticsArea = 1
	BEGIN
		SELECT @deploymentModeCategoryID = CategoryID
		FROM org.SettingsCategory
		WHERE CategoryName = 'Deployment Mode'

		SELECT @dataVisibilitySettingID = SettingID
		FROM org.Settings
		WHERE CategoryID = @deploymentModeCategoryID
			AND SettingName = 'Data_Visibility'

		IF EXISTS (
				SELECT TOP 1 CompanyID
				FROM org.CompanySettings
				WHERE CompanyID = @companyID
					AND SettingID = @dataVisibilitySettingID
				)
		BEGIN
			IF EXISTS (
					SELECT TOP 1 SettingID
					FROM org.CompanySettings
					WHERE CompanyID = @companyID
						AND SettingID = @dataVisibilitySettingID
						AND SettingValue = @dataVisibilityDepartmentLevelOption
					)
			BEGIN
				SET @IsOrgMode = 1
				SET @IsWorkerMode = 0
			END
			ELSE IF EXISTS (
					SELECT TOP 1 SettingID
					FROM org.CompanySettings
					WHERE CompanyID = @companyID
						AND SettingID = @dataVisibilitySettingID
						AND SettingValue = @dataVisibilityWorkerLevelOption
					)
			BEGIN
				SET @IsOrgMode = 0
				SET @IsWorkerMode = 1
			END
		END
		ELSE IF EXISTS (
				SELECT TOP 1 SettingID
				FROM org.Settings
				WHERE SettingID = @dataVisibilitySettingID
				)
		BEGIN
			IF EXISTS (
					SELECT TOP 1 SettingID
					FROM org.Settings
					WHERE SettingID = @dataVisibilitySettingID
						AND DefaultValue = @dataVisibilityDepartmentLevelOption
					)
			BEGIN
				SET @IsOrgMode = 1
				SET @IsWorkerMode = 0
			END
			ELSE IF EXISTS (
					SELECT TOP 1 SettingID
					FROM org.Settings
					WHERE SettingID = @dataVisibilitySettingID
						AND DefaultValue = @dataVisibilityWorkerLevelOption
					)
			BEGIN
				SET @IsOrgMode = 0
				SET @IsWorkerMode = 1
			END
		END

		IF (
				@IsOrgMode = 1
				AND @IsWorkerMode = 0
				)
		BEGIN
			IF EXISTS (
					SELECT TOP 1 DepartmentID
					FROM org.Department
					WHERE DepartmentOwnerID = @userID
						AND CompanyID = @companyID
					)
			BEGIN
				IF (
						(
							SELECT COUNT(1)
							FROM org.Users
							WHERE IsActive = 1
								AND DepartmentID IN (
									SELECT DepartmentID
									FROM org.Department
									WHERE IsActive = 1
										AND DepartmentOwnerID = @userID
										AND CompanyID = @companyID
									)
								AND CompanyID = @companyID
							) > 0
						)
				BEGIN
					SET @UserPermission = 'O'
				END
			END

			IF (@UserPermission = 'E')
			BEGIN
				IF (
						(
							SELECT COUNT(1)
							FROM org.Users
							WHERE DepartmentID IN (
									SELECT DepartmentID
									FROM org.Department
									WHERE DepartmentOwnerID IN (
											SELECT DISTINCT JoinUserID
											FROM [org].[View_UserTree]
											WHERE CompanyID = @companyID
												AND UserID = @userID
											)
									)
								AND CompanyID = @companyID
							) > 0
						)
				BEGIN
					SET @UserPermission = 'O'
				END
			END
		END
		ELSE IF (
				@IsOrgMode = 0
				AND @IsWorkerMode = 1
				)
		BEGIN
			IF EXISTS (
					SELECT TOP 1 TeamID
					FROM org.Team
					WHERE ManagerID = @userID
						AND CompanyID = @companyID
					)
			BEGIN
				SET @UserTeamID = (
						SELECT TOP 1 TeamID
						FROM org.Team
						WHERE ManagerID = @userID
							AND CompanyID = @companyID
						)

				IF (
						(
							SELECT COUNT(1)
							FROM org.Users
							WHERE IsActive = 1
								AND TeamID = @UserTeamID
								AND CompanyID = @companyID
							) > 0
						)
				BEGIN
					SET @UserPermission = 'M'
				END
			END
		END
	END
	ELSE IF @analyticsArea = 2
	BEGIN
		IF EXISTS (
				SELECT TOP 1 UserID
				FROM org.UserPermission
				WHERE UserID = @userID
					AND CompanyID = @companyID
					AND Entity = 'Admin'
					AND Permission IN (
						'Read'
						,'Write'
						)
				)
		BEGIN
			SET @adminUser = 1
		END
	END

	SELECT RLG.ReportID
		,RLG.ExternalReportId AS Oid
		,RLG.ReportName AS Title
		,RLG.ReportDescription AS [Description]
		,RC.ReportCategoryName AS Category
		,RLG.Permission
		,RLG.ReportHelpContextId AS ContextHelpId
		,RLG.ReportOrderId AS [Order]
		,CASE 
			WHEN RUF.ReportId IS NULL
				THEN 0
			ELSE 1
			END IsFavourite
		,GETUTCDATE() AS LastPublish
		,RLE.IsAvailable
	INTO #systemDefinedReports
	FROM [org].[ReportCatalogGeneral] RLG
	JOIN [org].[ReportCategory] RC ON RLG.ReportCategoryId = RC.ReportCategoryId
	LEFT JOIN [org].[ReportCatalogExclusive] RLE ON RLG.ReportID = RLE.ReportID
		AND RLE.CompanyID = @companyID
	LEFT JOIN [org].[ReportUserFavorites] RUF ON RLG.ReportID = RUF.ReportId
		AND RUF.UserID = @userID
		AND RUF.CompanyID = @companyID
	WHERE RLG.IsActive = 1
		AND RLG.IsSystemDefined = 1
		AND RC.IsActive = 1
		AND RLG.AnalyticsArea = @analyticsArea
		AND (
			@adminUser = 1
			OR @analyticsArea = 1
			)
	OPTION (RECOMPILE)

	SELECT RLG.ReportID
		,RLG.ExternalReportId AS Oid
		,RLG.ReportName AS Title
		,RLG.ReportDescription AS [Description]
		,RC.ReportCategoryName AS Category
		,RLG.Permission
		,RLG.ReportHelpContextId AS ContextHelpId
		,RLG.ReportOrderId AS [Order]
		,RUF.ReportId AS IsFavourite
		,GETUTCDATE() AS LastPublish
		,RLE.IsAvailable
	INTO #otherReports
	FROM [org].[ReportCatalogGeneral] RLG
	JOIN [org].[ReportCategory] RC ON RLG.ReportCategoryId = RC.ReportCategoryId
	JOIN [org].[ReportCatalogExclusive] RLE ON RLG.ReportID = RLE.ReportID
		AND RLE.CompanyID = @companyID
		AND RLE.IsAvailable = 1
	LEFT JOIN [org].[ReportUserFavorites] RUF ON RLG.ReportID = RUF.ReportId
		AND RUF.UserID = @userID
		AND RUF.CompanyID = @companyID
	WHERE RLG.IsActive = 1
		AND RLG.IsSystemDefined = 0
		AND RC.IsActive = 1
		AND RLG.AnalyticsArea = @analyticsArea
		AND (
			@adminUser = 1
			OR @analyticsArea = 1
			)
	OPTION (RECOMPILE)

	SET @strSQL = 'SELECT 
		ReportID,
		Oid,
		Title,
		[Description],
		Category,
		ContextHelpId,
		[Order],
		CASE 
			WHEN IsFavourite = 0
				OR IsFavourite IS NULL
				THEN 0
			ELSE 1
			END AS IsFavourite,
		LastPublish
		FROM 
		(SELECT * FROM #systemDefinedReports 
		WHERE IsAvailable = 1
		OR IsAvailable IS NULL
		UNION ALL
		SELECT * FROM #otherReports 
	WHERE IsAvailable = 1
		OR IsAvailable IS NULL) results
	WHERE 1=1' + CASE 
			WHEN (
					@reportCategoryName IS NULL
					OR @reportCategoryName = ''
					)
				THEN ''
			ELSE ' AND Category LIKE ''%' + @reportCategoryName + '%'''
			END + CASE 
			WHEN (
					@searchText IS NULL
					OR @searchText = ''
					)
				THEN ''
			ELSE ' AND (Title LIKE ''%' + @searchText + '%'' OR [Description] LIKE ''%' + @searchText + '%'')'
			END

	IF @analyticsArea = 1
	BEGIN
		SET @strSQLCondition = CASE 
				WHEN @UserPermission = 'E'
					THEN ' AND Permission IN (''E'',''EM'')'
				WHEN @UserPermission = 'M'
					THEN ' AND Permission IN (''M'',''EM'')'
				WHEN @UserPermission = 'O'
					THEN ' AND Permission IN (''O'',''E'',''EM'')'
				END + ' ORDER BY [Order]'
	END
	ELSE
	BEGIN
		SET @strSQLCondition = ' ORDER BY [Order]'
	END

	-- OUTPUT 
	SET @strSQLResult = @strSQL + @strSQLCondition

	EXEC sp_executesql @strSQLResult;

	DROP TABLE #systemDefinedReports

	DROP TABLE #otherReports
END

GO
/****** Object:  StoredProcedure [org].[sproc_LicenseUserCounts]    Script Date: 8/20/2021 4:27:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [org].[sproc_LicenseUserCounts]
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @companyID INT
	DECLARE @counter INT = 1
	DECLARE @startDate Datetime, @endDate Datetime, @currentDate Datetime, @companyLicenseStart Datetime, @companyLicenseEnd Datetime
	DECLARE @currentDaysInMonth INT

	SET @endDate=CONVERT(VARCHAR(10), GETUTCDATE(), 101)
	SET @startDate= @endDate-DAY(@endDate)+1

	-- #company
	SELECT ROW_NUMBER() OVER (ORDER BY CompanyID) ID, CompanyID, StartDate, EndDate 
	INTO #company
	FROM
	(SELECT CompanyID, MIN(StartDate) StartDate, MAX(EndDate) EndDate FROM org.ModuleLicenseLineItem GROUP BY CompanyID)
	company

	-- #usage
	CREATE TABLE #usage
	(
		CompanyID INT,
		UsageDate DateTime,
		UsageCount INT
	)

	-- #results
	CREATE TABLE #results
	(
		CompanyID INT,
		[Year] INT,
		[Month] INT,
		AverageUsage DECIMAL(9,2)
	)

	-- #usage
	WHILE (@counter <= (SELECT MAX(ID) FROM #company))
	BEGIN -- begin company
		SELECT @companyID=CompanyID, @companyLicenseStart=StartDate, @companyLicenseEnd=EndDate
		FROM #company WHERE ID=@counter

		-- company license start must be present or past month and end must be present or future month
		IF CAST(DATEPART(YEAR,@companyLicenseEnd) AS VARCHAR) + RIGHT('0'+CAST(DATEPART(MONTH,@companyLicenseEnd) AS VARCHAR),2) >= CAST(DATEPART(YEAR,@endDate) AS VARCHAR) + RIGHT('0'+CAST(DATEPART(MONTH,@endDate) AS VARCHAR),2)
		AND CAST(DATEPART(YEAR,@companyLicenseStart) AS VARCHAR) + RIGHT('0'+CAST(DATEPART(MONTH,@companyLicenseStart) AS VARCHAR),2) <= CAST(DATEPART(YEAR,@startDate) AS VARCHAR) + RIGHT('0'+CAST(DATEPART(MONTH,@startDate) AS VARCHAR),2)
		BEGIN -- begin company eligible to process

			-- If @startDate month/year the same as company license month/year, use the company's start date
			IF DATEPART(YEAR,@startDate) = DATEPART(YEAR,@companyLicenseStart) AND DATEPART(MONTH,@startDate) = DATEPART(MONTH,@companyLicenseStart)
			  BEGIN
				SET @CurrentDate = @companyLicenseStart
			  END
			ELSE
			  BEGIN
				SET @CurrentDate = @StartDate
			  END

			-- If @endDate month/year the same as company license month/year, use the company's end date
			IF DATEPART(YEAR,@endDate) = DATEPART(YEAR,@companyLicenseEnd) AND DATEPART(MONTH,@endDate) = DATEPART(MONTH,@companyLicenseEnd)
			  BEGIN
				SET @endDate = @companyLicenseEnd
			  END
			ELSE
			  BEGIN
				SET @endDate = CONVERT(VARCHAR(10), GETUTCDATE(), 101)
			  END

			-- flush out #usage for next company
			TRUNCATE TABLE #usage

			-- get current days in month to process
			SET @currentDaysInMonth=DATEDIFF(DAY,@CurrentDate,@endDate) + 1

			-- process each day of month
			WHILE (@CurrentDate < @EndDate)
			BEGIN -- begin each day of month
				INSERT INTO #usage (CompanyID, UsageDate, UsageCount) 
					(SELECT @companyID, @CurrentDate, count(*) 
					FROM org.Users  
					FOR SYSTEM_TIME AS OF  @CurrentDate 
					WHERE IsActive=1 AND CompanyId=@companyID)

				SET @CurrentDate = convert(varchar(30), dateadd(day,1, @CurrentDate), 101)
			END -- end each day of month

			-- #results
			INSERT INTO #results (CompanyID, [Year], [Month], AverageUsage)
			SELECT 	
			CompanyID,
			DATEPART(Year, UsageDate) as [Year], 
			DATEPART(MONTH, UsageDate) as [Month], 
			SUM(UsageCount)/cast(@currentDaysInMonth as decimal(9,2)) as AverageUsage
			FROM #usage 
			GROUP BY 
			CompanyID,
			DATEPART(YEAR, UsageDate), 
			DATEPART(MONTH, UsageDate),
			DAY(EOMONTH(UsageDate))

		END -- end company eligible to process
		
		SET @counter=@counter+1

	END -- end company


	-- UPDATE/INSERT
	MERGE org.LicenseCounts lc
	USING #results r ON lc.CompanyID=r.CompanyID AND lc.Year=r.Year AND lc.Month=r.Month
	WHEN MATCHED THEN 
		UPDATE SET AverageUsage = r.AverageUsage
	WHEN NOT MATCHED BY TARGET THEN 
		INSERT (CompanyID, Year, Month, AverageUsage)
		VALUES (r.CompanyID, r.Year, r.Month, r.AverageUsage);


	DROP TABLE #company
	DROP TABLE #usage
	DROP TABLE #results

END

GO
EXEC sys.sp_addextendedproperty @name=N'microsoft_database_tools_support', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysdiagrams'
GO
