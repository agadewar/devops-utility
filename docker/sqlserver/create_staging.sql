USE [master]
GO
/****** Object:  Database [Staging]    Script Date: 8/17/2021 3:06:17 PM ******/
CREATE DATABASE [Staging]
 CONTAINMENT = NONE
ON  PRIMARY 
( NAME = N'Staging', FILENAME = N'/var/opt/mssql/data/Staging.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
LOG ON 
( NAME = N'Staging_log', FILENAME = N'/var/opt/mssql/data/Staging_log.ldf' , SIZE = 73728KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
--WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO
--ALTER DATABASE [Staging] SET COMPATIBILITY_LEVEL = 150
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [Staging].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [Staging] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [Staging] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [Staging] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [Staging] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [Staging] SET ARITHABORT OFF 
GO
ALTER DATABASE [Staging] SET AUTO_CLOSE ON 
GO
ALTER DATABASE [Staging] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [Staging] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [Staging] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [Staging] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [Staging] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [Staging] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [Staging] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [Staging] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [Staging] SET  ENABLE_BROKER 
GO
ALTER DATABASE [Staging] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [Staging] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [Staging] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [Staging] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [Staging] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [Staging] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [Staging] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [Staging] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [Staging] SET  MULTI_USER 
GO
ALTER DATABASE [Staging] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [Staging] SET DB_CHAINING OFF 
GO
ALTER DATABASE [Staging] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [Staging] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [Staging] SET DELAYED_DURABILITY = DISABLED 
GO
--ALTER DATABASE [Staging] SET ACCELERATED_DATABASE_RECOVERY = OFF  
--GO
ALTER DATABASE [Staging] SET QUERY_STORE = OFF
GO
USE [Staging]
GO
/****** Object:  Table [dbo].[CycleStatus]    Script Date: 8/17/2021 3:06:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CycleStatus](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[CompanyId] [nvarchar](50) NULL,
	[CycleId] [nvarchar](50) NULL,
	[CycleEndTime] [datetime] NULL,
	[Status] [nvarchar](50) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[flyway_schema_history_integrations]    Script Date: 8/17/2021 3:06:17 PM ******/
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
/****** Object:  Table [dbo].[OrgUsers]    Script Date: 8/17/2021 3:06:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OrgUsers](
	[OrgUserID] [int] IDENTITY(100,1) NOT NULL,
	[CompanyID] [int] NOT NULL,
	[EmployeeID] [nvarchar](100) NULL,
	[FirstName] [nvarchar](100) NOT NULL,
	[LastName] [nvarchar](100) NOT NULL,
	[Email] [nvarchar](150) NOT NULL,
	[ManagerEmail] [nvarchar](150) NULL,
	[JobTitle] [nvarchar](100) NULL,
	[JobFamily] [nvarchar](100) NULL,
	[Location] [nvarchar](150) NULL,
	[Department] [nvarchar](150) NOT NULL,
	[IsUserDepartmentOwner] [bit] NULL,
	[IsActivityCollected] [bit] NULL,
	[IsContractor] [bit] NULL,
	[Vendor] [nvarchar](150) NULL,
	[CreateVueLogin] [bit] NULL,
	[DomainId1] [nvarchar](100) NULL,
	[DomainName1] [nvarchar](100) NULL,
	[DomainId2] [nvarchar](100) NULL,
	[DomainName2] [nvarchar](100) NULL,
	[CreatedDateTime] [datetimeoffset](7) NOT NULL,
 CONSTRAINT [PK_OrgUsers] PRIMARY KEY CLUSTERED 
(
	[OrgUserID] ASC,
	[CompanyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Staging]    Script Date: 8/17/2021 3:06:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Staging](
	[OrgUserID] [int] NOT NULL,
	[CompanyID] [int] NOT NULL,
	[EmployeeID] [nvarchar](50) NULL,
	[FirstName] [nvarchar](50) NOT NULL,
	[LastName] [nvarchar](50) NOT NULL,
	[Email] [nvarchar](50) NOT NULL,
	[ManagerEmail] [nvarchar](50) NULL,
	[JobTitle] [nvarchar](100) NULL,
	[JobFamily] [nvarchar](50) NULL,
	[Location] [nvarchar](50) NULL,
	[Department] [nvarchar](50) NOT NULL,
	[IsUserDepartmentOwner] [nvarchar](50) NULL,
	[IsActivityCollected] [nvarchar](50) NULL,
	[IsContractor] [nvarchar](50) NULL,
	[Vendor] [nvarchar](50) NULL,
	[CreateVueLogin] [nvarchar](50) NULL,
	[DomainId1] [nvarchar](50) NULL,
	[DomainName1] [nvarchar](50) NULL,
	[DomainId2] [nvarchar](50) NULL,
	[DomainName2] [nvarchar](50) NULL,
	[CreatedDateTime] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_Staging] PRIMARY KEY CLUSTERED 
(
	[OrgUserID] ASC,
	[CompanyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [flyway_schema_history_integrations_s_idx]    Script Date: 8/17/2021 3:06:17 PM ******/
CREATE NONCLUSTERED INDEX [flyway_schema_history_integrations_s_idx] ON [dbo].[flyway_schema_history_integrations]
(
	[success] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CycleStatus] ADD  CONSTRAINT [DF_CycleStatus_CycleEndTime]  DEFAULT (getutcdate()) FOR [CycleEndTime]
GO
ALTER TABLE [dbo].[flyway_schema_history_integrations] ADD  DEFAULT (getdate()) FOR [installed_on]
GO
ALTER TABLE [dbo].[OrgUsers] ADD  CONSTRAINT [DF_OrgUser_CreatedDateTime]  DEFAULT (getutcdate()) FOR [CreatedDateTime]
GO
USE [master]
GO
ALTER DATABASE [Staging] SET  READ_WRITE 
GO
