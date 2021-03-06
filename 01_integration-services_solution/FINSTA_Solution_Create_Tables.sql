USE [FinstaSolution]
GO
DROP PROCEDURE [dwh].[sprPopulateDimTime]
GO
ALTER TABLE [dwh].[FactSaldo] DROP CONSTRAINT [FK_FactSaldo_DimTime]
GO
ALTER TABLE [dwh].[FactSaldo] DROP CONSTRAINT [FK_FactSaldo_DimKonto]
GO
ALTER TABLE [dwh].[FactSaldo] DROP CONSTRAINT [FK_FactSaldo_DimGemeinde]
GO
ALTER TABLE [dwh].[FactSaldo] DROP CONSTRAINT [FK_FactSaldo_DimAufgabenstelle]
GO
ALTER TABLE [dwh].[DimGemeinde] DROP CONSTRAINT [FK_DimGemeinde_DimBFSTyp]
GO
ALTER TABLE [dwh].[DimGemeinde] DROP CONSTRAINT [FK_DimGemeinde_DimBezirk]
GO

ALTER TABLE [dwh].[DimBFSTyp] DROP CONSTRAINT [FK_DimBFSTyp_DimBFSHaupttyp]
GO

DROP TABLE [staging].[Gemeindetypologie]
GO
DROP TABLE [dwh].[FactSaldo]
GO
DROP TABLE [dwh].[DimTime]
GO
DROP TABLE [dwh].[DimKonto]
GO
DROP TABLE [dwh].[DimGemeinde]
GO
DROP TABLE [dwh].[DimBFSTyp]
GO
DROP TABLE [dwh].[DimBFSHaupttyp]
GO
DROP TABLE [dwh].[DimBezirk]
GO
DROP TABLE [dwh].[DimAufgabenstelle]
GO

CREATE TABLE [staging].[Gemeindetypologie](
	[BFS Nummer] [int] NULL,
	[BFS Typ] [int] NULL,
	[BFS Haupttyp] [int] NULL,
	[Gemeinde] [nvarchar](100) NULL,
) 
GO

CREATE TABLE [dwh].[DimAufgabenstelle](
	[AufgabenstelleKey] [int] IDENTITY(1,1) NOT NULL,
	[Aufgabenstelle Nummer] [int] NULL,
	[Aufgabenstelle Name] [nvarchar](512) NULL,
	[Aufgabe Nummer] [int] NULL,
	[Aufgabe Name] [nvarchar](512) NULL,
	[Aufgabenbereich Nummer] [int] NULL,
	[Aufgabenbereich Name] [nvarchar](512) NULL,
 CONSTRAINT [PK_DimAufgabenstelle] PRIMARY KEY CLUSTERED 
(
	[AufgabenstelleKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dwh].[DimBezirk](
	[BezirkKey] [int] IDENTITY(1,1) NOT NULL,
	[Bezirk Nummer] [int] NULL,
	[Bezirk Name] [nvarchar](50) NULL,
 CONSTRAINT [PK_DimBezirk] PRIMARY KEY CLUSTERED 
(
	[BezirkKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dwh].[DimBFSHaupttyp](
	[BFSHaupttypKey] [int] IDENTITY(1,1) NOT NULL,
	[BFS Haupttyp Nummer] [int] NULL,
	[BFS Haupttyp Name] [nvarchar](50) NULL,
 CONSTRAINT [PK_DimBFSHaupttyp] PRIMARY KEY CLUSTERED 
(
	[BFSHaupttypKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dwh].[DimBFSTyp](
	[BFSTypKey] [int] IDENTITY(1,1) NOT NULL,
	[BFS Typ Nummer] [int] NULL,
	[BFS Typ Name] [nvarchar](100) NULL,
	[BFSHaupttypKey] [int] NULL,
 CONSTRAINT [PK_DimBFSTyp] PRIMARY KEY CLUSTERED 
(
	[BFSTypKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dwh].[DimGemeinde](
	[GemeindeKey] [int] IDENTITY(1,1) NOT NULL,
	[BFS-Nr ] [int] NULL,
	[Gemeinde] [nvarchar](50) NULL,
	[BezirkKey] [int] NULL,
	[BFSTypKey] [int] NULL
 CONSTRAINT [Gemeindekey] PRIMARY KEY CLUSTERED 
(
	[GemeindeKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dwh].[DimKonto](
	[KontoKey] [int] IDENTITY(1,1) NOT NULL,
	[Kontenklasse Nummer] [int] NULL,
	[Kontengruppe Nummer] [int] NULL,
	[Konto Nummer] [int] NULL,
	[Kontenklasse Name] [nvarchar](512) NULL,
	[Kontengruppe Name] [nvarchar](512) NULL,
	[Konto Name] [nvarchar](512) NULL,
	[Subkonto Name] [nvarchar](512) NULL,
	[Konto Laufnummer] [int] NULL,
	[Kontenbereich Nummer] [int] NULL,
	[Kontenbereich Name] [nvarchar](512) NULL,
 CONSTRAINT [PK_DimKonto] PRIMARY KEY CLUSTERED 
(
	[KontoKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dwh].[DimTime](
	[TimeKey] [int] NOT NULL,
	[Date] [datetime] NOT NULL,
	[Date_Name] [nvarchar](50) NULL,
	[Year] [datetime] NULL,
	[Year_Name] [nvarchar](50) NULL,
 CONSTRAINT [PK_DimZeit] PRIMARY KEY CLUSTERED 
(
	[TimeKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dwh].[FactSaldo](
	[SaldoKey] [int] IDENTITY(1,1) NOT NULL,
	[AufgabenstelleKey] [int] NULL,
	[KontoKey] [int] NOT NULL,
	[GemeindeKey] [int] NOT NULL,
	[TimeKey] [int] NOT NULL,
	[Saldo] [decimal](18, 2) NULL,
 CONSTRAINT [PK_FactSaldo] PRIMARY KEY CLUSTERED 
(
	[SaldoKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dwh].[DimBFSTyp]  WITH CHECK ADD  CONSTRAINT [FK_DimBFSTyp_DimBFSHaupttyp] FOREIGN KEY([BFSHaupttypKey])
REFERENCES [dwh].[DimBFSHaupttyp] ([BFSHaupttypKey])
GO
ALTER TABLE [dwh].[DimBFSTyp] CHECK CONSTRAINT [FK_DimBFSTyp_DimBFSHaupttyp]
GO

ALTER TABLE [dwh].[DimGemeinde]  WITH CHECK ADD  CONSTRAINT [FK_DimGemeinde_DimBezirk] FOREIGN KEY([BezirkKey])
REFERENCES [dwh].[DimBezirk] ([BezirkKey])
GO
ALTER TABLE [dwh].[DimGemeinde] CHECK CONSTRAINT [FK_DimGemeinde_DimBezirk]
GO
ALTER TABLE [dwh].[DimGemeinde]  WITH CHECK ADD  CONSTRAINT [FK_DimGemeinde_DimBFSTyp] FOREIGN KEY([BFSTypKey])
REFERENCES [dwh].[DimBFSTyp] ([BFSTypKey])
GO
ALTER TABLE [dwh].[DimGemeinde] CHECK CONSTRAINT [FK_DimGemeinde_DimBFSTyp]
GO

ALTER TABLE [dwh].[FactSaldo]  WITH CHECK ADD  CONSTRAINT [FK_FactSaldo_DimAufgabenstelle] FOREIGN KEY([AufgabenstelleKey])
REFERENCES [dwh].[DimAufgabenstelle] ([AufgabenstelleKey])
GO
ALTER TABLE [dwh].[FactSaldo] CHECK CONSTRAINT [FK_FactSaldo_DimAufgabenstelle]
GO
ALTER TABLE [dwh].[FactSaldo]  WITH CHECK ADD  CONSTRAINT [FK_FactSaldo_DimGemeinde] FOREIGN KEY([GemeindeKey])
REFERENCES [dwh].[DimGemeinde] ([GemeindeKey])
GO
ALTER TABLE [dwh].[FactSaldo] CHECK CONSTRAINT [FK_FactSaldo_DimGemeinde]
GO
ALTER TABLE [dwh].[FactSaldo]  WITH CHECK ADD  CONSTRAINT [FK_FactSaldo_DimKonto] FOREIGN KEY([KontoKey])
REFERENCES [dwh].[DimKonto] ([KontoKey])
GO
ALTER TABLE [dwh].[FactSaldo] CHECK CONSTRAINT [FK_FactSaldo_DimKonto]
GO
ALTER TABLE [dwh].[FactSaldo]  WITH CHECK ADD  CONSTRAINT [FK_FactSaldo_DimTime] FOREIGN KEY([TimeKey])
REFERENCES [dwh].[DimTime] ([TimeKey])
GO
ALTER TABLE [dwh].[FactSaldo] CHECK CONSTRAINT [FK_FactSaldo_DimTime]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/***********************************************************************************
**	$Revision: 0 $	
**  Generiert den Inhalt der Tabelle dwh.DimTime.
**
**  Parameter : 
** 
** 	Aufruf :
** 		EXECUTE sprPopulateDimTime @Start='01.01.2010', @End='31.12.2010'
**
************************************************************************************/
CREATE PROCEDURE [dwh].[sprPopulateDimTime] 
	@Start date = '01.01.2006', 
	@End date = '31.12.2015'
AS
	SET DATEFIRST 1
	SET LANGUAGE German

	DECLARE 
		@startDate DATE
		,@endDatum DATE
		,@currentDate DATE
		,@dayCounter INT 

	SELECT 
		@startDate =@Start 
		,@endDatum = @End
		,@dayCounter = 0 

    DELETE FROM dwh.DimTime

	SELECT @currentDate = Dateadd(dd,@dayCounter,@startDate)

	WHILE @currentDate <= @endDatum
	BEGIN
	SELECT @currentDate = Dateadd(dd,@dayCounter,@startDate)
	INSERT INTO dwh.DimTime
	           ([TimeKey],
				[Date],
				[Date_Name],
				[Year],
				[Year_Name])
			SELECT
			   CONVERT(NVARCHAR(10), @currentDate, 112) AS [TimeKey],
			   @currentDate AS [Date],
			   CONVERT(NVARCHAR(10), @currentDate, 104) AS [Date_Name],
			   DATEADD(YEAR,DATEDIFF(YEAR,0,@currentDate)+1,0)-1 AS [Year],
			   DATENAME(YEAR, @currentDate) AS [Year_Name]
	SET @dayCounter = @dayCounter + 1 
	END 


GO
