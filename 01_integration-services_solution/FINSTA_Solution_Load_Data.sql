USE [FinstaSolution]
GO

DELETE FROM [staging].[Gemeindetypologie]
DELETE FROM [dwh].[FactSaldo]
DELETE FROM [dwh].[DimTime]
DELETE FROM [dwh].[DimKonto]
DELETE FROM [dwh].[DimGemeinde]
DELETE FROM [dwh].[DimBFSTyp]
DELETE FROM [dwh].[DimBFSHaupttyp]
DELETE FROM [dwh].[DimBezirk]
DELETE FROM [dwh].[DimAufgabenstelle]
GO

DECLARE @Start date
DECLARE @End date

SELECT @Start='2000.01.01'
SELECT @End='2015.12.31'

EXECUTE [dwh].[sprPopulateDimTime] 
   @Start
  ,@End
GO

INSERT INTO [dwh].[DimKonto]
           ([Kontenklasse Nummer]
           ,[Kontengruppe Nummer]
           ,[Konto Nummer]
           ,[Kontenklasse Name]
           ,[Kontengruppe Name]
           ,[Konto Name]
           ,[Subkonto Name]
           ,[Konto Laufnummer]
           ,[Kontenbereich Nummer]
           ,[Kontenbereich Name])
SELECT distinct 
    [kontenklasse] AS [Kontenklasse Nummer]
   ,[kontengruppe] AS [Kontengruppe Nummer]
   ,[sammelkonto] AS [Konto Nummer]
   ,'['+cast([kontenklasse] as nvarchar(4))+'] '+[kontenklassen_bez] AS [Kontenklasse Name]
   ,'['+cast([kontengruppe] as nvarchar(4))+'] '+ [kontengruppen_bez] AS [Kontengruppe Name]
   ,'['+cast([sammelkonto] as nvarchar(4))+'] '+COALESCE([sammelkonten_bez],'…') AS [Konto Name]
   ,(case when subaccount is not null then ('['+cast([sammelkonto] as nvarchar(4))+'.'+CAST(subaccount AS nvarchar(5))+'] '+COALESCE([sammelkonten_bez],'…')) else ('['+cast([sammelkonto] as nvarchar(4))+'] '+COALESCE([sammelkonten_bez],'…')) end) as [Sunbonto Name] 
   ,[Subaccount] AS [Konto Laufnummer]
   ,(case when rechnungsart='B' then Cast(Kontenklasse/10 as int) else (case when kontenklasse>10 then kontenklasse/100 else kontenklasse end) end) AS [Kontenbereich Nummer]
   ,cast((case when rechnungsart='B' then (case when Kontenklasse/10=1 then '[1] Aktiven' else '[2] Passiven' end) else (case when kontenklasse<10 then (case when kontenklasse=3 then '[3] Aufwand' when kontenklasse=4 then '[4] Ertrag' when kontenklasse=5 then '[5] Ausgaben' else '[6] Einnahmen' end) else (case when kontenklasse/100=3 then '[3] Aufwand' when kontenklasse/100=4 then '[4] Ertrag' when kontenklasse/100=5 then '[5] Ausgaben' else '[6] Einnahmen' end) end) end)as nvarchar(512)) AS [Kontenbereich Name]
  FROM [FinstaData].[staging].[FINSTA]
  WHERE kontenklasse is not null
GO

INSERT INTO [dwh].[DimAufgabenstelle]
           ([Aufgabenbereich Nummer]
		   ,[Aufgabe Nummer]
		   ,[Aufgabenstelle Nummer]
		   ,[Aufgabenbereich Name]
           ,[Aufgabe Name]
		   ,[Aufgabenstelle Name])
SELECT DISTINCT 
    aufgabenbereich AS [Aufgabenbereich Nummer]
	,aufgabe AS [Aufgabe Nummer]
	,aufwand_ertrag_stelle AS [Aufgabenstelle Nummer] 
    ,'[' + CAST(aufgabenbereich AS nvarchar(2)) + '] ' + aufgabenbereich_bez AS [Aufgabenbereich Name]
	,(CASE WHEN aufgabe < 10 THEN '[0' + CAST(Aufgabe AS nvarchar(2)) + '] n' + [aufgaben_bez] ELSE '[' + CAST(Aufgabe AS nvarchar(2)) + '] ' + [aufgaben_bez] END) AS [Aufgabe Name]
	,(CASE WHEN aufwand_ertrag_stelle < 100 THEN '[0' + CAST(aufwand_ertrag_stelle AS nvarchar(3)) + '] ' + [aufwand_ertrag_stellen_bez] ELSE '[' + CAST(aufwand_ertrag_stelle AS nvarchar(3)) + '] ' + [aufwand_ertrag_stellen_bez] END) AS [Aufgabenstelle Name]
FROM [FinstaData].[staging].[FINSTA]
WHERE (aufwand_ertrag_stelle IS NOT NULL)
GO

INSERT INTO [dwh].[DimBezirk]
           ([Bezirk Nummer]
           ,[Bezirk Name])
SELECT [Bezirksnummer]
      --,[Bezirksname]
      ,[BezirksnameKurz]
  FROM [FinstaData].[staging].[DimBezirk]
  WHERE [HistorisierteNummerBezirk] IN
    (SELECT DISTINCT [HistorisierteNummerBezirk]
      FROM [FinstaData].[staging].[DimGemeinde]
      WHERE BFSGemeindenummer IN (SELECT [BFS-Nr ] FROM [dwh].[DimGemeinde])
      AND DatumDerAufnahme >= '2010-01-01')
GO

INSERT INTO [dwh].[DimGemeinde]
           ([BFS-Nr ]
           ,[Gemeinde])
SELECT 
    Gemeinden.[BFS-Nr ]
	,g.Gemeinde
FROM
  (SELECT DISTINCT [gemeinde]
    FROM [FinstaData].[staging].[FINSTA]) AS g
  LEFT JOIN [FinstaData].[staging].[Gemeinden] ON g.gemeinde=Gemeinden.[Gemeinde]
GO

UPDATE [dwh].[DimGemeinde]
SET
[BezirkKey] = (SELECT [BezirkKey] 
                 FROM [dwh].[DimBezirk] 
                 WHERE [Bezirk Nummer] = (SELECT [Bezirksnummer] 
				                            FROM [FinstaData].[staging].[DimBezirk] 
											WHERE [HistorisierteNummerBezirk] = (SELECT TOP 1 [HistorisierteNummerBezirk]
                                                                                   FROM [FinstaData].[staging].[DimGemeinde] 
																				   WHERE BFSGemeindenummer = [BFS-Nr ] AND DatumDerAufnahme >= '2010-01-01'
																				)
										 )
              )
GO

--UPDATE [dwh].[DimGemeinde]
--SET
--[BFSTypKey] = COALESCE(
--                (SELECT [BFSTypKey] 
--				   FROM [dwh].[DimBFSTyp] 
--				   WHERE [BFS Typ Nummer]=(SELECT [BFS Typ] 
--				                             FROM [staging].[Gemeindetypologie] 
--											 WHERE [Gemeindetypologie].[BFS Nummer] = [DimGemeinde].[BFS-Nr ])),
--	            (SELECT [BFSTypKey] FROM [dwh].[DimBFSTyp] WHERE [BFS Typ Nummer]=0)
--			  )
--GO

INSERT INTO [dwh].[FactSaldo]
           ([TimeKey]
		   ,[AufgabenstelleKey]
           ,[KontoKey]
           ,[GemeindeKey]
           ,[Saldo])
SELECT
       [jahr]*10000+1231 AS TimeKey
	   ,CASE WHEN rechnungsart<>'B' THEN (SELECT [AufgabenstelleKey] FROM [dwh].[DimAufgabenstelle] WHERE [FINSTA].aufgabenbereich = [DimAufgabenstelle].[Aufgabenbereich Nummer] AND [FINSTA].aufgabe = [DimAufgabenstelle].[Aufgabe Nummer] AND [FINSTA].aufwand_ertrag_stelle = [DimAufgabenstelle].[Aufgabenstelle Nummer])  ELSE NULL END AS AufgabenstelleKey
       ,(SELECT KontoKey FROM [dwh].[DimKonto] WHERE [FINSTA].[kontenklasse] = [DimKonto].[Kontenklasse Nummer] AND [FINSTA].[kontengruppe] = [DimKonto].[Kontengruppe Nummer] AND [FINSTA].[sammelkonto] = [DimKonto].[Konto Nummer] AND COALESCE([FINSTA].[Subaccount],-1) = COALESCE([DimKonto].[Konto Laufnummer],-1)) AS KontoKey 
	   ,(SELECT [GemeindeKey] FROM [dwh].[DimGemeinde] WHERE [DimGemeinde].[Gemeinde]=[FINSTA].[gemeinde]) AS GemeindeKey
      ,[Saldo]     
  FROM [FinstaData].[staging].[FINSTA]
GO
