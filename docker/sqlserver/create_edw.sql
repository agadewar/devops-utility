USE [master]
GO
/****** Object:  Database [Admin]    Script Date: 8/17/2021 3:06:17 PM ******/
CREATE DATABASE [EDW]
 CONTAINMENT = NONE
ON  PRIMARY 
( NAME = N'EDW', FILENAME = N'/var/opt/mssql/data/EDW.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
LOG ON 
( NAME = N'EDW_log', FILENAME = N'/var/opt/mssql/data/EDW_log.ldf' , SIZE = 73728KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
--WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO
USE [EDW]
GO
/****** Object:  Schema [arch]    Script Date: 9/10/2021 8:09:56 AM ******/
CREATE SCHEMA [arch]
GO
/****** Object:  Schema [archv]    Script Date: 9/10/2021 8:09:56 AM ******/
CREATE SCHEMA [archv]
GO
/****** Object:  Schema [edw]    Script Date: 9/10/2021 8:09:56 AM ******/
CREATE SCHEMA [edw]
GO
/****** Object:  Schema [history]    Script Date: 9/10/2021 8:09:56 AM ******/
CREATE SCHEMA [history]
GO
/****** Object:  Schema [md]    Script Date: 9/10/2021 8:09:56 AM ******/
CREATE SCHEMA [md]
GO
/****** Object:  Schema [org]    Script Date: 9/10/2021 8:09:56 AM ******/
CREATE SCHEMA [org]
GO
/****** Object:  Schema [Staging]    Script Date: 9/10/2021 8:09:57 AM ******/
CREATE SCHEMA [Staging]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_diagramobjects]    Script Date: 9/10/2021 8:09:57 AM ******/
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
/****** Object:  UserDefinedFunction [dbo].[Parse_For_Domain_Name]    Script Date: 9/10/2021 8:09:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE    FUNCTION [dbo].[Parse_For_Domain_Name] (
@url nvarchar(255)
)
returns nvarchar(255)

AS

BEGIN

declare @domain nvarchar(255)

-- Check if there is the "http://" in the @url
declare @http nvarchar(10)
declare @https nvarchar(10)
declare @protocol nvarchar(10)
set @http = 'http://'
set @https = 'https://'

declare @isHTTPS bit
set @isHTTPS = 0

select @domain = CharIndex(@http, @url)

if CharIndex(@http, @url) > 1
begin
if CharIndex(@https, @url) = 1
set @isHTTPS = 1
else
select @url = @http + @url
-- return 'Error at : ' + @url
-- select @url = substring(@url, CharIndex(@http, @url), len(@url) - CharIndex(@http, @url) + 1)
end

if CharIndex(@http, @url) = 0
if CharIndex(@https, @url) = 1
set @isHTTPS = 1
else
select @url = @http + @url

if @isHTTPS = 1
set @protocol = @https
else
set @protocol = @http

if CharIndex(@protocol, @url) = 1
begin
select @url = substring(@url, len(@protocol) + 1, len(@url)-len(@protocol))
if CharIndex('/', @url) > 0
select @url = substring(@url, 0, CharIndex('/', @url))

declare @i int
set @i = 0
while CharIndex('.', @url) > 0
begin
select @i = CharIndex('.', @url)
select @url = stuff(@url,@i,1,'/')
end
select @url = stuff(@url,@i,1,'.')

set @i = 0
while CharIndex('/', @url) > 0
begin
select @i = CharIndex('/', @url)
select @url = stuff(@url,@i,1,'.')
end

select @domain = substring(@url, @i + 1, len(@url)-@i)
end

return @domain

END

GO
/****** Object:  UserDefinedFunction [edw].[GetHostNameFromUrl]    Script Date: 9/10/2021 8:09:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE    FUNCTION [edw].[GetHostNameFromUrl] (@Url nvarchar(4000))
RETURNS NVARCHAR(4000)

AS
BEGIN
   
	--set @Url = 'file:///D:/QuEST/CPD/2020/CPD_August%202020_Mechanical_01Aug2020_Approach_Circulation.pdf'
   -- set @Url = 'http://abc/a.html'
	--set @Url = 'http://www.DomainUrl.com/abc/xyz?a=1&b=2'

	--set @Url = 'www.DomainUrl.com/abc/xyz?a=1&b=2'

	 --set @Url = 'www.DomainUrl.com'

	 declare @HostName NVARCHAR(4000) = '' 

	 set @Url = REPLACE(@Url, '///', '//')
	
	 set @HostName = 
	/* Get just the host name from a URL */
	SUBSTRING(@Url,
		/* Starting Position (After any '//') */
		(CASE WHEN CHARINDEX('//', @Url)= 0 THEN 1 ELSE CHARINDEX('//', @Url) + 2 END),
		/* Length (ending on first '/' or on a '?') */
		CASE
			WHEN CHARINDEX('/', @Url, CHARINDEX('//', @Url) + 2) > 0 THEN CHARINDEX('/', @Url, CHARINDEX('//', @Url) + 2) - (CASE WHEN CHARINDEX('//', @Url)= 0 THEN 1 ELSE CHARINDEX('//', @Url) + 2 END)
			WHEN CHARINDEX('?', @Url, CHARINDEX('//', @Url) + 2) > 0 THEN CHARINDEX('?', @Url, CHARINDEX('//', @Url) + 2) - (CASE WHEN CHARINDEX('//', @Url)= 0 THEN 1 ELSE CHARINDEX('//', @Url) + 2 END)
			ELSE LEN(@Url)
		END
	) 

	return @HostName

	--declare @Dot int
	--declare @Slash int

	--set @Dot = CHARINDEX('.', @URL)
	--set @Slash = CHARINDEX('/', @URL)

	--WHILE @Slash > 0 AND @Slash < @Dot
	--BEGIN
	--	SET @URL = SUBSTRING(@URL,@Slash+1, LEN(@URL))
	--	set @Dot = CHARINDEX('.', @URL)
	--	set @Slash = CHARINDEX('/', @URL)
	--END

	--IF @Slash > 0 
	--BEGIN
	--	SET @URL = LEFT(@URL, @Slash-1)
	--END

	--	--select @Url UrlString

	--RETURN @URL -- HostName

END;


GO
/****** Object:  Table [md].[Department]    Script Date: 9/10/2021 8:09:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE EXTERNAL TABLE [md].[Department]
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
	[IsActive] [bit] NOT NULL
)
WITH (DATA_SOURCE = [eds_Dev_MAD])
GO
/****** Object:  Table [md].[Users]    Script Date: 9/10/2021 8:09:58 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE EXTERNAL TABLE [md].[Users]
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
	[DataCollectionOff] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[ModifiedBy] [int] NOT NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[SysStartTimeUTC] [datetime2](7) NULL,
	[SysEndTimeUTC] [datetime2](7) NULL
)
WITH (DATA_SOURCE = [eds_Dev_MAD])
GO
/****** Object:  Table [md].[UserDepartmentHistory]    Script Date: 9/10/2021 8:09:58 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE EXTERNAL TABLE [md].[UserDepartmentHistory]
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
/****** Object:  View [edw].[View_UserTreePan]    Script Date: 9/10/2021 8:09:59 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




--select * from [edw].[View_UserTreeWithDataCollectionOffCheck] u where u.CompanyID = 1


CREATE  VIEW [edw].[View_UserTreePan] 
AS

	with ReportsToUserIdList as
	(
		select distinct h.CompanyID, h.ReportsToUserID UserID  --1 IsUserDataManagerInCompany
		from [MD].[Users] h
		where
			DataCollectionOff = 0
	)
	
	, UserList as

	(
		select h.CompanyID, h.ReportsToUserID Parent, h.UserID Child, '' DepartmentIds
		from [MD].[Users] h
		where
			DataCollectionOff = 0 
		
	)

	
	, UserDept as
	
	(
		Select a.CompanyID, a.UserID, c.ManagerUserID DepartmentUserID, a.ReportsToUserID
		from [MD].[Users] a
		INNER JOIN [MD].[UserDepartmentHistory] b
		ON(a.CompanyID = b.CompanyID AND a.UserID = b.UserID)
		INNER JOIN [MD].[Department] c
		ON (b.CompanyID = c.CompanyID AND b.DepartmentID = c.DepartmentID)
		where
			DataCollectionOff = 0 and a.UserID <> c.ManagerUserID
	)


	
	--select * from #DataSource

	, UserHierarchy as (
	
			select s.CompanyID, Parent UserID, Child JoinUserID, 1 as TreeLevel
			from UserList s
			where
				s.Parent <> s.Child

			union all

			select d.CompanyID, d.UserID, s.Child, d.TreeLevel + 1
			from UserHierarchy as d
			inner join UserList s 
			on
				d.CompanyID = s.CompanyID AND d.JoinUserID = s.Parent
			where
				s.Parent <> s.Child ---and d.TreeLevel <= 1

	)
	
	, UserDeptBase as (
	select * from UserDept f
	where not exists (
		select 1 from UserHierarchy l where f.CompanyID = l.CompanyID and f.DepartmentUserID = l.UserID and f.UserID = l.JoinUserID)
	)


	---Select * from UserHierarchy


	select t.CompanyID , u.UserEmail UserEmail
	, t.UserID, t.JoinUserID, s.ReportsToUserID ManagerID, convert(bit, IsNull(rt.UserID, 0))  IsJoinUserIdManagerInCompany, ul.DepartmentIds
	, CASE WHEN s1.ReportsToUserID=t.UserID THEN 1 ELSE 0 END as IsManagerIDDirectReportee
	,s1.ReportsToUserID as PanUserid1 ,t.UserID as PanUserid2
	from
	(

		select u.CompanyID, u.UserID UserID, u.UserID JoinUserID, -1 TreeLevel
		from [MD].[Users] u
		where DataCollectionOff = 0
		
		union all

		select uh.CompanyID, uh.UserID, uh.JoinUserID, uh.TreeLevel 
		from UserHierarchy uh
	--option (maxrecursion 1000)

		union all

		select uhk.CompanyID, uhk.DepartmentUserID, uhk.UserID , -100 TreeLevel
		from UserDeptBase uhk

	) as t

	inner join [MD].[Users] s
	on
		t.CompanyID = s.CompanyID and t.JoinUserID = s.UserID
	
	inner join [MD].[Users] s1
	on
		t.CompanyID = s1.CompanyID and s.ReportsToUserID=s1.UserID
    
	inner join [MD].[Users] u
	on
		t.CompanyID = u.CompanyID and t.UserId = u.UserID
	inner join UserList ul
	on
		t.CompanyID = ul.CompanyID and t.JoinUserID = ul.Child
    
	left outer join ReportsToUserIdList rt
	on
		t.CompanyID = rt.CompanyID and t.JoinUserID = rt.UserID
GO
/****** Object:  View [edw].[View_UserTreeOld]    Script Date: 9/10/2021 8:09:59 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



--select * from [edw].[View_UserTreeWithDataCollectionOffCheck] u where u.CompanyID = 1


CREATE      VIEW [edw].[View_UserTreeOld] 
AS

	with ReportsToUserIdList as
	(
		select distinct h.CompanyID, h.ReportsToUserID UserID  --1 IsUserDataManagerInCompany
		from [MD].[Users] h
		where
			DataCollectionOff = 0
	)
	
	, UserList as

	(
		select h.CompanyID, h.ReportsToUserID Parent, h.UserID Child, '' DepartmentIds
		from [MD].[Users] h
		where
			DataCollectionOff = 0 
		
	)

	
	, UserDept as
	
	(
		Select a.CompanyID, a.UserID, c.ManagerUserID DepartmentUserID, a.ReportsToUserID
		from [MD].[Users] a
		INNER JOIN [MD].[UserDepartmentHistory] b
		ON(a.CompanyID = b.CompanyID AND a.UserID = b.UserID)
		INNER JOIN [MD].[Department] c
		ON (b.CompanyID = c.CompanyID AND b.DepartmentID = c.DepartmentID)
		where
			DataCollectionOff = 0 and a.UserID <> c.ManagerUserID
	)


	
	--select * from #DataSource

	, UserHierarchy as (
	
			select s.CompanyID, Parent UserID, Child JoinUserID, 1 as TreeLevel
			from UserList s
			where
				s.Parent <> s.Child

			union all

			select d.CompanyID, d.UserID, s.Child, d.TreeLevel + 1
			from UserHierarchy as d
			inner join UserList s 
			on
				d.CompanyID = s.CompanyID AND d.JoinUserID = s.Parent
			where
				s.Parent <> s.Child ---and d.TreeLevel <= 1

	)
	
	, UserDeptBase as (
	select * from UserDept f
	where not exists (
		select 1 from UserHierarchy l where f.CompanyID = l.CompanyID and f.DepartmentUserID = l.UserID and f.UserID = l.JoinUserID)
	)


	---Select * from UserHierarchy


	select t.CompanyID , u.UserEmail UserEmail
	, t.UserID, t.JoinUserID, s.ReportsToUserID ManagerID, convert(bit, IsNull(rt.UserID, 0))  IsJoinUserIdManagerInCompany, ul.DepartmentIds
	, CASE WHEN s1.ReportsToUserID=t.UserID THEN 1 ELSE 0 END as IsManagerIDDirectReportee
	from
	(

		select u.CompanyID, u.UserID UserID, u.UserID JoinUserID, -1 TreeLevel
		from [MD].[Users] u
		where DataCollectionOff = 0
		
		union all

		select uh.CompanyID, uh.UserID, uh.JoinUserID, uh.TreeLevel 
		from UserHierarchy uh
	--option (maxrecursion 1000)

		union all

		select uhk.CompanyID, uhk.DepartmentUserID, uhk.UserID , -100 TreeLevel
		from UserDeptBase uhk

	) as t

	inner join [MD].[Users] s
	on
		t.CompanyID = s.CompanyID and t.JoinUserID = s.UserID
	
	inner join [MD].[Users] s1
	on
		t.CompanyID = s1.CompanyID and s.ReportsToUserID=s1.UserID
    
	inner join [MD].[Users] u
	on
		t.CompanyID = u.CompanyID and t.UserId = u.UserID
	inner join UserList ul
	on
		t.CompanyID = ul.CompanyID and t.JoinUserID = ul.Child
    
	left outer join ReportsToUserIdList rt
	on
		t.CompanyID = rt.CompanyID and t.JoinUserID = rt.UserID
GO
/****** Object:  Table [edw].[Dim_User]    Script Date: 9/10/2021 8:09:59 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Dim_User](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CompanyID] [int] NOT NULL,
	[EmployeeCode] [nvarchar](255) NULL,
	[UserEmail] [nvarchar](255) NOT NULL,
	[FirstName] [nvarchar](255) NOT NULL,
	[LastName] [nvarchar](255) NULL,
	[DateCreated] [smalldatetime] NOT NULL,
	[DateDeleted] [smalldatetime] NULL,
	[IsActive] [bit] NOT NULL,
	[CurrentTimestamp] [timestamp] NOT NULL,
	[Dim_LocationID] [int] NULL,
	[UserID] [int] NOT NULL,
	[HasEmployeeDataAccess] [bit] NOT NULL,
	[Dim_WorkScheduleID] [int] NULL,
	[Dim_VendorID] [int] NULL,
	[Dim_DepartmentID] [int] NULL,
	[Dim_JobFamilyProfileID] [int] NULL,
	[Dim_UserProfileID] [int] NULL,
	[IsActivityCollectionOn] [bit] NOT NULL,
	[BI_ID] [nvarchar](100) NULL,
	[IdentityMgmt_ID] [nvarchar](100) NULL,
	[IsFullTimeEmployee] [bit] NOT NULL,
	[DimTeamID] [int] NULL,
	[UserName] [nvarchar](4000) NULL,
	[JobTitle] [nvarchar](100) NULL,
 CONSTRAINT [pk_User] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[CompanyID] ASC,
	[UserID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [edw].[View_User_CustomFields_22]    Script Date: 9/10/2021 8:09:59 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_22] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=22
GO
/****** Object:  Table [edw].[Dim_IntegrationProperty]    Script Date: 9/10/2021 8:09:59 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Dim_IntegrationProperty](
	[EntityID] [int] NOT NULL,
	[PropertyID] [int] IDENTITY(1,1) NOT NULL,
	[PropertyName] [nvarchar](4000) NOT NULL,
	[DataTypeID] [int] NOT NULL,
 CONSTRAINT [PK_Dim_IntegrationProperty] PRIMARY KEY CLUSTERED 
(
	[PropertyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Fact_Integration]    Script Date: 9/10/2021 8:09:59 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Fact_Integration](
	[Dim_CompanyID] [int] NOT NULL,
	[Dim_UserID] [int] NOT NULL,
	[Dim_EntityID] [int] NOT NULL,
	[Dim_PropertyID] [int] NOT NULL,
	[DateCreated] [datetime] NOT NULL,
	[StringValue] [nvarchar](1000) NULL,
	[NumericValue] [real] NULL,
	[DateValue] [datetime] NULL,
	[UniqueID] [nvarchar](100) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  View [edw].[View_IntegrationCases]    Script Date: 9/10/2021 8:09:59 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create   VIEW [edw].[View_IntegrationCases]
AS
	SELECT S.CompanyID, S.UserID, S.UniqueID
        ,[caseId],[Subject],[Priority],[Status],[CaseNumber],[AccountId],[AccountName],[CreatedBy],[AssignedTo],[CaseType],[IntegrationSource],[Severity],[CaseClosedBy],[CaseAcceptedBy],[CaseActivatedBy],[CaseAssignedTo],[Activity],[EstimateWorkHours],[CompletedWorkHours],[PlannedWorkHours],[RemainingWorkHours],[ActualWorkHours],[CommentCount],[DateCreated],[DateClosed],[DateLastUpdated],[DateStatusChanged],[CaseResolvedDate],[CaseActivatedDate]
        FROM
        (
            SELECT CompanyID, UserId, UniqueId, [caseId],[Subject],[Priority],[Status],[CaseNumber],[AccountId],[AccountName],[CreatedBy],[AssignedTo],[CaseType],[IntegrationSource],[Severity],[CaseClosedBy],[CaseAcceptedBy],[CaseActivatedBy],[CaseAssignedTo],[Activity],[EstimateWorkHours],[CompletedWorkHours] from 
            (
                select CompanyID, UserId, UniqueId, StringValue, PropertyName
                from 
                (
                    SELECT
                        F.Dim_CompanyID CompanyID,
                        F.Dim_UserId UserId,
                        F.UniqueId,
                        I.PropertyName,
                        F.StringValue
                    FROM
                    edw.[Fact_Integration] F
                    INNER JOIN edw.Dim_IntegrationProperty I ON F.Dim_PropertyId=I.PropertyId
                    WHERE F.Dim_EntityId = 2 AND DataTypeID=1
                ) m
            ) x
            pivot 
            (
                max(StringValue)
                for PropertyName in ([caseId],[Subject],[Priority],[Status],[CaseNumber],[AccountId],[AccountName],[CreatedBy],[AssignedTo],[CaseType],[IntegrationSource],[Severity],[CaseClosedBy],[CaseAcceptedBy],[CaseActivatedBy],[CaseAssignedTo],[Activity],[EstimateWorkHours],[CompletedWorkHours])
            ) p 
        ) S
        
        LEFT OUTER JOIN             
        (
            SELECT CompanyID, UserId, UniqueId, [PlannedWorkHours],[RemainingWorkHours],[ActualWorkHours],[CommentCount] from 
            (
                select CompanyID, UserId, UniqueId, NumericValue, PropertyName
                from 
                (
                    SELECT
                        F.Dim_CompanyID CompanyID,
                        F.Dim_UserId UserId,
                        F.UniqueId,
                        I.PropertyName,
                        F.NumericValue
                    FROM
                    edw.[Fact_Integration] F
                    INNER JOIN edw.Dim_IntegrationProperty I ON F.Dim_PropertyId=I.PropertyId
                    WHERE F.Dim_EntityId =  2  AND DataTypeID=2
                ) m
            ) x
            pivot 
            (
                max(NumericValue)
                for PropertyName in ([PlannedWorkHours],[RemainingWorkHours],[ActualWorkHours],[CommentCount])
            ) p 
        ) N ON S.CompanyID=N.CompanyID AND S.UserID=N.UserID AND S.UniqueID=N.UniqueID
        
        LEFT OUTER JOIN
        (
            SELECT CompanyID, UserId, UniqueId, [DateCreated],[DateClosed],[DateLastUpdated],[DateStatusChanged],[CaseResolvedDate],[CaseActivatedDate] from 
            (
                select CompanyID, UserId, UniqueId, DateValue, PropertyName
                from 
                (
                    SELECT
                        F.Dim_CompanyID CompanyID,
                        F.Dim_UserId UserId,
                        F.UniqueId,
                        I.PropertyName,
                        F.DateValue
                    FROM
                    edw.[Fact_Integration] F
                    INNER JOIN edw.Dim_IntegrationProperty I ON F.Dim_PropertyId=I.PropertyId
                    WHERE F.Dim_EntityId =  2  AND DataTypeID=3
                ) m
            ) x
            pivot 
            (
                max(DateValue)
                for PropertyName in ([DateCreated],[DateClosed],[DateLastUpdated],[DateStatusChanged],[CaseResolvedDate],[CaseActivatedDate])
            ) p 
        ) D ON S.CompanyID=D.CompanyID AND S.UserID=D.UserID AND S.UniqueID=D.UniqueID

 

GO
/****** Object:  View [edw].[View_User_CustomFields_123456]    Script Date: 9/10/2021 8:09:59 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_123456] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=123456
GO
/****** Object:  Table [history].[Dim_UserDomain]    Script Date: 9/10/2021 8:09:59 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [history].[Dim_UserDomain](
	[ID] [int] NOT NULL,
	[CompanyID] [int] NOT NULL,
	[UserDomainID] [int] NOT NULL,
	[Dim_UserID] [int] NOT NULL,
	[UserName] [nvarchar](256) NOT NULL,
	[DomainName] [nvarchar](256) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[StartTime] [datetime2](7) NOT NULL,
	[EndTime] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Dim_UserDomain]    Script Date: 9/10/2021 8:09:59 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Dim_UserDomain](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CompanyID] [int] NOT NULL,
	[UserDomainID] [int] NOT NULL,
	[Dim_UserID] [int] NOT NULL,
	[UserName] [nvarchar](256) NOT NULL,
	[DomainName] [nvarchar](256) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[StartTime] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[EndTime] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
 CONSTRAINT [pk_UserDomain] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[CompanyID] ASC,
	[UserName] ASC,
	[DomainName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([StartTime], [EndTime])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON ( HISTORY_TABLE = [history].[Dim_UserDomain] )
)
GO
/****** Object:  View [edw].[View_User_CustomFields_444444]    Script Date: 9/10/2021 8:10:00 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_444444] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=444444
GO
/****** Object:  View [edw].[View_User_CustomFields_444445]    Script Date: 9/10/2021 8:10:00 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_444445] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=444445
GO
/****** Object:  View [edw].[View_User_CustomFields_888888]    Script Date: 9/10/2021 8:10:00 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_888888] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=888888
GO
/****** Object:  View [edw].[View_User_CustomFields_999993]    Script Date: 9/10/2021 8:10:00 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_999993] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=999993
GO
/****** Object:  View [edw].[View_User_CustomFields_999999]    Script Date: 9/10/2021 8:10:00 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_999999] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=999999
GO
/****** Object:  View [edw].[View_User_CustomFields_4444440]    Script Date: 9/10/2021 8:10:00 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444440] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444440
GO
/****** Object:  View [edw].[View_User_CustomFields_4444450]    Script Date: 9/10/2021 8:10:00 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444450] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444450
GO
/****** Object:  View [edw].[View_User_CustomFields_4444453]    Script Date: 9/10/2021 8:10:00 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444453] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444453
GO
/****** Object:  View [edw].[View_User_CustomFields_4444454]    Script Date: 9/10/2021 8:10:00 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444454] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444454
GO
/****** Object:  View [edw].[View_User_CustomFields_4444456]    Script Date: 9/10/2021 8:10:00 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444456] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444456
GO
/****** Object:  View [edw].[View_User_CustomFields_4444457]    Script Date: 9/10/2021 8:10:00 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444457] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444457
GO
/****** Object:  View [edw].[View_User_CustomFields_4444458]    Script Date: 9/10/2021 8:10:00 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444458] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444458
GO
/****** Object:  View [edw].[View_User_CustomFields_4444459]    Script Date: 9/10/2021 8:10:00 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444459] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444459
GO
/****** Object:  View [edw].[View_User_CustomFields_4444460]    Script Date: 9/10/2021 8:10:00 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444460] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444460
GO
/****** Object:  View [edw].[View_User_CustomFields_4444461]    Script Date: 9/10/2021 8:10:00 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444461] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444461
GO
/****** Object:  Table [edw].[Fact_TimeSlot]    Script Date: 9/10/2021 8:10:00 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Fact_TimeSlot](
	[Dim_UserID] [int] NOT NULL,
	[Dim_CompanyID] [int] NOT NULL,
	[Dim_AppMasterID] [int] NULL,
	[Dim_ActivityCategoryID] [int] NOT NULL,
	[Dim_DeviceID] [int] NULL,
	[ActivityDate] [date] NOT NULL,
	[StartTimeInLocal]  AS (dateadd(minute,[TimeZoneOffset],[StartTimeInUTC])) PERSISTED,
	[EndTimeInLocal]  AS (dateadd(minute,[TimeZoneOffset],[EndTimeInUTC])) PERSISTED,
	[DeviceID] [int] NULL,
	[FileOrUrlName] [nvarchar](4000) NOT NULL,
	[IsFileOrUrl] [bit] NOT NULL,
	[PurposeID] [int] NOT NULL,
	[IsOnPc] [bit] NOT NULL,
	[IsShift] [bit] NOT NULL,
	[StartTimeInUTC] [datetime] NOT NULL,
	[EndTimeInUTC] [datetime] NOT NULL,
	[TimeZoneOffset] [smallint] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[TimeSpent] [real] NOT NULL,
	[UploadTime] [datetime] NOT NULL,
	[IsUserModified] [bit] NOT NULL,
	[ModifiedBy] [int] NULL,
	[Dim_WebAppID] [int] NULL,
	[IsCore] [bit] NULL,
	[Dim_MachineID] [int] NULL,
	[Dim_NetworkID] [int] NULL,
	[URLDomain] [nvarchar](200) NULL,
	[ETL_ModifiedBy] [varchar](8000) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Fact_DailyActivity]    Script Date: 9/10/2021 8:10:00 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Fact_DailyActivity](
	[Dim_UserID] [int] NOT NULL,
	[Dim_CompanyID] [int] NOT NULL,
	[ActivityDate] [date] NOT NULL,
	[Dim_DeviceID] [int] NULL,
	[Dim_AppMasterID] [int] NULL,
	[Dim_ActivityCategoryID] [int] NOT NULL,
	[FileOrUrlID] [int] NOT NULL,
	[IsFileOrUrl] [bit] NOT NULL,
	[PurposeID] [int] NOT NULL,
	[IsOnPc] [bit] NOT NULL,
	[TimeSpentInCalendarDay] [real] NOT NULL,
	[TimeSpentInShift] [real] NOT NULL,
	[Dim_WebAppID] [int] NULL,
	[IsCore] [bit] NULL,
	[Dim_NetworkID] [int] NULL,
	[Dim_MachineID] [int] NULL,
 CONSTRAINT [IX_Fact_DailyActivity] UNIQUE NONCLUSTERED 
(
	[Dim_UserID] ASC,
	[Dim_CompanyID] ASC,
	[ActivityDate] ASC,
	[Dim_DeviceID] ASC,
	[Dim_ActivityCategoryID] ASC,
	[Dim_AppMasterID] ASC,
	[Dim_WebAppID] ASC,
	[FileOrUrlID] ASC,
	[IsFileOrUrl] ASC,
	[IsOnPc] ASC,
	[PurposeID] ASC,
	[IsCore] ASC,
	[Dim_NetworkID] ASC,
	[Dim_MachineID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [psc_CompanyID]([Dim_CompanyID])
) ON [psc_CompanyID]([Dim_CompanyID])
GO
/****** Object:  Table [edw].[Dim_ActivityCategory]    Script Date: 9/10/2021 8:10:00 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Dim_ActivityCategory](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CompanyID] [int] NOT NULL,
	[ActivityCategoryID] [int] NULL,
	[ActivityCategoryName] [nvarchar](1000) NOT NULL,
	[IsCore] [bit] NOT NULL,
	[IsSystemDefined] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[CurrentTimestamp] [timestamp] NOT NULL,
	[IsWorkCategory] [bit] NOT NULL,
	[IsDefault] [bit] NOT NULL,
 CONSTRAINT [pk_ActivityCategory] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Dim_AppMaster]    Script Date: 9/10/2021 8:10:00 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Dim_AppMaster](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Dim_AppParentID] [int] NULL,
	[CompanyID] [int] NOT NULL,
	[AppID] [int] NULL,
	[ExeName] [nvarchar](2048) NOT NULL,
	[AppName] [nvarchar](2048) NOT NULL,
	[AppVersion] [nvarchar](512) NOT NULL,
	[IsApplication] [bit] NOT NULL,
	[IsOffline] [bit] NOT NULL,
	[CurrentTimestamp] [timestamp] NULL,
	[AppSpecPlatformID] [int] NULL,
	[Dim_PlatformID] [int] NULL,
 CONSTRAINT [pk_AppMaster] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[CompanyID] ASC,
	[ExeName] ASC,
	[AppName] ASC,
	[AppVersion] ASC,
	[Dim_PlatformID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[View_UnmappedDetail]    Script Date: 9/10/2021 8:10:00 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CReate   VIEW [dbo].[View_UnmappedDetail] as 
select t.Dim_CompanyID,t.Dim_UserID, t.ActivityDate, a.AppName, 0 AS IsWebApp, t.TimeSpentInCalendarDay
from [edw].[Fact_DailyActivity] t 
inner join [edw].[Dim_AppMaster] a
on
       t.Dim_CompanyID = a.CompanyID and t.Dim_AppMasterID = a.ID
inner join [edw].[Dim_ActivityCategory] c
on 
		t.Dim_ActivityCategoryID = c.ID
where 
       ----t.Dim_CompanyID = 1  and 
	   t.PurposeID = -1 and t.IsOnPc = 1 and t.ActivityDate > cast(dateadd(day, -30, getdate()) as date)
       and TRIM(IsNull(a.ExeName,'')) <> '' and a.ExeName not in ('chrome.exe', 'firefox.exe', 'ApplicationFrameHost.exe', 'iexplore.exe', 'msedge.exe')
	   and (a.ExeName like '%.exe' OR a.ExeName like '%.app%' OR a.ExeName like '%.bin%' OR a.ExeName like '%.dll%')
	   and t.IsFileOrUrl = 0 and c.ActivityCategoryID = -1
UNION ALL
Select Dim_CompanyID,Dim_UserID, ActivityDate, URLDomain, 1 AS IsWebApp, Sum(Timespent) from edw.Fact_TimeSlot 
WHere isFileorURL = 1 and IsOnPC = 1 and IsActive = 1 and Dim_WebAppID is null and ActivityDate > cast(dateadd(day, -30, getdate()) as date)
Group by Dim_CompanyID, Dim_UserID, ActivityDate, URLDomain


GO
/****** Object:  View [edw].[View_User_CustomFields_4444462]    Script Date: 9/10/2021 8:10:00 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444462] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444462
GO
/****** Object:  View [edw].[View_User_CustomFields_4444463]    Script Date: 9/10/2021 8:10:00 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444463] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444463
GO
/****** Object:  View [edw].[View_User_CustomFields_4444464]    Script Date: 9/10/2021 8:10:00 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444464] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444464
GO
/****** Object:  View [edw].[View_User_CustomFields_4444465]    Script Date: 9/10/2021 8:10:00 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444465] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444465
GO
/****** Object:  View [edw].[View_User_CustomFields_4444469]    Script Date: 9/10/2021 8:10:00 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444469] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444469
GO
/****** Object:  View [edw].[View_User_CustomFields_4444470]    Script Date: 9/10/2021 8:10:00 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444470] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444470
GO
/****** Object:  View [edw].[View_User_CustomFields_4444472]    Script Date: 9/10/2021 8:10:00 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444472] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444472
GO
/****** Object:  View [edw].[View_User_CustomFields_4444474]    Script Date: 9/10/2021 8:10:00 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444474] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444474
GO
/****** Object:  View [edw].[View_User_CustomFields_4444475]    Script Date: 9/10/2021 8:10:00 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444475] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444475
GO
/****** Object:  View [edw].[View_User_CustomFields_4444476]    Script Date: 9/10/2021 8:10:00 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444476] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444476
GO
/****** Object:  View [edw].[View_User_CustomFields_4444477]    Script Date: 9/10/2021 8:10:00 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444477] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444477
GO
/****** Object:  View [edw].[View_User_CustomFields_4444478]    Script Date: 9/10/2021 8:10:00 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444478] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444478
GO
/****** Object:  View [edw].[View_User_CustomFields_4444479]    Script Date: 9/10/2021 8:10:00 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444479] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444479
GO
/****** Object:  View [edw].[View_User_CustomFields_4444480]    Script Date: 9/10/2021 8:10:00 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444480] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444480
GO
/****** Object:  Table [edw].[Dim_Team]    Script Date: 9/10/2021 8:10:00 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Dim_Team](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CompanyID] [int] NOT NULL,
	[TeamID] [int] NOT NULL,
	[ManagerID] [int] NOT NULL,
	[TeamName] [nvarchar](200) NULL,
	[TeamDescription] [nvarchar](500) NULL,
	[IsEmployeeActivityVisible] [bit] NULL,
	[CurrentRowVersion] [timestamp] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[IsActive] [bit] NULL,
 CONSTRAINT [pk_Team] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[CompanyID] ASC,
	[TeamID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Dim_Department]    Script Date: 9/10/2021 8:10:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Dim_Department](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CompanyID] [int] NOT NULL,
	[DepartmentID] [int] NOT NULL,
	[DepartmentCode] [nvarchar](255) NULL,
	[DepartmentName] [nvarchar](255) NOT NULL,
	[ManagerDimUserID] [int] NOT NULL,
	[DateCreated] [smalldatetime] NOT NULL,
	[DateActivated] [smalldatetime] NULL,
	[DateDeleted] [smalldatetime] NULL,
	[IsActive] [bit] NOT NULL,
	[CurrentTimestamp] [timestamp] NOT NULL,
	[IsEmployeeActivityVisible] [bit] NULL,
 CONSTRAINT [pk_Department] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [uc_Department] UNIQUE NONCLUSTERED 
(
	[CompanyID] ASC,
	[DepartmentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[CompanyID] ASC,
	[DepartmentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [edw].[View_UserTreeTest]    Script Date: 9/10/2021 8:10:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****** Object:  View [edw].[View_UserTree]    Script Date: 2020/07/24 20:20:50 ******/

CREATE   VIEW [edw].[View_UserTreeTest] 
AS

	with ReportsToUserIdList as
	(
		select distinct h.CompanyID, h1.UserID UserID  --1 IsUserDataManagerInCompany
		from 
				(Select a.CompanyID, b.ManagerID ReportsToDimUserID
				From [edw].[Dim_User] a
				Join [edw].[Dim_Team] b
				On (a.DimTeamID = b.ID)) h
		inner join [edw].[Dim_User] h1
		on
			h.CompanyID = h1.CompanyID and h.ReportsToDimUserID = h1.ID and h1.IsActive = 1
	)



	, UserList as
	
		(
			select k.CompanyID, k1.UserID Parent, k.UserID Child, '' DepartmentIds
			from 
					(Select a.CompanyID,a.UserID, b.ManagerID ReportsToDimUserID
					From [edw].[Dim_User] a
					Join [edw].[Dim_Team] b
					On (a.DimTeamID = b.ID)) k
			inner join [edw].[Dim_User] k1
			on
				k.CompanyID = k1.CompanyID and k.ReportsToDimUserID = k1.ID and k1.IsActive = 1
			
	
		)

	

		, UserDept as
	
	(
			Select k.CompanyID, k.UserID, k1.Userid as DepartmentUserID, k2.Userid as ReportsToUserID 
	From 
	(Select a.CompanyID, a.UserID, c.ManagerDimUserID DepartmentUserID , b.ManagerID  as ReportsToUserID, a.IsActive
	From [edw].[Dim_User] a
		Join [edw].[Dim_Team] b
		On (a.DimTeamID = b.ID)
	INNER JOIN [edw].[Dim_Department] c
	ON (a.CompanyID = c.CompanyID AND a.Dim_DepartmentID = c.ID))k
	JOIN [edw].[Dim_User] k1
	on
		k.CompanyID = k1.CompanyID and k.DepartmentUserID = k1.ID
	JOIN [edw].[Dim_User] k2
	on
		k.CompanyID = k2.CompanyID and k.ReportsToUserID = k2.ID
	Where k.UserID <> k1.Userid and k.IsActive = 1
	)
		

	, UserHierarchy as (
	
			select s.CompanyID, Parent UserID, Child JoinUserID, 1 as TreeLevel
			from UserList s
			where
				s.Parent <> s.Child
			
			union all

			select d.CompanyID, d.UserID, s.Child, d.TreeLevel + 1
			from UserHierarchy as d
			inner join UserList s 
			on
				d.CompanyID = s.CompanyID and d.JoinUserID = s.Parent
			where
				s.Parent <> s.Child

		)

		, OnetoOneHierarchy as 
		(
		Select CompanyID, Parent, string_agg(cast(Child as nvarchar(MAX)),'_') Hierarchy from UserList
		Where parent <> child group by CompanyID, Parent
		)

	------	Select * from UserHierarchy


	, UserDeptBase as (
	select * from UserDept f
	where not exists (
		select 1 from UserHierarchy l where f.CompanyID = l.CompanyID and f.DepartmentUserID = l.UserID and f.UserID = l.JoinUserID)
	)



	select t.CompanyID, u.UserEmail UserEmail, t.UserID, t.JoinUserID, s1.UserID ManagerID,t.TreeLevel,
	 convert(bit, IsNull(rt.UserID, 0))  IsJoinUserIdManagerInCompany, ul.DepartmentIds,
	  CASE WHEN s1.ParentID=t.UserID THEN 1 ELSE 0 END as IsManagerIDDirectReportee,
	  case When t.TreeLevel > 0 THEN CONCAT('_',t.JoinUserID,'_',rm.Hierarchy) else Concat('_',t.JoinUserID,'_') end as Hierarchy

	from 
	(	
		select u.CompanyID, u.UserID UserID, u.UserID JoinUserID, -1 TreeLevel
		from [EDW].[Dim_User] u Where IsActive = 1
		
		
		union all

		select uh.CompanyID, uh.UserID, uh.JoinUserID, uh.TreeLevel 
		from UserHierarchy uh
	--	option (maxrecursion 1000)
		

		union all

		select uhk.CompanyID, uhk.DepartmentUserID, uhk.UserID , -100 TreeLevel
		from UserDeptBase uhk
	
		
	) as t

	inner join 
	(Select a.CompanyID,a.UserID, b.ManagerID ReportsToDimUserID
	From [edw].[Dim_User] a
	Join [edw].[Dim_Team] b
	On (a.DimTeamID = b.ID)) s
	on
		t.CompanyID = s.CompanyID AND t.JoinUserID = s.UserID  -- and t.UserID <> t.JoinUserID

	
	inner join (Select z.CompanyID,z.UserID,z.DimTeamID,z.ID, y.ManagerID ReportsToDimUserID,x.UserID ParentID
					From [edw].[Dim_User] z
					Join [edw].[Dim_Team] y
					On (z.CompanyID = y.CompanyID AND z.DimTeamID = y.ID)
					Join [edw].[Dim_User] x
					On z.CompanyID = x.CompanyID AND y.ManagerID = x.ID )s1
	on
		s.CompanyID = s1.CompanyID and s.ReportsToDimUserID = s1.ID ---and s.UserID <> s1.UserID

	inner join [EDW].[Dim_User] u
	on
		 t.CompanyID = u.CompanyID AND  t.UserId = u.UserID
	inner join UserList ul
	on
		t.CompanyID = ul.CompanyID  and t.JoinUserID = ul.Child

	left outer join ReportsToUserIdList rt
	on
		t.CompanyID = rt.CompanyID and t.JoinUserID = rt.UserID
	left outer join OnetoOneHierarchy rm
	on 
		t.CompanyID = rm.CompanyID and t.JoinUserID = rm.Parent


GO
/****** Object:  View [edw].[View_User_CustomFields_4444484]    Script Date: 9/10/2021 8:10:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444484] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444484
GO
/****** Object:  View [edw].[View_User_CustomFields_4444508]    Script Date: 9/10/2021 8:10:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444508] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444508
GO
/****** Object:  View [edw].[View_User_CustomFields_4444509]    Script Date: 9/10/2021 8:10:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444509] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444509
GO
/****** Object:  View [edw].[View_User_CustomFields_4444510]    Script Date: 9/10/2021 8:10:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444510] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444510
GO
/****** Object:  View [edw].[View_User_CustomFields_4444511]    Script Date: 9/10/2021 8:10:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444511] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444511
GO
/****** Object:  View [edw].[View_User_CustomFields_4444521]    Script Date: 9/10/2021 8:10:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444521] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444521
GO
/****** Object:  View [edw].[View_User_CustomFields_4444526]    Script Date: 9/10/2021 8:10:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444526] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444526
GO
/****** Object:  View [edw].[View_User_CustomFields_4444527]    Script Date: 9/10/2021 8:10:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444527] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444527
GO
/****** Object:  View [edw].[View_User_CustomFields_4444529]    Script Date: 9/10/2021 8:10:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444529] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444529
GO
/****** Object:  View [edw].[View_User_CustomFields_4444532]    Script Date: 9/10/2021 8:10:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444532] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444532
GO
/****** Object:  View [edw].[View_User_CustomFields_4444533]    Script Date: 9/10/2021 8:10:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444533] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444533
GO
/****** Object:  View [edw].[View_User_CustomFields_4444536]    Script Date: 9/10/2021 8:10:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444536] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444536
GO
/****** Object:  View [edw].[View_User_CustomFields_4444537]    Script Date: 9/10/2021 8:10:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444537] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444537
GO
/****** Object:  Table [arch].[Fact_TimeSlot]    Script Date: 9/10/2021 8:10:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [arch].[Fact_TimeSlot](
	[Dim_UserID] [int] NOT NULL,
	[Dim_CompanyID] [int] NOT NULL,
	[Dim_AppMasterID] [int] NULL,
	[Dim_ActivityCategoryID] [int] NOT NULL,
	[Dim_DeviceID] [int] NULL,
	[ActivityDate] [date] NOT NULL,
	[StartTimeInLocal]  AS (dateadd(minute,[TimeZoneOffset],[StartTimeInUTC])) PERSISTED,
	[EndTimeInLocal]  AS (dateadd(minute,[TimeZoneOffset],[EndTimeInUTC])) PERSISTED,
	[DeviceID] [int] NULL,
	[FileOrUrlName] [nvarchar](4000) NOT NULL,
	[IsFileOrUrl] [bit] NOT NULL,
	[PurposeID] [int] NOT NULL,
	[IsOnPc] [bit] NOT NULL,
	[IsShift] [bit] NOT NULL,
	[StartTimeInUTC] [datetime] NOT NULL,
	[EndTimeInUTC] [datetime] NOT NULL,
	[TimeZoneOffset] [smallint] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[TimeSpent] [real] NOT NULL,
	[UploadTime] [datetime] NOT NULL,
	[IsUserModified] [bit] NOT NULL,
	[ModifiedBy] [int] NULL,
	[Dim_WebAppID] [int] NULL,
	[Dim_MachineID] [int] NULL,
	[Dim_NetworkID] [int] NULL,
	[IsCore] [bit] NULL,
	[URLDomain] [nvarchar](200) NULL
) ON [psc_CompanyID]([Dim_CompanyID])
GO
/****** Object:  View [edw].[View_Fact_TimeSlot]    Script Date: 9/10/2021 8:10:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_Fact_TimeSlot] 
AS
	SELECT [Dim_UserID], [Dim_CompanyID], [Dim_AppMasterID], [Dim_ActivityCategoryID], [Dim_DeviceID], [ActivityDate], [StartTimeInLocal], [EndTimeInLocal], [DeviceID], [FileOrUrlName], [IsFileOrUrl], [PurposeID], [IsOnPc], [IsShift], [StartTimeInUTC], [EndTimeInUTC], [TimeZoneOffset], [IsActive], [TimeSpent], [UploadTime], [IsUserModified], [ModifiedBy], [Dim_WebAppID], [Dim_MachineID], [Dim_NetworkID], [IsCore], [URLDomain]
	FROM edw.Fact_TimeSlot
	UNION ALL
	SELECT [Dim_UserID], [Dim_CompanyID], [Dim_AppMasterID], [Dim_ActivityCategoryID], [Dim_DeviceID], [ActivityDate], [StartTimeInLocal], [EndTimeInLocal], [DeviceID], [FileOrUrlName], [IsFileOrUrl], [PurposeID], [IsOnPc], [IsShift], [StartTimeInUTC], [EndTimeInUTC], [TimeZoneOffset], [IsActive], [TimeSpent], [UploadTime], [IsUserModified], [ModifiedBy], [Dim_WebAppID], [Dim_MachineID], [Dim_NetworkID], [IsCore], [URLDomain]
	FROM arch.Fact_TimeSlot

GO
/****** Object:  View [edw].[View_User_CustomFields_4444538]    Script Date: 9/10/2021 8:10:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444538] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444538
GO
/****** Object:  View [edw].[View_User_CustomFields_4444539]    Script Date: 9/10/2021 8:10:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444539] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444539
GO
/****** Object:  View [edw].[View_User_CustomFields_4444540]    Script Date: 9/10/2021 8:10:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444540] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444540
GO
/****** Object:  View [edw].[View_User_CustomFields_4444541]    Script Date: 9/10/2021 8:10:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444541] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444541
GO
/****** Object:  View [edw].[View_User_CustomFields_4444542]    Script Date: 9/10/2021 8:10:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444542] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444542
GO
/****** Object:  View [edw].[View_User_CustomFields_4444543]    Script Date: 9/10/2021 8:10:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444543] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444543
GO
/****** Object:  View [edw].[View_User_CustomFields_4444544]    Script Date: 9/10/2021 8:10:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444544] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444544
GO
/****** Object:  View [edw].[View_User_CustomFields_4444545]    Script Date: 9/10/2021 8:10:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444545] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444545
GO
/****** Object:  View [edw].[View_User_CustomFields_4444546]    Script Date: 9/10/2021 8:10:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444546] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444546
GO
/****** Object:  View [edw].[View_User_CustomFields_4444547]    Script Date: 9/10/2021 8:10:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444547] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444547
GO
/****** Object:  View [edw].[View_User_CustomFields_4444548]    Script Date: 9/10/2021 8:10:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444548] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444548
GO
/****** Object:  View [edw].[View_User_CustomFields_4444550]    Script Date: 9/10/2021 8:10:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444550] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444550
GO
/****** Object:  View [edw].[View_User_CustomFields_4444551]    Script Date: 9/10/2021 8:10:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444551] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444551
GO
/****** Object:  View [edw].[View_User_CustomFields_4444552]    Script Date: 9/10/2021 8:10:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444552] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444552
GO
/****** Object:  View [edw].[View_User_CustomFields_4444553]    Script Date: 9/10/2021 8:10:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444553] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444553
GO
/****** Object:  View [edw].[View_User_CustomFields_4444554]    Script Date: 9/10/2021 8:10:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444554] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444554
GO
/****** Object:  View [edw].[View_User_CustomFields_4444555]    Script Date: 9/10/2021 8:10:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444555] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444555
GO
/****** Object:  View [edw].[View_IntegrationOpportunities]    Script Date: 9/10/2021 8:10:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_IntegrationOpportunities]
AS
	SELECT S.CompanyID, S.UserID, S.UniqueID
        ,[Id],[Name],[StageName],[AccountId],[AccountName],[CurrencyIsoCode],[Products],[Type],[Use_Case],[Mode_of_Deployment],[ForecastCategory],[ForecastCategoryName],[Amount],[TotalLicenses],[TotalContacts],[Converted_Amount],[Probability],[DateCreated],[DateClosed],[LastModifiedDate]
        FROM
        (
            SELECT CompanyID, UserId, UniqueId, [Id],[Name],[StageName],[AccountId],[AccountName],[CurrencyIsoCode],[Products],[Type],[Use_Case],[Mode_of_Deployment],[ForecastCategory],[ForecastCategoryName] from 
            (
                select CompanyID, UserId, UniqueId, StringValue, PropertyName
                from 
                (
                    SELECT
                        F.Dim_CompanyID CompanyID,
                        F.Dim_UserId UserId,
                        F.UniqueId,
                        I.PropertyName,
                        F.StringValue
                    FROM
                    edw.[Fact_Integration] F
                    INNER JOIN edw.Dim_IntegrationProperty I ON F.Dim_PropertyId=I.PropertyId
                    WHERE F.Dim_EntityId = 1 AND DataTypeID=1
                ) m
            ) x
            pivot 
            (
                max(StringValue)
                for PropertyName in ([Id],[Name],[StageName],[AccountId],[AccountName],[CurrencyIsoCode],[Products],[Type],[Use_Case],[Mode_of_Deployment],[ForecastCategory],[ForecastCategoryName])
            ) p 
        ) S
        
        LEFT OUTER JOIN             
        (
            SELECT CompanyID, UserId, UniqueId, [Amount],[TotalLicenses],[TotalContacts],[Converted_Amount],[Probability] from 
            (
                select CompanyID, UserId, UniqueId, NumericValue, PropertyName
                from 
                (
                    SELECT
                        F.Dim_CompanyID CompanyID,
                        F.Dim_UserId UserId,
                        F.UniqueId,
                        I.PropertyName,
                        F.NumericValue
                    FROM
                    edw.[Fact_Integration] F
                    INNER JOIN edw.Dim_IntegrationProperty I ON F.Dim_PropertyId=I.PropertyId
                    WHERE F.Dim_EntityId =  1  AND DataTypeID=2
                ) m
            ) x
            pivot 
            (
                max(NumericValue)
                for PropertyName in ([Amount],[TotalLicenses],[TotalContacts],[Converted_Amount],[Probability])
            ) p 
        ) N ON S.CompanyID=N.CompanyID AND S.UserID=N.UserID AND S.UniqueID=N.UniqueID
        
        LEFT OUTER JOIN
        (
            SELECT CompanyID, UserId, UniqueId, [DateCreated],[DateClosed],[LastModifiedDate] from 
            (
                select CompanyID, UserId, UniqueId, DateValue, PropertyName
                from 
                (
                    SELECT
                        F.Dim_CompanyID CompanyID,
                        F.Dim_UserId UserId,
                        F.UniqueId,
                        I.PropertyName,
                        F.DateValue
                    FROM
                    edw.[Fact_Integration] F
                    INNER JOIN edw.Dim_IntegrationProperty I ON F.Dim_PropertyId=I.PropertyId
                    WHERE F.Dim_EntityId =  1  AND DataTypeID=3
                ) m
            ) x
            pivot 
            (
                max(DateValue)
                for PropertyName in ([DateCreated],[DateClosed],[LastModifiedDate])
            ) p 
        ) D ON S.CompanyID=D.CompanyID AND S.UserID=D.UserID AND S.UniqueID=D.UniqueID

GO
/****** Object:  View [edw].[View_User_CustomFields_4444556]    Script Date: 9/10/2021 8:10:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444556] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444556
GO
/****** Object:  View [edw].[View_User_CustomFields_4444557]    Script Date: 9/10/2021 8:10:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444557] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444557
GO
/****** Object:  View [edw].[View_User_CustomFields_4444558]    Script Date: 9/10/2021 8:10:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444558] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444558
GO
/****** Object:  View [edw].[View_User_CustomFields_4444559]    Script Date: 9/10/2021 8:10:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444559] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444559
GO
/****** Object:  View [edw].[View_User_CustomFields_4444560]    Script Date: 9/10/2021 8:10:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444560] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444560
GO
/****** Object:  View [edw].[View_User_CustomFields_4444561]    Script Date: 9/10/2021 8:10:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444561] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444561
GO
/****** Object:  View [edw].[View_User_CustomFields_4444562]    Script Date: 9/10/2021 8:10:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444562] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444562
GO
/****** Object:  View [edw].[View_User_CustomFields_4444564]    Script Date: 9/10/2021 8:10:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444564] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444564
GO
/****** Object:  View [edw].[View_User_CustomFields_4444565]    Script Date: 9/10/2021 8:10:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444565] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444565
GO
/****** Object:  View [edw].[View_User_CustomFields_4444567]    Script Date: 9/10/2021 8:10:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444567] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444567
GO
/****** Object:  View [edw].[View_User_CustomFields_4444568]    Script Date: 9/10/2021 8:10:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444568] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444568
GO
/****** Object:  View [edw].[View_User_CustomFields_4444569]    Script Date: 9/10/2021 8:10:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444569] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444569
GO
/****** Object:  View [edw].[View_User_CustomFields_4444570]    Script Date: 9/10/2021 8:10:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444570] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444570
GO
/****** Object:  View [edw].[View_User_CustomFields_4444571]    Script Date: 9/10/2021 8:10:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444571] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444571
GO
/****** Object:  View [edw].[View_User_CustomFields_4444572]    Script Date: 9/10/2021 8:10:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444572] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444572
GO
/****** Object:  View [edw].[View_User_CustomFields_4444573]    Script Date: 9/10/2021 8:10:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444573] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444573
GO
/****** Object:  View [edw].[View_User_CustomFields_4444574]    Script Date: 9/10/2021 8:10:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444574] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444574
GO
/****** Object:  Table [history].[IntegrationCycleStatusHistory]    Script Date: 9/10/2021 8:10:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [history].[IntegrationCycleStatusHistory](
	[CycleStatusId] [int] NOT NULL,
	[CompanyId] [nvarchar](50) NOT NULL,
	[IntegrationSourceName] [nvarchar](50) NOT NULL,
	[StartTime] [datetimeoffset](7) NOT NULL,
	[EndTimeStamp] [datetimeoffset](7) NULL,
	[Status] [smallint] NOT NULL,
	[SysStartTimeUTC] [datetime2](7) NOT NULL,
	[SysEndTimeUTC] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[IntegrationCycleStatus]    Script Date: 9/10/2021 8:10:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[IntegrationCycleStatus](
	[CycleStatusId] [int] IDENTITY(1,1) NOT NULL,
	[CompanyId] [nvarchar](50) NOT NULL,
	[IntegrationSourceName] [nvarchar](50) NOT NULL,
	[StartTime] [datetimeoffset](7) NOT NULL,
	[EndTimeStamp] [datetimeoffset](7) NULL,
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
/****** Object:  View [edw].[View_User_CustomFields_4444575]    Script Date: 9/10/2021 8:10:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444575] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444575
GO
/****** Object:  View [edw].[View_User_CustomFields_4444576]    Script Date: 9/10/2021 8:10:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444576] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444576
GO
/****** Object:  View [edw].[View_User_CustomFields_4444581]    Script Date: 9/10/2021 8:10:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444581] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444581
GO
/****** Object:  View [edw].[View_User_CustomFields_4444582]    Script Date: 9/10/2021 8:10:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444582] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444582
GO
/****** Object:  View [edw].[View_User_CustomFields_4444583]    Script Date: 9/10/2021 8:10:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444583] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444583
GO
/****** Object:  View [edw].[View_User_CustomFields_4444584]    Script Date: 9/10/2021 8:10:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444584] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444584
GO
/****** Object:  View [edw].[View_User_CustomFields_4444589]    Script Date: 9/10/2021 8:10:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444589] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444589
GO
/****** Object:  View [edw].[View_User_CustomFields_4444590]    Script Date: 9/10/2021 8:10:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444590] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444590
GO
/****** Object:  Table [edw].[Dim_JobFamilyProfile]    Script Date: 9/10/2021 8:10:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Dim_JobFamilyProfile](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CompanyID] [int] NOT NULL,
	[JobFamilyProfileID] [int] NOT NULL,
	[JobFamilyName] [nvarchar](100) NOT NULL,
	[JobGradeLevel] [nvarchar](50) NULL,
	[JobFamilyDescription] [nvarchar](200) NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [pk_JobFamilyProfile] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[CompanyID] ASC,
	[JobFamilyProfileID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Fact_UserDataSyncInfo]    Script Date: 9/10/2021 8:10:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Fact_UserDataSyncInfo](
	[Dim_CompanyID] [int] NOT NULL,
	[Dim_UserId] [int] NOT NULL,
	[Dim_MachineID] [int] NOT NULL,
	[LastDataSyncTime] [datetime] NULL,
	[LastHeartBeatTime] [datetime] NULL,
	[LeafVersion] [nvarchar](1000) NULL,
	[LensVersion] [nvarchar](1000) NULL,
	[MeetingAddinStatus] [tinyint] NULL,
 CONSTRAINT [PK_Fact_UserDataSyncInfo] PRIMARY KEY CLUSTERED 
(
	[Dim_CompanyID] ASC,
	[Dim_UserId] ASC,
	[Dim_MachineID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Dim_Location]    Script Date: 9/10/2021 8:10:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Dim_Location](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CompanyID] [int] NOT NULL,
	[LocationID] [int] NOT NULL,
	[LocationName] [nvarchar](512) NOT NULL,
	[Country] [nvarchar](512) NULL,
	[City] [nvarchar](200) NULL,
	[CurrentTimestamp] [timestamp] NOT NULL,
	[Statoid] [nvarchar](100) NULL,
	[LocationExtra] [nvarchar](200) NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [pk_Location] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [uc_Location] UNIQUE NONCLUSTERED 
(
	[CompanyID] ASC,
	[LocationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[CompanyID] ASC,
	[LocationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Dim_Machine]    Script Date: 9/10/2021 8:10:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Dim_Machine](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CompanyID] [int] NOT NULL,
	[MachineName] [nvarchar](255) NOT NULL,
	[CreatedDate] [smalldatetime] NOT NULL,
 CONSTRAINT [pk_Machine] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [uc_Machine] UNIQUE NONCLUSTERED 
(
	[CompanyID] ASC,
	[MachineName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [edw].[View_UserSyncTest]    Script Date: 9/10/2021 8:10:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   VIEW [edw].[View_UserSyncTest]
AS

SELECT 
Worker.CompanyID,
Worker.UserID,
Worker.UserEmail,
Worker.FirstName + ' ' + Worker.LastName as 'Worker', 
CASE WHEN Worker.IsActivityCollectionOn = 1 THEN 'ON' ELSE 'OFF' END AS 'Activity Collection',
Worker.DateCreated AS 'Date User was added',
Worker.JobTitle,
Worker.IsFullTimeEmployee,
Worker.IsActive,
Manager.FirstName + ' '+Manager.LastName as 'Manager',
Dept.DepartmentName AS 'Department',
Loc.LocationName AS 'Location',
JobFamilyProf.JobFamilyName AS 'JobFamily',
Team.TeamName as 'Team',
CAST(Machine.MachineName AS varchar(30)) AS 'Machine Name',
UserDataSync.LastDataSyncTime,
UserDataSync.LastHeartBeatTime,
CAST(DateDiff(hh, UserDataSync.LastDataSyncTime, getdate()) AS NUMERIC(10, 2)) as 'UnSyncDurationInHrs',
CASE 
	WHEN UserDataSync.LastDataSyncTime IS NULL THEN 'Never Synced'
	WHEN CAST(DateDiff(hh, UserDataSync.LastDataSyncTime, getdate()) AS NUMERIC(10, 2))<=48 THEN 'Sync in last 2 days'
	WHEN CAST(DateDiff(hh, UserDataSync.LastDataSyncTime, getdate()) AS NUMERIC(10, 2)) <=168 THEN 'Last sync between 3 to 7 days'	
	WHEN CAST(DateDiff(hh, UserDataSync.LastDataSyncTime, getdate()) AS NUMERIC(10, 2)) <=360 THEN 'Last sync between 8 to 15 days'	
	WHEN CAST(DateDiff(hh, UserDataSync.LastDataSyncTime, getdate()) AS NUMERIC(10, 2)) >360 THEN 'Last sync 15+ days ago'
END AS 'UserSyncStatus',
CASE
    WHEN UserDataSync.LastDataSyncTime IS NULL THEN 'Never Synced'
    WHEN CAST(DateDiff(hh, UserDataSync.LastDataSyncTime, getdate()) AS NUMERIC(10, 2))<=48 THEN '0 - 2 days ago'
    WHEN CAST(DateDiff(hh, UserDataSync.LastDataSyncTime, getdate()) AS NUMERIC(10, 2)) <=168 THEN '3 - 7 days ago'   
    WHEN CAST(DateDiff(hh, UserDataSync.LastDataSyncTime, getdate()) AS NUMERIC(10, 2)) <=360 THEN '8 - 15 days ago'   
    WHEN CAST(DateDiff(hh, UserDataSync.LastDataSyncTime, getdate()) AS NUMERIC(10, 2)) >360 THEN '15+ days ago'
END AS 'Last Successful Sync',
CASE
    WHEN UserDataSync.LastDataSyncTime IS NULL THEN 1
ELSE  ROW_NUMBER() OVER (PARTITION BY UserDataSync.Dim_CompanyID,UserDataSync.Dim_UserID ORDER BY UserDataSync.LastDataSyncTime desc) 
END AS LastSyncRank

FROM [edw].[Dim_User] AS Worker 
LEFT OUTER JOIN [edw].[Fact_UserDataSyncInfo] AS UserDataSync ON Worker.CompanyID = UserDataSync.Dim_CompanyID and Worker.ID = UserDataSync.Dim_UserId
LEFT OUTER JOIN[edw].[Dim_Location] AS Loc on Loc.CompanyID =Worker.CompanyID and Loc.ID =Worker.Dim_LocationID
LEFT OUTER JOIN [edw].[Dim_JobFamilyProfile] AS JobFamilyProf ON JobFamilyProf.CompanyID = Worker.CompanyID and JobFamilyProf.ID = Worker.Dim_JobFamilyProfileID
LEFT OUTER JOIN [edw].[Dim_Department] AS Dept ON Dept.CompanyID = Worker.CompanyID and Dept.ID = Worker.Dim_DepartmentID
LEFT OUTER JOIN [edw].[Dim_Team] AS Team ON Team.CompanyID = Worker.CompanyID and Team.ID= Worker.DimTeamID
LEFT OUTER JOIN [edw].[Dim_User] AS Manager ON Manager.CompanyID = Team.CompanyID and Manager.ID = Team.ManagerID
LEFT OUTER JOIN [edw].[Dim_Machine] AS Machine ON Machine.CompanyID = UserDataSync.Dim_CompanyID and  Machine.ID = UserDataSync.Dim_MachineID
Where Worker.IsActive = 1 
GO
/****** Object:  Table [edw].[Stg_Lenses]    Script Date: 9/10/2021 8:10:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Stg_Lenses](
	[TenantID] [int] NULL,
	[LineofBusinessID] [int] NULL,
	[sessionId] [nvarchar](50) NULL,
	[tzoffset] [nvarchar](5) NULL,
	[productVersion] [nvarchar](256) NULL,
	[fileDescription] [nvarchar](500) NULL,
	[exeName] [nvarchar](500) NULL,
	[activityDomain] [nvarchar](100) NULL,
	[activityUserID] [nvarchar](200) NULL,
	[deviceId] [nvarchar](200) NULL,
	[windowTitle] [nvarchar](1000) NULL,
	[url] [nvarchar](1000) NULL,
	[activityTime] [datetime] NULL,
	[activityType] [nvarchar](20) NULL,
	[meetingID] [nvarchar](500) NULL,
	[meetingSubject] [nvarchar](300) NULL,
	[meetingStart] [datetime] NULL,
	[meetingEnd] [datetime] NULL,
	[meetingDuration] [smallint] NULL,
	[meetingActivityVersion] [nvarchar](100) NULL,
	[meetingBusyStatus] [nvarchar](100) NULL,
	[meetingResponseStatus] [nvarchar](100) NULL,
	[meetingSensitivity] [nvarchar](100) NULL,
	[meetingStatus] [nvarchar](100) NULL,
	[offset] [bigint] NULL,
	[machineName] [nvarchar](400) NULL,
	[networkname] [nvarchar](400) NULL,
	[keyboardHardEvents] [smallint] NULL,
	[keyboardSoftEvents] [smallint] NULL,
	[mouseHardEvents] [smallint] NULL,
	[mouseSoftEvents] [smallint] NULL,
	[meetingRecipients] [nvarchar](4000) NULL
) ON [PRIMARY]
GO
/****** Object:  View [edw].[View_Stg_Lenses_Exe]    Script Date: 9/10/2021 8:10:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_Stg_Lenses_Exe] 
AS

/**
NOTE: gets distinct exeName, two versions the backslash versions for windows (c:\program files\teams.exe) and the forward slash version for Mac (/Applications/Microsoft Teams.app)
**/

SELECT DISTINCT LineofBusinessID, TenantID, RIGHT(exeName, CHARINDEX('\', REVERSE(exeName)) - 1) exeName, 
CASE WHEN fileDescription IS NULL OR fileDescription ='' THEN
		RIGHT(exeName, CHARINDEX('\', REVERSE(exeName)) - 1)
		ELSE fileDescription
END fileDescription, 
COALESCE(productVersion,'') productVersion
FROM edw.Stg_Lenses
WHERE activityType='Application' AND CHARINDEX('\', exeName) > 0
UNION ---------------------------------------------------------------------------
SELECT DISTINCT LineofBusinessID, TenantID, RIGHT(exeName, CHARINDEX('/', REVERSE(exeName)) - 1) exeName, 
CASE WHEN fileDescription IS NULL OR fileDescription ='' THEN
		RIGHT(exeName, CHARINDEX('/', REVERSE(exeName)) - 1)
		ELSE fileDescription
END fileDescription, 
COALESCE(productVersion,'') productVersion
FROM edw.Stg_Lenses
WHERE activityType='Application' AND CHARINDEX('/', exeName) > 0


GO
/****** Object:  View [edw].[View_User_CustomFields_4444592]    Script Date: 9/10/2021 8:10:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444592] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444592
GO
/****** Object:  View [edw].[View_User_CustomFields_4444593]    Script Date: 9/10/2021 8:10:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444593] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444593
GO
/****** Object:  Table [edw].[Dim_Vendor]    Script Date: 9/10/2021 8:10:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Dim_Vendor](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CompanyID] [int] NOT NULL,
	[VendorID] [int] NOT NULL,
	[VendorName] [nvarchar](256) NOT NULL,
	[VendorContact] [nvarchar](512) NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [pk_Vendor] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[CompanyID] ASC,
	[VendorID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Dim_WebApp]    Script Date: 9/10/2021 8:10:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Dim_WebApp](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CompanyID] [int] NOT NULL,
	[WebAppID] [int] NOT NULL,
	[Dim_ActivityCategoryID] [int] NULL,
	[WebAppName] [nvarchar](200) NOT NULL,
	[WebAppDisplayName] [nvarchar](200) NOT NULL,
	[WebAppUrl] [nvarchar](300) NOT NULL,
	[WebAppVersion] [nvarchar](50) NULL,
	[WebAppDescription] [nvarchar](512) NULL,
	[UrlMatchStrategy] [int] NULL,
	[UrlMatchContent] [nvarchar](200) NULL,
	[IsSystemDiscovered] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [pk_WebApp] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[CompanyID] ASC,
	[WebAppID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [edw].[View_UserDailyActivity]    Script Date: 9/10/2021 8:10:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  View [edw].[View_UserDailyActivity]    Script Date: 2020/09/28 17:10:29 ******/



CREATE   VIEW [edw].[View_UserDailyActivity] 
--CREATE VIEW [edw].[View_UserDailyActivity] 
AS

select 
    u.CompanyID,
	 u.UserID,
     u.UserEmail,
	 (u.FirstName + ' ' + u.LastName) as UserFullName,
	  mgr.UserEmail as ManagerEmail,
	 (mgr.FirstName + ' ' + mgr.LastName) as ManagerFullName,
	 loc.LocationName as [Location],
	 d.DepartmentName as [Department],
	 v.VendorName as [Vendor],
	 jf.JobFamilyName as [JobFamily],
	 t.TeamName as [Team],
	 app.ExeName,
	 app.AppName,
	 app.IsApplication,
	 app.AppVersion as Version,
	 webapp.WebAppName,
	 webapp.WebAppDisplayName,
	 webapp.WebAppUrl,
	 webapp.WebAppVersion,
	 act.ActivityCategoryName,
	 act.ActivityCategoryId,
	 act.IsCore,
	 act.IsWorkCategory,
     f.ActivityDate,
	 f.FileOrUrlID,
	 f.IsFileOrUrl,
	 f.PurposeID,
	 f.TimeSpentInCalendarDay,
	 f.TimeSpentInShift,
	 f.IsOnPc
from  edw.Fact_DailyActivity f
	left join edw.Dim_User u  on u.CompanyID = f.Dim_CompanyID  and u.ID = f.Dim_UserId
	left join edw.Dim_Team t on t.CompanyID = f.Dim_CompanyID and t.ID = u.DimTeamID
	left join edw.Dim_User mgr  on u.CompanyID = f.Dim_CompanyID  and mgr.ID = t.ManagerID
	--left join edw.Dim_Location loc on loc.CompanyID = f.Dim_CompanyID and loc.LocationID = u.Dim_LocationID
	--left join edw.Dim_Department d on d.CompanyID = f.Dim_CompanyID and d.DepartmentID = u.Dim_DepartmentID
	left join edw.Dim_Location loc on loc.CompanyID = f.Dim_CompanyID and loc.ID = u.Dim_LocationID
	left join edw.Dim_Department d on d.CompanyID = f.Dim_CompanyID and d.ID = u.Dim_DepartmentID
	left join edw.Dim_Vendor v on v.CompanyID = f.Dim_CompanyID and v.ID = u.Dim_VendorID
	left join edw.Dim_JobFamilyProfile jf on jf.CompanyID = f.Dim_CompanyID and jf.ID = u.Dim_JobFamilyProfileID
	left join edw.Dim_AppMaster app on app.CompanyID = f.Dim_CompanyID and app.ID = f.Dim_AppMasterID
	left join edw.Dim_WebApp webapp on webapp.CompanyID = f.Dim_CompanyID and webapp.ID = f.Dim_WebAppID
	left join edw.Dim_ActivityCategory act on act.CompanyID = f.Dim_CompanyID and act.ID = f.Dim_ActivityCategoryID


	/*

	use edw
	select * from edw.Dim_Team

	select * from [edw].[View_UserDailyActivity] 
	where companyId = 1 and useremail like 'robert%'  and ActivityCategoryID = 5  and IsOnPC = 0

		select * from [edw].[View_UserDailyActivity] 
		where FileOrUrlName like '%sales%'
	
	 like '%meet%'

	select * from [edw].[View_UserDailyActivity] 
	where companyId = 1 and useremail like 'robert%' and activitydate > '2020-07-23'

	select * from [edw].[View_UserDailyActivity] 
	where companyId = 1 
	and useremail like 'robert%' 
	and activitydate > '2020-07-23'
	and ActivityCategoryName = 'Development'
	*/
GO
/****** Object:  View [edw].[View_User_CustomFields_4444595]    Script Date: 9/10/2021 8:10:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444595] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444595
GO
/****** Object:  View [edw].[View_UserTimeSlot]    Script Date: 9/10/2021 8:10:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_UserTimeSlot] 
AS

select 
     u.CompanyID,
       u.ID,
       u.UserID,
     u.UserEmail,
       (u.FirstName + ' ' + u.LastName) as UserFullName,
         mgr.UserEmail as ManagerEmail,
       (mgr.FirstName + ' ' + mgr.LastName) as ManagerFullName,
         loc.LocationName as [Location],
       d.DepartmentName as [Department],
       v.VendorName as [Vendor],
       jf.JobFamilyName as [JobFamily],
       t.TeamName as [Team],
       app.ExeName,
       app.AppName,
       app.IsApplication,
       app.AppVersion as Version,
       webapp.WebAppName,
       webapp.WebAppDisplayName,
       webapp.WebAppUrl,
       webapp.WebAppVersion,
       act.ActivityCategoryID,
       act.ActivityCategoryName,
       act.IsCore,
       act.IsWorkCategory,
       f.ActivityDate,
       f.FileOrUrlName,
       f.StartTimeInLocal,
       f.EndTimeInLocal,
       f.StartTimeInUTC,
       f.EndTimeInUTC,
       f.TimeZoneOffset,
       f.IsOnPc,
       f.PurposeID,
       f.IsActive,
       f.TimeSpent,
         -- Overrides can change activity on app or url.  So we need this to be able to uniquely identity
         -- and aggregate time spent 
        case
              when act.ActivityCategoryID = -1 and f.PurposeId = -1 then 'Private'
              else 
                 case 
                     when app.AppName is not null then (app.AppName + ' - ' + act.ActivityCategoryName)
                     else (f.FileOrUrlName + ' - ' + act.ActivityCategoryName)
                 end
       end as UniqueName
from  edw.View_Fact_TimeSlot f
       left join edw.Dim_User u  on u.CompanyID = f.Dim_CompanyID  and u.ID = f.Dim_UserId
       left join edw.Dim_Team t on t.CompanyID = f.Dim_CompanyID and t.ID = u.DimTeamID
       left join edw.Dim_User mgr  on u.CompanyID = f.Dim_CompanyID  and mgr.ID = t.ManagerID
       left join edw.Dim_Location loc on loc.CompanyID = f.Dim_CompanyID and loc.ID = u.Dim_LocationID
       left join edw.Dim_Department d on d.CompanyID = f.Dim_CompanyID and d.ID = u.Dim_DepartmentID
       left join edw.Dim_Vendor v on v.CompanyID = f.Dim_CompanyID and v.ID = u.Dim_VendorID
       left join edw.Dim_JobFamilyProfile jf on jf.CompanyID = f.Dim_CompanyID and jf.ID = u.Dim_JobFamilyProfileID
       left join edw.Dim_AppMaster app on app.CompanyID = f.Dim_CompanyID and app.ID = f.Dim_AppMasterID
       left join edw.Dim_WebApp webapp on webapp.CompanyID = f.Dim_CompanyID and webapp.ID = f.Dim_WebAppID
       left join edw.Dim_ActivityCategory act on act.CompanyID = f.Dim_CompanyID and act.ID = f.Dim_ActivityCategoryID

GO
/****** Object:  View [edw].[View_User_CustomFields_4444596]    Script Date: 9/10/2021 8:10:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444596] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444596
GO
/****** Object:  View [edw].[View_User_CustomFields_4444597]    Script Date: 9/10/2021 8:10:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444597] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444597
GO
/****** Object:  View [edw].[View_UserSync]    Script Date: 9/10/2021 8:10:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_UserSync]
AS

SELECT 
Worker.CompanyID,
Worker.UserID,
Worker.UserEmail,
Worker.FirstName + ' ' + Worker.LastName as 'Worker', 
CASE WHEN Worker.IsActivityCollectionOn = 1 THEN 'ON' ELSE 'OFF' END AS 'Activity Collection',
Worker.DateCreated AS 'Date User was added',
Worker.JobTitle,
Worker.IsFullTimeEmployee,
Worker.IsActive,
Manager.FirstName + ' '+Manager.LastName as 'Manager',
Dept.DepartmentName AS 'Department',
Loc.LocationName AS 'Location',
JobFamilyProf.JobFamilyName AS 'JobFamily',
Team.TeamName as 'Team',
CAST(Machine.MachineName AS varchar(30)) AS 'Machine Name',
UserDataSync.LastDataSyncTime,
UserDataSync.LastHeartBeatTime,
CAST(DateDiff(hh, UserDataSync.LastDataSyncTime, getdate()) AS NUMERIC(10, 2)) as 'UnSyncDurationInHrs',
CASE 
	WHEN UserDataSync.LastDataSyncTime IS NULL THEN 'Never Synced'
	WHEN CAST(DateDiff(hh, UserDataSync.LastDataSyncTime, getdate()) AS NUMERIC(10, 2))<=48 THEN 'Sync in last 2 days'
	WHEN CAST(DateDiff(hh, UserDataSync.LastDataSyncTime, getdate()) AS NUMERIC(10, 2)) <=168 THEN 'Last sync between 3 to 7 days'	
	WHEN CAST(DateDiff(hh, UserDataSync.LastDataSyncTime, getdate()) AS NUMERIC(10, 2)) <=360 THEN 'Last sync between 8 to 15 days'	
	WHEN CAST(DateDiff(hh, UserDataSync.LastDataSyncTime, getdate()) AS NUMERIC(10, 2)) >360 THEN 'Last sync 15+ days ago'
END AS 'UserSyncStatus',
CASE
    WHEN UserDataSync.LastDataSyncTime IS NULL THEN 'Never Synced'
    WHEN CAST(DateDiff(hh, UserDataSync.LastDataSyncTime, getdate()) AS NUMERIC(10, 2))<=48 THEN '0 - 2 days ago'
    WHEN CAST(DateDiff(hh, UserDataSync.LastDataSyncTime, getdate()) AS NUMERIC(10, 2)) <=168 THEN '3 - 7 days ago'   
    WHEN CAST(DateDiff(hh, UserDataSync.LastDataSyncTime, getdate()) AS NUMERIC(10, 2)) <=360 THEN '8 - 15 days ago'   
    WHEN CAST(DateDiff(hh, UserDataSync.LastDataSyncTime, getdate()) AS NUMERIC(10, 2)) >360 THEN '15+ days ago'
END AS 'Last Successful Sync',
CASE
    WHEN UserDataSync.LastDataSyncTime IS NULL THEN 1
ELSE  ROW_NUMBER() OVER (PARTITION BY UserDataSync.Dim_CompanyID,UserDataSync.Dim_UserID ORDER BY UserDataSync.LastDataSyncTime desc) 
END AS LastSyncRank

FROM [edw].[Dim_User] AS Worker 
LEFT OUTER JOIN [edw].[Fact_UserDataSyncInfo] AS UserDataSync ON Worker.CompanyID = UserDataSync.Dim_CompanyID and Worker.ID = UserDataSync.Dim_UserId
LEFT OUTER JOIN[edw].[Dim_Location] AS Loc on Loc.CompanyID =Worker.CompanyID and Loc.ID =Worker.Dim_LocationID
LEFT OUTER JOIN [edw].[Dim_JobFamilyProfile] AS JobFamilyProf ON JobFamilyProf.CompanyID = Worker.CompanyID and JobFamilyProf.ID = Worker.Dim_JobFamilyProfileID
LEFT OUTER JOIN [edw].[Dim_Department] AS Dept ON Dept.CompanyID = Worker.CompanyID and Dept.ID = Worker.Dim_DepartmentID
LEFT OUTER JOIN [edw].[Dim_Team] AS Team ON Team.CompanyID = Worker.CompanyID and Team.ID= Worker.DimTeamID
LEFT OUTER JOIN [edw].[Dim_User] AS Manager ON Manager.CompanyID = Team.CompanyID and Manager.ID = Team.ManagerID
LEFT OUTER JOIN [edw].[Dim_Machine] AS Machine ON Machine.CompanyID = UserDataSync.Dim_CompanyID and  Machine.ID = UserDataSync.Dim_MachineID
Where Worker.IsActive = 1




GO
/****** Object:  View [edw].[View_User_CustomFields_4444598]    Script Date: 9/10/2021 8:10:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444598] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444598
GO
/****** Object:  View [edw].[View_User_CustomFields_4444599]    Script Date: 9/10/2021 8:10:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444599] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444599
GO
/****** Object:  View [edw].[View_User_CustomFields_4444601]    Script Date: 9/10/2021 8:10:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444601] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444601
GO
/****** Object:  Table [edw].[TestFlywayHistory]    Script Date: 9/10/2021 8:10:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[TestFlywayHistory](
	[TestID] [int] NOT NULL,
	[TestData] [nvarchar](100) NOT NULL,
	[TestValue] [int] NOT NULL,
	[SysStartTimeUTC] [datetime2](7) NOT NULL,
	[SysEndTimeUTC] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[TestFlyway]    Script Date: 9/10/2021 8:10:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[TestFlyway](
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
SYSTEM_VERSIONING = ON ( HISTORY_TABLE = [edw].[TestFlywayHistory] )
)
GO
/****** Object:  View [edw].[View_TestFlyway]    Script Date: 9/10/2021 8:10:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_TestFlyway]
AS 

	select s.*
	from [edw].TestFlyway s 
  

GO
/****** Object:  View [edw].[View_User_CustomFields_4444602]    Script Date: 9/10/2021 8:10:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444602] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444602
GO
/****** Object:  View [edw].[View_User_CustomFields_4444604]    Script Date: 9/10/2021 8:10:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444604] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444604
GO
/****** Object:  View [edw].[View_User_CustomFields_4444605]    Script Date: 9/10/2021 8:10:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444605] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444605
GO
/****** Object:  View [edw].[View_User_CustomFields_4444606]    Script Date: 9/10/2021 8:10:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444606] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444606
GO
/****** Object:  View [edw].[View_Dim_AppMaster_Exe]    Script Date: 9/10/2021 8:10:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  View [edw].[View_Dim_AppMaster_Exe]    Script Date: 2020/07/24 20:20:50 ******/

CREATE   VIEW [edw].[View_Dim_AppMaster_Exe] 
AS

SELECT CompanyID, ExeName, MAX(AppName) AppName 
FROM edw.Dim_AppMaster
WHERE Dim_AppParentID IS NULL AND RIGHT(ExeName,4) IN ('.exe', '.app')
GROUP BY CompanyID, ExeName
GO
/****** Object:  View [edw].[View_User_CustomFields_4444608]    Script Date: 9/10/2021 8:10:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444608] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444608
GO
/****** Object:  View [edw].[View_User_CustomFields_4444636]    Script Date: 9/10/2021 8:10:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444636] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444636
GO
/****** Object:  View [edw].[View_UserTree]    Script Date: 9/10/2021 8:10:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_UserTree] 
AS

	with ReportsToUserIdList as
	(
		select distinct h.CompanyID, h1.UserID UserID  --1 IsUserDataManagerInCompany
		from 
				(Select a.CompanyID, b.ManagerID ReportsToDimUserID
				From [edw].[Dim_User] a
				Join [edw].[Dim_Team] b
				On (a.DimTeamID = b.ID)) h
		inner join [edw].[Dim_User] h1
		on
			h.CompanyID = h1.CompanyID and h.ReportsToDimUserID = h1.ID and h1.IsActive = 1
	)



	, UserList as
	
		(
			select k.CompanyID, k1.UserID Parent, k.UserID Child, '' DepartmentIds
			from 
					(Select a.CompanyID,a.UserID, b.ManagerID ReportsToDimUserID
					From [edw].[Dim_User] a
					Join [edw].[Dim_Team] b
					On (a.DimTeamID = b.ID)) k
			inner join [edw].[Dim_User] k1
			on
				k.CompanyID = k1.CompanyID and k.ReportsToDimUserID = k1.ID and k1.IsActive = 1
			
	
		)

	

		, UserDept as
	
	(
			Select k.CompanyID, k.UserID, k1.Userid as DepartmentUserID, k2.Userid as ReportsToUserID 
	From 
	(Select a.CompanyID, a.UserID, c.ManagerDimUserID DepartmentUserID , b.ManagerID  as ReportsToUserID, a.IsActive
	From [edw].[Dim_User] a
		Join [edw].[Dim_Team] b
		On (a.DimTeamID = b.ID)
	INNER JOIN [edw].[Dim_Department] c
	ON (a.CompanyID = c.CompanyID AND a.Dim_DepartmentID = c.ID))k
	JOIN [edw].[Dim_User] k1
	on
		k.CompanyID = k1.CompanyID and k.DepartmentUserID = k1.ID
	JOIN [edw].[Dim_User] k2
	on
		k.CompanyID = k2.CompanyID and k.ReportsToUserID = k2.ID
	Where k.UserID <> k1.Userid and k.IsActive = 1
	)
		

	, UserHierarchy as (
	
			select s.CompanyID, Parent UserID, Child JoinUserID, 1 as TreeLevel
			from UserList s
			where
				s.Parent <> s.Child
			
			union all

			select d.CompanyID, d.UserID, s.Child, d.TreeLevel + 1
			from UserHierarchy as d
			inner join UserList s 
			on
				d.CompanyID = s.CompanyID and d.JoinUserID = s.Parent
			where
				s.Parent <> s.Child

		)

		---, OnetoOneHierarchy as 
		---(
		---Select CompanyID, Parent, string_agg(cast(Child as nvarchar(MAX)),'-') Hierarchy from UserList
		---Where parent <> child group by CompanyID, Parent
		---)

		, OnetoOneHierarchy as 
		(
		Select CompanyID, UserID Parent, string_agg(cast(JoinUserID as nvarchar(MAX)),'-') Hierarchy from UserHierarchy
		Where UserID <> JoinUserID group by CompanyID, UserID
		)

	------	Select * from UserHierarchy


	, UserDeptBase as (
	select * from UserDept f
	where not exists (
		select 1 from UserHierarchy l where f.CompanyID = l.CompanyID and f.DepartmentUserID = l.UserID and f.UserID = l.JoinUserID)
	)



	select t.CompanyID, u.UserEmail UserEmail, t.UserID, t.JoinUserID, s1.UserID ManagerID,t.TreeLevel,
	 convert(bit, IsNull(rt.UserID, 0))  IsJoinUserIdManagerInCompany, ul.DepartmentIds,
	  CASE WHEN s1.ParentID=t.UserID THEN 1 ELSE 0 END as IsManagerIDDirectReportee,
	  case When t.TreeLevel > 0 THEN Replace(CONCAT('-',t.JoinUserID,'-',rm.Hierarchy,'-'),'--','-') else Concat('-',t.JoinUserID,'-') end as Hierarchy

	from 
	(	
		select u.CompanyID, u.UserID UserID, u.UserID JoinUserID, -1 TreeLevel
		from [EDW].[Dim_User] u Where IsActive = 1
		
		
		union all

		select uh.CompanyID, uh.UserID, uh.JoinUserID, uh.TreeLevel 
		from UserHierarchy uh
	--	option (maxrecursion 1000)
		

		union all

		select uhk.CompanyID, uhk.DepartmentUserID, uhk.UserID , -100 TreeLevel
		from UserDeptBase uhk
	
		
	) as t

	inner join 
	(Select a.CompanyID,a.UserID, b.ManagerID ReportsToDimUserID
	From [edw].[Dim_User] a
	Join [edw].[Dim_Team] b
	On (a.DimTeamID = b.ID)) s
	on
		t.CompanyID = s.CompanyID AND t.JoinUserID = s.UserID  -- and t.UserID <> t.JoinUserID

	
	inner join (Select z.CompanyID,z.UserID,z.DimTeamID,z.ID, y.ManagerID ReportsToDimUserID,x.UserID ParentID
					From [edw].[Dim_User] z
					Join [edw].[Dim_Team] y
					On (z.CompanyID = y.CompanyID AND z.DimTeamID = y.ID)
					Join [edw].[Dim_User] x
					On z.CompanyID = x.CompanyID AND y.ManagerID = x.ID )s1
	on
		s.CompanyID = s1.CompanyID and s.ReportsToDimUserID = s1.ID ---and s.UserID <> s1.UserID

	inner join [EDW].[Dim_User] u
	on
		 t.CompanyID = u.CompanyID AND  t.UserId = u.UserID
	inner join UserList ul
	on
		t.CompanyID = ul.CompanyID  and t.JoinUserID = ul.Child

	left outer join ReportsToUserIdList rt
	on
		t.CompanyID = rt.CompanyID and t.JoinUserID = rt.UserID
	left outer join OnetoOneHierarchy rm
	on 
		t.CompanyID = rm.CompanyID and t.JoinUserID = rm.Parent



GO
/****** Object:  View [edw].[View_User_CustomFields_4444637]    Script Date: 9/10/2021 8:10:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444637] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444637
GO
/****** Object:  View [edw].[View_ManagerDeptTree]    Script Date: 9/10/2021 8:10:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_ManagerDeptTree]
AS


WITH UserHierarchy AS 
	(
		SELECT a.CompanyID, b.ManagerID Parent, a.ID Child, 1 AS TreeLevel
		FROM [edw].[Dim_User] a
		Join [edw].[Dim_Team] b
		On (a.DimTeamID = b.ID)
		WHERE a.ID <> b.ManagerID

		UNION ALL

		SELECT d.CompanyID, d.Parent, s.UserID, d.TreeLevel + 1
		FROM UserHierarchy as d
		JOIN 
		(
		SELECT a.CompanyID, a.ID as UserID, b.ManagerID ReportsToUserID, 1 AS TreeLevel
		FROM [edw].[Dim_User] a
		Join [edw].[Dim_Team] b
		On (a.DimTeamID = b.ID)
		) s
		 ON d.Child = s.ReportsToUserID
		WHERE d.CompanyID = s.CompanyID and s.UserID <> s.ReportsToUserID
	)




	SELECT CompanyID, Parent ManagerUserID, DepartmentID, DepartmentCode, DepartmentName 
	FROM
	(
		SELECT DISTINCT cte.CompanyID, cte.Parent, d.DepartmentID, 
		case when d.DepartmentCode is null then d.DepartmentName else d.DepartmentCode end as DepartmentCode,
		d.DepartmentName from UserHierarchy cte
		JOIN [edw].[Dim_User] dh ON cte.Child = dh.ID
		JOIN [edw].[Dim_Department] d ON dh.CompanyID = d.CompanyID AND dh.Dim_DepartmentID = d.ID
		----WHERE dh.StartDate < GETDATE() AND COALESCE(dh.EndDate,GETDATE()) >= GETDATE()

		UNION		

		SELECT DISTINCT dh.CompanyID, dh.ID parent, d.DepartmentID,
		case when d.DepartmentCode is null then d.DepartmentName else d.DepartmentCode end as DepartmentCode,
		d.DepartmentName 
		FROM [edw].[Dim_User] dh
		JOIN [edw].[Dim_Department] d ON dh.CompanyID = d.CompanyID AND dh.Dim_DepartmentID = d.ID
		----WHERE dh.StartDate < GETDATE() AND COALESCE(dh.EndDate,GETDATE()) >= GETDATE()
	) results


GO
/****** Object:  View [edw].[View_User_CustomFields_4444638]    Script Date: 9/10/2021 8:10:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444638] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444638
GO
/****** Object:  View [edw].[View_User_CustomFields_4444642]    Script Date: 9/10/2021 8:10:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444642] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444642
GO
/****** Object:  View [edw].[View_User_CustomFields_4444643]    Script Date: 9/10/2021 8:10:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444643] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444643
GO
/****** Object:  View [edw].[View_User_CustomFields_4444644]    Script Date: 9/10/2021 8:10:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444644] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444644
GO
/****** Object:  View [edw].[View_User_CustomFields_4444645]    Script Date: 9/10/2021 8:10:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444645] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444645
GO
/****** Object:  View [edw].[View_User_CustomFields_4444646]    Script Date: 9/10/2021 8:10:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444646] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444646
GO
/****** Object:  View [edw].[View_User_CustomFields_4444647]    Script Date: 9/10/2021 8:10:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444647] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444647
GO
/****** Object:  View [edw].[View_UserTreeWithDataCollectionOffCheck]    Script Date: 9/10/2021 8:10:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  View [edw].[View_UserTreeWithDataCollectionOffCheck]    Script Date: 2020/07/24 20:20:50 ******/

CREATE     VIEW [edw].[View_UserTreeWithDataCollectionOffCheck] 
AS

	with ReportsToUserIdList as
	(
		select distinct h.CompanyID, h.ReportsToUserID UserID  --1 IsUserDataManagerInCompany
		from [MD].[Users] h
		where
			DataCollectionOff = 0
	)
	
	, UserList as

	(
		select h.CompanyID, h.ReportsToUserID Parent, h.UserID Child, '' DepartmentIds
		from [MD].[Users] h
		inner join [MD].UserDepartmentHistory ud
		on
			h.CompanyID = ud.CompanyID and h.UserID = ud.UserID
		where
			DataCollectionOff = 0 
		
		group by
		  h.CompanyID, h.ReportsToUserID, h.UserID
	)

	
	, UserDept as
	
	(
		Select a.CompanyID, a.UserID, c.ManagerUserID DepartmentUserID, a.ReportsToUserID
		from [MD].[Users] a
		INNER JOIN [MD].[UserDepartmentHistory] b
		ON(a.CompanyID = b.CompanyID AND a.UserID = b.UserID)
		INNER JOIN [MD].[Department] c
		ON (b.CompanyID = c.CompanyID AND b.DepartmentID = c.DepartmentID)
		where
			DataCollectionOff = 0 
	)


	
	--select * from #DataSource

	, UserHierarchy as (
	
			select s.CompanyID, Parent UserID, Child JoinUserID, 1 as TreeLevel
			from UserList s
			where
				s.Parent <> s.Child

			union all

			select d.CompanyID, d.UserID, s.Child, d.TreeLevel + 1
			from UserHierarchy as d
			inner join UserList s 
			on
				d.CompanyID = s.CompanyID AND d.JoinUserID = s.Parent
			where
				s.Parent <> s.Child ---and d.TreeLevel <= 1

	)
	
	, UserDeptBase as (
	select * from UserDept f
	where not exists (
		select 1 from UserHierarchy l where f.CompanyID = l.CompanyID and f.DepartmentUserID = l.UserID and f.UserID = l.JoinUserID)
	)


	---Select * from UserHierarchy


	select t.CompanyID , u.UserEmail UserEmail
	, t.UserID, t.JoinUserID, s.ReportsToUserID ManagerID, convert(bit, IsNull(rt.UserID, 0))  IsJoinUserIdManagerInCompany, ul.DepartmentIds
	, CASE WHEN s1.ReportsToUserID=t.UserID THEN 1 ELSE 0 END as IsManagerIDDirectReportee
	from
	(

		select u.CompanyID, u.UserID UserID, u.UserID JoinUserID, -1 TreeLevel
		from [MD].[Users] u
		where DataCollectionOff = 0
		
		union all

		select uh.CompanyID, uh.UserID, uh.JoinUserID, uh.TreeLevel 
		from UserHierarchy uh
	--option (maxrecursion 1000)

		union all

		select uhk.CompanyID, uhk.DepartmentUserID, uhk.UserID , -100 TreeLevel
		from UserDeptBase uhk

	) as t

	inner join [MD].[Users] s
	on
		t.CompanyID = s.CompanyID and t.JoinUserID = s.UserID
	
	inner join [MD].[Users] s1
	on
		t.CompanyID = s1.CompanyID and s.ReportsToUserID=s1.UserID
    
	inner join [MD].[Users] u
	on
		t.CompanyID = u.CompanyID and t.UserId = u.UserID
	inner join UserList ul
	on
		t.CompanyID = ul.CompanyID and t.JoinUserID = ul.Child
    
	left outer join ReportsToUserIdList rt
	on
		t.CompanyID = rt.CompanyID and t.JoinUserID = rt.UserID
GO
/****** Object:  View [edw].[View_User_CustomFields_4444651]    Script Date: 9/10/2021 8:10:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444651] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444651
GO
/****** Object:  View [edw].[View_UserTreeOrig]    Script Date: 9/10/2021 8:10:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE     VIEW [edw].[View_UserTreeOrig] 
AS

	with ReportsToUserIdList as
	(
		select distinct h.CompanyID, h.ReportsToUserID UserID  --1 IsUserDataManagerInCompany
		from [MD].[Users] h
	)
	
	, UserList as

	(
		select h.CompanyID, h.ReportsToUserID Parent, h.UserID Child, '' DepartmentIds
		from [MD].[Users] h
		
	)

	
	, UserDept as
	
	(
		Select a.CompanyID, a.UserID, c.ManagerUserID DepartmentUserID, a.ReportsToUserID
		from [MD].[Users] a
		INNER JOIN [MD].[UserDepartmentHistory] b
		ON(a.CompanyID = b.CompanyID AND a.UserID = b.UserID)
		INNER JOIN [MD].[Department] c
		ON (b.CompanyID = c.CompanyID AND b.DepartmentID = c.DepartmentID)
		where
			a.UserID <> c.ManagerUserID
	)


	
	--select * from #DataSource

	, UserHierarchy as (
	
			select s.CompanyID, Parent UserID, Child JoinUserID, 1 as TreeLevel
			from UserList s
			where
				s.Parent <> s.Child

			union all

			select d.CompanyID, d.UserID, s.Child, d.TreeLevel + 1
			from UserHierarchy as d
			inner join UserList s 
			on
				d.CompanyID = s.CompanyID AND d.JoinUserID = s.Parent
			where
				s.Parent <> s.Child ---and d.TreeLevel <= 1

	)
	
	, UserDeptBase as (
	select * from UserDept f
	where not exists (
		select 1 from UserHierarchy l where f.CompanyID = l.CompanyID and f.DepartmentUserID = l.UserID and f.UserID = l.JoinUserID)
	)


	---Select * from UserHierarchy


	select t.CompanyID , u.UserEmail UserEmail
	, t.UserID, t.JoinUserID, s.ReportsToUserID ManagerID, convert(bit, IsNull(rt.UserID, 0))  IsJoinUserIdManagerInCompany, ul.DepartmentIds
	, CASE WHEN s1.ReportsToUserID=t.UserID THEN 1 ELSE 0 END as IsManagerIDDirectReportee
	from
	(

		select u.CompanyID, u.UserID UserID, u.UserID JoinUserID, -1 TreeLevel
		from [MD].[Users] u
	
		
		union all

		select uh.CompanyID, uh.UserID, uh.JoinUserID, uh.TreeLevel 
		from UserHierarchy uh
	--option (maxrecursion 1000)

		union all

		select uhk.CompanyID, uhk.DepartmentUserID, uhk.UserID , -100 TreeLevel
		from UserDeptBase uhk

	) as t

	inner join [MD].[Users] s
	on
		t.CompanyID = s.CompanyID and t.JoinUserID = s.UserID
	
	inner join [MD].[Users] s1
	on
		t.CompanyID = s1.CompanyID and s.ReportsToUserID=s1.UserID
    
	inner join [MD].[Users] u
	on
		t.CompanyID = u.CompanyID and t.UserId = u.UserID
	inner join UserList ul
	on
		t.CompanyID = ul.CompanyID and t.JoinUserID = ul.Child
    
	left outer join ReportsToUserIdList rt
	on
		t.CompanyID = rt.CompanyID and t.JoinUserID = rt.UserID
GO
/****** Object:  View [edw].[View_User_CustomFields_4444652]    Script Date: 9/10/2021 8:10:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444652] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444652
GO
/****** Object:  View [edw].[View_UserDetail]    Script Date: 9/10/2021 8:10:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [edw].[View_UserDetail] 
--CREATE VIEW [edw].[View_UserDetail] 
AS

select 
    u.CompanyID,
	 u.UserID,
     u.UserEmail,
	 (u.FirstName + ' ' + u.LastName) as UserFullName,
	  mgr.UserEmail as ManagerEmail,
	 (mgr.FirstName + ' ' + mgr.LastName) as ManagerFullName,
	 d.DepartmentName as [Department],
	 t.TeamName as [Team],
	 loc.LocationName as [Location],
	 v.VendorName as [Vendor],
	 jf.JobFamilyName as [JobFamily]
	
from  edw.Fact_DailyActivity f
	left join edw.Dim_User u  on u.CompanyID = f.Dim_CompanyID  and u.ID = f.Dim_UserId
	left join edw.Dim_Team t on t.CompanyID = f.Dim_CompanyID and t.ID = u.DimTeamID
	left join edw.Dim_User mgr  on u.CompanyID = f.Dim_CompanyID  and mgr.ID = t.ManagerID
	left join edw.Dim_Location loc on loc.CompanyID = f.Dim_CompanyID and loc.LocationID = u.Dim_LocationID
	left join edw.Dim_Department d on d.CompanyID = f.Dim_CompanyID and d.DepartmentID = u.Dim_DepartmentID
	left join edw.Dim_Vendor v on v.CompanyID = f.Dim_CompanyID and v.ID = u.Dim_VendorID
	left join edw.Dim_JobFamilyProfile jf on jf.CompanyID = f.Dim_CompanyID and jf.ID = u.Dim_JobFamilyProfileID


	/*


	select * from [edw].[View_UserDetail] 
	where companyId = 1 and useremail like 'robert%'

	
	*/
GO
/****** Object:  View [edw].[View_User_CustomFields_4444653]    Script Date: 9/10/2021 8:10:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444653] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444653
GO
/****** Object:  View [edw].[View_Department]    Script Date: 9/10/2021 8:10:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [edw].[View_Department] 
--CREATE VIEW [edw].[View_UserDetail] 
AS

select 
     d.ID,
     d.CompanyID,
	 d.DepartmentID,
	 d.DepartmentName,
	 mgr.Id as ManagerId,
     mgr.UserEmail as ManagerEmail,
	 mgr.FirstName as ManagerFirstName,
	 mgr.LastName as ManagerLastName,
	 (mgr.FirstName + ' ' + mgr.LastName) as ManagerFullName,
	 EmployeCount = (select count(*) from Dim_User u where  u.CompanyID = d.CompanyID and u.Dim_DepartmentId = d.Id)
	
from  edw.Dim_Department d
	left join edw.Dim_User mgr  on mgr.CompanyID = d.CompanyID  and mgr.ID = d.ManagerDimUserID
	
GO
/****** Object:  Table [edw].[Fact_DailyUser]    Script Date: 9/10/2021 8:10:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Fact_DailyUser](
	[Dim_UserId] [int] NOT NULL,
	[Dim_CompanyID] [int] NOT NULL,
	[ActivityDate] [date] NOT NULL,
	[Start_Time] [datetime] NOT NULL,
	[End_Time] [datetime] NOT NULL,
	[FirstOnPcTime] [datetime] NULL,
	[LastOnPcTime] [datetime] NULL,
	[EstimatedTimeSpent] [real] NOT NULL,
	[OnlineTimeSpent] [real] NOT NULL,
	[OfflineTimeSpent] [real] NOT NULL,
	[PrivateTimeSpent] [real] NOT NULL,
	[UnaccountedTimeSpent] [real] NOT NULL,
	[FocusTimeInCalendarDay] [real] NOT NULL,
	[FocusTimeInShift] [real] NOT NULL,
	[MaxUnaccountedSlotTime] [real] NULL,
	[FirstOnPCTimeInUTC] [datetime] NULL,
	[LastOnPCTimeInUTC] [datetime] NULL,
	[MaxUnaccountedTimeWithPreviousDay] [real] NULL,
	[BreakTime_19_or_less] [real] NULL,
	[BreakTime_20_to_45] [real] NULL,
	[BreakTime_46_or_more] [real] NULL,
	[NumberOfBreak_19_or_less] [int] NULL,
	[NumberOfBreak_20_to_45] [int] NULL,
	[NumberOfBreak_46_or_more] [int] NULL,
	[BreakTimeInCalenderDay]  AS ((coalesce([BreakTime_19_or_less],(0))+coalesce([BreakTime_20_to_45],(0)))+coalesce([BreakTime_46_or_more],(0))),
	[NumberOfBreakInCalenderDay]  AS ((coalesce([NumberOfBreak_19_or_less],(0))+coalesce([NumberOfBreak_20_to_45],(0)))+coalesce([NumberOfBreak_46_or_more],(0))),
	[FirstWorkPCTime] [datetime] NULL,
	[LastWorkPcTime] [datetime] NULL,
	[previous24DayDetail] [real] NULL,
	[BreakTime_30] [real] NULL,
	[NumberOfBreak_30] [int] NULL,
	[MaxUnaccountedWorkTimeWithPreviousDay] [real] NULL,
	[FocusOfficeTimeInCalendarDay] [real] NOT NULL,
 CONSTRAINT [PK_FactDailyUserData] PRIMARY KEY CLUSTERED 
(
	[Dim_UserId] ASC,
	[Dim_CompanyID] ASC,
	[ActivityDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [psc_CompanyID]([Dim_CompanyID])
) ON [psc_CompanyID]([Dim_CompanyID])
GO
/****** Object:  View [edw].[View_UserDailyWorkTime]    Script Date: 9/10/2021 8:10:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--select * from edw.Dim_User

CREATE   VIEW [edw].[View_UserDailyWorkTime] 
AS

select 
     u.CompanyID,
	 u.ID,
	 u.UserID,
     u.UserEmail,
	 (u.FirstName + ' ' + u.LastName) as UserFullName,
	  mgr.UserEmail as ManagerEmail,
	 (mgr.FirstName + ' ' + mgr.LastName) as ManagerFullName,
	 loc.LocationName as [Location],
	 d.DepartmentName as [Department],
	 v.VendorName as [Vendor],
	 jf.JobFamilyName as [JobFamily],
	 t.TeamName as [Team],
	 f.ActivityDate,
	 f.Start_time,
	 f.End_Time,
     f.FirstOnPcTime,
	 f.LastOnPCTime , 
     f.FirstOnPcTimeInUTC,
	 f.LastOnPCTimeInUTC , 
	 f.EstimatedTimeSpent,
	 f.OnlineTimeSpent,
	 f.OfflineTimeSpent,
	 (f.OnlineTimeSpent + f.OfflineTimeSpent) as WorkTimeSpent,
	 f.PrivateTimeSpent,
	 f.UnaccountedTimeSpent,
	 f.FocusTimeInCalendarDay,
	 f.FocusTimeInShift
from  edw.Fact_DailyUser f
	left join edw.Dim_User u  on u.CompanyID = f.Dim_CompanyID  and u.ID = f.Dim_UserId
	left join edw.Dim_Team t on t.CompanyID = f.Dim_CompanyID and t.ID = u.DimTeamID
	left join edw.Dim_User mgr  on u.CompanyID = f.Dim_CompanyID  and mgr.ID = t.ManagerID
	left join edw.Dim_Location loc on loc.CompanyID = f.Dim_CompanyID and loc.ID = u.Dim_LocationID
	left join edw.Dim_Department d on d.CompanyID = f.Dim_CompanyID and d.ID = u.Dim_DepartmentID
	left join edw.Dim_Vendor v on v.CompanyID = f.Dim_CompanyID and v.ID = u.Dim_VendorID
	left join edw.Dim_JobFamilyProfile jf on jf.CompanyID = f.Dim_CompanyID and jf.ID = u.Dim_JobFamilyProfileID



	/*
	    select 
	        EstimatedTimeSpent, OnlineTimeSpent, OfflineTimeSpent, PrivateTimeSpent, UnaccountedTimeSpent, FocusTimeInCalendarDay
		 , datediff(minute, FirstOnPcTime, LastOnPCTime)  as TotalTime
		 , (estimatedTimeSpent - OnlineTimeSpent - PrivateTimeSpent) as TotalTime2
	     from edw.Fact_DailyUser where Dim_companyID = 1 
	    and Dim_UserID = 5036
	    and activitydate = '2020-07-23'

	select * from edw.View_UserDailyWorkTime
	where companyID = 1 
	    and useremail = 'robert.owens@sapience.net'
	    and activitydate > '2020-07-23'

	select * from edw.View_UserDailyActivity
	where companyID = 1 
	    and useremail = 'robert.owens@sapience.net'
	    and activitydate = '2020-07-23'

	*/
GO
/****** Object:  View [edw].[View_User_CustomFields_4444654]    Script Date: 9/10/2021 8:10:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444654] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444654
GO
/****** Object:  Table [edw].[Dim_Company]    Script Date: 9/10/2021 8:10:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Dim_Company](
	[CompanyID] [int] NOT NULL,
	[TenantID] [int] NOT NULL,
	[LineofBusinessID] [int] NOT NULL,
	[CompanyName] [nvarchar](512) NOT NULL,
	[DateCreated] [smalldatetime] NOT NULL,
	[DateActivated] [smalldatetime] NULL,
	[DateDeleted] [smalldatetime] NULL,
	[CurrentTimestamp] [timestamp] NOT NULL,
	[FileOrULPrivacy] [bit] NULL,
 CONSTRAINT [pk_Company] PRIMARY KEY CLUSTERED 
(
	[CompanyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Dim_Date]    Script Date: 9/10/2021 8:10:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Dim_Date](
	[DateNum] [int] NOT NULL,
	[Date] [date] NOT NULL,
	[YearMonthNum] [int] NOT NULL,
	[CalendarQuarter] [nvarchar](255) NOT NULL,
	[MonthNum] [int] NOT NULL,
	[MonthName] [nvarchar](255) NOT NULL,
	[MonthShortName] [nvarchar](255) NOT NULL,
	[WeekNum] [int] NOT NULL,
	[DayNumOfYear] [int] NOT NULL,
	[DayNumOfMonth] [int] NOT NULL,
	[DayNumOfWeek] [int] NOT NULL,
	[DayName] [nvarchar](255) NOT NULL,
	[DayShortName] [nvarchar](255) NOT NULL,
	[Quarter] [int] NOT NULL,
	[YearQuarterNum] [int] NOT NULL,
	[DayNumOfQuarter] [int] NULL,
 CONSTRAINT [PK_Dim_Date] PRIMARY KEY CLUSTERED 
(
	[Date] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [edw].[View_DimDates]    Script Date: 9/10/2021 8:10:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE    VIEW [edw].[View_DimDates] as 
	Select b.CompanyID as CompanyID,
	a.* from [EDW].[Dim_Date] a
	Join [EDW].[Dim_Company] b
	ON a.Date >= b.DateCreated -1 and a.Date < CAST(GETDATE()+30 AS DATE)

GO
/****** Object:  View [edw].[View_User_CustomFields_4444655]    Script Date: 9/10/2021 8:10:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444655] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444655
GO
/****** Object:  View [edw].[View_User_CustomFields_4444656]    Script Date: 9/10/2021 8:10:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444656] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444656
GO
/****** Object:  View [edw].[View_User_CustomFields_4444657]    Script Date: 9/10/2021 8:10:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444657] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444657
GO
/****** Object:  View [edw].[View_User_CustomFields_4444658]    Script Date: 9/10/2021 8:10:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444658] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444658
GO
/****** Object:  View [edw].[View_User_CustomFields_4444682]    Script Date: 9/10/2021 8:10:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444682] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444682
GO
/****** Object:  View [edw].[View_User_CustomFields_4444688]    Script Date: 9/10/2021 8:10:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444688] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444688
GO
/****** Object:  View [edw].[View_User_CustomFields_4444689]    Script Date: 9/10/2021 8:10:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444689] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444689
GO
/****** Object:  Table [edw].[Brdg_UserField]    Script Date: 9/10/2021 8:10:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Brdg_UserField](
	[Dim_UserID] [int] NOT NULL,
	[Dim_FieldID] [int] NOT NULL,
	[StringValue] [varchar](500) NULL,
	[DateTimeValue] [datetimeoffset](7) NULL,
	[NumericValue] [float] NULL,
	[BooleanValue] [bit] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Dim_Field]    Script Date: 9/10/2021 8:10:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Dim_Field](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Dim_SettingID] [int] NOT NULL,
	[Dim_DataTypeID] [int] NULL,
	[SourceKey] [int] NULL,
	[Name] [varchar](50) NOT NULL,
	[Description] [varchar](100) NULL,
	[DateCreatedModified] [smalldatetime] NOT NULL,
 CONSTRAINT [pk_Field] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[Dim_SettingID] ASC,
	[SourceKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [edw].[View_CustomFields_1]    Script Date: 9/10/2021 8:10:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   VIEW [edw].[View_CustomFields_1] AS

	SELECT usr.CompanyID, usr.UserID, [Shift ],[Cost Center],[Citizenship],[Business Unit],[BusinessU],[Joining Date],[CTC],[Cost],[Shift Worker],[Work From Home],[WFH]
	FROM (SELECT * FROM edw.dim_user WHERE CompanyID=1 AND IsActive=1) usr
	LEFT JOIN
	(select * from
			(select * from
				(select u.CompanyID, u.ID, u.UserID, StringValue, f.Name from edw.Brdg_UserField brdg
				join edw.Dim_Field f ON brdg.Dim_FieldID = f.ID
				JOIN edw.Dim_User u ON brdg.Dim_UserID = u.ID
				WHERE u.CompanyID=1
				) base
				PIVOT
				(
				MAX(StringValue)
				FOR Name IN ([Shift ],[Cost Center],[Citizenship],[Business Unit],[BusinessU])
			) StringResults
		) sr
	) strings ON usr.ID = strings.ID 

	LEFT JOIN -----------------------------------------------------------
	(
	select * from
		(select * from
			(select u.CompanyID, u.UserID, DateTimeValue, f.Name from edw.Brdg_UserField brdg
			join edw.Dim_Field f ON brdg.Dim_FieldID = f.ID
			JOIN edw.Dim_User u ON brdg.Dim_UserID = u.ID
			WHERE u.CompanyID=1
			) base 
			PIVOT
			(
			MAX(DateTimeValue)
			FOR Name IN ([Joining Date])
		) as DateTimeResults
	) dtr 
	) datetimes ON strings.CompanyID = datetimes.CompanyID AND strings.UserID = datetimes.UserID

	LEFT JOIN -----------------------------------------------------------
	(
	select * from
		(select * from
			(select u.CompanyID, u.UserID, NumericValue, f.Name from edw.Brdg_UserField brdg
			join edw.Dim_Field f ON brdg.Dim_FieldID = f.ID
			JOIN edw.Dim_User u ON brdg.Dim_UserID = u.ID
			WHERE u.CompanyID=1
			) base
			PIVOT
			(
			MAX(NumericValue)
			FOR Name IN ([CTC],[Cost],[Shift Worker])
		) as FloatResults
	) fr 
	) floats ON strings.CompanyID = floats.CompanyID AND strings.UserID = floats.UserID

	LEFT JOIN -----------------------------------------------------------
	(
	select * from
		(select * from
			(select u.CompanyID, u.UserID, CAST(BooleanValue AS tinyint) BoolAsInt, f.Name from edw.Brdg_UserField brdg
			join edw.Dim_Field f ON brdg.Dim_FieldID = f.ID
			JOIN edw.Dim_User u ON brdg.Dim_UserID = u.ID
			WHERE u.CompanyID=1
			) base
			PIVOT
			(
			MAX(BoolAsInt)
			FOR Name IN ([Work From Home],[WFH])
		) as BooleanResults
	) br
	) bools ON strings.CompanyID = bools.CompanyID AND strings.UserID = bools.UserID

GO
/****** Object:  View [edw].[View_User_CustomFields_4444701]    Script Date: 9/10/2021 8:10:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444701] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444701
GO
/****** Object:  View [edw].[View_Team]    Script Date: 9/10/2021 8:10:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [edw].[View_Team] 
-- ALTER VIEW [edw].[View_UserDetail] 
AS

select 
     t.ID,
     t.CompanyID,
	 t.TeamID,
	 t.TeamName,
	 mgr.Id as ManagerId,
     mgr.UserEmail as ManagerEmail,
	 mgr.FirstName as ManagerFirstName,
	 mgr.LastName as ManagerLastName,
	 (mgr.FirstName + ' ' + mgr.LastName) as ManagerFullName,
	 EmployeCount = (select count(*) from Dim_User u where  u.CompanyID = t.CompanyID and u.DimTeamId = t.Id)
	
from  edw.Dim_Team t
	left join edw.Dim_User mgr  on mgr.CompanyID = t.CompanyID  and mgr.ID = t.ManagerID
	
	/*


	select * from [edw].[View_Team] 
	where companyId = 1 

	*/
GO
/****** Object:  View [edw].[View_CustomFields_8]    Script Date: 9/10/2021 8:10:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE    VIEW [edw].[View_CustomFields_8] AS
SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=8 and IsActive=1
GO
/****** Object:  View [edw].[View_User_CustomFields_4444702]    Script Date: 9/10/2021 8:10:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444702] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444702
GO
/****** Object:  View [edw].[View_User_CustomFields_4444703]    Script Date: 9/10/2021 8:10:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444703] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444703
GO
/****** Object:  View [edw].[View_User_CustomFields_4444704]    Script Date: 9/10/2021 8:10:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4444704] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4444704
GO
/****** Object:  View [edw].[View_User_CustomFields_1]    Script Date: 9/10/2021 8:10:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
------------------------------------ Strings
			CREATE   VIEW [edw].[View_User_CustomFields_1] AS 
		
			SELECT usr.CompanyID, usr.UserID,[Work From Home],[Cost Center1],[Shift Of Worker],[Cost],[Unit Cost],[Business Unit] 
			FROM 
		
			(SELECT * FROM edw.dim_user WHERE CompanyID=1) usr 
			LEFT JOIN
			(select * from
					(select * from
						(select u.CompanyID, u.ID, u.UserID, StringValue, f.Name from edw.Brdg_UserField brdg
						join edw.Dim_Field f ON brdg.Dim_FieldID = f.ID
						JOIN edw.Dim_User u ON brdg.Dim_UserID = u.ID
						WHERE u.CompanyID = 1
						) base
						PIVOT
						(
						MAX(StringValue)
						FOR Name IN ([Cost Center1],[Shift Of Worker],[Business Unit])
					) StringResults
				) sr
			) strings ON usr.ID = strings.ID 

			FULL JOIN ---------------------------- Dates
			(select * from
				(select * from
					(select u.CompanyID, u.UserID, DateTimeValue, f.Name from edw.Brdg_UserField brdg
					join edw.Dim_Field f ON brdg.Dim_FieldID = f.ID
					JOIN edw.Dim_User u ON brdg.Dim_UserID = u.ID
					WHERE u.CompanyID = 1
					) base 
					PIVOT
					(
					MAX(DateTimeValue)
					FOR Name IN ([Not Applicable])
				) as DateTimeResults
			) dtr 
			) datetimes ON strings.CompanyID = datetimes.CompanyID AND strings.UserID = datetimes.UserID

			FULL JOIN ----------------------------- Floats
			(select * from
				(select * from
					(select u.CompanyID, u.UserID, NumericValue, f.Name from edw.Brdg_UserField brdg
					join edw.Dim_Field f ON brdg.Dim_FieldID = f.ID
					JOIN edw.Dim_User u ON brdg.Dim_UserID = u.ID
					WHERE u.CompanyID = 1
					) base
					PIVOT
					(
					MAX(NumericValue)
					FOR Name IN ([Cost],[Unit Cost])
				) as FloatResults
			) fr 
			) floats ON strings.CompanyID = floats.CompanyID AND strings.UserID = floats.UserID

			FULL JOIN ------------------------------- Bools
			(
			select * from
				(select * from
					(select u.CompanyID, u.UserID, CAST(BooleanValue AS tinyint) BoolAsInt, f.Name from edw.Brdg_UserField brdg
					join edw.Dim_Field f ON brdg.Dim_FieldID = f.ID
					JOIN edw.Dim_User u ON brdg.Dim_UserID = u.ID
					WHERE u.CompanyID = 1
					) base
					PIVOT
					(
					MAX(BoolAsInt)
					FOR Name IN ([Work From Home])
				) as BooleanResults
			) br
			) bools ON strings.CompanyID = bools.CompanyID AND strings.UserID = bools.UserID
			
GO
/****** Object:  View [edw].[View_User_CustomFields_0]    Script Date: 9/10/2021 8:10:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_0] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=0
GO
/****** Object:  View [edw].[View_User_CustomFields_8]    Script Date: 9/10/2021 8:10:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_8] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=8
GO
/****** Object:  View [edw].[View_User_CustomFields_3]    Script Date: 9/10/2021 8:10:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_3] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=3
GO
/****** Object:  View [edw].[View_User_CustomFields_4]    Script Date: 9/10/2021 8:10:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_4] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=4
GO
/****** Object:  View [edw].[View_User_CustomFields_2]    Script Date: 9/10/2021 8:10:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_2] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=2
GO
/****** Object:  View [edw].[View_User_CustomFields_5]    Script Date: 9/10/2021 8:10:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_5] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=5
GO
/****** Object:  View [edw].[View_User_CustomFields_10]    Script Date: 9/10/2021 8:10:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_10] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=10
GO
/****** Object:  View [edw].[View_User_CustomFields_6]    Script Date: 9/10/2021 8:10:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_6] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=6
GO
/****** Object:  View [edw].[View_User_CustomFields_7]    Script Date: 9/10/2021 8:10:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_7] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=7
GO
/****** Object:  View [edw].[View_User_CustomFields_30]    Script Date: 9/10/2021 8:10:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_30] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=30
GO
/****** Object:  View [edw].[View_User_CustomFields_9]    Script Date: 9/10/2021 8:10:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [edw].[View_User_CustomFields_9] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=9
GO
/****** Object:  Table [dbo].[flyway_schema_history]    Script Date: 9/10/2021 8:10:03 AM ******/
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
/****** Object:  Table [dbo].[flyway_schema_history_Backup]    Script Date: 9/10/2021 8:10:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[flyway_schema_history_Backup](
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
 CONSTRAINT [flyway_schema_history_Backup_pk] PRIMARY KEY CLUSTERED 
(
	[installed_rank] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[flyway_schema_history_hotfix]    Script Date: 9/10/2021 8:10:04 AM ******/
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
/****** Object:  Table [dbo].[ImportUserDepartment]    Script Date: 9/10/2021 8:10:04 AM ******/
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
/****** Object:  Table [dbo].[Log_TalendExceptions]    Script Date: 9/10/2021 8:10:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Log_TalendExceptions](
	[moment] [smalldatetime] NULL,
	[pid] [nvarchar](25) NULL,
	[root_pid] [nvarchar](25) NULL,
	[father_pid] [nvarchar](25) NULL,
	[project] [nvarchar](25) NULL,
	[job] [nvarchar](50) NULL,
	[context] [nvarchar](25) NULL,
	[priority] [tinyint] NULL,
	[type] [nvarchar](25) NULL,
	[origin] [nvarchar](25) NULL,
	[message] [nvarchar](500) NULL,
	[code] [tinyint] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PanTempActivitiesBase]    Script Date: 9/10/2021 8:10:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PanTempActivitiesBase](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [int] NULL,
	[StartTime] [datetime2](7) NULL,
	[EndTime] [datetime2](7) NULL,
	[TimeZoneOffSet] [int] NULL,
	[PurposeID] [int] NULL,
	[WorkCategory] [nvarchar](4000) NULL,
	[ActivityCategoryID] [int] NULL,
	[ActivityCategoryName] [nvarchar](4000) NULL,
	[AppID] [int] NULL,
	[AppName] [nvarchar](4000) NULL,
	[WebAppID] [int] NULL,
	[WebAppName] [nvarchar](4000) NULL,
	[FileOrUrlName] [nvarchar](4000) NULL,
	[IsUserModified] [bit] NULL,
	[StartTimeInUTC] [datetime2](7) NULL,
	[EndTimeInUTC] [datetime2](7) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RawEmailAnalyticsData]    Script Date: 9/10/2021 8:10:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RawEmailAnalyticsData](
	[ID] [float] NULL,
	[NumberOfSentEmails] [float] NULL,
	[NumberOfReceivedEmails] [float] NULL,
	[NumberOfUnreadEmails] [float] NULL,
	[AvgResponseTime] [float] NULL,
	[NumberOfAllRecipients] [float] NULL,
	[NumberOfTeamRecipients] [float] NULL,
	[NumberOfDepartmentRecipients] [float] NULL,
	[NumberOfRecipientsInCompany] [float] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[sysdiagrams]    Script Date: 9/10/2021 8:10:04 AM ******/
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
/****** Object:  Table [dbo].[TESTABC]    Script Date: 9/10/2021 8:10:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TESTABC](
	[CompanyID] [int] NOT NULL,
	[UserID] [int] NOT NULL,
	[DepartmentUserID] [int] NOT NULL,
	[ReportsToDimUserID] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TestPan]    Script Date: 9/10/2021 8:10:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TestPan](
	[ActivityDate] [nvarchar](255) NULL,
	[ID] [float] NULL,
	[EntityId] [float] NULL,
	[PropertyId_1] [float] NULL,
	[PropertyId_2] [float] NULL,
	[PropertyId_3] [float] NULL,
	[OutputValue] [float] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Testpan1]    Script Date: 9/10/2021 8:10:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Testpan1](
	[ActivityDate] [date] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Testpan2]    Script Date: 9/10/2021 8:10:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Testpan2](
	[ID] [float] NULL,
	[EntityId] [float] NULL,
	[PropertyId_1] [float] NULL,
	[PropertyId_2] [float] NULL,
	[PropertyId_3] [float] NULL,
	[OutputValue] [float] NULL,
	[ActivityDate] [date] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Testpannew]    Script Date: 9/10/2021 8:10:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Testpannew](
	[ID] [float] NULL,
	[EntityId] [float] NULL,
	[PropertyId_1] [float] NULL,
	[PropertyId_2] [float] NULL,
	[PropertyId_3] [float] NULL,
	[OutputValue] [float] NULL,
	[ActivityDate] [date] NULL,
	[UserID] [int] NOT NULL,
	[t2id] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TestUserid]    Script Date: 9/10/2021 8:10:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TestUserid](
	[UserID] [int] NOT NULL,
	[id] [int] IDENTITY(1,1) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserID0]    Script Date: 9/10/2021 8:10:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserID0](
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
	[WeekWorkDays] [real] NULL,
	[UserID] [int] NOT NULL,
	[DataCollectionOff] [bit] NOT NULL,
	[HasEmployeeDataAccess] [bit] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Vue_DeploymentInfo]    Script Date: 9/10/2021 8:10:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Vue_DeploymentInfo](
	[Sr No# ] [float] NULL,
	[CompanyID] [float] NULL,
	[TenantID] [float] NULL,
	[CompanyName] [nvarchar](255) NULL,
	[DateCreated] [datetime] NULL,
	[Status] [nvarchar](255) NULL,
	[Total Users] [float] NULL,
	[Deployment Type] [nvarchar](255) NULL,
	[Portal Access] [nvarchar](255) NULL,
	[Users Having Portal Access] [float] NULL,
	[Admin Portal Access] [nvarchar](255) NULL,
	[BI Portal Access] [nvarchar](255) NULL,
	[Deployment Mode] [nvarchar](255) NULL,
	[Deployment Status] [nvarchar](255) NULL,
	[End of Deployment] [datetime] NULL,
	[Sales Person] [nvarchar](255) NULL,
	[PS Person] [nvarchar](255) NULL,
	[Support Person] [nvarchar](255) NULL,
	[F19] [nvarchar](255) NULL,
	[F20] [nvarchar](255) NULL,
	[F21] [nvarchar](255) NULL,
	[F22] [nvarchar](255) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Brdg_AppActivityCategory]    Script Date: 9/10/2021 8:10:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Brdg_AppActivityCategory](
	[Dim_ActivityCategoryID] [int] NOT NULL,
	[Dim_AppParentID] [int] NOT NULL,
	[DefaultPurpose] [tinyint] NOT NULL,
	[WebApp] [nvarchar](512) NULL,
	[CanOverride] [bit] NOT NULL,
	[UrlMatching] [tinyint] NOT NULL,
	[DateCreated] [smalldatetime] NOT NULL,
	[DateDeleted] [smalldatetime] NULL,
	[IsActive] [bit] NOT NULL,
	[CurrentTimestamp] [timestamp] NOT NULL,
 CONSTRAINT [pk_AppActivityCategory] PRIMARY KEY CLUSTERED 
(
	[Dim_ActivityCategoryID] ASC,
	[Dim_AppParentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Brdg_AppActivityCategory(Old)]    Script Date: 9/10/2021 8:10:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Brdg_AppActivityCategory(Old)](
	[Dim_ActivityCategoryID] [int] NOT NULL,
	[Dim_AppMasterID] [int] NOT NULL,
	[DefaultPurpose] [tinyint] NOT NULL,
	[WebApp] [nvarchar](512) NOT NULL,
	[CanOverride] [bit] NOT NULL,
	[UrlMatching] [tinyint] NOT NULL,
	[DateCreated] [smalldatetime] NOT NULL,
	[DateDeleted] [smalldatetime] NULL,
	[IsActive] [bit] NOT NULL,
	[CurrentTimestamp] [timestamp] NOT NULL,
 CONSTRAINT [pk_AppActivityCategoryMap] PRIMARY KEY CLUSTERED 
(
	[Dim_ActivityCategoryID] ASC,
	[Dim_AppMasterID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Brdg_CompanySettings]    Script Date: 9/10/2021 8:10:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Brdg_CompanySettings](
	[CompanyID] [int] NOT NULL,
	[Dim_SettingID] [int] NOT NULL,
	[SettingValue] [nvarchar](4000) NOT NULL,
 CONSTRAINT [PK_CompanySettings] PRIMARY KEY CLUSTERED 
(
	[CompanyID] ASC,
	[Dim_SettingID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Brdg_HolidayLocationHistory]    Script Date: 9/10/2021 8:10:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Brdg_HolidayLocationHistory](
	[CompanyID] [int] NOT NULL,
	[Dim_HolidayID] [int] NOT NULL,
	[Dim_LocationID] [int] NOT NULL,
	[IsActive] [bit] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Brdg_JobFamilyAppOverride]    Script Date: 9/10/2021 8:10:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Brdg_JobFamilyAppOverride](
	[CompanyID] [int] NOT NULL,
	[Dim_AppParentID] [int] NOT NULL,
	[Dim_JobFamilyProfileID] [int] NOT NULL,
	[Dim_ActivityCategoryID] [int] NOT NULL,
	[IsCore] [bit] NULL,
	[IsWorkCategory] [bit] NULL,
	[IsActive] [bit] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Brdg_JobFamilyWebAppOverride]    Script Date: 9/10/2021 8:10:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Brdg_JobFamilyWebAppOverride](
	[CompanyID] [int] NOT NULL,
	[Dim_WebAppID] [int] NOT NULL,
	[Dim_JobFamilyProfileID] [int] NOT NULL,
	[Dim_ActivityCategoryID] [int] NOT NULL,
	[IsCore] [bit] NULL,
	[IsWorkCategory] [bit] NULL,
	[IsActive] [bit] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Brdg_UserAppOverride]    Script Date: 9/10/2021 8:10:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Brdg_UserAppOverride](
	[CompanyID] [int] NOT NULL,
	[Dim_AppParentID] [int] NOT NULL,
	[Dim_UserProfileID] [int] NOT NULL,
	[Dim_ActivityCategoryID] [int] NOT NULL,
	[IsCore] [bit] NULL,
	[IsWorkCategory] [bit] NULL,
	[IsActive] [bit] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Brdg_UserDepartmentHistory]    Script Date: 9/10/2021 8:10:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Brdg_UserDepartmentHistory](
	[Dim_UserID] [int] NOT NULL,
	[Dim_DepartmentID] [int] NOT NULL,
	[StartDate] [smalldatetime] NOT NULL,
	[EndDate] [smalldatetime] NULL,
	[IsManager] [bit] NOT NULL,
	[IsCurrent] [bit] NOT NULL,
 CONSTRAINT [pk_DepartmentUserHistory] PRIMARY KEY CLUSTERED 
(
	[Dim_UserID] ASC,
	[Dim_DepartmentID] ASC,
	[StartDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Brdg_UserDepartmentHistory(Temp)]    Script Date: 9/10/2021 8:10:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Brdg_UserDepartmentHistory(Temp)](
	[Dim_UserID] [int] NOT NULL,
	[Dim_DepartmentID] [int] NOT NULL,
	[StartDate] [smalldatetime] NOT NULL,
	[EndDate] [smalldatetime] NULL,
	[IsManager] [bit] NOT NULL,
	[IsCurrent] [bit] NOT NULL,
 CONSTRAINT [pk_DepartmentUserHistory(Temp)] PRIMARY KEY CLUSTERED 
(
	[Dim_UserID] ASC,
	[Dim_DepartmentID] ASC,
	[StartDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Brdg_UserLocationHistory]    Script Date: 9/10/2021 8:10:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Brdg_UserLocationHistory](
	[Dim_UserID] [int] NOT NULL,
	[Dim_LocationID] [int] NOT NULL,
	[StartDate] [smalldatetime] NOT NULL,
	[EndDate] [smalldatetime] NULL,
	[IsCurrent] [bit] NOT NULL,
 CONSTRAINT [PK_UserLocationHistory] PRIMARY KEY CLUSTERED 
(
	[Dim_UserID] ASC,
	[StartDate] ASC,
	[Dim_LocationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Brdg_UserReportsToHistory]    Script Date: 9/10/2021 8:10:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Brdg_UserReportsToHistory](
	[Dim_UserID] [int] NOT NULL,
	[StartDate] [date] NOT NULL,
	[EndDate] [date] NULL,
	[Dim_UserID_ReportsTo] [int] NOT NULL,
	[IsCurrent] [bit] NOT NULL,
 CONSTRAINT [PK_UserReportsToHistory] PRIMARY KEY CLUSTERED 
(
	[Dim_UserID] ASC,
	[StartDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Brdg_UserWebAppOverride]    Script Date: 9/10/2021 8:10:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Brdg_UserWebAppOverride](
	[CompanyID] [int] NOT NULL,
	[Dim_WebAppID] [int] NOT NULL,
	[Dim_UserProfileID] [int] NOT NULL,
	[Dim_ActivityCategoryID] [int] NOT NULL,
	[IsCore] [bit] NULL,
	[IsWorkCategory] [bit] NULL,
	[IsActive] [bit] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Brdg_Vendor_Contigent_RateCard]    Script Date: 9/10/2021 8:10:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Brdg_Vendor_Contigent_RateCard](
	[CompanyID] [int] NOT NULL,
	[Dim_VendorID] [int] NOT NULL,
	[Dim_JobFamilyProfileID] [int] NOT NULL,
	[Dim_LocationID] [int] NOT NULL,
	[CostPerDay] [real] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Brdg_Vendor_Invoice]    Script Date: 9/10/2021 8:10:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Brdg_Vendor_Invoice](
	[CompanyID] [int] NOT NULL,
	[Month] [date] NOT NULL,
	[Dim_VendorID] [int] NOT NULL,
	[InvoiceHours] [real] NOT NULL,
	[InvoiceAmount] [real] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Demo_Company]    Script Date: 9/10/2021 8:10:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Demo_Company](
	[CompanyID] [int] NOT NULL,
	[TenantID] [int] NOT NULL,
	[LineofBusinessID] [int] NOT NULL,
	[CompanyName] [nvarchar](512) NOT NULL,
	[IsActive] [bit] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Dim_AppParent]    Script Date: 9/10/2021 8:10:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Dim_AppParent](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CompanyID] [int] NOT NULL,
	[ExeName] [nvarchar](2048) NULL,
	[AppName] [nvarchar](2048) NOT NULL,
	[Dim_ActivityCategoryID] [int] NULL,
	[AppSpecID] [int] NULL,
	[LowPriority] [bit] NULL,
 CONSTRAINT [PK_Dim_AppParent] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [uc_AppParent] UNIQUE NONCLUSTERED 
(
	[CompanyID] ASC,
	[ExeName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Dim_Comment]    Script Date: 9/10/2021 8:10:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Dim_Comment](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Comment] [nvarchar](1000) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Dim_DataType]    Script Date: 9/10/2021 8:10:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Dim_DataType](
	[ID] [int] NOT NULL,
	[DataType] [nvarchar](20) NULL,
 CONSTRAINT [pk_DataType] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Dim_Device]    Script Date: 9/10/2021 8:10:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Dim_Device](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CompanyID] [int] NOT NULL,
	[DeviceName] [nvarchar](512) NOT NULL,
	[CreatedDate] [smalldatetime] NOT NULL,
	[DeletedDate] [smalldatetime] NULL,
	[IsActive] [bit] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Dim_EmployeeTitle]    Script Date: 9/10/2021 8:10:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Dim_EmployeeTitle](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CompanyID] [int] NOT NULL,
	[EmployeeTitleID] [int] NOT NULL,
	[EmployeeTitleCode] [nvarchar](255) NOT NULL,
	[EmployeeTitle] [nvarchar](512) NOT NULL,
	[DateCreated] [smalldatetime] NOT NULL,
	[DateDeleted] [smalldatetime] NULL,
	[IsActive] [bit] NOT NULL,
	[CurrentTimestamp] [timestamp] NOT NULL,
 CONSTRAINT [pk_EmployeeTitle] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [uc_EmployeeTitle] UNIQUE NONCLUSTERED 
(
	[CompanyID] ASC,
	[EmployeeTitleID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Dim_FileSystemPattern]    Script Date: 9/10/2021 8:10:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Dim_FileSystemPattern](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SysPattern] [nvarchar](100) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Dim_GlobalPrivate]    Script Date: 9/10/2021 8:10:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Dim_GlobalPrivate](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[AppKeyWord] [nvarchar](200) NOT NULL,
	[Activity] [nvarchar](200) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Dim_Holiday]    Script Date: 9/10/2021 8:10:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Dim_Holiday](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CompanyID] [int] NOT NULL,
	[HolidayID] [int] NOT NULL,
	[HolidayName] [nvarchar](256) NOT NULL,
	[HolidayDateFrom] [smalldatetime] NOT NULL,
	[HolidayDateTo] [smalldatetime] NULL,
	[IsActive] [bit] NOT NULL,
	[ModifiedBy] [nvarchar](256) NOT NULL,
 CONSTRAINT [pk_Holiday] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[CompanyID] ASC,
	[HolidayID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Dim_IntegrationEntity]    Script Date: 9/10/2021 8:10:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Dim_IntegrationEntity](
	[EntityID] [int] IDENTITY(1,1) NOT NULL,
	[IntegrationSourceID] [int] NOT NULL,
	[EntityName] [nvarchar](4000) NOT NULL,
 CONSTRAINT [PK_Dim_IntegrationEntity] PRIMARY KEY CLUSTERED 
(
	[EntityID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Dim_Network]    Script Date: 9/10/2021 8:10:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Dim_Network](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CompanyID] [int] NOT NULL,
	[NetworkName] [nvarchar](255) NOT NULL,
	[CreatedDate] [smalldatetime] NOT NULL,
	[IsOfficeNetwork] [bit] NULL,
	[AnalysisDate] [date] NULL,
 CONSTRAINT [pk_Network] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [uc_Network] UNIQUE NONCLUSTERED 
(
	[CompanyID] ASC,
	[NetworkName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Dim_Platform]    Script Date: 9/10/2021 8:10:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Dim_Platform](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CompanyID] [int] NOT NULL,
	[PlatformID] [int] NOT NULL,
	[PlatformName] [nvarchar](512) NOT NULL,
	[PlatformVersion] [nvarchar](256) NULL,
	[PlatformDescription] [nvarchar](1024) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[ModifiedBy] [nvarchar](256) NOT NULL,
 CONSTRAINT [pk_Platform] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[CompanyID] ASC,
	[PlatformID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Dim_Settings]    Script Date: 9/10/2021 8:10:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Dim_Settings](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SettingID] [int] NOT NULL,
	[SettingName] [nvarchar](4000) NOT NULL,
	[DefaultValue] [nvarchar](1000) NOT NULL,
 CONSTRAINT [PK_Dim_Settings] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Dim_UserProfile]    Script Date: 9/10/2021 8:10:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Dim_UserProfile](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CompanyID] [int] NOT NULL,
	[UserProfileID] [int] NOT NULL,
	[ProfileName] [nvarchar](100) NOT NULL,
	[ProfileDescription] [nvarchar](300) NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [pk_UserProfile] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[CompanyID] ASC,
	[UserProfileID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Dim_WorkSchedule]    Script Date: 9/10/2021 8:10:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Dim_WorkSchedule](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CompanyID] [int] NOT NULL,
	[WorkScheduleID] [int] NOT NULL,
	[WorkScheduleName] [nvarchar](100) NOT NULL,
	[WorkScheduleDescription] [nvarchar](300) NULL,
	[IsDefault] [bit] NOT NULL,
	[WorkWeekTotalHours] [float] NOT NULL,
	[IsWorkWeekCustom] [bit] NOT NULL,
	[IsSunWorkDay] [bit] NULL,
	[IsMonWorkDay] [bit] NULL,
	[IsTuesWorkDay] [bit] NULL,
	[IsWedWorkDay] [bit] NULL,
	[IsThuWorkDay] [bit] NULL,
	[IsFriWorkDay] [bit] NULL,
	[IsSatWorkDay] [bit] NULL,
	[ReportDataStartTime] [time](7) NULL,
	[ReportDataEndTime] [time](7) NULL,
	[ReportNonWorkDayActivityAsWork] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[ModifiedBy] [nvarchar](100) NOT NULL,
	[StartDay] [int] NULL,
	[Capacity] [float] NULL,
 CONSTRAINT [pk_WorkSchedule] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[CompanyID] ASC,
	[WorkScheduleID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[DUmmyFact_DailyActivity]    Script Date: 9/10/2021 8:10:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[DUmmyFact_DailyActivity](
	[Dim_UserID] [int] NOT NULL,
	[Dim_CompanyID] [int] NOT NULL,
	[ActivityDate] [date] NOT NULL,
	[Dim_DeviceID] [int] NULL,
	[Dim_AppMasterID] [int] NOT NULL,
	[Dim_ActivityCategoryID] [int] NOT NULL,
	[FileOrUrlID] [int] NOT NULL,
	[IsFileOrUrl] [bit] NOT NULL,
	[PurposeID] [int] NOT NULL,
	[IsOnPc] [bit] NOT NULL,
	[TimeSpentInCalendarDay] [real] NOT NULL,
	[TimeSpentInShift] [real] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[DUmmyFact_DailyUser]    Script Date: 9/10/2021 8:10:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[DUmmyFact_DailyUser](
	[Dim_UserId] [int] NOT NULL,
	[Dim_CompanyID] [int] NOT NULL,
	[ActivityDate] [date] NOT NULL,
	[Start_Time] [datetime] NOT NULL,
	[End_Time] [datetime] NOT NULL,
	[FirstOnPcTime] [datetime] NULL,
	[LastOnPcTime] [datetime] NULL,
	[EstimatedTimeSpent] [real] NOT NULL,
	[OnlineTimeSpent] [real] NOT NULL,
	[OfflineTimeSpent] [real] NOT NULL,
	[PrivateTimeSpent] [real] NOT NULL,
	[UnaccountedTimeSpent] [real] NOT NULL,
	[FocusTimeInCalendarDay] [real] NOT NULL,
	[FocusTimeInShift] [real] NOT NULL,
	[MaxUnaccountedSlotTime] [real] NULL,
	[FirstOnPCTimeInUTC] [datetime] NULL,
	[LastOnPCTimeInUTC] [datetime] NULL,
	[MaxUnaccountedTimeWithPreviousDay] [real] NULL,
	[BreakTime_19_or_less] [real] NULL,
	[BreakTime_20_to_45] [real] NULL,
	[BreakTime_46_or_more] [real] NULL,
	[NumberOfBreak_19_or_less] [int] NULL,
	[NumberOfBreak_20_to_45] [int] NULL,
	[NumberOfBreak_46_or_more] [int] NULL,
	[BreakTimeInCalenderDay]  AS ((coalesce([BreakTime_19_or_less],(0))+coalesce([BreakTime_20_to_45],(0)))+coalesce([BreakTime_46_or_more],(0))),
	[NumberOfBreakInCalenderDay]  AS ((coalesce([NumberOfBreak_19_or_less],(0))+coalesce([NumberOfBreak_20_to_45],(0)))+coalesce([NumberOfBreak_46_or_more],(0))),
	[FirstWorkPCTime] [datetime] NULL,
	[LastWorkPcTime] [datetime] NULL,
	[previous24DayDetail] [real] NULL,
	[BreakTime_30] [real] NULL,
	[NumberOfBreak_30] [int] NULL,
	[MaxUnaccountedWorkTimeWithPreviousDay] [real] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[DummyFact_DailyUserEmail]    Script Date: 9/10/2021 8:10:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[DummyFact_DailyUserEmail](
	[Dim_UserId] [int] NOT NULL,
	[Dim_CompanyID] [int] NOT NULL,
	[ActivityDate] [date] NOT NULL,
	[NumberOfSentEmails] [int] NULL,
	[NumberOfReceivedEmails] [int] NULL,
	[NumberOfUnreadEmails] [int] NULL,
	[AvgResponseTime] [real] NULL,
	[NumberOfAllRecipients] [int] NULL,
	[NumberOfTeamRecipients] [int] NULL,
	[NumberOfDepartmentRecipients] [int] NULL,
	[NumberOfCompanyRecipients] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[DummyFact_TimeSlot]    Script Date: 9/10/2021 8:10:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[DummyFact_TimeSlot](
	[Dim_UserID] [int] NOT NULL,
	[Dim_CompanyID] [int] NOT NULL,
	[Dim_AppMasterID] [int] NOT NULL,
	[Dim_ActivityCategoryID] [int] NOT NULL,
	[Dim_DeviceID] [int] NULL,
	[ActivityDate] [date] NOT NULL,
	[StartTimeInLocal]  AS (dateadd(minute,[TimeZoneOffset],[StartTimeInUTC])) PERSISTED,
	[EndTimeInLocal]  AS (dateadd(minute,[TimeZoneOffset],[EndTimeInUTC])) PERSISTED,
	[DeviceID] [int] NULL,
	[FileOrUrlName] [nvarchar](4000) NOT NULL,
	[IsFileOrUrl] [bit] NOT NULL,
	[PurposeID] [int] NOT NULL,
	[IsOnPc] [bit] NOT NULL,
	[IsShift] [bit] NOT NULL,
	[StartTimeInUTC] [datetime] NOT NULL,
	[EndTimeInUTC] [datetime] NOT NULL,
	[TimeZoneOffset] [smallint] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[TimeSpent] [real] NOT NULL,
	[UploadTime] [datetime] NOT NULL,
	[IsUserModified] [bit] NOT NULL,
	[ModifiedBy] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[DummyFact_TimeSlotMeeting]    Script Date: 9/10/2021 8:10:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[DummyFact_TimeSlotMeeting](
	[Dim_UserID] [int] NOT NULL,
	[Dim_CompanyID] [int] NOT NULL,
	[Dim_DeviceID] [int] NULL,
	[ActivityDate] [datetime] NOT NULL,
	[MeetingID] [nvarchar](512) NOT NULL,
	[MeetingSubject] [nvarchar](512) NOT NULL,
	[MeetingStartTimeUTC] [datetime] NOT NULL,
	[MeetingEndTimeUTC] [datetime] NOT NULL,
	[MeetingStartTimeLocal] [datetime] NOT NULL,
	[MeetingEndTimeLocal] [datetime] NOT NULL,
	[MeetingTimeZoneOffSet] [real] NOT NULL,
	[MeetingDuration] [int] NOT NULL,
	[MeetingBusyStatus] [nvarchar](256) NOT NULL,
	[MeetingResponseStatus] [nvarchar](256) NOT NULL,
	[MeetingSensitivity] [nvarchar](256) NOT NULL,
	[Meetingstatus] [nvarchar](256) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[UploadTime] [datetime] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[DummyStg_TimeSlot]    Script Date: 9/10/2021 8:10:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[DummyStg_TimeSlot](
	[Dim_UserID] [int] NOT NULL,
	[Dim_CompanyID] [int] NOT NULL,
	[Dim_AppMasterID] [int] NOT NULL,
	[Dim_ActivityCategoryID] [int] NOT NULL,
	[Dim_DeviceID] [int] NULL,
	[ActivityDate] [date] NOT NULL,
	[StartTimeInLocal]  AS (dateadd(minute,[TimeZoneOffset],[StartTimeInUTC])) PERSISTED,
	[EndTimeInLocal]  AS (dateadd(minute,[TimeZoneOffset],[EndTimeInUTC])) PERSISTED,
	[DeviceID] [int] NULL,
	[FileOrUrlName] [nvarchar](4000) NOT NULL,
	[IsFileOrUrl] [bit] NOT NULL,
	[PurposeID] [int] NOT NULL,
	[IsOnPc] [bit] NOT NULL,
	[IsShift] [bit] NOT NULL,
	[StartTimeInUTC] [datetime] NOT NULL,
	[EndTimeInUTC] [datetime] NOT NULL,
	[TimeZoneOffset] [smallint] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[TimeSpent] [real] NOT NULL,
	[IsUserModified] [bit] NOT NULL,
	[ModifiedBy] [int] NULL,
	[UploadTime] [datetime] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Fact_ActivityPred]    Script Date: 9/10/2021 8:10:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Fact_ActivityPred](
	[Dim_CompanyID] [int] NOT NULL,
	[Dim_UserID] [int] NOT NULL,
	[ActivityDate] [date] NOT NULL,
	[Weekday] [varchar](20) NULL,
	[Dim_ActivityCategoryID] [int] NULL,
	[Prediction] [float] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Fact_AppClassification_Exe]    Script Date: 9/10/2021 8:10:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Fact_AppClassification_Exe](
	[Dim_CompanyID] [int] NOT NULL,
	[Dim_JobFamilyProfileID] [int] NOT NULL,
	[ExeName] [nvarchar](200) NOT NULL,
	[AppName] [nvarchar](200) NOT NULL,
	[ActivityCategoryName] [nvarchar](1000) NOT NULL,
	[Time] [float] NOT NULL,
	[UserCount] [int] NOT NULL,
	[ConfidenceMapping] [nvarchar](200) NOT NULL,
	[MappingComment] [nvarchar](200) NOT NULL,
	[AnalysisDate] [date] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Fact_AppPred]    Script Date: 9/10/2021 8:10:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Fact_AppPred](
	[Dim_UserID] [int] NOT NULL,
	[Dim_AppParentID] [int] NOT NULL,
	[ActivityDate] [date] NOT NULL,
	[Day] [varchar](20) NOT NULL,
	[Pred_Time] [float] NOT NULL,
	[IsProcessed] [bit] NOT NULL,
	[UploadTime] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Fact_DailyActivityPred]    Script Date: 9/10/2021 8:10:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Fact_DailyActivityPred](
	[Dim_CompanyID] [int] NOT NULL,
	[Dim_UserID] [int] NOT NULL,
	[ActivityDate] [date] NOT NULL,
	[Dim_DeviceID] [int] NULL,
	[Dim_AppParentID] [int] NULL,
	[Dim_WebAppID] [int] NULL,
	[Dim_ActivityCategoryID] [int] NOT NULL,
	[PurposeID] [int] NOT NULL,
	[IsOnPc] [bit] NOT NULL,
	[TimeSpentInCalendarDay] [real] NOT NULL,
	[TimeSpentInShift] [real] NOT NULL,
	[IsCore] [bit] NULL,
 CONSTRAINT [IX_Fact_DailyActivityPred] UNIQUE NONCLUSTERED 
(
	[Dim_CompanyID] ASC,
	[Dim_UserID] ASC,
	[ActivityDate] ASC,
	[Dim_DeviceID] ASC,
	[Dim_AppParentID] ASC,
	[Dim_WebAppID] ASC,
	[Dim_ActivityCategoryID] ASC,
	[PurposeID] ASC,
	[IsOnPc] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Fact_DailyActivityTest]    Script Date: 9/10/2021 8:10:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Fact_DailyActivityTest](
	[Dim_UserID] [int] NOT NULL,
	[Dim_CompanyID] [int] NOT NULL,
	[ActivityDate] [date] NOT NULL,
	[Dim_DeviceID] [int] NULL,
	[Dim_AppMasterID] [int] NULL,
	[Dim_ActivityCategoryID] [int] NOT NULL,
	[FileOrUrlID] [int] NOT NULL,
	[IsFileOrUrl] [bit] NOT NULL,
	[PurposeID] [int] NOT NULL,
	[IsOnPc] [bit] NOT NULL,
	[TimeSpentInCalendarDay] [real] NOT NULL,
	[TimeSpentInShift] [real] NOT NULL,
	[Dim_WebAppID] [int] NULL,
	[IsCore] [bit] NULL,
	[Dim_NetworkID] [int] NULL,
	[Dim_MachineID] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Fact_DailyPredVue]    Script Date: 9/10/2021 8:10:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Fact_DailyPredVue](
	[Dim_CompanyID] [int] NOT NULL,
	[Dim_UserID] [int] NOT NULL,
	[ActivityDate] [smalldatetime] NOT NULL,
	[Day] [varchar](20) NULL,
	[Pred_Work_Hrs] [float] NULL,
	[Pred_Private_Hrs] [float] NULL,
	[Pred_Unaccounted_Hrs] [float] NULL,
	[Pred_Focus_Hrs] [float] NULL,
	[Pred_Meeting_Hrs] [float] NULL,
	[Pred_Core_Hrs] [float] NULL,
 CONSTRAINT [PK_Fact_DailyPredVue] PRIMARY KEY CLUSTERED 
(
	[Dim_UserID] ASC,
	[Dim_CompanyID] ASC,
	[ActivityDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Fact_DailyPredVueDup]    Script Date: 9/10/2021 8:10:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Fact_DailyPredVueDup](
	[Dim_CompanyID] [int] NOT NULL,
	[Dim_UserID] [int] NOT NULL,
	[ActivityDate] [smalldatetime] NOT NULL,
	[Day] [varchar](20) NULL,
	[Pred_Work_Hrs] [float] NULL,
	[Pred_Private_Hrs] [float] NULL,
	[Pred_Unaccounted_Hrs] [float] NULL,
	[Pred_Focus_Hrs] [float] NULL,
	[Pred_Meeting_Hrs] [float] NULL,
	[Pred_Core_Hrs] [float] NULL,
 CONSTRAINT [PK_Fact_DailyPredVueDup] PRIMARY KEY CLUSTERED 
(
	[Dim_UserID] ASC,
	[Dim_CompanyID] ASC,
	[ActivityDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Fact_DailyUserEmail]    Script Date: 9/10/2021 8:10:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Fact_DailyUserEmail](
	[Dim_UserId] [int] NOT NULL,
	[Dim_CompanyID] [int] NOT NULL,
	[ActivityDate] [date] NOT NULL,
	[NumberOfSentEmails] [int] NULL,
	[NumberOfReceivedEmails] [int] NULL,
	[NumberOfUnreadEmails] [int] NULL,
	[AvgResponseTime] [real] NULL,
	[NumberOfAllRecipients] [int] NULL,
	[NumberOfTeamRecipients] [int] NULL,
	[NumberOfDepartmentRecipients] [int] NULL,
	[NumberOfCompanyRecipients] [int] NULL,
 CONSTRAINT [PK_FactDailyUserEmail] PRIMARY KEY CLUSTERED 
(
	[Dim_UserId] ASC,
	[Dim_CompanyID] ASC,
	[ActivityDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [psc_CompanyID]([Dim_CompanyID])
) ON [psc_CompanyID]([Dim_CompanyID])
GO
/****** Object:  Table [edw].[Fact_DailyUserTest]    Script Date: 9/10/2021 8:10:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Fact_DailyUser](
	[Dim_UserId] [int] NOT NULL,
	[Dim_CompanyID] [int] NOT NULL,
	[ActivityDate] [date] NOT NULL,
	[Start_Time] [datetime] NOT NULL,
	[End_Time] [datetime] NOT NULL,
	[FirstOnPcTime] [datetime] NULL,
	[LastOnPcTime] [datetime] NULL,
	[EstimatedTimeSpent] [real] NOT NULL,
	[OnlineTimeSpent] [real] NOT NULL,
	[OfflineTimeSpent] [real] NOT NULL,
	[PrivateTimeSpent] [real] NOT NULL,
	[UnaccountedTimeSpent] [real] NOT NULL,
	[FocusTimeInCalendarDay] [real] NOT NULL,
	[FocusTimeInShift] [real] NOT NULL,
	[MaxUnaccountedSlotTime] [real] NULL,
	[FirstOnPCTimeInUTC] [datetime] NULL,
	[LastOnPCTimeInUTC] [datetime] NULL,
	[MaxUnaccountedTimeWithPreviousDay] [real] NULL,
	[BreakTime_19_or_less] [real] NULL,
	[BreakTime_20_to_45] [real] NULL,
	[BreakTime_46_or_more] [real] NULL,
	[NumberOfBreak_19_or_less] [int] NULL,
	[NumberOfBreak_20_to_45] [int] NULL,
	[NumberOfBreak_46_or_more] [int] NULL,
	[BreakTimeInCalenderDay]  AS ((coalesce([BreakTime_19_or_less],(0))+coalesce([BreakTime_20_to_45],(0)))+coalesce([BreakTime_46_or_more],(0))),
	[NumberOfBreakInCalenderDay]  AS ((coalesce([NumberOfBreak_19_or_less],(0))+coalesce([NumberOfBreak_20_to_45],(0)))+coalesce([NumberOfBreak_46_or_more],(0))),
	[FirstWorkPCTime] [datetime] NULL,
	[LastWorkPcTime] [datetime] NULL,
	[previous24DayDetail] [real] NULL,
	[BreakTime_30] [real] NULL,
	[NumberOfBreak_30] [int] NULL,
	[MaxUnaccountedWorkTimeWithPreviousDay] [real] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Fact_DynamicActivityPred]    Script Date: 9/10/2021 8:10:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Fact_DynamicActivityPred](
	[Dim_CompanyID] [int] NOT NULL,
	[Dim_UserID] [int] NOT NULL,
	[ActivityDate] [date] NOT NULL,
	[Dim_ActivityCategoryID] [int] NULL,
	[TimeSpentInCalendarDay] [float] NULL,
	[Lowerbound] [float] NULL,
	[Upperbound] [float] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Fact_DynamicCategoryPred]    Script Date: 9/10/2021 8:10:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Fact_DynamicCategoryPred](
	[Dim_CompanyID] [int] NOT NULL,
	[Dim_UserID] [int] NOT NULL,
	[ActivityDate] [date] NOT NULL,
	[Day] [nvarchar](50) NOT NULL,
	[CoreTime] [float] NULL,
	[Focus] [float] NULL,
	[MeetingTime] [float] NULL,
	[OfflineTimeSpent] [float] NULL,
	[OnlineTimeSpent] [float] NULL,
	[PrivateTimeSpent] [float] NULL,
	[UnaccountedTimeSpent] [float] NULL,
 CONSTRAINT [PK_Fact_DynamicCategoryPred] PRIMARY KEY CLUSTERED 
(
	[Dim_UserID] ASC,
	[ActivityDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Fact_DynamicUtilizationPred]    Script Date: 9/10/2021 8:10:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Fact_DynamicUtilizationPred](
	[Dim_UserId] [int] NOT NULL,
	[Dim_CompanyID] [int] NOT NULL,
	[ActivityDate] [date] NOT NULL,
	[Utilization] [float] NOT NULL,
 CONSTRAINT [PK_FactDynamicUtilizationPred] PRIMARY KEY CLUSTERED 
(
	[Dim_UserId] ASC,
	[ActivityDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Fact_EditedUnaccountedUser]    Script Date: 9/10/2021 8:10:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Fact_EditedUnaccountedUser](
	[Dim_CompanyID] [int] NOT NULL,
	[Dim_UserID] [int] NOT NULL,
	[Dim_ActivityCategoryID] [int] NULL,
	[ActivityDate] [date] NOT NULL,
	[Unaccounted_StartTime] [datetime] NULL,
	[Unaccounted_EndTime] [datetime] NULL,
	[Edited_UTCStartTime] [datetime] NOT NULL,
	[Edited_UTCEndTime] [datetime] NOT NULL,
	[ModifiedBy] [int] NULL,
	[TimeZoneOffset] [smallint] NULL,
	[Edited_StartTime]  AS (dateadd(minute,[TimeZoneOffset],[Edited_UTCStartTime])) PERSISTED,
	[Edited_EndTime]  AS (dateadd(minute,[TimeZoneOffset],[Edited_UTCEndTime])) PERSISTED,
 CONSTRAINT [IX_Fact_UnaccountedUser] UNIQUE NONCLUSTERED 
(
	[Dim_CompanyID] ASC,
	[Dim_UserID] ASC,
	[ActivityDate] ASC,
	[Edited_UTCStartTime] ASC,
	[Edited_UTCEndTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [psc_CompanyID]([Dim_CompanyID])
) ON [psc_CompanyID]([Dim_CompanyID])
GO
/****** Object:  Table [edw].[Fact_EmailUser]    Script Date: 9/10/2021 8:10:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Fact_EmailUser](
	[Dim_CompanyID] [int] NOT NULL,
	[Dim_UserID] [int] NOT NULL,
	[ActivityDate] [date] NOT NULL,
	[NumberOfSentEmails] [int] NOT NULL,
	[NumberOfReceivedEmails] [int] NOT NULL,
	[NumberOfUnreadEmails] [int] NOT NULL,
	[AvgResponseTime] [real] NOT NULL,
	[NumberOfAllRecipients] [int] NULL,
	[NumberOfTeamRecipients] [int] NULL,
	[NumberOfDepartmentRecipients] [int] NULL,
	[NumberOfRecipientsInCompany] [int] NULL,
 CONSTRAINT [IX_Fact_EmailUser] UNIQUE NONCLUSTERED 
(
	[Dim_CompanyID] ASC,
	[Dim_UserID] ASC,
	[ActivityDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [psc_CompanyID]([Dim_CompanyID])
) ON [psc_CompanyID]([Dim_CompanyID])
GO
/****** Object:  Table [edw].[Fact_FeatureSelectionImpact]    Script Date: 9/10/2021 8:10:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Fact_FeatureSelectionImpact](
	[Month] [int] NULL,
	[Dim_CompanyID] [int] NULL,
	[Dim_EmployeeTitleID] [int] NULL,
	[Variable_Explored] [nvarchar](200) NULL,
	[Impacting_Variable] [nvarchar](200) NULL,
	[Impact_Minutes] [float] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Fact_JobFamilyAnomaly]    Script Date: 9/10/2021 8:10:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Fact_JobFamilyAnomaly](
	[Dim_CompanyID] [int] NOT NULL,
	[Dim_UserID] [int] NOT NULL,
	[AppName] [nvarchar](2048) NOT NULL,
	[FirstName] [varchar](255) NOT NULL,
	[LastName] [varchar](255) NOT NULL,
	[AnalysisDate] [date] NOT NULL,
	[Minutes] [float] NOT NULL,
	[AllDistances] [float] NOT NULL,
	[Dim_JobFamilyProfileID] [int] NOT NULL,
	[JobFamilyName] [nvarchar](100) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Fact_MeetingImpact]    Script Date: 9/10/2021 8:10:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Fact_MeetingImpact](
	[Dim_CompanyID] [int] NOT NULL,
	[Dim_JobFamilyProfileID] [int] NOT NULL,
	[JobFamilyName] [nvarchar](100) NOT NULL,
	[MeetingImpact] [float] NOT NULL,
	[AnalysisDate] [date] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Fact_TimeSlot_Obfus]    Script Date: 9/10/2021 8:10:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Fact_TimeSlot_Obfus](
	[Dim_UserID] [int] NOT NULL,
	[Dim_CompanyID] [int] NOT NULL,
	[Dim_AppMasterID] [int] NULL,
	[Dim_ActivityCategoryID] [int] NOT NULL,
	[Dim_DeviceID] [int] NULL,
	[ActivityDate] [date] NOT NULL,
	[StartTimeInLocal]  AS (dateadd(minute,[TimeZoneOffset],[StartTimeInUTC])) PERSISTED,
	[EndTimeInLocal]  AS (dateadd(minute,[TimeZoneOffset],[EndTimeInUTC])) PERSISTED,
	[DeviceID] [int] NULL,
	[FileOrUrlName] [nvarchar](4000) NOT NULL,
	[IsFileOrUrl] [bit] NOT NULL,
	[PurposeID] [int] NOT NULL,
	[IsOnPc] [bit] NOT NULL,
	[IsShift] [bit] NOT NULL,
	[StartTimeInUTC] [datetime] NOT NULL,
	[EndTimeInUTC] [datetime] NOT NULL,
	[TimeZoneOffset] [smallint] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[TimeSpent] [real] NOT NULL,
	[UploadTime] [datetime] NOT NULL,
	[IsUserModified] [bit] NOT NULL,
	[ModifiedBy] [int] NULL,
	[Dim_WebAppID] [int] NULL,
	[IsCore] [bit] NULL,
	[Dim_MachineID] [int] NULL,
	[Dim_NetworkID] [int] NULL,
	[URLDomain] [nvarchar](200) NULL,
	[ETL_ModifiedBy] [varchar](8000) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Fact_TimeSlotMeeting]    Script Date: 9/10/2021 8:10:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Fact_TimeSlotMeeting](
	[Dim_UserID] [int] NOT NULL,
	[Dim_CompanyID] [int] NOT NULL,
	[Dim_DeviceID] [int] NULL,
	[ActivityDate] [datetime] NOT NULL,
	[MeetingID] [nvarchar](512) NOT NULL,
	[MeetingSubject] [nvarchar](512) NOT NULL,
	[MeetingStartTimeUTC] [datetime] NOT NULL,
	[MeetingEndTimeUTC] [datetime] NOT NULL,
	[MeetingStartTimeLocal] [datetime] NOT NULL,
	[MeetingEndTimeLocal] [datetime] NOT NULL,
	[MeetingTimeZoneOffSet] [real] NOT NULL,
	[MeetingDuration] [int] NOT NULL,
	[MeetingBusyStatus] [nvarchar](256) NOT NULL,
	[MeetingResponseStatus] [nvarchar](256) NOT NULL,
	[MeetingSensitivity] [nvarchar](256) NOT NULL,
	[Meetingstatus] [nvarchar](256) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[UploadTime] [datetime] NOT NULL,
	[Dim_MachineID] [int] NULL,
	[Dim_NetworkID] [int] NULL,
	[Source] [nvarchar](20) NULL,
	[Recipients] [nvarchar](2000) NULL,
	[WorkTimeInMeeting] [real] NOT NULL,
	[PrivateTimeInMeeting] [real] NOT NULL,
	[RecipientsCount] [int] NULL
) ON [psc_CompanyID]([Dim_CompanyID])
GO
/****** Object:  Table [edw].[Fact_TimeSlotMeetingTest]    Script Date: 9/10/2021 8:10:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Fact_TimeSlotMeetingTest](
	[Dim_UserID] [int] NOT NULL,
	[Dim_CompanyID] [int] NOT NULL,
	[Dim_DeviceID] [int] NULL,
	[ActivityDate] [datetime] NOT NULL,
	[MeetingID] [nvarchar](512) NOT NULL,
	[MeetingSubject] [nvarchar](512) NOT NULL,
	[MeetingStartTimeUTC] [datetime] NOT NULL,
	[MeetingEndTimeUTC] [datetime] NOT NULL,
	[MeetingStartTimeLocal] [datetime] NOT NULL,
	[MeetingEndTimeLocal] [datetime] NOT NULL,
	[MeetingTimeZoneOffSet] [real] NOT NULL,
	[MeetingDuration] [int] NOT NULL,
	[MeetingBusyStatus] [nvarchar](256) NOT NULL,
	[MeetingResponseStatus] [nvarchar](256) NOT NULL,
	[MeetingSensitivity] [nvarchar](256) NOT NULL,
	[Meetingstatus] [nvarchar](256) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[UploadTime] [datetime] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Fact_TimeSlotTemp]    Script Date: 9/10/2021 8:10:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Fact_TimeSlotTemp](
	[Dim_UserID] [int] NOT NULL,
	[Dim_CompanyID] [int] NOT NULL,
	[Dim_AppMasterID] [int] NOT NULL,
	[Dim_ActivityCategoryID] [int] NOT NULL,
	[Dim_DeviceID] [int] NULL,
	[ActivityDate] [date] NOT NULL,
	[StartTimeInLocal]  AS (dateadd(minute,[TimeZoneOffset],[StartTimeInUTC])) PERSISTED,
	[EndTimeInLocal]  AS (dateadd(minute,[TimeZoneOffset],[EndTimeInUTC])) PERSISTED,
	[DeviceID] [int] NULL,
	[FileOrUrlName] [nvarchar](4000) NOT NULL,
	[IsFileOrUrl] [bit] NOT NULL,
	[PurposeID] [int] NOT NULL,
	[IsOnPc] [bit] NOT NULL,
	[IsShift] [bit] NOT NULL,
	[StartTimeInUTC] [datetime] NOT NULL,
	[EndTimeInUTC] [datetime] NOT NULL,
	[TimeZoneOffset] [smallint] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[TimeSpent] [real] NOT NULL,
	[UploadTime] [datetime] NOT NULL,
	[IsUserModified] [bit] NOT NULL,
	[ModifiedBy] [int] NULL,
	[IsStgTimeSlot] [bit] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Fact_UnmappedAppUsage]    Script Date: 9/10/2021 8:10:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Fact_UnmappedAppUsage](
	[Dim_CompanyID] [int] NOT NULL,
	[Dim_AppParentID] [int] NULL,
	[URL_Domain] [nvarchar](300) NULL,
	[TimeSpent] [real] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Fact_WebAppMetrics]    Script Date: 9/10/2021 8:10:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Fact_WebAppMetrics](
	[Dim_UserID] [int] NOT NULL,
	[Dim_CompanyID] [int] NOT NULL,
	[Dim_AppMasterID] [int] NULL,
	[Dim_ActivityCategoryID] [int] NOT NULL,
	[Dim_DeviceID] [int] NULL,
	[ActivityDate] [date] NOT NULL,
	[StartTimeInLocal]  AS (dateadd(minute,[TimeZoneOffset],[StartTimeInUTC])) PERSISTED,
	[EndTimeInLocal]  AS (dateadd(minute,[TimeZoneOffset],[EndTimeInUTC])) PERSISTED,
	[DeviceID] [int] NULL,
	[FileOrUrlName] [nvarchar](4000) NOT NULL,
	[PurposeID] [int] NOT NULL,
	[IsOnPc] [bit] NOT NULL,
	[IsShift] [bit] NOT NULL,
	[StartTimeInUTC] [datetime] NOT NULL,
	[EndTimeInUTC] [datetime] NOT NULL,
	[TimeZoneOffset] [smallint] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[TimeSpent] [real] NOT NULL,
	[UploadTime] [datetime] NOT NULL,
	[IsUserModified] [bit] NOT NULL,
	[ModifiedBy] [int] NULL,
	[Dim_WebAppID] [int] NULL,
	[IsCore] [bit] NULL,
	[Dim_MachineID] [int] NULL,
	[Dim_NetworkID] [int] NULL,
	[URLDomain] [nvarchar](200) NULL,
	[ETL_ModifiedBy] [varchar](8000) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Hst_Lenses]    Script Date: 9/10/2021 8:10:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Hst_Lenses](
	[TenantID] [int] NULL,
	[LineofBusinessID] [int] NULL,
	[sessionId] [nvarchar](50) NULL,
	[tzoffset] [nvarchar](5) NULL,
	[productVersion] [nvarchar](256) NULL,
	[fileDescription] [nvarchar](500) NULL,
	[exeName] [nvarchar](500) NULL,
	[activityDomain] [nvarchar](100) NULL,
	[activityUserID] [nvarchar](200) NULL,
	[deviceId] [nvarchar](200) NULL,
	[windowTitle] [nvarchar](1000) NULL,
	[url] [nvarchar](1000) NULL,
	[activityTime] [datetime] NULL,
	[activityType] [nvarchar](20) NULL,
	[meetingID] [nvarchar](500) NULL,
	[meetingSubject] [nvarchar](300) NULL,
	[meetingStart] [datetime] NULL,
	[meetingEnd] [datetime] NULL,
	[meetingDuration] [smallint] NULL,
	[meetingActivityVersion] [nvarchar](100) NULL,
	[meetingBusyStatus] [nvarchar](100) NULL,
	[meetingResponseStatus] [nvarchar](100) NULL,
	[meetingSensitivity] [nvarchar](100) NULL,
	[meetingStatus] [nvarchar](100) NULL,
	[offset] [bigint] NULL,
	[time_stamp] [smalldatetime] NULL,
	[machineName] [nvarchar](400) NULL,
	[networkname] [nvarchar](400) NULL,
	[keyboardHardEvents] [smallint] NULL,
	[keyboardSoftEvents] [smallint] NULL,
	[mouseHardEvents] [smallint] NULL,
	[mouseSoftEvents] [smallint] NULL,
	[meetingRecipients] [nvarchar](4000) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[HST_LENSESTEST1]    Script Date: 9/10/2021 8:10:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[HST_LENSESTEST1](
	[TenantID] [int] NULL,
	[LineofBusinessID] [int] NULL,
	[sessionId] [nvarchar](50) NULL,
	[tzoffset] [nvarchar](5) NULL,
	[productVersion] [nvarchar](256) NULL,
	[fileDescription] [nvarchar](500) NULL,
	[exeName] [nvarchar](500) NULL,
	[activityDomain] [nvarchar](100) NULL,
	[activityUserID] [nvarchar](200) NULL,
	[deviceId] [nvarchar](200) NULL,
	[windowTitle] [nvarchar](1000) NULL,
	[url] [nvarchar](1000) NULL,
	[activityTime] [datetime] NULL,
	[activityType] [nvarchar](20) NULL,
	[meetingID] [nvarchar](500) NULL,
	[meetingSubject] [nvarchar](300) NULL,
	[meetingStart] [datetime] NULL,
	[meetingEnd] [datetime] NULL,
	[meetingDuration] [smallint] NULL,
	[meetingActivityVersion] [nvarchar](100) NULL,
	[meetingBusyStatus] [nvarchar](100) NULL,
	[meetingResponseStatus] [nvarchar](100) NULL,
	[meetingSensitivity] [nvarchar](100) NULL,
	[meetingStatus] [nvarchar](100) NULL,
	[offset] [bigint] NULL,
	[time_stamp] [smalldatetime] NULL,
	[machineName] [nvarchar](400) NULL,
	[networkname] [nvarchar](400) NULL,
	[keyboardHardEvents] [smallint] NULL,
	[keyboardSoftEvents] [smallint] NULL,
	[mouseHardEvents] [smallint] NULL,
	[mouseSoftEvents] [smallint] NULL,
	[meetingRecipients] [nvarchar](4000) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Hst_O365_Email]    Script Date: 9/10/2021 8:10:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Hst_O365_Email](
	[TenantID] [int] NULL,
	[LineofBusinessID] [int] NULL,
	[type] [nvarchar](5) NULL,
	[receivedDateTime] [datetime] NULL,
	[hasAttachments] [bit] NULL,
	[subject] [nvarchar](500) NULL,
	[importance] [nvarchar](50) NULL,
	[from_address] [nvarchar](200) NULL,
	[from_name] [nvarchar](200) NULL,
	[recipient_address] [nvarchar](200) NULL,
	[recipient_name] [nvarchar](200) NULL,
	[conversationId] [nvarchar](200) NULL,
	[id] [nvarchar](200) NULL,
	[deviceId] [nvarchar](100) NULL,
	[timestamp] [bigint] NULL,
	[tzoffset] [nvarchar](5) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Hst_Test]    Script Date: 9/10/2021 8:10:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Hst_Test](
	[TenantID] [int] NULL,
	[LineofBusinessID] [int] NULL,
	[sessionId] [nvarchar](50) NULL,
	[tzoffset] [nvarchar](5) NULL,
	[productVersion] [nvarchar](50) NULL,
	[fileDescription] [nvarchar](500) NULL,
	[exeName] [nvarchar](500) NULL,
	[activityDomain] [nvarchar](100) NULL,
	[activityUserID] [nvarchar](200) NULL,
	[deviceId] [nvarchar](200) NULL,
	[windowTitle] [nvarchar](1000) NULL,
	[url] [nvarchar](1000) NULL,
	[activityTime] [datetime] NULL,
	[activityType] [nvarchar](20) NULL,
	[meetingID] [nvarchar](500) NULL,
	[meetingSubject] [nvarchar](300) NULL,
	[meetingStart] [datetime] NULL,
	[meetingEnd] [datetime] NULL,
	[meetingDuration] [smallint] NULL,
	[meetingActivityVersion] [nvarchar](100) NULL,
	[meetingBusyStatus] [nvarchar](100) NULL,
	[meetingResponseStatus] [nvarchar](100) NULL,
	[meetingSensitivity] [nvarchar](100) NULL,
	[meetingStatus] [nvarchar](100) NULL,
	[offset] [bigint] NULL,
	[time_stamp] [smalldatetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Log_NotificationTrace]    Script Date: 9/10/2021 8:10:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Log_NotificationTrace](
	[CompanyID] [int] NULL,
	[LogData] [varchar](4000) NULL,
	[ProcessTime] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Log_TalendExceptions]    Script Date: 9/10/2021 8:10:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Log_TalendExceptions](
	[moment] [smalldatetime] NULL,
	[pid] [nvarchar](20) NULL,
	[root_pid] [nvarchar](20) NULL,
	[father_pid] [nvarchar](20) NULL,
	[project] [nvarchar](50) NULL,
	[job] [nvarchar](255) NULL,
	[context] [nvarchar](50) NULL,
	[priority] [int] NULL,
	[type] [nvarchar](255) NULL,
	[origin] [nvarchar](255) NULL,
	[message] [nvarchar](2000) NULL,
	[code] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Log_TimeSlotProcessStatus]    Script Date: 9/10/2021 8:10:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Log_TimeSlotProcessStatus](
	[CompanyID] [int] NOT NULL,
	[TimeSlotType] [tinyint] NOT NULL,
	[LastCreatedRawTimeSlotProcessedID] [bigint] NOT NULL,
	[LastRawTimeSlotProcessedTime] [datetime] NULL,
	[LastTimeSlotProcessedTime] [datetime] NOT NULL,
 CONSTRAINT [pk_TimeSlotProcessStatus] PRIMARY KEY CLUSTERED 
(
	[CompanyID] ASC,
	[TimeSlotType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Log_Trace]    Script Date: 9/10/2021 8:10:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Log_Trace](
	[Project] [nvarchar](20) NULL,
	[Job] [nvarchar](20) NULL,
	[SubJob] [nvarchar](50) NULL,
	[Duration] [int] NULL,
	[ProcessTime] [smalldatetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Log_UnaccountedDims]    Script Date: 9/10/2021 8:10:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Log_UnaccountedDims](
	[CompanyID] [int] NOT NULL,
	[Dimension] [nvarchar](50) NULL,
	[Value] [nvarchar](2048) NOT NULL,
	[DateCreated] [smalldatetime] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Meta_NotificationRule]    Script Date: 9/10/2021 8:10:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Meta_NotificationRule](
	[ID] [uniqueidentifier] NOT NULL,
	[Dim_CompanyID] [int] NOT NULL,
	[Entity] [varchar](20) NOT NULL,
	[EntityType] [varchar](20) NOT NULL,
	[AlertType] [varchar](20) NOT NULL,
	[AlertSubType] [varchar](50) NOT NULL,
	[EffectiveDate] [date] NOT NULL,
	[IsAlertPerEmployee] [bit] NOT NULL,
	[CreatedOn] [smalldatetime] NOT NULL,
	[CreatedBy] [varchar](50) NOT NULL,
	[AlertTimeFrame] [varchar](20) NOT NULL,
	[AlertOperator] [varchar](2) NOT NULL,
	[PredictiveValue] [float] NOT NULL,
 CONSTRAINT [PK__Fact_Not__3214EC27A20651C6] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[ML_test1]    Script Date: 9/10/2021 8:10:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[ML_test1](
	[index] [int] NOT NULL,
	[company] [nvarchar](100) NOT NULL,
	[value] [int] NOT NULL,
	[analysisDate] [date] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Stg_JimTest]    Script Date: 9/10/2021 8:10:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Stg_JimTest](
	[TenantID] [int] NULL,
	[LineofBusinessID] [int] NULL,
	[sessionId] [nvarchar](50) NULL,
	[tzoffset] [nvarchar](5) NULL,
	[productVersion] [nvarchar](max) NULL,
	[fileDescription] [nvarchar](500) NULL,
	[exeName] [nvarchar](500) NULL,
	[activityDomain] [nvarchar](100) NULL,
	[activityUserID] [nvarchar](200) NULL,
	[deviceId] [nvarchar](200) NULL,
	[windowTitle] [nvarchar](1000) NULL,
	[url] [nvarchar](1000) NULL,
	[activityTime] [datetime] NULL,
	[activityType] [nvarchar](20) NULL,
	[meetingID] [nvarchar](500) NULL,
	[meetingSubject] [nvarchar](300) NULL,
	[meetingStart] [datetime] NULL,
	[meetingEnd] [datetime] NULL,
	[meetingDuration] [smallint] NULL,
	[meetingActivityVersion] [nvarchar](100) NULL,
	[meetingBusyStatus] [nvarchar](100) NULL,
	[meetingResponseStatus] [nvarchar](100) NULL,
	[meetingSensitivity] [nvarchar](100) NULL,
	[meetingStatus] [nvarchar](100) NULL,
	[offset] [bigint] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [edw].[Stg_Lenses_Dup]    Script Date: 9/10/2021 8:10:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Stg_Lenses_Dup](
	[TenantID] [int] NULL,
	[LineofBusinessID] [int] NULL,
	[sessionId] [nvarchar](50) NULL,
	[tzoffset] [nvarchar](5) NULL,
	[productVersion] [nvarchar](max) NULL,
	[fileDescription] [nvarchar](500) NULL,
	[exeName] [nvarchar](500) NULL,
	[activityDomain] [nvarchar](100) NULL,
	[activityUserID] [nvarchar](200) NULL,
	[deviceId] [nvarchar](200) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [edw].[Stg_LensesTask]    Script Date: 9/10/2021 8:10:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Stg_LensesTask](
	[TenantID] [int] NULL,
	[LineofBusinessID] [int] NULL,
	[sessionId] [nvarchar](50) NULL,
	[tzoffset] [nvarchar](5) NULL,
	[productVersion] [nvarchar](256) NULL,
	[fileDescription] [nvarchar](500) NULL,
	[exeName] [nvarchar](500) NULL,
	[activityDomain] [nvarchar](100) NULL,
	[activityUserID] [nvarchar](200) NULL,
	[deviceId] [nvarchar](200) NULL,
	[windowTitle] [nvarchar](1000) NULL,
	[url] [nvarchar](1000) NULL,
	[activityTime] [datetime] NULL,
	[activityType] [nvarchar](20) NULL,
	[meetingID] [nvarchar](500) NULL,
	[meetingSubject] [nvarchar](300) NULL,
	[meetingStart] [datetime] NULL,
	[meetingEnd] [datetime] NULL,
	[meetingDuration] [smallint] NULL,
	[meetingActivityVersion] [nvarchar](100) NULL,
	[meetingBusyStatus] [nvarchar](100) NULL,
	[meetingResponseStatus] [nvarchar](100) NULL,
	[meetingSensitivity] [nvarchar](100) NULL,
	[meetingStatus] [nvarchar](100) NULL,
	[offset] [bigint] NULL,
	[time_stamp] [smalldatetime] NULL,
	[machineName] [nvarchar](400) NULL,
	[networkname] [nvarchar](400) NULL,
	[keyboardHardEvents] [smallint] NULL,
	[keyboardSoftEvents] [smallint] NULL,
	[mouseHardEvents] [smallint] NULL,
	[mouseSoftEvents] [smallint] NULL,
	[meetingRecipients] [nvarchar](4000) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Stg_O365_Email]    Script Date: 9/10/2021 8:10:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Stg_O365_Email](
	[TenantID] [int] NULL,
	[LineofBusinessID] [int] NULL,
	[type] [nvarchar](5) NULL,
	[receivedDateTime] [datetime] NULL,
	[hasAttachments] [bit] NULL,
	[subject] [nvarchar](500) NULL,
	[importance] [nvarchar](50) NULL,
	[from_address] [nvarchar](200) NULL,
	[from_name] [nvarchar](200) NULL,
	[recipient_address] [nvarchar](200) NULL,
	[recipient_name] [nvarchar](200) NULL,
	[conversationId] [nvarchar](200) NULL,
	[id] [nvarchar](200) NULL,
	[deviceId] [nvarchar](100) NULL,
	[timestamp] [bigint] NULL,
	[tzoffset] [nvarchar](5) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Stg_O365_UnreadEmail]    Script Date: 9/10/2021 8:10:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Stg_O365_UnreadEmail](
	[TenantID] [int] NULL,
	[LineofBusinessID] [int] NULL,
	[email] [nvarchar](200) NULL,
	[unreadCount] [int] NULL,
	[deviceId] [nvarchar](100) NULL,
	[timestamp] [bigint] NULL,
	[tzoffset] [nvarchar](5) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Stg_TimeSlot]    Script Date: 9/10/2021 8:10:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Stg_TimeSlot](
	[Dim_UserID] [int] NOT NULL,
	[Dim_CompanyID] [int] NOT NULL,
	[Dim_AppMasterID] [int] NULL,
	[Dim_ActivityCategoryID] [int] NOT NULL,
	[Dim_DeviceID] [int] NULL,
	[ActivityDate] [date] NOT NULL,
	[StartTimeInLocal]  AS (dateadd(minute,[TimeZoneOffset],[StartTimeInUTC])) PERSISTED,
	[EndTimeInLocal]  AS (dateadd(minute,[TimeZoneOffset],[EndTimeInUTC])) PERSISTED,
	[DeviceID] [int] NULL,
	[FileOrUrlName] [nvarchar](4000) NOT NULL,
	[IsFileOrUrl] [bit] NOT NULL,
	[PurposeID] [int] NOT NULL,
	[IsOnPc] [bit] NOT NULL,
	[IsShift] [bit] NOT NULL,
	[StartTimeInUTC] [datetime] NOT NULL,
	[EndTimeInUTC] [datetime] NOT NULL,
	[TimeZoneOffset] [smallint] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[TimeSpent] [real] NOT NULL,
	[IsUserModified] [bit] NOT NULL,
	[ModifiedBy] [int] NULL,
	[UploadTime] [datetime] NOT NULL,
	[Dim_WebAppID] [int] NULL,
	[Dim_MachineID] [int] NULL,
	[Dim_NetworkID] [int] NULL,
	[IsCore] [bit] NULL,
	[URLDomain] [nvarchar](200) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Stg_TimeSlot_Private]    Script Date: 9/10/2021 8:10:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Stg_TimeSlot_Private](
	[Dim_UserID] [int] NOT NULL,
	[Dim_AppMasterID] [int] NULL,
	[Dim_WebAppID] [int] NULL,
	[ActivityDate] [date] NOT NULL,
	[FileOrUrlName] [nvarchar](4000) NOT NULL,
	[IsFileOrUrl] [bit] NOT NULL,
	[PurposeID] [int] NOT NULL,
	[StartTimeInUTC] [datetime] NOT NULL,
	[EndTimeInUTC] [datetime] NOT NULL,
	[TimeZoneOffset] [smallint] NOT NULL,
	[TimeSpent] [real] NOT NULL,
	[URLDomain] [nvarchar](200) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Stg_Users]    Script Date: 9/10/2021 8:10:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Stg_Users](
	[CompanyID] [int] NULL,
	[UserID] [int] NULL,
	[DomainUserID] [nvarchar](128) NULL,
	[DomainName] [nvarchar](128) NULL,
	[IsActive] [bit] NULL,
	[EmployeeCode] [nvarchar](255) NULL,
	[UserEmail] [nvarchar](255) NULL,
	[FirstName] [nvarchar](255) NULL,
	[MiddleName] [nvarchar](255) NULL,
	[LastName] [nvarchar](255) NULL,
	[Dim_EmployeeTitleID] [int] NULL,
	[Dim_LocationID] [int] NULL,
	[ReportsToDimUserID] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Stg_UsersDates]    Script Date: 9/10/2021 8:10:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Stg_UsersDates](
	[Dim_UserID] [int] NOT NULL,
	[ActivityDate] [date] NOT NULL,
	[ActivityType] [nvarchar](20) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Test_IntegrationEntity]    Script Date: 9/10/2021 8:10:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Test_IntegrationEntity](
	[EntityID] [int] IDENTITY(1,1) NOT NULL,
	[IntegrationSourceID] [int] NOT NULL,
	[EntityName] [nvarchar](4000) NOT NULL,
 CONSTRAINT [PK_Test_IntegrationEntity] PRIMARY KEY CLUSTERED 
(
	[EntityID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Test_IntegrationEntityProperty]    Script Date: 9/10/2021 8:10:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Test_IntegrationEntityProperty](
	[EntityID] [int] NOT NULL,
	[PropertyID] [int] IDENTITY(1,1) NOT NULL,
	[PropertyName] [nvarchar](4000) NOT NULL,
	[DataTypeID] [int] NOT NULL,
	[PropertyPosition] [int] NULL,
 CONSTRAINT [PK_Test_IntegrationEntityProperty] PRIMARY KEY CLUSTERED 
(
	[EntityID] ASC,
	[PropertyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Test_IntegrationEntityProperty_1]    Script Date: 9/10/2021 8:10:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Test_IntegrationEntityProperty_1](
	[EntityId] [int] NOT NULL,
	[PropertyId] [int] NOT NULL,
	[PropertyName] [nvarchar](1000) NOT NULL,
	[PropertyValue] [nvarchar](1000) NOT NULL,
 CONSTRAINT [PK_Test_IntegrationEntityProperty_1] PRIMARY KEY CLUSTERED 
(
	[PropertyId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Test_IntegrationEntityProperty_2]    Script Date: 9/10/2021 8:10:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Test_IntegrationEntityProperty_2](
	[EntityId] [int] NOT NULL,
	[PropertyId] [int] NOT NULL,
	[PropertyName] [nvarchar](1000) NOT NULL,
	[PropertyValue] [nvarchar](1000) NOT NULL,
 CONSTRAINT [PK_Test_IntegrationEntityProperty_2] PRIMARY KEY CLUSTERED 
(
	[PropertyId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Test_IntegrationEntityProperty_3]    Script Date: 9/10/2021 8:10:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Test_IntegrationEntityProperty_3](
	[EntityId] [int] NOT NULL,
	[PropertyId] [int] NOT NULL,
	[PropertyName] [nvarchar](1000) NOT NULL,
	[PropertyValue] [nvarchar](1000) NOT NULL,
 CONSTRAINT [PK_Test_IntegrationEntityProperty_3] PRIMARY KEY CLUSTERED 
(
	[PropertyId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Test_IntegrationEntityPropertyMap]    Script Date: 9/10/2021 8:10:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Test_IntegrationEntityPropertyMap](
	[EntityId] [int] NOT NULL,
	[PropertyId_1] [int] NOT NULL,
	[PropertyName_1] [nvarchar](1000) NOT NULL,
	[PropertyValue_1] [nvarchar](1000) NOT NULL,
	[PropertyId_2] [int] NOT NULL,
	[PropertyName_2] [nvarchar](1000) NOT NULL,
	[PropertyValue_2] [nvarchar](1000) NOT NULL,
	[PropertyId_3] [int] NOT NULL,
	[PropertyName_3] [nvarchar](1000) NOT NULL,
	[PropertyValue_3] [nvarchar](1000) NOT NULL,
 CONSTRAINT [PK_Test_IntegrationEntityPropertyMap] PRIMARY KEY CLUSTERED 
(
	[EntityId] ASC,
	[PropertyId_1] ASC,
	[PropertyId_2] ASC,
	[PropertyId_3] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Test_IntegrationOutputData]    Script Date: 9/10/2021 8:10:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Test_IntegrationOutputData](
	[CompanyId] [int] NOT NULL,
	[Date] [date] NOT NULL,
	[UserId] [nvarchar](4000) NOT NULL,
	[EntityId] [int] NOT NULL,
	[IntegrationPropertyId1] [int] NOT NULL,
	[IntegrationPropertyValue1] [nvarchar](1000) NOT NULL,
	[IntegrationPropertyId2] [int] NULL,
	[IntegrationPropertyValue2] [nvarchar](1000) NULL,
	[IntegrationPropertyId3] [int] NULL,
	[IntegrationPropertyValue3] [nvarchar](1000) NULL,
	[IntegrationPropertyId4] [int] NULL,
	[IntegrationPropertyValue4] [nvarchar](1000) NULL,
	[IntegrationPropertyId5] [int] NULL,
	[IntegrationPropertyValue5] [nvarchar](1000) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Test_IntegrationOutputData_New]    Script Date: 9/10/2021 8:10:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Test_IntegrationOutputData_New](
	[CompanyId] [int] NOT NULL,
	[Date] [date] NOT NULL,
	[UserId] [int] NOT NULL,
	[EntityId] [int] NOT NULL,
	[PropertyId_1] [int] NOT NULL,
	[PropertyId_2] [int] NOT NULL,
	[PropertyId_3] [int] NOT NULL,
	[OutputValue] [real] NOT NULL,
 CONSTRAINT [PK_Test_IntegrationOutputData_New] PRIMARY KEY CLUSTERED 
(
	[CompanyId] ASC,
	[Date] ASC,
	[UserId] ASC,
	[EntityId] ASC,
	[PropertyId_1] ASC,
	[PropertyId_2] ASC,
	[PropertyId_3] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Test_IntegrationOutputData_New_1]    Script Date: 9/10/2021 8:10:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Test_IntegrationOutputData_New_1](
	[CompanyId] [int] NOT NULL,
	[Date] [date] NOT NULL,
	[UserId] [int] NOT NULL,
	[EntityId] [int] NOT NULL,
	[PropertyId_1] [int] NOT NULL,
	[PropertyId_1_Value] [nvarchar](1000) NOT NULL,
	[PropertyId_2] [int] NOT NULL,
	[PropertyId_2_Value] [nvarchar](1000) NOT NULL,
	[PropertyId_3] [int] NOT NULL,
	[PropertyId_3_Value] [nvarchar](1000) NOT NULL,
	[outputValue] [real] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[Test_IntegrationOutputData_New_2]    Script Date: 9/10/2021 8:10:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Test_IntegrationOutputData_New_2](
	[Dim_CompanyId] [int] NOT NULL,
	[Dim_UserId] [int] NOT NULL,
	[EntityId] [int] NOT NULL,
	[DateCreated] [smalldatetime] NOT NULL,
	[PropertyId] [int] NOT NULL,
	[StringValue] [nvarchar](max) NULL,
	[NumericValue] [real] NULL,
	[DateValue] [smalldatetime] NULL,
	[UniqueID] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [edw].[Test_New_IntegrationOutputData]    Script Date: 9/10/2021 8:10:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Test_New_IntegrationOutputData](
	[PropertyId] [int] NULL,
	[Value] [nvarchar](1000) NULL,
	[UniqueID] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [edw].[Test_UserMapping]    Script Date: 9/10/2021 8:10:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[Test_UserMapping](
	[ActualUser] [nvarchar](100) NULL,
	[AliasUser] [nvarchar](100) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [edw].[TestABCDEF]    Script Date: 9/10/2021 8:10:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [edw].[TestABCDEF](
	[LineofBusinessID] [int] NULL,
	[activityDomain] [nvarchar](100) NULL,
	[activityUserID] [nvarchar](200) NULL,
	[meetingID] [nvarchar](500) NULL,
	[activityTime] [datetime] NULL,
	[meetingRecipientCount] [nvarchar](4000) NULL,
	[meetingRecipients] [nvarchar](4000) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [md].[ActivityCategory]    Script Date: 9/10/2021 8:10:19 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE EXTERNAL TABLE [md].[ActivityCategory]
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
/****** Object:  Table [md].[AppActivityCategoryMap]    Script Date: 9/10/2021 8:10:19 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE EXTERNAL TABLE [md].[AppActivityCategoryMap]
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
	[IsActive] [bit] NOT NULL,
	[CurrentTimestamp] [timestamp] NOT NULL
)
WITH (DATA_SOURCE = [eds_Dev_MAD])
GO
/****** Object:  Table [md].[AppMaster]    Script Date: 9/10/2021 8:10:20 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE EXTERNAL TABLE [md].[AppMaster]
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
/****** Object:  Table [md].[Company]    Script Date: 9/10/2021 8:10:20 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE EXTERNAL TABLE [md].[Company]
(
	[CompanyID] [int] NOT NULL,
	[TenantID] [int] NOT NULL,
	[CompanyName] [nvarchar](512) NOT NULL,
	[DateCreated] [smalldatetime] NOT NULL,
	[DateActivated] [smalldatetime] NULL,
	[DateDeleted] [smalldatetime] NULL
)
WITH (DATA_SOURCE = [eds_Dev_MAD])
GO
/****** Object:  Table [md].[Device]    Script Date: 9/10/2021 8:10:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE EXTERNAL TABLE [md].[Device]
(
	[CompanyID] [int] NOT NULL,
	[DeviceID] [int] NOT NULL,
	[DeviceName] [nvarchar](512) NOT NULL,
	[DateCreated] [smalldatetime] NOT NULL,
	[DateDeleted] [smalldatetime] NULL,
	[IsActive] [bit] NOT NULL
)
WITH (DATA_SOURCE = [eds_Dev_MAD])
GO
/****** Object:  Table [md].[UserDomain]    Script Date: 9/10/2021 8:10:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE EXTERNAL TABLE [md].[UserDomain]
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
/****** Object:  Table [md].[UserEmployeeTitleHistory]    Script Date: 9/10/2021 8:10:22 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE EXTERNAL TABLE [md].[UserEmployeeTitleHistory]
(
	[CompanyID] [int] NOT NULL,
	[UserID] [int] NOT NULL,
	[StartDate] [smalldatetime] NOT NULL,
	[EndDate] [smalldatetime] NULL,
	[EmployeeTitleID] [int] NOT NULL,
	[IsCurrent] [bit] NOT NULL
)
WITH (DATA_SOURCE = [eds_Dev_MAD])
GO
/****** Object:  Table [md].[UserLocationHistory]    Script Date: 9/10/2021 8:10:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE EXTERNAL TABLE [md].[UserLocationHistory]
(
	[CompanyID] [int] NOT NULL,
	[UserID] [int] NOT NULL,
	[StartDate] [smalldatetime] NOT NULL,
	[EndDate] [smalldatetime] NULL,
	[LocationID] [int] NOT NULL,
	[IsCurrent] [bit] NOT NULL
)
WITH (DATA_SOURCE = [eds_Dev_MAD])
GO
/****** Object:  Table [md].[UserReportsToHistory]    Script Date: 9/10/2021 8:10:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE EXTERNAL TABLE [md].[UserReportsToHistory]
(
	[CompanyID] [int] NOT NULL,
	[UserID] [int] NOT NULL,
	[StartDate] [date] NOT NULL,
	[EndDate] [date] NULL,
	[ReportsToUserID] [int] NOT NULL,
	[IsCurrent] [bit] NOT NULL
)
WITH (DATA_SOURCE = [eds_Dev_MAD])
GO
/****** Object:  Table [Staging].[DailyActivity]    Script Date: 9/10/2021 8:10:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE EXTERNAL TABLE [Staging].[DailyActivity]
(
	[CompanyId] [int] NOT NULL,
	[UserID] [int] NOT NULL,
	[ActivityDate] [date] NOT NULL,
	[DeviceID] [int] NOT NULL,
	[AppID] [int] NOT NULL,
	[FileOrUrlID] [int] NOT NULL,
	[IsFileOrUrl] [bit] NOT NULL,
	[PurposeID] [int] NOT NULL,
	[ActivityCategoryGroupID] [smallint] NOT NULL,
	[ActivityCategoryID] [int] NOT NULL,
	[IsOnPc] [bit] NOT NULL,
	[TimeSpentInCalendarDay] [real] NOT NULL,
	[TimeSpentInShift] [real] NOT NULL
)
WITH (DATA_SOURCE = [eds_Dev_Staging])
GO
/****** Object:  Table [Staging].[FactDailyUserData]    Script Date: 9/10/2021 8:10:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE EXTERNAL TABLE [Staging].[FactDailyUserData]
(
	[CompanyId] [int] NOT NULL,
	[UserId] [int] NOT NULL,
	[ActivityDate] [date] NOT NULL,
	[Start_Time] [datetime] NOT NULL,
	[End_Time] [datetime] NOT NULL,
	[FirstOnPcTime] [datetime] NULL,
	[LastOnPcTime] [datetime] NULL,
	[EstimatedTimeSpent] [real] NOT NULL,
	[OnlineTimeSpent] [real] NOT NULL,
	[OfflineTimeSpent] [real] NOT NULL,
	[PrivateTimeSpent] [real] NOT NULL,
	[UnaccountedTimeSpent] [real] NOT NULL,
	[FocusTimeInCalendarDay] [real] NOT NULL,
	[FocusTimeInShift] [real] NOT NULL,
	[BreakTimeInCalenderDay] [real] NULL,
	[NumberOfBreakInCalenderDay] [int] NULL,
	[MaxUnaccountedSlotTime] [real] NULL
)
WITH (DATA_SOURCE = [eds_Dev_Staging])
GO
/****** Object:  Table [Staging].[RawTimeSlot_App]    Script Date: 9/10/2021 8:10:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE EXTERNAL TABLE [Staging].[RawTimeSlot_App]
(
	[RawTimeSlot_AppID] [bigint] NOT NULL,
	[CompanyID] [int] NOT NULL,
	[TenantID] [int] NOT NULL,
	[data_version] [nvarchar](128) NULL,
	[batch_id] [nvarchar](128) NULL,
	[data_activity_activityTime] [datetime2](7) NULL,
	[data_activity_timezone] [nvarchar](128) NULL,
	[data_activity_activityType] [nvarchar](128) NULL,
	[data_activity_domain] [nvarchar](512) NULL,
	[data_activity_id] [nvarchar](128) NULL,
	[data_activity_machineName] [nvarchar](512) NULL,
	[data_activity_userId] [nvarchar](512) NULL,
	[data_activity_version] [nvarchar](128) NULL,
	[data_exeName] [nvarchar](1024) NULL,
	[data_fileDescription] [nvarchar](512) NULL,
	[data_fileVersion] [nvarchar](128) NULL,
	[data_platform] [nvarchar](128) NULL,
	[data_procId] [nvarchar](128) NULL,
	[data_productversion] [nvarchar](128) NULL,
	[data_sessionid] [nvarchar](128) NULL,
	[data_url] [nvarchar](2048) NULL,
	[data_windowTitle] [nvarchar](1024) NULL,
	[data_subWindowTitle] [nvarchar](1024) NULL,
	[deviceId] [nvarchar](128) NULL,
	[eventType] [nvarchar](128) NULL,
	[messageType] [nvarchar](128) NULL,
	[path] [nvarchar](1024) NULL,
	[remoteAddr] [nvarchar](128) NULL,
	[spotid] [nvarchar](128) NULL,
	[spotTimeStamp] [bigint] NULL,
	[spotTimeZone] [nvarchar](128) NULL,
	[timestamp] [bigint] NULL,
	[tzOffset] [nvarchar](128) NULL,
	[version] [nvarchar](128) NULL,
	[data_type] [nvarchar](256) NULL,
	[UserEmail] [nvarchar](512) NULL,
	[IsProcessed] [bit] NOT NULL,
	[UploadTime] [datetime] NOT NULL,
	[data_productName] [nvarchar](128) NULL,
	[data_publisher] [nvarchar](128) NULL,
	[data_exePath] [nvarchar](1024) NULL,
	[kafka_cluster] [smallint] NOT NULL,
	[kafka_partition] [int] NOT NULL,
	[kafka_offset] [bigint] NOT NULL
)
WITH (DATA_SOURCE = [eds_Dev_Staging])
GO
/****** Object:  Table [Staging].[RawTimeSlot_Meeting]    Script Date: 9/10/2021 8:10:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE EXTERNAL TABLE [Staging].[RawTimeSlot_Meeting]
(
	[RawTimeSlot_MeetingID] [bigint] NOT NULL,
	[CompanyID] [int] NOT NULL,
	[TenantID] [int] NOT NULL,
	[data_version] [nvarchar](128) NULL,
	[batch_id] [nvarchar](128) NULL,
	[data_activity_activityTime] [datetime2](7) NULL,
	[data_activity_timezone] [nvarchar](128) NULL,
	[data_activity_activityType] [nvarchar](128) NULL,
	[data_activity_domain] [nvarchar](512) NULL,
	[data_activity_id] [nvarchar](128) NULL,
	[data_activity_machineName] [nvarchar](512) NULL,
	[data_activity_userId] [nvarchar](512) NULL,
	[data_activity_version] [nvarchar](128) NULL,
	[data_busyStatus] [nvarchar](128) NULL,
	[data_categories] [nvarchar](128) NULL,
	[data_creationTime] [nvarchar](128) NULL,
	[data_duration] [nvarchar](128) NULL,
	[data_importance] [nvarchar](128) NULL,
	[data_isConflict] [nvarchar](128) NULL,
	[data_isRecurring] [nvarchar](128) NULL,
	[data_meetingID] [nvarchar](512) NULL,
	[data_recipients] [nvarchar](4000) NULL,
	[data_recipients_address] [nvarchar](2048) NULL,
	[data_recipients_name] [nvarchar](2048) NULL,
	[data_responseStatus] [nvarchar](128) NULL,
	[data_sensitivity] [nvarchar](128) NULL,
	[data_start] [nvarchar](128) NULL,
	[data_end] [nvarchar](128) NULL,
	[data_status] [nvarchar](128) NULL,
	[data_subject] [nvarchar](256) NULL,
	[deviceId] [nvarchar](128) NULL,
	[eventType] [nvarchar](128) NULL,
	[messageType] [nvarchar](128) NULL,
	[path] [nvarchar](1024) NULL,
	[remoteAddr] [nvarchar](128) NULL,
	[spotid] [nvarchar](128) NULL,
	[spotTimeStamp] [bigint] NULL,
	[spotTimeZone] [nvarchar](128) NULL,
	[timestamp] [bigint] NULL,
	[tzOffset] [nvarchar](128) NULL,
	[version] [nvarchar](128) NULL,
	[data_type] [nvarchar](256) NULL,
	[UserEmail] [nvarchar](512) NULL,
	[IsProcessed] [bit] NOT NULL,
	[UploadTime] [datetime] NOT NULL,
	[kafka_cluster] [smallint] NOT NULL,
	[kafka_partition] [int] NOT NULL,
	[kafka_offset] [bigint] NOT NULL
)
WITH (DATA_SOURCE = [eds_Dev_Staging])
GO
/****** Object:  Table [Staging].[RawTimeSlotProcessStatus]    Script Date: 9/10/2021 8:10:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE EXTERNAL TABLE [Staging].[RawTimeSlotProcessStatus]
(
	[CompanyID] [int] NOT NULL,
	[RawTimeSlotType] [tinyint] NOT NULL,
	[LastRawTimeSlotProcessedTime] [datetime] NOT NULL,
	[LastRawTimeSlotProcessedId] [bigint] NOT NULL
)
WITH (DATA_SOURCE = [eds_Dev_Staging])
GO
/****** Object:  Table [Staging].[TimeSlot]    Script Date: 9/10/2021 8:10:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE EXTERNAL TABLE [Staging].[TimeSlot]
(
	[CompanyId] [int] NOT NULL,
	[ActivityDate] [date] NOT NULL,
	[UserID] [int] NOT NULL,
	[StartTimeInLocal] [datetime] NOT NULL,
	[EndTimeInLocal] [datetime] NOT NULL,
	[DeviceID] [int] NOT NULL,
	[AppID] [int] NOT NULL,
	[FileOrUrlName] [nvarchar](4000) NOT NULL,
	[IsFileOrUrl] [bit] NOT NULL,
	[PurposeID] [int] NOT NULL,
	[ActivityCategoryGroupID] [smallint] NOT NULL,
	[ActivityCategoryID] [int] NOT NULL,
	[IsOnPc] [bit] NOT NULL,
	[IsShift] [bit] NOT NULL,
	[StartTimeInUTC] [datetime] NOT NULL,
	[EndTimeInUTC] [datetime] NOT NULL,
	[TimeZoneOffset] [smallint] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[TimeSpent] [real] NOT NULL,
	[UploadTime] [datetime] NOT NULL,
	[IsUserModified] [bit] NULL,
	[ModifiedBy] [int] NULL
)
WITH (DATA_SOURCE = [eds_Dev_Staging])
GO
ALTER TABLE [arch].[Fact_TimeSlot] ADD  CONSTRAINT [DF_Fact_TimeSlot_UploadTime]  DEFAULT (getutcdate()) FOR [UploadTime]
GO
ALTER TABLE [arch].[Fact_TimeSlot] ADD  CONSTRAINT [df_IsUserModified]  DEFAULT ((0)) FOR [IsUserModified]
GO
ALTER TABLE [arch].[Fact_TimeSlot] ADD  CONSTRAINT [DF_Fact_TimeSlot_IsCore]  DEFAULT ((0)) FOR [IsCore]
GO
ALTER TABLE [dbo].[flyway_schema_history] ADD  DEFAULT (getdate()) FOR [installed_on]
GO
ALTER TABLE [dbo].[flyway_schema_history_Backup] ADD  DEFAULT (getdate()) FOR [installed_on]
GO
ALTER TABLE [dbo].[flyway_schema_history_hotfix] ADD  DEFAULT (getdate()) FOR [installed_on]
GO
ALTER TABLE [dbo].[ImportUserDepartment] ADD  CONSTRAINT [DF_ImportUserDepartment_IsManager]  DEFAULT ((0)) FOR [IsManager]
GO
ALTER TABLE [dbo].[ImportUserDepartment] ADD  CONSTRAINT [DF_ImportUserDepartment_PushedInMaster]  DEFAULT ((0)) FOR [PushedInMaster]
GO
ALTER TABLE [dbo].[ImportUserDepartment] ADD  CONSTRAINT [DF_ImportUserDepartment_DateUploaded]  DEFAULT (getutcdate()) FOR [DateUploaded]
GO
ALTER TABLE [edw].[Dim_AppMaster] ADD  CONSTRAINT [DF_AppMaster_AppVersion]  DEFAULT ('') FOR [AppVersion]
GO
ALTER TABLE [edw].[Dim_AppMaster] ADD  CONSTRAINT [DF_ApplicationMaster_IsApplication]  DEFAULT ((0)) FOR [IsApplication]
GO
ALTER TABLE [edw].[Dim_AppMaster] ADD  CONSTRAINT [DF_ApplicationMaster_IsOffline]  DEFAULT ((0)) FOR [IsOffline]
GO
ALTER TABLE [edw].[Dim_Company] ADD  CONSTRAINT [df_Organization_DateCreated]  DEFAULT (getutcdate()) FOR [DateCreated]
GO
ALTER TABLE [edw].[Dim_EmployeeTitle] ADD  CONSTRAINT [df_EmployeeTitle_IsActive]  DEFAULT ((0)) FOR [IsActive]
GO
ALTER TABLE [edw].[Dim_Location] ADD  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [edw].[Dim_User] ADD  CONSTRAINT [df_UserDetails_DateCreated]  DEFAULT (getutcdate()) FOR [DateCreated]
GO
ALTER TABLE [edw].[Dim_User] ADD  CONSTRAINT [df_UserDetails_IsDeleted]  DEFAULT ((0)) FOR [IsActive]
GO
ALTER TABLE [edw].[Dim_User] ADD  CONSTRAINT [DF_Dim_User_HasEmployeeDataAccess]  DEFAULT ((1)) FOR [HasEmployeeDataAccess]
GO
ALTER TABLE [edw].[Dim_User] ADD  DEFAULT ((1)) FOR [IsActivityCollectionOn]
GO
ALTER TABLE [edw].[Dim_User] ADD  DEFAULT ((1)) FOR [IsFullTimeEmployee]
GO
ALTER TABLE [edw].[Dim_UserDomain] ADD  DEFAULT (getutcdate()) FOR [StartTime]
GO
ALTER TABLE [edw].[Dim_UserDomain] ADD  DEFAULT (CONVERT([datetime2],'9999-12-31 23:59:59.9999999')) FOR [EndTime]
GO
ALTER TABLE [edw].[Fact_AppPred] ADD  CONSTRAINT [DF_IsProcessed_Fact_AppPred]  DEFAULT ((0)) FOR [IsProcessed]
GO
ALTER TABLE [edw].[Fact_DailyUser] ADD  CONSTRAINT [DF_Fact_DailyUser_UnaccountedTimeSpent]  DEFAULT ((0)) FOR [UnaccountedTimeSpent]
GO
ALTER TABLE [edw].[Fact_DailyUser] ADD  CONSTRAINT [DF_Fact_DailyUser_FocusTimeInCalendarDay]  DEFAULT ((0)) FOR [FocusTimeInCalendarDay]
GO
ALTER TABLE [edw].[Fact_DailyUser] ADD  CONSTRAINT [DF_Fact_DailyUser_MaxUnaccountedSlotTime]  DEFAULT ((0)) FOR [MaxUnaccountedSlotTime]
GO
ALTER TABLE [edw].[Fact_DailyUser] ADD  CONSTRAINT [DF_Fact_DailyUser_previous24DayDetail]  DEFAULT ((0)) FOR [previous24DayDetail]
GO
ALTER TABLE [edw].[Fact_DailyUser] ADD  CONSTRAINT [DF_Fact_DailyUser_FocusOfficeTimeInCalendarDay]  DEFAULT ((0)) FOR [FocusOfficeTimeInCalendarDay]
GO
ALTER TABLE [edw].[Fact_EmailUser] ADD  CONSTRAINT [DF_Fact_EmailUser_AvgResponseTime]  DEFAULT ((0)) FOR [AvgResponseTime]
GO
ALTER TABLE [edw].[Fact_EmailUser] ADD  CONSTRAINT [DF_Fact_EmailUser_NumberOfAllRecipients]  DEFAULT ((0)) FOR [NumberOfAllRecipients]
GO
ALTER TABLE [edw].[Fact_EmailUser] ADD  CONSTRAINT [DF_Fact_EmailUser_NumberOfTeamRecipients]  DEFAULT ((0)) FOR [NumberOfTeamRecipients]
GO
ALTER TABLE [edw].[Fact_EmailUser] ADD  CONSTRAINT [DF_Fact_EmailUser_NumberOfDepartmentRecipients]  DEFAULT ((0)) FOR [NumberOfDepartmentRecipients]
GO
ALTER TABLE [edw].[Fact_EmailUser] ADD  CONSTRAINT [DF_Fact_EmailUser_NumberOfRecipientsInCompany]  DEFAULT ((0)) FOR [NumberOfRecipientsInCompany]
GO
ALTER TABLE [edw].[Fact_TimeSlot] ADD  CONSTRAINT [DF_FactTimeSlot_UploadTime]  DEFAULT (getutcdate()) FOR [UploadTime]
GO
ALTER TABLE [edw].[Fact_TimeSlot] ADD  CONSTRAINT [df_IsUserModified_FactTimeSlot]  DEFAULT ((0)) FOR [IsUserModified]
GO
ALTER TABLE [edw].[Fact_TimeSlot_Obfus] ADD  CONSTRAINT [DF_Fact_TimeSlot_Obfus_UploadTime]  DEFAULT (getutcdate()) FOR [UploadTime]
GO
ALTER TABLE [edw].[Fact_TimeSlot_Obfus] ADD  CONSTRAINT [DF_Fact_TimeSlot_Obfus_IsUserModified]  DEFAULT ((0)) FOR [IsUserModified]
GO
ALTER TABLE [edw].[Fact_TimeSlotMeeting] ADD  CONSTRAINT [DF_Fact_TimeSlotMeeting_WorkTimeInMeeting]  DEFAULT ((0)) FOR [WorkTimeInMeeting]
GO
ALTER TABLE [edw].[Fact_TimeSlotMeeting] ADD  CONSTRAINT [DF_Fact_TimeSlotMeeting_PrivateTimeInMeeting]  DEFAULT ((0)) FOR [PrivateTimeInMeeting]
GO
ALTER TABLE [edw].[Fact_TimeSlotTemp] ADD  CONSTRAINT [DF_Fact_TimeSlotTemp_UploadTime]  DEFAULT (getutcdate()) FOR [UploadTime]
GO
ALTER TABLE [edw].[Fact_TimeSlotTemp] ADD  CONSTRAINT [df_IsUserModifiedTemp]  DEFAULT ((0)) FOR [IsUserModified]
GO
ALTER TABLE [edw].[Fact_WebAppMetrics] ADD  CONSTRAINT [DF_Fact_WebAppMetrics_UploadTime]  DEFAULT (getutcdate()) FOR [UploadTime]
GO
ALTER TABLE [edw].[Fact_WebAppMetrics] ADD  CONSTRAINT [df_Fact_WebAppMetrics_IsUserModified]  DEFAULT ((0)) FOR [IsUserModified]
GO
ALTER TABLE [edw].[IntegrationCycleStatus] ADD  CONSTRAINT [DF_IntegrationCycleStatus_Status]  DEFAULT ((0)) FOR [Status]
GO
ALTER TABLE [edw].[IntegrationCycleStatus] ADD  CONSTRAINT [DF_IntegrationCycleStatus_SysStartTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysStartTimeUTC]
GO
ALTER TABLE [edw].[IntegrationCycleStatus] ADD  CONSTRAINT [DF_IntegrationCycleStatus_SysEndTimeUTC]  DEFAULT (sysutcdatetime()) FOR [SysEndTimeUTC]
GO
ALTER TABLE [edw].[Log_TimeSlotProcessStatus] ADD  CONSTRAINT [df_TimeSlotProcessStatus_LastTimeSlotProcessedID]  DEFAULT ((0)) FOR [LastCreatedRawTimeSlotProcessedID]
GO
ALTER TABLE [edw].[Meta_NotificationRule] ADD  DEFAULT (newid()) FOR [ID]
GO
ALTER TABLE [edw].[Stg_TimeSlot] ADD  CONSTRAINT [DF_Stg_TimeSlot_IsUserModified]  DEFAULT ((0)) FOR [IsUserModified]
GO
ALTER TABLE [edw].[Stg_TimeSlot] ADD  CONSTRAINT [DF_Stg_TimeSlot_UploadTime]  DEFAULT (getutcdate()) FOR [UploadTime]
GO
ALTER TABLE [edw].[Stg_TimeSlot] ADD  CONSTRAINT [DF_Stg_TimeSlot_IsCore]  DEFAULT ((0)) FOR [IsCore]
GO
ALTER TABLE [edw].[Test_IntegrationOutputData_New_2] ADD  DEFAULT (getutcdate()) FOR [DateCreated]
GO
ALTER TABLE [edw].[TestFlyway] ADD  CONSTRAINT [TestFlyway_TestValue]  DEFAULT ((0)) FOR [TestValue]
GO
ALTER TABLE [arch].[Fact_TimeSlot]  WITH CHECK ADD  CONSTRAINT [FK_Dim_WebApp_Fact_TimeSlot] FOREIGN KEY([Dim_WebAppID])
REFERENCES [edw].[Dim_WebApp] ([ID])
GO
ALTER TABLE [arch].[Fact_TimeSlot] CHECK CONSTRAINT [FK_Dim_WebApp_Fact_TimeSlot]
GO
ALTER TABLE [arch].[Fact_TimeSlot]  WITH CHECK ADD  CONSTRAINT [FK_Fact_TimeSlot_Dim_ActivityCategory1] FOREIGN KEY([Dim_ActivityCategoryID])
REFERENCES [edw].[Dim_ActivityCategory] ([ID])
GO
ALTER TABLE [arch].[Fact_TimeSlot] CHECK CONSTRAINT [FK_Fact_TimeSlot_Dim_ActivityCategory1]
GO
ALTER TABLE [arch].[Fact_TimeSlot]  WITH CHECK ADD  CONSTRAINT [FK_Fact_TimeSlot_Dim_AppMaster] FOREIGN KEY([Dim_AppMasterID])
REFERENCES [edw].[Dim_AppMaster] ([ID])
GO
ALTER TABLE [arch].[Fact_TimeSlot] CHECK CONSTRAINT [FK_Fact_TimeSlot_Dim_AppMaster]
GO
ALTER TABLE [arch].[Fact_TimeSlot]  WITH CHECK ADD  CONSTRAINT [FK_Fact_TimeSlot_Dim_CompanyID] FOREIGN KEY([Dim_CompanyID])
REFERENCES [edw].[Dim_Company] ([CompanyID])
GO
ALTER TABLE [arch].[Fact_TimeSlot] CHECK CONSTRAINT [FK_Fact_TimeSlot_Dim_CompanyID]
GO
ALTER TABLE [arch].[Fact_TimeSlot]  WITH CHECK ADD  CONSTRAINT [FK_Fact_TimeSlot_Dim_MachineID] FOREIGN KEY([Dim_MachineID])
REFERENCES [edw].[Dim_Machine] ([ID])
GO
ALTER TABLE [arch].[Fact_TimeSlot] CHECK CONSTRAINT [FK_Fact_TimeSlot_Dim_MachineID]
GO
ALTER TABLE [arch].[Fact_TimeSlot]  WITH CHECK ADD  CONSTRAINT [FK_Fact_TimeSlot_Dim_NetworkID] FOREIGN KEY([Dim_NetworkID])
REFERENCES [edw].[Dim_Network] ([ID])
GO
ALTER TABLE [arch].[Fact_TimeSlot] CHECK CONSTRAINT [FK_Fact_TimeSlot_Dim_NetworkID]
GO
ALTER TABLE [arch].[Fact_TimeSlot]  WITH CHECK ADD  CONSTRAINT [FK_Fact_TimeSlot_Dim_User] FOREIGN KEY([Dim_UserID])
REFERENCES [edw].[Dim_User] ([ID])
GO
ALTER TABLE [arch].[Fact_TimeSlot] CHECK CONSTRAINT [FK_Fact_TimeSlot_Dim_User]
GO
ALTER TABLE [edw].[Brdg_AppActivityCategory]  WITH CHECK ADD  CONSTRAINT [FK_Brdg_AppActivityCat_Dim_ActivityCat] FOREIGN KEY([Dim_ActivityCategoryID])
REFERENCES [edw].[Dim_ActivityCategory] ([ID])
GO
ALTER TABLE [edw].[Brdg_AppActivityCategory] CHECK CONSTRAINT [FK_Brdg_AppActivityCat_Dim_ActivityCat]
GO
ALTER TABLE [edw].[Brdg_AppActivityCategory(Old)]  WITH CHECK ADD  CONSTRAINT [FK_Brdg_AppActivityCategory_Dim_ActivityCategory] FOREIGN KEY([Dim_ActivityCategoryID])
REFERENCES [edw].[Dim_ActivityCategory] ([ID])
GO
ALTER TABLE [edw].[Brdg_AppActivityCategory(Old)] CHECK CONSTRAINT [FK_Brdg_AppActivityCategory_Dim_ActivityCategory]
GO
ALTER TABLE [edw].[Brdg_AppActivityCategory(Old)]  WITH CHECK ADD  CONSTRAINT [FK_Brdg_AppActivityCategory_Dim_AppMaster] FOREIGN KEY([Dim_AppMasterID])
REFERENCES [edw].[Dim_AppMaster] ([ID])
GO
ALTER TABLE [edw].[Brdg_AppActivityCategory(Old)] CHECK CONSTRAINT [FK_Brdg_AppActivityCategory_Dim_AppMaster]
GO
ALTER TABLE [edw].[Brdg_CompanySettings]  WITH CHECK ADD  CONSTRAINT [FK_Brdg_CompanySettings] FOREIGN KEY([Dim_SettingID])
REFERENCES [edw].[Dim_Settings] ([ID])
GO
ALTER TABLE [edw].[Brdg_CompanySettings] CHECK CONSTRAINT [FK_Brdg_CompanySettings]
GO
ALTER TABLE [edw].[Brdg_HolidayLocationHistory]  WITH CHECK ADD  CONSTRAINT [FK_Dim_Holiday_Brdg_HolidayLocationHistory] FOREIGN KEY([Dim_HolidayID])
REFERENCES [edw].[Dim_Holiday] ([ID])
GO
ALTER TABLE [edw].[Brdg_HolidayLocationHistory] CHECK CONSTRAINT [FK_Dim_Holiday_Brdg_HolidayLocationHistory]
GO
ALTER TABLE [edw].[Brdg_HolidayLocationHistory]  WITH CHECK ADD  CONSTRAINT [FK_Dim_Location_Brdg_HolidayLocationHistory] FOREIGN KEY([Dim_LocationID])
REFERENCES [edw].[Dim_Location] ([ID])
GO
ALTER TABLE [edw].[Brdg_HolidayLocationHistory] CHECK CONSTRAINT [FK_Dim_Location_Brdg_HolidayLocationHistory]
GO
ALTER TABLE [edw].[Brdg_JobFamilyAppOverride]  WITH CHECK ADD  CONSTRAINT [FK_Dim_ActivityCategory_Brdg_JobFamilyAppOverride] FOREIGN KEY([Dim_ActivityCategoryID])
REFERENCES [edw].[Dim_ActivityCategory] ([ID])
GO
ALTER TABLE [edw].[Brdg_JobFamilyAppOverride] CHECK CONSTRAINT [FK_Dim_ActivityCategory_Brdg_JobFamilyAppOverride]
GO
ALTER TABLE [edw].[Brdg_JobFamilyAppOverride]  WITH CHECK ADD  CONSTRAINT [FK_Dim_AppParent_Brdg_JobFamilyAppOverride] FOREIGN KEY([Dim_AppParentID])
REFERENCES [edw].[Dim_AppParent] ([ID])
GO
ALTER TABLE [edw].[Brdg_JobFamilyAppOverride] CHECK CONSTRAINT [FK_Dim_AppParent_Brdg_JobFamilyAppOverride]
GO
ALTER TABLE [edw].[Brdg_JobFamilyAppOverride]  WITH CHECK ADD  CONSTRAINT [FK_Dim_Company_Brdg_JobFamilyAppOverride] FOREIGN KEY([CompanyID])
REFERENCES [edw].[Dim_Company] ([CompanyID])
GO
ALTER TABLE [edw].[Brdg_JobFamilyAppOverride] CHECK CONSTRAINT [FK_Dim_Company_Brdg_JobFamilyAppOverride]
GO
ALTER TABLE [edw].[Brdg_JobFamilyAppOverride]  WITH CHECK ADD  CONSTRAINT [FK_Dim_JobFamilyProfile_Brdg_JobFamilyAppOverride] FOREIGN KEY([Dim_JobFamilyProfileID])
REFERENCES [edw].[Dim_JobFamilyProfile] ([ID])
GO
ALTER TABLE [edw].[Brdg_JobFamilyAppOverride] CHECK CONSTRAINT [FK_Dim_JobFamilyProfile_Brdg_JobFamilyAppOverride]
GO
ALTER TABLE [edw].[Brdg_JobFamilyWebAppOverride]  WITH CHECK ADD  CONSTRAINT [FK_Dim_ActivityCategory_Brdg_JobFamilyWebAppOverride] FOREIGN KEY([Dim_ActivityCategoryID])
REFERENCES [edw].[Dim_ActivityCategory] ([ID])
GO
ALTER TABLE [edw].[Brdg_JobFamilyWebAppOverride] CHECK CONSTRAINT [FK_Dim_ActivityCategory_Brdg_JobFamilyWebAppOverride]
GO
ALTER TABLE [edw].[Brdg_JobFamilyWebAppOverride]  WITH CHECK ADD  CONSTRAINT [FK_Dim_AppParent_Brdg_JobFamilyWebAppOverride] FOREIGN KEY([Dim_WebAppID])
REFERENCES [edw].[Dim_WebApp] ([ID])
GO
ALTER TABLE [edw].[Brdg_JobFamilyWebAppOverride] CHECK CONSTRAINT [FK_Dim_AppParent_Brdg_JobFamilyWebAppOverride]
GO
ALTER TABLE [edw].[Brdg_JobFamilyWebAppOverride]  WITH CHECK ADD  CONSTRAINT [FK_Dim_Company_Brdg_JobFamilyWebAppOverride] FOREIGN KEY([CompanyID])
REFERENCES [edw].[Dim_Company] ([CompanyID])
GO
ALTER TABLE [edw].[Brdg_JobFamilyWebAppOverride] CHECK CONSTRAINT [FK_Dim_Company_Brdg_JobFamilyWebAppOverride]
GO
ALTER TABLE [edw].[Brdg_JobFamilyWebAppOverride]  WITH CHECK ADD  CONSTRAINT [FK_Dim_JobFamilyProfile_Brdg_JobFamilyWebAppOverride] FOREIGN KEY([Dim_JobFamilyProfileID])
REFERENCES [edw].[Dim_JobFamilyProfile] ([ID])
GO
ALTER TABLE [edw].[Brdg_JobFamilyWebAppOverride] CHECK CONSTRAINT [FK_Dim_JobFamilyProfile_Brdg_JobFamilyWebAppOverride]
GO
ALTER TABLE [edw].[Brdg_UserAppOverride]  WITH CHECK ADD  CONSTRAINT [FK_Dim_ActivityCategory_Brdg_UserAppOverride] FOREIGN KEY([Dim_ActivityCategoryID])
REFERENCES [edw].[Dim_ActivityCategory] ([ID])
GO
ALTER TABLE [edw].[Brdg_UserAppOverride] CHECK CONSTRAINT [FK_Dim_ActivityCategory_Brdg_UserAppOverride]
GO
ALTER TABLE [edw].[Brdg_UserAppOverride]  WITH CHECK ADD  CONSTRAINT [FK_Dim_AppParent_Brdg_UserAppOverride] FOREIGN KEY([Dim_AppParentID])
REFERENCES [edw].[Dim_AppParent] ([ID])
GO
ALTER TABLE [edw].[Brdg_UserAppOverride] CHECK CONSTRAINT [FK_Dim_AppParent_Brdg_UserAppOverride]
GO
ALTER TABLE [edw].[Brdg_UserAppOverride]  WITH CHECK ADD  CONSTRAINT [FK_Dim_Brdg_UserAppOverride_Brdg_JobFamilyAppOverride] FOREIGN KEY([Dim_UserProfileID])
REFERENCES [edw].[Dim_UserProfile] ([ID])
GO
ALTER TABLE [edw].[Brdg_UserAppOverride] CHECK CONSTRAINT [FK_Dim_Brdg_UserAppOverride_Brdg_JobFamilyAppOverride]
GO
ALTER TABLE [edw].[Brdg_UserAppOverride]  WITH CHECK ADD  CONSTRAINT [FK_Dim_Company_Brdg_UserAppOverride] FOREIGN KEY([CompanyID])
REFERENCES [edw].[Dim_Company] ([CompanyID])
GO
ALTER TABLE [edw].[Brdg_UserAppOverride] CHECK CONSTRAINT [FK_Dim_Company_Brdg_UserAppOverride]
GO
ALTER TABLE [edw].[Brdg_UserDepartmentHistory]  WITH CHECK ADD  CONSTRAINT [FK_Brdg_UserDepartmentHistory_Dim_Department] FOREIGN KEY([Dim_DepartmentID])
REFERENCES [edw].[Dim_Department] ([ID])
GO
ALTER TABLE [edw].[Brdg_UserDepartmentHistory] CHECK CONSTRAINT [FK_Brdg_UserDepartmentHistory_Dim_Department]
GO
ALTER TABLE [edw].[Brdg_UserDepartmentHistory]  WITH CHECK ADD  CONSTRAINT [FK_Brdg_UserDepartmentHistory_Dim_User] FOREIGN KEY([Dim_UserID])
REFERENCES [edw].[Dim_User] ([ID])
GO
ALTER TABLE [edw].[Brdg_UserDepartmentHistory] CHECK CONSTRAINT [FK_Brdg_UserDepartmentHistory_Dim_User]
GO
ALTER TABLE [edw].[Brdg_UserField]  WITH CHECK ADD  CONSTRAINT [FK_Brdg_UserField_Dim_UserID] FOREIGN KEY([Dim_UserID])
REFERENCES [edw].[Dim_User] ([ID])
GO
ALTER TABLE [edw].[Brdg_UserField] CHECK CONSTRAINT [FK_Brdg_UserField_Dim_UserID]
GO
ALTER TABLE [edw].[Brdg_UserLocationHistory]  WITH CHECK ADD  CONSTRAINT [FK_Brdg_UserLocationHistory_Dim_Location] FOREIGN KEY([Dim_LocationID])
REFERENCES [edw].[Dim_Location] ([ID])
GO
ALTER TABLE [edw].[Brdg_UserLocationHistory] CHECK CONSTRAINT [FK_Brdg_UserLocationHistory_Dim_Location]
GO
ALTER TABLE [edw].[Brdg_UserLocationHistory]  WITH CHECK ADD  CONSTRAINT [FK_Brdg_UserLocationHistory_Dim_User] FOREIGN KEY([Dim_UserID])
REFERENCES [edw].[Dim_User] ([ID])
GO
ALTER TABLE [edw].[Brdg_UserLocationHistory] CHECK CONSTRAINT [FK_Brdg_UserLocationHistory_Dim_User]
GO
ALTER TABLE [edw].[Brdg_UserReportsToHistory]  WITH CHECK ADD  CONSTRAINT [FK_Brdg_UserReportsToHistory_Dim_User] FOREIGN KEY([Dim_UserID])
REFERENCES [edw].[Dim_User] ([ID])
GO
ALTER TABLE [edw].[Brdg_UserReportsToHistory] CHECK CONSTRAINT [FK_Brdg_UserReportsToHistory_Dim_User]
GO
ALTER TABLE [edw].[Brdg_UserWebAppOverride]  WITH CHECK ADD  CONSTRAINT [FK_Dim_ActivityCategory_Brdg_UserWebAppOverride] FOREIGN KEY([Dim_ActivityCategoryID])
REFERENCES [edw].[Dim_ActivityCategory] ([ID])
GO
ALTER TABLE [edw].[Brdg_UserWebAppOverride] CHECK CONSTRAINT [FK_Dim_ActivityCategory_Brdg_UserWebAppOverride]
GO
ALTER TABLE [edw].[Brdg_UserWebAppOverride]  WITH CHECK ADD  CONSTRAINT [FK_Dim_AppParent_Brdg_UserWebAppOverride] FOREIGN KEY([Dim_WebAppID])
REFERENCES [edw].[Dim_WebApp] ([ID])
GO
ALTER TABLE [edw].[Brdg_UserWebAppOverride] CHECK CONSTRAINT [FK_Dim_AppParent_Brdg_UserWebAppOverride]
GO
ALTER TABLE [edw].[Brdg_UserWebAppOverride]  WITH CHECK ADD  CONSTRAINT [FK_Dim_Company_Brdg_UserWebAppOverride] FOREIGN KEY([CompanyID])
REFERENCES [edw].[Dim_Company] ([CompanyID])
GO
ALTER TABLE [edw].[Brdg_UserWebAppOverride] CHECK CONSTRAINT [FK_Dim_Company_Brdg_UserWebAppOverride]
GO
ALTER TABLE [edw].[Brdg_UserWebAppOverride]  WITH CHECK ADD  CONSTRAINT [FK_Dim_JobFamilyProfile_Brdg_UserWebAppOverride] FOREIGN KEY([Dim_UserProfileID])
REFERENCES [edw].[Dim_UserProfile] ([ID])
GO
ALTER TABLE [edw].[Brdg_UserWebAppOverride] CHECK CONSTRAINT [FK_Dim_JobFamilyProfile_Brdg_UserWebAppOverride]
GO
ALTER TABLE [edw].[Brdg_Vendor_Contigent_RateCard]  WITH NOCHECK ADD  CONSTRAINT [FK_Brdg_Vendor_Contigent_RateCard_CompanyID] FOREIGN KEY([CompanyID])
REFERENCES [edw].[Dim_Company] ([CompanyID])
GO
ALTER TABLE [edw].[Brdg_Vendor_Contigent_RateCard] CHECK CONSTRAINT [FK_Brdg_Vendor_Contigent_RateCard_CompanyID]
GO
ALTER TABLE [edw].[Brdg_Vendor_Contigent_RateCard]  WITH NOCHECK ADD  CONSTRAINT [FK_Brdg_Vendor_Contigent_RateCard_JobFamilyProfileID] FOREIGN KEY([Dim_JobFamilyProfileID])
REFERENCES [edw].[Dim_JobFamilyProfile] ([ID])
GO
ALTER TABLE [edw].[Brdg_Vendor_Contigent_RateCard] CHECK CONSTRAINT [FK_Brdg_Vendor_Contigent_RateCard_JobFamilyProfileID]
GO
ALTER TABLE [edw].[Brdg_Vendor_Contigent_RateCard]  WITH NOCHECK ADD  CONSTRAINT [FK_Brdg_Vendor_Contigent_RateCard_LocationID] FOREIGN KEY([Dim_LocationID])
REFERENCES [edw].[Dim_Location] ([ID])
GO
ALTER TABLE [edw].[Brdg_Vendor_Contigent_RateCard] CHECK CONSTRAINT [FK_Brdg_Vendor_Contigent_RateCard_LocationID]
GO
ALTER TABLE [edw].[Brdg_Vendor_Contigent_RateCard]  WITH NOCHECK ADD  CONSTRAINT [FK_Brdg_Vendor_Contigent_RateCard_VendorID] FOREIGN KEY([Dim_VendorID])
REFERENCES [edw].[Dim_Vendor] ([ID])
GO
ALTER TABLE [edw].[Brdg_Vendor_Contigent_RateCard] CHECK CONSTRAINT [FK_Brdg_Vendor_Contigent_RateCard_VendorID]
GO
ALTER TABLE [edw].[Brdg_Vendor_Invoice]  WITH NOCHECK ADD  CONSTRAINT [FK_Brdg_Vendor_Invoice_CompanyID] FOREIGN KEY([CompanyID])
REFERENCES [edw].[Dim_Company] ([CompanyID])
GO
ALTER TABLE [edw].[Brdg_Vendor_Invoice] CHECK CONSTRAINT [FK_Brdg_Vendor_Invoice_CompanyID]
GO
ALTER TABLE [edw].[Brdg_Vendor_Invoice]  WITH NOCHECK ADD  CONSTRAINT [FK_Brdg_Vendor_Invoice_VendorID] FOREIGN KEY([Dim_VendorID])
REFERENCES [edw].[Dim_Vendor] ([ID])
GO
ALTER TABLE [edw].[Brdg_Vendor_Invoice] CHECK CONSTRAINT [FK_Brdg_Vendor_Invoice_VendorID]
GO
ALTER TABLE [edw].[Dim_ActivityCategory]  WITH CHECK ADD  CONSTRAINT [FK_Dim_ActivityCategory_Dim_Company] FOREIGN KEY([CompanyID])
REFERENCES [edw].[Dim_Company] ([CompanyID])
GO
ALTER TABLE [edw].[Dim_ActivityCategory] CHECK CONSTRAINT [FK_Dim_ActivityCategory_Dim_Company]
GO
ALTER TABLE [edw].[Dim_AppMaster]  WITH CHECK ADD  CONSTRAINT [FK_Dim_AppMaster_Dim_AppParent] FOREIGN KEY([Dim_AppParentID])
REFERENCES [edw].[Dim_AppParent] ([ID])
GO
ALTER TABLE [edw].[Dim_AppMaster] CHECK CONSTRAINT [FK_Dim_AppMaster_Dim_AppParent]
GO
ALTER TABLE [edw].[Dim_AppMaster]  WITH CHECK ADD  CONSTRAINT [FK_Dim_AppMaster_Dim_Company] FOREIGN KEY([CompanyID])
REFERENCES [edw].[Dim_Company] ([CompanyID])
GO
ALTER TABLE [edw].[Dim_AppMaster] CHECK CONSTRAINT [FK_Dim_AppMaster_Dim_Company]
GO
ALTER TABLE [edw].[Dim_AppMaster]  WITH CHECK ADD  CONSTRAINT [FK_Dim_AppMaster_PlatformID] FOREIGN KEY([Dim_PlatformID])
REFERENCES [edw].[Dim_Platform] ([ID])
GO
ALTER TABLE [edw].[Dim_AppMaster] CHECK CONSTRAINT [FK_Dim_AppMaster_PlatformID]
GO
ALTER TABLE [edw].[Dim_AppParent]  WITH CHECK ADD  CONSTRAINT [FK_Dim_AppParent_ActivityCategoryID] FOREIGN KEY([Dim_ActivityCategoryID])
REFERENCES [edw].[Dim_ActivityCategory] ([ID])
GO
ALTER TABLE [edw].[Dim_AppParent] CHECK CONSTRAINT [FK_Dim_AppParent_ActivityCategoryID]
GO
ALTER TABLE [edw].[Dim_Department]  WITH CHECK ADD  CONSTRAINT [FK_Dim_Department_Dim_Company] FOREIGN KEY([CompanyID])
REFERENCES [edw].[Dim_Company] ([CompanyID])
GO
ALTER TABLE [edw].[Dim_Department] CHECK CONSTRAINT [FK_Dim_Department_Dim_Company]
GO
ALTER TABLE [edw].[Dim_Department]  WITH CHECK ADD  CONSTRAINT [FK_Dim_User_Department_Manager] FOREIGN KEY([ManagerDimUserID])
REFERENCES [edw].[Dim_User] ([ID])
GO
ALTER TABLE [edw].[Dim_Department] CHECK CONSTRAINT [FK_Dim_User_Department_Manager]
GO
ALTER TABLE [edw].[Dim_Device]  WITH CHECK ADD  CONSTRAINT [FK_Dim_Device_Dim_Company] FOREIGN KEY([CompanyID])
REFERENCES [edw].[Dim_Company] ([CompanyID])
GO
ALTER TABLE [edw].[Dim_Device] CHECK CONSTRAINT [FK_Dim_Device_Dim_Company]
GO
ALTER TABLE [edw].[Dim_Field]  WITH CHECK ADD  CONSTRAINT [FK_Dim_Field_Dim_DataType] FOREIGN KEY([Dim_DataTypeID])
REFERENCES [edw].[Dim_DataType] ([ID])
GO
ALTER TABLE [edw].[Dim_Field] CHECK CONSTRAINT [FK_Dim_Field_Dim_DataType]
GO
ALTER TABLE [edw].[Dim_Field]  WITH CHECK ADD  CONSTRAINT [FK_Dim_Field_Dim_Settings] FOREIGN KEY([Dim_SettingID])
REFERENCES [edw].[Dim_Settings] ([ID])
GO
ALTER TABLE [edw].[Dim_Field] CHECK CONSTRAINT [FK_Dim_Field_Dim_Settings]
GO
ALTER TABLE [edw].[Dim_Holiday]  WITH CHECK ADD  CONSTRAINT [FK_Dim_Company_Holiday_CompanyID] FOREIGN KEY([CompanyID])
REFERENCES [edw].[Dim_Company] ([CompanyID])
GO
ALTER TABLE [edw].[Dim_Holiday] CHECK CONSTRAINT [FK_Dim_Company_Holiday_CompanyID]
GO
ALTER TABLE [edw].[Dim_IntegrationProperty]  WITH CHECK ADD  CONSTRAINT [FK_Dim_IntegrationProperty_Dim_IntegrationEntity] FOREIGN KEY([EntityID])
REFERENCES [edw].[Dim_IntegrationEntity] ([EntityID])
GO
ALTER TABLE [edw].[Dim_IntegrationProperty] CHECK CONSTRAINT [FK_Dim_IntegrationProperty_Dim_IntegrationEntity]
GO
ALTER TABLE [edw].[Dim_JobFamilyProfile]  WITH CHECK ADD  CONSTRAINT [FK_Dim_Company_JobFamily_CompanyID] FOREIGN KEY([CompanyID])
REFERENCES [edw].[Dim_Company] ([CompanyID])
GO
ALTER TABLE [edw].[Dim_JobFamilyProfile] CHECK CONSTRAINT [FK_Dim_Company_JobFamily_CompanyID]
GO
ALTER TABLE [edw].[Dim_Location]  WITH CHECK ADD  CONSTRAINT [FK_Dim_Location_Dim_Company] FOREIGN KEY([CompanyID])
REFERENCES [edw].[Dim_Company] ([CompanyID])
GO
ALTER TABLE [edw].[Dim_Location] CHECK CONSTRAINT [FK_Dim_Location_Dim_Company]
GO
ALTER TABLE [edw].[Dim_Machine]  WITH CHECK ADD  CONSTRAINT [FK_Dim_Machine_CompanyID] FOREIGN KEY([CompanyID])
REFERENCES [edw].[Dim_Company] ([CompanyID])
GO
ALTER TABLE [edw].[Dim_Machine] CHECK CONSTRAINT [FK_Dim_Machine_CompanyID]
GO
ALTER TABLE [edw].[Dim_Network]  WITH CHECK ADD  CONSTRAINT [FK_Dim_Network_CompanyID] FOREIGN KEY([CompanyID])
REFERENCES [edw].[Dim_Company] ([CompanyID])
GO
ALTER TABLE [edw].[Dim_Network] CHECK CONSTRAINT [FK_Dim_Network_CompanyID]
GO
ALTER TABLE [edw].[Dim_Platform]  WITH CHECK ADD  CONSTRAINT [FK_Dim_Company_Platform_CompanyID] FOREIGN KEY([CompanyID])
REFERENCES [edw].[Dim_Company] ([CompanyID])
GO
ALTER TABLE [edw].[Dim_Platform] CHECK CONSTRAINT [FK_Dim_Company_Platform_CompanyID]
GO
ALTER TABLE [edw].[Dim_Team]  WITH CHECK ADD  CONSTRAINT [FK_Dim_Company_Team_CompanyID] FOREIGN KEY([CompanyID])
REFERENCES [edw].[Dim_Company] ([CompanyID])
GO
ALTER TABLE [edw].[Dim_Team] CHECK CONSTRAINT [FK_Dim_Company_Team_CompanyID]
GO
ALTER TABLE [edw].[Dim_Team]  WITH CHECK ADD  CONSTRAINT [FK_Dim_User_Team_ManagerID] FOREIGN KEY([ManagerID])
REFERENCES [edw].[Dim_User] ([ID])
GO
ALTER TABLE [edw].[Dim_Team] CHECK CONSTRAINT [FK_Dim_User_Team_ManagerID]
GO
ALTER TABLE [edw].[Dim_User]  WITH CHECK ADD  CONSTRAINT [FK_Dim_Department_Dim_User] FOREIGN KEY([Dim_DepartmentID])
REFERENCES [edw].[Dim_Department] ([ID])
GO
ALTER TABLE [edw].[Dim_User] CHECK CONSTRAINT [FK_Dim_Department_Dim_User]
GO
ALTER TABLE [edw].[Dim_User]  WITH CHECK ADD  CONSTRAINT [FK_Dim_JobFamilyProfile_Dim_User] FOREIGN KEY([Dim_JobFamilyProfileID])
REFERENCES [edw].[Dim_JobFamilyProfile] ([ID])
GO
ALTER TABLE [edw].[Dim_User] CHECK CONSTRAINT [FK_Dim_JobFamilyProfile_Dim_User]
GO
ALTER TABLE [edw].[Dim_User]  WITH CHECK ADD  CONSTRAINT [FK_Dim_Location_Dim_User] FOREIGN KEY([Dim_LocationID])
REFERENCES [edw].[Dim_Location] ([ID])
GO
ALTER TABLE [edw].[Dim_User] CHECK CONSTRAINT [FK_Dim_Location_Dim_User]
GO
ALTER TABLE [edw].[Dim_User]  WITH CHECK ADD  CONSTRAINT [FK_Dim_User_Dim_Company] FOREIGN KEY([CompanyID])
REFERENCES [edw].[Dim_Company] ([CompanyID])
GO
ALTER TABLE [edw].[Dim_User] CHECK CONSTRAINT [FK_Dim_User_Dim_Company]
GO
ALTER TABLE [edw].[Dim_User]  WITH CHECK ADD  CONSTRAINT [FK_Dim_UserProfile_Dim_User] FOREIGN KEY([Dim_UserProfileID])
REFERENCES [edw].[Dim_UserProfile] ([ID])
GO
ALTER TABLE [edw].[Dim_User] CHECK CONSTRAINT [FK_Dim_UserProfile_Dim_User]
GO
ALTER TABLE [edw].[Dim_User]  WITH CHECK ADD  CONSTRAINT [FK_Dim_Vendor_Dim_User] FOREIGN KEY([Dim_VendorID])
REFERENCES [edw].[Dim_Vendor] ([ID])
GO
ALTER TABLE [edw].[Dim_User] CHECK CONSTRAINT [FK_Dim_Vendor_Dim_User]
GO
ALTER TABLE [edw].[Dim_User]  WITH CHECK ADD  CONSTRAINT [FK_Dim_WorkSchedule_Dim_User] FOREIGN KEY([Dim_WorkScheduleID])
REFERENCES [edw].[Dim_WorkSchedule] ([ID])
GO
ALTER TABLE [edw].[Dim_User] CHECK CONSTRAINT [FK_Dim_WorkSchedule_Dim_User]
GO
ALTER TABLE [edw].[Dim_User]  WITH CHECK ADD  CONSTRAINT [FK_TeamID_Dim_User] FOREIGN KEY([DimTeamID])
REFERENCES [edw].[Dim_Team] ([ID])
GO
ALTER TABLE [edw].[Dim_User] CHECK CONSTRAINT [FK_TeamID_Dim_User]
GO
ALTER TABLE [edw].[Dim_UserDomain]  WITH CHECK ADD  CONSTRAINT [FK_Dim_Company_DimUserDomain] FOREIGN KEY([CompanyID])
REFERENCES [edw].[Dim_Company] ([CompanyID])
GO
ALTER TABLE [edw].[Dim_UserDomain] CHECK CONSTRAINT [FK_Dim_Company_DimUserDomain]
GO
ALTER TABLE [edw].[Dim_UserDomain]  WITH CHECK ADD  CONSTRAINT [FK_Dim_User_DimUserDomain_UserID] FOREIGN KEY([Dim_UserID])
REFERENCES [edw].[Dim_User] ([ID])
GO
ALTER TABLE [edw].[Dim_UserDomain] CHECK CONSTRAINT [FK_Dim_User_DimUserDomain_UserID]
GO
ALTER TABLE [edw].[Dim_UserProfile]  WITH CHECK ADD  CONSTRAINT [FK_Dim_Company_UserProfile_CompanyID] FOREIGN KEY([CompanyID])
REFERENCES [edw].[Dim_Company] ([CompanyID])
GO
ALTER TABLE [edw].[Dim_UserProfile] CHECK CONSTRAINT [FK_Dim_Company_UserProfile_CompanyID]
GO
ALTER TABLE [edw].[Dim_Vendor]  WITH CHECK ADD  CONSTRAINT [FK_Dim_Company_Vendor_CompanyID] FOREIGN KEY([CompanyID])
REFERENCES [edw].[Dim_Company] ([CompanyID])
GO
ALTER TABLE [edw].[Dim_Vendor] CHECK CONSTRAINT [FK_Dim_Company_Vendor_CompanyID]
GO
ALTER TABLE [edw].[Dim_WebApp]  WITH CHECK ADD  CONSTRAINT [FK_Dim_Company_WebApp_ActivityCategoryID] FOREIGN KEY([Dim_ActivityCategoryID])
REFERENCES [edw].[Dim_ActivityCategory] ([ID])
GO
ALTER TABLE [edw].[Dim_WebApp] CHECK CONSTRAINT [FK_Dim_Company_WebApp_ActivityCategoryID]
GO
ALTER TABLE [edw].[Dim_WebApp]  WITH CHECK ADD  CONSTRAINT [FK_Dim_Company_WebApp_CompanyID] FOREIGN KEY([CompanyID])
REFERENCES [edw].[Dim_Company] ([CompanyID])
GO
ALTER TABLE [edw].[Dim_WebApp] CHECK CONSTRAINT [FK_Dim_Company_WebApp_CompanyID]
GO
ALTER TABLE [edw].[Dim_WorkSchedule]  WITH CHECK ADD  CONSTRAINT [FK_Dim_Company_WorkSchedule_CompanyID] FOREIGN KEY([CompanyID])
REFERENCES [edw].[Dim_Company] ([CompanyID])
GO
ALTER TABLE [edw].[Dim_WorkSchedule] CHECK CONSTRAINT [FK_Dim_Company_WorkSchedule_CompanyID]
GO
ALTER TABLE [edw].[Fact_ActivityPred]  WITH CHECK ADD  CONSTRAINT [FK_Fact_Pred_Dim_ActivityCategoryID] FOREIGN KEY([Dim_ActivityCategoryID])
REFERENCES [edw].[Dim_ActivityCategory] ([ID])
GO
ALTER TABLE [edw].[Fact_ActivityPred] CHECK CONSTRAINT [FK_Fact_Pred_Dim_ActivityCategoryID]
GO
ALTER TABLE [edw].[Fact_ActivityPred]  WITH CHECK ADD  CONSTRAINT [FK_Fact_Pred_Dim_CompanyID] FOREIGN KEY([Dim_CompanyID])
REFERENCES [edw].[Dim_Company] ([CompanyID])
GO
ALTER TABLE [edw].[Fact_ActivityPred] CHECK CONSTRAINT [FK_Fact_Pred_Dim_CompanyID]
GO
ALTER TABLE [edw].[Fact_ActivityPred]  WITH CHECK ADD  CONSTRAINT [FK_Fact_Pred_Dim_UserID] FOREIGN KEY([Dim_UserID])
REFERENCES [edw].[Dim_User] ([ID])
GO
ALTER TABLE [edw].[Fact_ActivityPred] CHECK CONSTRAINT [FK_Fact_Pred_Dim_UserID]
GO
ALTER TABLE [edw].[Fact_AppClassification_Exe]  WITH CHECK ADD  CONSTRAINT [FK_Dim_Company_Fact_AppClassification_Exe] FOREIGN KEY([Dim_CompanyID])
REFERENCES [edw].[Dim_Company] ([CompanyID])
GO
ALTER TABLE [edw].[Fact_AppClassification_Exe] CHECK CONSTRAINT [FK_Dim_Company_Fact_AppClassification_Exe]
GO
ALTER TABLE [edw].[Fact_AppClassification_Exe]  WITH CHECK ADD  CONSTRAINT [FK_Dim_JobFamilyProfile_Fact_AppClassification_Exe] FOREIGN KEY([Dim_JobFamilyProfileID])
REFERENCES [edw].[Dim_JobFamilyProfile] ([ID])
GO
ALTER TABLE [edw].[Fact_AppClassification_Exe] CHECK CONSTRAINT [FK_Dim_JobFamilyProfile_Fact_AppClassification_Exe]
GO
ALTER TABLE [edw].[Fact_AppPred]  WITH CHECK ADD  CONSTRAINT [FK_Dim_AppParentID_Fact_AppPred] FOREIGN KEY([Dim_AppParentID])
REFERENCES [edw].[Dim_AppParent] ([ID])
GO
ALTER TABLE [edw].[Fact_AppPred] CHECK CONSTRAINT [FK_Dim_AppParentID_Fact_AppPred]
GO
ALTER TABLE [edw].[Fact_AppPred]  WITH CHECK ADD  CONSTRAINT [FK_Dim_User_Fact_AppPred] FOREIGN KEY([Dim_UserID])
REFERENCES [edw].[Dim_User] ([ID])
GO
ALTER TABLE [edw].[Fact_AppPred] CHECK CONSTRAINT [FK_Dim_User_Fact_AppPred]
GO
ALTER TABLE [edw].[Fact_DailyActivity]  WITH CHECK ADD  CONSTRAINT [FK_Fact_DailyActivity_Dim_ActivityCategory] FOREIGN KEY([Dim_CompanyID])
REFERENCES [edw].[Dim_Company] ([CompanyID])
GO
ALTER TABLE [edw].[Fact_DailyActivity] CHECK CONSTRAINT [FK_Fact_DailyActivity_Dim_ActivityCategory]
GO
ALTER TABLE [edw].[Fact_DailyActivity]  WITH CHECK ADD  CONSTRAINT [FK_Fact_DailyActivity_Dim_ActivityCategory1] FOREIGN KEY([Dim_ActivityCategoryID])
REFERENCES [edw].[Dim_ActivityCategory] ([ID])
GO
ALTER TABLE [edw].[Fact_DailyActivity] CHECK CONSTRAINT [FK_Fact_DailyActivity_Dim_ActivityCategory1]
GO
ALTER TABLE [edw].[Fact_DailyActivity]  WITH CHECK ADD  CONSTRAINT [FK_Fact_DailyActivity_Dim_AppMaster] FOREIGN KEY([Dim_AppMasterID])
REFERENCES [edw].[Dim_AppMaster] ([ID])
GO
ALTER TABLE [edw].[Fact_DailyActivity] CHECK CONSTRAINT [FK_Fact_DailyActivity_Dim_AppMaster]
GO
ALTER TABLE [edw].[Fact_DailyActivity]  WITH CHECK ADD  CONSTRAINT [FK_Fact_DailyActivity_Dim_User] FOREIGN KEY([Dim_UserID])
REFERENCES [edw].[Dim_User] ([ID])
GO
ALTER TABLE [edw].[Fact_DailyActivity] CHECK CONSTRAINT [FK_Fact_DailyActivity_Dim_User]
GO
ALTER TABLE [edw].[Fact_DailyActivityPred]  WITH CHECK ADD  CONSTRAINT [FK_Fact_DailyActivity_Pred_CompanyID] FOREIGN KEY([Dim_CompanyID])
REFERENCES [edw].[Dim_Company] ([CompanyID])
GO
ALTER TABLE [edw].[Fact_DailyActivityPred] CHECK CONSTRAINT [FK_Fact_DailyActivity_Pred_CompanyID]
GO
ALTER TABLE [edw].[Fact_DailyActivityPred]  WITH CHECK ADD  CONSTRAINT [FK_Fact_DailyActivity_Pred_Dim_ActivityCategory] FOREIGN KEY([Dim_ActivityCategoryID])
REFERENCES [edw].[Dim_ActivityCategory] ([ID])
GO
ALTER TABLE [edw].[Fact_DailyActivityPred] CHECK CONSTRAINT [FK_Fact_DailyActivity_Pred_Dim_ActivityCategory]
GO
ALTER TABLE [edw].[Fact_DailyActivityPred]  WITH CHECK ADD  CONSTRAINT [FK_Fact_DailyActivity_Pred_Dim_AppParent] FOREIGN KEY([Dim_AppParentID])
REFERENCES [edw].[Dim_AppParent] ([ID])
GO
ALTER TABLE [edw].[Fact_DailyActivityPred] CHECK CONSTRAINT [FK_Fact_DailyActivity_Pred_Dim_AppParent]
GO
ALTER TABLE [edw].[Fact_DailyActivityPred]  WITH CHECK ADD  CONSTRAINT [FK_Fact_DailyActivity_Pred_Dim_User] FOREIGN KEY([Dim_UserID])
REFERENCES [edw].[Dim_User] ([ID])
GO
ALTER TABLE [edw].[Fact_DailyActivityPred] CHECK CONSTRAINT [FK_Fact_DailyActivity_Pred_Dim_User]
GO
ALTER TABLE [edw].[Fact_DailyActivityPred]  WITH CHECK ADD  CONSTRAINT [FK_Fact_DailyActivity_Pred_Dim_WebApp] FOREIGN KEY([Dim_WebAppID])
REFERENCES [edw].[Dim_WebApp] ([ID])
GO
ALTER TABLE [edw].[Fact_DailyActivityPred] CHECK CONSTRAINT [FK_Fact_DailyActivity_Pred_Dim_WebApp]
GO
ALTER TABLE [edw].[Fact_DailyPredVue]  WITH CHECK ADD  CONSTRAINT [FK_Fact_DailyPredVue_Dim_Company] FOREIGN KEY([Dim_CompanyID])
REFERENCES [edw].[Dim_Company] ([CompanyID])
GO
ALTER TABLE [edw].[Fact_DailyPredVue] CHECK CONSTRAINT [FK_Fact_DailyPredVue_Dim_Company]
GO
ALTER TABLE [edw].[Fact_DailyPredVue]  WITH CHECK ADD  CONSTRAINT [FK_Fact_DailyPredVue_Dim_User] FOREIGN KEY([Dim_UserID])
REFERENCES [edw].[Dim_User] ([ID])
GO
ALTER TABLE [edw].[Fact_DailyPredVue] CHECK CONSTRAINT [FK_Fact_DailyPredVue_Dim_User]
GO
ALTER TABLE [edw].[Fact_DailyUser]  WITH CHECK ADD  CONSTRAINT [FK_Fact_DailyUser_Dim_User] FOREIGN KEY([Dim_CompanyID])
REFERENCES [edw].[Dim_Company] ([CompanyID])
GO
ALTER TABLE [edw].[Fact_DailyUser] CHECK CONSTRAINT [FK_Fact_DailyUser_Dim_User]
GO
ALTER TABLE [edw].[Fact_DailyUserEmail]  WITH CHECK ADD  CONSTRAINT [FK_Fact_DailyUserEmail_Dim_Company] FOREIGN KEY([Dim_CompanyID])
REFERENCES [edw].[Dim_Company] ([CompanyID])
GO
ALTER TABLE [edw].[Fact_DailyUserEmail] CHECK CONSTRAINT [FK_Fact_DailyUserEmail_Dim_Company]
GO
ALTER TABLE [edw].[Fact_DailyUserEmail]  WITH CHECK ADD  CONSTRAINT [FK_Fact_DailyUserEmail_Dim_User] FOREIGN KEY([Dim_UserId])
REFERENCES [edw].[Dim_User] ([ID])
GO
ALTER TABLE [edw].[Fact_DailyUserEmail] CHECK CONSTRAINT [FK_Fact_DailyUserEmail_Dim_User]
GO
ALTER TABLE [edw].[Fact_DynamicActivityPred]  WITH CHECK ADD  CONSTRAINT [FK_Fact_DynamicActivityPred_Dim_CompanyID] FOREIGN KEY([Dim_CompanyID])
REFERENCES [edw].[Dim_Company] ([CompanyID])
GO
ALTER TABLE [edw].[Fact_DynamicActivityPred] CHECK CONSTRAINT [FK_Fact_DynamicActivityPred_Dim_CompanyID]
GO
ALTER TABLE [edw].[Fact_DynamicActivityPred]  WITH CHECK ADD  CONSTRAINT [FK_Fact_DynamicActivityPred_Dim_UserID] FOREIGN KEY([Dim_UserID])
REFERENCES [edw].[Dim_User] ([ID])
GO
ALTER TABLE [edw].[Fact_DynamicActivityPred] CHECK CONSTRAINT [FK_Fact_DynamicActivityPred_Dim_UserID]
GO
ALTER TABLE [edw].[Fact_DynamicCategoryPred]  WITH CHECK ADD  CONSTRAINT [FK_DynamicCategoryPred_Dim_CompanyID] FOREIGN KEY([Dim_CompanyID])
REFERENCES [edw].[Dim_Company] ([CompanyID])
GO
ALTER TABLE [edw].[Fact_DynamicCategoryPred] CHECK CONSTRAINT [FK_DynamicCategoryPred_Dim_CompanyID]
GO
ALTER TABLE [edw].[Fact_DynamicCategoryPred]  WITH CHECK ADD  CONSTRAINT [FK_Fact_DynamicCategoryPred_Dim_UserID] FOREIGN KEY([Dim_UserID])
REFERENCES [edw].[Dim_User] ([ID])
GO
ALTER TABLE [edw].[Fact_DynamicCategoryPred] CHECK CONSTRAINT [FK_Fact_DynamicCategoryPred_Dim_UserID]
GO
ALTER TABLE [edw].[Fact_DynamicUtilizationPred]  WITH CHECK ADD  CONSTRAINT [FK_Fact_DynamicUtilizationPred_Dim_User] FOREIGN KEY([Dim_UserId])
REFERENCES [edw].[Dim_User] ([ID])
GO
ALTER TABLE [edw].[Fact_DynamicUtilizationPred] CHECK CONSTRAINT [FK_Fact_DynamicUtilizationPred_Dim_User]
GO
ALTER TABLE [edw].[Fact_EditedUnaccountedUser]  WITH CHECK ADD  CONSTRAINT [FK_Fact_EditedUnaccountedUser_Dim_ActivityCategory] FOREIGN KEY([Dim_ActivityCategoryID])
REFERENCES [edw].[Dim_ActivityCategory] ([ID])
GO
ALTER TABLE [edw].[Fact_EditedUnaccountedUser] CHECK CONSTRAINT [FK_Fact_EditedUnaccountedUser_Dim_ActivityCategory]
GO
ALTER TABLE [edw].[Fact_EditedUnaccountedUser]  WITH CHECK ADD  CONSTRAINT [FK_Fact_EditedUnaccountedUser_Dim_Company] FOREIGN KEY([Dim_CompanyID])
REFERENCES [edw].[Dim_Company] ([CompanyID])
GO
ALTER TABLE [edw].[Fact_EditedUnaccountedUser] CHECK CONSTRAINT [FK_Fact_EditedUnaccountedUser_Dim_Company]
GO
ALTER TABLE [edw].[Fact_EditedUnaccountedUser]  WITH CHECK ADD  CONSTRAINT [FK_Fact_EditedUnaccountedUser_Dim_User] FOREIGN KEY([Dim_UserID])
REFERENCES [edw].[Dim_User] ([ID])
GO
ALTER TABLE [edw].[Fact_EditedUnaccountedUser] CHECK CONSTRAINT [FK_Fact_EditedUnaccountedUser_Dim_User]
GO
ALTER TABLE [edw].[Fact_EmailUser]  WITH CHECK ADD  CONSTRAINT [FK_Fact_EmailUser_Dim_Company] FOREIGN KEY([Dim_CompanyID])
REFERENCES [edw].[Dim_Company] ([CompanyID])
GO
ALTER TABLE [edw].[Fact_EmailUser] CHECK CONSTRAINT [FK_Fact_EmailUser_Dim_Company]
GO
ALTER TABLE [edw].[Fact_EmailUser]  WITH CHECK ADD  CONSTRAINT [FK_Fact_EmailUser_Dim_User] FOREIGN KEY([Dim_UserID])
REFERENCES [edw].[Dim_User] ([ID])
GO
ALTER TABLE [edw].[Fact_EmailUser] CHECK CONSTRAINT [FK_Fact_EmailUser_Dim_User]
GO
ALTER TABLE [edw].[Fact_FeatureSelectionImpact]  WITH CHECK ADD  CONSTRAINT [FK_Fact_FeatureSelectionImpact_Dim_CompanyID] FOREIGN KEY([Dim_CompanyID])
REFERENCES [edw].[Dim_Company] ([CompanyID])
GO
ALTER TABLE [edw].[Fact_FeatureSelectionImpact] CHECK CONSTRAINT [FK_Fact_FeatureSelectionImpact_Dim_CompanyID]
GO
ALTER TABLE [edw].[Fact_Integration]  WITH CHECK ADD  CONSTRAINT [FK_Fact_Integration_Dim_Company] FOREIGN KEY([Dim_CompanyID])
REFERENCES [edw].[Dim_Company] ([CompanyID])
GO
ALTER TABLE [edw].[Fact_Integration] CHECK CONSTRAINT [FK_Fact_Integration_Dim_Company]
GO
ALTER TABLE [edw].[Fact_Integration]  WITH CHECK ADD  CONSTRAINT [FK_Fact_Integration_Dim_IntegrationEntity] FOREIGN KEY([Dim_EntityID])
REFERENCES [edw].[Dim_IntegrationEntity] ([EntityID])
GO
ALTER TABLE [edw].[Fact_Integration] CHECK CONSTRAINT [FK_Fact_Integration_Dim_IntegrationEntity]
GO
ALTER TABLE [edw].[Fact_Integration]  WITH CHECK ADD  CONSTRAINT [FK_Fact_Integration_Dim_IntegrationProperty] FOREIGN KEY([Dim_PropertyID])
REFERENCES [edw].[Dim_IntegrationProperty] ([PropertyID])
GO
ALTER TABLE [edw].[Fact_Integration] CHECK CONSTRAINT [FK_Fact_Integration_Dim_IntegrationProperty]
GO
ALTER TABLE [edw].[Fact_Integration]  WITH CHECK ADD  CONSTRAINT [FK_Fact_Integration_Dim_User] FOREIGN KEY([Dim_UserID])
REFERENCES [edw].[Dim_User] ([ID])
GO
ALTER TABLE [edw].[Fact_Integration] CHECK CONSTRAINT [FK_Fact_Integration_Dim_User]
GO
ALTER TABLE [edw].[Fact_JobFamilyAnomaly]  WITH CHECK ADD  CONSTRAINT [FK_Dim_Company_Fact_JobFamilyAnomaly] FOREIGN KEY([Dim_CompanyID])
REFERENCES [edw].[Dim_Company] ([CompanyID])
GO
ALTER TABLE [edw].[Fact_JobFamilyAnomaly] CHECK CONSTRAINT [FK_Dim_Company_Fact_JobFamilyAnomaly]
GO
ALTER TABLE [edw].[Fact_JobFamilyAnomaly]  WITH CHECK ADD  CONSTRAINT [FK_Dim_JobFamilyProfile_Fact_JobFamilyAnomaly] FOREIGN KEY([Dim_JobFamilyProfileID])
REFERENCES [edw].[Dim_JobFamilyProfile] ([ID])
GO
ALTER TABLE [edw].[Fact_JobFamilyAnomaly] CHECK CONSTRAINT [FK_Dim_JobFamilyProfile_Fact_JobFamilyAnomaly]
GO
ALTER TABLE [edw].[Fact_JobFamilyAnomaly]  WITH CHECK ADD  CONSTRAINT [FK_Dim_User_Fact_JobFamilyAnomaly] FOREIGN KEY([Dim_UserID])
REFERENCES [edw].[Dim_User] ([ID])
GO
ALTER TABLE [edw].[Fact_JobFamilyAnomaly] CHECK CONSTRAINT [FK_Dim_User_Fact_JobFamilyAnomaly]
GO
ALTER TABLE [edw].[Fact_MeetingImpact]  WITH CHECK ADD  CONSTRAINT [FK_Fact_MeetingImpact_Dim_CompanyID] FOREIGN KEY([Dim_CompanyID])
REFERENCES [edw].[Dim_Company] ([CompanyID])
GO
ALTER TABLE [edw].[Fact_MeetingImpact] CHECK CONSTRAINT [FK_Fact_MeetingImpact_Dim_CompanyID]
GO
ALTER TABLE [edw].[Fact_MeetingImpact]  WITH CHECK ADD  CONSTRAINT [FK_Fact_MeetingImpact_Dim_JobFamID] FOREIGN KEY([Dim_JobFamilyProfileID])
REFERENCES [edw].[Dim_JobFamilyProfile] ([ID])
GO
ALTER TABLE [edw].[Fact_MeetingImpact] CHECK CONSTRAINT [FK_Fact_MeetingImpact_Dim_JobFamID]
GO
ALTER TABLE [edw].[Fact_TimeSlot]  WITH CHECK ADD  CONSTRAINT [FK_Dim_WebApp_FactTimeSlot] FOREIGN KEY([Dim_WebAppID])
REFERENCES [edw].[Dim_WebApp] ([ID])
GO
ALTER TABLE [edw].[Fact_TimeSlot] CHECK CONSTRAINT [FK_Dim_WebApp_FactTimeSlot]
GO
ALTER TABLE [edw].[Fact_TimeSlot]  WITH CHECK ADD  CONSTRAINT [FK_FactTimeSlot_Dim_ActivityCategory1] FOREIGN KEY([Dim_ActivityCategoryID])
REFERENCES [edw].[Dim_ActivityCategory] ([ID])
GO
ALTER TABLE [edw].[Fact_TimeSlot] CHECK CONSTRAINT [FK_FactTimeSlot_Dim_ActivityCategory1]
GO
ALTER TABLE [edw].[Fact_TimeSlot]  WITH CHECK ADD  CONSTRAINT [FK_FactTimeSlot_Dim_AppMaster] FOREIGN KEY([Dim_AppMasterID])
REFERENCES [edw].[Dim_AppMaster] ([ID])
GO
ALTER TABLE [edw].[Fact_TimeSlot] CHECK CONSTRAINT [FK_FactTimeSlot_Dim_AppMaster]
GO
ALTER TABLE [edw].[Fact_TimeSlot]  WITH CHECK ADD  CONSTRAINT [FK_FactTimeSlot_Dim_CompanyID] FOREIGN KEY([Dim_CompanyID])
REFERENCES [edw].[Dim_Company] ([CompanyID])
GO
ALTER TABLE [edw].[Fact_TimeSlot] CHECK CONSTRAINT [FK_FactTimeSlot_Dim_CompanyID]
GO
ALTER TABLE [edw].[Fact_TimeSlot]  WITH CHECK ADD  CONSTRAINT [FK_FactTimeSlot_Dim_MachineID] FOREIGN KEY([Dim_MachineID])
REFERENCES [edw].[Dim_Machine] ([ID])
GO
ALTER TABLE [edw].[Fact_TimeSlot] CHECK CONSTRAINT [FK_FactTimeSlot_Dim_MachineID]
GO
ALTER TABLE [edw].[Fact_TimeSlot]  WITH CHECK ADD  CONSTRAINT [FK_FactTimeSlot_Dim_NetworkID] FOREIGN KEY([Dim_NetworkID])
REFERENCES [edw].[Dim_Network] ([ID])
GO
ALTER TABLE [edw].[Fact_TimeSlot] CHECK CONSTRAINT [FK_FactTimeSlot_Dim_NetworkID]
GO
ALTER TABLE [edw].[Fact_TimeSlot]  WITH CHECK ADD  CONSTRAINT [FK_FactTimeSlot_Dim_User] FOREIGN KEY([Dim_UserID])
REFERENCES [edw].[Dim_User] ([ID])
GO
ALTER TABLE [edw].[Fact_TimeSlot] CHECK CONSTRAINT [FK_FactTimeSlot_Dim_User]
GO
ALTER TABLE [edw].[Fact_TimeSlotMeeting]  WITH CHECK ADD  CONSTRAINT [FK_Fact_TimeSlotMeeting_Dim_Company] FOREIGN KEY([Dim_CompanyID])
REFERENCES [edw].[Dim_Company] ([CompanyID])
GO
ALTER TABLE [edw].[Fact_TimeSlotMeeting] CHECK CONSTRAINT [FK_Fact_TimeSlotMeeting_Dim_Company]
GO
ALTER TABLE [edw].[Fact_TimeSlotMeeting]  WITH CHECK ADD  CONSTRAINT [FK_Fact_TimeSlotMeeting_Dim_User] FOREIGN KEY([Dim_UserID])
REFERENCES [edw].[Dim_User] ([ID])
GO
ALTER TABLE [edw].[Fact_TimeSlotMeeting] CHECK CONSTRAINT [FK_Fact_TimeSlotMeeting_Dim_User]
GO
ALTER TABLE [edw].[Fact_TimeSlotTemp]  WITH CHECK ADD  CONSTRAINT [FK_Fact_TimeSlotTemp_Dim_ActivityCategory1] FOREIGN KEY([Dim_ActivityCategoryID])
REFERENCES [edw].[Dim_ActivityCategory] ([ID])
GO
ALTER TABLE [edw].[Fact_TimeSlotTemp] CHECK CONSTRAINT [FK_Fact_TimeSlotTemp_Dim_ActivityCategory1]
GO
ALTER TABLE [edw].[Fact_TimeSlotTemp]  WITH CHECK ADD  CONSTRAINT [FK_Fact_TimeSlotTemp_Dim_AppMaster] FOREIGN KEY([Dim_AppMasterID])
REFERENCES [edw].[Dim_AppMaster] ([ID])
GO
ALTER TABLE [edw].[Fact_TimeSlotTemp] CHECK CONSTRAINT [FK_Fact_TimeSlotTemp_Dim_AppMaster]
GO
ALTER TABLE [edw].[Fact_TimeSlotTemp]  WITH CHECK ADD  CONSTRAINT [FK_Fact_TimeSlotTemp_Dim_CompanyID] FOREIGN KEY([Dim_CompanyID])
REFERENCES [edw].[Dim_Company] ([CompanyID])
GO
ALTER TABLE [edw].[Fact_TimeSlotTemp] CHECK CONSTRAINT [FK_Fact_TimeSlotTemp_Dim_CompanyID]
GO
ALTER TABLE [edw].[Fact_TimeSlotTemp]  WITH CHECK ADD  CONSTRAINT [FK_Fact_TimeSlotTemp_Dim_User] FOREIGN KEY([Dim_UserID])
REFERENCES [edw].[Dim_User] ([ID])
GO
ALTER TABLE [edw].[Fact_TimeSlotTemp] CHECK CONSTRAINT [FK_Fact_TimeSlotTemp_Dim_User]
GO
ALTER TABLE [edw].[Fact_UnmappedAppUsage]  WITH CHECK ADD  CONSTRAINT [FK_Fact_UnmappedAppUsage_Dim_AppParent] FOREIGN KEY([Dim_AppParentID])
REFERENCES [edw].[Dim_AppParent] ([ID])
GO
ALTER TABLE [edw].[Fact_UnmappedAppUsage] CHECK CONSTRAINT [FK_Fact_UnmappedAppUsage_Dim_AppParent]
GO
ALTER TABLE [edw].[Fact_UnmappedAppUsage]  WITH CHECK ADD  CONSTRAINT [FK_Fact_UnmappedAppUsage_Dim_Company] FOREIGN KEY([Dim_CompanyID])
REFERENCES [edw].[Dim_Company] ([CompanyID])
GO
ALTER TABLE [edw].[Fact_UnmappedAppUsage] CHECK CONSTRAINT [FK_Fact_UnmappedAppUsage_Dim_Company]
GO
ALTER TABLE [edw].[Fact_UserDataSyncInfo]  WITH CHECK ADD  CONSTRAINT [FK_Fact_UserDataSyncInfo_Dim_User] FOREIGN KEY([Dim_UserId])
REFERENCES [edw].[Dim_User] ([ID])
GO
ALTER TABLE [edw].[Fact_UserDataSyncInfo] CHECK CONSTRAINT [FK_Fact_UserDataSyncInfo_Dim_User]
GO
ALTER TABLE [edw].[Log_TimeSlotProcessStatus]  WITH CHECK ADD  CONSTRAINT [FK_Log_TimeSlotProcessStatus_Dim_Company] FOREIGN KEY([CompanyID])
REFERENCES [edw].[Dim_Company] ([CompanyID])
GO
ALTER TABLE [edw].[Log_TimeSlotProcessStatus] CHECK CONSTRAINT [FK_Log_TimeSlotProcessStatus_Dim_Company]
GO
ALTER TABLE [edw].[Log_UnaccountedDims]  WITH CHECK ADD  CONSTRAINT [FK_Log_MissingAppMappings_Dim_Company] FOREIGN KEY([CompanyID])
REFERENCES [edw].[Dim_Company] ([CompanyID])
GO
ALTER TABLE [edw].[Log_UnaccountedDims] CHECK CONSTRAINT [FK_Log_MissingAppMappings_Dim_Company]
GO
ALTER TABLE [edw].[Stg_TimeSlot]  WITH CHECK ADD  CONSTRAINT [FK_Stg_TimeSlot_Dim_ActivityCategory1] FOREIGN KEY([Dim_ActivityCategoryID])
REFERENCES [edw].[Dim_ActivityCategory] ([ID])
GO
ALTER TABLE [edw].[Stg_TimeSlot] CHECK CONSTRAINT [FK_Stg_TimeSlot_Dim_ActivityCategory1]
GO
ALTER TABLE [edw].[Stg_TimeSlot]  WITH CHECK ADD  CONSTRAINT [FK_Stg_TimeSlot_Dim_AppMaster] FOREIGN KEY([Dim_AppMasterID])
REFERENCES [edw].[Dim_AppMaster] ([ID])
GO
ALTER TABLE [edw].[Stg_TimeSlot] CHECK CONSTRAINT [FK_Stg_TimeSlot_Dim_AppMaster]
GO
ALTER TABLE [edw].[Stg_TimeSlot]  WITH CHECK ADD  CONSTRAINT [FK_Stg_TimeSlot_Dim_CompanyID] FOREIGN KEY([Dim_CompanyID])
REFERENCES [edw].[Dim_Company] ([CompanyID])
GO
ALTER TABLE [edw].[Stg_TimeSlot] CHECK CONSTRAINT [FK_Stg_TimeSlot_Dim_CompanyID]
GO
ALTER TABLE [edw].[Stg_TimeSlot]  WITH CHECK ADD  CONSTRAINT [FK_Stg_timeSlot_Dim_MachineID] FOREIGN KEY([Dim_MachineID])
REFERENCES [edw].[Dim_Machine] ([ID])
GO
ALTER TABLE [edw].[Stg_TimeSlot] CHECK CONSTRAINT [FK_Stg_timeSlot_Dim_MachineID]
GO
ALTER TABLE [edw].[Stg_TimeSlot]  WITH CHECK ADD  CONSTRAINT [FK_Stg_timeSlot_Dim_NetworkID] FOREIGN KEY([Dim_NetworkID])
REFERENCES [edw].[Dim_Network] ([ID])
GO
ALTER TABLE [edw].[Stg_TimeSlot] CHECK CONSTRAINT [FK_Stg_timeSlot_Dim_NetworkID]
GO
ALTER TABLE [edw].[Stg_TimeSlot]  WITH CHECK ADD  CONSTRAINT [FK_Stg_TimeSlot_Dim_User] FOREIGN KEY([Dim_UserID])
REFERENCES [edw].[Dim_User] ([ID])
GO
ALTER TABLE [edw].[Stg_TimeSlot] CHECK CONSTRAINT [FK_Stg_TimeSlot_Dim_User]
GO
/****** Object:  StoredProcedure [dbo].[KABIL]    Script Date: 9/10/2021 8:10:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   procedure [dbo].[KABIL](@a int,@b int)
as
begin

BEGIN TRY
	declare @c int
	set @c=@a+@b
	print @c
END TRY
BEGIN CATCH
	select ERROR_NUMBER() as ErrorNumber,
	ERROR_STATE() as ErrorState,
	ERROR_MESSAGE() as ErrorMessage,
	ERROR_PROCEDURE() as ErrorProcedure,
	ERROR_LINE() as ErrorLine

END CATCH

end
GO
/****** Object:  StoredProcedure [dbo].[sp_alterdiagram]    Script Date: 9/10/2021 8:10:28 AM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_creatediagram]    Script Date: 9/10/2021 8:10:28 AM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_dropdiagram]    Script Date: 9/10/2021 8:10:28 AM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_helpdiagramdefinition]    Script Date: 9/10/2021 8:10:28 AM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_helpdiagrams]    Script Date: 9/10/2021 8:10:28 AM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_renamediagram]    Script Date: 9/10/2021 8:10:28 AM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_upgraddiagrams]    Script Date: 9/10/2021 8:10:28 AM ******/
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
/****** Object:  StoredProcedure [dbo].[sproc_AddImportedUsers]    Script Date: 9/10/2021 8:10:28 AM ******/
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
									(@CompanyID, null, null, @JobFamilyID, @LocationID, null, @EmployeeCode, @UserEmail, @FirstName, @LastName, @JobTitle, null,null , 1,
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
							
								l.[ExternalUserI] = @EmployeeCode,
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

			---UPDATE T1
			---SET T1.IsTeam = 1
			---FROM #Team T1, [org].[Team] T2
			---WHERE T1.CompanyID = T2.CompanyID AND CONCAT(SUBSTRING(T1.ReportsToUserEmail,0,charindex('@',T1.ReportsToUserEmail,0)),' Team') =  T2.TeamName
			
			UPDATE T1
			SET T1.IsTeam = 1
			FROM #Team T1, [org].[Team] T2
			WHERE T1.CompanyID = T2.CompanyID AND T1.DimUserID =  T2.ManagerID


			INSERT INTO [org].[Team]
			([CompanyID], [ManagerID], [TeamName], [TeamDescription], [IsEmployeeActivityVisible], [ModifiedBy])
			Select CompanyID, DimUserID, CONCAT(SUBSTRING(ReportsToUserEmail,0,charindex('@',ReportsToUserEmail,0)),' Team'), null, 1, 'System' From #Team
			Where IsTeam = 0

			--- TeamID population on User Table
			
			Select CompanyID, UserEmail, ReportsToUserEmail INTO #ReportsToDetails From [dbo].[ImportUsers] Where CompanyID = @CompanyID


			ALTER Table #ReportsToDetails
			ADD TeamID int, ReportUserID int

			UPDATE T1
			SET T1.ReportUserID = T2.UserID
			FROM #ReportsToDetails T1, org.Users T2
			WHERE T1.CompanyID = T2.CompanyID AND T1.ReportsToUserEmail =  T2.Useremail


			UPDATE T1
			SET T1.TeamID = T2.TeamID
			FROM #ReportsToDetails T1, org.Team T2
			WHERE T1.CompanyID = T2.CompanyID AND T1.ReportUserID =  T2.ManagerID


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
/****** Object:  StoredProcedure [dbo].[sproc_EnableDisableConstraints]    Script Date: 9/10/2021 8:10:28 AM ******/
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

			--PRINT @cmd
			EXEC( @cmd )

			FETCH NEXT FROM table_cursor INTO @schema_name, @table_name
		END

		CLOSE table_cursor
		DEALLOCATE table_cursor

	COMMIT TRAN A

		PRINT 'Success:: Disable Constraints'
	
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
/****** Object:  StoredProcedure [dbo].[sproc_GetAppMappings]    Script Date: 9/10/2021 8:10:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE     PROCEDURE [dbo].[sproc_GetAppMappings]
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
/****** Object:  StoredProcedure [dbo].[sproc_PurgeDataForCompany]    Script Date: 9/10/2021 8:10:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sproc_PurgeDataForCompany]

	@CompanyID smallint,
	@TimeOutLimit smallint = 240,
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

	if (@DBServerName <>  @Portal)
	begin

		set @Error = 'This is not ' + @Portal +' portal. Script will not run.' 
		RAISERROR(@Error, 16, 16)
	
		RETURN
	end




	BEGIN TRAN A
	BEGIN TRY

	
		DECLARE table_cursor CURSOR FOR
		SELECT
			tables.name, columns.name
		FROM
			sys.tables
			INNER JOIN sys.schemas ON tables.schema_id = schemas.schema_id
			INNER JOIN sys.columns ON tables.object_id = columns.object_id
		WHERE
			schemas.Name = 'edw' and columns.name IN ('CompanyID', 'Dim_CompanyID')
			
				
		DECLARE @TableName NVARCHAR(1000), @CompanyFilterName NVARCHAR(50)
     
  
		---- PRINT '-------- Table data deletion cursor --------';  
  
		--DECLARE table_cursor CURSOR FOR   
		--SELECT TableName
		--FROM @PurgeTables  
	  
		OPEN table_cursor  
  
		FETCH NEXT FROM table_cursor   
		INTO @TableName, @CompanyFilterName
  
		WHILE @@FETCH_STATUS = 0  
		BEGIN  

			select 'Table To purge => ' + @TableName

			exec [dbo].[sproc_PurgeEDWDataForCompany] @CompanyID = @CompanyID, @DbName = 'edw', @TableName = @TableName, @CompanyFilterName = @CompanyFilterName

			FETCH NEXT FROM table_cursor   
			INTO @TableName, @CompanyFilterName
  
     
		END

		CLOSE table_cursor
		DEALLOCATE table_cursor  


	COMMIT TRAN A

		PRINT 'Success:: Disable Constraints'
	
	END TRY

	BEGIN CATCH
		
		ROLLBACK TRAN A

		CLOSE table_cursor
		DEALLOCATE table_cursor  


		PRINT 'Error: changes rolled back'
		DECLARE @ErrorStr NVARCHAR(4000)
		SET @ErrorStr  ='ERROR: ERR_NO: ' + CONVERT(VARCHAR(20),ERROR_NUMBER()) + ', ERR_MSG: '  + ERROR_MESSAGE()
			RAISERROR (@ErrorStr , -- Message text.
			   16, -- Severity,
			   1); -- State.
	END CATCH
	

	SET NOCOUNT OFF

END

GO
/****** Object:  StoredProcedure [dbo].[sproc_PurgeEDWDataForCompany]    Script Date: 9/10/2021 8:10:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sproc_PurgeEDWDataForCompany]

	@CompanyID smallint,
	@TimeOutLimit smallint = 240,
	@DbName nvarchar(100),
	@Portal NVARCHAR(1000) = '',
	@TableId smallint = -1, -- -1: do not add table id
	@TableName nvarchar(100),
	@CompanyFilterName nvarchar(100),
	@CompanyFilterName1 nvarchar(100) = '',
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
		,@RetentionPeriod smallint = 120
		,@DayBatchSize smallint = 30
		,@BatchLimit int = 100 -- Max Batches
		,@RetentionParam nvarchar(100)
		,@RetentionDate date	
		,@Table nvarchar(100) =  @TableName + case @TableId when -1 then '' else convert(nvarchar, @TableId) end
		,@FilterCondition nvarchar(4000) = ''
		,@LogName nvarchar(4000) = 'sproc_PurgeEDWDataForCompany, Table => ' +  @DbName + '.edw.'+ @TableName, @LogDesc nvarchar(4000) = '', @ProcStartTime datetime = GetDate()
		,@ElapsedTimeInMins int = 0

	

	if (@RetentionParam = '')
	begin
		return; -- Invalid Table for Cleanup
	end

	if (@CompanyFilterName1 <> '')
	begin

		if (@CompareAllFilters = 0)
		begin

			set @CompanyFilterName =  ' IsNull(' + @CompanyFilterName + ',' + @CompanyFilterName1 + ') '
			
		end
		else begin
			set @CompanyFilterName = ' ( case when ' + @CompanyFilterName + ' > '  + @CompanyFilterName1 + ' then ' + @CompanyFilterName + ' else ' + @CompanyFilterName1 + ' end ) '
		end	
	end	

	declare @RootOrgs table (Idx smallint identity(1,1), CompanyID smallint, RetentionPeriod int, [BatchSize] smallint
		, BatchLimit int)
	
	declare @CompanyIdx int = 0, @CompanyCount int = 0 

	set @CompanyCount = @@ROWCOUNT

	
	if (@Debug = 100)

		select * from @RootOrgs

	-- Find Min and Max Date for the range to be deleted -- , @MaxDate = MAX(a.' + @CompanyFilterName + ')
	declare  @sqlInitRange nvarchar(max) = ' select @FromDate = MIN(' + @CompanyFilterName + ')
		from ' + 'edw.'+ @Table + ' a 
		where 
			a.CompanyID = @CompanyID '

	-- purge records before @ToDate (and eventually before @RetentionDate)
	declare @sqlPurge nvarchar(max) = ' delete a from ' + 'edw.[' + @Table + '] a 
		where 
			a.'+ @CompanyFilterName + ' = @CompanyID '
	
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


			exec sp_executesql @sqlPurge, N'@CompanyID smallint, @FromDate Date, @ToDate Date, @DelCount int out'
			, @CompanyID, @FromDate, @ToDate, @DelCount out

			set @LogDesc = ' DelCount = ' + IsNull(convert(varchar, @DelCount), '') 
				--+ ' ' + ', BatchCount = ' + IsNull(convert(varchar, @BatchCount), '')

			select @LogDesc 'LogDesc'

		
	
			-- Log RowsDeleted if required..
				
		end try
		begin catch

			SELECT  @ErrorStr  ='ERROR: sproc_PurgeEDWDataForCompany 1: ' + @Table +  ', RootOrg => ' +  CONVERT(VARCHAR(20),@CompanyID) + ' ' + ERROR_MESSAGE()
				RAISERROR (@ErrorStr , -- Message text.
					18, -- Severity,
					3); -- State.
	
		end catch

	--END

	IF (@DEBUG = 1)
	BEGIN		
		select 'sproc_PurgeEDWDataForCompany END'
	END	

	if (@Debug = 100)
	BEGIN
		set @LogDesc = 'Cleanup End' 
		select @LogDesc 'Log Details'
	END					
	
	SET NOCOUNT OFF
END

GO
/****** Object:  StoredProcedure [dbo].[sproc_PurgeFactDataForCompany]    Script Date: 9/10/2021 8:10:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





/*****************************************************************************
	
	 exec [dbo].[sproc_PurgeFactDataForCompany] @CompanyID = 0,
	@DbName = 'EDW',
	@TableName = 'abc',
	@FilterColumn = 'xyz'


 *****************************************************************************/

	
CREATE   PROCEDURE [dbo].[sproc_PurgeFactDataForCompany]

	@CompanyID smallint,
	@TimeOutLimit smallint = 240,
	@DbName nvarchar(100),
	@TableId smallint = -1, -- -1: do not add table id
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
		,@RetentionPeriod smallint = 120
		,@DayBatchSize smallint = 30
		,@BatchLimit int = 100 -- Max Batches
		,@RetentionParam nvarchar(100)
		,@RetentionDate date	
		,@Table nvarchar(100) =  @TableName + case @TableId when -1 then '' else convert(nvarchar, @TableId) end
		,@FilterCondition nvarchar(4000) = ''
		,@LogName nvarchar(4000) = 'sproc_PurgeFactDataForCompany, Table => ' +  @DbName + '.dbo.'+ @TableName, @LogDesc nvarchar(4000) = '', @ProcStartTime datetime = GetDate()
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

	declare @RootOrgs table (Idx smallint identity(1,1), CompanyID smallint, RetentionPeriod int, [BatchSize] smallint
		, BatchLimit int)
	
	declare @RootOrgIdx int = 0, @RootOrgCount int = 0 

	insert into @RootOrgs(CompanyID, RetentionPeriod, [BatchSize], BatchLimit)
	select 0, 100, 10000, 100000
	--select  
	--	r.CompanyID
	--	,IsNull(max(case r.ParameterName when @RetentionParam then convert(int, r.ParameterValue) else NULL end), @RetentionPeriod) RetentionPeriod
	--	,IsNull(max(case r.ParameterName when 'DaysBatchSize' then convert(int, r.ParameterValue) else NULL end), @DayBatchSize) [BatchSize]
	--	,IsNull(max(case r.ParameterName when 'BatchLimit' then convert(int, r.ParameterValue) else NULL end), @BatchLimit) BatchLimit
		
	--from registry.dbo.Parameters r with (nolock)
	--where 
	--	(@CompanyID = 0 OR r.CompanyID = @CompanyID) -- All ( = 0)  or for a specific RootOrg
	--	and r.IsDeleted = 0 and r.ParameterName in (@RetentionParam, 'DaysBatchSize', 'BatchLimit')
	--group by r.CompanyID
	--order by NEWID() 
	set @RootOrgCount = @@ROWCOUNT

	--if (@CompanyID = 0)
	--begin
		
	--	-- Copy values of RootOrg 1 to RootOrg 0, till we get RootOrg 0 params in UI. 
	--	insert into @RootOrgs(CompanyID, RetentionPeriod, [BatchSize], BatchLimit)

	--	select 
	--		0 CompanyID, r.RetentionPeriod, r.BatchSize, r.BatchLimit
	--	from @RootOrgs r where 
	--		r.CompanyID = 1

	--	if (@@ROWCOUNT = 0)
	--	begin
		
	--		-- RootOrg 1 deleted. So add defaults for RootOrg 0.
	--		insert into @RootOrgs(CompanyID, RetentionPeriod, [BatchSize], BatchLimit)
	--		values(0, @RetentionPeriod, @DayBatchSize, @BatchLimit)
		
	--	end	

	--	set @RootOrgCount = @RootOrgCount + 1

	--end

	select @Table = 'Fact_DailyActivity', @FilterColumn = 'ActivityDate'

	if (@Debug = 100)

		select * from @RootOrgs

	-- Find Min and Max Date for the range to be deleted -- , @MaxDate = MAX(a.' + @FilterColumn + ')
	declare  @sqlInitRange nvarchar(max) = ' select @FromDate = MIN(' + @FilterColumn + ')
		from ' + 'edw.'+ @Table + ' a 
		where 
			a.Dim_CompanyID = @CompanyID and ' + @FilterColumn + ' < @RetentionDate '

	-- purge records before @ToDate (and eventually before @RetentionDate)
	declare @sqlPurge nvarchar(max) = ' delete a from ' + 'edw.' + @Table + ' a 
		where 
			a.Dim_CompanyID = @CompanyID and ' + @FilterColumn + ' >= @FromDate and ' + @FilterColumn + ' < @ToDate 
			
			set @DelCount = @@ROWCOUNT
			
			'
	
	if (@Debug = 99)
	begin
		
		print '@sqlInitRange => ' + @sqlInitRange
		print '----------------'
		print '----------------'
		print '@sqlPurge => ' + @sqlPurge

	end
	
	if (@Debug = 100)
	begin
		
		set @LogDesc = 'Company Count for Purge, => ' + convert(varchar, @RootOrgCount)

		--INSERT INTO [dbo].[SapTraceLog] ([CompanyID] ,[LDate] ,[Name] ,[LogDesc] ,[ETInMS])
		--VALUES (@CompanyID, GetDate(), @LogName , @LogDesc,  DATEDIFF(second, @ProcStartTime, GetDate()))
		select @LogDesc 'Log Details'

	end

	

	while (@RootOrgIdx < @RootOrgCount and  @ElapsedTimeInMins < @TimeOutLimit)
	begin

		begin try

			set @BatchCount = 0
			set @DelCount = -1
			set @RootOrgIdx = @RootOrgIdx + 1

			select 
				@CompanyID = CompanyID, @RetentionDate = DATEADD(day, -RetentionPeriod,GETDATE()) 
				,@DayBatchSize = r.[BatchSize], @BatchLimit = r.BatchLimit
			from @RootOrgs r where r.Idx = @RootOrgIdx

			if (@Debug = 100)
			begin
				set @LogDesc = 'Begin Cleanup, ElapsedTimeInMins => ' + convert(varchar, @ElapsedTimeInMins)

				--INSERT INTO [dbo].[SapTraceLog] ([CompanyID] ,[LDate] ,[Name] ,[LogDesc] ,[ETInMS])
				--VALUES (@CompanyID, GetDate(), @LogName , @LogDesc,  DATEDIFF(second, @ProcStartTime, GetDate()))

				select @LogDesc 'Log Details'
			end

			exec sp_executesql @sqlInitRange, N'@CompanyID smallint, @RetentionDate date, @FromDate date out' -- , @MaxDate date out
				, @CompanyID, @RetentionDate, @FromDate out --, @MaxDate out

			if (@FromDate IS NULL)
				set @FromDate = '2000-01-01'

			if (@Debug = 100)
			begin
				set @LogDesc = 'Init, RetentionDate => ' + IsNull(convert(varchar, @RetentionDate, 120), 'NULL')
					+ ', FromDate => ' + IsNull(convert(varchar, @FromDate, 120), 'NULL')

				--INSERT INTO [dbo].[SapTraceLog] ([CompanyID] ,[LDate] ,[Name] ,[LogDesc] ,[ETInMS])
				--VALUES (@CompanyID, GetDate(), @LogName , @LogDesc,  DATEDIFF(second, @ProcStartTime, GetDate()))

				select @LogDesc 'Log Details'

			end

			set @ToDate = DATEADD(DAY, @DayBatchSize, @FromDate)
					
			if (@ToDate >= @RetentionDate)
			begin
				set @ToDate = DATEADD(DAY, -1, @RetentionDate)
			end
				

			WHILE (@DelCount <> 0 and @BatchCount < @BatchLimit and @FromDate < @RetentionDate)
			BEGIN
				BEGIN TRY
				
					set @BatchCount = @BatchCount + 1
					
					exec sp_executesql @sqlPurge, N'@CompanyID smallint, @FromDate Date, @ToDate Date, @DelCount int out'
					, @CompanyID, @FromDate, @ToDate, @DelCount out
					
					if (@Debug = 100)
					BEGIN
						set @LogDesc = 'Post Purge, DelCount => ' + IsNull(convert(varchar, @DelCount, 120), 'Null') 
							+ ', BatchCount => ' + IsNull(convert(varchar, @BatchCount, 120), 'Null') 
							+ ', FromDate => ' + IsNull(convert(varchar, @FromDate, 120), 'Null')
							+ ', ToDate => ' + IsNull(convert(varchar, @ToDate, 120), 'Null')

						--INSERT INTO [dbo].[SapTraceLog] ([CompanyID] ,[LDate] ,[Name] ,[LogDesc] ,[ETInMS])
						--VALUES (@CompanyID, GetDate(), @LogName , @LogDesc,  DATEDIFF(second, @ProcStartTime, GetDate()))

						select @LogDesc 'Log Details'
					END
					
				END TRY
	
				BEGIN CATCH
		
					SET @ErrorStr  ='ERROR: sproc_PurgeFactDataForCompany: ' + @Table + ', RootOrg => ' +  CONVERT(VARCHAR(20),@CompanyID) + ' ' + ERROR_MESSAGE()
					RAISERROR (@ErrorStr , -- Message text.
					   18, -- Severity,
					   3); -- State.
	
					
				END CATCH
		
				set @FromDate = DATEADD( DAY, 1, @ToDate)
				set @ToDate = DATEADD(DAY, @DayBatchSize, @ToDate)
					
				if (@ToDate >= @RetentionDate)
				begin
					set @ToDate = DATEADD(DAY, -1, @RetentionDate)
				end
					
			END	
			
			set @ElapsedTimeInMins = DATEDIFF(MINUTE,@ProcStartTime,GETDATE())
	
			-- Log RowsDeleted if required..
				
		end try
		begin catch

			SELECT  @ErrorStr  ='ERROR: sproc_PurgeFactDataForCompany 1: ' + @Table +  ', RootOrg => ' +  CONVERT(VARCHAR(20),@CompanyID) + ' ' + ERROR_MESSAGE()
				RAISERROR (@ErrorStr , -- Message text.
					18, -- Severity,
					3); -- State.
	
		end catch

	END

	IF (@DEBUG = 1)
	BEGIN		
		select 'sproc_PurgeFactDataForCompany END'
	END	

	if (@Debug = 100)
	BEGIN
		set @LogDesc = 'Cleanup End' 
		--INSERT INTO [dbo].[SapTraceLog] ([CompanyID] ,[LDate] ,[Name] ,[LogDesc] ,[ETInMS])
		--VALUES (@CompanyID, GetDate(), @LogName , @LogDesc,  DATEDIFF(second, @ProcStartTime, GetDate()))

		select @LogDesc 'Log Details'
	END					
	
	SET NOCOUNT OFF
END
GO
/****** Object:  StoredProcedure [dbo].[sproc_userDeletionFromEDW]    Script Date: 9/10/2021 8:10:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sproc_userDeletionFromEDW]

(
	@CompanyID INT, 
	@Useremail [nvarchar](255),
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

			--------------

			DECLARE @Dim_UserID int , @TimeSlotCount int = 0 , @TeamID int , @TeamCount int = 0 , @DepartmentIDManagercount int = 0

			

				SELECT @Dim_UserID = ID from edw.Dim_User Where CompanyID = @CompanyID and Useremail = @Useremail

				Select @TimeSlotCount = count(*) from edw.Fact_TimeSlot where Dim_UserID = @Dim_UserID

				Select @TeamID = ID from [edw].[Dim_Team] Where ManagerID = @Dim_UserID

				Select @TeamCount = count(*) from [edw].[Dim_User] Where DimTeamID = @TeamID

				Select @DepartmentIDManagercount = count(*) From  [edw].[Dim_Department] Where ManagerDimUserID = @Dim_UserID


						if ( @Dim_UserID is null ) 
						BEGIN

							set @ErrorValidation = @ErrorValidation + 'No Record Found in User Table' + CHAR(10)
						
						select 'No Record Found For :   ' + @Useremail
						SELECT @Useremail
						
						END

						if ( @TimeSlotCount > 0 ) 
						BEGIN

							set @ErrorValidation = @ErrorValidation + 'Record Found in Edw.TimeSlot Table' + CHAR(10)
										
						END

						if ( @TeamCount > 0 ) 
						BEGIN

							set @ErrorValidation = @ErrorValidation + 'User Found under his Team' + CHAR(10)
										
						END

						if ( @DepartmentIDManagercount > 0 ) 
						BEGIN

							set @ErrorValidation = @ErrorValidation + 'Department manager' + CHAR(10)

						SELECT @Useremail
										
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
						
						Delete from edw.Fact_DailyUserEmail Where Dim_UserID = @Dim_UserID

						Delete from [edw].[Dim_UserDomain] WHere Dim_UserID = @Dim_UserID

						Delete from [edw].[Dim_User] Where ID = @Dim_UserID


						select 'User Deleted Succesfully :   ' + @Useremail


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
/****** Object:  StoredProcedure [edw].[PankajTest]    Script Date: 9/10/2021 8:10:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE     PROCEDURE [edw].[PankajTest]
--PLEASE SEE PRODUCT BACKLOG ITEMS 19864 AND 18540
(
	@CompanyID INT, 
	@Entity VARCHAR(40),
	@EntityValue VARCHAR(200),
	@AlertType VARCHAR(40),
	@AlertTypeValue VARCHAR(100) = NULL,
	@EffectiveDate DATE,
	@IsAlertPerEmployee BIT,
	@AlertOperator VARCHAR(2),
	@PredictiveValue FLOAT,
	@Debug tinyint = 0
)
AS 
BEGIN
    SET NOCOUNT ON
	SET DATEFIRST 1

	DECLARE @YearMonthNum INT,
			@WeekNum INT,
			@strSQL NVARCHAR(MAX),
			@strSQL_UserCount NVARCHAR(MAX),
			@PredictiveValueInMinutes FLOAT,
			@UserCount INT,
			@ParmDef NVARCHAR(50),
			@ManagerDimUserID INT

	SET @PredictiveValueInMinutes = @PredictiveValue * 60

	SELECT @WeekNum=WeekNum, @YearMonthNum=YearMonthNum FROM edw.Dim_Date
    WHERE Date=DATEADD(WK,-1, @EffectiveDate)


	SELECT @ManagerDimUserID=ManagerDimUserID FROM edw.Dim_Department
	WHERE CompanyID=@CompanyID AND DepartmentName=@EntityValue

	
	--******************* GET USER COUNT ******************

	if (@AlertType <> 'Application')
	begin

		SET @strSQL_UserCount=

		'SELECT @retvalOUT=COUNT(1) FROM
			(SELECT u.ID 
								FROM edw.Fact_DailyActivity da 
								JOIN edw.Dim_User u ON da.Dim_UserID = u.ID
								JOIN edw.Dim_Department d ON u.Dim_DepartmentID = d.ID
								JOIN edw.Dim_ActivityCategory ac ON da.Dim_ActivityCategoryID = ac.ID
								JOIN edw.Dim_AppMaster am ON da.Dim_AppMasterID = am.ID 
								JOIN edw.Dim_Date dt ON da.ActivityDate = dt.Date
								WHERE  da.Dim_CompanyID=' + CAST(@CompanyID AS varchar(5)) + ' AND u.IsActivityCollectionOn = 1 AND u.IsActive = 1 AND YearMonthNum='
								  + CAST(@YearMonthNum AS varchar(20)) + ' AND WeekNum=' + CAST(@WeekNum AS varchar(20)) 
								  + ' and am.AppName=''' + @AlertTypeValue + ''''
								  + ' AND d.DepartmentName=''' + @EntityValue + ''''
								  + CASE
									WHEN @ManagerDimUserID IS NOT NULL THEN ' AND u.ID <> ' + CAST(@ManagerDimUserID AS varchar(10))
								   END
								+ CHAR(10) +
								+ ' GROUP BY u.ID 
				UNION
				SELECT u.ID 
								FROM edw.Fact_DailyActivity da 
								JOIN edw.Dim_User u ON da.Dim_UserID = u.ID
								JOIN edw.Dim_Department d ON u.Dim_DepartmentID = d.ID
								JOIN edw.Dim_ActivityCategory ac ON da.Dim_ActivityCategoryID = ac.ID
								JOIN edw.Dim_WebApp am ON da.Dim_WebAppID = am.ID 
								JOIN edw.Dim_Date dt ON da.ActivityDate = dt.Date
								WHERE  da.Dim_CompanyID=' + CAST(@CompanyID AS varchar(5)) + ' AND u.IsActivityCollectionOn = 1 AND u.IsActive = 1 AND 
								YearMonthNum='+ CAST(@YearMonthNum AS varchar(20)) + ' AND WeekNum=' + CAST(@WeekNum AS varchar(20)) 
								  + ' and am.WebAppName=''' + @AlertTypeValue + ''''
								  + ' AND d.DepartmentName=''' + @EntityValue + ''''
								  + CASE
									WHEN @ManagerDimUserID IS NOT NULL THEN ' AND u.ID <> ' + CAST(@ManagerDimUserID AS varchar(10))
								   END
								+ CHAR(10) +
								+ ' 
								GROUP BY u.ID) base'

			

		if (@Debug = 1)
		begin

			print 'strSQL for UserCount => ' +  IsNull(@strSQL_UserCount, ' Empty' ) + CHAR(10)
	
		end

		--**** assign @UserCount ****
		SET @ParmDef = '@retvalOUT INT OUTPUT'
		EXEC sp_EXECUTESQL @strSQL_UserCount, @ParmDef, @retvalOUT= @UserCount OUTPUT


		if (@UserCount IS NULL OR @UserCount = 0)
			set @UserCount = 1

			--**************** MAIN OUTPUT ***************
		/**
		Note: TimeSpentInCalendarDay is divided by 5 since 5 working days in week. Also when @IsAlertPerEmployee=0 (by Dept), we want to multiply the # of users in Dept by 5.
		**/

		SET @strSQL=

		'SELECT ' 
		+ CASE @IsAlertPerEmployee 
			WHEN 1 THEN 'n.UserID PartyID, n.FirstName + '' '' + IsNull(n.LastName, '''' ) PartyName, '
			ELSE 'n.DepartmentID PartyID, n.DepartmentName PartyName, '
		  END
		+ CASE @IsAlertPerEmployee
			WHEN 1 THEN
				'CAST((SUM(TimeSpentInCalendarDay) / 5) / 60 AS decimal(18,2)) TimeSpent,
				CAST((SUM(TimeSpentInCalendarDay) / 5) / 60 AS decimal(18,2)) - ' + CAST(@PredictiveValue AS varchar(10)) + ' ThresholdDiff '
			ELSE
				'CAST((SUM(TimeSpentInCalendarDay) / (5*' + CAST(@UserCount AS varchar(10)) + ')) / 60 AS DECIMAL(18,2)) TimeSpent,
				CAST((SUM(TimeSpentInCalendarDay) / (5*' + CAST(@UserCount AS varchar(10)) + ')) / 60 AS DECIMAL(18,2)) - ' + CAST(@PredictiveValue AS varchar(10)) + ' ThresholdDiff '
		  END
		+
		'FROM
		(Select da.Dim_CompanyID, u.ID,u.UserID, u.FirstName, u.LastName, d.DepartmentID, d.DepartmentName, da.TimeSpentInCalendarDay, ac.ActivityCategoryName, am.AppName as AppName
		, ac.ActivityCategoryID, da.PurposeID,u.IsActive
		FROM edw.Fact_DailyActivity da 
		JOIN edw.Dim_User u ON da.Dim_UserID = u.ID  
		JOIN edw.Dim_Department d ON u.Dim_DepartmentID = d.ID
		JOIN edw.Dim_ActivityCategory ac ON da.Dim_ActivityCategoryID = ac.ID
		JOIN edw.Dim_AppMaster am ON da.Dim_AppMasterID = am.ID
		JOIN edw.Dim_Date dt ON da.ActivityDate = dt.Date
		WHERE da.Dim_CompanyID=1 AND u.IsActivityCollectionOn = 1 AND u.IsActive = 1 AND YearMonthNum='+ CAST(@YearMonthNum AS varchar(20)) + ' 
		AND WeekNum=' + CAST(@WeekNum AS varchar(20))+' and d.DepartmentName=''' + @EntityValue + '''
        UNION ALL
		Select da.Dim_CompanyID,u.ID,u.UserID, u.FirstName, u.LastName, d.DepartmentID, d.DepartmentName, da.TimeSpentInCalendarDay, ac.ActivityCategoryName, am.WebAppName as AppName
		, ac.ActivityCategoryID, da.PurposeID,u.IsActive
		FROM edw.Fact_DailyActivity da 
		JOIN edw.Dim_User u ON da.Dim_UserID = u.ID  
		JOIN edw.Dim_Department d ON u.Dim_DepartmentID = d.ID
		JOIN edw.Dim_ActivityCategory ac ON da.Dim_ActivityCategoryID = ac.ID
		JOIN edw.Dim_WebApp am ON da.Dim_WebAppID = am.ID
		JOIN edw.Dim_Date dt ON da.ActivityDate = dt.Date
		WHERE da.Dim_CompanyID=1 AND u.IsActivityCollectionOn = 1 AND u.IsActive = 1 AND YearMonthNum='+ CAST(@YearMonthNum AS varchar(20)) + ' 
		AND WeekNum=' + CAST(@WeekNum AS varchar(20))+' and d.DepartmentName=''' + @EntityValue + ''') n
		WHERE n.Dim_CompanyID = ' + CAST(@CompanyID AS varchar(5))  + 
		+ CASE @AlertType 
			WHEN 'ActivityCategory' THEN ' AND n.ActivityCategoryName=''' + @AlertTypeValue + ''''
			WHEN 'TotalHours' THEN ' AND n.ActivityCategoryID=0 AND n.PurposeID = - 1 '
			WHEN 'UnaccountedTime' THEN ' AND n.ActivityCategoryID=0 AND n.PurposeID=-1'
		  END
		+ ' AND n.DepartmentName=''' + @EntityValue + ''''
		+ CASE
			WHEN @ManagerDimUserID IS NOT NULL THEN ' AND n.ID <> ' + CAST(@ManagerDimUserID AS varchar(10))
		  END
		+ CHAR(10)
		+ CASE @IsAlertPerEmployee 
			WHEN 1 THEN 'GROUP BY n.UserID, n.FirstName + '' '' + IsNull(n.LastName, '''' )'
			ELSE ' GROUP BY n.DepartmentID, n.DepartmentName '
		  END
		+ CHAR(10)	
		+ CASE @IsAlertPerEmployee
			WHEN 1 THEN 'HAVING SUM(TimeSpentInCalendarDay) / 5 '  + @AlertOperator + CAST(@PredictiveValueInMinutes AS varchar(20))
			ELSE 'HAVING SUM(TimeSpentInCalendarDay) / (5*' + CAST(@UserCount AS varchar(10)) + ') ' + @AlertOperator + CAST(@PredictiveValueInMinutes AS varchar(20))
		  END

		  ---------------- UNION of no data users for <  -----------------
		+ CHAR(10)
		
		+ CASE charindex('<',@AlertOperator) WHEN 0 THEN ''
		  ELSE CASE WHEN @IsAlertPerEmployee = 0 THEN '' ELSE ''
	--	UNION ALL 
	--		  
	--			  '
	--		+
	--			'	SELECT distinct  '
	--		+ 
	--			CASE @IsAlertPerEmployee 
	--				WHEN 1 THEN 'u.UserID PartyID, u.FirstName + '' '' + IsNull(u.LastName, '''' ) PartyName, '
	--				ELSE 'd.DepartmentID PartyID, d.DepartmentName PartyName, '
	--			END
	--		+	CASE @IsAlertPerEmployee
	--				WHEN 1 THEN
	--					'0 TimeSpent,
	--					 0 - ' + CAST(@PredictiveValue AS varchar(10)) + ' ThresholdDiff '
	--				ELSE
	--					'0 TimeSpent,
	--					 0 - ' + CAST(@PredictiveValue AS varchar(10)) + ' ThresholdDiff '
	--			END
	--		+
	--		'
	--		FROM edw.Dim_User u 
	--		JOIN edw.Dim_Department d ON u.Dim_DepartmentID = d.ID
	--
	--		WHERE u.CompanyID=' + CAST(@CompanyID AS varchar(5)) + '  AND u.IsActivityCollectionOn = 1 AND u.IsActive = 1
	--	
	--			AND d.DepartmentName=''' + @EntityValue + ''''
	--		+ CASE
	--			WHEN @ManagerDimUserID IS NOT NULL THEN ' AND u.ID <> ' + CAST(@ManagerDimUserID AS varchar(10))
	--		  END
	--			+ CHAR(10) +
	--			' AND NOT EXISTS (
	--				SELECT 1 FROM edw.Fact_DailyActivity da 
	--					INNER JOIN edw.Dim_ActivityCategory ac ON da.Dim_ActivityCategoryID = ac.ID
	--					INNER JOIN edw.Dim_Date dt ON da.ActivityDate = dt.Date
	--					WHERE
	--						da.Dim_UserID = u.ID AND YearMonthNum='+ CAST(@YearMonthNum AS varchar(20)) + ' AND WeekNum=' + CAST(@WeekNum AS varchar(20)) 
	--						+ CASE @AlertType 
	--							WHEN 'Activity Category' THEN ' AND ac.ActivityCategoryName=''' + @AlertTypeValue + ''''
	--							WHEN 'TotalHours' THEN ''
	--							WHEN 'UnaccountedTime' THEN ' AND ac.ActivityCategoryID=0 AND da.PurposeID=-1'
	--						  END  + ' ) '
	--
		END
		END

		if (@Debug = 1)
		begin

			print 'strSQL for Results => ' +  IsNull(@strSQL, ' Empty' )
	
		end

	END
		
	EXEC (@strSQL)

END


GO
/****** Object:  StoredProcedure [edw].[sproc_ActivityCategoryMappingForPredData]    Script Date: 9/10/2021 8:10:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [edw].[sproc_ActivityCategoryMappingForPredData]
(
	@Debug tinyint = 0
)

WITH RECOMPILE

AS
BEGIN



		SET NOCOUNT ON
		declare  @TimeOutDurationInMinutes int = 5
		,@ProcStartTime datetime = GetUTCDate()
		,@MaxUploadTime datetime = GetUTCDate()
		,@ProcName varchar(100) = 'sproc_ActivityCategoryMappingForPredData'
		,@Step varchar(1024) = ''
		,@TimeSlotRecordCount int = 0
		,@BatchCount int = 10000



		select @MaxUploadTime = MAX(ActivityDate) From [edw].[Fact_DailyActivityPred]


		Drop table if exists #ActiveFact_AppPredData

		create table #ActiveFact_AppPredData
		(
		[Dim_CompanyID] [int] NULL,
		[Dim_UserID] [int] NOT NULL,
		[Dim_AppParentID] [int] NOT NULL,
		[ActivityDate] [date] NOT NULL,
		[Day] [varchar](20) NOT NULL,
		[Pred_Time] [float] NOT NULL,
		[Dim_ActivityCategoryID] [int] NULL,
		[IsProcessed] [bit] NOT NULL,
		[PurposeID] [int] default(-1),
		[IsOnPc] [int] default(1),
		[IsCore] [int] default(0)
		)

		insert into  #ActiveFact_AppPredData(Dim_CompanyID, Dim_UserID, Dim_AppParentID, ActivityDate, Day, Pred_Time, Dim_ActivityCategoryID,IsProcessed)
		Select null,Dim_UserID, Dim_AppParentID, ActivityDate, Day, Pred_Time, null, 0
		From [edw].[Fact_AppPred] WHere IsProcessed = 0 AND ActivityDate > @MaxUploadTime



		update d
		set	
			d.Dim_CompanyID = s.CompanyID,
			d.Dim_ActivityCategoryID = s.Dim_ActivityCategoryID,
			d.IsProcessed = 1,
			d.PurposeID = 1
		from #ActiveFact_AppPredData d
		inner join [edw].[Brdg_UserAppOverride] s
		on
			d.Dim_AppParentID = s.Dim_AppParentID and s.IsActive = 1 and d.IsProcessed = 0


		update d
		set	
			d.Dim_CompanyID = s.CompanyID,
			d.Dim_ActivityCategoryID = s.Dim_ActivityCategoryID,
			d.IsProcessed = 1,
			d.PurposeID = 1
		from #ActiveFact_AppPredData d
		inner join [edw].[Brdg_UserWebAppOverride] s
		on
			d.Dim_AppParentID = s.Dim_WebAppID and s.IsActive = 1 and d.IsProcessed = 0


			update d
		set	
			d.Dim_CompanyID = s.CompanyID,
			d.Dim_ActivityCategoryID = s.Dim_ActivityCategoryID,
			d.IsProcessed = 1,
			d.PurposeID = 1
		from #ActiveFact_AppPredData d
		inner join [edw].[Brdg_JobFamilyAppOverride] s
		on
			d.Dim_AppParentID = s.Dim_AppParentID and s.IsActive = 1 and d.IsProcessed = 0


		update d
		set	
			d.Dim_CompanyID = s.CompanyID,
			d.Dim_ActivityCategoryID = s.Dim_ActivityCategoryID,
			d.IsProcessed = 1,
			d.PurposeID = 1
		from #ActiveFact_AppPredData d
		inner join [edw].[Brdg_JobFamilyWebAppOverride] s
		on
			d.Dim_AppParentID = s.Dim_WebAppID and s.IsActive = 1 and d.IsProcessed = 0


		DROP TABLE if EXists #AppMasterBase

		Select k.* INTO #AppMasterBase From
		(Select a.CompanyID, a.Dim_AppParentID, b.Dim_ActivityCategoryID, IsOffline
		From [edw].[Dim_AppMaster] a
		Inner join [edw].[Dim_AppParent] b
		On(a.CompanyID = b.CompanyID and a.ExeName = b.ExeName and a.AppName = b.AppName) )k
		Where k.Dim_ActivityCategoryID is not null


		update d
		set	
			d.Dim_CompanyID = s.CompanyID,
			d.Dim_ActivityCategoryID = s.Dim_ActivityCategoryID,
			d.IsProcessed = 1,
			d.PurposeID = 1
		from #ActiveFact_AppPredData d
		inner join #AppMasterBase s
		on
			d.Dim_AppParentID = s.Dim_AppParentID and d.IsProcessed = 0


		Drop table if exists #WebAppBase

		Select a.CompanyID, a.Dim_ActivityCategoryID, b.Dim_AppParentID, b.IsOffline, a.IsActive INTO #WebAppBase
		from [edw].[Dim_WebApp] a
		inner join [edw].[Dim_AppMaster] b
		On (a.CompanyID = b.CompanyID and a.WebAppDisplayName = b.AppName)


		update d
		set	
			d.Dim_CompanyID = s.CompanyID,
			d.Dim_ActivityCategoryID = s.Dim_ActivityCategoryID,
			d.IsProcessed = 1,
			d.PurposeID = 1
		from #ActiveFact_AppPredData d
		inner join #WebAppBase s
		on
			d.Dim_AppParentID = s.Dim_AppParentID and s.IsActive = 1 and d.IsProcessed = 0

		

		update d
		set	
			d.Dim_CompanyID = s.CompanyID
		from #ActiveFact_AppPredData d
		inner join edw.Dim_User s
		on
			d.Dim_UserID = s.ID and s.IsActive = 1 and d.IsProcessed = 0

		
		update d
		set	
			d.Dim_ActivityCategoryID = s.ID,
			d.IsProcessed = 1
		from #ActiveFact_AppPredData d
		inner join [edw].[Dim_ActivityCategory] s
		on
			d.Dim_CompanyID = s.CompanyID and ActivityCategoryName ='Private' and s.IsActive = 1 and d.IsProcessed = 0
		
	

				update d
		set	
			d.Dim_ActivityCategoryID = s.ID,
			d.IsProcessed = 1
		from #ActiveFact_AppPredData d
		inner join (Select * from [edw].[Dim_ActivityCategory] Where ActivityCategoryID = 5)s
		on
			d.Dim_CompanyID = s.CompanyID and d.Dim_ActivityCategoryID is null and s.IsActive = 1


			

		update d
		set	
			d.IsOnPc = s.IsCore
			,d.IsCore = s.IsCore
		from #ActiveFact_AppPredData d
		inner join [edw].[Dim_ActivityCategory] s
		on
			d.Dim_CompanyID = s.CompanyID and d.Dim_ActivityCategoryID = s.ID and s.IsActive = 1 



		   	INSERT INTO [edw].[Fact_DailyActivityPred]
           ([Dim_CompanyID], [Dim_UserID], [ActivityDate], [Dim_DeviceID], [Dim_AppParentID], [Dim_WebAppID]
			,[Dim_ActivityCategoryID], [PurposeID], [IsOnPc], [TimeSpentInCalendarDay], [TimeSpentInShift],IsCore)
		   Select [Dim_CompanyID], [Dim_UserID], [ActivityDate], 0, [Dim_AppParentID],null
		   ,[Dim_ActivityCategoryID], [PurposeID], [IsOnPc], Pred_Time, 0,IsCore From #ActiveFact_AppPredData
		   Where [Dim_CompanyID] is not null



END


GO
/****** Object:  StoredProcedure [edw].[sproc_AddEmailData]    Script Date: 9/10/2021 8:10:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [edw].[sproc_AddEmailData]
AS
BEGIN

		
		declare 
			@ExceptionMessage NVARCHAR(4000) = '',
			@ExceptionSeverity INT = 0,
			@ExceptionState INT = 0,
			@ErrorValidation NVARCHAR(MAX) = '',
			@Step NVARCHAR(4000) = '',
			@CurrentDate date,
			@StartDate date,
			@EndDate date

BEGIN TRAN TenantCreation
BEGIN TRY

		
		Select @StartDate = DATEADD(DD,1,max(ActivityDate)) from [edw].[Fact_DailyUserEmail]


if @StartDate <= GETDATE()
	BEGIN

				SET @CurrentDate = GETDATE()
				
				 Select @EndDate = GETDATE()

---GETDA		TE()

				Select Distinct CompanyID, ID into #TempUsertbl from edw.Dim_User

				Alter Table #TempUsertbl
				ADD ActivityDate Date
				,RowID int


				WHILE (@CurrentDate <= @EndDate)
				BEGIN

 
				Update #TempUsertbl
				SET ActivityDate = @CurrentDate
				
				Update #TempUsertbl
				SET ROWID = ID + DATEPART(WEEKDAY , ActivityDate) + DATEPART(WEEK , ActivityDate)


				
				INSERT INTO [edw].[Fact_DailyUserEmail]
				([Dim_UserId],[Dim_CompanyID],[ActivityDate],[NumberOfSentEmails],[NumberOfReceivedEmails],[NumberOfUnreadEmails]
				,[AvgResponseTime],[NumberOfAllRecipients],[NumberOfTeamRecipients],[NumberOfDepartmentRecipients],[NumberOfCompanyRecipients])
				Select a.ID, a.CompanyID, Activitydate, b.NumberOfSentEmails, b.NumberOfReceivedEmails, b.NumberOfUnreadEmails, b.AvgResponseTime,
				 b.NumberOfAllRecipients, b.NumberOfTeamRecipients, b.NumberOfDepartmentRecipients, b.NumberOfRecipientsInCompany
				 FROM #TempUsertbl a
				 INNER JOIN [dbo].[RawEmailAnalyticsData] b
				 on(a.RowID = b.ID)

				 set @Step = @CurrentDate

				 print 'Step => Data inserted successfully' + @Step


				SET @CurrentDate = convert(varchar(30), dateadd(day,1, @CurrentDate), 101); /*increment current date*/
				END

				DROP TABLE IF EXISTS #TempUsertbl
	
END

ELSE 

 BEGIN
        PRINT 'Data present for :@CurrentDate';
    END	
	
	
	COMMIT TRAN TenantCreation
	
	END TRY
	
	BEGIN CATCH
	ROLLBACK TRAN TenantCreation

			SELECT 
			@ExceptionMessage = ERROR_MESSAGE(),
			@ExceptionSeverity = ERROR_SEVERITY(),
			@ExceptionState = ERROR_STATE();

			
		PRINT 'Error => ' + @ExceptionMessage

			RAISERROR (
					@ExceptionMessage,
					@ExceptionSeverity,
					@ExceptionState    
				);


	END CATCH


END		


GO
/****** Object:  StoredProcedure [edw].[sproc_AzureContainerBulkInsert]    Script Date: 9/10/2021 8:10:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [edw].[sproc_AzureContainerBulkInsert]
(
    @path VARCHAR(50)
	,@datasource VARCHAR(20)
)
AS
BEGIN
	DECLARE @SQLString VARCHAR(500)

	TRUNCATE TABLE edw.Stg_Lenses

	SET @SQLString = 
		'BULK INSERT edw.stg_lenses
		FROM ''' + @path + '''
		WITH (DATA_SOURCE = ''' + @datasource + ''', 
			FORMAT = ''CSV'',
			FIRSTROW = 2,
			FIELDTERMINATOR = '','', 
			ROWTERMINATOR = ''0x0a'',  
			TABLOCK
			)'

	EXEC (@SQLString)
END

GO
/****** Object:  StoredProcedure [edw].[sproc_Create_DefaultDimValues]    Script Date: 9/10/2021 8:10:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE    PROCEDURE [edw].[sproc_Create_DefaultDimValues]
AS 
BEGIN
    SET NOCOUNT ON

	-- VENDOR: record of VendorID 0 with VendorName of Employee
	DECLARE @counter INT = 1, @CompanyID INT

	SELECT ROW_NUMBER() OVER(ORDER BY CompanyID) ID, CompanyID INTO #company FROM edw.Dim_Company

	WHILE @counter <= (SELECT MAX(ID) FROM (SELECT ROW_NUMBER() OVER(ORDER BY CompanyID) ID, CompanyID FROM edw.Dim_Company) base)
	BEGIN
		SELECT @CompanyID=CompanyID FROM #company WHERE ID = @counter

		---- Default Vendor Record
		IF NOT EXISTS (SELECT ID FROM edw.Dim_Vendor WHERE CompanyID=@CompanyID AND VendorID=0)
		BEGIN
			INSERT INTO edw.Dim_Vendor (CompanyID, VendorID, VendorName, VendorContact, IsActive)
			VALUES (@CompanyID, 0, 'FTE', 'FTE', 1)
		END
		
		---- Default Network Record
		IF NOT EXISTS (SELECT ID FROM edw.Dim_Network WHERE CompanyID=@CompanyID AND NetworkName='undefined')
		BEGIN
			INSERT INTO edw.Dim_Network (CompanyID, NetworkName, CreatedDate)
			VALUES (@CompanyID, 'undefined', GETUTCDATE())
		END

		---- Default Machine Record
		IF NOT EXISTS (SELECT ID FROM edw.Dim_Machine WHERE CompanyID=@CompanyID AND MachineName='undefined')
		BEGIN
			INSERT INTO edw.Dim_Machine (CompanyID, MachineName, CreatedDate)
			VALUES (@CompanyID, 'undefined', GETUTCDATE())
		END

		---- Default AppMaster Records
		IF NOT EXISTS (SELECT ID FROM [edw].[Dim_AppMaster] WHERE CompanyID=@CompanyID AND AppID = 0)
		BEGIN
			INSERT INTO [edw].[Dim_AppMaster] ([CompanyID], [AppID], [ExeName], [AppName], [IsApplication], [IsOffline])
			VALUES (@CompanyID, 0, '', 'Off-PC', 0, 1)
		END

		IF NOT EXISTS (SELECT ID FROM [edw].[Dim_AppMaster] WHERE CompanyID=@CompanyID AND AppID = -1)
		BEGIN
			INSERT INTO [edw].[Dim_AppMaster] ([CompanyID], [AppID], [ExeName], [AppName], [IsApplication], [IsOffline])
			VALUES (@CompanyID, -1, '', 'Unknown', 0, 1)
		END

		IF NOT EXISTS (SELECT ID FROM [edw].[Dim_AppMaster] WHERE CompanyID=@CompanyID AND AppID = -2)
		BEGIN
			INSERT INTO [edw].[Dim_AppMaster] ([CompanyID], [AppID], [ExeName], [AppName], [IsApplication], [IsOffline])
			VALUES (@CompanyID, -2, '', 'Outlook Meetings', 0, 1)
		END

		IF NOT EXISTS (SELECT ID FROM [edw].[Dim_AppMaster] WHERE CompanyID=@CompanyID AND AppID = -3)
		BEGIN
			INSERT INTO [edw].[Dim_AppMaster] ([CompanyID], [AppID], [ExeName], [AppName], [IsApplication], [IsOffline])
			VALUES (@CompanyID, -3, '', 'Not Applicable', 0, 1)
		END

		IF NOT EXISTS (SELECT ID FROM [edw].[Dim_AppMaster] WHERE CompanyID=@CompanyID AND AppID = -4)
		BEGIN
			INSERT INTO [edw].[Dim_AppMaster] ([CompanyID], [AppID], [ExeName], [AppName], [AppVersion], [IsApplication], [IsOffline])
			VALUES (@CompanyID, -4, '', 'WebApp', 'NA', 0, 1)
		END

		IF NOT EXISTS (SELECT ID FROM [edw].[Dim_AppMaster] WHERE CompanyID=@CompanyID AND AppID = -5)
		BEGIN
			INSERT INTO [edw].[Dim_AppMaster] ([CompanyID], [AppID], [ExeName], [AppName], [IsApplication], [IsOffline])
			VALUES (@CompanyID, -5, '', 'Private', 0, 1)
		END

		---- Default Activity Category Records
		IF NOT EXISTS (SELECT ID FROM [edw].[Dim_ActivityCategory] WHERE CompanyID=@CompanyID AND ActivityCategoryID = -1)
		BEGIN
			INSERT INTO [edw].[Dim_ActivityCategory] ([CompanyID], [ActivityCategoryID], [ActivityCategoryName], [IsCore], [IsSystemDefined], [IsActive], [IsWorkCategory], [IsDefault])
			VALUES (@CompanyID, -1, 'Private', 0, 1, 1, 0, 0)
		END

		IF NOT EXISTS (SELECT ID FROM [edw].[Dim_ActivityCategory] WHERE CompanyID=@CompanyID AND ActivityCategoryID = 0)
		BEGIN
			INSERT INTO [edw].[Dim_ActivityCategory] ([CompanyID], [ActivityCategoryID], [ActivityCategoryName], [IsCore], [IsSystemDefined], [IsActive], [IsWorkCategory], [IsDefault])
			VALUES (@CompanyID, 0, 'Unaccounted', 0, 1, 1, 1, 0)
		END

		IF NOT EXISTS (SELECT ID FROM [edw].[Dim_ActivityCategory] WHERE CompanyID=@CompanyID AND ActivityCategoryID = 5)
		BEGIN
			INSERT INTO [edw].[Dim_ActivityCategory] ([CompanyID], [ActivityCategoryID], [ActivityCategoryName], [IsCore], [IsSystemDefined], [IsActive], [IsWorkCategory], [IsDefault])
			VALUES (@CompanyID, 5, 'Meetings', 0, 1, 1, 1, 0)
		END

		IF NOT EXISTS (SELECT ID FROM [edw].[Dim_ActivityCategory] WHERE CompanyID=@CompanyID AND ActivityCategoryID = 100)
		BEGIN
			INSERT INTO [edw].[Dim_ActivityCategory] ([CompanyID], [ActivityCategoryID], [ActivityCategoryName], [IsCore], [IsSystemDefined], [IsActive], [IsWorkCategory], [IsDefault])
			VALUES (@CompanyID, 100, 'Miscellaneous', 0, 1, 1, 1, 0)
		END
		
		---- Default AppParent Record
		IF NOT EXISTS (SELECT ID FROM [edw].[Dim_AppParent] WHERE CompanyID=@CompanyID AND [AppName] like 'Not Applicable')
		BEGIN		
		INSERT INTO [edw].[Dim_AppParent] ([CompanyID], [ExeName], [AppName], [Dim_ActivityCategoryID], [AppSpecID], [LowPriority])
		VALUES (@CompanyID, 'Not Applicable', 'Not Applicable', null, -3, null)
		END
		IF NOT EXISTS (SELECT ID FROM [edw].[Dim_AppParent] WHERE CompanyID=@CompanyID AND [AppName] like 'WebApp')
		BEGIN		
		INSERT INTO [edw].[Dim_AppParent] ([CompanyID], [ExeName], [AppName], [Dim_ActivityCategoryID], [AppSpecID], [LowPriority])
		VALUES (@CompanyID, 'WebApp', 'WebApp', null, -4, null)
		END

		---- Default WebApp Record
		IF NOT EXISTS (SELECT ID FROM [edw].[Dim_WebApp] WHERE CompanyID=@CompanyID AND [WebAppID] = -3)
		BEGIN	
		INSERT INTO [edw].[Dim_WebApp]
		([CompanyID], [WebAppID], [Dim_ActivityCategoryID], [WebAppName], [WebAppDisplayName], [WebAppUrl], [WebAppVersion],
		[WebAppDescription], [IsSystemDiscovered], IsActive)
		VALUES
		(@CompanyID, -3, null, 'Not Applicable', 'Not Applicable', 'Not Applicable', null, null, 1, 1)
		END

		IF NOT EXISTS (SELECT ID FROM [edw].[Dim_WebApp] WHERE CompanyID=@CompanyID AND [WebAppID] = -4)
		BEGIN	
		INSERT INTO [edw].[Dim_WebApp]
		([CompanyID], [WebAppID], [Dim_ActivityCategoryID], [WebAppName], [WebAppDisplayName], [WebAppUrl], [WebAppVersion],
		[WebAppDescription], [IsSystemDiscovered], IsActive)
		VALUES
		(@CompanyID, -4, null, 'WebApp', 'WebApp', 'WebApp', 'NA', null, 1, 1)
		END

		IF NOT EXISTS (SELECT ID FROM [edw].[Dim_WebApp] WHERE CompanyID=@CompanyID AND [WebAppID] = -5)
		BEGIN	
		INSERT INTO [edw].[Dim_WebApp]
		([CompanyID], [WebAppID], [Dim_ActivityCategoryID], [WebAppName], [WebAppDisplayName], [WebAppUrl], [WebAppVersion],
		[WebAppDescription], [IsSystemDiscovered], IsActive)
		VALUES
		(@CompanyID, -5, null, 'Private', 'Private', 'Private', null, null, 1, 1)
		END

		SET @counter=@counter+1
	END


	DROP TABLE #company

END

GO
/****** Object:  StoredProcedure [edw].[sproc_CreateDailyUserActivity]    Script Date: 9/10/2021 8:10:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [edw].[sproc_CreateDailyUserActivity]
(
    @CompanyID int
	,@Debug tinyint = 0
)
AS
BEGIN

    SET XACT_ABORT, NOCOUNT ON
	SET DATEFIRST 1

	BEGIN TRY
	--######################### BEGIN TRANSACTION #####################
	BEGIN TRANSACTION trans_DailyUserActivity

		DECLARE @ProcStartTime datetime = GetUTCDate()
				,@ProcName varchar(100) = 'sproc_TransformTimeSlotsToDailyActivities'
				,@Step varchar(1024) = ''
				,@MinUnaccountedTimeThreshold int = 5 -- 5 minutes
				,@MaxUnaccountedTimeThreshold int = 180 -- 180 minutes
				,@MaxMeetingOverlapThreshold int = 30 -- 30 minutes
				,@WeekEND1 int = 1, @WeekEND2 int = 7
				,@PrivateWork int = -1
				,@UnaccountedCategory int
				,@LastTimeSlotProcessedTime datetime = '2000-01-01'
				,@CurrentTimeSlotProcessedTime datetime = GetUTCDate()
				,@UnknownAppID int
				,@MinBreakTimeThreshold int = 20 -- 5 minutes
				,@MaxBreakTimeThreshold int = 240 -- 180 minutes


		SELECT @LastTimeSlotProcessedTime = LastTimeSlotProcessedTime
		FROM EDW.Log_TimeSlotProcessStatus t 
		WHERE t.CompanyID = @CompanyID and t.TimeSlotType = 0


		CREATE TABLE #TransientTimeSlot
		(
			[Dim_CompanyId] [int] NOT NULL, -- Internal Company ID 
			[Dim_UserID] [int] NOT NULL, -- Internal User ID
			[ActivityDate] [Date]  NOT NULL, -- Date of the Activity
			[DeviceID] [int] NOT NULL, -- Internal Device ID
			[Dim_AppMasterID] [int] NOT NULL, -- Internal App Id
			[FileOrUrlID] [int] NOT NULL, -- Internal File or Url Id
			[IsFileOrUrl] [bit] NOT NULL, -- Is File or URL. File: 0, Url: 1
			[PurposeID] [int] NOT NULL, -- Private or Work Purpose. 
			[Dim_ActivityCategoryID] [int] NOT NULL,
			[IsOnPc] [bit] NOT NULL, -- Is this a On Pc slot while working on an App or Off Pc such as Meeting or Idle
			[TimeSpent] [real] NOT NULL -- Timespent by User in a calENDar day
		)

		CREATE TABLE #TransientUsers
		(
			[Dim_CompanyId] [int] NOT NULL, -- Internal Company ID 
			[Dim_UserID] [int] NOT NULL, -- Internal User ID
			[ActivityDate] [Date]  NOT NULL -- Date of the Activity
		)

		CREATE TABLE #TransientTotalTime
		(
			[Dim_CompanyId] [int] NOT NULL, -- Internal Company ID 
			[Dim_UserID] [int] NOT NULL, -- Internal User ID
			[ActivityDate] [Date]  NOT NULL, -- Date of the Activity
			[TimeSpent] [real] NOT NULL -- Total Time Spent
		)

		CREATE TABLE #TransientChronoUnaccountedTimeSlots
		(
			[ActivityDate] date NOT NULL,
			[Dim_UserID] integer NOT NULL,
			--[ID] bigint NOT NULL, -- Internal Company ID 
			[StartTimeSlotInUTC] [datetime] NOT NULL, -- LaSET Time Slot
			[ENDTimeSlotInUTC] [datetime] NULL, -- Next Time Slot
			[TimeZoneOffSET] int NULL,
			[MeetingName] nvarchar(4000) NULL,
			[IsAccounted] bit NOT NULL DEFAULT (0)
		)

		CREATE TABLE #MeetingTimeSlots
		(
			[Dim_CompanyID] int,
			[ActivityDate] date,
			--[ID] bigint,
			[Dim_UserID] int,
			[MeetingSubject] nvarchar(512),
			[MeetingStartTimeUTC] datetime,
			[MeetingEndTimeUTC] datetime,
			[StartTimeInUTCforTimeSlot] datetime,
			[EndTimeInUTCforTimeSlot] datetime,
			[MeetingTimeZoneOffSet] real,
			[MeetingDuration] int
		)


		-- ******* #TransientUsers ******
		INSERT INTO #TransientUsers(Dim_CompanyId, Dim_UserID, ActivityDate)

		SELECT DISTINCT t.Dim_CompanyID, t.Dim_UserID, t.ActivityDate 
		FROM EDW.Fact_TimeSlot t
		WHERE t.Dim_CompanyID = @CompanyID AND t.IsActive = 1
			AND t.UploadTime > @LastTimeSlotProcessedTime AND t.UploadTime <= @CurrentTimeSlotProcessedTime



		INSERT INTO  #TransientChronoUnaccountedTimeSlots(ActivityDate, Dim_UserID, StartTimeSlotInUTC, ENDTimeSlotInUTC)	

		SELECT t.ActivityDate, t.Dim_UserID, t.ENDTimeInUTC, LEAD (StartTimeInUTC, 1) OVER (PARTITION BY t.ActivityDate, t.Dim_UserID ORDER BY StartTimeInUTC) LeadStartTimeInUTC
		FROM EDW.Fact_TimeSlot t 
		INNER JOIN #TransientUsers s
			ON t.Dim_CompanyID = s.Dim_CompanyID AND t.ActivityDate = s.ActivityDate AND t.Dim_UserID = s.Dim_UserID
		WHERE t.ActivityDate IN (SELECT DISTINCT ActivityDate FROM #TransientUsers)
			AND t.Dim_CompanyID = @CompanyID  AND t.IsActive = 1 AND DATEPART(WEEKDAY, t.ActivityDate) NOT IN (@WeekEND1, @WeekEND2)-- exclude weekEND holidays


		/******************* START Merge Meetings (#MeetingTimeSlots and #TransientChronoUnaccountedTimeSlots) ***************************/
		DECLARE @LastCreatedTimeSlotID bigint = 0, @OutlookMeetingsAppID int, @MeetingActivityCategoryID int

		SELECT @OutlookMeetingsAppID = ID FROM edw.Dim_AppMaster WHERE CompanyID=@CompanyID AND AppID=-2
		SELECT @MeetingActivityCategoryID = ID FROM edw.Dim_ActivityCategory WHERE CompanyID=@CompanyID AND ActivityCategoryGroupID=1 AND ActivityCategoryID=5

		
		INSERT INTO #MeetingTimeSlots (Dim_CompanyID, ActivityDate, Dim_UserID, MeetingSubject, MeetingStartTimeUTC, MeetingEndTimeUTC, StartTimeInUTCforTimeSlot, EndTimeInUTCforTimeSlot, MeetingTimeZoneOffSet, MeetingDuration)

		SELECT s.Dim_CompanyID, s.ActivityDate, s.Dim_UserID, s.MeetingSubject, s.MeetingStartTimeUTC, s.MeetingEndTimeUTC, t.StartTimeSlotInUTC, t.ENDTimeSlotInUTC, s.MeetingTimeZoneOffSet, s.MeetingDuration
		FROM EDW.Fact_TimeSlotMeeting  s
		JOIN #TransientChronoUnaccountedTimeSlots t
			ON s.Dim_UserID = t.Dim_UserID AND s.ActivityDate = t.ActivityDate 
				AND (t.EndTimeSlotInUTC > s.MeetingStartTimeUTC AND t.StartTimeSlotInUTC < s.MeetingEndTimeUTC)
		WHERE
			s.Dim_CompanyID = @CompanyID
			AND s.ISACTIVE =1
			AND DATEDIFF(MINUTE,t.StartTimeSlotInUTC,t.EndTimeSlotInUTC) >= @MinUnaccountedTimeThreshold


		-- If the Unaccounted gap is larger than the Meeting Duration Overlap threshold, only consider the overlapped part
		UPDATE m
		SET
			StartTimeInUTCforTimeSlot = CASE WHEN MeetingStartTimeUTC > StartTimeInUTCforTimeSlot THEN MeetingStartTimeUTC ELSE StartTimeInUTCforTimeSlot END
			,EndTimeInUTCforTimeSlot = CASE WHEN MeetingEndTimeUTC < EndTimeInUTCforTimeSlot THEN MeetingEndTimeUTC ELSE EndTimeInUTCforTimeSlot END
		FROM #MeetingTimeSlots m
		WHERE DATEDIFF(MINUTE,m.StartTimeInUTCforTimeSlot,m.EndTimeInUTCforTimeSlot) > (m.MeetingDuration + @MaxMeetingOverlapThreshold)


		UPDATE  t
		SET
			t.MeetingName = m.MeetingSubject
			,t.TimeZoneOffSET = m.MeetingTimeZoneOffSet
			,t.StartTimeSlotInUTC = m.StartTimeInUTCforTimeSlot
			,t.EndTimeSlotInUTC = m.EndTimeInUTCforTimeSlot 
			,t.IsAccounted = 1
		FROM #TransientChronoUnaccountedTimeSlots t
		JOIN #MeetingTimeSlots m ON t.Dim_UserID = m.Dim_UserID --AND t.Id = m.Id
			AND t.StartTimeSlotInUTC = m.MeetingStartTimeUTC
			AND t.ENDTimeSlotInUTC = m.MeetingEndTimeUTC
			AND t.MeetingName = m.MeetingSubject


		/******** INSERT INTO [TimeSlot] meeting data *********/
		INSERT INTO EDW.Fact_TimeSlot
			([Dim_CompanyId], [ActivityDate], [Dim_UserID], [DeviceID], [Dim_AppMasterID], [FileOrUrlName] ,[IsFileOrUrl] ,[PurposeID], [Dim_ActivityCategoryID], [IsOnPc] ,[IsActive] ,[IsShift] ,[StartTimeInUTC] ,[ENDTimeInUTC] ,[TimeZoneOffSET] ,[TimeSpent])

		SELECT @CompanyID, t.ActivityDate, t.Dim_UserID, 0, @OutlookMeetingsAppID, t.MeetingName, 0, 1, @MeetingActivityCategoryID, 0, 1, 0, t.StartTimeSlotInUTC, t.ENDTimeSlotInUTC
				,t.TimeZoneOffSET, ROUND(DATEDIFF(millisecond, t.StartTimeSlotInUTC, t.ENDTimeSlotInUTC)/(1000.0 * 60.0),4)
		FROM #TransientChronoUnaccountedTimeSlots t
		WHERE t.IsAccounted = 1

		SET @LastCreatedTimeSlotID = @LastCreatedTimeSlotID + @@ROWCOUNT

		DELETE t FROM #TransientChronoUnaccountedTimeSlots t WHERE t.IsAccounted = 1



		/****************************** END Merge Meetings *********************************/

		/********** Prepare #TransientTimeSlot for UPDATE/INSERT [DailyActivity] *********/
		SELECT @UnknownAppID = ID FROM EDW.Dim_AppMaster WHERE CompanyID=@CompanyID AND AppID=0
		SELECT @UnaccountedCategory = ID FROM EDW.Dim_ActivityCategory WHERE CompanyID=@CompanyID AND ActivityCategoryID=0

		INSERT INTO #TransientTimeSlot(Dim_CompanyId, Dim_UserID, ActivityDate, DeviceID, Dim_AppMasterID, FileOrUrlID, IsFileOrUrl, PurposeID, Dim_ActivityCategoryID, IsOnPc, TimeSpent)

		SELECT t.Dim_CompanyID, t.Dim_UserID, t.ActivityDate,
				t.DeviceID, t.Dim_AppMasterID, 0 FileOrUrlID, t.IsFileOrUrl, t.PurposeID, t.Dim_ActivityCategoryID, t.IsOnPc
				,SUM(t.Timespent)  
		FROM EDW.Fact_TimeSlot t
		JOIN EDW.Dim_ActivityCategory ac ON t.Dim_ActivityCategoryID = ac.ID
		JOIN EDW.Dim_AppMaster am ON t.Dim_AppMasterID = am.ID
		JOIN #TransientUsers s ON t.Dim_CompanyID = s.Dim_CompanyId AND t.ActivityDate = s.ActivityDate AND t.Dim_UserID = s.Dim_UserID
		WHERE t.ActivityDate IN (SELECT DISTINCT ActivityDate FROM #TransientUsers)
			AND t.Dim_CompanyId = @CompanyID AND t.IsActive = 1 AND ac.ActivityCategoryID <> 0
		GROUP BY t.Dim_CompanyID, t.Dim_UserID, t.ActivityDate, t.DeviceID, Dim_AppMasterID, t.IsFileOrUrl, t.PurposeID, Dim_ActivityCategoryID, ac.ActivityCategoryID, t.IsOnPc

		UNION ALL --------------------------------------------------------

		SELECT @CompanyID, s.Dim_UserID, s.ActivityDate, 0, @UnknownAppID, 0, 0, @PrivateWork, @UnaccountedCategory, 0, sum(DATEDIFF(minute, s.StartTimeSlotInUTC, s.ENDTimeSlotInUTC))
		FROM #TransientChronoUnaccountedTimeSlots s
		WHERE s.ENDTimeSlotInUTC is not null AND DATEDIFF(minute, s.StartTimeSlotInUTC, s.ENDTimeSlotInUTC) between @MinUnaccountedTimeThreshold AND @MaxUnaccountedTimeThreshold
		GROUP BY s.Dim_UserID, s.ActivityDate


		-- ********** UPDATE/INSERT [DailyActivity] *****
		MERGE EDW.Fact_DailyActivity a
		USING #TransientTimeSlot t
		ON
			(a.Dim_CompanyID = t.Dim_CompanyID AND a.Dim_UserID = t.Dim_UserID AND a.ActivityDate = t.ActivityDate AND a.DeviceID = t.DeviceID AND a.Dim_AppMasterID = t.Dim_AppMasterID AND a.FileOrUrlID = t.FileOrUrlID AND a.IsFileOrUrl = t.IsFileOrUrl AND a.PurposeID = t.PurposeID 
				AND a.Dim_ActivityCategoryID = t.Dim_ActivityCategoryID AND a.IsOnPc = t.IsOnPc)
		WHEN MATCHED THEN UPDATE
			SET a.TimeSpentInCalENDarDay = t.Timespent
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (Dim_CompanyID, Dim_UserID, ActivityDate, DeviceID, Dim_AppMasterID, FileOrUrlID, IsFileOrUrl, PurposeID, Dim_ActivityCategoryID, IsOnPc, TimeSpentInCalendarDay, TimeSpentInShift)    
			VALUES (Dim_CompanyID, Dim_UserID, ActivityDate, DeviceID, Dim_AppMasterID, 0, IsFileOrUrl, PurposeID, Dim_ActivityCategoryID, IsOnPc, TimeSpent, 0);

		UPDATE t
		SET t.TimeSpentInCalendarDay = 0
		FROM EDW.Fact_DailyActivity t
		JOIN #TransientUsers s ON t.Dim_CompanyId = s.Dim_CompanyID AND  t.Dim_UserID = s.Dim_UserID AND t.ActivityDate = s.ActivityDate
		WHERE t.Dim_CompanyID = @CompanyID 
		AND NOT EXISTS 
			(SELECT 1 FROM #TransientTimeSlot a WHERE a.Dim_CompanyID = t.Dim_CompanyID AND a.Dim_UserID = t.Dim_UserID AND a.ActivityDate = t.ActivityDate AND a.DeviceID = t.DeviceID AND a.Dim_AppMasterID = t.Dim_AppMasterID AND a.FileOrUrlID = t.FileOrUrlID AND a.IsFileOrUrl = t.IsFileOrUrl AND a.PurposeID = t.PurposeID 
				AND a.Dim_ActivityCategoryID = t.Dim_ActivityCategoryID AND a.IsOnPc = t.IsOnPc
			)		


		/********* #TempTimeSlot ********/
		SELECT m.Dim_CompanyId,
				m.Dim_UserId,
				m.ActivityDate,
				MIN(m.StartTimeInLocal) Start_Time,
				MAX(m.EndTimeInLocal) End_Time,
				MIN(CASE WHEN m.IsOnPc =1 THEN m.StartTimeInLocal ELSE NULL END) FirstOnPcTime,
				MAX(CASE WHEN m.IsOnPc =1 THEN m.EndTimeInLocal ELSE NULL END) LastOnPcTime,
				DATEDIFF(MINUTE,MIN(m.StartTimeInLocal),MAX(m.EndTimeInLocal)) as EstimatedTimeSpent,
				SUM(Case WHEN m.PurposeID = 1 AND m.IsOnPc = 1 THEN m.TimeSpent ELSE 0 END) as OnlineTimeSpent,
				SUM(Case WHEN m.PurposeID = 1 AND m.IsOnPc = 0 THEN m.TimeSpent ELSE 0 END) as OfflineTimeSpent,
				SUM(Case WHEN m.PurposeID = -1 AND DATEPART(WEEKDAY,m.ActivityDate) NOT IN (@WeekEND1, @WeekEND2) THEN m.TimeSpent ELSE 0 END) as PrivateTimeSpent,
				0 as UnaccountedTimeSpent,
				0 as FocusTimeInCalendarDay,
				0 as FocusTimeInShift
		INTO #TempTimeSlot
		FROM EDW.Fact_TimeSlot m
		JOIN EDW.Dim_ActivityCategory ac ON m.Dim_ActivityCategoryID = ac.ID
		JOIN #TransientUsers n ON n.Dim_CompanyId = m.Dim_CompanyId AND n.Dim_UserID = m.Dim_UserID AND n.ActivityDate = m.ActivityDate
		WHERE m.IsActive = 1 and ac.ActivityCategoryID <> 0
		GROUP BY m.Dim_CompanyId,m.Dim_UserId,m.ActivityDate

		UPDATE t
		SET t.UnaccountedTimeSpent = s.TimeSpentInCalendarDay
		FROM #TempTimeSlot t
		JOIN EDW.Fact_DailyActivity s on t.Dim_CompanyId = s.Dim_CompanyID and t.Dim_UserID = s.Dim_UserID and t.ActivityDate = s.ActivityDate 
		JOIN EDW.Dim_ActivityCategory ac ON s.Dim_ActivityCategoryID = ac.ID
		WHERE s.PurposeID = -1 and ac.ActivityCategoryID = 0



		/*************** UPDATE/INSERT [Fact_DailyUser]  *************/
		MERGE EDW.Fact_DailyUser a 
		USING #TempTimeSlot t
		ON (a.Dim_CompanyID = t.Dim_CompanyID AND a.Dim_UserID = t.Dim_UserID AND a.ActivityDate = t.ActivityDate)
		WHEN MATCHED THEN 
			UPDATE
			SET
				a.Start_Time = t.Start_Time,
				a.End_Time = t.End_Time,
				a.FirstOnPcTime = t.FirstOnPcTime,
				a.LastOnPcTime = t.LastOnPcTime,
				a.EstimatedTimeSpent = t.EstimatedTimeSpent,
				a.OnlineTimeSpent = t.OnlineTimeSpent,
				a.OfflineTimeSpent = t.OfflineTimeSpent,
				a.PrivateTimeSpent = t.PrivateTimeSpent,
				a.UnaccountedTimeSpent = t.UnaccountedTimeSpent,
				a.FocusTimeInCalendarDay = t.FocusTimeInCalendarDay,
				a.FocusTimeInShift = t.FocusTimeInShift
		WHEN NOT MATCHED THEN
			INSERT (Dim_CompanyID, Dim_UserID, ActivityDate, Start_Time, End_Time, FirstOnPcTime, LastOnPcTime, EstimatedTimeSpent, OnlineTimeSpent, OfflineTimeSpent, PrivateTimeSpent, UnaccountedTimeSpent, FocusTimeInCalendarDay, FocusTimeInShift)    
			VALUES (Dim_CompanyID, Dim_UserID, ActivityDate, Start_Time, End_Time, FirstOnPcTime, LastOnPcTime, EstimatedTimeSpent, OnlineTimeSpent, OfflineTimeSpent, PrivateTimeSpent, UnaccountedTimeSpent, FocusTimeInCalendarDay, FocusTimeInShift);


		SELECT s.Dim_CompanyId,s.ActivityDate, s.Dim_UserID, s.StartTimeInUTC, s.ENDTimeInUTC, s.TimeSpent
		INTO #CoreTimeSlots
		FROM EDW.Fact_TimeSlot s
		JOIN #TransientUsers t ON t.Dim_CompanyID = s.Dim_CompanyId AND t.Dim_UserID = s.Dim_UserID AND t.ActivityDate = s.ActivityDate
		JOIN EDW.Dim_ActivityCategory a ON s.Dim_CompanyId = a.CompanyID AND s.Dim_ActivityCategoryID = a.ID
		WHERE t.ActivityDate IN (SELECT DISTINCT ActivityDate FROM #TransientUsers) AND a.IsCore = 1

		SELECT s.Dim_CompanyId,s.ActivityDate, s.Dim_UserID, s.TimeSpent, s.StartTimeInUTC, s.ENDTimeInUTC,   ---DateDIFf < 1 minute
		CASE WHEN DATEDIFF(minute,LAG(s.ENDTimeInUTC, 1, '1900') OVER(PARTITION BY s.ActivityDate, s.Dim_UserID ORDER BY s.StartTimeInUTC, s.ENDTimeInUTC),s.StartTimeInUTC) < 1 THEN 0 ELSE 1 END AS HasGap
		INTO #TimeSlots 
		FROM #CoreTimeSlots s

		SELECT s.Dim_CompanyId, s.Dim_UserID, s.ActivityDate,  s.TimeSpent, s.StartTimeInUTC, s.ENDTimeInUTC, sum(s.HasGap) over (partition by s.ActivityDate, s.Dim_UserID ORDER BY s.StartTimeInUTC, s.ENDTimeInUTC ROWS UNBOUNDED PRECEDING) as TimeSlotGroup 
		INTO #TimeSlotGroups
		FROM #TimeSlots s

		SELECT s.Dim_CompanyId,s.ActivityDate, s.Dim_UserID, MIN (s.StartTimeInUTC) StartTime, MAX(s.ENDTimeInUTC) ENDTime, SUM(s.TimeSpent) TimeSpent 
		INTO #TimeSlotsTime
		FROM #TimeSlotGroups s
		GROUP BY s.Dim_CompanyId, s.Dim_UserID, s.ActivityDate, s.TimeSlotGroup
		ORDER BY s.Dim_UserID, s.ActivityDate

		INSERT INTO #TransientTotalTime ([Dim_CompanyId], [Dim_UserID], [ActivityDate], [TimeSpent] )
		SELECT s.Dim_CompanyId, s.Dim_UserID, s.ActivityDate, SUM(s.TimeSpent)
		FROM #TimeSlotsTime s
		WHERE s.TimeSpent > 25
		GROUP BY s.Dim_CompanyId, s.Dim_UserID, s.ActivityDate

		-- ********** UPDATE/INSERT [Fact_DailyUser] ***********
		UPDATE t
		SET t.FocusTimeInCalendarDay = s.TimeSpent
		FROM EDW.Fact_DailyUser t
		JOIN #TransientTotalTime s on t.Dim_CompanyId = s.Dim_CompanyID and t.Dim_UserID = s.Dim_UserID and t.ActivityDate = s.ActivityDate 


		SELECT t.Dim_CompanyID,t.Dim_UserID,t.ActivityDate,
			SUM(CASE WHEN t.BreakSlot >= @MinBreakTimeThreshold AND t.BreakSlot <= @MaxBreakTimeThreshold THEN t.BreakSlot else 0 END) BreakTime,
			SUM(CASE WHEN t.BreakSlot >= @MinBreakTimeThreshold AND t.BreakSlot <= @MaxBreakTimeThreshold THEN 1 ELSE 0 END) BreakStatus 
			INTO #BreakTimeSlot
			FROM
			(SELECT
				t.Dim_CompanyID, t.Dim_UserID, t.ActivityDate, t.StartTimeInLocal, t.EndTimeInLocal,
				DATEDIFF(minute, t.EndTimeInLocal, Lead(t.StartTimeInLocal, 1) OVER (PARTITION BY t.Dim_UserID, t.ActivityDate ORDER BY t.StartTimeInLocal)) as BreakSlot 
				FROM edw.Fact_TimeSlot t
				JOIN #TransientTotalTime s on t.Dim_CompanyId = s.Dim_CompanyID and t.Dim_UserID = s.Dim_UserID and t.ActivityDate = s.ActivityDate 
			) t
	    GROUP by t.Dim_CompanyID,t.Dim_UserID,t.ActivityDate

		UPDATE t
		SET
			t.BreakTimeInCalenderDay = s.BreakTime
			,t.NumberOfBreakInCalenderDay = s.BreakStatus
		FROM
		edw.Fact_DailyUser t
		JOIN #BreakTimeSlot s ON t.Dim_CompanyID = s.Dim_CompanyID AND t.Dim_UserId = s.Dim_UserID AND t.ActivityDate = s.ActivityDate 


		UPDATE t
		SET LastTimeSlotProcessedTime = @CurrentTimeSlotProcessedTime 
		FROM EDW.Log_TimeSlotProcessStatus t 
		WHERE t.CompanyID = @CompanyID and t.TimeSlotType = 0


		DROP TABLE #TransientTimeSlot
		DROP TABLE #TransientTotalTime
		DROP TABLE #TransientUsers
		DROP TABLE #TransientChronoUnaccountedTimeSlots
		DROP TABLE #CoreTimeSlots
		DROP TABLE #TimeSlots
		DROP TABLE #TimeSlotGroups
		DROP TABLE #TimeSlotsTime
		DROP TABLE #MeetingTimeSlots
		DROP TABLE #TempTimeSlot
		DROP TABLE #BreakTimeSlot


		COMMIT TRANSACTION trans_DailyUserActivity
	END TRY

	BEGIN CATCH
		IF (@@TRANCOUNT > 0) 
		BEGIN

			ROLLBACK TRANSACTION trans_DailyUserActivity
			
			--##################### IF ERR, ROLLBACK TRANSACTION ##################
			DECLARE 
				@ErrorMessage NVARCHAR(4000),
				@ErrorSeverity INT,
				@ErrorState INT;
			SELECT 
				@ErrorMessage = ERROR_MESSAGE(),
				@ErrorSeverity = ERROR_SEVERITY(),
				@ErrorState = ERROR_STATE();
			RAISERROR (
				@ErrorMessage,
				@ErrorSeverity,
				@ErrorState    
				);
		END
	END CATCH

END

GO
/****** Object:  StoredProcedure [edw].[sproc_CreateSpecialDimValues]    Script Date: 9/10/2021 8:10:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [edw].[sproc_CreateSpecialDimValues]

AS
BEGIN
/**********************************************
SPECIAL VALUES - ActivityCategory and AppMaster
	create if special values do not exist
***********************************************/

	SELECT ROW_NUMBER() OVER(ORDER BY CompanyID) ID, LineofBusinessID
	INTO #Company
	FROM edw.Dim_Company
	WHERE CompanyID<>0

	DECLARE @MaxID INT
	DECLARE @CompanyID INT
	DECLARE @Counter INT = 1

	SELECT @MaxID = MAX(ID) FROM #Company

	WHILE @Counter <= @MaxID
	BEGIN
		SELECT @CompanyID = LineofBusinessID FROM #Company WHERE ID = @Counter

		--******************************* Dim_ActivityCategory **********************************
		-- 0 Unaccounted
		IF NOT EXISTS (SELECT * FROM edw.Dim_ActivityCategory WHERE CompanyID=@CompanyID AND ActivityCategoryID=0)
		BEGIN
			INSERT INTO edw.Dim_ActivityCategory (CompanyID, ActivityCategoryGroupID, ActivityCategoryID, ActivityCategoryTypeID, PlatformTypeID, ActivityCategoryGroupName, ActivityCategoryName, IsCore, IsSystemDefined, IsConfigurable, IsGlobal, DateCreated, IsActive, IsWorkCategory, IsDefault)
			VALUES (@CompanyID, 1, 0, 1, 1, '', 'Unaccounted', 0, 1, 1, 1, GETUTCDATE(), 1, 1, 0)
		END

		-- 100 Miscellaneous
		IF NOT EXISTS (SELECT * FROM edw.Dim_ActivityCategory WHERE CompanyID=@CompanyID AND ActivityCategoryID=100)
		BEGIN
			INSERT INTO edw.Dim_ActivityCategory (CompanyID, ActivityCategoryGroupID, ActivityCategoryID, ActivityCategoryTypeID, PlatformTypeID, ActivityCategoryGroupName, ActivityCategoryName, IsCore, IsSystemDefined, IsConfigurable, IsGlobal, DateCreated, IsActive, IsWorkCategory, IsDefault)
			VALUES (@CompanyID, 1, 100, 1, 1, '', 'Miscellaneous', 0, 1, 1, 1, GETUTCDATE(), 1, 1, 0)
		END

		-- -1 Private
		IF NOT EXISTS (SELECT * FROM edw.Dim_ActivityCategory WHERE CompanyID=@CompanyID AND ActivityCategoryID=-1)
		BEGIN
			INSERT INTO edw.Dim_ActivityCategory (CompanyID, ActivityCategoryGroupID, ActivityCategoryID, ActivityCategoryTypeID, PlatformTypeID, ActivityCategoryGroupName, ActivityCategoryName, IsCore, IsSystemDefined, IsConfigurable, IsGlobal, DateCreated, IsActive, IsWorkCategory, IsDefault)
			VALUES (@CompanyID, 1, -1, 1, 1, '', 'Private', 0, 1, 1, 1, GETUTCDATE(), 1, 1, 0)
		END

		-- 5 Meetings
		IF NOT EXISTS (SELECT * FROM edw.Dim_ActivityCategory WHERE CompanyID=@CompanyID AND ActivityCategoryID=5)
		BEGIN
			INSERT INTO edw.Dim_ActivityCategory (CompanyID, ActivityCategoryGroupID, ActivityCategoryID, ActivityCategoryTypeID, PlatformTypeID, ActivityCategoryGroupName, ActivityCategoryName, IsCore, IsSystemDefined, IsConfigurable, IsGlobal, DateCreated, IsActive, IsWorkCategory, IsDefault)
			VALUES (@CompanyID, 1, 5, 1, 1, '', 'Meetings', 0, 1, 1, 1, GETUTCDATE(), 1, 1, 0)
		END


		--******************************* Dim_AppMaster **********************************

		-- -3 Not Applicable
		IF NOT EXISTS (SELECT * FROM edw.Dim_AppMaster WHERE CompanyID=@CompanyID AND AppID=-3)
		BEGIN
			INSERT INTO edw.Dim_AppMaster (CompanyID, AppID, PlatformTypeID, ExeName, AppName, AppVersion, IsApplication, IsOffline)
			VALUES (@CompanyID, -3, 1, '', 'Not Applicable', '', 0, 1)
		END

		-- -2 Outlook Meetings
		IF NOT EXISTS (SELECT * FROM edw.Dim_AppMaster WHERE CompanyID=@CompanyID AND AppID=-2)
		BEGIN
			INSERT INTO edw.Dim_AppMaster (CompanyID, AppID, PlatformTypeID, ExeName, AppName, AppVersion, IsApplication, IsOffline)
			VALUES (@CompanyID, -2, 1, '', 'Outlook Meetings', '', 0, 1)
		END

		-- -1 Unknown
		IF NOT EXISTS (SELECT * FROM edw.Dim_AppMaster WHERE CompanyID=@CompanyID AND AppID=-1)
		BEGIN
			INSERT INTO edw.Dim_AppMaster (CompanyID, AppID, PlatformTypeID, ExeName, AppName, AppVersion, IsApplication, IsOffline)
			VALUES (@CompanyID, -1, 1, '', 'Unknown', '', 0, 1)
		END

		-- 0 Off-PC
		IF NOT EXISTS (SELECT * FROM edw.Dim_AppMaster WHERE CompanyID=@CompanyID AND AppID=0)
		BEGIN
			INSERT INTO edw.Dim_AppMaster (CompanyID, AppID, PlatformTypeID, ExeName, AppName, AppVersion, IsApplication, IsOffline)
			VALUES (@CompanyID, 0, 1, '', 'Off-PC', '', 0, 1)
		END


		SET @Counter = @Counter + 1
	END


	DROP TABLE #Company

END

GO
/****** Object:  StoredProcedure [edw].[sproc_CreateTimeSlots]    Script Date: 9/10/2021 8:10:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [edw].[sproc_CreateTimeSlots]
(
    @CompanyID int
	,@Debug tinyint = 0
)
AS
BEGIN
    SET XACT_ABORT, NOCOUNT ON

	BEGIN TRY
		--######################### BEGIN TRANSACTION #####################
		BEGIN TRANSACTION trans_TimeSlot
		
			DECLARE @TimeOutDurationInMinutes int = 5
				,@ProcStartTime datetime = GetUTCDate()
				,@MaxUploadTime datetime = GetUTCDate()
				,@ProcName varchar(100) = 'sproc_AnalyzeTimeSlots'
				,@Step varchar(1024) = ''
				,@TimeSlotRecordCount int = 0
				,@BatchCount int = 100000
				,@OutlookMeetingsAppID integer = -2
				,@MeetingActivityCategoryID integer = 5
				,@LastProcessedRawTimeSlotID bigint = 0
				,@LastRawTimeSlotProcessedTime datetime = NULL
				,@MaxRawTimeSlotId bigint = 0
				,@BeginRawTimeslotBatchId bigint = 0
				,@ENDRawTimeSlotBatchId bigint = 0
				,@RowCount int = 0
				,@MaxAppID int = 0


				IF (@Debug = 100)
				BEGIN
					SET @Step = 'Begin 0'
					INSERT INTO EDW.Log_Trace ([CompanyId], [LogTime], [LogName], [LogDetail], [ElapsedTimeInSeconds])
					VALUES (@CompanyID, GetUTCDate(), @ProcName, @Step, DATEDIFF(SECOND, @ProcStartTime, GetUTCDate()))
				END

			CREATE TABLE #TempMeetingTimeSlots
				([CompanyID] [int] NOT NULL,
				[UserID] [int] NOT NULL,
				[ActivityDate] [date] NOT NULL,
				[MeetingID] [nvarchar](512) NOT NULL,
				[MeetingSubject] [nvarchar](512) NOT NULL,
				[MeetingStartTimeUTC] [datetime] NOT NULL,
				[MeetingENDTimeUTC] [datetime] NOT NULL,
				[MeetingStartTimeLocal] [datetime] NOT NULL,
				[MeetingENDTimeLocal] [datetime] NOT NULL,
				[MeetingTimeZoneOffSet] [real] NOT NULL,
				[MeetingDuration] INT NOT NULL,
				[MeetingActivityVersion] [nvarchar](256) NOT NULL,
				[MeetingBusyStatus] [nvarchar](256) NOT NULL,
				[MeetingResponseStatus] [nvarchar](256) NOT NULL,
				[MeetingSensitivity] [nvarchar](256) NOT NULL,
				[Meetingstatus] [nvarchar](256) NOT NULL,
				[IsActive] [bit] NOT NULL,
				[UploadTime] [datetime] NOT NULL 
				)

			CREATE TABLE #FinalMeetingTimeSlots
				([CompanyID] [int] NOT NULL,
				[UserID] [int] NOT NULL,
				[ActivityDate] [date] NOT NULL,
				[MeetingID] [nvarchar](512) NOT NULL,
				[MeetingSubject] [nvarchar](512) NOT NULL,
				[MeetingStartTimeUTC] [datetime] NOT NULL,
				[MeetingENDTimeUTC] [datetime] NOT NULL,
				[MeetingStartTimeLocal] [datetime] NOT NULL,
				[MeetingENDTimeLocal] [datetime] NOT NULL,
				[MeetingTimeZoneOffSet] [real] NOT NULL,
				[MeetingDuration] INT NOT NULL,
				[MeetingActivityVersion] [nvarchar](256) NOT NULL,
				[MeetingBusyStatus] [nvarchar](256) NOT NULL,
				[MeetingResponseStatus] [nvarchar](256) NOT NULL,
				[MeetingSensitivity] [nvarchar](256) NOT NULL,
				[Meetingstatus] [nvarchar](256) NOT NULL,
				[IsActive] [bit] NOT NULL,
				[UploadTime] [datetime] NOT NULL ,
				MeetingRank [int] NOT NULL
				)

				IF (@Debug = 100)
				BEGIN
					SET @Step = 'Meeting Analysis Start' 
					INSERT INTO EDW.Log_Trace ([CompanyId], [LogTime], [LogName], [LogDetail], [ElapsedTimeInSeconds])
					VALUES (@CompanyID, GetUTCDate(), @ProcName, @Step, DATEDIFF(SECOND, @ProcStartTime, GetUTCDate()))
				END

			/***********************************************************************************************************************
			Notes: @BeginRawTimeslotBatchId ---> [EDW].[Log_TimeSlotProcessStatus].LastRawTimeSlotProcessedID + 1 (TimeSlotType = 1)
				   @MaxRawTimeSlotId ---> [Staging].[RawTimeSlot_Meeting].MAX(RawTimeSlot_MeetingID)
			***********************************************************************************************************************/

			SELECT @LastProcessedRawTimeSlotID = r.LastCreatedRawTimeSlotProcessedID,
				   @LastRawTimeSlotProcessedTime = r.LastRawTimeSlotProcessedTime
			FROM EDW.Log_TimeSlotProcessStatus r
			WHERE r.CompanyID = @CompanyID and r.TimeSlotType = 1

			SET @BeginRawTimeslotBatchId = @LastProcessedRawTimeSlotID + 1
			SET @EndRawTimeSlotBatchId = (@BatchCount -1) + @BeginRawTimeslotBatchId 

			SELECT @MaxRawTimeSlotId = ISNULL(MAX(s.RawTimeSlot_MeetingID),0) 
			FROM [Staging].[RawTimeSlot_Meeting] s
			WHERE s.CompanyID = @CompanyID and s.RawTimeSlot_MeetingID >=  @LastProcessedRawTimeSlotID

			IF (@EndRawTimeSlotBatchId > @MaxRawTimeSlotId)
			BEGIN
				SET @ENDRawTimeSlotBatchId = @MaxRawTimeSlotId
			END


			-- BEGIN MEETING WHILE
			WHILE (@BeginRawTimeslotBatchId < @MaxRawTimeSlotId AND DATEDIFF(MINUTE, @ProcStartTime, GetUTCDate()) < @TimeOutDurationInMinutes)
			BEGIN

					IF (@Debug = 100)
					BEGIN
						SET @Step = 'Meeting Analysis - Next Interval: ' + convert(varchar, @BeginRawTimeslotBatchId) + ' and ' + + convert(varchar, @ENDRawTimeslotBatchId)
						INSERT INTO EDW.Log_Trace([CompanyId], [LogTime], [LogName], [LogDetail], [ElapsedTimeInSeconds])
						 VALUES (@CompanyID, GetUTCDate(), @ProcName, @Step, DATEDIFF(SECOND, @ProcStartTime, GetUTCDate()))
					END

				-- ******** #TempMeetingTimeSlots
				INSERT INTO #TempMeetingTimeSlots
				SELECT s.[CompanyID]
						,u.[UserID]
						,CONVERT(date,DATEADD(minute,convert(real,[tzOffSET])*60.0,CONVERT(datetime,LEFT(s.data_start, 19)))) ActivityDate
						,ISNULL(s.[data_meetingid],s.[data_Subject])  as MeetingID
						,s.[data_Subject] MeetingSubject
						,CONVERT(datetime,LEFT(s.data_start, 19)) MeetingStartTimeUTC
						,CONVERT(datetime,LEFT(s.data_END, 19))  MeetingENDTimeUTC
						,DATEADD(minute,convert(real,[tzOffSET])*60.0,CONVERT(datetime,LEFT(s.data_start, 19))) as MeetingStartTimeLocal
						,DATEADD(minute,convert(real,[tzOffSET])*60.0,CONVERT(datetime,LEFT(s.data_END, 19))) as MeetingENDTimeLocal
						,CONVERT(real,s.[tzOffSET]) * 60.0 MeetingTimeZoneOffSet
						,ISNULL(s.data_duration,'') as MeetingDuration
						,ISNULL(s.data_activity_version,'') as [MeetingActivityVersion]
						,ISNULL(s.data_busyStatus,'') as [MeetingBusyStatus]
						,ISNULL(s.data_responseStatus ,'') as [MeetingResponseStatus]
						,ISNULL(s.data_sensitivity,'') as [MeetingSensitivity]
						,ISNULL(s.data_status,'') as [MeetingStatus]
						,0 as ISACTIVE
						,s.UploadTime as UploadTime
				FROM [Staging].[RawTimeSlot_Meeting] s
				JOIN EDW.Dim_User u
					ON s.CompanyID = u.CompanyID AND s.data_activity_domain = u.DomainName AND s.data_activity_userId = u.DomainUserID
				WHERE (s.CompanyID = @CompanyID) 
					AND (s.RawTimeSlot_MeetingID BETWEEN @BeginRawTimeslotBatchId AND @EndRawTimeslotBatchId)
					AND ([data_activity_version] IS NULL OR [data_activity_version] <> '0.1.0')


				-- ******** #FinalMeetingTimeSlots
				INSERT INTO #FinalMeetingTimeSlots
				SELECT * FROM
					(SELECT k.CompanyID,k.UserID,k.ActivityDate
							,MeetingID,MeetingSubject,MeetingStartTimeUTC,MeetingENDTimeUTC
							,MeetingStartTimeLocal,MeetingENDTimeLocal,MeetingTimeZoneOffSet
							,MeetingDuration,MeetingActivityVersion,MeetingBusyStatus,MeetingResponseStatus
							,MeetingSensitivity,MeetingStatus,IsActive,UploadTime
							,ROW_NUMBER() OVER (PARTITION BY k.CompanyID,k.UserID,k.ActivityDate,k.MeetingID ORDER BY UploadTime DESC) MeetingRank 
					FROM #TempMeetingTimeSlots k
					WHERE DATEDIFF(minute,MeetingStartTimeLocal,MeetingENDTimeLocal) = MeetingDuration		
					) s
				WHERE s.MeetingRank = 1
	
				UPDATE #FinalMeetingTimeSlots
				SET IsActive = 1
				WHERE CompanyID = @CompanyID
					AND MeetingDuration < 720
					AND [MeetingbusyStatus] in ('olBusy','olWorkingELSEWHERE')
					AND [MeetingresponseStatus] in ('olResponseAccepted','olResponseOrganized')
					AND [Meetingsensitivity] in ('olNormal')
					AND [Meetingstatus] in ('olMeeting', 'olMeetingReceived')


				-- ********** UPDATE EDW.Fact_TimeSlotMeeting *********
				UPDATE a
				SET a.MeetingStartTimeUTC = t.MeetingStartTimeUTC,
					a.MeetingENDTimeUTC = t.MeetingENDTimeUTC,
					a.MeetingStartTimeLocal = t.MeetingStartTimeLocal,
					a.MeetingENDTimeLocal = t.MeetingENDTimeLocal,
					a.MeetingTimeZoneOffSet = t.MeetingTimeZoneOffSet,
					a.MeetingDuration = t.MeetingDuration,
					a.MeetingbusyStatus = t.MeetingbusyStatus,
					a.MeetingresponseStatus = t.MeetingresponseStatus,
					a.Meetingsensitivity = t.Meetingsensitivity,
					a.Meetingstatus = t.Meetingstatus,
					a.IsActive = t.IsActive,
					a.UploadTime = t.UploadTime
				FROM EDW.Fact_TimeSlotMeeting a
				JOIN EDW.Dim_User u ON a.Dim_UserID = u.ID
				JOIN #FinalMeetingTimeSlots t
					ON u.CompanyID = t.CompanyID AND u.UserID = t.UserID AND a.ActivityDate = t.ActivityDate AND a.MeetingID = t.MeetingID


				-- ********** INSERT EDW.Fact_TimeSlotMeeting *********
				INSERT INTO EDW.Fact_TimeSlotMeeting ([Dim_CompanyID],[Dim_UserID],[ActivityDate],[MeetingID],[MeetingSubject],[MeetingStartTimeUTC],[MeetingENDTimeUTC],[MeetingStartTimeLocal],[MeetingENDTimeLocal], [MeetingTimeZoneOffSet],[MeetingDuration],[MeetingbusyStatus],[MeetingresponseStatus],[Meetingsensitivity],[Meetingstatus],[IsActive],[UploadTime]) 
				SELECT p.CompanyID, u.ID, p.ActivityDate, p.MeetingID, p.MeetingSubject, p.MeetingStartTimeUTC, p.MeetingENDTimeUTC, p.MeetingStartTimeLocal, p.MeetingENDTimeLocal, p.MeetingTimeZoneOffSet, p.MeetingDuration,p.MeetingbusyStatus,p.MeetingresponseStatus,p.Meetingsensitivity,p.Meetingstatus,p.IsActive,GetUTCDate()
				FROM #FinalMeetingTimeSlots p
				JOIN EDW.Dim_User u ON p.UserID = u.UserID AND p.CompanyID = u.CompanyID
				LEFT JOIN EDW.Fact_TimeSlotMeeting tsm ON p.CompanyID = u.CompanyID
					AND p.UserID = u.UserID
					AND p.MeetingStartTimeUTC = tsm.MeetingStartTimeUTC
					AND p.MeetingEndTimeUTC = tsm.MeetingEndTimeUTC
					AND p.MeetingID = tsm.MeetingID
				WHERE tsm.Dim_UserID IS NULL


				-- ******* UPDATE Log_TimeSlotProcessStatus 'TimeSlot'
				UPDATE d
				SET d.LastTimeSlotProcessedTime = GETUTCDATE()
					--d.LastCreatedTimeSlotID = @LastCreatedTimeSlotID,
				FROM EDW.Log_TimeSlotProcessStatus d
				WHERE d.CompanyID = @CompanyID AND d.TimeSlotType = 1

					IF (@Debug = 100)
					BEGIN
						SET @Step = 'Meeting Analysis - END of Loop. Start: ' + convert(varchar, @BeginRawTimeslotBatchId) + ' and ' + + convert(varchar, @ENDRawTimeslotBatchId)
						INSERT INTO EDW.Log_Trace ([CompanyId], [LogTime], [LogName], [LogDetail], [ElapsedTimeInSeconds])
						VALUES (@CompanyID, GetUTCDate(), @ProcName, @Step, DATEDIFF(SECOND, @ProcStartTime, GetUTCDate()))
					END


				-- ******* UPDATE Log_TimeSlotProcessStatus 'RawTimeSlot'
				UPDATE u
				SET u.LastRawTimeSlotProcessedTime = GetUTCDate(), u.LastCreatedRawTimeSlotProcessedID = @EndRawTimeSlotBatchID
				FROM EDW.Log_TimeSlotProcessStatus u
				WHERE u.CompanyID = @CompanyID and u.TimeSlotType = 1	


				TRUNCATE TABLE #FinalMeetingTimeSlots
				TRUNCATE TABLE #TempMeetingTimeSlots

				SET @BeginRawTimeslotBatchID = @ENDRawTimeSlotBatchID + 1
				SET @ENDRawTimeSlotBatchID = (@BatchCount - 1) + @BeginRawTimeslotBatchID

				IF (@ENDRawTimeSlotBatchId > @MaxRawTimeSlotId)
				BEGIN
					SET @ENDRawTimeSlotBatchId = @MaxRawTimeSlotId
				END 

			END 
			-- END MEETING WHILE

			DROP TABLE #FinalMeetingTimeSlots
			DROP TABLE #TempMeetingTimeSlots


			-- ******************************************* END: MEETING PROCESSING / START: REG ACTIVITY PROCESSING *****************************************

			CREATE TABLE #TempTimeSlots
				([CompanyID] [integer]
				,[UserID] [integer]		
				,[StartTimeInUTC] [datetime] 
				,[ENDTimeInUTC] [datetime]
				,[TimeZoneOffset] [nvarchar] (512)
				,[data_sessionid] [nvarchar] (4000)
				,[data_productversion] [nvarchar] (512)
				,[data_fileDescription] [nvarchar] (2048)
				,[data_exeName] [nvarchar] (2048)
				,[data_activity_domain] [nvarchar] (512)
				,[data_activity_userId] [nvarchar] (512)
				,[DeviceID] [integer]
				,[data_windowTitle] [nvarchar] (4000)
				,[data_subWindowTitle] [nvarchar] (4000) default ('')
				,[data_url] [nvarchar] (4000)
				,[AppID] [integer] default (-1)
				,[ActivityCategoryGroupID] [integer] default (1)
				,[ActivityCategoryID] [integer]  default (100)
				,IsUrl bit default(0)
				,WebAppName [nvarchar] (4000) default ('')
				) 

			CREATE TABLE #TempUsersByActivityDate 
				(CompanyId integer, 
				Dim_UserID integer, 
				ActivityDate Date
				)

			CREATE TABLE #TempChronoTimeSlots
				([ActivityDate] date NOT NULL,
				[Dim_UserID] integer NOT NULL,
				[EndTimeInUTC] [datetime] NOT NULL, 
				[StartTimeInUTC] [datetime] NOT NULL, 
				[LeadStartTimeInUTC] [datetime] NULL 
				)
	
			SELECT @MaxAppID = IsNull(MAX(a.AppID),0) 
			FROM EDW.Dim_AppMaster a 
			WHERE a.CompanyID = @CompanyID

				IF (@Debug = 100)
				BEGIN
					SET @Step = 'Get MaxID'
					INSERT INTO edw.Log_Trace ([CompanyId], [LogTime], [LogName], [LogDetail], [ElapsedTimeInSeconds])
					VALUES (@CompanyID, GetUTCDate(), @ProcName, @Step, DATEDIFF(SECOND, @ProcStartTime, GetUTCDate()))
				END

			/**********************************************************************************************************************
			Notes: @BeginRawTimeslotBatchId ---> [EDW].[Log_TimeSlotProcessStatus].LastRawTimeSlotProcessedID + 1 (TimeSlotType = 0)
				   @MaxRawTimeSlotId ---> [Staging].[RawTimeSlot_App].MAX(RawTimeSlot_MeetingID)
			**********************************************************************************************************************/

			SELECT @LastProcessedRawTimeSlotID = r.LastCreatedRawTimeSlotProcessedID, @LastRawTimeSlotProcessedTime = r.LastRawTimeSlotProcessedTime
			FROM EDW.Log_TimeSlotProcessStatus r
			WHERE r.CompanyID = @CompanyID and r.TimeSlotType = 0

			SELECT @MaxRawTimeSlotId = ISNULL(MAX(s.RawTimeSlot_AppID),0) 
			FROM [Staging].[RawTimeSlot_App] s
			WHERE s.CompanyID = @CompanyID AND s.RawTimeSlot_AppID >= @LastProcessedRawTimeSlotID

			SET @BeginRawTimeslotBatchId = @LastProcessedRawTimeSlotID + 1
			SET @ENDRawTimeSlotBatchId = (@BatchCount -1) + @BeginRawTimeslotBatchId 

			IF (@ENDRawTimeSlotBatchId > @MaxRawTimeSlotId)
			BEGIN
				SET @ENDRawTimeSlotBatchId = @MaxRawTimeSlotId
			END


			WHILE (@BeginRawTimeslotBatchId < @MaxRawTimeSlotId AND DATEDIFF(MINUTE, @ProcStartTime, GetUTCDate()) < @TimeOutDurationInMinutes)
			-- BEGIN REG ACTIVITY WHILE
			BEGIN

					IF (@Debug = 100)
					BEGIN
						SET @Step = 'Next Interval: ' + convert(varchar, @BeginRawTimeslotBatchId) + ' and ' + + convert(varchar, @ENDRawTimeslotBatchId)
						INSERT INTO EDW.Log_Trace ([CompanyId], [LogTime], [LogName], [LogDetail], [ElapsedTimeInSeconds])
						VALUES (@CompanyID, GetUTCDate(), @ProcName, @Step, DATEDIFF(SECOND, @ProcStartTime, GetUTCDate()))
					END

				INSERT INTO #TempTimeSlots([CompanyID] ,[UserID] , [data_sessionid] ,[TimeZoneOffset] , [data_productversion], [data_fileDescription], [data_exeName] ,[data_activity_domain], [data_activity_userId] ,[DeviceID] ,[data_windowTitle], [data_url], [StartTimeInUTC]  ,[ENDTimeInUTC] )
				SELECT a.CompanyID, s.UserID, a.[data_sessionid], a.[tzOffset], a.[data_productversion], a.[data_fileDescription], a.[data_exeName], a.[data_activity_domain], a.[data_activity_userId],0, [data_windowTitle], [data_url], MIN(a.[data_activity_activityTime]) StartTime, DATEADD(second, 15, MAX(a.[data_activity_activityTime])) ENDTime
				FROM [Staging].[RawTimeSlot_App] a
				JOIN EDW.Dim_User s
					ON a.CompanyID = s.CompanyID AND a.[data_activity_domain] = s.[DomainName] AND a.[data_activity_userId] = s.[DomainUserID]
				WHERE (a.CompanyID = @CompanyID)
					AND (a.RawTimeSlot_AppID BETWEEN @BeginRawTimeslotBatchId AND @ENDRawTimeslotBatchId)
					AND (a.data_activity_activityType = 'Application')
				GROUP BY a.CompanyID, s.UserID, a.[data_sessionid],[tzOffset],[data_productversion],[data_fileDescription],[data_exeName],[data_activity_domain],[data_activity_userId],[data_windowTitle], [data_url]

				SET @TimeSlotRecordCount = @@ROWCOUNT
	
					IF (@Debug = 100)
					BEGIN
						SET @Step = 'Created #TempSession with TimeSlotRecordCount => ' + convert(varchar, @TimeSlotRecordCount)
						INSERT INTO EDW.Log_Trace([CompanyId], [LogTime], [LogName], [LogDetail], [ElapsedTimeInSeconds])
						VALUES (@CompanyID, GetUTCDate(), @ProcName, @Step, DATEDIFF(SECOND, @ProcStartTime, GetUTCDate()))
					END

				IF (@TimeSlotRecordCount > 0)
				--BEGIN: @TimeSlotRecordCount > 0
				BEGIN

					--************* New Apps to EDW.AppMaster **********
					;WITH s AS
					(
						SELECT DISTINCT ISNULL(CASE WHEN data_exeName like '%\%' then right(data_exeName, charindex('\', reverse(data_exeName)) - 1) ELSE data_exeName END , '') ExeName,
						ISNULL(CASE 
								WHEN s.data_fileDescription is not null and len(trim(s.data_fileDescription)) > 0 then s.data_fileDescription 
								ELSE 
									CASE 
										WHEN 
											(CASE 
												WHEN s.data_exeName like '%\%' then right(s.data_exeName, charindex('\', reverse(s.data_exeName)) - 1) 
												ELSE s.data_exeName 
											END) like '%.%' then left((
													CASE 
														WHEN s.data_exeName like '%\%' then right(s.data_exeName, charindex('\', reverse(s.data_exeName)) - 1) 
														ELSE s.data_exeName 
													END), charindex('.', (
														CASE 
															WHEN s.data_exeName like '%\%' then right(s.data_exeName, charindex('\', reverse(s.data_exeName)) - 1) 
															ELSE s.data_exeName 
														END)) - 1)
										ELSE 
											(CASE 
												WHEN s.data_exeName like '%\%' then right(s.data_exeName, charindex('\', reverse(s.data_exeName)) - 1) 
												ELSE s.data_exeName 
											END)  
									END
								END, '') AppName
	
						, ISNULL(s.data_productversion, '') AppVersion
	
						FROM #TempTimeSlots s
						WHERE s.CompanyID = @CompanyID
					)

					INSERT INTO EDW.Dim_AppMaster([CompanyID] ,[AppID] ,[PlatformTypeID] ,[ExeName] ,[AppName] ,[AppVersion] ,[IsApplication] ,[IsOffline])
					SELECT @CompanyID, @MaxAppID + ROW_NUMBER() OVER (ORDER BY (select 1)), 1, s.ExeName, s.AppName, s.AppVersion, 1, 0 
					FROM s
					LEFT JOIN EDW.Dim_AppMaster am ON am.CompanyID = @CompanyID
						AND am.ExeName = s.ExeName
						AND am.AppName = s.AppName
						AND am.AppVersion = s.AppVersion
					WHERE am.ID IS NULL

					-- Also, Insert records in AppParent (in master but not in parent)
					INSERT INTO EDW.Dim_AppParent (CompanyID, ExeName, AppName, URLMatching)
					SELECT master.CompanyID, master.ExeName, master.AppName, 0 FROM
					(SELECT CompanyID, ExeName, MAX(AppName) AppName 
					FROM edw.Dim_AppMaster
					WHERE Dim_AppParentID IS NULL AND RIGHT(ExeName,4)='.exe'
					GROUP BY CompanyID, ExeName
					) master
					LEFT JOIN edw.Dim_AppParent parent ON master.CompanyID = parent.CompanyID AND master.ExeName = parent.ExeName
					WHERE parent.ID IS NULL


					-- Update AppMaster.Dim_AppParentID with appropriate parent ID
					UPDATE master
					SET Dim_AppParentID = parent.ID
					FROM edw.Dim_AppParent parent
					JOIN edw.Dim_AppMaster master ON parent.CompanyID = parent.CompanyID AND parent.ExeName = master.ExeName
					WHERE master.Dim_AppParentID IS NULL


					SET @MaxAppID = @MaxAppID + @@ROWCOUNT

						IF (@Debug = 100)
						BEGIN
							SET @Step = 'Added new Apps'
							INSERT INTO EDW.Log_Trace([CompanyId], [LogTime], [LogName], [LogDetail], [ElapsedTimeInSeconds])
							VALUES (@CompanyID, GetUTCDate(), @ProcName, @Step, DATEDIFF(SECOND, @ProcStartTime, GetUTCDate()))
						END

						IF (@Debug = 100)
						BEGIN
							SET @Step = 'Set Start and EndTime by SessionID of slots'
							INSERT INTO EDW.Log_Trace ([CompanyId], [LogTime], [LogName], [LogDetail], [ElapsedTimeInSeconds])
							VALUES (@CompanyID, GetUTCDate(), @ProcName, @Step, DATEDIFF(SECOND, @ProcStartTime, GetUTCDate()))
						END


					--************* Updates to #TempTimeSlots. Prep for TimeSlot insert **********
					UPDATE d
					SET d.WebAppName = ap.WebApp, d.IsUrl = 1, d.ActivityCategoryGroupID = s.ActivityCategoryGroupID, d.ActivityCategoryID = s.ActivityCategoryID 
					FROM #TempTimeSlots d
					JOIN EDW.Brdg_AppActivityCategory ap ON CHARINDEX(ap.WebApp, d.data_url) > 0 
					JOIN EDW.Dim_ActivityCategory s ON d.CompanyID = s.CompanyID AND ap.Dim_ActivityCategoryID = s.ID
					WHERE ( d.[data_exeName] in ('chrome.exe', 'iexplore.exe', 'microsoftedge.exe', 'firefox.exe') OR d.[data_fileDescription] in ('Google Chrome') )  
						AND ap.UrlMatching=1

						IF (@Debug = 100)
						BEGIN
							SET @Step = 'Update Browser Url by WebApp'
							INSERT INTO EDW.Log_Trace ([CompanyId], [LogTime], [LogName], [LogDetail], [ElapsedTimeInSeconds])
							VALUES (@CompanyID, GetUTCDate(), @ProcName, @Step, DATEDIFF(SECOND, @ProcStartTime, GetUTCDate()))
						END

					UPDATE d
					SET d.AppID = am.AppID
					FROM #TempTimeSlots d
					JOIN EDW.Dim_AppMaster am ON d.CompanyID = am.CompanyID and d.[WebAppName] = am.AppName and d.IsUrl = 1

						IF (@Debug = 100)
						BEGIN
							SET @Step = 'Update AppIds for WebApp'
							INSERT INTO EDW.Log_Trace ([CompanyId], [LogTime], [LogName], [LogDetail], [ElapsedTimeInSeconds])
							VALUES (@CompanyID, GetUTCDate(), @ProcName, @Step, DATEDIFF(SECOND, @ProcStartTime, GetUTCDate()))
						END

					UPDATE d
					SET d.AppID = am.AppID
					FROM #TempTimeSlots d
					JOIN EDW.Dim_AppMaster am ON d.CompanyID = am.CompanyID and d.[data_fileDescription] = am.AppName and d.[data_exeName] = am.ExeName and d.[data_productversion] = am.AppVersion
					WHERE d.AppID = -1

						IF (@Debug = 100)
						BEGIN
							SET @Step = 'Update Browser Url by WebApp'
							INSERT INTO EDW.Log_Trace([CompanyId], [LogTime], [LogName], [LogDetail], [ElapsedTimeInSeconds])
							VALUES (@CompanyID, GetUTCDate(), @ProcName, @Step, DATEDIFF(SECOND, @ProcStartTime, GetUTCDate()))
						END

					UPDATE d
					SET d.AppID = am.AppID
					FROM #TempTimeSlots d
					JOIN EDW.Dim_AppMaster am ON d.CompanyID = am.CompanyID and d.[data_fileDescription] = am.AppName and d.[data_exeName] = am.ExeName
					WHERE d.AppID = -1

					UPDATE d
					SET d.AppID = am.AppID
					FROM #TempTimeSlots d
					JOIN EDW.Dim_AppMaster am ON d.CompanyID = am.CompanyID and (d.[data_fileDescription] = am.AppName OR d.[data_exeName] = am.ExeName)
					WHERE d.AppID = -1

					UPDATE d
					SET d.AppID = am.AppID
					FROM #TempTimeSlots d
					JOIN EDW.Dim_AppMaster am
						ON d.CompanyID = am.CompanyID AND (CHARINDEX(am.AppName, d.[data_fileDescription]) > 0 OR CHARINDEX(d.[data_fileDescription], am.AppName) > 0 OR CHARINDEX(d.[data_exeName], am.ExeName ) > 0 OR CHARINDEX(am.ExeName, d.[data_exeName]) > 0)  
					WHERE d.AppID = -1

						IF (@Debug = 100)
						BEGIN
							SET @Step = 'Update Other AppIds'
							INSERT INTO EDW.Log_Trace ([CompanyId], [LogTime], [LogName], [LogDetail], [ElapsedTimeInSeconds])
							VALUES (@CompanyID, GetUTCDate(), @ProcName, @Step, DATEDIFF(SECOND, @ProcStartTime, GetUTCDate()))
						END

					UPDATE d
					SET d.[ActivityCategoryGroupID] = ac.ActivityCategoryGroupID, d.ActivityCategoryID = ac.ActivityCategoryID
					from #TempTimeSlots d
					JOIN edw.Dim_AppMaster am on d.CompanyID = am.CompanyID and ( d.[data_exeName] = am.AppName OR d.[data_fileDescription] = am.AppName )
					JOIN edw.Brdg_AppActivityCategory brg ON am.Dim_AppParentID = brg.Dim_AppParentID
					JOIN edw.Dim_ActivityCategory ac ON d.CompanyID = ac.CompanyID AND ac.id = brg.Dim_ActivityCategoryID
					WHERE d.ActivityCategoryID = 100

						IF (@Debug = 100)
						BEGIN
							set @Step = 'Update ActivityCategories'
							INSERT INTO EDW.Log_Trace([CompanyId], [LogTime], [LogName], [LogDetail], [ElapsedTimeInSeconds])
							VALUES (@CompanyID, GetUTCDate(), @ProcName, @Step, DATEDIFF(SECOND, @ProcStartTime, GetUTCDate()))
						END


					-- ***************** EDW.Fact_TimeSlot ***************
					INSERT INTO EDW.Fact_TimeSlot(Dim_CompanyID, [ActivityDate], Dim_UserID ,[DeviceID] , Dim_AppMasterID ,[FileOrUrlName] ,[IsFileOrUrl] ,[PurposeID] ,[Dim_ActivityCategoryID], [IsOnPc] ,[IsActive] ,[IsShift] ,[StartTimeInUTC] ,[ENDTimeInUTC] ,[TimeZoneOffSET] ,[TimeSpent])
					SELECT	t.CompanyID, 
							DATEADD (minute, CASE WHEN ISNUMERIC(t.[TimeZoneOffSET]) > 0 THEN convert(real,t.[TimeZoneOffSET]) * 60.0 ELSE 0 END, t.StartTimeInUTC),
							u.ID, 
							t.DeviceID, 
							ISNULL(am.ID, 100),
							CASE t.IsUrl WHEN 1 THEN t.data_url ELSE t.[data_windowTitle] END, 
							t.IsUrl,
							CASE t.ActivityCategoryID WHEN 100 THEN -1 ELSE 1 END PurposeID,
							ac.ID,
							1 IsOnPc, 
							1 IsActive, 
							0 IsShift, 
							t.StartTimeInUTC, 
							t.ENDTimeInUTC, 
							CASE WHEN ISNUMERIC(t.[TimeZoneOffSET]) > 0 THEN CONVERT(real,t.[TimeZoneOffSET]) * 60.0  ELSE 0 END, ROUND(DATEDIFF(millisecond, t.StartTimeInUTC, t.ENDTimeInUTC)/(1000.0 * 60.0), 4)
					FROM #TempTimeSlots t
					JOIN EDW.Dim_User u ON t.CompanyID = u.CompanyID AND t.UserID = u.UserID
					JOIN edw.Dim_ActivityCategory ac ON t.CompanyID = ac.CompanyID AND t.ActivityCategoryGroupID = ac.ActivityCategoryGroupID AND t.ActivityCategoryID = ac.ActivityCategoryID
					LEFT JOIN EDW.Dim_AppMaster am ON t.CompanyID = am.CompanyID AND t.AppID = am.AppID
					LEFT JOIN EDW.Fact_TimeSlot ts ON u.ID = ts.Dim_UserID AND t.StartTimeInUTC = ts.StartTimeInUTC AND t.ENDTimeInUTC = ts.ENDTimeInUTC
					WHERE ts.Dim_UserID IS NULL


					--******* #TempUsersByActivityDate
					INSERT INTO #TempUsersByActivityDate(CompanyId, Dim_UserID, ActivityDate)
					SELECT DISTINCT t.CompanyId, u.ID, convert(date, DATEADD(minute, convert(real, IsNull(t.Timezoneoffset,0)), t.StartTimeInUTC)) ActivityDate
					FROM #TempTimeSlots t
					JOIN EDW.Dim_User u ON t.CompanyID = u.CompanyID AND t.UserID = u.UserID

						IF (@Debug = 100)
						BEGIN
							SET @Step = '#TempUsersByActivityDate formed'
							INSERT INTO EDW.Log_Trace([CompanyId], [LogTime], [LogName], [LogDetail], [ElapsedTimeInSeconds])
							VALUES (@CompanyID, GetUTCDate(), @ProcName, @Step, DATEDIFF(SECOND, @ProcStartTime, GetUTCDate()))
						END

					--******* #TempChronoTimeSlots
					INSERT INTO #TempChronoTimeSlots (ActivityDate, Dim_UserID, EndTimeInUTC, StartTimeInUTC, LeadStartTimeInUTC)
					SELECT t.ActivityDate, t.Dim_UserID, t.EndTimeInUTC, StartTimeInUTC, LEAD (t.StartTimeInUTC, 1) OVER (PARTITION BY t.ActivityDate, t.Dim_UserID ORDER BY t.StartTimeInUTC) LeadStartTimeInUTC
					FROM EDW.Fact_TimeSlot t 
					JOIN #TempUsersByActivityDate s ON t.Dim_CompanyID = s.CompanyID and t.ActivityDate = s.ActivityDate and t.Dim_UserID = s.Dim_UserID
					WHERE t.Dim_CompanyID = @CompanyID AND t.IsActive = 1

						IF (@Debug = 100)
						BEGIN
							SET @Step = '#TempChronoTimeSlots formed'
							INSERT INTO EDW.Log_Trace ([CompanyId], [LogTime], [LogName], [LogDetail], [ElapsedTimeInSeconds])
							VALUES (@CompanyID, GetUTCDate(), @ProcName, @Step, DATEDIFF(SECOND, @ProcStartTime, GetUTCDate()))
						END

					UPDATE d
					SET d.EndTimeInUTC = s.LeadStartTimeInUTC,
						d.TimeSpent = ROUND(DATEDIFF(millisecond,  d.StartTimeInUTC, s.LeadStartTimeInUTC)/(1000.0 * 60.0),4),
						d.IsActive = case when (d.StartTimeInUTC = s.LeadStartTimeInUTC) then 0 else 1 end
					FROM EDW.Fact_TimeSlot d 
					JOIN #TempChronoTimeSlots s ON d.Dim_UserID = s.Dim_UserID
						AND d.StartTimeInUTC = s.StartTimeInUTC
						AND d.EndTimeInUTC = s.EndTimeInUTC
					WHERE d.Dim_CompanyID = @CompanyID
						AND d.IsActive = 1 
						AND s.LeadStartTimeInUTC IS NOT NULL
						AND (s.EndTimeInUTC > s.LeadStartTimeInUTC OR DATEDIFF(millisecond, s.EndTimeInUTC, s.LeadStartTimeInUTC) between 1 and 300000)

						IF (@Debug = 100)
						BEGIN
							SET @Step = 'EndTime updated by LeadStartTime'
							INSERT INTO EDW.Log_Trace ([CompanyId], [LogTime], [LogName], [LogDetail], [ElapsedTimeInSeconds])
							VALUES (@CompanyID, GetUTCDate(), @ProcName, @Step, DATEDIFF(SECOND, @ProcStartTime, GetUTCDate()))
						END

				END
				--END: @TimeSlotRecordCount > 0


				UPDATE u
				SET u.LastRawTimeSlotProcessedTime = GetUTCDate(), u.LastCreatedRawTimeSlotProcessedID = @EndRawTimeSlotBatchID
				FROM EDW.Log_TimeSlotProcessStatus u
				WHERE u.CompanyID = @CompanyID and u.TimeSlotType = 0


				SET @BeginRawTimeslotBatchID = @ENDRawTimeSlotBatchID + 1
				SET @ENDRawTimeSlotBatchID = (@BatchCount - 1) + @BeginRawTimeslotBatchID

					IF (@ENDRawTimeSlotBatchId > @MaxRawTimeSlotId)
					BEGIN
						SET @ENDRawTimeSlotBatchId = @MaxRawTimeSlotId
					END  

				TRUNCATE TABLE #TempTimeSlots
				TRUNCATE TABLE #TempUsersByActivityDate
				TRUNCATE TABLE #TempChronoTimeSlots

			END
			-- END REG ACTIVITY WHILE

				IF (@Debug = 100)
				BEGIN
					SET @Step = 'Proc Ends. Next scheduled Interval: ' + convert(varchar, @BeginRawTimeslotBatchId) + ' and ' + + convert(varchar, @EndRawTimeSlotBatchId)
					INSERT INTO EDW.Log_Trace ([CompanyId], [LogTime], [LogName], [LogDetail], [ElapsedTimeInSeconds])
					VALUES (@CompanyID, GetUTCDate(), @ProcName, @Step, DATEDIFF(SECOND, @ProcStartTime, GetUTCDate()))
				END

			DROP TABLE #TempTimeSlots
			DROP TABLE #TempUsersByActivityDate
			DROP TABLE #TempChronoTimeSlots


		COMMIT TRANSACTION trans_TimeSlot
	END TRY

	BEGIN CATCH
		IF (@@TRANCOUNT > 0) 
		BEGIN

			ROLLBACK TRANSACTION trans_TimeSlot
			
			--##################### IF ERR, ROLLBACK TRANSACTION ##################
			INSERT INTO edw.Log_Trace(CompanyId, LogTime, LogName, LogDetail, ElapsedTimeInSeconds)
			VALUES (@CompanyID, GetUTCDate(), @ProcName, 'ERROR: ' + ERROR_MESSAGE() + ' (line ' + CAST(ERROR_LINE() AS varchar) + ')', DATEDIFF(SECOND, @ProcStartTime, GetUTCDate()))

			DECLARE 
				@ErrorMessage NVARCHAR(4000),
				@ErrorSeverity INT,
				@ErrorState INT;
			SELECT 
				@ErrorMessage = ERROR_MESSAGE(),
				@ErrorSeverity = ERROR_SEVERITY(),
				@ErrorState = ERROR_STATE();
			RAISERROR (
				@ErrorMessage,
				@ErrorSeverity,
				@ErrorState    
				);
		END
	END CATCH


END
GO
/****** Object:  StoredProcedure [edw].[sproc_CreateTimeSlots_stgLenses]    Script Date: 9/10/2021 8:10:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [edw].[sproc_CreateTimeSlots_stgLenses]
(
    @CompanyID int
	,@Debug tinyint = 0
)
AS
BEGIN
    SET XACT_ABORT, NOCOUNT ON

	BEGIN TRY
		--######################### BEGIN TRANSACTION #####################
		BEGIN TRANSACTION trans_TimeSlot
		
			DECLARE @TimeOutDurationInMinutes int = 5
				,@ProcStartTime datetime = GetUTCDate()
				,@MaxUploadTime datetime = GetUTCDate()
				,@ProcName varchar(100) = 'sproc_AnalyzeTimeSlots'
				,@Step varchar(1024) = ''
				,@TimeSlotRecordCount int = 0
				,@BatchCount int = 100000
				,@OutlookMeetingsAppID integer = -2
				,@MeetingActivityCategoryID integer = 5
				,@LastProcessedRawTimeSlotID bigint = 0
				,@LastRawTimeSlotProcessedTime datetime = NULL
				,@MaxRawTimeSlotId bigint = 0
				,@BeginRawTimeslotBatchId bigint = 0
				,@ENDRawTimeSlotBatchId bigint = 0
				,@RowCount int = 0
				,@MaxAppID int = 0


			CREATE TABLE #TempMeetingTimeSlots
				([CompanyID] [int] NOT NULL,
				[UserID] [int] NOT NULL,
				[ActivityDate] [date] NOT NULL,
				[MeetingID] [nvarchar](512) NOT NULL,
				[MeetingSubject] [nvarchar](512) NOT NULL,
				[MeetingStartTimeUTC] [datetime] NOT NULL,
				[MeetingENDTimeUTC] [datetime] NOT NULL,
				[MeetingStartTimeLocal] [datetime] NOT NULL,
				[MeetingENDTimeLocal] [datetime] NOT NULL,
				[MeetingTimeZoneOffSet] [real] NOT NULL,
				[MeetingDuration] INT NOT NULL,
				[MeetingActivityVersion] [nvarchar](256) NOT NULL,
				[MeetingBusyStatus] [nvarchar](256) NOT NULL,
				[MeetingResponseStatus] [nvarchar](256) NOT NULL,
				[MeetingSensitivity] [nvarchar](256) NOT NULL,
				[Meetingstatus] [nvarchar](256) NOT NULL,
				[IsActive] [bit] NOT NULL,
				[UploadTime] [datetime] NOT NULL 
				)

			CREATE TABLE #FinalMeetingTimeSlots
				([CompanyID] [int] NOT NULL,
				[UserID] [int] NOT NULL,
				[ActivityDate] [date] NOT NULL,
				[MeetingID] [nvarchar](512) NOT NULL,
				[MeetingSubject] [nvarchar](512) NOT NULL,
				[MeetingStartTimeUTC] [datetime] NOT NULL,
				[MeetingENDTimeUTC] [datetime] NOT NULL,
				[MeetingStartTimeLocal] [datetime] NOT NULL,
				[MeetingENDTimeLocal] [datetime] NOT NULL,
				[MeetingTimeZoneOffSet] [real] NOT NULL,
				[MeetingDuration] INT NOT NULL,
				[MeetingActivityVersion] [nvarchar](256) NOT NULL,
				[MeetingBusyStatus] [nvarchar](256) NOT NULL,
				[MeetingResponseStatus] [nvarchar](256) NOT NULL,
				[MeetingSensitivity] [nvarchar](256) NOT NULL,
				[Meetingstatus] [nvarchar](256) NOT NULL,
				[IsActive] [bit] NOT NULL,
				[UploadTime] [datetime] NOT NULL ,
				MeetingRank [int] NOT NULL
				)


			-- ******** #TempMeetingTimeSlots
			INSERT INTO #TempMeetingTimeSlots
			SELECT s.CompanyID, 
			u.UserID,
			CONVERT(date,DATEADD(minute,convert(real,[tzOffSET])*60.0,CONVERT(datetime,LEFT(s.meetingStart, 19)))) ActivityDate,
			MeetingID,
			MeetingSubject,
			meetingStart MeetingStartTimeUTC,
			meetingEnd MeetingENDTimeUTC,
			DATEADD(minute,convert(real,[tzOffSET])*60.0, meetingStart) as MeetingStartTimeLocal,
			DATEADD(minute,convert(real,[tzOffSET])*60.0, meetingEnd) as MeetingEndTimeLocal,
			CONVERT(real,s.[tzOffSET]) * 60.0 MeetingTimeZoneOffSet,
			MeetingDuration,
			MeetingActivityVersion,
			MeetingBusyStatus,
			MeetingResponseStatus,
			MeetingSensitivity,
			MeetingStatus,
			0 IsActive,
			GetDate() UploadTime
			FROM edw.Stg_Lenses s
			JOIN edw.Dim_User u ON s.CompanyID = u.CompanyID AND s.activityDomain = u.DomainName AND s.activityUserID = u.DomainUserID
			WHERE activityType ='Meeting' AND s.CompanyID=@CompanyID
				AND (meetingActivityVersion IS NULL OR meetingActivityVersion <> '0.1.0')


			-- ******** #FinalMeetingTimeSlots
			INSERT INTO #FinalMeetingTimeSlots
			SELECT * FROM
				(SELECT k.CompanyID,k.UserID,k.ActivityDate
						,MeetingID,MeetingSubject,MeetingStartTimeUTC,MeetingENDTimeUTC
						,MeetingStartTimeLocal,MeetingENDTimeLocal,MeetingTimeZoneOffSet
						,MeetingDuration,MeetingActivityVersion,MeetingBusyStatus,MeetingResponseStatus
						,MeetingSensitivity,MeetingStatus,IsActive,UploadTime
						,ROW_NUMBER() OVER (PARTITION BY k.CompanyID,k.UserID,k.ActivityDate,k.MeetingID ORDER BY UploadTime DESC) MeetingRank 
				FROM #TempMeetingTimeSlots k
				WHERE DATEDIFF(minute,MeetingStartTimeLocal,MeetingENDTimeLocal) = MeetingDuration		
				) s
			WHERE s.MeetingRank = 1
	
			UPDATE #FinalMeetingTimeSlots
			SET IsActive = 1
			WHERE CompanyID = @CompanyID
				AND MeetingDuration < 720
				AND [MeetingbusyStatus] in ('olBusy','olWorkingELSEWHERE')
				AND [MeetingresponseStatus] in ('olResponseAccepted','olResponseOrganized')
				AND [Meetingsensitivity] in ('olNormal')
				AND [Meetingstatus] in ('olMeeting', 'olMeetingReceived')


			-- ********** UPDATE EDW.Fact_TimeSlotMeeting *********
			UPDATE a
			SET a.MeetingStartTimeUTC = t.MeetingStartTimeUTC,
				a.MeetingENDTimeUTC = t.MeetingENDTimeUTC,
				a.MeetingStartTimeLocal = t.MeetingStartTimeLocal,
				a.MeetingENDTimeLocal = t.MeetingENDTimeLocal,
				a.MeetingTimeZoneOffSet = t.MeetingTimeZoneOffSet,
				a.MeetingDuration = t.MeetingDuration,
				a.MeetingbusyStatus = t.MeetingbusyStatus,
				a.MeetingresponseStatus = t.MeetingresponseStatus,
				a.Meetingsensitivity = t.Meetingsensitivity,
				a.Meetingstatus = t.Meetingstatus,
				a.IsActive = t.IsActive,
				a.UploadTime = t.UploadTime
			FROM EDW.Fact_TimeSlotMeeting a
			JOIN EDW.Dim_User u ON a.Dim_UserID = u.ID
			JOIN #FinalMeetingTimeSlots t
				ON u.CompanyID = t.CompanyID AND u.UserID = t.UserID AND a.ActivityDate = t.ActivityDate AND a.MeetingID = t.MeetingID


			-- ********** INSERT EDW.Fact_TimeSlotMeeting *********
			INSERT INTO EDW.Fact_TimeSlotMeeting ([Dim_CompanyID],[Dim_UserID],[ActivityDate],[MeetingID],[MeetingSubject],[MeetingStartTimeUTC],[MeetingENDTimeUTC],[MeetingStartTimeLocal],[MeetingENDTimeLocal], [MeetingTimeZoneOffSet],[MeetingDuration],[MeetingbusyStatus],[MeetingresponseStatus],[Meetingsensitivity],[Meetingstatus],[IsActive],[UploadTime]) 
			SELECT p.CompanyID, u.ID, p.ActivityDate, p.MeetingID, p.MeetingSubject, p.MeetingStartTimeUTC, p.MeetingENDTimeUTC, p.MeetingStartTimeLocal, p.MeetingENDTimeLocal, p.MeetingTimeZoneOffSet, p.MeetingDuration,p.MeetingbusyStatus,p.MeetingresponseStatus,p.Meetingsensitivity,p.Meetingstatus,p.IsActive,GetUTCDate()
			FROM #FinalMeetingTimeSlots p
			JOIN EDW.Dim_User u ON p.UserID = u.UserID AND p.CompanyID = u.CompanyID
			LEFT JOIN EDW.Fact_TimeSlotMeeting tsm ON p.CompanyID = u.CompanyID
				AND p.UserID = u.UserID
				AND p.MeetingStartTimeUTC = tsm.MeetingStartTimeUTC
				AND p.MeetingEndTimeUTC = tsm.MeetingEndTimeUTC
				AND p.MeetingID = tsm.MeetingID
			WHERE tsm.Dim_UserID IS NULL


			-- ******* UPDATE Log_TimeSlotProcessStatus 'TimeSlot'
			UPDATE d
			SET d.LastTimeSlotProcessedTime = GETUTCDATE()
				--d.LastCreatedTimeSlotID = @LastCreatedTimeSlotID,
			FROM EDW.Log_TimeSlotProcessStatus d
			WHERE d.CompanyID = @CompanyID AND d.TimeSlotType = 1


			-- ******* UPDATE Log_TimeSlotProcessStatus 'RawTimeSlot'
			UPDATE u
			SET u.LastRawTimeSlotProcessedTime = GetUTCDate(), u.LastCreatedRawTimeSlotProcessedID = @EndRawTimeSlotBatchID
			FROM EDW.Log_TimeSlotProcessStatus u
			WHERE u.CompanyID = @CompanyID and u.TimeSlotType = 1	


			TRUNCATE TABLE #FinalMeetingTimeSlots
			TRUNCATE TABLE #TempMeetingTimeSlots

			SET @BeginRawTimeslotBatchID = @ENDRawTimeSlotBatchID + 1
			SET @ENDRawTimeSlotBatchID = (@BatchCount - 1) + @BeginRawTimeslotBatchID

			IF (@ENDRawTimeSlotBatchId > @MaxRawTimeSlotId)
			BEGIN
				SET @ENDRawTimeSlotBatchId = @MaxRawTimeSlotId
			END 


			DROP TABLE #FinalMeetingTimeSlots
			DROP TABLE #TempMeetingTimeSlots


			-- ******************************************* END: MEETING PROCESSING / START: REG ACTIVITY PROCESSING *****************************************

			CREATE TABLE #TempTimeSlots
				([CompanyID] [integer]
				,[UserID] [integer]		
				,[StartTimeInUTC] [datetime] 
				,[ENDTimeInUTC] [datetime]
				,[TimeZoneOffset] [nvarchar] (512)
				,[data_sessionid] [nvarchar] (4000)
				,[data_productversion] [nvarchar] (512)
				,[data_fileDescription] [nvarchar] (2048)
				,[data_exeName] [nvarchar] (2048)
				,[data_activity_domain] [nvarchar] (512)
				,[data_activity_userId] [nvarchar] (512)
				,[DeviceID] [integer]
				,[data_windowTitle] [nvarchar] (4000)
				,[data_subWindowTitle] [nvarchar] (4000) default ('')
				,[data_url] [nvarchar] (4000)
				,[AppID] [integer] default (-1)
				,[ActivityCategoryGroupID] [integer] default (1)
				,[ActivityCategoryID] [integer]  default (100)
				,IsUrl bit default(0)
				,WebAppName [nvarchar] (4000) default ('')
				) 

			CREATE TABLE #TempUsersByActivityDate 
				(CompanyId integer, 
				Dim_UserID integer, 
				ActivityDate Date
				)

			CREATE TABLE #TempChronoTimeSlots
				([ActivityDate] date NOT NULL,
				[Dim_UserID] integer NOT NULL,
				[EndTimeInUTC] [datetime] NOT NULL, 
				[StartTimeInUTC] [datetime] NOT NULL, 
				[LeadStartTimeInUTC] [datetime] NULL 
				)
	
			SELECT @MaxAppID = IsNull(MAX(a.AppID),0) 
			FROM EDW.Dim_AppMaster a 
			WHERE a.CompanyID = @CompanyID


			INSERT INTO #TempTimeSlots([CompanyID] ,[UserID] , [data_sessionid] ,[TimeZoneOffset] , [data_productversion], [data_fileDescription], [data_exeName] ,[data_activity_domain], [data_activity_userId] ,[DeviceID] ,[data_windowTitle], [data_url], [StartTimeInUTC]  ,[ENDTimeInUTC] )
			SELECT 
			a.CompanyID,
			s.UserID,
			sessionId,
			tzoffset,
			productVersion,
			fileDescription,
			exeName,
			activityDomain,
			activityUserID,
			0 DeviceID,
			windowTitle,
			url,
			MIN(activityTime) StartTime,
			DATEADD(second, 15, MAX(a.activityTime)) EndTime
			FROM edw.Stg_Lenses a
			JOIN edw.Dim_User s ON a.CompanyID = s.CompanyID AND a.activityDomain = s.DomainName AND a.activityUserID = s.DomainUserID
			WHERE activityType='Application'
			GROUP BY a.CompanyID, s.UserID, sessionId, tzoffset, productVersion, fileDescription, exeName, activityDomain, activityUserID, windowTitle, url

			SET @TimeSlotRecordCount = @@ROWCOUNT
	

			IF (@TimeSlotRecordCount > 0)
			--BEGIN: @TimeSlotRecordCount > 0
			BEGIN

				SET @MaxAppID = @MaxAppID + @@ROWCOUNT

				--************* Updates to #TempTimeSlots. Prep for TimeSlot insert **********
				UPDATE d
				SET d.WebAppName = ap.WebApp, d.IsUrl = 1, d.ActivityCategoryGroupID = s.ActivityCategoryGroupID, d.ActivityCategoryID = s.ActivityCategoryID 
				FROM #TempTimeSlots d
				JOIN EDW.Brdg_AppActivityCategory ap ON CHARINDEX(ap.WebApp, d.data_url) > 0 
				JOIN EDW.Dim_ActivityCategory s ON d.CompanyID = s.CompanyID AND ap.Dim_ActivityCategoryID = s.ID
				WHERE ap.UrlMatching=1

				UPDATE d
				SET d.AppID = am.AppID
				FROM #TempTimeSlots d
				JOIN EDW.Dim_AppMaster am ON d.CompanyID = am.CompanyID and d.[WebAppName] = am.AppName and d.IsUrl = 1

				UPDATE d
				SET d.AppID = am.AppID
				FROM #TempTimeSlots d
				JOIN EDW.Dim_AppMaster am ON d.CompanyID = am.CompanyID and d.[data_fileDescription] = am.AppName and d.[data_exeName] = am.ExeName and d.[data_productversion] = am.AppVersion
				WHERE d.AppID = -1

				UPDATE d
				SET d.AppID = am.AppID
				FROM #TempTimeSlots d
				JOIN EDW.Dim_AppMaster am ON d.CompanyID = am.CompanyID and d.[data_fileDescription] = am.AppName and d.[data_exeName] = am.ExeName
				WHERE d.AppID = -1

				UPDATE d
				SET d.AppID = am.AppID
				FROM #TempTimeSlots d
				JOIN EDW.Dim_AppMaster am ON d.CompanyID = am.CompanyID and (d.[data_fileDescription] = am.AppName OR d.[data_exeName] = am.ExeName)
				WHERE d.AppID = -1

				UPDATE d
				SET d.AppID = am.AppID
				FROM #TempTimeSlots d
				JOIN EDW.Dim_AppMaster am
					ON d.CompanyID = am.CompanyID AND (CHARINDEX(am.AppName, d.[data_fileDescription]) > 0 OR CHARINDEX(d.[data_fileDescription], am.AppName) > 0 OR CHARINDEX(d.[data_exeName], am.ExeName ) > 0 OR CHARINDEX(am.ExeName, d.[data_exeName]) > 0)  
				WHERE d.AppID = -1

				UPDATE d
				SET d.[ActivityCategoryGroupID] = ac.ActivityCategoryGroupID, d.ActivityCategoryID = ac.ActivityCategoryID
				from #TempTimeSlots d
				JOIN edw.Dim_AppMaster am on d.CompanyID = am.CompanyID and ( d.[data_exeName] = am.AppName OR d.[data_fileDescription] = am.AppName )
				JOIN edw.Brdg_AppActivityCategory brg ON am.Dim_AppParentID = brg.Dim_AppParentID
				JOIN edw.Dim_ActivityCategory ac ON d.CompanyID = ac.CompanyID AND ac.id = brg.Dim_ActivityCategoryID
				WHERE d.ActivityCategoryID = 100


				-- ***************** EDW.Fact_TimeSlot ***************
				INSERT INTO EDW.Fact_TimeSlot(Dim_CompanyID, [ActivityDate], Dim_UserID ,[DeviceID] , Dim_AppMasterID ,[FileOrUrlName] ,[IsFileOrUrl] ,[PurposeID] ,[Dim_ActivityCategoryID], [IsOnPc] ,[IsActive] ,[IsShift] ,[StartTimeInUTC] ,[ENDTimeInUTC] ,[TimeZoneOffSET] ,[TimeSpent])
				SELECT	t.CompanyID, 
						DATEADD (minute, CASE WHEN ISNUMERIC(t.[TimeZoneOffSET]) > 0 THEN convert(real,t.[TimeZoneOffSET]) * 60.0 ELSE 0 END, t.StartTimeInUTC),
						u.ID, 
						t.DeviceID, 
						ISNULL(am.ID, 100),
						CASE t.IsUrl WHEN 1 THEN t.data_url ELSE t.[data_windowTitle] END, 
						t.IsUrl,
						CASE t.ActivityCategoryID WHEN 100 THEN -1 ELSE 1 END PurposeID,
						ac.ID,
						1 IsOnPc, 
						1 IsActive, 
						0 IsShift, 
						t.StartTimeInUTC, 
						t.ENDTimeInUTC, 
						CASE WHEN ISNUMERIC(t.[TimeZoneOffSET]) > 0 THEN CONVERT(real,t.[TimeZoneOffSET]) * 60.0  ELSE 0 END, ROUND(DATEDIFF(millisecond, t.StartTimeInUTC, t.ENDTimeInUTC)/(1000.0 * 60.0), 4)
				FROM #TempTimeSlots t
				JOIN EDW.Dim_User u ON t.CompanyID = u.CompanyID AND t.UserID = u.UserID
				JOIN edw.Dim_ActivityCategory ac ON t.CompanyID = ac.CompanyID AND t.ActivityCategoryGroupID = ac.ActivityCategoryGroupID AND t.ActivityCategoryID = ac.ActivityCategoryID
				LEFT JOIN EDW.Dim_AppMaster am ON t.CompanyID = am.CompanyID AND t.AppID = am.AppID
				LEFT JOIN EDW.Fact_TimeSlot ts ON u.ID = ts.Dim_UserID AND t.StartTimeInUTC = ts.StartTimeInUTC AND t.ENDTimeInUTC = ts.ENDTimeInUTC
				WHERE ts.Dim_UserID IS NULL


				--******* #TempUsersByActivityDate
				INSERT INTO #TempUsersByActivityDate(CompanyId, Dim_UserID, ActivityDate)
				SELECT DISTINCT t.CompanyId, u.ID, convert(date, DATEADD(minute, convert(real, IsNull(t.Timezoneoffset,0)), t.StartTimeInUTC)) ActivityDate
				FROM #TempTimeSlots t
				JOIN EDW.Dim_User u ON t.CompanyID = u.CompanyID AND t.UserID = u.UserID


				--******* #TempChronoTimeSlots
				INSERT INTO #TempChronoTimeSlots (ActivityDate, Dim_UserID, EndTimeInUTC, StartTimeInUTC, LeadStartTimeInUTC)
				SELECT t.ActivityDate, t.Dim_UserID, t.EndTimeInUTC, StartTimeInUTC, LEAD (t.StartTimeInUTC, 1) OVER (PARTITION BY t.ActivityDate, t.Dim_UserID ORDER BY t.StartTimeInUTC) LeadStartTimeInUTC
				FROM EDW.Fact_TimeSlot t 
				JOIN #TempUsersByActivityDate s ON t.Dim_CompanyID = s.CompanyID and t.ActivityDate = s.ActivityDate and t.Dim_UserID = s.Dim_UserID
				WHERE t.Dim_CompanyID = @CompanyID AND t.IsActive = 1


				UPDATE d
				SET d.EndTimeInUTC = s.LeadStartTimeInUTC,
					d.TimeSpent = ROUND(DATEDIFF(millisecond,  d.StartTimeInUTC, s.LeadStartTimeInUTC)/(1000.0 * 60.0),4),
					d.IsActive = case when (d.StartTimeInUTC = s.LeadStartTimeInUTC) then 0 else 1 end
				FROM EDW.Fact_TimeSlot d 
				JOIN #TempChronoTimeSlots s ON d.Dim_UserID = s.Dim_UserID
					AND d.StartTimeInUTC = s.StartTimeInUTC
					AND d.EndTimeInUTC = s.EndTimeInUTC
				WHERE d.Dim_CompanyID = @CompanyID
					AND d.IsActive = 1 
					AND s.LeadStartTimeInUTC IS NOT NULL
					AND (s.EndTimeInUTC > s.LeadStartTimeInUTC OR DATEDIFF(millisecond, s.EndTimeInUTC, s.LeadStartTimeInUTC) between 1 and 300000)

			END
			--END: @TimeSlotRecordCount > 0


			DROP TABLE #TempTimeSlots
			DROP TABLE #TempUsersByActivityDate
			DROP TABLE #TempChronoTimeSlots


		COMMIT TRANSACTION trans_TimeSlot
	END TRY

	BEGIN CATCH
		IF (@@TRANCOUNT > 0) 
		BEGIN

			ROLLBACK TRANSACTION trans_TimeSlot
			
			--##################### IF ERR, ROLLBACK TRANSACTION ##################
			DECLARE 
				@ErrorMessage NVARCHAR(4000),
				@ErrorSeverity INT,
				@ErrorState INT;
			SELECT 
				@ErrorMessage = ERROR_MESSAGE(),
				@ErrorSeverity = ERROR_SEVERITY(),
				@ErrorState = ERROR_STATE();
			RAISERROR (
				@ErrorMessage,
				@ErrorSeverity,
				@ErrorState    
				);
		END
	END CATCH


END
GO
/****** Object:  StoredProcedure [edw].[sproc_CustomFields_Views_Generator]    Script Date: 9/10/2021 8:10:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [edw].[sproc_CustomFields_Views_Generator]
AS

  BEGIN
	SET NOCOUNT ON

	DECLARE @strCols AS NVARCHAR(500), @realCols AS NVARCHAR(500), @dateCols AS NVARCHAR(500), @boolCols AS NVARCHAR(500), @allCols AS NVARCHAR(500)
	DECLARE @counter INT=1, @companyID INT, @companyUserField INT, @strCompanyID VARCHAR(10), @strQuery VARCHAR(3000)

	SELECT @strcols = STUFF((SELECT ',' + QUOTENAME(Name) 
				FROM edw.Dim_Field f
				JOIN edw.Dim_Settings s ON f.Dim_SettingID = s.ID
				JOIN edw.Dim_DataType dt ON f.Dim_DataTypeID = dt.ID
				WHERE SettingName='Admin - User Custom Field' AND DataType='String'
				group by f.Name, f.ID
				order by f.ID
		FOR XML PATH(''), TYPE
		).value('.', 'NVARCHAR(MAX)') 
	,1,1,'')

	SELECT @realCols = STUFF((SELECT ',' + QUOTENAME(Name) 
				FROM edw.Dim_Field f
				JOIN edw.Dim_Settings s ON f.Dim_SettingID = s.ID
				JOIN edw.Dim_DataType dt ON f.Dim_DataTypeID = dt.ID
				WHERE SettingName='Admin - User Custom Field' AND DataType='Float'
				group by f.Name, f.ID
				order by f.ID
		FOR XML PATH(''), TYPE
		).value('.', 'NVARCHAR(MAX)') 
	,1,1,'')

	SELECT @dateCols = STUFF((SELECT ',' + QUOTENAME(Name) 
				FROM edw.Dim_Field f
				JOIN edw.Dim_Settings s ON f.Dim_SettingID = s.ID
				JOIN edw.Dim_DataType dt ON f.Dim_DataTypeID = dt.ID
				WHERE SettingName='Admin - User Custom Field' AND DataType='DateTime'
				group by f.Name, f.ID
				order by f.ID
		FOR XML PATH(''), TYPE
		).value('.', 'NVARCHAR(MAX)') 
	,1,1,'')

	SELECT @boolCols = STUFF((SELECT ',' + QUOTENAME(Name) 
				FROM edw.Dim_Field f
				JOIN edw.Dim_Settings s ON f.Dim_SettingID = s.ID
				JOIN edw.Dim_DataType dt ON f.Dim_DataTypeID = dt.ID
				WHERE SettingName='Admin - User Custom Field' AND DataType='Boolean'
				group by f.Name, f.ID
				order by f.ID
		FOR XML PATH(''), TYPE
		).value('.', 'NVARCHAR(MAX)') 
	,1,1,'')

	SELECT @allCols = STUFF((SELECT ',' + QUOTENAME(Name) 
				FROM edw.Dim_Field f
				JOIN edw.Dim_Settings s ON f.Dim_SettingID = s.ID
				JOIN edw.Dim_DataType dt ON f.Dim_DataTypeID = dt.ID
				WHERE SettingName='Admin - User Custom Field'
				group by f.Name, f.ID
				order by f.ID
		FOR XML PATH(''), TYPE
		).value('.', 'NVARCHAR(MAX)') 
	,1,1,'')


	SELECT * INTO #company 
	FROM
	(SELECT ROW_NUMBER() OVER(ORDER BY CompanyID) ID, CompanyID FROM edw.Dim_Company) cid
	LEFT JOIN (SELECT DISTINCT u.CompanyID CompanyUserField FROM EDW.Brdg_UserField uf
				JOIN edw.Dim_User u ON uf.Dim_UserID=u.ID) brdg ON cid.CompanyID = brdg.CompanyUserField


	WHILE @counter<=(SELECT MAX(ID) FROM #company)
	BEGIN
		SELECT @companyID=CompanyID, @strCompanyID=CAST(CompanyID AS varchar(10)), @companyUserField=CompanyUserField FROM #company WHERE ID=@counter

		IF @companyUserField IS NULL
		  BEGIN
			SET @strQuery = 
			'CREATE OR ALTER VIEW [edw].[View_User_CustomFields_' + @strCompanyID + '] AS
			SELECT CompanyID, UserID FROM edw.Dim_User WHERE CompanyID=' + @strCompanyID

			EXEC (@strQuery)
		  END
		ELSE
		  BEGIN
			SET @strQuery = 
			'------------------------------------ Strings
			CREATE OR ALTER VIEW [edw].[View_User_CustomFields_' + @strCompanyID + '] AS 
		
			SELECT usr.CompanyID, usr.UserID,' + @allCols + ' 
			FROM 
		
			(SELECT * FROM edw.dim_user WHERE CompanyID=' + @strCompanyID + ') usr 
			LEFT JOIN
			(select * from
					(select * from
						(select u.CompanyID, u.ID, u.UserID, StringValue, f.Name from edw.Brdg_UserField brdg
						join edw.Dim_Field f ON brdg.Dim_FieldID = f.ID
						JOIN edw.Dim_User u ON brdg.Dim_UserID = u.ID
						WHERE u.CompanyID = ' + @strCompanyID + '
						) base
						PIVOT
						(
						MAX(StringValue)
						FOR Name IN (' + COALESCE(@strCols,'[Not Applicable]') + ')
					) StringResults
				) sr
			) strings ON usr.ID = strings.ID 

			FULL JOIN ---------------------------- Dates
			(select * from
				(select * from
					(select u.CompanyID, u.UserID, DateTimeValue, f.Name from edw.Brdg_UserField brdg
					join edw.Dim_Field f ON brdg.Dim_FieldID = f.ID
					JOIN edw.Dim_User u ON brdg.Dim_UserID = u.ID
					WHERE u.CompanyID = ' + @strCompanyID + '
					) base 
					PIVOT
					(
					MAX(DateTimeValue)
					FOR Name IN (' + COALESCE(@dateCols,'[Not Applicable]') + ')
				) as DateTimeResults
			) dtr 
			) datetimes ON strings.CompanyID = datetimes.CompanyID AND strings.UserID = datetimes.UserID

			FULL JOIN ----------------------------- Floats
			(select * from
				(select * from
					(select u.CompanyID, u.UserID, NumericValue, f.Name from edw.Brdg_UserField brdg
					join edw.Dim_Field f ON brdg.Dim_FieldID = f.ID
					JOIN edw.Dim_User u ON brdg.Dim_UserID = u.ID
					WHERE u.CompanyID = ' + @strCompanyID + '
					) base
					PIVOT
					(
					MAX(NumericValue)
					FOR Name IN (' + COALESCE(@realCols,'[Not Applicable]') + ')
				) as FloatResults
			) fr 
			) floats ON strings.CompanyID = floats.CompanyID AND strings.UserID = floats.UserID

			FULL JOIN ------------------------------- Bools
			(
			select * from
				(select * from
					(select u.CompanyID, u.UserID, CAST(BooleanValue AS tinyint) BoolAsInt, f.Name from edw.Brdg_UserField brdg
					join edw.Dim_Field f ON brdg.Dim_FieldID = f.ID
					JOIN edw.Dim_User u ON brdg.Dim_UserID = u.ID
					WHERE u.CompanyID = ' + @strCompanyID + '
					) base
					PIVOT
					(
					MAX(BoolAsInt)
					FOR Name IN (' + COALESCE(@boolCols,'[Not Applicable]') + ')
				) as BooleanResults
			) br
			) bools ON strings.CompanyID = bools.CompanyID AND strings.UserID = bools.UserID
			'

			EXEC (@strQuery)
		  END

		SET @counter=@counter+1
	END

	DROP TABLE #company


  END
GO
/****** Object:  StoredProcedure [edw].[sproc_DataTransferScript]    Script Date: 9/10/2021 8:10:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [edw].[sproc_DataTransferScript]
(
		 @StartDate date
	    ,@EndDate   date
		,@SourceCompanyID int
		,@DestinationCompanyID int
	
)
AS
BEGIN
		
		Declare @LastProcessDate Date


	Select @LastProcessDate = max(ActivityDate) from [edw].[Fact_DailyUser] Where Dim_CompanyID = @DestinationCompanyID

		if @LastProcessDate < @StartDate
			BEGIN

			
			Select ID,CompanyID,LOWER(SUBSTRING(Useremail, 0, (CHARINDEX('@',Useremail)))) Email,UserID INTO #DestUser from EDW.Dim_User wHERE CompanyID = @DestinationCompanyID


			Select ID,CompanyID,LOWER(SUBSTRING(Useremail, 0, (CHARINDEX('@',Useremail)))) Email,UserID INTO #SourceUser from EDW.Dim_User wHERE CompanyID = @SourceCompanyID


			ALTER TABLE #DestUser
			ADD SourceID INt;
			
				UPDATE #DestUser  SET
				#DestUser.SourceID = RAN.ID
				FROM
				#DestUser SI
				INNER JOIN
				#SourceUser RAN
				ON 
				SI.Email = RAN.Email;



			 ---- App_Parent

			---Select * INTO #App_Parent from edw.Dim_AppParent Where CompanyID = @SourceCompanyID
			---
			---
			---
			---MERGE edw.Dim_AppParent T
			---USING #App_Parent S ON T.CompanyID = @DestinationCompanyID AND T.ExeName = S.ExeName AND T.AppName = S.AppName
			---WHEN NOT MATCHED BY TARGET 
			---THEN 
			---INSERT (CompanyID,ExeName,AppName,WebApp,URLMatching)
			---VALUES (@DestinationCompanyID, ExeName,AppName,WebApp,URLMatching);


			---- AppMaster and ActivityCategory

			Select * INTO #App_Master from edw.Dim_AppMaster Where CompanyID = @SourceCompanyID

			MERGE edw.Dim_AppMaster T
			USING #App_Master S ON T.CompanyID = @DestinationCompanyID AND T.ExeName = S.ExeName AND T.AppName = S.AppName AND T.AppVersion = S.AppVersion
			WHEN NOT MATCHED BY TARGET 
			THEN 
			INSERT (Dim_AppParentID,CompanyID,AppID,ExeName,AppName,AppVersion,IsApplication,IsOffline,AppSpecPlatformID,Dim_PlatformID)
			VALUES (Dim_AppParentID,@DestinationCompanyID, AppID, ExeName, AppName,AppVersion,IsApplication,IsOffline,AppSpecPlatformID,Dim_PlatformID);
		
		
		
			Select * INTO #DestApp_Master from edw.Dim_AppMaster Where CompanyID = @DestinationCompanyID
			
			
			Alter Table #DestApp_Master
			ADD SourceID INT;
			
			UPDATE T1
			SET T1.SourceID = T2.ID
			FROM #DestApp_Master T1
			INNER JOIN #App_Master T2
			ON (T1.ExeName = T2.ExeName AND T1.AppName = T2.AppName AND T1.AppVersion = T2.AppVersion);
			
			----
			
			Select * INTO #ActivityCategory from  edw.Dim_ActivityCategory Where CompanyID = @SourceCompanyID
			
		    MERGE edw.Dim_ActivityCategory T
			USING #ActivityCategory S ON T.CompanyID = @DestinationCompanyID AND T.ActivityCategoryName = S.ActivityCategoryName AND T.ActivityCategoryID = S.ActivityCategoryID
			WHEN NOT MATCHED BY TARGET 
			THEN 
			INSERT (CompanyID,ActivityCategoryID,
			ActivityCategoryName,IsCore,IsSystemDefined,IsActive,IsWorkCategory,IsDefault)
			VALUES (@DestinationCompanyID,ActivityCategoryID,
			ActivityCategoryName,IsCore,IsSystemDefined,IsActive,IsWorkCategory,IsDefault);
			
			
	

			Select * INTO #DestActivityCategory from  edw.Dim_ActivityCategory Where CompanyID = @DestinationCompanyID
			
			
			Alter Table #DestActivityCategory
			ADD SourceID INT;
			
			UPDATE T1
			SET T1.SourceID = T2.ID
			FROM #DestActivityCategory T1
			INNER JOIN #ActivityCategory T2
			ON (T1.ActivityCategoryName = T2.ActivityCategoryName AND T1.ActivityCategoryID = T2.ActivityCategoryID);
			
			----
			
		-----------------	Select * INTO #TempAppParent from [edw].[Dim_AppParent] Where CompanyID = @SourceCompanyID
		-----------------	
		-----------------    MERGE [edw].[Dim_AppParent] T
		-----------------	USING #TempAppParent S ON T.ExeName = S.ExeName AND T.AppName = S.AppName
		-----------------	WHEN NOT MATCHED BY TARGET 
		-----------------	THEN 
		-----------------	INSERT ([CompanyID],[ExeName],[AppName],[Dim_ActivityCategoryID],[WebApp],[URLMatching])
		-----------------	VALUES (@DestinationCompanyID,[ExeName],[AppName],null,[WebApp],[URLMatching]);
		-----------------	
		-----------------	
		-----------------	Select * INTO #DestTempAppParent from [edw].[Dim_AppParent] Where CompanyID = @DestinationCompanyID
		-----------------	
		-----------------	
		-----------------	Alter Table #DestTempAppParent
		-----------------	ADD SourceID INT;
		-----------------	
		-----------------	UPDATE T1
		-----------------	SET T1.SourceID = T2.ID
		-----------------	FROM #DestTempAppParent T1
		-----------------	INNER JOIN #TempAppParent T2
		-----------------	ON (T1.[ExeName] = T2.[ExeName] AND T1.[AppName] = T2.[AppName]);
		-----------------
			-------------
			----------------Alter Table #DestApp_Master
			----------------ADD DestDim_AppParentID INT;
			----------------
			----------------
			----------------	UPDATE T1
			----------------SET T1.DestDim_AppParentID = T2.ID
			----------------FROM #DestApp_Master T1
			----------------INNER JOIN #DestTempAppParent T2
			----------------ON (T1.[Dim_AppParentID] = T2.[SourceID]);
			----------------
			---------------- Fact_TimeSlot
		    Select a.*,b.ID,b.CompanyID INTO #TempTimeSlot From edw.Fact_TimeSlot a 
			INNER JOIN (Select * from #DestUser Where SourceID is not null) b
			On(a.Dim_UserID = b.SourceID AND ActivityDate Between @StartDate And @EndDate)
			
			
			INSERT INTO edw.Fact_TimeSlot
			(Dim_UserID,Dim_CompanyID,Dim_AppMasterID,Dim_ActivityCategoryID,Dim_DeviceID,ActivityDate,DeviceID,FileOrUrlName,IsFileOrUrl
			,PurposeID,IsOnPc,IsShift,StartTimeInUTC,EndTimeInUTC,TimeZoneOffset,IsActive,TimeSpent,UploadTime,IsUserModified,ModifiedBy)
			Select a.ID, a.CompanyID, b.ID,c.ID,a.Dim_DeviceID,a.ActivityDate,a.DeviceID,a.FileOrUrlName,a.IsFileOrUrl
			,a.PurposeID,a.IsOnPc,a.IsShift,a.StartTimeInUTC,a.EndTimeInUTC,a.TimeZoneOffset,a.IsActive,a.TimeSpent,a.UploadTime,a.IsUserModified,null from
			#TempTimeSlot a
			inner Join #DestApp_Master b ON a.Dim_AppMasterID = b.SourceID
			inner join #DestActivityCategory c ON a.Dim_ActivityCategoryID = c.SourceID
			
				
			 ---Fact_TimeSlotMeeting
			Select a.*,b.ID,b.CompanyID INTO #TempTimeSlotMeeting From edw.Fact_TimeSlotMeeting a 
			INNER JOIN (Select * from #DestUser Where SourceID is not null) b
			On(a.Dim_UserID = b.SourceID AND ActivityDate Between @StartDate And @EndDate)
			
			INSERT INTO edw.Fact_TimeSlotMeeting
			(Dim_UserID,Dim_CompanyID,Dim_DeviceID,ActivityDate,MeetingID,MeetingSubject,MeetingStartTimeUTC,MeetingEndTimeUTC,MeetingStartTimeLocal
			,MeetingEndTimeLocal,MeetingTimeZoneOffSet,MeetingDuration,MeetingBusyStatus,MeetingResponseStatus,MeetingSensitivity,Meetingstatus
			,IsActive,UploadTime)
			Select ID, CompanyID,Dim_DeviceID,ActivityDate,MeetingID,MeetingSubject,MeetingStartTimeUTC,MeetingEndTimeUTC,MeetingStartTimeLocal
			,MeetingEndTimeLocal,MeetingTimeZoneOffSet,MeetingDuration,MeetingBusyStatus,MeetingResponseStatus,MeetingSensitivity,Meetingstatus
			,IsActive,UploadTime From #TempTimeSlotMeeting 
			
			
	

			--- Fact_dailyActivity
			Select a.*,b.ID,b.CompanyID INTO #TempFact_DailyActivity From edw.Fact_DailyActivity a 
			INNER JOIN (Select * from #DestUser Where SourceID is not null) b
			On(a.Dim_UserID = b.SourceID AND ActivityDate Between @StartDate And @EndDate)
			
			INSERT INTO edw.Fact_DailyActivity
			(Dim_UserID,Dim_CompanyID,ActivityDate,Dim_DeviceID,Dim_AppMasterID,Dim_ActivityCategoryID
			,FileOrUrlID,IsFileOrUrl,PurposeID,IsOnPc,TimeSpentInCalendarDay,TimeSpentInShift)
			Select a.ID, a.CompanyID, a.ActivityDate,a.Dim_DeviceID,b.ID,c.ID
			,a.FileOrUrlID,a.IsFileOrUrl,a.PurposeID,a.IsOnPc,a.TimeSpentInCalendarDay,a.TimeSpentInShift From 
			#TempFact_DailyActivity a
			inner Join #DestApp_Master b ON (a.Dim_AppMasterID = b.SourceID)
			inner join #DestActivityCategory c ON (a.Dim_ActivityCategoryID = c.SourceID) 
			

	
		--- Fact_DailyUser
			Select a.*,b.ID,b.CompanyID INTO #TempFact_DailyUser From edw.Fact_DailyUser a 
			INNER JOIN (Select * from #DestUser Where SourceID is not null) b
			On(a.Dim_UserID = b.SourceID AND ActivityDate Between @StartDate And @EndDate)
			
			
			INSERT INTO edw.Fact_DailyUser
			(Dim_UserId,Dim_CompanyID,ActivityDate,Start_Time,End_Time,FirstOnPcTime,LastOnPcTime,EstimatedTimeSpent,OnlineTimeSpent,OfflineTimeSpent
			,PrivateTimeSpent,UnaccountedTimeSpent,FocusTimeInCalendarDay,FocusTimeInShift,MaxUnaccountedSlotTime,FirstOnPCTimeInUTC,LastOnPCTimeInUTC
			,MaxUnaccountedTimeWithPreviousDay,BreakTime_19_or_less,BreakTime_20_to_45,BreakTime_46_or_more,NumberOfBreak_19_or_less,NumberOfBreak_20_to_45
			,NumberOfBreak_46_or_more)
			 Select ID, CompanyID,ActivityDate,Start_Time,End_Time,FirstOnPcTime,LastOnPcTime,EstimatedTimeSpent,OnlineTimeSpent,OfflineTimeSpent
			,PrivateTimeSpent,UnaccountedTimeSpent,FocusTimeInCalendarDay,FocusTimeInShift,MaxUnaccountedSlotTime,FirstOnPCTimeInUTC,LastOnPCTimeInUTC
			,MaxUnaccountedTimeWithPreviousDay,BreakTime_19_or_less,BreakTime_20_to_45,BreakTime_46_or_more,NumberOfBreak_19_or_less,NumberOfBreak_20_to_45
			,NumberOfBreak_46_or_more
			FRom #TempFact_DailyUser


				
			 ---Stg_TimeSlot
			Select a.*,b.ID,b.CompanyID INTO #TempStg_TimeSlot From edw.Stg_TimeSlot a 
			INNER JOIN (Select * from #DestUser Where SourceID is not null) b
			On(a.Dim_UserID = b.SourceID AND ActivityDate Between @StartDate And @EndDate)
			
			
			INSERT INTO edw.Stg_TimeSlot
			(Dim_UserID,Dim_CompanyID,Dim_AppMasterID,Dim_ActivityCategoryID,Dim_DeviceID,ActivityDate,DeviceID,FileOrUrlName
			,IsFileOrUrl,PurposeID,IsOnPc,IsShift,StartTimeInUTC,EndTimeInUTC,TimeZoneOffset,IsActive,TimeSpent,IsUserModified,ModifiedBy,UploadTime)
			Select a.ID, a.CompanyID,b.ID,c.ID,a.Dim_DeviceID,a.ActivityDate,a.DeviceID,a.FileOrUrlName
			,a.IsFileOrUrl,a.PurposeID,a.IsOnPc,a.IsShift,a.StartTimeInUTC,a.EndTimeInUTC,a.TimeZoneOffset,a.IsActive,a.TimeSpent,a.IsUserModified,a.ModifiedBy,a.UploadTime
			FROM #TempStg_TimeSlot  a
			inner Join #DestApp_Master b ON (a.Dim_AppMasterID = b.SourceID)
			inner join #DestActivityCategory c ON (a.Dim_ActivityCategoryID = c.SourceID) 
			
			
	
			--- Fact_DailyUserEmail
			--Select a.*,b.ID,b.CompanyID INTO #TempFact_DailyUserEmail From edw.Fact_DailyUserEmail a 
			--INNER JOIN (Select * from #DestUser Where SourceID is not null) b
			--On(a.Dim_UserID = b.SourceID AND ActivityDate Between @StartDate And @EndDate)
			--
			--
			--INSERT INTO edw.Fact_DailyUserEmail
			--(Dim_UserId,Dim_CompanyID,ActivityDate,NumberOfSentEmails,NumberOfReceivedEmails,
			--NumberOfUnreadEmails,AvgResponseTime,NumberOfAllRecipients,NumberOfTeamRecipients,NumberOfDepartmentRecipients,NumberOfCompanyRecipients)
			--Select ID, CompanyID,ActivityDate,NumberOfSentEmails,NumberOfReceivedEmails,
			--NumberOfUnreadEmails,AvgResponseTime,NumberOfAllRecipients,NumberOfTeamRecipients,NumberOfDepartmentRecipients,NumberOfCompanyRecipients
			--FROM #TempFact_DailyUserEmail
			
			
			
	--- DailyPredVue
				Select a.*,b.ID,b.CompanyID INTO #TempFact_DailyPredVue From edw.Fact_DailyPredVue a 
				INNER JOIN (Select * from #DestUser Where SourceID is not null) b
				On(a.Dim_UserID = b.SourceID AND ActivityDate Between @StartDate And DATEADD(month, 1, @EndDate))
				
				
			INSERT INTO [edw].[Fact_DailyPredVue]
			([Dim_CompanyID],[Dim_UserID],[ActivityDate],[Day],[Pred_Work_Hrs],[Pred_Private_Hrs],[Pred_Unaccounted_Hrs],[Pred_Focus_Hrs],[Pred_Meeting_Hrs],[Pred_Core_Hrs])
			Select CompanyID, ID, ActivityDate,[Day],[Pred_Work_Hrs],[Pred_Private_Hrs],[Pred_Unaccounted_Hrs],[Pred_Focus_Hrs],[Pred_Meeting_Hrs],[Pred_Core_Hrs] from #TempFact_DailyPredVue
			
			
			
			Drop table if Exists  #TempTimeSlot
			Drop table if Exists  #TempTimeSlotMeeting
			Drop table if Exists  #TempFact_DailyActivity
			Drop table if Exists  #TempFact_DailyUser
			Drop table if Exists  #TempStg_TimeSlot
			Drop table if Exists  #TempFact_DailyUserEmail

END

ELSE 

 BEGIN
        PRINT 'Data already Exists';
    END	


	
END


GO
/****** Object:  StoredProcedure [edw].[sproc_GenerateNotificationResults]    Script Date: 9/10/2021 8:10:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE    PROCEDURE [edw].[sproc_GenerateNotificationResults]
--PLEASE SEE PRODUCT BACKLOG ITEMS 19864 AND 18540
(
	@CompanyID INT, 
	@EntityType NVARCHAR(100), -- 1: Department
	@EntityValue integer, -- find if dim or non dim
	@AlertType NVARCHAR(100), -- 1: ActivityCategory
	@AlertTypeValue NVARCHAR(4000) = NULL,
	@EffectiveDate DATE,
	@IsAlertPerEmployee BIT,
	@AlertOperator VARCHAR(2),
	@PredictiveValue FLOAT,
	@Debug tinyint = 0
)
AS 
BEGIN
    SET NOCOUNT ON
	SET DATEFIRST 1

	-- Input and Output discussion.

	DECLARE @AlertValue VARCHAR(100) = NULL
	set @AlertValue = @AlertTypeValue
	
	if (@AlertType = 'Activity time')
	begin

		set @AlertValue = @AlertTypeValue
		select @AlertValue = ActivityCategoryName
		from edw.Dim_ActivityCategory ac 
		where ac.CompanyID = @CompanyID and ac.ActivityCategoryID  = convert(integer, @AlertTypeValue)

	end
	else
	begin
		
		set @AlertValue = @AlertTypeValue
	
	end

	DECLARE @YearMonthNum INT,
			@WeekNum INT,
			@strSQL NVARCHAR(MAX),
			@strSQL_UserCount NVARCHAR(MAX),
			@PredictiveValueInMinutes FLOAT,
			@UserCount INT,
			@ParmDef NVARCHAR(50),
			@ManagerDimUserID INT

	SET @PredictiveValueInMinutes = @PredictiveValue * 60

	SELECT @WeekNum=WeekNum, @YearMonthNum=YearMonthNum FROM edw.Dim_Date
    WHERE Date=DATEADD(WK,-1, @EffectiveDate)


	SELECT @ManagerDimUserID=ManagerDimUserID FROM edw.Dim_Department
	WHERE CompanyID=@CompanyID AND DepartmentID=@EntityValue

	
	--******************* GET USER COUNT ******************

	SET @strSQL_UserCount=
	
	'SELECT @retvalOUT=COUNT(1) FROM
		(SELECT u.ID
			FROM edw.Fact_DailyActivity da 
			JOIN edw.Dim_User u ON da.Dim_UserID = u.ID
			JOIN edw.Dim_Department d ON u.Dim_DepartmentID = d.ID
			JOIN edw.Dim_ActivityCategory ac ON da.Dim_ActivityCategoryID = ac.ID '
	
				+ CASE @AlertType 
					WHEN 'Application time' THEN ' JOIN edw.Dim_AppMaster am ON da.Dim_AppMasterID = am.ID '
					ELSE ''
				END
			 + '
	
			JOIN edw.Dim_Date dt ON da.ActivityDate = dt.Date
			WHERE da.Dim_CompanyID=' + convert(varchar,@CompanyID) + ' AND u.IsActivityCollectionOn = 1 AND u.IsActive = 1 AND YearMonthNum='+ convert(varchar,@YearMonthNum)  + ' AND WeekNum=' + convert(varchar,@WeekNum) 
				+ CASE @AlertType 
					WHEN 'Activity time' THEN ' AND da.PurposeID <> -1 AND ac.ActivityCategoryName=''' + @AlertValue + ''''
					WHEN 'Application time' THEN '  AND da.PurposeID <> -1 AND am.AppName=''' + @AlertValue + ''''
					WHEN 'Total hours' THEN '  AND da.PurposeID <> -1 '
					WHEN 'Unaccounted hours' THEN ' AND da.PurposeID = -1 AND ac.ActivityCategoryID=0 '
				  END
			 + ' AND d.DepartmentID= ' +  convert(varchar,@EntityValue) 
			 + CASE
				WHEN @ManagerDimUserID IS NOT NULL THEN ' AND u.ID <> ' + convert(varchar,@ManagerDimUserID)
			   END
			+ CHAR(10) +
			+ ' GROUP BY u.ID
		) base'
	


	
	if (@Debug = 1)
	begin

		print 'strSQL for UserCount => ' +  IsNull(@strSQL_UserCount, ' Empty' ) + CHAR(10)
	
	end
	

	--**** assign @UserCount ****
	SET @ParmDef = '@retvalOUT INT OUTPUT'
	EXEC sp_EXECUTESQL @strSQL_UserCount, @ParmDef, @retvalOUT= @UserCount OUTPUT


	if (@UserCount IS NULL OR @UserCount = 0)
		set @UserCount = 1

	--**************** MAIN OUTPUT ***************
	/**
	Note: TimeSpentInCalendarDay is divided by 5 since 5 working days in week. Also when @IsAlertPerEmployee=0 (by Dept), we want to multiply the # of users in Dept by 5.
	**/

	SET @strSQL=

	'SELECT ' 
	+ CASE @IsAlertPerEmployee 
		WHEN 1 THEN 'u.UserID PartyID, u.FirstName + '' '' + IsNull(u.LastName, '''' ) PartyName, '
		ELSE 'd.DepartmentID PartyID, d.DepartmentName PartyName, '
	  END
	+ CASE @IsAlertPerEmployee
		WHEN 1 THEN
			'CAST((SUM(TimeSpentInCalendarDay) / 5) / 60 AS decimal(18,2)) TimeSpent,
			CAST((SUM(TimeSpentInCalendarDay) / 5) / 60 AS decimal(18,2)) - ' + convert(varchar, @PredictiveValue) + ' ThresholdDiff '
		ELSE
			'CAST((SUM(TimeSpentInCalendarDay) / (5*' + convert(varchar, @UserCount) + ')) / 60 AS DECIMAL(18,2)) TimeSpent,
			CAST((SUM(TimeSpentInCalendarDay) / (5*' + convert(varchar, @UserCount) + ')) / 60 AS DECIMAL(18,2)) - ' + convert(varchar, @PredictiveValue) + ' ThresholdDiff '
	  END
	+
	'FROM edw.Fact_DailyActivity da 
	JOIN edw.Dim_User u ON da.Dim_UserID = u.ID  
	JOIN edw.Dim_Department d ON u.Dim_DepartmentID = d.ID
	JOIN edw.Dim_ActivityCategory ac ON da.Dim_ActivityCategoryID = ac.ID '
	
				+ CASE @AlertType 
					WHEN 'Application time' THEN ' JOIN edw.Dim_AppMaster am ON da.Dim_AppMasterID = am.ID '
					ELSE ''
				END
			 + '
	JOIN edw.Dim_Date dt ON da.ActivityDate = dt.Date
	WHERE da.Dim_CompanyID=' + convert(varchar, @CompanyID) + '  AND u.IsActivityCollectionOn = 1 AND u.IsActive = 1 AND YearMonthNum='+ convert(varchar, @YearMonthNum)  + ' AND WeekNum=' + convert(varchar, @WeekNum) 
	+ CASE @AlertType 
		WHEN 'Activity time' THEN ' AND da.PurposeID <> -1 AND ac.ActivityCategoryName=''' + @AlertValue + ''''
		WHEN 'Application time' THEN '  AND da.PurposeID <> -1 AND am.AppName=''' + @AlertValue + ''''
		WHEN 'Total hours' THEN '  AND da.PurposeID <> -1 '
		WHEN 'Unaccounted hours' THEN ' AND da.PurposeID = -1 AND ac.ActivityCategoryID=0 '
	  END
	+ ' AND d.DepartmentID=' + convert(varchar, @EntityValue)
	+ CASE
		WHEN @ManagerDimUserID IS NOT NULL THEN ' AND u.ID <> ' + convert(varchar, @ManagerDimUserID)
	  END
	+ CHAR(10)
	+ CASE @IsAlertPerEmployee 
		WHEN 1 THEN 'GROUP BY u.UserID, u.FirstName + '' '' + IsNull(u.LastName, '''' )'
		ELSE ' GROUP BY d.DepartmentID, d.DepartmentName '
	  END
	+ CHAR(10)	
	+ CASE @IsAlertPerEmployee
		WHEN 1 THEN 'HAVING SUM(TimeSpentInCalendarDay) / 5 '  + @AlertOperator + convert(varchar, @PredictiveValueInMinutes)
		ELSE 'HAVING SUM(TimeSpentInCalendarDay) / (5*' + convert(varchar, @UserCount) + ') ' + @AlertOperator + convert(varchar, @PredictiveValueInMinutes)
	  END

	  ---------------- UNION of no data users for <  -----------------
	+ CHAR(10)
		
	+ CASE charindex('<',@AlertOperator) WHEN 0 THEN ''
	  ELSE CASE WHEN @IsAlertPerEmployee = 0 THEN '' ELSE '
				UNION ALL 
			  
			  '
		+
			'	SELECT distinct  '
		+ 
			CASE @IsAlertPerEmployee 
				WHEN 1 THEN 'u.UserID PartyID, u.FirstName + '' '' + IsNull(u.LastName, '''' ) PartyName, '
				ELSE 'd.DepartmentID PartyID, d.DepartmentName PartyName, '
			END
		+	CASE @IsAlertPerEmployee
				WHEN 1 THEN
					'0 TimeSpent,
					 0 - ' + convert(varchar, @PredictiveValue) + ' ThresholdDiff '
				ELSE
					'0 TimeSpent,
					 0 - ' + convert(varchar, @PredictiveValue) + ' ThresholdDiff '
			END
		+
		'
		FROM edw.Dim_User u 
		JOIN edw.Dim_Department d ON u.Dim_DepartmentID = d.ID
	
		WHERE u.CompanyID=' + convert(varchar, @CompanyID) + '  AND u.IsActivityCollectionOn = 1 AND u.IsActive = 1
		
			 AND d.DepartmentID=' + convert(varchar, @EntityValue)
		+ CASE
			WHEN @ManagerDimUserID IS NOT NULL THEN ' AND u.ID <> ' + convert(varchar, @ManagerDimUserID)
		  END
			+ CHAR(10) +
			' AND NOT EXISTS (
				SELECT 1 FROM edw.Fact_DailyActivity da 
					INNER JOIN edw.Dim_ActivityCategory ac ON da.Dim_ActivityCategoryID = ac.ID '
					
				+ CASE @AlertType 
					WHEN 'Application time' THEN ' JOIN edw.Dim_AppMaster am ON da.Dim_AppMasterID = am.ID '
					ELSE ''
				END
			 + '
					INNER JOIN edw.Dim_Date dt ON da.ActivityDate = dt.Date
					WHERE
						da.Dim_UserID = u.ID AND YearMonthNum='+ convert(varchar, @YearMonthNum) + ' AND WeekNum=' + convert(varchar, @WeekNum) 
						+ CASE @AlertType 
							WHEN 'Activity time' THEN ' AND da.PurposeID <> -1 AND ac.ActivityCategoryName=''' + @AlertValue + ''''
							WHEN 'Application time' THEN '  AND da.PurposeID <> -1 AND am.AppName=''' + @AlertValue + ''''
							WHEN 'Total hours' THEN '  AND da.PurposeID <> -1 '
							WHEN 'Unaccounted hours' THEN ' AND da.PurposeID = -1 AND ac.ActivityCategoryID=0 '
						  END  + ' ) '

	END
	END

	if (@Debug = 1)
	begin

		print 'strSQL for Results => ' +  IsNull(@strSQL, ' Empty' )
	
	end
	
	EXEC (@strSQL)


END



GO
/****** Object:  StoredProcedure [edw].[sproc_GenerateNotificationResults1]    Script Date: 9/10/2021 8:10:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE    PROCEDURE [edw].[sproc_GenerateNotificationResults1]
--PLEASE SEE PRODUCT BACKLOG ITEMS 19864 AND 18540
(
	@CompanyID INT, 
	@EntityType VARCHAR(40), -- 1: Department
	@EntityValue integer, -- find if dim or non dim
	@AlertType VARCHAR(40), -- 1: ActivityCategory
	@AlertTypeValue VARCHAR(100) = NULL,
	@EffectiveDate DATE,
	@IsAlertPerEmployee BIT,
	@AlertOperator VARCHAR(2),
	@PredictiveValue FLOAT,
	@Debug tinyint = 0
)
AS 
BEGIN
    SET NOCOUNT ON
	SET DATEFIRST 1

	-- Input and Output discussion.

	DECLARE @AlertValue VARCHAR(100) = NULL
	set @AlertValue = @AlertTypeValue
	
	if (@AlertType = 'Activity time')
	begin

		select @AlertValue = ActivityCategoryName
		from edw.Dim_ActivityCategory ac 
		where ac.CompanyID = @CompanyID and ac.ActivityCategoryID  = convert(integer, @AlertTypeValue)

	end
	else
	begin
		
		set @AlertValue = @AlertTypeValue
	
	end

	DECLARE @YearMonthNum INT,
			@WeekNum INT,
			@strSQL NVARCHAR(MAX),
			@strSQL_UserCount NVARCHAR(MAX),
			@PredictiveValueInMinutes FLOAT,
			@UserCount INT,
			@ParmDef NVARCHAR(50),
			@ManagerDimUserID INT

	SET @PredictiveValueInMinutes = @PredictiveValue * 60

	SELECT @WeekNum=WeekNum, @YearMonthNum=YearMonthNum FROM edw.Dim_Date
    WHERE Date=DATEADD(WK,-1, @EffectiveDate)


	SELECT @ManagerDimUserID=ManagerDimUserID FROM edw.Dim_Department
	WHERE CompanyID=@CompanyID AND DepartmentID=@EntityValue

	
	--******************* GET USER COUNT ******************

	SET @strSQL_UserCount=
	
	'SELECT @retvalOUT=COUNT(1) FROM
		(SELECT u.ID
			FROM edw.Fact_DailyActivity da 
			JOIN edw.Dim_User u ON da.Dim_UserID = u.ID
			JOIN edw.Dim_Department d ON u.Dim_DepartmentID = d.ID
			JOIN edw.Dim_ActivityCategory ac ON da.Dim_ActivityCategoryID = ac.ID '
	
				+ CASE @AlertType 
					WHEN 'Application time' THEN ' JOIN edw.Dim_AppMaster am ON da.Dim_AppMasterID = am.ID '
					ELSE ''
				END
			 + '
	
			JOIN edw.Dim_Date dt ON da.ActivityDate = dt.Date
			WHERE da.Dim_CompanyID=' + CAST(@CompanyID AS varchar(5)) + ' AND u.IsActivityCollectionOn = 1 AND u.IsActive = 1 AND YearMonthNum='+ CAST(@YearMonthNum AS varchar(20)) + ' AND WeekNum=' + CAST(@WeekNum AS varchar(20)) 
				+ CASE @AlertType 
					WHEN 'Activity time' THEN ' AND da.PurposeID <> -1 AND ac.ActivityCategoryName=''' + @AlertValue + ''''
					WHEN 'Application time' THEN '  AND da.PurposeID <> -1 AND am.AppName=''' + @AlertValue + ''''
					WHEN 'Total hours' THEN '  AND da.PurposeID <> -1 '
					WHEN 'Unaccounted hours' THEN ' AND da.PurposeID = -1 AND ac.ActivityCategoryID=0 '
				  END
			 + ' AND d.DepartmentID= ' + CAST(@EntityValue AS varchar(10))
			 + CASE
				WHEN @ManagerDimUserID IS NOT NULL THEN ' AND u.ID <> ' + CAST(@ManagerDimUserID AS varchar(10))
			   END
			+ CHAR(10) +
			+ ' GROUP BY u.ID
		) base'
	


	
	if (@Debug = 1)
	begin

		print 'strSQL for UserCount => ' +  IsNull(@strSQL_UserCount, ' Empty' ) + CHAR(10)
	
	end
	

	--**** assign @UserCount ****
	SET @ParmDef = '@retvalOUT INT OUTPUT'
	EXEC sp_EXECUTESQL @strSQL_UserCount, @ParmDef, @retvalOUT= @UserCount OUTPUT


	if (@UserCount IS NULL OR @UserCount = 0)
		set @UserCount = 1

	--**************** MAIN OUTPUT ***************
	/**
	Note: TimeSpentInCalendarDay is divided by 5 since 5 working days in week. Also when @IsAlertPerEmployee=0 (by Dept), we want to multiply the # of users in Dept by 5.
	**/

	SET @strSQL=

	'SELECT ' 
	+ CASE @IsAlertPerEmployee 
		WHEN 1 THEN 'u.UserID PartyID, u.FirstName + '' '' + IsNull(u.LastName, '''' ) PartyName, '
		ELSE 'd.DepartmentID PartyID, d.DepartmentName PartyName, '
	  END
	+ CASE @IsAlertPerEmployee
		WHEN 1 THEN
			'CAST((SUM(TimeSpentInCalendarDay) / 5) / 60 AS decimal(18,2)) TimeSpent,
			CAST((SUM(TimeSpentInCalendarDay) / 5) / 60 AS decimal(18,2)) - ' + CAST(@PredictiveValue AS varchar(10)) + ' ThresholdDiff '
		ELSE
			'CAST((SUM(TimeSpentInCalendarDay) / (5*' + CAST(@UserCount AS varchar(10)) + ')) / 60 AS DECIMAL(18,2)) TimeSpent,
			CAST((SUM(TimeSpentInCalendarDay) / (5*' + CAST(@UserCount AS varchar(10)) + ')) / 60 AS DECIMAL(18,2)) - ' + CAST(@PredictiveValue AS varchar(10)) + ' ThresholdDiff '
	  END
	+
	'FROM edw.Fact_DailyActivity da 
	JOIN edw.Dim_User u ON da.Dim_UserID = u.ID  
	JOIN edw.Dim_Department d ON u.Dim_DepartmentID = d.ID
	JOIN edw.Dim_ActivityCategory ac ON da.Dim_ActivityCategoryID = ac.ID '
	
				+ CASE @AlertType 
					WHEN 'Application time' THEN ' JOIN edw.Dim_AppMaster am ON da.Dim_AppMasterID = am.ID '
					ELSE ''
				END
			 + '
	JOIN edw.Dim_Date dt ON da.ActivityDate = dt.Date
	WHERE da.Dim_CompanyID=' + CAST(@CompanyID AS varchar(5)) + '  AND u.IsActivityCollectionOn = 1 AND u.IsActive = 1 AND YearMonthNum='+ CAST(@YearMonthNum AS varchar(20)) + ' AND WeekNum=' + CAST(@WeekNum AS varchar(20)) 
	+ CASE @AlertType 
		WHEN 'Activity time' THEN ' AND da.PurposeID <> -1 AND ac.ActivityCategoryName=''' + @AlertValue + ''''
		WHEN 'Application time' THEN '  AND da.PurposeID <> -1 AND am.AppName=''' + @AlertValue + ''''
		WHEN 'Total hours' THEN '  AND da.PurposeID <> -1 '
		WHEN 'Unaccounted hours' THEN ' AND da.PurposeID = -1 AND ac.ActivityCategoryID=0 '
	  END
	+ ' AND d.DepartmentID=' + CAST(@EntityValue AS varchar(10))
	+ CASE
		WHEN @ManagerDimUserID IS NOT NULL THEN ' AND u.ID <> ' + CAST(@ManagerDimUserID AS varchar(10))
	  END
	+ CHAR(10)
	+ CASE @IsAlertPerEmployee 
		WHEN 1 THEN 'GROUP BY u.UserID, u.FirstName + '' '' + IsNull(u.LastName, '''' )'
		ELSE ' GROUP BY d.DepartmentID, d.DepartmentName '
	  END
	+ CHAR(10)	
	+ CASE @IsAlertPerEmployee
		WHEN 1 THEN 'HAVING SUM(TimeSpentInCalendarDay) / 5 '  + @AlertOperator + CAST(@PredictiveValueInMinutes AS varchar(20))
		ELSE 'HAVING SUM(TimeSpentInCalendarDay) / (5*' + CAST(@UserCount AS varchar(10)) + ') ' + @AlertOperator + CAST(@PredictiveValueInMinutes AS varchar(20))
	  END

	  ---------------- UNION of no data users for <  -----------------
	+ CHAR(10)
		
	+ CASE charindex('<',@AlertOperator) WHEN 0 THEN ''
	  ELSE CASE WHEN @IsAlertPerEmployee = 0 THEN '' ELSE '
				UNION ALL 
			  
			  '
		+
			'	SELECT distinct  '
		+ 
			CASE @IsAlertPerEmployee 
				WHEN 1 THEN 'u.UserID PartyID, u.FirstName + '' '' + IsNull(u.LastName, '''' ) PartyName, '
				ELSE 'd.DepartmentID PartyID, d.DepartmentName PartyName, '
			END
		+	CASE @IsAlertPerEmployee
				WHEN 1 THEN
					'0 TimeSpent,
					 0 - ' + CAST(@PredictiveValue AS varchar(10)) + ' ThresholdDiff '
				ELSE
					'0 TimeSpent,
					 0 - ' + CAST(@PredictiveValue AS varchar(10)) + ' ThresholdDiff '
			END
		+
		'
		FROM edw.Dim_User u 
		JOIN edw.Dim_Department d ON u.Dim_DepartmentID = d.ID
	
		WHERE u.CompanyID=' + CAST(@CompanyID AS varchar(5)) + '  AND u.IsActivityCollectionOn = 1 AND u.IsActive = 1
		
			 AND d.DepartmentID=' + CAST(@EntityValue AS varchar(10))
		+ CASE
			WHEN @ManagerDimUserID IS NOT NULL THEN ' AND u.ID <> ' + CAST(@ManagerDimUserID AS varchar(10))
		  END
			+ CHAR(10) +
			' AND NOT EXISTS (
				SELECT 1 FROM edw.Fact_DailyActivity da 
					INNER JOIN edw.Dim_ActivityCategory ac ON da.Dim_ActivityCategoryID = ac.ID '
					
				+ CASE @AlertType 
					WHEN 'Application time' THEN ' JOIN edw.Dim_AppMaster am ON da.Dim_AppMasterID = am.ID '
					ELSE ''
				END
			 + '
					INNER JOIN edw.Dim_Date dt ON da.ActivityDate = dt.Date
					WHERE
						da.Dim_UserID = u.ID AND YearMonthNum='+ CAST(@YearMonthNum AS varchar(20)) + ' AND WeekNum=' + CAST(@WeekNum AS varchar(20)) 
						+ CASE @AlertType 
							WHEN 'Activity time' THEN ' AND da.PurposeID <> -1 AND ac.ActivityCategoryName=''' + @AlertValue + ''''
							WHEN 'Application time' THEN '  AND da.PurposeID <> -1 AND am.AppName=''' + @AlertValue + ''''
							WHEN 'Total hours' THEN '  AND da.PurposeID <> -1 '
							WHEN 'Unaccounted hours' THEN ' AND da.PurposeID = -1 AND ac.ActivityCategoryID=0 '
						  END  + ' ) '

	END
	END

	if (@Debug = 1)
	begin

		print 'strSQL for Results => ' +  IsNull(@strSQL, ' Empty' )
	
	end
	
	EXEC (@strSQL)


END


GO
/****** Object:  StoredProcedure [edw].[sproc_GetUnmappedApps]    Script Date: 9/10/2021 8:10:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [edw].[sproc_GetUnmappedApps]
(
    @CompanyID int
	,@FromDate DATE
	,@MinimumTimeSpentInHrs real
	,@Debug tinyint = 0
)
AS
BEGIN



/****** With Timing *****/

declare @ToDate date = GetDate()

if (@MinimumTimeSpentInHrs < 0.1)
set
	@MinimumTimeSpentInHrs = 0.1

select a.ExeName UnmappedExeName, a.AppName, ROUND(SUM(t.TimeSpentInCalendarDay)/60.0,2 ) TimeSpentInHrs into #UnmappedAppName 
from [edw].[Fact_DailyActivity] t 
inner join [edw].[Dim_AppMaster] a
on
       t.Dim_CompanyID = a.CompanyID and t.Dim_AppMasterID = a.ID
where 
       t.Dim_CompanyID = @CompanyID  and  t.PurposeID = -1 and t.IsOnPc = 1 and t.ActivityDate between @FromDate and @ToDate
       and TRIM(IsNull(a.ExeName,'')) <> '' and a.ExeName not in ('chrome.exe', 'firefox.exe', 'ApplicationFrameHost.exe', 'iexplore.exe', 'msedge.exe')
	   and (a.ExeName like '%.exe' OR a.ExeName like '%.app%' OR a.ExeName like '%.bin%' OR a.ExeName like '%.dll%')
	   and t.IsFileOrUrl = 0
group by  a.ExeName, a.AppName


select top 10000 * from #UnmappedAppName h
where h.TimeSpentInHrs >= @MinimumTimeSpentInHrs and
	not exists (
			select 1 from [edw].[Brdg_AppActivityCategory] a 
			inner join [edw].[Dim_AppParent] m
			on
				a.Dim_AppParentID = m.ID
			where
				m.CompanyID = @CompanyID and TRIM(ISNULL(a.WebApp, '')) = ''
				and m.ExeName = h.UnmappedExeName
		)

order by TimeSpentInHrs desc


drop table #UnmappedAppName


END

GO
/****** Object:  StoredProcedure [edw].[sproc_GetUnmappedUrls]    Script Date: 9/10/2021 8:10:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [edw].[sproc_GetUnmappedUrls]
(
    @CompanyID int
	,@FromDate DATE
	,@MinimumTimeSpentInHrs real
	,@Debug tinyint = 0
)
AS
BEGIN

declare @ToDate date = GetDate()

if (@MinimumTimeSpentInHrs < 0.1)
set
	@MinimumTimeSpentInHrs = 0.1


select [edw].GetHostNameFromUrl (t.FileOrUrlName) UnmappedUrlHostName, ROUND(SUM(t.TimeSpent)/60.0,2 ) TimeSpentInHrs into #UnmappedUrlHostName 
	from [edw].[Fact_TimeSlot] t 
	where 
		t.Dim_CompanyID = @CompanyID  and t.IsFileOrUrl = 1  and t.PurposeID = -1 and t.IsOnPc = 1
		and t.ActivityDate between @FromDate and @ToDate
	group by [edw].GetHostNameFromUrl (t.FileOrUrlName)

select top 10000 * from #UnmappedUrlHostName h
where h.TimeSpentInHrs >= @MinimumTimeSpentInHrs and
	not exists (
			select 1 from [edw].[Brdg_AppActivityCategory] a 
			inner join [edw].[Dim_AppParent] m
			on
				a.Dim_AppParentID = m.ID
			where
				m.CompanyID = @CompanyID and TRIM(ISNULL(a.WebApp, '')) <> ''
				and charindex(a.WebApp, h.UnmappedUrlHostName) > 0
		)

order by TimeSpentInHrs desc

if @Debug = 1
begin
	select top 10000 [edw].GetHostNameFromUrl (t.FileOrUrlName) UnmappedUrlHostName, t.FileOrUrlName, ROUND(SUM(t.TimeSpent)/60.0,2 ) TimeSpentInHrs 
	from [edw].[Fact_TimeSlot] t 
	where 
		t.Dim_CompanyID = @CompanyID  and t.IsFileOrUrl = 1  and t.PurposeID = -1 and t.IsOnPc = 1
		and t.ActivityDate between @FromDate and @ToDate
	group by [edw].GetHostNameFromUrl (t.FileOrUrlName), t.FileOrUrlName
	having ROUND(SUM(t.TimeSpent)/60.0,2 ) > @MinimumTimeSpentInHrs
end


drop table #UnmappedUrlHostName



END


GO
/****** Object:  StoredProcedure [edw].[sproc_GetUserActivities]    Script Date: 9/10/2021 8:10:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [edw].[sproc_GetUserActivities]
(
		@CompanyID int
       ,@LoggedInUserId int = 0
       ,@UserEmail nvarchar(4000)
       ,@UserID int
       ,@StartDate date
       ,@EndDate date
       ,@Page int = 0
       ,@PageSize int = 0
       ,@IsListView TINYINT = 0
       ,@Debug tinyint = 0

)
AS
BEGIN

              declare @DayFirstActivityTime datetime, 
					  @DayEndActivityTime datetime,
					  @DateNextToEndDate Date = DATEADD(DAY, 1 , @EndDate),
					  @iInterval AS INT = 30,
				      @StartDateTime datetime = @StartDate,
					  @EndDateTime datetime =  @EndDate,
					  @DayFirstTimeZoneOffset int,
					  @DayEndTimeZoneOffset int,
					  @EditedDay AS INT = 15,
					  @DayFirstActivityTimeUTC datetime,
					  @EstimatedTimeSpent real = 0,
					  @OnlineTimeSpent real = 0,
					  @OfflineTimeSpent real = 0,
					  @PrivateTimeSpent real = 0,
					  @UnaccountedTimeSpent real = 0,
					  @archiveEnd date


              if (@UserEmail <> '')
              begin
                     select @UserID = s.ID from [edw].[Dim_User] s with (nolock) where s.CompanyID = @CompanyID and s.UserEmail = @UserEmail
              end
			  else
			  begin				
				     select @UserID = s.ID from [edw].[Dim_User] s with (nolock) where s.CompanyID = @CompanyID and s.UserID = @UserID
			  end


              if (@Debug = 1)
              begin
                     select @UserID 'UserID',  @LoggedInUserId 'LoggedInUserId'
              end


			   Select @EstimatedTimeSpent = k.OnlineTimeSpent+ k.OfflineTimeSpent+ k.PrivateTimeSpent + k.UnaccountedTimeSpent
					,@OnlineTimeSpent = k.OnlineTimeSpent, @OfflineTimeSpent = k.OfflineTimeSpent
					,@PrivateTimeSpent = k.PrivateTimeSpent, @UnaccountedTimeSpent = k.UnaccountedTimeSpent

			  FROM edw.Fact_DailyUser k Where DIm_Userid = @UserID and ActivityDate = @StartDate


			   ------Start Work/Unaccounted/Private Time Calculation	

				IF @EstimatedTimeSpent = 0
					
						Select 'totalTime' as totalTime,'Total Time / Hrs' as title,
						0 as value,'0' as per 
						UNION ALL
						Select 'Work' as totalTime,'Work Time / Hrs' as title,
						0 as value,
						0 as per 
						UNION ALL
						Select 'Unaccounted' as totalTime,'Unaccounted Time / Hrs' as title,
						0 as value,0 as per
						UNION ALL
						Select 'Private' as totalTime,'Private Time / Hrs' as title,					
						0,
						0 per

				ELSE

						Select 'totalTime' as totalTime,'Total Time / Hrs' as title,
						(@EstimatedTimeSpent)/60.0 as value,'100' as per 
						UNION ALL
						Select 'Work' as totalTime,'Work Time / Hrs' as title,
						(@OnlineTimeSpent + @OfflineTimeSpent)/60.0 as value,
						Round(((@OnlineTimeSpent + @OfflineTimeSpent)/@EstimatedTimeSpent) * 100,2) as per 
						UNION ALL
						Select 'Unaccounted' as totalTime,'Unaccounted Time / Hrs' as title,
						@UnaccountedTimeSpent/60.0 as value,Round((@UnaccountedTimeSpent / @EstimatedTimeSpent) * 100,2) as per
						UNION ALL
						Select 'Private' as totalTime,'Private Time / Hrs' as title,					
						@PrivateTimeSpent /60.0,
						Round((@PrivateTimeSpent/@EstimatedTimeSpent) * 100,2) per


			  ------End Work/Unaccounted/Private Time Calculation			


			-- max date of archive
			SELECT @archiveEnd = CAST(CONVERT(VARCHAR(10),DATEADD(day, -90, getutcdate()), 101) AS date)


              create table #TempActivitiesBase
              (
                     ID int identity(1,1),UserID integer, StartTime datetime2, EndTime datetime2, TimeZoneOffSet int, PurposeID integer, WorkCategory nvarchar(4000),
					 ActivityCategoryID int, [ActivityCategoryName] nvarchar(4000), AppID int,AppName nvarchar(4000),WebAppID int,WebAppName nvarchar(4000),
					 FileOrUrlName nvarchar(4000) ,IsUserModified bit, StartTimeInUTC datetime2, EndTimeInUTC datetime2
              )


		    -- Depending on start/end dates, pull from either archive, standard Fact_TimeSlot or the view

			-- arch.Fact_TimeSlot
			IF @endDate <= @archiveEnd
			  insert into #TempActivitiesBase(UserID ,StartTime,  EndTime, TimeZoneOffSet, PurposeID, ActivityCategoryID, AppID, WebAppID, FileOrUrlName, IsUserModified, StartTimeInUTC, EndTimeInUTC)
              select s.Dim_UserID, convert (datetime2(0), s.StartTimeInLocal),  convert (datetime2(0),s.EndTimeInLocal), s.TimeZoneOffSet, s.PurposeID, s.Dim_ActivityCategoryID, s.Dim_AppMasterID,s.Dim_WebAppID,
			  s.FileOrUrlName, 0 as IsUserModified, 
			  dateadd(minute, -[TimeZoneOffSet],CONVERT(datetime2(0),s.StartTimeInLocal)), dateadd(minute,-[TimeZoneOffSet],CONVERT(datetime2(0),s.EndTimeInLocal))
              from [arch].[Fact_TimeSlot] s with (nolock)
			  where s.Dim_CompanyID = @CompanyID 
			  and s.[ActivityDate] between  @StartDate and @EndDate and s.[ActivityDate] < (GETDATE() - @EditedDay)
			  and s.IsActive = 1
			  and s.Dim_UserID = @UserID 

			-- edw.Fact_TimeSlot
			ELSE IF @startDate > @archiveEnd
			  insert into #TempActivitiesBase(UserID ,StartTime,  EndTime, TimeZoneOffSet, PurposeID, ActivityCategoryID, AppID, WebAppID, FileOrUrlName, IsUserModified, StartTimeInUTC, EndTimeInUTC)
              select s.Dim_UserID, convert (datetime2(0), s.StartTimeInLocal),  convert (datetime2(0),s.EndTimeInLocal), s.TimeZoneOffSet, s.PurposeID, s.Dim_ActivityCategoryID, s.Dim_AppMasterID,s.Dim_WebAppID,
			  s.FileOrUrlName, 0 as IsUserModified, 
			  dateadd(minute, -[TimeZoneOffSet],CONVERT(datetime2(0),s.StartTimeInLocal)), dateadd(minute,-[TimeZoneOffSet],CONVERT(datetime2(0),s.EndTimeInLocal))
              from [edw].[Fact_TimeSlot] s with (nolock)
			  where s.Dim_CompanyID = @CompanyID 
			  and s.[ActivityDate] between  @StartDate and @EndDate and s.[ActivityDate] < (GETDATE() - @EditedDay)
			  and s.IsActive = 1
			  and s.Dim_UserID = @UserID 

			-- edw.View_Fact_TimeSlot
			ELSE
			  BEGIN
				  insert into #TempActivitiesBase(UserID ,StartTime,  EndTime, TimeZoneOffSet, PurposeID, ActivityCategoryID, AppID, WebAppID, FileOrUrlName, IsUserModified, StartTimeInUTC, EndTimeInUTC)
				  select s.Dim_UserID, convert (datetime2(0), s.StartTimeInLocal),  convert (datetime2(0),s.EndTimeInLocal), s.TimeZoneOffSet, s.PurposeID, s.Dim_ActivityCategoryID, s.Dim_AppMasterID,s.Dim_WebAppID,
				  s.FileOrUrlName, 0 as IsUserModified, 
				  dateadd(minute, -[TimeZoneOffSet],CONVERT(datetime2(0),s.StartTimeInLocal)), dateadd(minute,-[TimeZoneOffSet],CONVERT(datetime2(0),s.EndTimeInLocal))
				  from [edw].[View_Fact_TimeSlot] s with (nolock)
				  where s.Dim_CompanyID = @CompanyID 
				  and s.[ActivityDate] between  @StartDate and @EndDate and s.[ActivityDate] < (GETDATE() - @EditedDay)
				  and s.IsActive = 1
				  and s.Dim_UserID = @UserID 
			  END


			  insert into #TempActivitiesBase(UserID ,StartTime,  EndTime, TimeZoneOffSet, PurposeID, ActivityCategoryID,  AppID, WebAppID, FileOrUrlName,IsUserModified, StartTimeInUTC, EndTimeInUTC)
              select s.Dim_UserID, convert (datetime2(0), s.StartTimeInLocal),  convert (datetime2(0),s.EndTimeInLocal), s.TimeZoneOffSet, s.PurposeID, s.Dim_ActivityCategoryID, s.Dim_AppMasterID,s.Dim_WebAppID,
			  s.FileOrUrlName,IsUserModified as IsUserModified, 
			  dateadd(minute, -[TimeZoneOffSet],CONVERT(datetime2(0),s.StartTimeInLocal)), dateadd(minute,-[TimeZoneOffSet],CONVERT(datetime2(0),s.EndTimeInLocal))
              from [edw].[Stg_TimeSlot] s with (nolock)
			  where s.Dim_CompanyID = @CompanyID 
			  and s.[ActivityDate] between  @StartDate and @EndDate and s.[ActivityDate] >= (GETDATE() - @EditedDay)
			  and s.IsActive = 1
              and s.Dim_UserID = @UserID 

			  
              -- TODO: Fill gaps with Unaccounted, avoid overlap and avoid Day End greater than today 
              -- Adjust overlap.  say 2 pm is end and 1.30 pm is start of next..adjust 2 pm end to 1.30 pm

              select @DayFirstActivityTimeUTC = MIN(t.StartTimeInUTC), @DayFirstActivityTime = MIN(t.StartTime), @DayEndActivityTime = MAX(t.EndTime) from #TempActivitiesBase t 
              
			  select @DayFirstTimeZoneOffset = t.TimeZoneOffset from #TempActivitiesBase t  where t.StartTime = @DayFirstActivityTime

			  select @DayEndTimeZoneOffset = t.TimeZoneOffset from #TempActivitiesBase t  where t.EndTime = @DayEndActivityTime

              -- where t.ActivityCategoryID <> 0 .. TODO: required for AccountedFirst and LastTime
              -- TODO in Analyzer: if DayEnd exceeds 00:00:midnight of end date ..Round it to the start of the next day

              if ( convert(Date, @DayEndActivityTime) > @DateNextToEndDate ) 
              begin
                     update t
                     set
                           t.EndTime = @DateNextToEndDate
                     from #TempActivitiesBase t
                     where
                           convert(Date, @DayEndActivityTime) > @DateNextToEndDate

              end

			 /* ****************************Temp Table contains TimeSlot between Start and end time***************** */
				;WITH aCTE
				AS(
				    SELECT 
				        @StartDateTime AS StartDateTime,
				        DATEADD(MINUTE,@iInterval,@StartDateTime) AS EndDateTime
				    UNION ALL
				    SELECT 
				        DATEADD(MINUTE,@iInterval,StartDateTime),
				        DATEADD(MINUTE,@iInterval,EndDateTime)
				    FROM aCTE
				    WHERE
				        DATEADD(MINUTE,@iInterval,EndDateTime) <= @EndDateTime
				)

				SELECT StartDateTime as StartTime,EndDateTime as EndTime,-1 as PurposeID,0 as ActivityCategoryID,0 as AppID,'' as FileOrUrlName
				 INTO #StartEnd_Temp
				FROM aCTE

			    IF (@DayFirstActivityTime > @StartDateTime)
					BEGIN
                     
							IF @IsListView = 0
							BEGIN
								IF DATEADD(HOUR, DATEDIFF(HOUR, 0, @DayFirstActivityTime),0) <> @DayFirstActivityTime
								BEGIN
										INSERT INTO #TempActivitiesBase(UserID,StartTime,  EndTime, TimeZoneOffset, PurposeID, ActivityCategoryID,  AppID, FileOrUrlName,IsUserModified)
										SELECT @UserID,DATEADD(HOUR, DATEDIFF(HOUR, 0, @DayFirstActivityTime),0), @DayFirstActivityTime, @DayFirstTimeZoneOffset, -1, 0, 0, '',0  
								END
							END
							ELSE
							BEGIN
                           
								INSERT INTO #TempActivitiesBase(UserID,StartTime,  EndTime, TimeZoneOffset, PurposeID, ActivityCategoryID,  AppID, FileOrUrlName,IsUserModified)
					SELECT @UserID,@StartDateTime, @DayFirstActivityTime, @DayFirstTimeZoneOffset, -1, 0, 0, '',0
						END
				END


			IF (@DayEndActivityTime < @DateNextToEndDate)
			BEGIN
					IF DATEADD(HOUR,DATEDIFF(HOUR,0,DATEADD(HOUR, 1, @DayEndActivityTime )),0) < @DateNextToEndDate AND @IsListView = 0
					BEGIN
							INSERT INTO #TempActivitiesBase(UserID,StartTime,  EndTime, TimeZoneOffset, PurposeID, ActivityCategoryID,  AppID, FileOrUrlName,IsUserModified)
							SELECT @UserID,@DayEndActivityTime, DATEADD(HOUR,DATEDIFF(HOUR,0,DATEADD(HOUR, 1, @DayEndActivityTime)),0) , @DayEndTimeZoneOffset, -1, 0, 0, '' ,0                                   
					END
                           
				ELSE
				BEGIN
					INSERT INTO #TempActivitiesBase(UserID,StartTime,  EndTime, TimeZoneOffset, PurposeID, ActivityCategoryID,  AppID, FileOrUrlName,IsUserModified)
					SELECT @UserID,@DayEndActivityTime, @DateNextToEndDate, @DayEndTimeZoneOffset, -1, 0, 0, ''  ,0
				END
			END


---- update Starttime
		Select * INTO #Ismodified from #TempActivitiesBase
		where IsUserModified = 1

		Select a.UserId,a.StartTime,max(b.EndTime) as EndTime INTO #Ismodified1
		from #Ismodified a
		INNER JOIN #TempActivitiesBase b
		On a.Userid = b.Userid and b.EndTime Between a.STartTime AND DateAdd(MINUTE, 1, a.STartTime)  and b.IsUserModified <> 1
		group by a.UserId,a.STartTime

		Update t
		Set t.StartTimeInUTC = DateAdd(minute,-t.TimeZoneOffset,a.EndTime)
		,t.TimeSpent = datediff(second, a.EndTime, t.EndTimeInLocal) /60.0
		from [EDW].[stg_TimeSlot] t with (nolock)
		inner join #Ismodified1 a
		On t.Dim_userid = a.userid and t.StartTimeInLocal = a.StartTime

		Update t
		Set t.StartTime = a.EndTime
		,t.StartTimeInUTC = DateAdd(Minute,-t.TimeZoneOffset,a.EndTime)
		from #TempActivitiesBase t
		inner join #Ismodified1 a
		On t.userid = a.userid and t.StartTime = a.StartTime
		--- update Endtime
		Select a.UserId,a.EndTime,min(b.startTime) as Starttime INTO #Ismodified2
		from #Ismodified a
		INNER JOIN #TempActivitiesBase b
		On a.Userid = b.Userid and b.startTime Between a.EndTime AND DateAdd(MINUTE, 1, a.EndTime)  and b.IsUserModified <> 1
		group by a.UserId,a.EndTime

		Update t
		Set t.EndTimeInUTC = DateAdd(Minute,-t.TimeZoneOffset,a.StartTime)
		,t.TimeSpent = datediff(second, t.startTimeInLocal, a.startTime) /60.0
		from [EDW].[stg_TimeSlot] t with (nolock)
		inner join #Ismodified2 a
		On t.Dim_userid = a.userid and t.EndTimeInLocal = a.EndTime

		Update t
		Set t.EndTime = a.StartTime
		,t.EndTimeInUTC = DateAdd(Minute,-t.TimeZoneOffset,a.StartTime)
		from #TempActivitiesBase t
		inner join #Ismodified2 a
		On t.userid = a.userid and t.EndTime = a.EndTime


		-- Update edw.Fact_TimeSlot if dates match, if applicable
		update t
		set
			t.StartTimeInUTC = a.EndTimeInUTC
			,t.TimeSpent = datediff(minute, a.EndTimeInUTC, t.EndTimeInUTC)
		from Edw.Fact_TimeSlot t
		inner join
		(
			Select s.UserID, s.StartTime,  s.EndTime, s.TimeZoneOffset, s.StartTimeInUTC, s.EndTimeInUTC, LEAD(s.startTime, 1, '1900') OVER(PARTITION BY s.UserID ORDER BY s.StartTime, s.EndTime) as NextStartTime,
			CASE WHEN s.EndTime = LEAD(s.startTime, 1, '1900') OVER(PARTITION BY s.UserID ORDER BY s.StartTime, s.EndTime) THEN 0 ELSE 1 END as HASGAP,s.IsUserModified, s.PurposeID
			FROM #TempActivitiesBase s
		) as a
		on
			t.Dim_UserID = a.UserId and t.StartTimeInLocal = a.NextStartTime 	
		WHERE  a.NextStartTime <> '1900-01-01 00:00:00.000' and a.HASGAP = 1 and a.NextStartTime < a.EndTime
		and t.Dim_CompanyID = @CompanyID and  t.ActivityDate = @StartDate 


		-- Update arch.Fact_TimeSlot if dates match, if applicable
		update t
		set
			t.StartTimeInUTC = a.EndTimeInUTC
			,t.TimeSpent = datediff(minute, a.EndTimeInUTC, t.EndTimeInUTC)
		from arch.Fact_TimeSlot t
		inner join
		(
			Select s.UserID, s.StartTime,  s.EndTime, s.TimeZoneOffset, s.StartTimeInUTC, s.EndTimeInUTC, LEAD(s.startTime, 1, '1900') OVER(PARTITION BY s.UserID ORDER BY s.StartTime, s.EndTime) as NextStartTime,
			CASE WHEN s.EndTime = LEAD(s.startTime, 1, '1900') OVER(PARTITION BY s.UserID ORDER BY s.StartTime, s.EndTime) THEN 0 ELSE 1 END as HASGAP,s.IsUserModified, s.PurposeID
			FROM #TempActivitiesBase s
		) as a
		on
			t.Dim_UserID = a.UserId and t.StartTimeInLocal = a.NextStartTime 	
		WHERE  a.NextStartTime <> '1900-01-01 00:00:00.000' and a.HASGAP = 1 and a.NextStartTime < a.EndTime
		and t.Dim_CompanyID = @CompanyID and  t.ActivityDate = @StartDate 

	

		insert into #TempActivitiesBase(UserID, StartTime,  EndTime, TimeZoneOffset, PurposeID, ActivityCategoryID,  AppID, FileOrUrlName,IsUserModified)
		Select @UserID as UserID, a.EndTime StartTime,a.ENDTIME1 as EndTime, a.TimeZoneOffset, -1 as PurposeID,0 as ActivityCategoryID,0 as AppID,'' as FileOrUrlName,IsUserModified FROM
		(Select  s.EndTime, s.TimeZoneOffset, LEAD(s.startTime, 1, '1900') OVER(PARTITION BY s.UserID ORDER BY s.StartTime, s.EndTime) as ENDTIME1 ,
		CASE WHEN s.EndTime = LEAD(s.startTime, 1, '1900') OVER(PARTITION BY s.UserID ORDER BY s.StartTime, s.EndTime) THEN 0 ELSE 1 END as HASGAP,s.IsUserModified, s.PurposeID
		FROM #TempActivitiesBase s) a
		Where a.ENDTIME1 <> '1900-01-01 00:00:00.000' and HASGAP = 1 and a.ENDTIME1 >= a.EndTime 
		
              -- Add Day Start and Day end gaps
  
              ; WITH CTEUserActivities
              AS
              (
                     SELECT t.ID, t.EndTime, Lead(t.StartTime, 1) OVER( ORDER BY t.StartTime, t.EndTime ) NextSlotStartTime
                     FROM #TempActivitiesBase t
              )
              update t
              set
                     t.EndTime = s.NextSlotStartTime
              from #TempActivitiesBase t
              inner join CTEUserActivities s
              on
                     t.ID = s.ID
              where
                     s.NextSlotStartTime <  s.EndTime	
			
              -- Update ActivityCategory
              update t
              set
                     t.[ActivityCategoryName] = s.[ActivityCategoryName]
              from #TempActivitiesBase t
              inner join [edw].[Dim_ActivityCategory] s with (nolock)
              on
                     s.CompanyID = @CompanyID and t.ActivityCategoryID = s.ID --and t.PurposeID <> -1

			  --Update AppName
              update t
              set
                     [AppName] = s.AppName
              from #TempActivitiesBase t
              inner join [edw].[Dim_AppMaster] s with (nolock)
              on
                     s.CompanyID = @CompanyID and t.AppID = s.ID --and t.PurposeID <> -1

			 --Update WebAppName
              update t
              set
                     [WebAppName] = s.WebAppName
              from #TempActivitiesBase t
              inner join [edw].[Dim_WebApp] s with (nolock)
              on
                     s.CompanyID = @CompanyID and t.WebAppID = s.ID --and t.PurposeID <> -1

		IF (convert(Date, @DayFirstActivityTimeUTC) <> convert(Date,getUtcdate()))
			update #TempActivitiesBase
			set
			[EndTime] = DATEADD(MS, -1, CONVERT(DATETIME2, @DateNextToEndDate))
   			Where EndTime = (Select Max(EndTime) From #TempActivitiesBase)	
		ELSE
			delete from #TempActivitiesBase			
   			Where EndTime = (Select Max(EndTime) From #TempActivitiesBase) and PurposeID = -1 and AppID = 0 and ActivityCategoryID = 0 

			--select * from #TempActivitiesBase

			create table #FinalActivities
            (
                ID int identity(1,1), StartTime datetime2, EndTime datetime2, TimeZoneOffset int,  PurposeID integer,  ActivityCategoryID int, [ActivityCategoryName] nvarchar(4000), AppID int,  AppName nvarchar(4000), FileOrUrlName nvarchar(4000) ,IsUserModified BIT
            )
			
            if (@Page = 0)
              begin
					insert into #FinalActivities
					(
						StartTime, EndTime, TimeZoneOffset, PurposeID,  ActivityCategoryID, [ActivityCategoryName], AppID,  AppName, FileOrUrlName ,IsUserModified
					) 
					select 
						StartTime, EndTime, t.TimeZoneOffset, PurposeID, ActivityCategoryID,							   
						case when @LoggedInUserId = @UserID then IsNull([ActivityCategoryName], '') ELSE '' END as ActivityCategoryName,
						Case when AppID is null then WebAppID end as AppID,
						case when @LoggedInUserId = @UserID then IsNull(case when AppName is null then WebAppName else AppName end, '') ELSE '' END as AppName,
						case when @LoggedInUserId = @UserID then  IsNull(FileOrUrlName, '') Else '' END  as FileOrUrlName,IsUserModified
						from #TempActivitiesBase t
						where t.StartTime <> t.EndTime and t.PurposeID = -1
						order by t.StartTime asc

					insert into #FinalActivities
					(
						StartTime, EndTime, TimeZoneOffset, PurposeID,  ActivityCategoryID, [ActivityCategoryName], AppID,  AppName, FileOrUrlName ,IsUserModified
					) 
					select 
							StartTime, EndTime, t.TimeZoneOffset, PurposeID, ActivityCategoryID,							   
							IsNull([ActivityCategoryName], '') ActivityCategoryName,
							Case when AppID is null then WebAppID else AppID end as AppID,
							IsNull(Case when AppName is null then WebAppName else AppName end, '') AppName,
							IsNull(FileOrUrlName, '') FileOrUrlName, IsUserModified
						from #TempActivitiesBase t
						where t.StartTime <> t.EndTime and t.PurposeID <> -1
						order by t.StartTime asc

					Select * from #FinalActivities order by StartTime asc
                     
					return 0
              end
              else begin
                    declare @Records int = 0, @TotalPages int = 0
					insert into #FinalActivities
					(
						StartTime, EndTime, TimeZoneOffset, PurposeID,  ActivityCategoryID, [ActivityCategoryName], AppID,  AppName, FileOrUrlName ,IsUserModified
					) 
					select 
							StartTime, EndTime, t.TimeZoneOffset, PurposeID, ActivityCategoryID, 
							case when @LoggedInUserId = @UserID then IsNull([ActivityCategoryName], '') ELSE '' END as ActivityCategoryName,
							Case when AppID is null then WebAppID else AppID end as AppID,  
							case when @LoggedInUserId = @UserID then IsNull(case when AppName is null then WebAppName else AppName end, '') ELSE '' END as AppName,
							case when @LoggedInUserId = @UserID then  IsNull(FileOrUrlName, '') Else '' END  as FileOrUrlName,IsUserModified
						from #TempActivitiesBase t

						where t.StartTime <> t.EndTime and t.PurposeID = -1
						order by t.StartTime asc

					insert into #FinalActivities
					(
						StartTime, EndTime, TimeZoneOffset, PurposeID,  ActivityCategoryID, [ActivityCategoryName], AppID,  AppName, FileOrUrlName ,IsUserModified
					) 
					select 
							StartTime, EndTime, t.TimeZoneOffset, PurposeID, ActivityCategoryID, 
							IsNull([ActivityCategoryName], '') ActivityCategoryName, 
							Case when AppID is null then WebAppID else AppID end as AppID,
							IsNull(Case when AppName is null then WebAppName else AppName end, '') AppName,
							IsNull(FileOrUrlName, '') FileOrUrlName,IsUserModified
						from #TempActivitiesBase t
						where t.StartTime <> t.EndTime and t.PurposeID <> -1
						order by t.StartTime asc

                     set @Records = @@RowCount
                     set @TotalPages = @Records / @PageSize

                     if ( ( @Records % @PageSize ) <> 0)
                     begin
                     
                           set @TotalPages = @TotalPages + 1
                     
                     end 

                     declare @BeginPage int =  (@Page - 1) * @PageSize + 1

                     declare @EndPage int = @BeginPage + ( @PageSize - 1)

                     if (@Debug = 1)
                     begin

                           select @Records 'Records', @TotalPages 'TotalPages' , @BeginPage 'BeginPage' , @EndPage 'EndPage'
                     end

                     select 
                           StartTime, EndTime, t.TimeZoneOffset, PurposeID, ActivityCategoryID, IsNull([ActivityCategoryName], '') [ActivityCategoryName], AppID,  IsNull(AppName, '') AppName, IsNull(FileOrUrlName, '') FileOrUrlName,IsUserModified
                     from #FinalActivities t
                     where @Page = 0 OR (t.ID between @BeginPage and @EndPage)


					return @TotalPages


              end
END

GO
/****** Object:  StoredProcedure [edw].[sproc_GetUserActivities_new]    Script Date: 9/10/2021 8:10:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create      PROCEDURE [edw].[sproc_GetUserActivities_new]
(
		@CompanyID int
       ,@LoggedInUserId int = 0
       ,@UserEmail nvarchar(4000)
       ,@UserID int
       ,@StartDate date
       ,@EndDate date
       ,@Page int = 0
       ,@PageSize int = 0
       ,@IsListView TINYINT = 0
       ,@Debug tinyint = 0

)
AS
BEGIN

              declare @DayFirstActivityTime datetime, 
					  @DayEndActivityTime datetime,
					  @DateNextToEndDate Date = DATEADD(DAY, 1 , @EndDate),
					  @iInterval AS INT = 30,
				      @StartDateTime datetime = @StartDate,
					  @EndDateTime datetime =  @EndDate,
					  @DayFirstTimeZoneOffset int,
					  @DayEndTimeZoneOffset int,
					  @EditedDay AS INT = 15,
					  @DayFirstActivityTimeUTC datetime

              if (@UserEmail <> '')
              begin
                     select @UserID = s.ID from [edw].[Dim_User] s where s.CompanyID = @CompanyID and s.UserEmail = @UserEmail
              end
			  else
			  begin				
				     select @UserID = s.ID from [edw].[Dim_User] s where s.CompanyID = @CompanyID and s.UserID = @UserID
			  end


              if (@Debug = 1)
              begin
                     select @UserID 'UserID',  @LoggedInUserId 'LoggedInUserId'
              end

			   ------Start Work/Unaccounted/Private Time Calculation	
			
					Select 'totalTime' as totalTime,'Total Time / Hrs' as title,
					(OnlineTimeSpent+OfflineTimeSpent+UnaccountedTimeSpent+PrivateTimeSpent)/60.0 as value,'100' as per from edw.Fact_DailyUser Where DIm_Userid = @UserID and ActivityDate =@StartDate
					UNION ALL
					Select 'Work' as totalTime,'Work Time / Hrs' as title,
					(OnlineTimeSpent+OfflineTimeSpent)/60.0 as value,Round(((OnlineTimeSpent+OfflineTimeSpent)/EstimatedTimeSpent) * 100,2) as per
					from edw.Fact_DailyUser Where DIm_Userid = @UserID and ActivityDate =@StartDate
					UNION ALL
					Select 'Unaccounted' as totalTime,'Unaccounted Time / Hrs' as title,
					UnaccountedTimeSpent/60.0 as value,Round((UnaccountedTimeSpent/EstimatedTimeSpent) * 100,2) as per
					from edw.Fact_DailyUser Where DIm_Userid = @UserID and ActivityDate = @StartDate
					UNION ALL
					Select 'Private' as totalTime,'Private Time / Hrs' as title,					
					PrivateTimeSpent/60.0,
					Round((PrivateTimeSpent/EstimatedTimeSpent) * 100,2) per
					from edw.Fact_DailyUser Where DIm_Userid = @UserID and ActivityDate = @StartDate	
			
			  ------End Work/Unaccounted/Private Time Calculation			

              create table #TempActivitiesBase
              (
                     ID int identity(1,1),UserID integer, StartTime datetime2, EndTime datetime2, TimeZoneOffSet int, PurposeID integer, WorkCategory nvarchar(4000),
					 ActivityCategoryID int, [ActivityCategoryName] nvarchar(4000), AppID int,AppName nvarchar(4000), FileOrUrlName nvarchar(4000) ,IsUserModified bit,
					 StartTimeInUTC datetime2, EndTimeInUTC datetime2
              )

			  insert into #TempActivitiesBase(UserID ,StartTime,  EndTime, TimeZoneOffSet, PurposeID, ActivityCategoryID,  AppID, FileOrUrlName,IsUserModified, StartTimeInUTC, EndTimeInUTC)
              select s.Dim_UserID, convert (datetime2(0), s.StartTimeInLocal),  convert (datetime2(0),s.EndTimeInLocal), s.TimeZoneOffSet, s.PurposeID, s.Dim_ActivityCategoryID, s.Dim_AppMasterID, case when s.PurposeID = -1 then '' else s.FileOrUrlName end,0 as IsUserModified, 
			  dateadd(minute, -[TimeZoneOffSet],CONVERT(datetime2(0),s.StartTimeInLocal)), dateadd(minute,-[TimeZoneOffSet],CONVERT(datetime2(0),s.EndTimeInLocal))
              from [edw].[Fact_TimeSlot] s 
			  where s.Dim_CompanyID = @CompanyID 
			  and s.[ActivityDate] between  @StartDate and @EndDate and s.[ActivityDate] < (GETDATE() - @EditedDay)
			  and s.IsActive = 1
			  and s.Dim_UserID = @UserID 

			  insert into #TempActivitiesBase(UserID ,StartTime,  EndTime, TimeZoneOffSet, PurposeID, ActivityCategoryID,  AppID, FileOrUrlName,IsUserModified, StartTimeInUTC, EndTimeInUTC)
              select s.Dim_UserID, convert (datetime2(0), s.StartTimeInLocal),  convert (datetime2(0),s.EndTimeInLocal), s.TimeZoneOffSet, s.PurposeID, s.Dim_ActivityCategoryID, s.Dim_AppMasterID, case when s.PurposeID = -1 then '' else s.FileOrUrlName end,IsUserModified as IsUserModified, 
			  dateadd(minute, -[TimeZoneOffSet],CONVERT(datetime2(0),s.StartTimeInLocal)), dateadd(minute,-[TimeZoneOffSet],CONVERT(datetime2(0),s.EndTimeInLocal))
              from [edw].[Stg_TimeSlot] s 
			  where s.Dim_CompanyID = @CompanyID 
			  and s.[ActivityDate] between  @StartDate and @EndDate and s.[ActivityDate] >= (GETDATE() - @EditedDay)
			  and s.IsActive = 1
              and s.Dim_UserID = @UserID 

			  
              -- TODO: Fill gaps with Unaccounted, avoid overlap and avoid Day End greater than today 
              -- Adjust overlap.  say 2 pm is end and 1.30 pm is start of next..adjust 2 pm end to 1.30 pm

              select @DayFirstActivityTimeUTC = MIN(t.StartTimeInUTC), @DayFirstActivityTime = MIN(t.StartTime), @DayEndActivityTime = MAX(t.EndTime) from #TempActivitiesBase t 
              
			  select @DayFirstTimeZoneOffset = t.TimeZoneOffset from #TempActivitiesBase t  where t.StartTime = @DayFirstActivityTime

			  select @DayEndTimeZoneOffset = t.TimeZoneOffset from #TempActivitiesBase t  where t.EndTime = @DayEndActivityTime

              -- where t.ActivityCategoryID <> 0 .. TODO: required for AccountedFirst and LastTime
              -- TODO in Analyzer: if DayEnd exceeds 00:00:midnight of end date ..Round it to the start of the next day

              if ( convert(Date, @DayEndActivityTime) > @DateNextToEndDate ) 
              begin
                     update t
                     set
                           t.EndTime = @DateNextToEndDate
                     from #TempActivitiesBase t
                     where
                           convert(Date, @DayEndActivityTime) > @DateNextToEndDate

              end

			 /* ****************************Temp Table contains TimeSlot between Start and end time***************** */
				;WITH aCTE
				AS(
				    SELECT 
				        @StartDateTime AS StartDateTime,
				        DATEADD(MINUTE,@iInterval,@StartDateTime) AS EndDateTime
				    UNION ALL
				    SELECT 
				        DATEADD(MINUTE,@iInterval,StartDateTime),
				        DATEADD(MINUTE,@iInterval,EndDateTime)
				    FROM aCTE
				    WHERE
				        DATEADD(MINUTE,@iInterval,EndDateTime) <= @EndDateTime
				)

				SELECT StartDateTime as StartTime,EndDateTime as EndTime,-1 as PurposeID,0 as ActivityCategoryID,0 as AppID,'' as FileOrUrlName
				 INTO #StartEnd_Temp
				FROM aCTE

			    IF (@DayFirstActivityTime > @StartDateTime)
					BEGIN
                     
							IF @IsListView = 0
							BEGIN
								IF DATEADD(HOUR, DATEDIFF(HOUR, 0, @DayFirstActivityTime),0) <> @DayFirstActivityTime
								BEGIN
										INSERT INTO #TempActivitiesBase(UserID,StartTime,  EndTime, TimeZoneOffset, PurposeID, ActivityCategoryID,  AppID, FileOrUrlName,IsUserModified)
										SELECT @UserID,DATEADD(HOUR, DATEDIFF(HOUR, 0, @DayFirstActivityTime),0), @DayFirstActivityTime, @DayFirstTimeZoneOffset, -1, 0, 0, '',0  
								END
							END
							ELSE
							BEGIN
                           
								INSERT INTO #TempActivitiesBase(UserID,StartTime,  EndTime, TimeZoneOffset, PurposeID, ActivityCategoryID,  AppID, FileOrUrlName,IsUserModified)
					SELECT @UserID,@StartDateTime, @DayFirstActivityTime, @DayFirstTimeZoneOffset, -1, 0, 0, '',0
						END
				END


			IF (@DayEndActivityTime < @DateNextToEndDate)
			BEGIN
					IF DATEADD(HOUR,DATEDIFF(HOUR,0,DATEADD(HOUR, 1, @DayEndActivityTime )),0) < @DateNextToEndDate AND @IsListView = 0
					BEGIN
							INSERT INTO #TempActivitiesBase(UserID,StartTime,  EndTime, TimeZoneOffset, PurposeID, ActivityCategoryID,  AppID, FileOrUrlName,IsUserModified)
							SELECT @UserID,@DayEndActivityTime, DATEADD(HOUR,DATEDIFF(HOUR,0,DATEADD(HOUR, 1, @DayEndActivityTime)),0) , @DayEndTimeZoneOffset, -1, 0, 0, '' ,0                                   
					END
                           
				ELSE
				BEGIN
					INSERT INTO #TempActivitiesBase(UserID,StartTime,  EndTime, TimeZoneOffset, PurposeID, ActivityCategoryID,  AppID, FileOrUrlName,IsUserModified)
					SELECT @UserID,@DayEndActivityTime, @DateNextToEndDate, @DayEndTimeZoneOffset, -1, 0, 0, ''  ,0
				END
			END

		update t
		set
			t.StartTimeInUTC = a.EndTimeInUTC
			,t.TimeSpent = datediff(minute, a.EndTimeInUTC, t.EndTimeInUTC)
		from [EDW].[Fact_TimeSlot] t
		inner join
		(
			Select s.UserID, s.StartTime,  s.EndTime, s.TimeZoneOffset, s.StartTimeInUTC, s.EndTimeInUTC, LEAD(s.startTime, 1, '1900') OVER(PARTITION BY s.UserID ORDER BY s.StartTime, s.EndTime) as NextStartTime,
			CASE WHEN s.EndTime = LEAD(s.startTime, 1, '1900') OVER(PARTITION BY s.UserID ORDER BY s.StartTime, s.EndTime) THEN 0 ELSE 1 END as HASGAP,s.IsUserModified, s.PurposeID
			FROM #TempActivitiesBase s
		) as a
		on
			t.Dim_UserID = a.UserId and t.StartTimeInLocal = a.NextStartTime 	
		WHERE  a.NextStartTime <> '1900-01-01 00:00:00.000' and a.HASGAP = 1 and a.NextStartTime < a.EndTime
		and t.Dim_CompanyID = @CompanyID and  t.ActivityDate = @StartDate 
	

		insert into #TempActivitiesBase(UserID, StartTime,  EndTime, TimeZoneOffset, PurposeID, ActivityCategoryID,  AppID, FileOrUrlName,IsUserModified)
		Select @UserID as UserID, a.EndTime StartTime,a.ENDTIME1 as EndTime, a.TimeZoneOffset, -1 as PurposeID,0 as ActivityCategoryID,0 as AppID,'' as FileOrUrlName,IsUserModified FROM
		(Select  s.EndTime, s.TimeZoneOffset, LEAD(s.startTime, 1, '1900') OVER(PARTITION BY s.UserID ORDER BY s.StartTime, s.EndTime) as ENDTIME1 ,
		CASE WHEN s.EndTime = LEAD(s.startTime, 1, '1900') OVER(PARTITION BY s.UserID ORDER BY s.StartTime, s.EndTime) THEN 0 ELSE 1 END as HASGAP,s.IsUserModified, s.PurposeID
		FROM #TempActivitiesBase s) a
		Where a.ENDTIME1 <> '1900-01-01 00:00:00.000' and HASGAP = 1 and a.ENDTIME1 >= a.EndTime 
		
              -- Add Day Start and Day end gaps
  
              ; WITH CTEUserActivities
              AS
              (
                     SELECT t.ID, t.EndTime, Lead(t.StartTime, 1) OVER( ORDER BY t.StartTime, t.EndTime ) NextSlotStartTime
                     FROM #TempActivitiesBase t
              )
              update t
              set
                     t.EndTime = s.NextSlotStartTime
              from #TempActivitiesBase t
              inner join CTEUserActivities s
              on
                     t.ID = s.ID
              where
                     s.NextSlotStartTime <  s.EndTime	
			
              -- Update ActivityCategory
              update t
              set
                     t.[ActivityCategoryName] = s.[ActivityCategoryName]
              from #TempActivitiesBase t
              inner join [edw].[Dim_ActivityCategory] s
              on
                     s.CompanyID = @CompanyID and t.ActivityCategoryID = s.ID --and t.PurposeID <> -1

			  --Update AppName
              update t
              set
                     [AppName] = s.AppName
              from #TempActivitiesBase t
              inner join [edw].[Dim_AppMaster] s
              on
                     s.CompanyID = @CompanyID and t.AppID = s.ID --and t.PurposeID <> -1	

		IF (convert(Date, @DayFirstActivityTimeUTC) <> convert(Date,getUtcdate()))
			update #TempActivitiesBase
			set
			[EndTime] = DATEADD(MS, -1, CONVERT(DATETIME2, @DateNextToEndDate))
   			Where EndTime = (Select Max(EndTime) From #TempActivitiesBase)	
		ELSE
			delete from #TempActivitiesBase			
   			Where EndTime = (Select Max(EndTime) From #TempActivitiesBase) and PurposeID = -1 and AppID = 0 and ActivityCategoryID = 0 

			--select * from #TempActivitiesBase

			create table #FinalActivities
            (
                ID int identity(1,1), StartTime datetime2, EndTime datetime2, TimeZoneOffset int,  PurposeID integer,  ActivityCategoryID int, [ActivityCategoryName] nvarchar(4000), AppID int,  AppName nvarchar(4000), FileOrUrlName nvarchar(4000) ,IsUserModified BIT
            )
			
            if (@Page = 0)
              begin
					insert into #FinalActivities
					(
						StartTime, EndTime, TimeZoneOffset, PurposeID,  ActivityCategoryID, [ActivityCategoryName], AppID,  AppName, FileOrUrlName ,IsUserModified
					) 
					select 
						StartTime, EndTime, t.TimeZoneOffset, PurposeID, ActivityCategoryID,							   
						case when @LoggedInUserId = @UserID then IsNull([ActivityCategoryName], '') ELSE '' END as ActivityCategoryName, AppID,
						case when @LoggedInUserId = @UserID then IsNull(AppName, '') ELSE '' END as AppName,
						case when @LoggedInUserId = @UserID then  IsNull(FileOrUrlName, '') Else '' END  as FileOrUrlName,IsUserModified
						from #TempActivitiesBase t
						where t.StartTime <> t.EndTime and t.PurposeID = -1
						order by t.StartTime asc

					insert into #FinalActivities
					(
						StartTime, EndTime, TimeZoneOffset, PurposeID,  ActivityCategoryID, [ActivityCategoryName], AppID,  AppName, FileOrUrlName ,IsUserModified
					) 
					select 
							StartTime, EndTime, t.TimeZoneOffset, PurposeID, ActivityCategoryID,							   
							IsNull([ActivityCategoryName], '') ActivityCategoryName, AppID,
							IsNull(AppName, '') AppName,
							IsNull(FileOrUrlName, '') FileOrUrlName, IsUserModified
						from #TempActivitiesBase t
						where t.StartTime <> t.EndTime and t.PurposeID <> -1
						order by t.StartTime asc

					Select * from #FinalActivities order by StartTime asc
                     
					return 0
              end
              else begin
                    declare @Records int = 0, @TotalPages int = 0
					insert into #FinalActivities
					(
						StartTime, EndTime, TimeZoneOffset, PurposeID,  ActivityCategoryID, [ActivityCategoryName], AppID,  AppName, FileOrUrlName ,IsUserModified
					) 
					select 
							StartTime, EndTime, t.TimeZoneOffset, PurposeID, ActivityCategoryID, 
							case when @LoggedInUserId = @UserID then IsNull([ActivityCategoryName], '') ELSE '' END as ActivityCategoryName, AppID,  
							case when @LoggedInUserId = @UserID then IsNull(AppName, '') ELSE '' END as AppName,
							case when @LoggedInUserId = @UserID then  IsNull(FileOrUrlName, '') Else '' END  as FileOrUrlName,IsUserModified
						from #TempActivitiesBase t

						where t.StartTime <> t.EndTime and t.PurposeID = -1
						order by t.StartTime asc

					insert into #FinalActivities
					(
						StartTime, EndTime, TimeZoneOffset, PurposeID,  ActivityCategoryID, [ActivityCategoryName], AppID,  AppName, FileOrUrlName ,IsUserModified
					) 
					select 
							StartTime, EndTime, t.TimeZoneOffset, PurposeID, ActivityCategoryID, 
							IsNull([ActivityCategoryName], '') ActivityCategoryName, AppID,  
							IsNull(AppName, '') AppName,
							IsNull(FileOrUrlName, '') FileOrUrlName,IsUserModified
						from #TempActivitiesBase t
						where t.StartTime <> t.EndTime and t.PurposeID <> -1
						order by t.StartTime asc

                     set @Records = @@RowCount
                     set @TotalPages = @Records / @PageSize

                     if ( ( @Records % @PageSize ) <> 0)
                     begin
                     
                           set @TotalPages = @TotalPages + 1
                     
                     end 

                     declare @BeginPage int =  (@Page - 1) * @PageSize + 1

                     declare @EndPage int = @BeginPage + ( @PageSize - 1)

                     if (@Debug = 1)
                     begin

                           select @Records 'Records', @TotalPages 'TotalPages' , @BeginPage 'BeginPage' , @EndPage 'EndPage'
                     end

                     select 
                           StartTime, EndTime, t.TimeZoneOffset, PurposeID, ActivityCategoryID, IsNull([ActivityCategoryName], '') [ActivityCategoryName], AppID,  IsNull(AppName, '') AppName, IsNull(FileOrUrlName, '') FileOrUrlName,IsUserModified
                     from #FinalActivities t
                     where @Page = 0 OR (t.ID between @BeginPage and @EndPage)


					return @TotalPages


              end
END

GO
/****** Object:  StoredProcedure [edw].[sproc_GetUserActivitiesk]    Script Date: 9/10/2021 8:10:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [edw].[sproc_GetUserActivitiesk]
(
		@CompanyID int
       ,@LoggedInUserId int = 0
       ,@UserEmail nvarchar(4000)
       ,@UserID int
       ,@StartDate date
       ,@EndDate date
       ,@Page int = 0
       ,@PageSize int = 0
       ,@IsListView TINYINT = 0
       ,@Debug tinyint = 0

)
AS
BEGIN

              declare @DayFirstActivityTime datetime, 
					  @DayEndActivityTime datetime,
					  @DateNextToEndDate Date = DATEADD(DAY, 1 , @EndDate),
					  @iInterval AS INT = 30,
				      @StartDateTime datetime = @StartDate,
					  @EndDateTime datetime =  @EndDate,
					  @DayFirstTimeZoneOffset int,
					  @DayEndTimeZoneOffset int,
					  @EditedDay AS INT = 15,
					  @DayFirstActivityTimeUTC datetime,
					  @EstimatedTimeSpent real = 0,
					  @OnlineTimeSpent real = 0,
					  @OfflineTimeSpent real = 0,
					  @PrivateTimeSpent real = 0,
					  @UnaccountedTimeSpent real = 0

              if (@UserEmail <> '')
              begin
                     select @UserID = s.ID from [edw].[Dim_User] s where s.CompanyID = @CompanyID and s.UserEmail = @UserEmail
              end
			  else
			  begin				
				     select @UserID = s.ID from [edw].[Dim_User] s where s.CompanyID = @CompanyID and s.UserID = @UserID
			  end


              if (@Debug = 1)
              begin
                     select @UserID 'UserID',  @LoggedInUserId 'LoggedInUserId'
              end

			  --------

			  Select @EstimatedTimeSpent = k.OnlineTimeSpent+ k.OfflineTimeSpent+ k.PrivateTimeSpent + k.UnaccountedTimeSpent
					,@OnlineTimeSpent = k.OnlineTimeSpent, @OfflineTimeSpent = k.OfflineTimeSpent
					,@PrivateTimeSpent = k.PrivateTimeSpent, @UnaccountedTimeSpent = k.UnaccountedTimeSpent

			  FROM edw.Fact_DailyUser k Where DIm_Userid = @UserID and ActivityDate = @StartDate

			   select @UserID 'UserID',  @LoggedInUserId 'LoggedInUserId'

			   ------Start Work/Unaccounted/Private Time Calculation	

					Select 'totalTime' as totalTime,'Total Time / Hrs' as title,
					(@EstimatedTimeSpent)/60.0 as value,'100' as per 
					UNION ALL
					Select 'Work' as totalTime,'Work Time / Hrs' as title,
					(@OnlineTimeSpent + @OfflineTimeSpent)/60.0 as value,
					Round(((@OnlineTimeSpent + @OfflineTimeSpent)/@EstimatedTimeSpent) * 100,2) as per 
					UNION ALL
					Select 'Unaccounted' as totalTime,'Unaccounted Time / Hrs' as title,
					@UnaccountedTimeSpent/60.0 as value,Round((@UnaccountedTimeSpent / @EstimatedTimeSpent) * 100,2) as per
					UNION ALL
					Select 'Private' as totalTime,'Private Time / Hrs' as title,					
					@PrivateTimeSpent /60.0,
					Round((@PrivateTimeSpent/@EstimatedTimeSpent) * 100,2) per


			  ------End Work/Unaccounted/Private Time Calculation			





              create table #TempActivitiesBase
              (
                     ID int identity(1,1),UserID integer, StartTime datetime2, EndTime datetime2, TimeZoneOffSet int, PurposeID integer, WorkCategory nvarchar(4000),
					 ActivityCategoryID int, [ActivityCategoryName] nvarchar(4000), AppID int,AppName nvarchar(4000),WebAppID int,WebAppName nvarchar(4000),
					 FileOrUrlName nvarchar(4000) ,IsUserModified bit, StartTimeInUTC datetime2, EndTimeInUTC datetime2
              )

			  insert into #TempActivitiesBase(UserID ,StartTime,  EndTime, TimeZoneOffSet, PurposeID, ActivityCategoryID, AppID, WebAppID, FileOrUrlName, IsUserModified, StartTimeInUTC, EndTimeInUTC)
              select s.Dim_UserID, convert (datetime2(0), s.StartTimeInLocal),  convert (datetime2(0),s.EndTimeInLocal), s.TimeZoneOffSet, s.PurposeID, s.Dim_ActivityCategoryID, s.Dim_AppMasterID,s.Dim_WebAppID,
			  s.FileOrUrlName,0 as IsUserModified, 
			  dateadd(minute, -[TimeZoneOffSet],CONVERT(datetime2(0),s.StartTimeInLocal)), dateadd(minute,-[TimeZoneOffSet],CONVERT(datetime2(0),s.EndTimeInLocal))
              from [edw].[Fact_TimeSlot] s 
			  where s.Dim_CompanyID = @CompanyID 
			  and s.[ActivityDate] between  @StartDate and @EndDate and s.[ActivityDate] < (GETDATE() - @EditedDay)
			  and s.IsActive = 1
			  and s.Dim_UserID = @UserID 

			  insert into #TempActivitiesBase(UserID ,StartTime,  EndTime, TimeZoneOffSet, PurposeID, ActivityCategoryID,  AppID, WebAppID, FileOrUrlName,IsUserModified, StartTimeInUTC, EndTimeInUTC)
              select s.Dim_UserID, convert (datetime2(0), s.StartTimeInLocal),  convert (datetime2(0),s.EndTimeInLocal), s.TimeZoneOffSet, s.PurposeID, s.Dim_ActivityCategoryID, s.Dim_AppMasterID,s.Dim_WebAppID,
			  s.FileOrUrlName,IsUserModified as IsUserModified, 
			  dateadd(minute, -[TimeZoneOffSet],CONVERT(datetime2(0),s.StartTimeInLocal)), dateadd(minute,-[TimeZoneOffSet],CONVERT(datetime2(0),s.EndTimeInLocal))
              from [edw].[Stg_TimeSlot] s 
			  where s.Dim_CompanyID = @CompanyID 
			  and s.[ActivityDate] between  @StartDate and @EndDate and s.[ActivityDate] >= (GETDATE() - @EditedDay)
			  and s.IsActive = 1
              and s.Dim_UserID = @UserID 

			  
              -- TODO: Fill gaps with Unaccounted, avoid overlap and avoid Day End greater than today 
              -- Adjust overlap.  say 2 pm is end and 1.30 pm is start of next..adjust 2 pm end to 1.30 pm

              select @DayFirstActivityTimeUTC = MIN(t.StartTimeInUTC), @DayFirstActivityTime = MIN(t.StartTime), @DayEndActivityTime = MAX(t.EndTime) from #TempActivitiesBase t 
              
			  select @DayFirstTimeZoneOffset = t.TimeZoneOffset from #TempActivitiesBase t  where t.StartTime = @DayFirstActivityTime

			  select @DayEndTimeZoneOffset = t.TimeZoneOffset from #TempActivitiesBase t  where t.EndTime = @DayEndActivityTime

              -- where t.ActivityCategoryID <> 0 .. TODO: required for AccountedFirst and LastTime
              -- TODO in Analyzer: if DayEnd exceeds 00:00:midnight of end date ..Round it to the start of the next day

              if ( convert(Date, @DayEndActivityTime) > @DateNextToEndDate ) 
              begin
                     update t
                     set
                           t.EndTime = @DateNextToEndDate
                     from #TempActivitiesBase t
                     where
                           convert(Date, @DayEndActivityTime) > @DateNextToEndDate

              end

			 /* ****************************Temp Table contains TimeSlot between Start and end time***************** */
				;WITH aCTE
				AS(
				    SELECT 
				        @StartDateTime AS StartDateTime,
				        DATEADD(MINUTE,@iInterval,@StartDateTime) AS EndDateTime
				    UNION ALL
				    SELECT 
				        DATEADD(MINUTE,@iInterval,StartDateTime),
				        DATEADD(MINUTE,@iInterval,EndDateTime)
				    FROM aCTE
				    WHERE
				        DATEADD(MINUTE,@iInterval,EndDateTime) <= @EndDateTime
				)

				SELECT StartDateTime as StartTime,EndDateTime as EndTime,-1 as PurposeID,0 as ActivityCategoryID,0 as AppID,'' as FileOrUrlName
				 INTO #StartEnd_Temp
				FROM aCTE

			    IF (@DayFirstActivityTime > @StartDateTime)
					BEGIN
                     
							IF @IsListView = 0
							BEGIN
								IF DATEADD(HOUR, DATEDIFF(HOUR, 0, @DayFirstActivityTime),0) <> @DayFirstActivityTime
								BEGIN
										INSERT INTO #TempActivitiesBase(UserID,StartTime,  EndTime, TimeZoneOffset, PurposeID, ActivityCategoryID,  AppID, FileOrUrlName,IsUserModified)
										SELECT @UserID,DATEADD(HOUR, DATEDIFF(HOUR, 0, @DayFirstActivityTime),0), @DayFirstActivityTime, @DayFirstTimeZoneOffset, -1, 0, 0, '',0  
								END
							END
							ELSE
							BEGIN
                           
								INSERT INTO #TempActivitiesBase(UserID,StartTime,  EndTime, TimeZoneOffset, PurposeID, ActivityCategoryID,  AppID, FileOrUrlName,IsUserModified)
					SELECT @UserID,@StartDateTime, @DayFirstActivityTime, @DayFirstTimeZoneOffset, -1, 0, 0, '',0
						END
				END


			IF (@DayEndActivityTime < @DateNextToEndDate)
			BEGIN
					IF DATEADD(HOUR,DATEDIFF(HOUR,0,DATEADD(HOUR, 1, @DayEndActivityTime )),0) < @DateNextToEndDate AND @IsListView = 0
					BEGIN
							INSERT INTO #TempActivitiesBase(UserID,StartTime,  EndTime, TimeZoneOffset, PurposeID, ActivityCategoryID,  AppID, FileOrUrlName,IsUserModified)
							SELECT @UserID,@DayEndActivityTime, DATEADD(HOUR,DATEDIFF(HOUR,0,DATEADD(HOUR, 1, @DayEndActivityTime)),0) , @DayEndTimeZoneOffset, -1, 0, 0, '' ,0                                   
					END
                           
				ELSE
				BEGIN
					INSERT INTO #TempActivitiesBase(UserID,StartTime,  EndTime, TimeZoneOffset, PurposeID, ActivityCategoryID,  AppID, FileOrUrlName,IsUserModified)
					SELECT @UserID,@DayEndActivityTime, @DateNextToEndDate, @DayEndTimeZoneOffset, -1, 0, 0, ''  ,0
				END
			END


---- update Starttime
		Select * INTO #Ismodified from #TempActivitiesBase
		where IsUserModified = 1

		Select a.UserId,a.StartTime,max(b.EndTime) as EndTime INTO #Ismodified1
		from #Ismodified a
		INNER JOIN #TempActivitiesBase b
		On a.Userid = b.Userid and b.EndTime Between a.STartTime AND DateAdd(MINUTE, 1, a.STartTime)
		group by a.UserId,a.STartTime

		Update t
		Set t.StartTimeInUTC = DateAdd(minute,-t.TimeZoneOffset,a.EndTime)
		,t.TimeSpent = datediff(second, a.EndTime, t.EndTimeInLocal) /60.0
		from [EDW].[stg_TimeSlot] t with (nolock)
		inner join #Ismodified1 a
		On t.Dim_userid = a.userid and t.StartTimeInLocal = a.StartTime

		Update t
		Set t.StartTime = a.EndTime
		,t.StartTimeInUTC = DateAdd(Minute,-t.TimeZoneOffset,a.EndTime)
		from #TempActivitiesBase t
		inner join #Ismodified1 a
		On t.userid = a.userid and t.StartTime = a.StartTime
		--- update Endtime
		Select a.UserId,a.EndTime,min(b.startTime) as Starttime INTO #Ismodified2
		from #Ismodified a
		INNER JOIN #TempActivitiesBase b
		On a.Userid = b.Userid and b.startTime Between a.EndTime AND DateAdd(MINUTE, 1, a.EndTime)
		group by a.UserId,a.EndTime

		Update t
		Set t.EndTimeInUTC = DateAdd(Minute,-t.TimeZoneOffset,a.StartTime)
		,t.TimeSpent = datediff(second, t.startTimeInLocal, a.startTime) /60.0
		from [EDW].[stg_TimeSlot] t with (nolock)
		inner join #Ismodified2 a
		On t.Dim_userid = a.userid and t.EndTimeInLocal = a.EndTime

		Update t
		Set t.EndTime = a.StartTime
		,t.EndTimeInUTC = DateAdd(Minute,-t.TimeZoneOffset,a.StartTime)
		from #TempActivitiesBase t
		inner join #Ismodified2 a
		On t.userid = a.userid and t.EndTime = a.EndTime


		----


		update t
		set
			t.StartTimeInUTC = a.EndTimeInUTC
			,t.TimeSpent = datediff(minute, a.EndTimeInUTC, t.EndTimeInUTC)
		from Edw.Fact_TimeSlot t
		inner join
		(
			Select s.UserID, s.StartTime,  s.EndTime, s.TimeZoneOffset, s.StartTimeInUTC, s.EndTimeInUTC, LEAD(s.startTime, 1, '1900') OVER(PARTITION BY s.UserID ORDER BY s.StartTime, s.EndTime) as NextStartTime,
			CASE WHEN s.EndTime = LEAD(s.startTime, 1, '1900') OVER(PARTITION BY s.UserID ORDER BY s.StartTime, s.EndTime) THEN 0 ELSE 1 END as HASGAP,s.IsUserModified, s.PurposeID
			FROM #TempActivitiesBase s
		) as a
		on
			t.Dim_UserID = a.UserId and t.StartTimeInLocal = a.NextStartTime 	
		WHERE  a.NextStartTime <> '1900-01-01 00:00:00.000' and a.HASGAP = 1 and a.NextStartTime < a.EndTime
		and t.Dim_CompanyID = @CompanyID and  t.ActivityDate = @StartDate 
	

		insert into #TempActivitiesBase(UserID, StartTime,  EndTime, TimeZoneOffset, PurposeID, ActivityCategoryID,  AppID, FileOrUrlName,IsUserModified)
		Select @UserID as UserID, a.EndTime StartTime,a.ENDTIME1 as EndTime, a.TimeZoneOffset, -1 as PurposeID,0 as ActivityCategoryID,0 as AppID,'' as FileOrUrlName,IsUserModified FROM
		(Select  s.EndTime, s.TimeZoneOffset, LEAD(s.startTime, 1, '1900') OVER(PARTITION BY s.UserID ORDER BY s.StartTime, s.EndTime) as ENDTIME1 ,
		CASE WHEN s.EndTime = LEAD(s.startTime, 1, '1900') OVER(PARTITION BY s.UserID ORDER BY s.StartTime, s.EndTime) THEN 0 ELSE 1 END as HASGAP,s.IsUserModified, s.PurposeID
		FROM #TempActivitiesBase s) a
		Where a.ENDTIME1 <> '1900-01-01 00:00:00.000' and HASGAP = 1 and a.ENDTIME1 >= a.EndTime 
		
              -- Add Day Start and Day end gaps
  
              ; WITH CTEUserActivities
              AS
              (
                     SELECT t.ID, t.EndTime, Lead(t.StartTime, 1) OVER( ORDER BY t.StartTime, t.EndTime ) NextSlotStartTime
                     FROM #TempActivitiesBase t
              )
              update t
              set
                     t.EndTime = s.NextSlotStartTime
              from #TempActivitiesBase t
              inner join CTEUserActivities s
              on
                     t.ID = s.ID
              where
                     s.NextSlotStartTime <  s.EndTime	
			
              -- Update ActivityCategory
              update t
              set
                     t.[ActivityCategoryName] = s.[ActivityCategoryName]
              from #TempActivitiesBase t
              inner join [edw].[Dim_ActivityCategory] s
              on
                     s.CompanyID = @CompanyID and t.ActivityCategoryID = s.ID --and t.PurposeID <> -1

			  --Update AppName
              update t
              set
                     [AppName] = s.AppName
              from #TempActivitiesBase t
              inner join [edw].[Dim_AppMaster] s
              on
                     s.CompanyID = @CompanyID and t.AppID = s.ID --and t.PurposeID <> -1

			 --Update WebAppName
              update t
              set
                     [WebAppName] = s.WebAppName
              from #TempActivitiesBase t
              inner join [edw].[Dim_WebApp] s
              on
                     s.CompanyID = @CompanyID and t.WebAppID = s.ID --and t.PurposeID <> -1

		IF (convert(Date, @DayFirstActivityTimeUTC) <> convert(Date,getUtcdate()))
			update #TempActivitiesBase
			set
			[EndTime] = DATEADD(MS, -1, CONVERT(DATETIME2, @DateNextToEndDate))
   			Where EndTime = (Select Max(EndTime) From #TempActivitiesBase)	
		ELSE
			delete from #TempActivitiesBase			
   			Where EndTime = (Select Max(EndTime) From #TempActivitiesBase) and PurposeID = -1 and AppID = 0 and ActivityCategoryID = 0 

			--select * from #TempActivitiesBase

			create table #FinalActivities
            (
                ID int identity(1,1), StartTime datetime2, EndTime datetime2, TimeZoneOffset int,  PurposeID integer,  ActivityCategoryID int, [ActivityCategoryName] nvarchar(4000), AppID int,  AppName nvarchar(4000), FileOrUrlName nvarchar(4000) ,IsUserModified BIT
            )
			
            if (@Page = 0)
              begin
					insert into #FinalActivities
					(
						StartTime, EndTime, TimeZoneOffset, PurposeID,  ActivityCategoryID, [ActivityCategoryName], AppID,  AppName, FileOrUrlName ,IsUserModified
					) 
					select 
						StartTime, EndTime, t.TimeZoneOffset, PurposeID, ActivityCategoryID,							   
						case when @LoggedInUserId = @UserID then IsNull([ActivityCategoryName], '') ELSE '' END as ActivityCategoryName,
						Case when AppID is null then WebAppID end as AppID,
						case when @LoggedInUserId = @UserID then IsNull(case when AppName is null then WebAppName else AppName end, '') ELSE '' END as AppName,
						case when @LoggedInUserId = @UserID then  IsNull(FileOrUrlName, '') Else '' END  as FileOrUrlName,IsUserModified
						from #TempActivitiesBase t
						where t.StartTime <> t.EndTime and t.PurposeID = -1
						order by t.StartTime asc

					insert into #FinalActivities
					(
						StartTime, EndTime, TimeZoneOffset, PurposeID,  ActivityCategoryID, [ActivityCategoryName], AppID,  AppName, FileOrUrlName ,IsUserModified
					) 
					select 
							StartTime, EndTime, t.TimeZoneOffset, PurposeID, ActivityCategoryID,							   
							IsNull([ActivityCategoryName], '') ActivityCategoryName,
							Case when AppID is null then WebAppID else AppID end as AppID,
							IsNull(Case when AppName is null then WebAppName else AppName end, '') AppName,
							IsNull(FileOrUrlName, '') FileOrUrlName, IsUserModified
						from #TempActivitiesBase t
						where t.StartTime <> t.EndTime and t.PurposeID <> -1
						order by t.StartTime asc

					Select * from #FinalActivities order by StartTime asc
                     
					return 0
              end
              else begin
                    declare @Records int = 0, @TotalPages int = 0
					insert into #FinalActivities
					(
						StartTime, EndTime, TimeZoneOffset, PurposeID,  ActivityCategoryID, [ActivityCategoryName], AppID,  AppName, FileOrUrlName ,IsUserModified
					) 
					select 
							StartTime, EndTime, t.TimeZoneOffset, PurposeID, ActivityCategoryID, 
							case when @LoggedInUserId = @UserID then IsNull([ActivityCategoryName], '') ELSE '' END as ActivityCategoryName,
							Case when AppID is null then WebAppID else AppID end as AppID,  
							case when @LoggedInUserId = @UserID then IsNull(case when AppName is null then WebAppName else AppName end, '') ELSE '' END as AppName,
							case when @LoggedInUserId = @UserID then  IsNull(FileOrUrlName, '') Else '' END  as FileOrUrlName,IsUserModified
						from #TempActivitiesBase t

						where t.StartTime <> t.EndTime and t.PurposeID = -1
						order by t.StartTime asc

					insert into #FinalActivities
					(
						StartTime, EndTime, TimeZoneOffset, PurposeID,  ActivityCategoryID, [ActivityCategoryName], AppID,  AppName, FileOrUrlName ,IsUserModified
					) 
					select 
							StartTime, EndTime, t.TimeZoneOffset, PurposeID, ActivityCategoryID, 
							IsNull([ActivityCategoryName], '') ActivityCategoryName, 
							Case when AppID is null then WebAppID else AppID end as AppID,
							IsNull(Case when AppName is null then WebAppName else AppName end, '') AppName,
							IsNull(FileOrUrlName, '') FileOrUrlName,IsUserModified
						from #TempActivitiesBase t
						where t.StartTime <> t.EndTime and t.PurposeID <> -1
						order by t.StartTime asc

                     set @Records = @@RowCount
                     set @TotalPages = @Records / @PageSize

                     if ( ( @Records % @PageSize ) <> 0)
                     begin
                     
                           set @TotalPages = @TotalPages + 1
                     
                     end 

                     declare @BeginPage int =  (@Page - 1) * @PageSize + 1

                     declare @EndPage int = @BeginPage + ( @PageSize - 1)

                     if (@Debug = 1)
                     begin

                           select @Records 'Records', @TotalPages 'TotalPages' , @BeginPage 'BeginPage' , @EndPage 'EndPage'
                     end

                     select 
                           StartTime, EndTime, t.TimeZoneOffset, PurposeID, ActivityCategoryID, IsNull([ActivityCategoryName], '') [ActivityCategoryName], AppID,  IsNull(AppName, '') AppName, IsNull(FileOrUrlName, '') FileOrUrlName,IsUserModified
                     from #FinalActivities t
                     where @Page = 0 OR (t.ID between @BeginPage and @EndPage)


					return @TotalPages


              end
END


GO
/****** Object:  StoredProcedure [edw].[sproc_GetUserActivitiesTest]    Script Date: 9/10/2021 8:10:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [edw].[sproc_GetUserActivitiesTest]
(
		@CompanyID int
       ,@LoggedInUserId int = 0
       ,@UserEmail nvarchar(4000)
       ,@UserID int
       ,@StartDate date
       ,@EndDate date
       ,@Page int = 0
       ,@PageSize int = 0
       ,@IsListView TINYINT = 0
       ,@Debug tinyint = 0

)
AS
BEGIN

              declare @DayFirstActivityTime datetime, 
					  @DayEndActivityTime datetime,
					  @DateNextToEndDate Date = DATEADD(DAY, 1 , @EndDate),
					  @iInterval AS INT = 30,
				      @StartDateTime datetime = @StartDate,
					  @EndDateTime datetime =  @EndDate,
					  @DayFirstTimeZoneOffset int,
					  @DayEndTimeZoneOffset int,
					  @EditedDay AS INT = 15,
					  @DayFirstActivityTimeUTC datetime,
					  @EstimatedTimeSpent real = 0,
					  @OnlineTimeSpent real = 0,
					  @OfflineTimeSpent real = 0,
					  @PrivateTimeSpent real = 0,
					  @UnaccountedTimeSpent real = 0

              if (@UserEmail <> '')
              begin
                     select @UserID = s.ID from [edw].[Dim_User] s where s.CompanyID = @CompanyID and s.UserEmail = @UserEmail
              end
			  else
			  begin				
				     select @UserID = s.ID from [edw].[Dim_User] s where s.CompanyID = @CompanyID and s.UserID = @UserID
			  end


              if (@Debug = 1)
              begin
                     select @UserID 'UserID',  @LoggedInUserId 'LoggedInUserId'
              end

			  --------

			  Select @EstimatedTimeSpent = k.OnlineTimeSpent+ k.OfflineTimeSpent+ k.PrivateTimeSpent + k.UnaccountedTimeSpent
					,@OnlineTimeSpent = k.OnlineTimeSpent, @OfflineTimeSpent = k.OfflineTimeSpent
					,@PrivateTimeSpent = k.PrivateTimeSpent, @UnaccountedTimeSpent = k.UnaccountedTimeSpent

			  FROM edw.Fact_DailyUser k Where DIm_Userid = @UserID and ActivityDate = @StartDate

			   select @UserID 'UserID',  @LoggedInUserId 'LoggedInUserId'

			   ------Start Work/Unaccounted/Private Time Calculation	

				
			   IF @EstimatedTimeSpent = 0
					
					Select 'totalTime' as totalTime,'Total Time / Hrs' as title,
					(@EstimatedTimeSpent)/60.0 as value,'0' as per 
					UNION ALL
					Select 'Work' as totalTime,'Work Time / Hrs' as title,
					(@OnlineTimeSpent + @OfflineTimeSpent)/60.0 as value,
					0 as per 
					UNION ALL
					Select 'Unaccounted' as totalTime,'Unaccounted Time / Hrs' as title,
					@UnaccountedTimeSpent/60.0 as value,0 as per
					UNION ALL
					Select 'Private' as totalTime,'Private Time / Hrs' as title,					
					@PrivateTimeSpent /60.0,
					0 per

				ELSE

					Select 'totalTime' as totalTime,'Total Time / Hrs' as title,
					(@EstimatedTimeSpent)/60.0 as value,'100' as per 
					UNION ALL
					Select 'Work' as totalTime,'Work Time / Hrs' as title,
					(@OnlineTimeSpent + @OfflineTimeSpent)/60.0 as value,
					Round(((@OnlineTimeSpent + @OfflineTimeSpent)/@EstimatedTimeSpent) * 100,2) as per 
					UNION ALL
					Select 'Unaccounted' as totalTime,'Unaccounted Time / Hrs' as title,
					@UnaccountedTimeSpent/60.0 as value,Round((@UnaccountedTimeSpent / @EstimatedTimeSpent) * 100,2) as per
					UNION ALL
					Select 'Private' as totalTime,'Private Time / Hrs' as title,					
					@PrivateTimeSpent /60.0,
					Round((@PrivateTimeSpent/@EstimatedTimeSpent) * 100,2) per


			  ------End Work/Unaccounted/Private Time Calculation			





              create table #TempActivitiesBase
              (
                     ID int identity(1,1),UserID integer, StartTime datetime2, EndTime datetime2, TimeZoneOffSet int, PurposeID integer, WorkCategory nvarchar(4000),
					 ActivityCategoryID int, [ActivityCategoryName] nvarchar(4000), AppID int,AppName nvarchar(4000),WebAppID int,WebAppName nvarchar(4000),
					 FileOrUrlName nvarchar(4000) ,IsUserModified bit, StartTimeInUTC datetime2, EndTimeInUTC datetime2
              )

			  insert into #TempActivitiesBase(UserID ,StartTime,  EndTime, TimeZoneOffSet, PurposeID, ActivityCategoryID, AppID, WebAppID, FileOrUrlName, IsUserModified, StartTimeInUTC, EndTimeInUTC)
              select s.Dim_UserID, convert (datetime2(0), s.StartTimeInLocal),  convert (datetime2(0),s.EndTimeInLocal), s.TimeZoneOffSet, s.PurposeID, s.Dim_ActivityCategoryID, s.Dim_AppMasterID,s.Dim_WebAppID,
			  s.FileOrUrlName,0 as IsUserModified, 
			  dateadd(minute, -[TimeZoneOffSet],CONVERT(datetime2(0),s.StartTimeInLocal)), dateadd(minute,-[TimeZoneOffSet],CONVERT(datetime2(0),s.EndTimeInLocal))
              from [edw].[Fact_TimeSlot] s 
			  where s.Dim_CompanyID = @CompanyID 
			  and s.[ActivityDate] between  @StartDate and @EndDate and s.[ActivityDate] < (GETDATE() - @EditedDay)
			  and s.IsActive = 1
			  and s.Dim_UserID = @UserID 

			  insert into #TempActivitiesBase(UserID ,StartTime,  EndTime, TimeZoneOffSet, PurposeID, ActivityCategoryID,  AppID, WebAppID, FileOrUrlName,IsUserModified, StartTimeInUTC, EndTimeInUTC)
              select s.Dim_UserID, convert (datetime2(0), s.StartTimeInLocal),  convert (datetime2(0),s.EndTimeInLocal), s.TimeZoneOffSet, s.PurposeID, s.Dim_ActivityCategoryID, s.Dim_AppMasterID,s.Dim_WebAppID,
			  s.FileOrUrlName,IsUserModified as IsUserModified, 
			  dateadd(minute, -[TimeZoneOffSet],CONVERT(datetime2(0),s.StartTimeInLocal)), dateadd(minute,-[TimeZoneOffSet],CONVERT(datetime2(0),s.EndTimeInLocal))
              from [edw].[Stg_TimeSlot] s 
			  where s.Dim_CompanyID = @CompanyID 
			  and s.[ActivityDate] between  @StartDate and @EndDate and s.[ActivityDate] >= (GETDATE() - @EditedDay)
			  and s.IsActive = 1
              and s.Dim_UserID = @UserID 

			  
              -- TODO: Fill gaps with Unaccounted, avoid overlap and avoid Day End greater than today 
              -- Adjust overlap.  say 2 pm is end and 1.30 pm is start of next..adjust 2 pm end to 1.30 pm

              select @DayFirstActivityTimeUTC = MIN(t.StartTimeInUTC), @DayFirstActivityTime = MIN(t.StartTime), @DayEndActivityTime = MAX(t.EndTime) from #TempActivitiesBase t 
              
			  select @DayFirstTimeZoneOffset = t.TimeZoneOffset from #TempActivitiesBase t  where t.StartTime = @DayFirstActivityTime

			  select @DayEndTimeZoneOffset = t.TimeZoneOffset from #TempActivitiesBase t  where t.EndTime = @DayEndActivityTime

              -- where t.ActivityCategoryID <> 0 .. TODO: required for AccountedFirst and LastTime
              -- TODO in Analyzer: if DayEnd exceeds 00:00:midnight of end date ..Round it to the start of the next day

              if ( convert(Date, @DayEndActivityTime) > @DateNextToEndDate ) 
              begin
                     update t
                     set
                           t.EndTime = @DateNextToEndDate
                     from #TempActivitiesBase t
                     where
                           convert(Date, @DayEndActivityTime) > @DateNextToEndDate

              end

			 /* ****************************Temp Table contains TimeSlot between Start and end time***************** */
				;WITH aCTE
				AS(
				    SELECT 
				        @StartDateTime AS StartDateTime,
				        DATEADD(MINUTE,@iInterval,@StartDateTime) AS EndDateTime
				    UNION ALL
				    SELECT 
				        DATEADD(MINUTE,@iInterval,StartDateTime),
				        DATEADD(MINUTE,@iInterval,EndDateTime)
				    FROM aCTE
				    WHERE
				        DATEADD(MINUTE,@iInterval,EndDateTime) <= @EndDateTime
				)

				SELECT StartDateTime as StartTime,EndDateTime as EndTime,-1 as PurposeID,0 as ActivityCategoryID,0 as AppID,'' as FileOrUrlName
				 INTO #StartEnd_Temp
				FROM aCTE

			    IF (@DayFirstActivityTime > @StartDateTime)
					BEGIN
                     
							IF @IsListView = 0
							BEGIN
								IF DATEADD(HOUR, DATEDIFF(HOUR, 0, @DayFirstActivityTime),0) <> @DayFirstActivityTime
								BEGIN
										INSERT INTO #TempActivitiesBase(UserID,StartTime,  EndTime, TimeZoneOffset, PurposeID, ActivityCategoryID,  AppID, FileOrUrlName,IsUserModified)
										SELECT @UserID,DATEADD(HOUR, DATEDIFF(HOUR, 0, @DayFirstActivityTime),0), @DayFirstActivityTime, @DayFirstTimeZoneOffset, -1, 0, 0, '',0  
								END
							END
							ELSE
							BEGIN
                           
								INSERT INTO #TempActivitiesBase(UserID,StartTime,  EndTime, TimeZoneOffset, PurposeID, ActivityCategoryID,  AppID, FileOrUrlName,IsUserModified)
					SELECT @UserID,@StartDateTime, @DayFirstActivityTime, @DayFirstTimeZoneOffset, -1, 0, 0, '',0
						END
				END


			IF (@DayEndActivityTime < @DateNextToEndDate)
			BEGIN
					IF DATEADD(HOUR,DATEDIFF(HOUR,0,DATEADD(HOUR, 1, @DayEndActivityTime )),0) < @DateNextToEndDate AND @IsListView = 0
					BEGIN
							INSERT INTO #TempActivitiesBase(UserID,StartTime,  EndTime, TimeZoneOffset, PurposeID, ActivityCategoryID,  AppID, FileOrUrlName,IsUserModified)
							SELECT @UserID,@DayEndActivityTime, DATEADD(HOUR,DATEDIFF(HOUR,0,DATEADD(HOUR, 1, @DayEndActivityTime)),0) , @DayEndTimeZoneOffset, -1, 0, 0, '' ,0                                   
					END
                           
				ELSE
				BEGIN
					INSERT INTO #TempActivitiesBase(UserID,StartTime,  EndTime, TimeZoneOffset, PurposeID, ActivityCategoryID,  AppID, FileOrUrlName,IsUserModified)
					SELECT @UserID,@DayEndActivityTime, @DateNextToEndDate, @DayEndTimeZoneOffset, -1, 0, 0, ''  ,0
				END
			END


---- update Starttime
		Select * INTO #Ismodified from #TempActivitiesBase
		where IsUserModified = 1

		Select a.UserId,a.StartTime,max(b.EndTime) as EndTime INTO #Ismodified1
		from #Ismodified a
		INNER JOIN #TempActivitiesBase b
		On a.Userid = b.Userid and b.EndTime Between a.STartTime AND DateAdd(MINUTE, 1, a.STartTime)
		group by a.UserId,a.STartTime

		Update t
		Set t.StartTimeInUTC = DateAdd(minute,-t.TimeZoneOffset,a.EndTime)
		,t.TimeSpent = datediff(second, a.EndTime, t.EndTimeInLocal) /60.0
		from [EDW].[stg_TimeSlot] t with (nolock)
		inner join #Ismodified1 a
		On t.Dim_userid = a.userid and t.StartTimeInLocal = a.StartTime

		Update t
		Set t.StartTime = a.EndTime
		,t.StartTimeInUTC = DateAdd(Minute,-t.TimeZoneOffset,a.EndTime)
		from #TempActivitiesBase t
		inner join #Ismodified1 a
		On t.userid = a.userid and t.StartTime = a.StartTime
		--- update Endtime
		Select a.UserId,a.EndTime,min(b.startTime) as Starttime INTO #Ismodified2
		from #Ismodified a
		INNER JOIN #TempActivitiesBase b
		On a.Userid = b.Userid and b.startTime Between a.EndTime AND DateAdd(MINUTE, 1, a.EndTime)
		group by a.UserId,a.EndTime

		Update t
		Set t.EndTimeInUTC = DateAdd(Minute,-t.TimeZoneOffset,a.StartTime)
		,t.TimeSpent = datediff(second, t.startTimeInLocal, a.startTime) /60.0
		from [EDW].[stg_TimeSlot] t with (nolock)
		inner join #Ismodified2 a
		On t.Dim_userid = a.userid and t.EndTimeInLocal = a.EndTime

		Update t
		Set t.EndTime = a.StartTime
		,t.EndTimeInUTC = DateAdd(Minute,-t.TimeZoneOffset,a.StartTime)
		from #TempActivitiesBase t
		inner join #Ismodified2 a
		On t.userid = a.userid and t.EndTime = a.EndTime


		----


		update t
		set
			t.StartTimeInUTC = a.EndTimeInUTC
			,t.TimeSpent = datediff(minute, a.EndTimeInUTC, t.EndTimeInUTC)
		from Edw.Fact_TimeSlot t
		inner join
		(
			Select s.UserID, s.StartTime,  s.EndTime, s.TimeZoneOffset, s.StartTimeInUTC, s.EndTimeInUTC, LEAD(s.startTime, 1, '1900') OVER(PARTITION BY s.UserID ORDER BY s.StartTime, s.EndTime) as NextStartTime,
			CASE WHEN s.EndTime = LEAD(s.startTime, 1, '1900') OVER(PARTITION BY s.UserID ORDER BY s.StartTime, s.EndTime) THEN 0 ELSE 1 END as HASGAP,s.IsUserModified, s.PurposeID
			FROM #TempActivitiesBase s
		) as a
		on
			t.Dim_UserID = a.UserId and t.StartTimeInLocal = a.NextStartTime 	
		WHERE  a.NextStartTime <> '1900-01-01 00:00:00.000' and a.HASGAP = 1 and a.NextStartTime < a.EndTime
		and t.Dim_CompanyID = @CompanyID and  t.ActivityDate = @StartDate 
	

		insert into #TempActivitiesBase(UserID, StartTime,  EndTime, TimeZoneOffset, PurposeID, ActivityCategoryID,  AppID, FileOrUrlName,IsUserModified)
		Select @UserID as UserID, a.EndTime StartTime,a.ENDTIME1 as EndTime, a.TimeZoneOffset, -1 as PurposeID,0 as ActivityCategoryID,0 as AppID,'' as FileOrUrlName,IsUserModified FROM
		(Select  s.EndTime, s.TimeZoneOffset, LEAD(s.startTime, 1, '1900') OVER(PARTITION BY s.UserID ORDER BY s.StartTime, s.EndTime) as ENDTIME1 ,
		CASE WHEN s.EndTime = LEAD(s.startTime, 1, '1900') OVER(PARTITION BY s.UserID ORDER BY s.StartTime, s.EndTime) THEN 0 ELSE 1 END as HASGAP,s.IsUserModified, s.PurposeID
		FROM #TempActivitiesBase s) a
		Where a.ENDTIME1 <> '1900-01-01 00:00:00.000' and HASGAP = 1 and a.ENDTIME1 >= a.EndTime 
		
              -- Add Day Start and Day end gaps
  
              ; WITH CTEUserActivities
              AS
              (
                     SELECT t.ID, t.EndTime, Lead(t.StartTime, 1) OVER( ORDER BY t.StartTime, t.EndTime ) NextSlotStartTime
                     FROM #TempActivitiesBase t
              )
              update t
              set
                     t.EndTime = s.NextSlotStartTime
              from #TempActivitiesBase t
              inner join CTEUserActivities s
              on
                     t.ID = s.ID
              where
                     s.NextSlotStartTime <  s.EndTime	
			
              -- Update ActivityCategory
              update t
              set
                     t.[ActivityCategoryName] = s.[ActivityCategoryName]
              from #TempActivitiesBase t
              inner join [edw].[Dim_ActivityCategory] s
              on
                     s.CompanyID = @CompanyID and t.ActivityCategoryID = s.ID --and t.PurposeID <> -1

			  --Update AppName
              update t
              set
                     [AppName] = s.AppName
              from #TempActivitiesBase t
              inner join [edw].[Dim_AppMaster] s
              on
                     s.CompanyID = @CompanyID and t.AppID = s.ID --and t.PurposeID <> -1

			 --Update WebAppName
              update t
              set
                     [WebAppName] = s.WebAppName
              from #TempActivitiesBase t
              inner join [edw].[Dim_WebApp] s
              on
                     s.CompanyID = @CompanyID and t.WebAppID = s.ID --and t.PurposeID <> -1

		IF (convert(Date, @DayFirstActivityTimeUTC) <> convert(Date,getUtcdate()))
			update #TempActivitiesBase
			set
			[EndTime] = DATEADD(MS, -1, CONVERT(DATETIME2, @DateNextToEndDate))
   			Where EndTime = (Select Max(EndTime) From #TempActivitiesBase)	
		ELSE
			delete from #TempActivitiesBase			
   			Where EndTime = (Select Max(EndTime) From #TempActivitiesBase) and PurposeID = -1 and AppID = 0 and ActivityCategoryID = 0 

			--select * from #TempActivitiesBase

			create table #FinalActivities
            (
                ID int identity(1,1), StartTime datetime2, EndTime datetime2, TimeZoneOffset int,  PurposeID integer,  ActivityCategoryID int, [ActivityCategoryName] nvarchar(4000), AppID int,  AppName nvarchar(4000), FileOrUrlName nvarchar(4000) ,IsUserModified BIT
            )
			
            if (@Page = 0)
              begin
					insert into #FinalActivities
					(
						StartTime, EndTime, TimeZoneOffset, PurposeID,  ActivityCategoryID, [ActivityCategoryName], AppID,  AppName, FileOrUrlName ,IsUserModified
					) 
					select 
						StartTime, EndTime, t.TimeZoneOffset, PurposeID, ActivityCategoryID,							   
						case when @LoggedInUserId = @UserID then IsNull([ActivityCategoryName], '') ELSE '' END as ActivityCategoryName,
						Case when AppID is null then WebAppID end as AppID,
						case when @LoggedInUserId = @UserID then IsNull(case when AppName is null then WebAppName else AppName end, '') ELSE '' END as AppName,
						case when @LoggedInUserId = @UserID then  IsNull(FileOrUrlName, '') Else '' END  as FileOrUrlName,IsUserModified
						from #TempActivitiesBase t
						where t.StartTime <> t.EndTime and t.PurposeID = -1
						order by t.StartTime asc

					insert into #FinalActivities
					(
						StartTime, EndTime, TimeZoneOffset, PurposeID,  ActivityCategoryID, [ActivityCategoryName], AppID,  AppName, FileOrUrlName ,IsUserModified
					) 
					select 
							StartTime, EndTime, t.TimeZoneOffset, PurposeID, ActivityCategoryID,							   
							IsNull([ActivityCategoryName], '') ActivityCategoryName,
							Case when AppID is null then WebAppID else AppID end as AppID,
							IsNull(Case when AppName is null then WebAppName else AppName end, '') AppName,
							IsNull(FileOrUrlName, '') FileOrUrlName, IsUserModified
						from #TempActivitiesBase t
						where t.StartTime <> t.EndTime and t.PurposeID <> -1
						order by t.StartTime asc

					Select * from #FinalActivities order by StartTime asc
                     
					return 0
              end
              else begin
                    declare @Records int = 0, @TotalPages int = 0
					insert into #FinalActivities
					(
						StartTime, EndTime, TimeZoneOffset, PurposeID,  ActivityCategoryID, [ActivityCategoryName], AppID,  AppName, FileOrUrlName ,IsUserModified
					) 
					select 
							StartTime, EndTime, t.TimeZoneOffset, PurposeID, ActivityCategoryID, 
							case when @LoggedInUserId = @UserID then IsNull([ActivityCategoryName], '') ELSE '' END as ActivityCategoryName,
							Case when AppID is null then WebAppID else AppID end as AppID,  
							case when @LoggedInUserId = @UserID then IsNull(case when AppName is null then WebAppName else AppName end, '') ELSE '' END as AppName,
							case when @LoggedInUserId = @UserID then  IsNull(FileOrUrlName, '') Else '' END  as FileOrUrlName,IsUserModified
						from #TempActivitiesBase t

						where t.StartTime <> t.EndTime and t.PurposeID = -1
						order by t.StartTime asc

					insert into #FinalActivities
					(
						StartTime, EndTime, TimeZoneOffset, PurposeID,  ActivityCategoryID, [ActivityCategoryName], AppID,  AppName, FileOrUrlName ,IsUserModified
					) 
					select 
							StartTime, EndTime, t.TimeZoneOffset, PurposeID, ActivityCategoryID, 
							IsNull([ActivityCategoryName], '') ActivityCategoryName, 
							Case when AppID is null then WebAppID else AppID end as AppID,
							IsNull(Case when AppName is null then WebAppName else AppName end, '') AppName,
							IsNull(FileOrUrlName, '') FileOrUrlName,IsUserModified
						from #TempActivitiesBase t
						where t.StartTime <> t.EndTime and t.PurposeID <> -1
						order by t.StartTime asc

                     set @Records = @@RowCount
                     set @TotalPages = @Records / @PageSize

                     if ( ( @Records % @PageSize ) <> 0)
                     begin
                     
                           set @TotalPages = @TotalPages + 1
                     
                     end 

                     declare @BeginPage int =  (@Page - 1) * @PageSize + 1

                     declare @EndPage int = @BeginPage + ( @PageSize - 1)

                     if (@Debug = 1)
                     begin

                           select @Records 'Records', @TotalPages 'TotalPages' , @BeginPage 'BeginPage' , @EndPage 'EndPage'
                     end

                     select 
                           StartTime, EndTime, t.TimeZoneOffset, PurposeID, ActivityCategoryID, IsNull([ActivityCategoryName], '') [ActivityCategoryName], AppID,  IsNull(AppName, '') AppName, IsNull(FileOrUrlName, '') FileOrUrlName,IsUserModified
                     from #FinalActivities t
                     where @Page = 0 OR (t.ID between @BeginPage and @EndPage)


					return @TotalPages


              end
END


GO
/****** Object:  StoredProcedure [edw].[sproc_HarnessDataCopyScript]    Script Date: 9/10/2021 8:10:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE    PROCEDURE [edw].[sproc_HarnessDataCopyScript]
(
	  @SrcCompanyID as INT = 1
)
AS
BEGIN

--- Initializing

	Declare @StartDate Date = GETDATE() -1 ; 
	Declare @EndDate Date = GETDATE() -1 ;
	Declare  @DestCompanyID as INT ;
	Declare @Step NVARCHAR(4000) = '';
	Declare @Active bit = 1;


--- Cursor Declaration
DECLARE @CompanyCursor as CURSOR;


SET @CompanyCursor = CURSOR FOR
	Select CompanyID from [edw].[Demo_Company] Where IsActive = @Active

OPEN @CompanyCursor;
	 FETCH NEXT FROM @CompanyCursor INTO @DestCompanyID;
	
	 WHILE @@FETCH_STATUS = 0
		BEGIN
			
			INSERT INTO [edw].[Stg_Lenses]
			([TenantID],[LineofBusinessID],[sessionId],[tzoffset],[productVersion],[fileDescription],[exeName],
			[activityDomain],[activityUserID],[deviceId],[windowTitle],[url],[activityTime],[activityType],[meetingID],
			[meetingSubject],[meetingStart],[meetingEnd],[meetingDuration],[meetingActivityVersion],[meetingBusyStatus],
			[meetingResponseStatus],[meetingSensitivity],[meetingStatus],[offset],[machineName],[networkname],[keyboardHardEvents],
			[keyboardSoftEvents],[mouseHardEvents],[mouseSoftEvents])
			
			Select [TenantID], @DestCompanyID,[sessionId],[tzoffset],[productVersion],[fileDescription],[exeName],[activityDomain],
			CONCAT ([activityUserID], '_',@DestCompanyID) ,[deviceId],[windowTitle],[url],[activityTime],[activityType],[meetingID],[meetingSubject],[meetingStart],
			[meetingEnd],[meetingDuration],[meetingActivityVersion],[meetingBusyStatus],[meetingResponseStatus],[meetingSensitivity],
			[meetingStatus],[offset],[machineName],[networkname],[keyboardHardEvents],[keyboardSoftEvents],[mouseHardEvents],[mouseSoftEvents]
			From edw.Stg_Lenses Where [LineofBusinessID] = @SrcCompanyID 



			PRINT 'Data present for :@DestCompanyID';

FETCH NEXT FROM @CompanyCursor INTO @DestCompanyID;
END


END


GO
/****** Object:  StoredProcedure [edw].[sproc_Lenses_Visits_TimeSpent_byApp]    Script Date: 9/10/2021 8:10:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE    PROCEDURE [edw].[sproc_Lenses_Visits_TimeSpent_byApp]
(
    @CompanyID int,
	@DayRangeEnum int,
	@AppIDs nvarchar(200),
	@WebAppIDs nvarchar(200)
)
AS
BEGIN

	DECLARE @startDate DATE, @endDate DATE, @DayRange INT

	-- 1 enum = 7 days, 2 enum = 15 days, else 30 days
	SET @DayRange = CASE @DayRangeEnum WHEN 1 THEN 7 WHEN 2 THEN 15 ELSE 30 END

	SET @startDate = DATEADD(dd, -@DayRange, CAST(CONVERT(VARCHAR(10), GETUTCDATE(), 101) AS date))
	SET @endDate = DATEADD(dd, -1, CAST(CONVERT(VARCHAR(10), GETUTCDATE(), 101) AS date))

	CREATE TABLE #results
	(
	[AppID] INT,
	[IsWebApp] BIT,
	[DailyAverage] float,
	[Users] int
	)

	--************ EXEs **************
	IF LEN(@AppIDs) > 0
	BEGIN
		INSERT INTO #results (AppID, IsWebApp, DailyAverage, Users)
		SELECT AppSpecID, CAST(0 AS bit) IsWebApp, DailyAverage, UserCount
		FROM 
			(SELECT
				ap.ID,
				ap.AppSpecID,
				SUM(TimeSpentInCalendarDay) AS [DailyAverage]
				FROM edw.Fact_DailyActivity da with(nolock)
				JOIN edw.Dim_AppMaster am with(nolock) ON da.Dim_AppMasterID = am.ID
				JOIN edw.Dim_AppParent ap with(nolock) ON am.Dim_AppParentID = ap.ID
				LEFT JOIN edw.Dim_ActivityCategory ac with(nolock) ON ap.Dim_ActivityCategoryID = ac.ID
				WHERE ActivityDate BETWEEN @startDate AND @endDate
					AND da.Dim_CompanyID=@CompanyID
					AND ap.AppName NOT IN ('Unknown','Off-PC')
					AND ap.AppSpecID IN (select value from string_split(@AppIDs,','))
				GROUP BY ap.ID, ap.AppSpecID
			) DailyAvg
			JOIN
			(SELECT ID, count(Dim_UserID) UserCount 
			FROM
				(SELECT
					ap.ID,
					Dim_UserID
					FROM edw.Fact_DailyActivity da with(nolock)
					JOIN edw.Dim_AppMaster am with(nolock) ON da.Dim_AppMasterID = am.ID
					JOIN edw.Dim_AppParent ap with(nolock) ON am.Dim_AppParentID = ap.ID
					LEFT JOIN edw.Dim_ActivityCategory ac with(nolock) ON ap.Dim_ActivityCategoryID = ac.ID
					WHERE ActivityDate BETWEEN @startDate AND @endDate
						AND da.Dim_CompanyID=@CompanyID
						AND ap.AppName NOT IN ('Unknown','Off-PC')
						AND ap.AppSpecID IN (select value from string_split(@AppIDs,','))
					GROUP BY ap.ID, Dim_UserID
				) base
			GROUP BY ID
			) UserCnt ON DailyAvg.ID = UserCnt.ID
		END


	--************ WebApps ***************
	IF LEN(@WebAppIDs) > 0
	BEGIN
		INSERT INTO #results (AppID, IsWebApp, DailyAverage, Users)
		SELECT WebAppID, CAST(1 AS bit) IsWebApp, DailyAverage, UserCount
		FROM 
			(SELECT
					wa.ID,
					wa.WebAppID,
					SUM(TimeSpentInCalendarDay) AS [DailyAverage]
					FROM edw.Fact_DailyActivity da with(nolock)
					JOIN edw.Dim_WebApp wa with(nolock) ON da.Dim_CompanyID = wa.CompanyID AND da.Dim_WebAppID = wa.ID
					JOIN edw.Dim_ActivityCategory ac with(nolock) ON da.Dim_ActivityCategoryID = ac.ID
					WHERE ActivityDate BETWEEN @startDate AND @endDate
						AND da.Dim_CompanyID=@CompanyID
						AND wa.WebAppID IN (select value from string_split(@WebAppIDs,','))
					GROUP BY wa.ID, wa.WebAppID
			) DailyAvg
			JOIN
			(SELECT ID, COUNT(Dim_UserID) UserCount  
			FROM 
				(SELECT
					wa.ID,
					Dim_UserID
					FROM edw.Fact_DailyActivity da with(nolock)
					JOIN edw.Dim_WebApp wa with(nolock) ON da.Dim_CompanyID = wa.CompanyID AND da.Dim_WebAppID = wa.ID
					JOIN edw.Dim_ActivityCategory ac with(nolock) ON da.Dim_ActivityCategoryID = ac.ID
					WHERE ActivityDate BETWEEN @startDate AND @endDate
						AND da.Dim_CompanyID=@CompanyID
						AND wa.WebAppID IN (select value from string_split(@WebAppIDs,','))
					GROUP BY wa.ID, Dim_UserID
				) base
			GROUP BY ID
			) UserCnt ON DailyAvg.ID = UserCnt.ID
	END



	-- ***************** Results ******************

	UPDATE #results
	SET DailyAverage = CAST(DailyAverage/Users AS decimal(9,2))

	SELECT * FROM #results

	DROP TABLE #results

END

GO
/****** Object:  StoredProcedure [edw].[sproc_MasterDataCopyScript]    Script Date: 9/10/2021 8:10:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [edw].[sproc_MasterDataCopyScript]
(
	  @SrcCompanyID as INT = 1
)
AS
BEGIN

--- Initializing

	Declare @StartDate Date = GETDATE() -1 ; 
	Declare @EndDate Date = GETDATE() -1 ;
	Declare  @DestCompanyID as INT ;
	Declare @Step NVARCHAR(4000) = '';


--- Cursor Declaration
DECLARE @CompanyCursor as CURSOR;


SET @CompanyCursor = CURSOR FOR
	Select CompanyID from [edw].[Dim_Company] Where CompanyID IN (3,10,11,12,13,14,15)

OPEN @CompanyCursor;
	 FETCH NEXT FROM @CompanyCursor INTO @DestCompanyID;
	
	 WHILE @@FETCH_STATUS = 0
		BEGIN
			
			exec [edw].[sproc_DataTransferScript] @StartDate,@EndDate,@SrcCompanyID,@DestCompanyID


			PRINT 'Data present for :@DestCompanyID';

FETCH NEXT FROM @CompanyCursor INTO @DestCompanyID;
END


END


GO
/****** Object:  StoredProcedure [edw].[sproc_MergeConflictingTimeSlots]    Script Date: 9/10/2021 8:10:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [edw].[sproc_MergeConflictingTimeSlots]

AS
BEGIN

	DECLARE @counter INT = 1
	DECLARE @lowPriority BIT, @leadLowPriority BIT, @IsCore BIT, @leadIsCore BIT
	DECLARE @PurposeID INT, @leadPurposeID INT, @Dim_UserID INT
	DECLARE @leadStartTime DATETIME, @leadEndTime DATETIME, @startTime DATETIME, @endTime DATETIME, @uploadTime DATETIME
	DECLARE @activityDate DATE


	--******************************************* TIMESLOT RECORDS WITH SAME START AND END TIMES *****************************************

	SELECT ROW_NUMBER() OVER(ORDER BY StartTimeInUTC) ID, StartTimeInUTC, EndTimeInUTC, ts.Dim_UserID, ts.ActivityDate 
	INTO #Process2	
	FROM edw.Fact_TimeSlot ts
	JOIN (SELECT DISTINCT Dim_UserID, ActivityDate FROM edw.Stg_UsersDates) ud ON ts.Dim_UserID = ud.Dim_UserID AND ts.ActivityDate= ud.ActivityDate
	WHERE IsActive=1
	GROUP BY StartTimeInUTC, EndTimeInUTC, ts.Dim_UserID, ts.ActivityDate
	HAVING COUNT(*) > 1


	WHILE (@counter <= (SELECT MAX(ID) FROM #Process2))
	BEGIN
		--set @startTime, @endTime, @dimUserID, @activityDate
		SELECT @startTime=StartTimeInUTC, @endTime=EndTimeInUTC, @Dim_UserID=Dim_UserID, @activityDate=ActivityDate
		FROM #Process2
		WHERE ID=@counter

		-- ************************** Fact_TimeSlot **************************
		--first update IsActive = false for all
		UPDATE edw.Fact_TimeSlot
		SET IsActive=0
		WHERE StartTimeInUTC=@startTime
			AND EndTimeInUTC=@endTime
			AND Dim_UserID=@Dim_UserID
			AND ActivityDate=@activityDate

		--then update top record IsActive = true (based on LowPriority/PurposeID/IsCore)
		;WITH CTE
			AS (SELECT TOP (1) ts.IsActive, TimeSpent, StartTimeInUTC, EndTimeInUTC
				FROM edw.Fact_TimeSlot ts
				LEFT JOIN edw.Dim_AppMaster am ON ts.Dim_AppMasterID = am.ID
				LEFT JOIN edw.Dim_AppParent ap ON am.Dim_AppParentID = ap.ID
				LEFT JOIN edw.Dim_ActivityCategory ac ON ts.Dim_ActivityCategoryID = ac.ID
				WHERE StartTimeInUTC=@startTime
					AND EndTimeInUTC=@endTime
					AND Dim_UserID=@Dim_UserID
					AND ActivityDate=@activityDate
				ORDER BY LowPriority ASC, PurposeID DESC, ac.IsCore DESC	
				)

		UPDATE CTE
		SET IsActive = 1,
		TimeSpent = ROUND(DATEDIFF(millisecond, StartTimeInUTC, EndTimeInUTC)/(1000.0 * 60.0), 4)


		-- ************************** Stg_TimeSlot **************************
		UPDATE edw.Stg_TimeSlot
		SET IsActive=0
		WHERE StartTimeInUTC=@startTime
			AND EndTimeInUTC=@endTime
			AND Dim_UserID=@Dim_UserID
			AND ActivityDate=@activityDate

		;WITH CTE_stg
			AS (SELECT TOP (1) ts.IsActive, TimeSpent, StartTimeInUTC, EndTimeInUTC
				FROM edw.Stg_TimeSlot ts
				LEFT JOIN edw.Dim_AppMaster am ON ts.Dim_AppMasterID = am.ID
				LEFT JOIN edw.Dim_AppParent ap ON am.Dim_AppParentID = ap.ID
				LEFT JOIN edw.Dim_ActivityCategory ac ON ts.Dim_ActivityCategoryID = ac.ID
				WHERE StartTimeInUTC=@startTime
					AND EndTimeInUTC=@endTime
					AND Dim_UserID=@Dim_UserID
					AND ActivityDate=@activityDate
				ORDER BY LowPriority ASC, PurposeID DESC, ac.IsCore DESC	
				)

		UPDATE CTE_stg
		SET IsActive = 1,
		TimeSpent = ROUND(DATEDIFF(millisecond, StartTimeInUTC, EndTimeInUTC)/(1000.0 * 60.0), 4)

		SET @counter=@counter+1
	END


	DROP TABLE #Process2


	--******************************************* TIMESLOT RECORDS WITH SAME START AND END TIMES (obfus) *****************************************
	SET @counter = 1

	SELECT ROW_NUMBER() OVER(ORDER BY StartTimeInUTC) ID, StartTimeInUTC, EndTimeInUTC, ts.Dim_UserID, ts.ActivityDate 
	INTO #Process2_o	
	FROM edw.Fact_TimeSlot_Obfus ts
	JOIN (SELECT DISTINCT (56104893/152+Dim_UserID)*-1 Dim_UserID, ActivityDate FROM edw.Stg_UsersDates) ud ON ts.Dim_UserID = ud.Dim_UserID AND ts.ActivityDate= ud.ActivityDate
	WHERE IsActive=1
	GROUP BY StartTimeInUTC, EndTimeInUTC, ts.Dim_UserID, ts.ActivityDate
	HAVING COUNT(*) > 1

	WHILE (@counter <= (SELECT MAX(ID) FROM #Process2_o))
	BEGIN
		--set @startTime, @endTime, @dimUserID, @activityDate
		SELECT @startTime=StartTimeInUTC, @endTime=EndTimeInUTC, @Dim_UserID=Dim_UserID, @activityDate=ActivityDate
		FROM #Process2_o
		WHERE ID=@counter

		UPDATE edw.Fact_TimeSlot_Obfus
		SET IsActive=0
		WHERE StartTimeInUTC=@startTime
			AND EndTimeInUTC=@endTime
			AND Dim_UserID=@Dim_UserID
			AND ActivityDate=@activityDate

		;WITH CTE_obfus
			AS (SELECT TOP (1) ts.IsActive, TimeSpent, StartTimeInUTC, EndTimeInUTC
				FROM edw.Fact_TimeSlot_Obfus ts
				LEFT JOIN edw.Dim_AppMaster am ON ts.Dim_AppMasterID = am.ID
				LEFT JOIN edw.Dim_AppParent ap ON am.Dim_AppParentID = ap.ID
				LEFT JOIN edw.Dim_ActivityCategory ac ON ts.Dim_ActivityCategoryID = ac.ID
				WHERE StartTimeInUTC=@startTime
					AND EndTimeInUTC=@endTime
					AND Dim_UserID=@Dim_UserID
					AND ActivityDate=@activityDate
				ORDER BY LowPriority ASC, PurposeID DESC, ac.IsCore DESC	
				)

		UPDATE CTE_obfus
		SET IsActive = 1,
		TimeSpent = ROUND(DATEDIFF(millisecond, StartTimeInUTC, EndTimeInUTC)/(1000.0 * 60.0), 4)

		SET @counter=@counter+1
	END

	DROP TABLE #Process2_o


	--******************************************* TIMESLOT RECORDS OVERLAP *****************************************
	SET @counter = 1

	SELECT 
	LEAD(StartTimeInUTC) over (partition by ts.dim_userID, ts.activityDate order by StartTimeInUTC) LeadStartTime, 
	LEAD(EndTimeInUTC) over (partition by ts.dim_userID, ts.activityDate order by StartTimeInUTC) LeadEndTime, 
	LEAD(Dim_AppMasterID) over (partition by ts.dim_userID, ts.activityDate order by StartTimeInUTC) LeadDim_AppMasterID, 
	LEAD(Dim_ActivityCategoryID) over (partition by ts.dim_userID, ts.activityDate order by StartTimeInUTC) LeadDim_ActivityCategoryID, 
	LEAD(PurposeID) over (partition by ts.dim_userID, ts.activityDate order by StartTimeInUTC) LeadPurposeID, 
	LEAD(IsActive) over (partition by ts.dim_userID, ts.activityDate order by StartTimeInUTC) LeadIsActive, 
	ts.Dim_UserID, ts.ActivityDate, Dim_AppMasterID, StartTimeInUTC, EndTimeInUTC, TimeSpent, Dim_ActivityCategoryID, PurposeID
	INTO #LEAD
	FROM edw.Fact_TimeSlot ts
	JOIN (SELECT DISTINCT Dim_UserID, ActivityDate FROM edw.Stg_UsersDates) ud ON ts.Dim_UserID = ud.Dim_UserID AND ts.ActivityDate= ud.ActivityDate
	WHERE IsActive=1
	ORDER BY StartTimeInUTC asc, EndTimeInUTC asc	


	SELECT ROW_NUMBER() OVER(ORDER BY LeadStartTime) ID,
	ap.LowPriority, ac.IsCore, 
	ap2.LowPriority LeadLowPriority, ac2.IsCore LeadIsCore, 
	l.* 
	INTO #Process
	FROM #LEAD l
	LEFT JOIN edw.Dim_AppMaster am ON l.Dim_AppMasterID = am.ID
	LEFT JOIN edw.Dim_AppParent ap ON am.Dim_AppParentID = ap.ID
	LEFT JOIN edw.Dim_ActivityCategory ac ON l.Dim_ActivityCategoryID = ac.ID

	LEFT JOIN edw.Dim_AppMaster am2 ON l.LeadDim_AppMasterID = am2.ID
	LEFT JOIN edw.Dim_AppParent ap2 ON am2.Dim_AppParentID = ap2.ID
	LEFT JOIN edw.Dim_ActivityCategory ac2 ON l.LeadDim_ActivityCategoryID = ac2.ID
	WHERE EndTimeInUTC > LeadStartTime 

	WHILE (@counter <= (SELECT MAX(ID) FROM #Process))
	BEGIN
		SELECT @lowPriority=COALESCE(LowPriority,0), @leadLowPriority=COALESCE(LeadLowPriority,0), @IsCore=COALESCE(IsCore,0), @leadIsCore=COALESCE(LeadIsCore,0), @PurposeID=PurposeID, @leadPurposeID=LeadPurposeID, 
		@leadStartTime=LeadStartTime, @leadEndTime=LeadEndTime, @Dim_UserID=Dim_UserID, @activityDate=ActivityDate, @startTime=StartTimeInUTC, @endTime=EndTimeInUTC 
		FROM #Process
		WHERE ID = @counter

			--********* Conflicting current app is low priority
			IF @lowPriority = 1 AND @leadLowPriority = 0
			  BEGIN
				UPDATE edw.Fact_TimeSlot
				SET EndTimeInUTC = @leadStartTime,
					TimeSpent=ROUND(DATEDIFF(millisecond, StartTimeInUTC, @leadStartTime)/(1000.0 * 60.0), 4)
				WHERE Dim_UserID=@Dim_UserID
					AND ActivityDate=@activityDate
					AND StartTimeInUTC=@startTime
					AND EndTimeInUTC=@endTime

				UPDATE edw.Stg_TimeSlot
				SET EndTimeInUTC = @leadStartTime,
					TimeSpent=ROUND(DATEDIFF(millisecond, StartTimeInUTC, @leadStartTime)/(1000.0 * 60.0), 4)
				WHERE Dim_UserID=@Dim_UserID
					AND ActivityDate=@activityDate
					AND StartTimeInUTC=@startTime
					AND EndTimeInUTC=@endTime
	
			  END
			--********* Conflicting lead app is low priority
			ELSE IF @leadLowPriority = 1 AND @lowPriority = 0
				IF @endTime < @leadEndTime
				  BEGIN
					UPDATE edw.Fact_TimeSlot
					SET StartTimeInUTC = @endTime,
						TimeSpent=ROUND(DATEDIFF(millisecond, @endTime, EndTimeInUTC)/(1000.0 * 60.0), 4)
					WHERE Dim_UserID=@Dim_UserID
						AND ActivityDate=@activityDate
						AND StartTimeInUTC=@leadStartTime
						AND EndTimeInUTC=@leadEndTime

					UPDATE edw.Stg_TimeSlot
					SET StartTimeInUTC = @endTime,
						TimeSpent=ROUND(DATEDIFF(millisecond, @endTime, EndTimeInUTC)/(1000.0 * 60.0), 4)
					WHERE Dim_UserID=@Dim_UserID
						AND ActivityDate=@activityDate
						AND StartTimeInUTC=@leadStartTime
						AND EndTimeInUTC=@leadEndTime
				  END
				ELSE
				  BEGIN
					UPDATE edw.Fact_TimeSlot
					SET IsActive=0
					WHERE Dim_UserID=@Dim_UserID
						AND ActivityDate=@activityDate
						AND StartTimeInUTC=@leadStartTime
						AND EndTimeInUTC=@leadEndTime

					UPDATE edw.Stg_TimeSlot
					SET IsActive=0
					WHERE Dim_UserID=@Dim_UserID
						AND ActivityDate=@activityDate
						AND StartTimeInUTC=@leadStartTime
						AND EndTimeInUTC=@leadEndTime
				  END
			--********* Neither conflicting apps are low priority
			ELSE
				BEGIN
					IF (@IsCore=1 AND @leadIsCore=0) OR (@PurposeID=1 AND @leadPurposeID=-1)
						IF @endTime < @leadEndTime
						  BEGIN
							UPDATE edw.Fact_TimeSlot
							SET StartTimeInUTC = @endTime,
								TimeSpent=ROUND(DATEDIFF(millisecond, @endTime, EndTimeInUTC)/(1000.0 * 60.0), 4)
							WHERE Dim_UserID=@Dim_UserID
								AND ActivityDate=@activityDate
								AND StartTimeInUTC=@leadStartTime
								AND EndTimeInUTC=@leadEndTime

							UPDATE edw.Stg_TimeSlot
							SET StartTimeInUTC = @endTime,
								TimeSpent=ROUND(DATEDIFF(millisecond, @endTime, EndTimeInUTC)/(1000.0 * 60.0), 4)
							WHERE Dim_UserID=@Dim_UserID
								AND ActivityDate=@activityDate
								AND StartTimeInUTC=@leadStartTime
								AND EndTimeInUTC=@leadEndTime
						  END
						ELSE
						  BEGIN
							UPDATE edw.Fact_TimeSlot
							SET IsActive=0
							WHERE Dim_UserID=@Dim_UserID
								AND ActivityDate=@activityDate
								AND StartTimeInUTC=@leadStartTime
								AND EndTimeInUTC=@leadEndTime

							UPDATE edw.Stg_TimeSlot
							SET IsActive=0
							WHERE Dim_UserID=@Dim_UserID
								AND ActivityDate=@activityDate
								AND StartTimeInUTC=@leadStartTime
								AND EndTimeInUTC=@leadEndTime
						  END
					ELSE -- NOT (@IsCore=1 AND @leadIsCore=0) OR (@PurposeID=1 AND @leadPurposeID=-1)
					  BEGIN
						IF @endTime < @leadEndTime
						  BEGIN
							UPDATE edw.Fact_TimeSlot
							SET EndTimeInUTC = @leadStartTime,
							TimeSpent = ROUND(DATEDIFF(millisecond, StartTimeInUTC, @leadStartTime)/(1000.0 * 60.0), 4)
							WHERE Dim_UserID=@Dim_UserID
								AND ActivityDate=@activityDate
								AND StartTimeInUTC=@startTime
								AND EndTimeInUTC=@endTime

							UPDATE edw.Stg_TimeSlot
							SET EndTimeInUTC = @leadStartTime,
							TimeSpent = ROUND(DATEDIFF(millisecond, StartTimeInUTC, @leadStartTime)/(1000.0 * 60.0), 4)
							WHERE Dim_UserID=@Dim_UserID
								AND ActivityDate=@activityDate
								AND StartTimeInUTC=@startTime
								AND EndTimeInUTC=@endTime
						  END
						ELSE
						  BEGIN
						    UPDATE edw.Fact_TimeSlot
							SET IsActive=0
							WHERE Dim_UserID=@Dim_UserID
								AND ActivityDate=@activityDate
								AND StartTimeInUTC=@leadStartTime
								AND EndTimeInUTC=@leadEndTime

							UPDATE edw.Stg_TimeSlot
							SET IsActive=0
							WHERE Dim_UserID=@Dim_UserID
								AND ActivityDate=@activityDate
								AND StartTimeInUTC=@leadStartTime
								AND EndTimeInUTC=@leadEndTime
						  END
					  END
				END

		SET @counter = @counter + 1
	END

	DROP TABLE #LEAD
	DROP TABLE #PROCESS


	--******************************************* TIMESLOT RECORDS OVERLAP (obfus) *****************************************
	SET @counter = 1

	SELECT 
	LEAD(StartTimeInUTC) over (partition by ts.dim_userID, ts.activityDate order by StartTimeInUTC) LeadStartTime, 
	LEAD(EndTimeInUTC) over (partition by ts.dim_userID, ts.activityDate order by StartTimeInUTC) LeadEndTime, 
	LEAD(Dim_AppMasterID) over (partition by ts.dim_userID, ts.activityDate order by StartTimeInUTC) LeadDim_AppMasterID, 
	LEAD(Dim_ActivityCategoryID) over (partition by ts.dim_userID, ts.activityDate order by StartTimeInUTC) LeadDim_ActivityCategoryID, 
	LEAD(PurposeID) over (partition by ts.dim_userID, ts.activityDate order by StartTimeInUTC) LeadPurposeID, 
	LEAD(IsActive) over (partition by ts.dim_userID, ts.activityDate order by StartTimeInUTC) LeadIsActive, 
	ts.Dim_UserID, ts.ActivityDate, Dim_AppMasterID, StartTimeInUTC, EndTimeInUTC, TimeSpent, Dim_ActivityCategoryID, PurposeID
	INTO #LEAD_o
	FROM edw.Fact_TimeSlot_Obfus ts
	JOIN (SELECT DISTINCT (56104893/152+Dim_UserID)*-1 Dim_UserID, ActivityDate FROM edw.Stg_UsersDates) ud ON ts.Dim_UserID = ud.Dim_UserID AND ts.ActivityDate= ud.ActivityDate
	WHERE IsActive=1
	ORDER BY StartTimeInUTC asc, EndTimeInUTC asc	


	SELECT ROW_NUMBER() OVER(ORDER BY LeadStartTime) ID,
	ap.LowPriority, ac.IsCore, 
	ap2.LowPriority LeadLowPriority, ac2.IsCore LeadIsCore, 
	l.* 
	INTO #Process_o
	FROM #LEAD_o l
	LEFT JOIN edw.Dim_AppMaster am ON l.Dim_AppMasterID = am.ID
	LEFT JOIN edw.Dim_AppParent ap ON am.Dim_AppParentID = ap.ID
	LEFT JOIN edw.Dim_ActivityCategory ac ON l.Dim_ActivityCategoryID = ac.ID

	LEFT JOIN edw.Dim_AppMaster am2 ON l.LeadDim_AppMasterID = am2.ID
	LEFT JOIN edw.Dim_AppParent ap2 ON am2.Dim_AppParentID = ap2.ID
	LEFT JOIN edw.Dim_ActivityCategory ac2 ON l.LeadDim_ActivityCategoryID = ac2.ID
	WHERE EndTimeInUTC > LeadStartTime 

	WHILE (@counter <= (SELECT MAX(ID) FROM #Process_o))
	BEGIN
		SELECT @lowPriority=COALESCE(LowPriority,0), @leadLowPriority=COALESCE(LeadLowPriority,0), @IsCore=COALESCE(IsCore,0), @leadIsCore=COALESCE(LeadIsCore,0), @PurposeID=PurposeID, @leadPurposeID=LeadPurposeID, 
		@leadStartTime=LeadStartTime, @leadEndTime=LeadEndTime, @Dim_UserID=Dim_UserID, @activityDate=ActivityDate, @startTime=StartTimeInUTC, @endTime=EndTimeInUTC 
		FROM #Process_o
		WHERE ID = @counter

			--********* Conflicting current app is low priority
			IF @lowPriority = 1 AND @leadLowPriority = 0
			  BEGIN
				UPDATE edw.Fact_TimeSlot_Obfus
				SET EndTimeInUTC = @leadStartTime,
					TimeSpent=ROUND(DATEDIFF(millisecond, StartTimeInUTC, @leadStartTime)/(1000.0 * 60.0), 4)
				WHERE Dim_UserID=@Dim_UserID
					AND ActivityDate=@activityDate
					AND StartTimeInUTC=@startTime
					AND EndTimeInUTC=@endTime
			  END
			--********* Conflicting lead app is low priority
			ELSE IF @leadLowPriority = 1 AND @lowPriority = 0
				IF @endTime < @leadEndTime
				  BEGIN
					UPDATE edw.Fact_TimeSlot_Obfus
					SET StartTimeInUTC = @endTime,
						TimeSpent=ROUND(DATEDIFF(millisecond, @endTime, EndTimeInUTC)/(1000.0 * 60.0), 4)
					WHERE Dim_UserID=@Dim_UserID
						AND ActivityDate=@activityDate
						AND StartTimeInUTC=@leadStartTime
						AND EndTimeInUTC=@leadEndTime
				  END
				ELSE
				  BEGIN
					UPDATE edw.Fact_TimeSlot_Obfus
					SET IsActive=0
					WHERE Dim_UserID=@Dim_UserID
						AND ActivityDate=@activityDate
						AND StartTimeInUTC=@leadStartTime
						AND EndTimeInUTC=@leadEndTime
				  END
			--********* Neither conflicting apps are low priority
			ELSE
				BEGIN
					IF (@IsCore=1 AND @leadIsCore=0) OR (@PurposeID=1 AND @leadPurposeID=-1)
						IF @endTime < @leadEndTime
						  BEGIN
							UPDATE edw.Fact_TimeSlot_Obfus
							SET StartTimeInUTC = @endTime,
								TimeSpent=ROUND(DATEDIFF(millisecond, @endTime, EndTimeInUTC)/(1000.0 * 60.0), 4)
							WHERE Dim_UserID=@Dim_UserID
								AND ActivityDate=@activityDate
								AND StartTimeInUTC=@leadStartTime
								AND EndTimeInUTC=@leadEndTime
						  END
						ELSE
						  BEGIN
							UPDATE edw.Fact_TimeSlot_Obfus
							SET IsActive=0
							WHERE Dim_UserID=@Dim_UserID
								AND ActivityDate=@activityDate
								AND StartTimeInUTC=@leadStartTime
								AND EndTimeInUTC=@leadEndTime
						  END
					ELSE -- NOT (@IsCore=1 AND @leadIsCore=0) OR (@PurposeID=1 AND @leadPurposeID=-1)
					  BEGIN
						IF @endTime < @leadEndTime
						  BEGIN
							UPDATE edw.Fact_TimeSlot_Obfus
							SET EndTimeInUTC = @leadStartTime,
							TimeSpent = ROUND(DATEDIFF(millisecond, StartTimeInUTC, @leadStartTime)/(1000.0 * 60.0), 4)
							WHERE Dim_UserID=@Dim_UserID
								AND ActivityDate=@activityDate
								AND StartTimeInUTC=@startTime
								AND EndTimeInUTC=@endTime
						  END
						ELSE
						  BEGIN
							UPDATE edw.Fact_TimeSlot_Obfus
							SET IsActive=0
							WHERE Dim_UserID=@Dim_UserID
								AND ActivityDate=@activityDate
								AND StartTimeInUTC=@leadStartTime
								AND EndTimeInUTC=@leadEndTime
						  END
					  END
				END

		SET @counter = @counter + 1
	END

	DROP TABLE #LEAD_o
	DROP TABLE #PROCESS_o



	--******************************************* calculation for Meeting Private and Work Time *******************************************

		Drop table if Exists #MeetingPrivateWorkTime
		
		Select a.Dim_CompanyID,a.Dim_UserID, b.StartTimeInUTC, b.EndTimeInUTC, b.Dim_ActivityCategoryID---, l.ActivityCategoryID
		, b.PurposeID, b.IsOnPc
		, a.MeetingStartTimeUTC, a.MeetingEndTimeUTC, b.TimeSpent
		, a.MeetingID, a.MeetingSubject, a.ActivityDate INTO #MeetingPrivateWorkTime
		From edw.Fact_TimeSlotMeeting a
		Inner Join edw.Stg_UsersDates k
		On a.Dim_UserID = k.Dim_UserID and a.ActivityDate = k.ActivityDate and a.IsActive = 1
		Join edw.Fact_TimeSlot b
		On a.Dim_UserID = b.Dim_UserID and Convert(Date,a.ActivityDate) = b.ActivityDate
		AND 
		(    (b.StartTimeInUTC BETWEEN a.MeetingStartTimeUTC and a.MeetingEndTimeUTC)
		  OR (b.EndTimeInUTC BETWEEN a.MeetingStartTimeUTC and a.MeetingEndTimeUTC)
		  OR (b.StartTimeInUTC < a.MeetingStartTimeUTC and b.EndTimeInUTC> a.MeetingEndTimeUTC) )
		  AND b.IsActive = 1
		
		
		UPDATE #MeetingPrivateWorkTime
				SET StartTimeInUTC = MeetingStartTimeUTC,
				TimeSpent = ROUND(DATEDIFF(millisecond, MeetingStartTimeUTC, EndTimeInUTC)/(1000.0 * 60.0), 4)
				Where StartTimeInUTC < MeetingStartTimeUTC and EndTimeInUTC > MeetingStartTimeUTC
		
		UPDATE #MeetingPrivateWorkTime
				SET EndTimeInUTC = MeetingEndTimeUTC,
				TimeSpent = ROUND(DATEDIFF(millisecond, StartTimeInUTC,  MeetingEndTimeUTC)/(1000.0 * 60.0), 4)
				Where StartTimeInUTC < MeetingEndTimeUTC and EndTimeInUTC > MeetingEndTimeUTC
		
		Drop table if exists #MeetingPrivateWorkTimeAgg
		
		Select Dim_CompanyID, Dim_UserID, ActivityDate, MeetingID, MeetingSubject,
		sum(Case when PurposeID > 0 and IsOnPc = 1 Then TimeSpent else 0 end) as WorkTimeInMeeting,
		sum(Case when PurposeID < 0 and IsOnPc = 1 Then TimeSpent else 0 end) as PrivateTimeInMeeting 
		INTO #MeetingPrivateWorkTimeAgg
		from #MeetingPrivateWorkTime
		Group by Dim_CompanyID, Dim_UserID, ActivityDate, MeetingID, MeetingSubject
		
		UPDATE
		    edw.Fact_TimeSlotMeeting
		SET
		    Fact_TimeSlotMeeting.WorkTimeInMeeting = RAN.WorkTimeInMeeting,
			Fact_TimeSlotMeeting.PrivateTimeInMeeting = RAN.PrivateTimeInMeeting
		FROM
		    edw.Fact_TimeSlotMeeting SI
		INNER JOIN
		    #MeetingPrivateWorkTimeAgg RAN
		ON 
			SI.Dim_CompanyID = RAN.Dim_CompanyID
		    AND SI.Dim_UserID = RAN.Dim_UserID 
			AND SI.ActivityDate = RAN.ActivityDate
			AND SI.MeetingID = RAN.MeetingID
			AND SI.MeetingSubject = RAN.MeetingSubject
			;


END


GO
/****** Object:  StoredProcedure [edw].[sproc_MergeConflictingTimeSlotsTest]    Script Date: 9/10/2021 8:10:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE   PROCEDURE [edw].[sproc_MergeConflictingTimeSlotsTest]

AS
SET ARITHABORT ON

BEGIN

	DECLARE @counter INT = 1
	DECLARE @lowPriority BIT, @leadLowPriority BIT, @IsCore BIT, @leadIsCore BIT
	DECLARE @PurposeID INT, @leadPurposeID INT, @Dim_UserID INT
	DECLARE @leadStartTime DATETIME, @leadEndTime DATETIME, @startTime DATETIME, @endTime DATETIME, @uploadTime DATETIME
	DECLARE @activityDate DATE

	--******************************************* TIMESLOT RECORDS WITH SAME START AND END TIMES *****************************************

	SELECT ROW_NUMBER() OVER(ORDER BY StartTimeInUTC) ID, StartTimeInUTC, EndTimeInUTC, Dim_UserID, ActivityDate 
	INTO #Process2
	FROM edw.Fact_TimeSlot
	--WHERE ActivityDate IN (SELECT DISTINCT CAST(CONVERT(VARCHAR(10),DATEADD(minute, cast(tzoffset as float)*60, activityTime), 101) as Date) FROM edw.Stg_Lenses WHERE activityTime IS NOT NULL and activityType IN ('application','meeting'))
	WHERE ActivityDate > GETDATE()-16
		AND IsActive=1
	GROUP BY StartTimeInUTC, EndTimeInUTC, Dim_UserID, ActivityDate
	HAVING COUNT(*) > 1


	WHILE (@counter <= (SELECT MAX(ID) FROM #Process2))
	BEGIN
		--set @startTime, @endTime, @dimUserID, @activityDate
		SELECT @startTime=StartTimeInUTC, @endTime=EndTimeInUTC, @Dim_UserID=Dim_UserID, @activityDate=ActivityDate
		FROM #Process2
		WHERE ID=@counter

		--first update IsActive = false for all
		UPDATE edw.Fact_TimeSlot
		SET IsActive=0
		WHERE StartTimeInUTC=@startTime
			AND EndTimeInUTC=@endTime
			AND Dim_UserID=@Dim_UserID
			AND ActivityDate=@activityDate

		--then update top record IsActive = true (based on LowPriority/PurposeID/IsCore)
		;WITH CTE
			AS (SELECT TOP (1) ts.IsActive, TimeSpent, StartTimeInUTC, EndTimeInUTC
				FROM edw.Fact_TimeSlot ts
				LEFT JOIN edw.Dim_AppMaster am ON ts.Dim_AppMasterID = am.ID
				LEFT JOIN edw.Dim_AppParent ap ON am.Dim_AppParentID = ap.ID
				LEFT JOIN edw.Dim_ActivityCategory ac ON ts.Dim_ActivityCategoryID = ac.ID
				WHERE StartTimeInUTC=@startTime
					AND EndTimeInUTC=@endTime
					AND Dim_UserID=@Dim_UserID
					AND ActivityDate=@activityDate
				ORDER BY LowPriority ASC, PurposeID DESC, ac.IsCore DESC	
				)

		UPDATE CTE
		SET IsActive = 1,
		TimeSpent = ROUND(DATEDIFF(millisecond, StartTimeInUTC, EndTimeInUTC)/(1000.0 * 60.0), 4)


		-- same for stg_TimeSlots
		UPDATE edw.Stg_TimeSlot
		SET IsActive=0
		WHERE StartTimeInUTC=@startTime
			AND EndTimeInUTC=@endTime
			AND Dim_UserID=@Dim_UserID
			AND ActivityDate=@activityDate


		;WITH CTE_stg
			AS (SELECT TOP (1) ts.IsActive, TimeSpent, StartTimeInUTC, EndTimeInUTC
				FROM edw.Stg_TimeSlot ts
				LEFT JOIN edw.Dim_AppMaster am ON ts.Dim_AppMasterID = am.ID
				LEFT JOIN edw.Dim_AppParent ap ON am.Dim_AppParentID = ap.ID
				LEFT JOIN edw.Dim_ActivityCategory ac ON ts.Dim_ActivityCategoryID = ac.ID
				WHERE StartTimeInUTC=@startTime
					AND EndTimeInUTC=@endTime
					AND Dim_UserID=@Dim_UserID
					AND ActivityDate=@activityDate
				ORDER BY LowPriority ASC, PurposeID DESC, ac.IsCore DESC	
				)

		UPDATE CTE_stg
		SET IsActive = 1,
		TimeSpent = ROUND(DATEDIFF(millisecond, StartTimeInUTC, EndTimeInUTC)/(1000.0 * 60.0), 4)

		SET @counter=@counter+1
	END

	DROP TABLE #Process2



	--******************************************* TIMESLOT RECORDS OVERLAP *****************************************
	SET @counter = 1

	SELECT 
	LEAD(StartTimeInUTC) over (partition by dim_userID, activityDate order by StartTimeInUTC) LeadStartTime, 
	LEAD(EndTimeInUTC) over (partition by dim_userID, activityDate order by StartTimeInUTC) LeadEndTime, 
	LEAD(Dim_AppMasterID) over (partition by dim_userID, activityDate order by StartTimeInUTC) LeadDim_AppMasterID, 
	LEAD(Dim_ActivityCategoryID) over (partition by dim_userID, activityDate order by StartTimeInUTC) LeadDim_ActivityCategoryID, 
	LEAD(PurposeID) over (partition by dim_userID, activityDate order by StartTimeInUTC) LeadPurposeID, 
	LEAD(IsActive) over (partition by dim_userID, activityDate order by StartTimeInUTC) LeadIsActive, 
	Dim_UserID, ActivityDate, Dim_AppMasterID, StartTimeInUTC, EndTimeInUTC, TimeSpent, Dim_ActivityCategoryID, PurposeID
	INTO #LEAD
	FROM edw.Fact_TimeSlot
	WHERE ActivityDate > GETDATE()-16
		AND IsActive=1
	ORDER BY StartTimeInUTC asc, EndTimeInUTC asc


	SELECT ROW_NUMBER() OVER(ORDER BY LeadStartTime) ID,
	ap.LowPriority, ac.IsCore, 
	ap2.LowPriority LeadLowPriority, ac2.IsCore LeadIsCore, 
	l.* 
	INTO #Process
	FROM #LEAD l
	LEFT JOIN edw.Dim_AppMaster am ON l.Dim_AppMasterID = am.ID
	LEFT JOIN edw.Dim_AppParent ap ON am.Dim_AppParentID = ap.ID
	LEFT JOIN edw.Dim_ActivityCategory ac ON l.Dim_ActivityCategoryID = ac.ID

	LEFT JOIN edw.Dim_AppMaster am2 ON l.LeadDim_AppMasterID = am2.ID
	LEFT JOIN edw.Dim_AppParent ap2 ON am2.Dim_AppParentID = ap2.ID
	LEFT JOIN edw.Dim_ActivityCategory ac2 ON l.LeadDim_ActivityCategoryID = ac2.ID
	WHERE EndTimeInUTC > LeadStartTime 

	WHILE (@counter <= (SELECT MAX(ID) FROM #Process))
	BEGIN
		SELECT @lowPriority=LowPriority, @leadLowPriority=LeadLowPriority, @IsCore=IsCore, @leadIsCore=LeadIsCore, @PurposeID=PurposeID, @leadPurposeID=LeadPurposeID, 
		@leadStartTime=LeadStartTime, @leadEndTime=LeadEndTime, @Dim_UserID=Dim_UserID, @activityDate=ActivityDate, @startTime=StartTimeInUTC, @endTime=EndTimeInUTC 
		FROM #Process
		WHERE ID = @counter

			--********* Conflicting current app is low priority
			IF @lowPriority IS NOT NULL AND @leadLowPriority IS NULL
			  BEGIN
				UPDATE edw.Fact_TimeSlot
				SET EndTimeInUTC = @leadStartTime,
					TimeSpent=ROUND(DATEDIFF(millisecond, StartTimeInUTC, @leadStartTime)/(1000.0 * 60.0), 4)
					--,DeviceID = 111
				WHERE Dim_UserID=@Dim_UserID
					AND ActivityDate=@activityDate
					AND StartTimeInUTC=@startTime
					AND EndTimeInUTC=@endTime

				UPDATE edw.Stg_TimeSlot
				SET EndTimeInUTC = @leadStartTime,
					TimeSpent=ROUND(DATEDIFF(millisecond, StartTimeInUTC, @leadStartTime)/(1000.0 * 60.0), 4)
					--,DeviceID = 111
				WHERE Dim_UserID=@Dim_UserID
					AND ActivityDate=@activityDate
					AND StartTimeInUTC=@startTime
					AND EndTimeInUTC=@endTime
			  END
			--********* Conflicting lead app is low priority
			ELSE IF @leadLowPriority IS NOT NULL AND @lowPriority IS NULL
				IF @endTime < @leadEndTime
				  BEGIN
					UPDATE edw.Fact_TimeSlot
					SET StartTimeInUTC = @endTime,
						TimeSpent=ROUND(DATEDIFF(millisecond, @endTime, EndTimeInUTC)/(1000.0 * 60.0), 4)
						--,DeviceID=333
					WHERE Dim_UserID=@Dim_UserID
						AND ActivityDate=@activityDate
						AND StartTimeInUTC=@leadStartTime
						AND EndTimeInUTC=@leadEndTime

					UPDATE edw.Stg_TimeSlot
					SET StartTimeInUTC = @endTime,
						TimeSpent=ROUND(DATEDIFF(millisecond, @endTime, EndTimeInUTC)/(1000.0 * 60.0), 4)
						--,DeviceID=333
					WHERE Dim_UserID=@Dim_UserID
						AND ActivityDate=@activityDate
						AND StartTimeInUTC=@leadStartTime
						AND EndTimeInUTC=@leadEndTime
				  END
				ELSE
				  BEGIN
					UPDATE edw.Fact_TimeSlot
					SET IsActive=0
					WHERE Dim_UserID=@Dim_UserID
						AND ActivityDate=@activityDate
						AND StartTimeInUTC=@leadStartTime
						AND EndTimeInUTC=@leadEndTime

					UPDATE edw.Stg_TimeSlot
					SET IsActive=0
					WHERE Dim_UserID=@Dim_UserID
						AND ActivityDate=@activityDate
						AND StartTimeInUTC=@leadStartTime
						AND EndTimeInUTC=@leadEndTime
				  END
			--********* Neither conflicting apps are low priority
			ELSE
				BEGIN
					IF (@IsCore=1 AND @leadIsCore=0) OR (@PurposeID=1 AND @leadPurposeID=-1)
						IF @endTime < @leadEndTime
						  BEGIN
							UPDATE edw.Fact_TimeSlot
							SET StartTimeInUTC = @endTime,
								TimeSpent=ROUND(DATEDIFF(millisecond, @endTime, EndTimeInUTC)/(1000.0 * 60.0), 4)
								--,DeviceID=555
							WHERE Dim_UserID=@Dim_UserID
								AND ActivityDate=@activityDate
								AND StartTimeInUTC=@leadStartTime
								AND EndTimeInUTC=@leadEndTime

							UPDATE edw.Stg_TimeSlot
							SET StartTimeInUTC = @endTime,
								TimeSpent=ROUND(DATEDIFF(millisecond, @endTime, EndTimeInUTC)/(1000.0 * 60.0), 4)
								--,DeviceID=555
							WHERE Dim_UserID=@Dim_UserID
								AND ActivityDate=@activityDate
								AND StartTimeInUTC=@leadStartTime
								AND EndTimeInUTC=@leadEndTime
						  END
						ELSE
						  BEGIN
							UPDATE edw.Fact_TimeSlot
							SET IsActive=0
							WHERE Dim_UserID=@Dim_UserID
								AND ActivityDate=@activityDate
								AND StartTimeInUTC=@leadStartTime
								AND EndTimeInUTC=@leadEndTime

							UPDATE edw.Stg_TimeSlot
							SET IsActive=0
							WHERE Dim_UserID=@Dim_UserID
								AND ActivityDate=@activityDate
								AND StartTimeInUTC=@leadStartTime
								AND EndTimeInUTC=@leadEndTime
						  END
					ELSE
					  BEGIN
						UPDATE edw.Fact_TimeSlot
						SET EndTimeInUTC = @leadStartTime,
						TimeSpent = ROUND(DATEDIFF(millisecond, StartTimeInUTC, @leadStartTime)/(1000.0 * 60.0), 4)
						--,DeviceID=777
						WHERE Dim_UserID=@Dim_UserID
							AND ActivityDate=@activityDate
							AND StartTimeInUTC=@startTime
							AND EndTimeInUTC=@endTime

						UPDATE edw.Stg_TimeSlot
						SET EndTimeInUTC = @leadStartTime,
						TimeSpent = ROUND(DATEDIFF(millisecond, StartTimeInUTC, @leadStartTime)/(1000.0 * 60.0), 4)
						--,DeviceID=777
						WHERE Dim_UserID=@Dim_UserID
							AND ActivityDate=@activityDate
							AND StartTimeInUTC=@startTime
							AND EndTimeInUTC=@endTime
					  END
				END

		SET @counter = @counter + 1
	END

	DROP TABLE #LEAD
	DROP TABLE #PROCESS

END
GO
/****** Object:  StoredProcedure [edw].[sproc_NotificationResults]    Script Date: 9/10/2021 8:10:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

	
CREATE PROCEDURE [edw].[sproc_NotificationResults]
--PLEASE SEE PRODUCT BACKLOG ITEMS 19864 AND 18540
(
	@CompanyID INT, 
	@Entity VARCHAR(40),
	@EntityValue VARCHAR(200),
	@AlertType VARCHAR(40),
	@AlertTypeValue VARCHAR(100) = NULL,
	@EffectiveDate DATE,
	@IsAlertPerEmployee BIT,
	@AlertOperator VARCHAR(2),
	@PredictiveValue FLOAT,
	@Debug tinyint = 0
)
AS 
BEGIN
    SET NOCOUNT ON
	SET DATEFIRST 1


		begin try

			INSERT INTO [edw].[Log_NotificationTrace] (CompanyID, LogData, ProcessTime)
		    Select @CompanyID,  'CompanyID= ' +  '' + IsNull(CAST(@CompanyID AS VARCHAR), 'null') + '' +  ',  Entity=  ' +  '' + IsNull(CAST(@Entity AS VARCHAR), 'null') + '' +
		 ',  EntityValue=  ' +  '' + IsNull(CAST(@EntityValue AS VARCHAR), 'null') + '' +  ',  AlertType=  ' +  '' + IsNull(CAST(@AlertType AS VARCHAR), 'null') + '' +
		 ',  AlertTypeValue=  ' +  ''	 + IsNull(CAST(IsNull(@AlertTypeValue, 'null') AS VARCHAR), '') + '' +  ',  EffectiveDate=  ' +  '' + IsNull(CAST(@EffectiveDate AS VARCHAR), 'null') + '' +
		 ',  IsAlertPerEmployee=  ' +  '' + IsNull(CAST(@IsAlertPerEmployee AS VARCHAR), 'null') + '' +  ',  AlertOperator=  ' +  '' + IsNull(CAST(@AlertOperator AS VARCHAR), 'null') + '' +
		 ',  PredictiveValue=  ' +  '' + IsNull(CAST(@PredictiveValue AS VARCHAR), 'null') + '' +  ',  Debug=  ' +  '' + IsNull(CAST(@Debug AS VARCHAR), 'null') + ''
		
		  ,GetUTCDate() 

		end try
		begin catch

			print ' error in trace log ' 

		end catch 

	


	DECLARE @YearMonthNum INT,
			@WeekNum INT,
			@strSQL NVARCHAR(MAX),
			@strSQL_UserCount NVARCHAR(MAX),
			@PredictiveValueInMinutes FLOAT,
			@UserCount INT,
			@ParmDef NVARCHAR(50),
			@ManagerDimUserID INT

	SET @PredictiveValueInMinutes = @PredictiveValue * 60

	SELECT @WeekNum=WeekNum, @YearMonthNum=YearMonthNum FROM edw.Dim_Date
    WHERE Date=DATEADD(WK,-1, @EffectiveDate)


	SELECT @ManagerDimUserID=ManagerDimUserID FROM edw.Dim_Department
	WHERE CompanyID=@CompanyID AND DepartmentName=@EntityValue

	
	--******************* GET USER COUNT ******************

	SET @strSQL_UserCount=

	'SELECT @retvalOUT=COUNT(1) FROM
		(SELECT u.ID
			FROM edw.Fact_DailyActivity da 
			JOIN edw.Dim_User u ON da.Dim_UserID = u.ID
			JOIN edw.Dim_Department d ON u.Dim_DepartmentID = d.ID
			JOIN edw.Dim_ActivityCategory ac ON da.Dim_ActivityCategoryID = ac.ID '

				+ CASE @AlertType 
					WHEN 'Application time' THEN ' JOIN edw.Dim_AppMaster am ON da.Dim_AppMasterID = am.ID '
					ELSE ''
				END
			 + '

			JOIN edw.Dim_Date dt ON da.ActivityDate = dt.Date
			WHERE da.Dim_CompanyID=' + CAST(@CompanyID AS varchar(5)) + ' AND u.IsActivityCollectionOn = 1 AND u.IsActive = 1 AND YearMonthNum='+ CAST(@YearMonthNum AS varchar(20)) + ' AND WeekNum=' + CAST(@WeekNum AS varchar(20)) 
				+ CASE @AlertType 
					WHEN 'Activity time' THEN ' AND da.PurposeID <> -1 AND ac.ActivityCategoryName=''' + @AlertTypeValue + ''''
					WHEN 'Application time' THEN '  AND da.PurposeID <> -1 AND am.AppName=''' + @AlertTypeValue + ''''
					WHEN 'Total hours' THEN '  AND da.PurposeID <> -1 '
					WHEN 'Unaccounted hours' THEN ' AND da.PurposeID = -1 AND ac.ActivityCategoryID=0 '
				  END
			 + ' AND d.DepartmentName=''' + @EntityValue + ''''
			 + CASE
				WHEN @ManagerDimUserID IS NOT NULL THEN ' AND u.ID <> ' + CAST(@ManagerDimUserID AS varchar(10))
			   END
			+ CHAR(10) +
			+ ' GROUP BY u.ID
		) base'


	
	if (@Debug = 1)
	begin

		print 'strSQL for UserCount => ' +  IsNull(@strSQL_UserCount, ' Empty' ) + CHAR(10)
	
	end
	

	--**** assign @UserCount ****
	SET @ParmDef = '@retvalOUT INT OUTPUT'
	EXEC sp_EXECUTESQL @strSQL_UserCount, @ParmDef, @retvalOUT= @UserCount OUTPUT


	if (@UserCount IS NULL OR @UserCount = 0)
		set @UserCount = 1

	--**************** MAIN OUTPUT ***************
	/**
	Note: TimeSpentInCalendarDay is divided by 5 since 5 working days in week. Also when @IsAlertPerEmployee=0 (by Dept), we want to multiply the # of users in Dept by 5.
	**/

	SET @strSQL=

	'SELECT ' 
	+ CASE @IsAlertPerEmployee 
		WHEN 1 THEN 'u.UserID PartyID, u.FirstName + '' '' + IsNull(u.LastName, '''' ) PartyName, '
		ELSE 'd.DepartmentID PartyID, d.DepartmentName PartyName, '
	  END
	+ CASE @IsAlertPerEmployee
		WHEN 1 THEN
			'CAST((SUM(TimeSpentInCalendarDay) / 5) / 60 AS decimal(18,2)) TimeSpent,
			CAST((SUM(TimeSpentInCalendarDay) / 5) / 60 AS decimal(18,2)) - ' + CAST(@PredictiveValue AS varchar(10)) + ' ThresholdDiff '
		ELSE
			'CAST((SUM(TimeSpentInCalendarDay) / (5*' + CAST(@UserCount AS varchar(10)) + ')) / 60 AS DECIMAL(18,2)) TimeSpent,
			CAST((SUM(TimeSpentInCalendarDay) / (5*' + CAST(@UserCount AS varchar(10)) + ')) / 60 AS DECIMAL(18,2)) - ' + CAST(@PredictiveValue AS varchar(10)) + ' ThresholdDiff '
	  END
	+
	'FROM edw.Fact_DailyActivity da 
	JOIN edw.Dim_User u ON da.Dim_UserID = u.ID  
	JOIN edw.Dim_Department d ON u.Dim_DepartmentID = d.ID
	JOIN edw.Dim_ActivityCategory ac ON da.Dim_ActivityCategoryID = ac.ID '
	
				+ CASE @AlertType 
					WHEN 'Application time' THEN ' JOIN edw.Dim_AppMaster am ON da.Dim_AppMasterID = am.ID '
					ELSE ''
				END
			 + '
	JOIN edw.Dim_Date dt ON da.ActivityDate = dt.Date
	WHERE da.Dim_CompanyID=' + CAST(@CompanyID AS varchar(5)) + '  AND u.IsActivityCollectionOn = 1 AND u.IsActive = 1 AND YearMonthNum='+ CAST(@YearMonthNum AS varchar(20)) + ' AND WeekNum=' + CAST(@WeekNum AS varchar(20)) 
	+ CASE @AlertType 
		WHEN 'Activity time' THEN ' AND da.PurposeID <> -1 AND ac.ActivityCategoryName=''' + @AlertTypeValue + ''''
		WHEN 'Application time' THEN '  AND da.PurposeID <> -1 AND am.AppName=''' + @AlertTypeValue + ''''
		WHEN 'Total hours' THEN '  AND da.PurposeID <> -1 '
		WHEN 'Unaccounted hours' THEN ' AND da.PurposeID = -1 AND ac.ActivityCategoryID=0 '
	  END
	+ ' AND d.DepartmentName=''' + @EntityValue + ''''
	+ CASE
		WHEN @ManagerDimUserID IS NOT NULL THEN ' AND u.ID <> ' + CAST(@ManagerDimUserID AS varchar(10))
	  END
	+ CHAR(10)
	+ CASE @IsAlertPerEmployee 
		WHEN 1 THEN 'GROUP BY u.UserID, u.FirstName + '' '' + IsNull(u.LastName, '''' )'
		ELSE ' GROUP BY d.DepartmentID, d.DepartmentName '
	  END
	+ CHAR(10)	
	+ CASE @IsAlertPerEmployee
		WHEN 1 THEN 'HAVING SUM(TimeSpentInCalendarDay) / 5 '  + @AlertOperator + CAST(@PredictiveValueInMinutes AS varchar(20))
		ELSE 'HAVING SUM(TimeSpentInCalendarDay) / (5*' + CAST(@UserCount AS varchar(10)) + ') ' + @AlertOperator + CAST(@PredictiveValueInMinutes AS varchar(20))
	  END

	  ---------------- UNION of no data users for <  -----------------
	+ CHAR(10)
		
	+ CASE charindex('<',@AlertOperator) WHEN 0 THEN ''
	  ELSE CASE WHEN @IsAlertPerEmployee = 0 THEN '' ELSE '
				UNION ALL 
			  
			  '
		+
			'	SELECT distinct  '
		+ 
			CASE @IsAlertPerEmployee 
				WHEN 1 THEN 'u.UserID PartyID, u.FirstName + '' '' + IsNull(u.LastName, '''' ) PartyName, '
				ELSE 'd.DepartmentID PartyID, d.DepartmentName PartyName, '
			END
		+	CASE @IsAlertPerEmployee
				WHEN 1 THEN
					'0 TimeSpent,
					 0 - ' + CAST(@PredictiveValue AS varchar(10)) + ' ThresholdDiff '
				ELSE
					'0 TimeSpent,
					 0 - ' + CAST(@PredictiveValue AS varchar(10)) + ' ThresholdDiff '
			END
		+
		'
		FROM edw.Dim_User u 
		JOIN edw.Dim_Department d ON u.Dim_DepartmentID = d.ID
	
		WHERE u.CompanyID=' + CAST(@CompanyID AS varchar(5)) + '  AND u.IsActivityCollectionOn = 1 AND u.IsActive = 1
		
			AND d.DepartmentName=''' + @EntityValue + ''''
		+ CASE
			WHEN @ManagerDimUserID IS NOT NULL THEN ' AND u.ID <> ' + CAST(@ManagerDimUserID AS varchar(10))
		  END
			+ CHAR(10) +
			' AND NOT EXISTS (
				SELECT 1 FROM edw.Fact_DailyActivity da 
					INNER JOIN edw.Dim_ActivityCategory ac ON da.Dim_ActivityCategoryID = ac.ID '
					
				+ CASE @AlertType 
					WHEN 'Application time' THEN ' JOIN edw.Dim_AppMaster am ON da.Dim_AppMasterID = am.ID '
					ELSE ''
				END
			 + '
					INNER JOIN edw.Dim_Date dt ON da.ActivityDate = dt.Date
					WHERE
						da.Dim_UserID = u.ID AND YearMonthNum='+ CAST(@YearMonthNum AS varchar(20)) + ' AND WeekNum=' + CAST(@WeekNum AS varchar(20)) 
						+ CASE @AlertType 
							WHEN 'Activity time' THEN ' AND da.PurposeID <> -1 AND ac.ActivityCategoryName=''' + @AlertTypeValue + ''''
							WHEN 'Application time' THEN '  AND da.PurposeID <> -1 AND am.AppName=''' + @AlertTypeValue + ''''
							WHEN 'Total hours' THEN '  AND da.PurposeID <> -1 '
							WHEN 'Unaccounted hours' THEN ' AND da.PurposeID = -1 AND ac.ActivityCategoryID=0 '
						  END  + ' ) '

	END
	END

	if (@Debug = 1)
	begin

		print 'strSQL for Results => ' +  IsNull(@strSQL, ' Empty' )
	
	end
	
	EXEC (@strSQL)


END


GO
/****** Object:  StoredProcedure [edw].[sproc_NotificationResultsTest]    Script Date: 9/10/2021 8:10:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [edw].[sproc_NotificationResultsTest]
--PLEASE SEE PRODUCT BACKLOG ITEMS 19864 AND 18540
(
	@CompanyID INT, 
	@Entity VARCHAR(40),
	@EntityValue VARCHAR(200),
	@AlertType VARCHAR(40),
	@AlertTypeValue VARCHAR(100) = NULL,
	@EffectiveDate DATE,
	@IsAlertPerEmployee BIT,
	@AlertOperator VARCHAR(2),
	@PredictiveValue FLOAT,
	@Debug tinyint = 0
)
AS 
BEGIN
    SET NOCOUNT ON
	SET DATEFIRST 1

	DECLARE @YearMonthNum INT,
			@WeekNum INT,
			@strSQL NVARCHAR(MAX),
			@strSQL_UserCount NVARCHAR(MAX),
			@PredictiveValueInMinutes FLOAT,
			@UserCount INT,
			@ParmDef NVARCHAR(50),
			@ManagerDimUserID INT

	SET @PredictiveValueInMinutes = @PredictiveValue * 60

	SELECT @WeekNum=WeekNum, @YearMonthNum=YearMonthNum FROM edw.Dim_Date
    WHERE Date=DATEADD(WK,-1, @EffectiveDate)


	SELECT @ManagerDimUserID=ManagerDimUserID FROM edw.Dim_Department
	WHERE CompanyID=@CompanyID AND DepartmentName=@EntityValue



	if (@Debug = 0)
	begin
	
		INSERT INTO [edw].[Log_NotificationTrace] (CompanyID, Val, ProcessTime)
		Select @CompanyID,  'CompanyID= ' +  '' + CAST(@CompanyID AS VARCHAR) + '' +  '  Entity=  ' +  '' + CAST(@Entity AS VARCHAR) + '' +
		 '  EntityValue=  ' +  '' + CAST(@EntityValue AS VARCHAR) + '' +  '  AlertType=  ' +  '' + CAST(@AlertType AS VARCHAR) + '' +
		 '  AlertTypeValue=  ' +  '' + CAST(@AlertTypeValue AS VARCHAR) + '' +  '  EffectiveDate=  ' +  '' + CAST(@EffectiveDate AS VARCHAR) + '' +
		 '  IsAlertPerEmployee=  ' +  '' + CAST(@IsAlertPerEmployee AS VARCHAR) + '' +  '  AlertOperator=  ' +  '' + CAST(@AlertOperator AS VARCHAR) + '' +
		 '  PredictiveValue=  ' +  '' + CAST(@PredictiveValue AS VARCHAR) + '' +  '  Debug=  ' +  '' + CAST(@Debug AS VARCHAR) + ''
		
		,GetUTCDate() 
	
	end
	
	
	--******************* GET USER COUNT ******************

	SET @strSQL_UserCount=

	'SELECT @retvalOUT=COUNT(1) FROM
		(SELECT u.ID
			FROM edw.Fact_DailyActivity da 
			JOIN edw.Dim_User u ON da.Dim_UserID = u.ID
			JOIN edw.Dim_Department d ON u.Dim_DepartmentID = d.ID
			JOIN edw.Dim_ActivityCategory ac ON da.Dim_ActivityCategoryID = ac.ID '

				+ CASE @AlertType 
					WHEN 'Application time' THEN ' JOIN edw.Dim_AppMaster am ON da.Dim_AppMasterID = am.ID '
					ELSE ''
				END
			 + '

			JOIN edw.Dim_Date dt ON da.ActivityDate = dt.Date
			WHERE da.Dim_CompanyID=' + CAST(@CompanyID AS varchar(5)) + ' AND u.IsActivityCollectionOn = 1 AND u.IsActive = 1 AND YearMonthNum='+ CAST(@YearMonthNum AS varchar(20)) + ' AND WeekNum=' + CAST(@WeekNum AS varchar(20)) 
				+ CASE @AlertType 
					WHEN 'Activity time' THEN ' AND da.PurposeID <> -1 AND ac.ActivityCategoryName=''' + @AlertTypeValue + ''''
					WHEN 'Application time' THEN '  AND da.PurposeID <> -1 AND am.AppName=''' + @AlertTypeValue + ''''
					WHEN 'Total hours' THEN '  AND da.PurposeID <> -1 '
					WHEN 'Unaccounted hours' THEN ' AND da.PurposeID = -1 AND ac.ActivityCategoryID=0 '
				  END
			 + ' AND d.DepartmentName=''' + @EntityValue + ''''
			 + CASE
				WHEN @ManagerDimUserID IS NOT NULL THEN ' AND u.ID <> ' + CAST(@ManagerDimUserID AS varchar(10))
			   END
			+ CHAR(10) +
			+ ' GROUP BY u.ID
		) base'


	
	if (@Debug = 1)
	begin

		print 'strSQL for UserCount => ' +  IsNull(@strSQL_UserCount, ' Empty' ) + CHAR(10)
	
	end
	

	--**** assign @UserCount ****
	SET @ParmDef = '@retvalOUT INT OUTPUT'
	EXEC sp_EXECUTESQL @strSQL_UserCount, @ParmDef, @retvalOUT= @UserCount OUTPUT


	if (@UserCount IS NULL OR @UserCount = 0)
		set @UserCount = 1

	--**************** MAIN OUTPUT ***************
	/**
	Note: TimeSpentInCalendarDay is divided by 5 since 5 working days in week. Also when @IsAlertPerEmployee=0 (by Dept), we want to multiply the # of users in Dept by 5.
	**/

	SET @strSQL=

	'SELECT ' 
	+ CASE @IsAlertPerEmployee 
		WHEN 1 THEN 'u.UserID PartyID, u.FirstName + '' '' + IsNull(u.LastName, '''' ) PartyName, '
		ELSE 'd.DepartmentID PartyID, d.DepartmentName PartyName, '
	  END
	+ CASE @IsAlertPerEmployee
		WHEN 1 THEN
			'CAST((SUM(TimeSpentInCalendarDay) / 5) / 60 AS decimal(18,2)) TimeSpent,
			CAST((SUM(TimeSpentInCalendarDay) / 5) / 60 AS decimal(18,2)) - ' + CAST(@PredictiveValue AS varchar(10)) + ' ThresholdDiff '
		ELSE
			'CAST((SUM(TimeSpentInCalendarDay) / (5*' + CAST(@UserCount AS varchar(10)) + ')) / 60 AS DECIMAL(18,2)) TimeSpent,
			CAST((SUM(TimeSpentInCalendarDay) / (5*' + CAST(@UserCount AS varchar(10)) + ')) / 60 AS DECIMAL(18,2)) - ' + CAST(@PredictiveValue AS varchar(10)) + ' ThresholdDiff '
	  END
	+
	'FROM edw.Fact_DailyActivity da 
	JOIN edw.Dim_User u ON da.Dim_UserID = u.ID  
	JOIN edw.Dim_Department d ON u.Dim_DepartmentID = d.ID
	JOIN edw.Dim_ActivityCategory ac ON da.Dim_ActivityCategoryID = ac.ID '
	
				+ CASE @AlertType 
					WHEN 'Application time' THEN ' JOIN edw.Dim_AppMaster am ON da.Dim_AppMasterID = am.ID '
					ELSE ''
				END
			 + '
	JOIN edw.Dim_Date dt ON da.ActivityDate = dt.Date
	WHERE da.Dim_CompanyID=' + CAST(@CompanyID AS varchar(5)) + '  AND u.IsActivityCollectionOn = 1 AND u.IsActive = 1 AND YearMonthNum='+ CAST(@YearMonthNum AS varchar(20)) + ' AND WeekNum=' + CAST(@WeekNum AS varchar(20)) 
	+ CASE @AlertType 
		WHEN 'Activity time' THEN ' AND da.PurposeID <> -1 AND ac.ActivityCategoryName=''' + @AlertTypeValue + ''''
		WHEN 'Application time' THEN '  AND da.PurposeID <> -1 AND am.AppName=''' + @AlertTypeValue + ''''
		WHEN 'Total hours' THEN '  AND da.PurposeID <> -1 '
		WHEN 'Unaccounted hours' THEN ' AND da.PurposeID = -1 AND ac.ActivityCategoryID=0 '
	  END
	+ ' AND d.DepartmentName=''' + @EntityValue + ''''
	+ CASE
		WHEN @ManagerDimUserID IS NOT NULL THEN ' AND u.ID <> ' + CAST(@ManagerDimUserID AS varchar(10))
	  END
	+ CHAR(10)
	+ CASE @IsAlertPerEmployee 
		WHEN 1 THEN 'GROUP BY u.UserID, u.FirstName + '' '' + IsNull(u.LastName, '''' )'
		ELSE ' GROUP BY d.DepartmentID, d.DepartmentName '
	  END
	+ CHAR(10)	
	+ CASE @IsAlertPerEmployee
		WHEN 1 THEN 'HAVING SUM(TimeSpentInCalendarDay) / 5 '  + @AlertOperator + CAST(@PredictiveValueInMinutes AS varchar(20))
		ELSE 'HAVING SUM(TimeSpentInCalendarDay) / (5*' + CAST(@UserCount AS varchar(10)) + ') ' + @AlertOperator + CAST(@PredictiveValueInMinutes AS varchar(20))
	  END

	  ---------------- UNION of no data users for <  -----------------
	+ CHAR(10)
		
	+ CASE charindex('<',@AlertOperator) WHEN 0 THEN ''
	  ELSE CASE WHEN @IsAlertPerEmployee = 0 THEN '' ELSE '
				UNION ALL 
			  
			  '
		+
			'	SELECT distinct  '
		+ 
			CASE @IsAlertPerEmployee 
				WHEN 1 THEN 'u.UserID PartyID, u.FirstName + '' '' + IsNull(u.LastName, '''' ) PartyName, '
				ELSE 'd.DepartmentID PartyID, d.DepartmentName PartyName, '
			END
		+	CASE @IsAlertPerEmployee
				WHEN 1 THEN
					'0 TimeSpent,
					 0 - ' + CAST(@PredictiveValue AS varchar(10)) + ' ThresholdDiff '
				ELSE
					'0 TimeSpent,
					 0 - ' + CAST(@PredictiveValue AS varchar(10)) + ' ThresholdDiff '
			END
		+
		'
		FROM edw.Dim_User u 
		JOIN edw.Dim_Department d ON u.Dim_DepartmentID = d.ID
	
		WHERE u.CompanyID=' + CAST(@CompanyID AS varchar(5)) + '  AND u.IsActivityCollectionOn = 1 AND u.IsActive = 1
		
			AND d.DepartmentName=''' + @EntityValue + ''''
		+ CASE
			WHEN @ManagerDimUserID IS NOT NULL THEN ' AND u.ID <> ' + CAST(@ManagerDimUserID AS varchar(10))
		  END
			+ CHAR(10) +
			' AND NOT EXISTS (
				SELECT 1 FROM edw.Fact_DailyActivity da 
					INNER JOIN edw.Dim_ActivityCategory ac ON da.Dim_ActivityCategoryID = ac.ID '
					
				+ CASE @AlertType 
					WHEN 'Application time' THEN ' JOIN edw.Dim_AppMaster am ON da.Dim_AppMasterID = am.ID '
					ELSE ''
				END
			 + '
					INNER JOIN edw.Dim_Date dt ON da.ActivityDate = dt.Date
					WHERE
						da.Dim_UserID = u.ID AND YearMonthNum='+ CAST(@YearMonthNum AS varchar(20)) + ' AND WeekNum=' + CAST(@WeekNum AS varchar(20)) 
						+ CASE @AlertType 
							WHEN 'Activity time' THEN ' AND da.PurposeID <> -1 AND ac.ActivityCategoryName=''' + @AlertTypeValue + ''''
							WHEN 'Application time' THEN '  AND da.PurposeID <> -1 AND am.AppName=''' + @AlertTypeValue + ''''
							WHEN 'Total hours' THEN '  AND da.PurposeID <> -1 '
							WHEN 'Unaccounted hours' THEN ' AND da.PurposeID = -1 AND ac.ActivityCategoryID=0 '
						  END  + ' ) '

	END
	END

	if (@Debug = 1)
	begin

		print 'strSQL for Results => ' +  IsNull(@strSQL, ' Empty' )
	
	end
	
	EXEC (@strSQL)


END



GO
/****** Object:  StoredProcedure [edw].[sproc_NotificationResultsTestPK]    Script Date: 9/10/2021 8:10:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [edw].[sproc_NotificationResultsTestPK]
--PLEASE SEE PRODUCT BACKLOG ITEMS 19864 AND 18540
(
	@CompanyID INT, 
	@Entity VARCHAR(40),
	@EntityValue VARCHAR(200),
	@AlertType VARCHAR(40),
	@AlertTypeValue VARCHAR(100) = NULL,
	@EffectiveDate DATE,
	@IsAlertPerEmployee BIT,
	@AlertOperator VARCHAR(2),
	@PredictiveValue FLOAT,
	@Debug tinyint = 0
)
AS 
BEGIN
    SET NOCOUNT ON
	SET DATEFIRST 1

	DECLARE @YearMonthNum INT,
			@WeekNum INT,
			@strSQL NVARCHAR(MAX),
			@strSQL_UserCount NVARCHAR(MAX),
			@PredictiveValueInMinutes FLOAT,
			@UserCount INT,
			@ParmDef NVARCHAR(50),
			@ManagerDimUserID INT

	SET @PredictiveValueInMinutes = @PredictiveValue * 60

	SELECT @WeekNum=WeekNum, @YearMonthNum=YearMonthNum FROM edw.Dim_Date
    WHERE Date=DATEADD(WK,-1, @EffectiveDate)


	SELECT @ManagerDimUserID=ManagerDimUserID FROM edw.Dim_Department
	WHERE CompanyID=@CompanyID AND DepartmentName=@EntityValue

	
	--******************* GET USER COUNT ******************

	if (@AlertType <> 'Application')
	begin


				SET @strSQL_UserCount=

				'SELECT @retvalOUT=COUNT(1) FROM
					(SELECT u.ID
						FROM edw.Fact_DailyActivity da 
						JOIN edw.Dim_User u ON da.Dim_UserID = u.ID
						JOIN edw.Dim_Department d ON u.Dim_DepartmentID = d.ID
						JOIN edw.Dim_ActivityCategory ac ON da.Dim_ActivityCategoryID = ac.ID '

							+ CASE @AlertType 
								WHEN 'Application time' THEN ' JOIN edw.Dim_AppMaster am ON da.Dim_AppMasterID = am.ID '
								ELSE ''
							END
						 + '

						JOIN edw.Dim_Date dt ON da.ActivityDate = dt.Date
						WHERE da.Dim_CompanyID=' + CAST(@CompanyID AS varchar(5)) + ' AND u.IsActivityCollectionOn = 1 AND u.IsActive = 1 AND YearMonthNum='+ CAST(@YearMonthNum AS varchar(20)) + ' AND WeekNum=' + CAST(@WeekNum AS varchar(20)) 
							+ CASE @AlertType 
								WHEN 'Activity time' THEN ' AND da.PurposeID <> -1 AND ac.ActivityCategoryName=''' + @AlertTypeValue + ''''
								WHEN 'Application time' THEN '  AND da.PurposeID <> -1 AND am.AppName=''' + @AlertTypeValue + ''''
								WHEN 'Total hours' THEN '  AND da.PurposeID <> -1 '
								WHEN 'Unaccounted hours' THEN ' AND da.PurposeID = -1 AND ac.ActivityCategoryID=0 '
							  END
						 + ' AND d.DepartmentName=''' + @EntityValue + ''''
						 + CASE
							WHEN @ManagerDimUserID IS NOT NULL THEN ' AND u.ID <> ' + CAST(@ManagerDimUserID AS varchar(10))
						   END
						+ CHAR(10) +
						+ ' GROUP BY u.ID
					) base'


				
				if (@Debug = 1)
				begin

					print 'strSQL for UserCount => ' +  IsNull(@strSQL_UserCount, ' Empty' ) + CHAR(10)
				
				end
				

				--**** assign @UserCount ****
				SET @ParmDef = '@retvalOUT INT OUTPUT'
				EXEC sp_EXECUTESQL @strSQL_UserCount, @ParmDef, @retvalOUT= @UserCount OUTPUT


				if (@UserCount IS NULL OR @UserCount = 0)
					set @UserCount = 1

				--**************** MAIN OUTPUT ***************
				/**
				Note: TimeSpentInCalendarDay is divided by 5 since 5 working days in week. Also when @IsAlertPerEmployee=0 (by Dept), we want to multiply the # of users in Dept by 5.
				**/

				SET @strSQL=

				'SELECT ' 
				+ CASE @IsAlertPerEmployee 
					WHEN 1 THEN 'u.UserID PartyID, u.FirstName + '' '' + IsNull(u.LastName, '''' ) PartyName, '
					ELSE 'd.DepartmentID PartyID, d.DepartmentName PartyName, '
				  END
				+ CASE @IsAlertPerEmployee
					WHEN 1 THEN
						'CAST((SUM(TimeSpentInCalendarDay) / 5) / 60 AS decimal(18,2)) TimeSpent,
						CAST((SUM(TimeSpentInCalendarDay) / 5) / 60 AS decimal(18,2)) - ' + CAST(@PredictiveValue AS varchar(10)) + ' ThresholdDiff '
					ELSE
						'CAST((SUM(TimeSpentInCalendarDay) / (5*' + CAST(@UserCount AS varchar(10)) + ')) / 60 AS DECIMAL(18,2)) TimeSpent,
						CAST((SUM(TimeSpentInCalendarDay) / (5*' + CAST(@UserCount AS varchar(10)) + ')) / 60 AS DECIMAL(18,2)) - ' + CAST(@PredictiveValue AS varchar(10)) + ' ThresholdDiff '
				  END
				+
				'FROM edw.Fact_DailyActivity da 
				JOIN edw.Dim_User u ON da.Dim_UserID = u.ID  
				JOIN edw.Dim_Department d ON u.Dim_DepartmentID = d.ID
				JOIN edw.Dim_ActivityCategory ac ON da.Dim_ActivityCategoryID = ac.ID '
				
							+ CASE @AlertType 
								WHEN 'Application time' THEN ' JOIN edw.Dim_AppMaster am ON da.Dim_AppMasterID = am.ID '
								ELSE ''
							END
						 + '
				JOIN edw.Dim_Date dt ON da.ActivityDate = dt.Date
				WHERE da.Dim_CompanyID=' + CAST(@CompanyID AS varchar(5)) + '  AND u.IsActivityCollectionOn = 1 AND u.IsActive = 1 AND YearMonthNum='+ CAST(@YearMonthNum AS varchar(20)) + ' AND WeekNum=' + CAST(@WeekNum AS varchar(20)) 
				+ CASE @AlertType 
					WHEN 'Activity time' THEN ' AND da.PurposeID <> -1 AND ac.ActivityCategoryName=''' + @AlertTypeValue + ''''
					WHEN 'Application time' THEN '  AND da.PurposeID <> -1 AND am.AppName=''' + @AlertTypeValue + ''''
					WHEN 'Total hours' THEN '  AND da.PurposeID <> -1 '
					WHEN 'Unaccounted hours' THEN ' AND da.PurposeID = -1 AND ac.ActivityCategoryID=0 '
				  END
				+ ' AND d.DepartmentName=''' + @EntityValue + ''''
				+ CASE
					WHEN @ManagerDimUserID IS NOT NULL THEN ' AND u.ID <> ' + CAST(@ManagerDimUserID AS varchar(10))
				  END
				+ CHAR(10)
				+ CASE @IsAlertPerEmployee 
					WHEN 1 THEN 'GROUP BY u.UserID, u.FirstName + '' '' + IsNull(u.LastName, '''' )'
					ELSE ' GROUP BY d.DepartmentID, d.DepartmentName '
				  END
				+ CHAR(10)	
				+ CASE @IsAlertPerEmployee
					WHEN 1 THEN 'HAVING SUM(TimeSpentInCalendarDay) / 5 '  + @AlertOperator + CAST(@PredictiveValueInMinutes AS varchar(20))
					ELSE 'HAVING SUM(TimeSpentInCalendarDay) / (5*' + CAST(@UserCount AS varchar(10)) + ') ' + @AlertOperator + CAST(@PredictiveValueInMinutes AS varchar(20))
				  END

				  ---------------- UNION of no data users for <  -----------------
				+ CHAR(10)
					
				+ CASE charindex('<',@AlertOperator) WHEN 0 THEN ''
				  ELSE CASE WHEN @IsAlertPerEmployee = 0 THEN '' ELSE '
							UNION ALL 
						  
						  '
					+
						'	SELECT distinct  '
					+ 
						CASE @IsAlertPerEmployee 
							WHEN 1 THEN 'u.UserID PartyID, u.FirstName + '' '' + IsNull(u.LastName, '''' ) PartyName, '
							ELSE 'd.DepartmentID PartyID, d.DepartmentName PartyName, '
						END
					+	CASE @IsAlertPerEmployee
							WHEN 1 THEN
								'0 TimeSpent,
								 0 - ' + CAST(@PredictiveValue AS varchar(10)) + ' ThresholdDiff '
							ELSE
								'0 TimeSpent,
								 0 - ' + CAST(@PredictiveValue AS varchar(10)) + ' ThresholdDiff '
						END
					+
					'
					FROM edw.Dim_User u 
					JOIN edw.Dim_Department d ON u.Dim_DepartmentID = d.ID
				
					WHERE u.CompanyID=' + CAST(@CompanyID AS varchar(5)) + '  AND u.IsActivityCollectionOn = 1 AND u.IsActive = 1
					
						AND d.DepartmentName=''' + @EntityValue + ''''
					+ CASE
						WHEN @ManagerDimUserID IS NOT NULL THEN ' AND u.ID <> ' + CAST(@ManagerDimUserID AS varchar(10))
					  END
						+ CHAR(10) +
						' AND NOT EXISTS (
							SELECT 1 FROM edw.Fact_DailyActivity da 
								INNER JOIN edw.Dim_ActivityCategory ac ON da.Dim_ActivityCategoryID = ac.ID '
								
							+ CASE @AlertType 
								WHEN 'Application time' THEN ' JOIN edw.Dim_AppMaster am ON da.Dim_AppMasterID = am.ID '
								ELSE ''
							END
						 + '
								INNER JOIN edw.Dim_Date dt ON da.ActivityDate = dt.Date
								WHERE
									da.Dim_UserID = u.ID AND YearMonthNum='+ CAST(@YearMonthNum AS varchar(20)) + ' AND WeekNum=' + CAST(@WeekNum AS varchar(20)) 
									+ CASE @AlertType 
										WHEN 'Activity time' THEN ' AND da.PurposeID <> -1 AND ac.ActivityCategoryName=''' + @AlertTypeValue + ''''
										WHEN 'Application time' THEN '  AND da.PurposeID <> -1 AND am.AppName=''' + @AlertTypeValue + ''''
										WHEN 'Total hours' THEN '  AND da.PurposeID <> -1 '
										WHEN 'Unaccounted hours' THEN ' AND da.PurposeID = -1 AND ac.ActivityCategoryID=0 '
									  END  + ' ) '

				END
				END

				if (@Debug = 1)
				begin

					print 'strSQL for Results => ' +  IsNull(@strSQL, ' Empty' )
				
				end

		end
		else  -- if @AlertType ='Application'
		Begin

					---create table #Users (UserId int)
		
						SET @strSQL_UserCount= 
						
						' SELECT u.ID 
								FROM edw.Fact_DailyActivity da 
								JOIN edw.Dim_User u ON da.Dim_UserID = u.ID
								JOIN edw.Dim_Department d ON u.Dim_DepartmentID = d.ID
								JOIN edw.Dim_ActivityCategory ac ON da.Dim_ActivityCategoryID = ac.ID
								JOIN edw.Dim_AppMaster am ON da.Dim_AppMasterID = am.ID 
								JOIN edw.Dim_Date dt ON da.ActivityDate = dt.Date
								WHERE  da.Dim_CompanyID=' + CAST(@CompanyID AS varchar(5)) + ' AND u.IsActivityCollectionOn = 1 AND u.IsActive = 1 AND YearMonthNum='
								  + CAST(@YearMonthNum AS varchar(20)) + ' AND WeekNum=' + CAST(@WeekNum AS varchar(20)) 
								  + ' and am.AppName=''' + @AlertTypeValue + ''''
								  + ' AND d.DepartmentName=''' + @EntityValue + ''''
								  + CASE
									WHEN @ManagerDimUserID IS NOT NULL THEN ' AND u.ID <> ' + CAST(@ManagerDimUserID AS varchar(10))
								   END
								+ CHAR(10) +
								+ ' GROUP BY u.ID '


								Select @strSQL_UserCount

						EXEC sp_EXECUTESQL @strSQL_UserCount

						SET @strSQL_UserCount = 
						
						' SELECT u.ID 
								FROM edw.Fact_DailyActivity da 
								JOIN edw.Dim_User u ON da.Dim_UserID = u.ID
								JOIN edw.Dim_Department d ON u.Dim_DepartmentID = d.ID
								JOIN edw.Dim_ActivityCategory ac ON da.Dim_ActivityCategoryID = ac.ID
								JOIN edw.Dim_WebApp am ON da.Dim_WebAppID = am.ID 
								JOIN edw.Dim_Date dt ON da.ActivityDate = dt.Date
								WHERE  da.Dim_CompanyID=' + CAST(@CompanyID AS varchar(5)) + ' AND u.IsActivityCollectionOn = 1 AND u.IsActive = 1 AND 
								YearMonthNum='+ CAST(@YearMonthNum AS varchar(20)) + ' AND WeekNum=' + CAST(@WeekNum AS varchar(20)) 
								  + ' and am.WebAppName=''' + @AlertTypeValue + ''''
								  + ' AND d.DepartmentName=''' + @EntityValue + ''''
								  + CASE
									WHEN @ManagerDimUserID IS NOT NULL THEN ' AND u.ID <> ' + CAST(@ManagerDimUserID AS varchar(10))
								   END
								+ CHAR(10) +
								+ ' 
								GROUP BY u.ID '

								
								Select @strSQL_UserCount

						EXEC sp_EXECUTESQL @strSQL_UserCount

					---	'SELECT @retvalOUT=COUNT(1) FROM
					---		(
					---		    select userId from #Users
					---
					---		) base'

						Select @strSQL_UserCount
						
						
						---, @retvalOUT
			 END


---END



	
	EXEC (@strSQL)


END



GO
/****** Object:  StoredProcedure [edw].[sproc_Talend_TimeSlots_Update_EndTime]    Script Date: 9/10/2021 8:10:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  StoredProcedure [edw].[sproc_Talend_TimeSlots_Update_EndTime]    Script Date: 2020/07/24 20:21:11 ******/


CREATE    PROCEDURE [edw].[sproc_Talend_TimeSlots_Update_EndTime]
(    
    @Dim_CompanyID int,
	@Dim_UserID int,
	@StartTimeInUTC datetime,
	@EndTimeInUTC datetime,
	@EndTimeInUTC_original datetime,
	@IsActive bit,
	@TimeSpent real
)
AS
BEGIN
    SET NOCOUNT ON
	
	UPDATE ts
	SET EndTimeInUTC = @EndTimeInUTC,
		TimeSpent = @TimeSpent,
		IsActive = @IsActive
	FROM edw.Fact_TimeSlot ts
	WHERE Dim_CompanyID = @Dim_CompanyID
		AND Dim_UserID = @Dim_UserID
		AND StartTimeInUTC = @StartTimeInUTC
		AND EndTimeInUTC = @EndTimeInUTC_original


				UPDATE ts
	SET EndTimeInUTC = @EndTimeInUTC,
		TimeSpent = @TimeSpent,
		IsActive = @IsActive
	FROM edw.Stg_TimeSlot ts
	WHERE Dim_CompanyID = @Dim_CompanyID
		AND Dim_UserID = @Dim_UserID
		AND StartTimeInUTC = @StartTimeInUTC
		AND EndTimeInUTC = @EndTimeInUTC_original


END

GO
/****** Object:  StoredProcedure [edw].[sproc_TestFlyway]    Script Date: 9/10/2021 8:10:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      <Author, , Name>
-- Create Date: <Create Date, , >
-- Description: <Description, , >
-- =============================================
CREATE   PROCEDURE [edw].[sproc_TestFlyway]
    

AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON
	
	select top 10 * from [edw].TestFlyway

	set nocount off
END

GO
/****** Object:  StoredProcedure [edw].[sproc_UnaccountedDims]    Script Date: 9/10/2021 8:10:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [edw].[sproc_UnaccountedDims]

AS
BEGIN

    SET NOCOUNT ON

	DECLARE @LastCreatedRawTimeSlotProcessedID INT

	SELECT @LastCreatedRawTimeSlotProcessedID=LastCreatedRawTimeSlotProcessedID 
	FROM edw.Log_TimeSlotProcessStatus 
	WHERE TimeSlotType = 0


	--************************** INSERT NON-EXISTING USERS AND APPS *****************************
	-- Users
	INSERT INTO edw.Log_UnaccountedDims (CompanyID, Dimension, Value, DateCreated)
	SELECT a.* FROM
	(
	SELECT DISTINCT r.CompanyID, 'Dim_User' Dimension, r.data_activity_userId Value, GETUTCDATE() DateCreated
	FROM Staging.RawTimeSlot_App r
	LEFT JOIN edw.Dim_User u ON r.CompanyID = u.CompanyID AND r.data_activity_domain = u.DomainName AND r.data_activity_userId = u.DomainUserID
	WHERE r.CompanyID=1
		AND data_activity_activityType = 'Application'
		AND RawTimeSlot_AppID > @LastCreatedRawTimeSlotProcessedID
		AND u.ID IS NULL
	) a
	LEFT JOIN edw.Log_UnaccountedDims b ON a.CompanyID = b.CompanyID AND a.Dimension = b.Dimension AND a.Value = b.Value
	WHERE b.Value IS NULL


	-- Applications
	INSERT INTO edw.Log_UnaccountedDims (CompanyID, Dimension, Value, DateCreated)
	SELECT a.* FROM
	(
	SELECT DISTINCT r.CompanyID, 'Dim_AppParent' Dimension, r.data_exeName Value, GETUTCDATE() DateCreated
	FROM Staging.RawTimeSlot_App r
	LEFT JOIN EDW.Dim_AppParent ap ON r.CompanyID = ap.CompanyID AND r.data_exeName = ap.ExeName
	WHERE r.CompanyID=1
		AND data_activity_activityType = 'Application'
		AND RawTimeSlot_AppID > @LastCreatedRawTimeSlotProcessedID
		AND ap.ID IS NULL
	) a
	LEFT JOIN edw.Log_UnaccountedDims b ON a.CompanyID = b.CompanyID AND a.Dimension = b.Dimension AND a.Value = b.Value
	WHERE b.Value IS NULL



	--************************** REMOVE NOW EXISTING USERS AND APPS *****************************
	-- delete those records in Log_UnaccountedDims where users now exist in Dim_User
	DELETE a
	FROM edw.Log_UnaccountedDims a
	JOIN
	(
	SELECT ud.CompanyID, ud.Value, ud.Dimension FROM edw.Log_UnaccountedDims ud
	JOIN edw.Dim_User u ON ud.CompanyID = u.CompanyID AND ud.Value = u.DomainUserID
	WHERE Dimension = 'Dim_User'
	) b ON a.CompanyID = b.CompanyID AND a.Value = b.Value AND a.Dimension = b.Dimension


	-- delete those records in Log_UnaccountedDims where apps now exist in Dim_AppParent
	DELETE a
	FROM edw.Log_UnaccountedDims a
	JOIN
	(
	SELECT ud.CompanyID, ud.Value, ud.Dimension FROM edw.Log_UnaccountedDims ud
	JOIN edw.Dim_AppParent p ON ud.CompanyID = p.CompanyID AND ud.Value = p.ExeName
	WHERE Dimension = 'Dim_AppParent'
	) b ON a.CompanyID = b.CompanyID AND a.Value = b.Value AND a.Dimension = b.Dimension
	END


GO
/****** Object:  StoredProcedure [edw].[sproc_UpdateDimensions]    Script Date: 9/10/2021 8:10:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [edw].[sproc_UpdateDimensions]
AS 
BEGIN
    SET NOCOUNT ON

	-- Dim_Company
	INSERT INTO EDW.Dim_Company (LineofBusinessID, TenantID, CompanyName, DateCreated, DateDeleted)
	SELECT MD.CompanyID, md.TenantID, md.CompanyName, md.DateCreated, md.DateDeleted from md.Company md
	LEFT JOIN edw.Dim_Company edw ON md.CompanyID = edw.LineofBusinessID 
		AND md.TenantID = edw.TenantID
	WHERE edw.CompanyID IS NULL


	---- Dim_User
	--INSERT INTO edw.Dim_User (CompanyID, UserID, DomainUserID, DomainName, EmployeeCode, UserEmail, FirstName, MiddleName, LastName, DateCreated, DateDeleted, IsActive)
	--SELECT md.CompanyID, md.UserID, md.DomainUserID, md.DomainName, md.EmployeeCode, md.UserEmail, md.FirstName, md.MiddleName, md.LastName, GetUTCDate() DateCreated, NULL DateDeleted, md.IsActive
	--FROM 
	--	(SELECT ud.CompanyID, ud.UserID, ud.DomainUserID, ud.DomainName, u.EmployeeCode, UserEmail, FirstName, MiddleName, LastName, ud.IsActive 
	--	FROM md.Users u
	--	JOIN md.UserDomain ud ON u.UserID=ud.UserID AND u.CompanyID = ud.CompanyID
	--	) md 
	--LEFT JOIN edw.dim_User edw ON edw.CompanyID = md.CompanyID AND edw.UserID = md.UserID
	--WHERE edw.ID IS NULL


	----Dim_Department
	--INSERT INTO edw.Dim_Department (CompanyID, DepartmentID, DepartmentCode, DepartmentName, ParentDepartmentID, ManagerDimUserID, DateCreated, DateActivated, DateDeleted, IsActive)
	--SELECT md.CompanyID, md.DepartmentID, md.DepartmentCode, md.DepartmentName, CASE WHEN md.ParentDepartmentID=0 THEN NULL ELSE md.ParentDepartmentID END,
	--md.ManagerUserID, md.DateCreated, md.DateActivated, md.DateDeleted, md.IsActive
	--FROM md.Department md
	--LEFT JOIN edw.Dim_Department edw ON md.CompanyID = edw.CompanyID AND md.DepartmentID = edw.DepartmentID
	--WHERE edw.ID IS NULL


	---- Brdg_UserDepartmentHistory
	--DELETE FROM EDW.Brdg_UserDepartmentHistory

	--INSERT INTO edw.Brdg_UserDepartmentHistory (Dim_DepartmentID, Dim_UserID, StartDate, EndDate, IsManager, IsCurrent)
	--SELECT d.ID DimDeptID, u.ID DimUserID, StartDate, EndDate, IsManager, IsCurrent
	--FROM md.UserDepartmentHistory dh
	--JOIN edw.Dim_Department d ON dh.CompanyID = d.CompanyID AND dh.DepartmentID = d.DepartmentID
	--JOIN edw.Dim_User u ON dh.CompanyID = u.CompanyID AND dh.UserID = u.UserID



	----Dim_ActivityCategory
	--INSERT INTO edw.Dim_ActivityCategory (CompanyID, ActivityCategoryGroupID, ActivityCategoryID, ActivityCategoryTypeID, PlatformTypeID, ActivityCategoryGroupName, ActivityCategoryName, IsCore, IsSystemDefined, IsConfigurable, IsGlobal, DateCreated, DateDeleted, IsActive)
	--SELECT md.CompanyID, md.ActivityCategoryGroupID, md.ActivityCategoryID, md.ActivityCategoryTypeID, md.PlatformTypeID, md.ActivityCategoryGroupName, md.ActivityCategoryName, md.IsCore, md.IsSystemDefined, md.IsConfigurable, md.IsGlobal, md.DateCreated, md.DateDeleted, md.IsActive
	--FROM md.ActivityCategory md
	--LEFT JOIN edw.Dim_ActivityCategory edw ON md.CompanyID = edw.CompanyID AND md.ActivityCategoryGroupID = edw.ActivityCategoryGroupID AND md.ActivityCategoryID = edw.ActivityCategoryID
	--WHERE edw.ID IS NULL


	---- Dim_ActivityCategory
	--INSERT INTO edw.Dim_ActivityCategory (CompanyID, ActivityCategoryGroupID, ActivityCategoryID, ActivityCategoryTypeID, PlatformTypeID, ActivityCategoryGroupName, ActivityCategoryName, IsCore, IsSystemDefined, IsConfigurable, IsGlobal, DateCreated, DateDeleted, IsActive)
	--SELECT mad.CompanyID, mad.ActivityCategoryGroupID, mad.ActivityCategoryID, mad.ActivityCategoryTypeID, mad.PlatformTypeID, mad.ActivityCategoryGroupName, mad.ActivityCategoryName, mad.IsCore, mad.IsSystemDefined, mad.IsConfigurable, mad.IsGlobal, mad.DateCreated, mad.DateDeleted, mad.IsActive
	--FROM md.ActivityCategory mad
	--LEFT JOIN edw.Dim_ActivityCategory edw ON mad.CompanyID = edw.CompanyID AND mad.ActivityCategoryGroupID = edw.ActivityCategoryGroupID AND mad.ActivityCategoryID = edw.ActivityCategoryID
	--WHERE edw.ID IS NULL


	----Brdg_AppActivityCategory
	--DELETE FROM edw.Brdg_AppActivityCategory

	--INSERT INTO edw.Brdg_AppActivityCategory (Dim_ActivityCategoryID, Dim_AppParentID, DefaultPurpose, CanOverride, UrlMatching, DateCreated, DateDeleted, IsActive)
	--SELECT MIN(CatID) CatID, appID, MIN(DefaultPurpose), CAST(MIN(CAST(CanOverride as tinyint)) as bit) CanOverride, CAST(MIN(CAST(URlMatching as tinyint)) as bit) URLMatching, MIN(DateCreated) DateCreated, MIN(DateDeleted) DAteDeleted, CAST(MIN(CAST(IsActive as tinyint)) as bit) IsActive
	--FROM
	--(
	--	SELECT ac.ID CatID, app.ID appID, DefaultPurpose, CanOverride, map.UrlMatching, map.DateCreated, map.DateDeleted, map.IsActive
	--	FROM md.AppActivityCategoryMap map
	--	JOIN edw.Dim_ActivityCategory ac ON map.CompanyID = ac.CompanyID AND map.ActivityCategoryGroupID = ac.ActivityCategoryGroupID AND map.ActivityCategoryID = ac.ActivityCategoryID
	--	JOIN edw.Dim_AppParent app ON map.AppName = app.ExeName
	--	WHERE right(map.AppName,4) = '.EXE'
	--	UNION
	--	SELECT ac.ID CatID, app.ID appID, DefaultPurpose, CanOverride, map.UrlMatching, map.DateCreated, map.DateDeleted, map.IsActive
	--	FROM md.AppActivityCategoryMap map
	--	JOIN edw.Dim_ActivityCategory ac ON map.CompanyID = ac.CompanyID AND map.ActivityCategoryGroupID = ac.ActivityCategoryGroupID AND map.ActivityCategoryID = ac.ActivityCategoryID
	--	JOIN edw.Dim_AppParent app ON map.AppName = app.AppName
	--		--OR CHARINDEX(map.AppName,app.AppName) > 0 
	--		--OR CHARINDEX(app.AppName, map.AppName) > 0
	--		--OR CHARINDEX(map.AppName, app.ExeName) > 0
	--	WHERE right(map.AppName,4) <> '.EXE' AND app.WebApp IS NULL
	--) base
	--GROUP BY appID


	--INSERT INTO edw.Brdg_AppActivityCategory (Dim_ActivityCategoryID, Dim_AppParentID, DefaultPurpose, CanOverride, UrlMatching, DateCreated, DateDeleted, IsActive, WebApp)
	--SELECT ac.ID CatID, app.ID appID, DefaultPurpose, CanOverride, map.UrlMatching, map.DateCreated, map.DateDeleted, map.IsActive, map.WebApp 
	--FROM md.AppActivityCategoryMap map
	--JOIN edw.Dim_ActivityCategory ac ON map.CompanyID = ac.CompanyID AND map.ActivityCategoryGroupID = ac.ActivityCategoryGroupID AND map.ActivityCategoryID = ac.ActivityCategoryID
	--JOIN edw.Dim_AppParent app ON map.WebApp = app.WebApp
	--WHERE map.WebApp<>''

	---- For testing purposes, adding Salesforce as webapp since a lot of salesforce data
	--IF @@SERVERNAME='sapience-lab-us-dev'
	--INSERT INTO edw.Brdg_AppActivityCategory (Dim_ActivityCategoryID, Dim_AppParentID, DefaultPurpose, CanOverride, UrlMatching, DateCreated, DateDeleted, IsActive, WebApp)
	--VALUES (2, 112, 1, 1, 1, '2019-07-08 19:01:00', null, 1, 'salesforce')


END

GO
/****** Object:  StoredProcedure [edw].[Test_sproc_NotificationResultsProdHotFix]    Script Date: 9/10/2021 8:10:28 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE     PROCEDURE [edw].[Test_sproc_NotificationResultsProdHotFix]
--PLEASE SEE PRODUCT BACKLOG ITEMS 19864 AND 18540
(
	@CompanyID INT, 
	@Entity VARCHAR(40),
	@EntityValue VARCHAR(200),
	@AlertType VARCHAR(40),
	@AlertTypeValue VARCHAR(100) = NULL,
	@EffectiveDate DATE,
	@IsAlertPerEmployee BIT,
	@AlertOperator VARCHAR(2),
	@PredictiveValue FLOAT,
	@Debug tinyint = 0
)
AS 
BEGIN
    SET NOCOUNT ON
	SET DATEFIRST 1

	DECLARE @YearMonthNum INT,
			@WeekNum INT,
			@strSQL NVARCHAR(MAX),
			@strSQL_UserCount NVARCHAR(MAX),
			@PredictiveValueInMinutes FLOAT,
			@UserCount INT,
			@ParmDef NVARCHAR(50),
			@ManagerDimUserID INT

	SET @PredictiveValueInMinutes = @PredictiveValue * 60

	SELECT @WeekNum=WeekNum, @YearMonthNum=YearMonthNum FROM edw.Dim_Date
    WHERE Date=DATEADD(WK,-1, @EffectiveDate)


	SELECT @ManagerDimUserID=ManagerDimUserID FROM edw.Dim_Department
	WHERE CompanyID=@CompanyID AND DepartmentName=@EntityValue

	
	--******************* GET USER COUNT ******************

	SET @strSQL_UserCount=

	'SELECT @retvalOUT=COUNT(1) FROM
		(SELECT u.ID
			FROM edw.Fact_DailyActivity da 
			JOIN edw.Dim_User u ON da.Dim_UserID = u.ID
			JOIN edw.Dim_Department d ON u.Dim_DepartmentID = d.ID
			JOIN edw.Dim_ActivityCategory ac ON da.Dim_ActivityCategoryID = ac.ID
			JOIN edw.Dim_AppMaster am ON da.Dim_AppMasterID = am.ID
			JOIN edw.Dim_Date dt ON da.ActivityDate = dt.Date
			WHERE da.Dim_CompanyID=' + CAST(@CompanyID AS varchar(5)) + ' AND u.IsActivityCollectionOn = 1 AND u.IsActive = 1 AND YearMonthNum='+ CAST(@YearMonthNum AS varchar(20)) + ' AND WeekNum=' + CAST(@WeekNum AS varchar(20)) 
				+ CASE @AlertType 
					WHEN 'Activity Category' THEN ' AND ac.ActivityCategoryName=''' + @AlertTypeValue + ''''
					WHEN 'Application' THEN ' AND am.AppName=''' + @AlertTypeValue + ''''
					WHEN 'TotalHours' THEN ''
					WHEN 'UnaccountedTime' THEN ' AND ac.ActivityCategoryID=0 AND da.PurposeID=-1'
				  END
			 + ' AND d.DepartmentName=''' + @EntityValue + ''''
			 + CASE
				WHEN @ManagerDimUserID IS NOT NULL THEN ' AND u.ID <> ' + CAST(@ManagerDimUserID AS varchar(10))
			   END
			+ CHAR(10) +
			+ ' GROUP BY u.ID
		) base'


	
	if (@Debug = 1)
	begin

		print 'strSQL for UserCount => ' +  IsNull(@strSQL_UserCount, ' Empty' ) + CHAR(10)
	
	end
	

	--**** assign @UserCount ****
	SET @ParmDef = '@retvalOUT INT OUTPUT'
	EXEC sp_EXECUTESQL @strSQL_UserCount, @ParmDef, @retvalOUT= @UserCount OUTPUT


	if (@UserCount IS NULL OR @UserCount = 0)
		set @UserCount = 1

	--**************** MAIN OUTPUT ***************
	/**
	Note: TimeSpentInCalendarDay is divided by 5 since 5 working days in week. Also when @IsAlertPerEmployee=0 (by Dept), we want to multiply the # of users in Dept by 5.
	**/

	SET @strSQL=

	'SELECT ' 
	+ CASE @IsAlertPerEmployee 
		WHEN 1 THEN 'u.UserID PartyID, u.FirstName + '' '' + IsNull(u.LastName, '''' ) PartyName, '
		ELSE 'd.DepartmentID PartyID, d.DepartmentName PartyName, '
	  END
	+ CASE @IsAlertPerEmployee
		WHEN 1 THEN
			'CAST((SUM(TimeSpentInCalendarDay) / 5) / 60 AS decimal(18,2)) TimeSpent,
			CAST((SUM(TimeSpentInCalendarDay) / 5) / 60 AS decimal(18,2)) - ' + CAST(@PredictiveValue AS varchar(10)) + ' ThresholdDiff '
		ELSE
			'CAST((SUM(TimeSpentInCalendarDay) / (5*' + CAST(@UserCount AS varchar(10)) + ')) / 60 AS DECIMAL(18,2)) TimeSpent,
			CAST((SUM(TimeSpentInCalendarDay) / (5*' + CAST(@UserCount AS varchar(10)) + ')) / 60 AS DECIMAL(18,2)) - ' + CAST(@PredictiveValue AS varchar(10)) + ' ThresholdDiff '
	  END
	+
	'FROM edw.Fact_DailyActivity da 
	JOIN edw.Dim_User u ON da.Dim_UserID = u.ID  
	JOIN edw.Dim_Department d ON u.Dim_DepartmentID = d.ID
	JOIN edw.Dim_ActivityCategory ac ON da.Dim_ActivityCategoryID = ac.ID
	JOIN edw.Dim_AppMaster am ON da.Dim_AppMasterID = am.ID
	JOIN edw.Dim_Date dt ON da.ActivityDate = dt.Date
	WHERE da.Dim_CompanyID=' + CAST(@CompanyID AS varchar(5)) + '  AND u.IsActivityCollectionOn = 1 AND u.IsActive = 1 AND YearMonthNum='+ CAST(@YearMonthNum AS varchar(20)) + ' AND WeekNum=' + CAST(@WeekNum AS varchar(20)) 
	+ CASE @AlertType 
		WHEN 'Activity Category' THEN ' AND ac.ActivityCategoryName=''' + @AlertTypeValue + ''''
		WHEN 'Application' THEN ' AND am.AppName=''' + @AlertTypeValue + ''''
		WHEN 'TotalHours' THEN ''
		WHEN 'UnaccountedTime' THEN ' AND ac.ActivityCategoryID=0 AND da.PurposeID=-1'
	  END
	+ ' AND d.DepartmentName=''' + @EntityValue + ''''
	+ CASE
		WHEN @ManagerDimUserID IS NOT NULL THEN ' AND u.ID <> ' + CAST(@ManagerDimUserID AS varchar(10))
	  END
	+ CHAR(10)
	+ CASE @IsAlertPerEmployee 
		WHEN 1 THEN 'GROUP BY u.UserID, u.FirstName + '' '' + IsNull(u.LastName, '''' )'
		ELSE ' GROUP BY d.DepartmentID, d.DepartmentName '
	  END
	+ CHAR(10)	
	+ CASE @IsAlertPerEmployee
		WHEN 1 THEN 'HAVING SUM(TimeSpentInCalendarDay) / 5 '  + @AlertOperator + CAST(@PredictiveValueInMinutes AS varchar(20))
		ELSE 'HAVING SUM(TimeSpentInCalendarDay) / (5*' + CAST(@UserCount AS varchar(10)) + ') ' + @AlertOperator + CAST(@PredictiveValueInMinutes AS varchar(20))
	  END

	  ---------------- UNION of no data users for <  -----------------
	+ CHAR(10)
		
	+ CASE charindex('<',@AlertOperator) WHEN 0 THEN ''
	  ELSE CASE WHEN @IsAlertPerEmployee = 0 THEN '' ELSE '
				UNION ALL 
			  
			  '
		+
			'	SELECT distinct  '
		+ 
			CASE @IsAlertPerEmployee 
				WHEN 1 THEN 'u.UserID PartyID, u.FirstName + '' '' + IsNull(u.LastName, '''' ) PartyName, '
				ELSE 'd.DepartmentID PartyID, d.DepartmentName PartyName, '
			END
		+	CASE @IsAlertPerEmployee
				WHEN 1 THEN
					'0 TimeSpent,
					 0 - ' + CAST(@PredictiveValue AS varchar(10)) + ' ThresholdDiff '
				ELSE
					'0 TimeSpent,
					 0 - ' + CAST(@PredictiveValue AS varchar(10)) + ' ThresholdDiff '
			END
		+
		'
		FROM edw.Dim_User u 
		JOIN edw.Dim_Department d ON u.Dim_DepartmentID = d.ID
	
		WHERE u.CompanyID=' + CAST(@CompanyID AS varchar(5)) + '  AND u.IsActivityCollectionOn = 1 AND u.IsActive = 1
		
			AND d.DepartmentName=''' + @EntityValue + ''''
		+ CASE
			WHEN @ManagerDimUserID IS NOT NULL THEN ' AND u.ID <> ' + CAST(@ManagerDimUserID AS varchar(10))
		  END
			+ CHAR(10) +
			' AND NOT EXISTS (
				SELECT 1 FROM edw.Fact_DailyActivity da 
					INNER JOIN edw.Dim_ActivityCategory ac ON da.Dim_ActivityCategoryID = ac.ID
					INNER JOIN edw.Dim_AppMaster am ON da.Dim_AppMasterID = am.ID
					INNER JOIN edw.Dim_Date dt ON da.ActivityDate = dt.Date
					WHERE
						da.Dim_UserID = u.ID AND YearMonthNum='+ CAST(@YearMonthNum AS varchar(20)) + ' AND WeekNum=' + CAST(@WeekNum AS varchar(20)) 
						+ CASE @AlertType 
							WHEN 'Activity Category' THEN ' AND ac.ActivityCategoryName=''' + @AlertTypeValue + ''''
							WHEN 'Application' THEN ' AND am.AppName=''' + @AlertTypeValue + ''''
							WHEN 'TotalHours' THEN ''
							WHEN 'UnaccountedTime' THEN ' AND ac.ActivityCategoryID=0 AND da.PurposeID=-1'
						  END  + ' ) '

	END
	END

	if (@Debug = 1)
	begin

		print 'strSQL for Results => ' +  IsNull(@strSQL, ' Empty' )
	
	end
	
	EXEC (@strSQL)


END


GO
EXEC sys.sp_addextendedproperty @name=N'microsoft_database_tools_support', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sysdiagrams'
GO
EXEC sys.sp_addextendedproperty @name=N'Pro2', @value=N'Test2' , @level0type=N'SCHEMA',@level0name=N'edw', @level1type=N'TABLE',@level1name=N'Stg_Lenses_Dup'
GO
EXEC sys.sp_addextendedproperty @name=N'Prop1', @value=N'Test1' , @level0type=N'SCHEMA',@level0name=N'edw', @level1type=N'TABLE',@level1name=N'Stg_Lenses_Dup'
GO
