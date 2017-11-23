USE [DGSDATA]
GO
/****** Object:  StoredProcedure [dbo].[_BI_Feed]    Script Date: 11/20/2017 6:05:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[_BI_Feed_Jeison] 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON;

INSERT INTO [G8Apps].[dbo].[_prueba_luis_temp_BI_WL]( 
[IdWager],
[IdWagerDetail],
IdAgent,
Agent,
[IdPlayer],
[Player],
[IdLineType],
LineTypeName,
[LoginName],
[WinAmount],
[RiskAmount],
[Result],
[Net],
GamePeriod,
LEAGUE,
[CompleteDescription],
[DetailDescription],
TEAM,
[IdGame],
[IdLeague],
[Period],
[Play],
WagerPlay,
FAV_DOG,
[IdSport],
[PlacedDate],
[SettledDate],
[Odds],
[Points],
[Score],	
--[ResultDetail],
[IP],
OpeningPoints,
OpeningMoneyLine,
ClosingPoints,
ClosingMoneyLine,
BeatLine
)

Select
[IdWager],
[IdWagerDetail],
IdAgent,
Agent,
[IdPlayer],
[Player],
[IdLineType],
Description as LineType,
[LoginName],
[WinAmount],
[RiskAmount],
[Result],
[Neto],
GamePeriod,
LEAGUE,
[CompleteDescription],
[DetailDescription],
TEAM,
[IdGame],
[IdLeague],
[Period],
[Play],
WagerPlay,
FAV_DOG,
[IdSport],
[PlacedDate],
[SettledDate],
[Odds],
[Points],
[Score],	
--[ResultDetail],
[IP],
OpeningPoints,
OpeningMoneyLine,
ClosingPoints,
ClosingMoneyLine,
BeatLine = (
	    CASE Play 
		WHEN 0 THEN (CASE WHEN Points = ClosingPoints THEN (CASE WHEN Odds > ClosingMoneyLine THEN 'beat' ELSE 'NO beat' END)
		                  WHEN Points > ClosingPoints THEN 'beat' 
						  ELSE 'NO beat'
						  END)

        WHEN 1 THEN (CASE WHEN Points = ClosingPoints THEN (CASE WHEN Odds > ClosingMoneyLine THEN 'beat' ELSE 'NO beat' END)
		                  WHEN Points > ClosingPoints THEN 'beat'
						  ELSE 'NO beat'
						  END)

        WHEN 2 THEN (CASE WHEN Points = ClosingPoints THEN (CASE WHEN Odds > ClosingMoneyLine THEN 'beat' ELSE 'NO beat' END)
		                  WHEN Points < ClosingPoints THEN 'beat' 
		                  ELSE 'NO beat' END)

        WHEN 3 THEN (CASE WHEN Points = ClosingPoints THEN (CASE WHEN Odds > ClosingMoneyLine THEN 'beat' ELSE 'NO beat' END)
						  WHEN Points > ClosingPoints THEN 'beat' 
		                  ELSE 'NO beat' END) 

        WHEN 4 THEN (CASE WHEN Odds > ClosingMoneyLine THEN 'beat' ELSE 'NO beat' END) 
        WHEN 5 THEN (CASE WHEN Odds > ClosingMoneyLine THEN 'beat' ELSE 'NO beat' END) 
        WHEN 6 THEN (CASE WHEN Odds > ClosingMoneyLine THEN 'beat' ELSE 'NO beat' END)
		ELSE 'Nothing' 
		END)
 
FROM (
		 
					SELECT 
								
					X.[IdWager]	,
					X.[IdWagerDetail],
					A.IdAgent,
					A.Agent	,			
					X.[IdPlayer]	,
					X.[Player]	,
					X.IdLineType,
					LT.Description,			
					X.[LoginName]	,			
					X.[WinAmount]	,
					X.[RiskAmount]	,
					X.[Result]		,	
					X.[Neto]		,
					GamePeriod = (CASE X.[Period] 	
							WHEN 0	THEN 'GAME'
							WHEN 1	THEN 'FIRST HALF'
							WHEN 2	THEN 'SECOND HALF'
							WHEN 3	THEN 'FIRST QUARTER'
							WHEN 4	THEN 'SECOND QUARTER'
							WHEN 5	THEN 'THIRD  QUARTER'
							WHEN 6	THEN 'FOURTH QUARTER'
							WHEN 10	THEN 'OVERTIME'
						END
					),	
					L.Description as LEAGUE,
					X.[CompleteDescription],
					X.[DetailDescription]	,
TEAM = (
	CASE X.[IdSport] WHEN 'SOC' THEN
		CASE
			WHEN Play IN (0,4) Then (SELECT HomeTeam FROM GAME WHERE IdGame = X.[IdGame]) 
			WHEN Play IN (1,5) Then (SELECT VisitorTeam FROM GAME WHERE IdGame = X.[IdGame])
			WHEN Play IN (2,3,6) Then (SELECT HomeTeam + ' vs ' + VisitorTeam FROM GAME WHERE IdGame = X.[IdGame])
			ELSE ''
		END
	ELSE
		CASE 
			WHEN Play IN (0,4) Then (SELECT VisitorTeam FROM GAME WHERE IdGame = X.[IdGame]) 
			WHEN Play IN (1,5) Then (SELECT HomeTeam FROM GAME WHERE IdGame = X.[IdGame])
			WHEN Play IN (2,3) Then (SELECT VisitorTeam + ' vs ' + HomeTeam FROM GAME WHERE IdGame = X.[IdGame])
			ELSE '' 
		END 
	END	
),
					X.[IdGame],
					X.[IdLeague],
					X.[Period],
					X.[Play],
					WagerPlay = (
							  CASE X.[Play]  
							  WHEN 0 THEN 'VisitorSpread' 
							  WHEN 1 THEN 'HomeSpread' 
							  WHEN 2 THEN 'TotalOver' 
							  WHEN 3 THEN 'TotalUnder'
							  WHEN 4 THEN 'VisitorMoneylines' 
							  WHEN 5 THEN 'HomeMoneylines' 
							  WHEN 6 THEN 'Draw' 
							  ELSE 'TNT' END),
					FAV_DOG	= (
		CASE X.[IdSport] WHEN 'SOC' THEN							
							CASE X.[Play] 
							  WHEN 0 THEN CASE WHEN Points > 0 THEN 'HomeSpreadDOG' ELSE 'HomeSpreadFAV' END
							  WHEN 1 THEN CASE WHEN Points > 0 THEN 'VisSpreadDOG' ELSE 'VisSpreadFAV' END
							  WHEN 2 THEN 'TotalOver' 
							  WHEN 3 THEN 'TotalUnder'
							  WHEN 4 THEN CASE WHEN Odds > 0 THEN 'HomeDOGML' ELSE 'HomeFAVML' END 
							  WHEN 5 THEN CASE WHEN Odds > 0 THEN 'VisDOGML' ELSE 'VisFAVML' END
							  WHEN 6 THEN 'Draw'
							  ELSE ''
							END						  
		ELSE
							CASE X.[Play] 
							  WHEN 0 THEN CASE WHEN Points > 0 THEN 'VisSpreadDOG' ELSE 'VisSpreadFAV' END
							  WHEN 1 THEN CASE WHEN Points > 0 THEN 'HomeSpreadDOG' ELSE 'HomeSpreadFAV' END
							  WHEN 2 THEN 'TotalOver' 
							  WHEN 3 THEN 'TotalUnder'
							  WHEN 4 THEN CASE WHEN Odds > 0 THEN 'VisDOGML' ELSE 'VisFAVML' END 
							  WHEN 5 THEN CASE WHEN Odds > 0 THEN 'HomeDOGML' ELSE 'HomeFAVML' END
							  ELSE ''
							END
		END),
					
					X.[IdSport]	,					
					X.[SettledDate],			
					X.[PlacedDate],	
					X.[Odds],
					X.[Points],
					X.[Score],	
					--[ResultDetail],	
					X.[IP],
					
					OpeningPoints = (CASE 
					   WHEN X.IdSport = 'NHL' 
						 THEN 
					  CASE 
					  WHEN Play = 0 THEN OL.VisitorSpecial 
					  WHEN Play = 1 THEN OL.HomeSpecial 
					  WHEN Play = 2 THEN OL.TotalOver 
					  WHEN Play = 3 THEN OL.TotalUnder 
					  WHEN Play = 4 THEN 0 
					  WHEN Play = 5 THEN 0 
					  WHEN Play = 6 THEN 0 
					  ELSE - 999999 
					  END 
					  ELSE 
					  CASE 
					  WHEN Play = 0 THEN OL.VisitorSpread 
					  WHEN Play = 1 THEN OL.HomeSpread 
					  WHEN Play = 2 THEN OL.TotalOver 
					  WHEN Play = 3 THEN OL.TotalUnder 
					  WHEN Play = 4 THEN 0
					  WHEN Play = 5 THEN 0
					  WHEN Play = 6 THEN 0 
					  ELSE - 999999 
					  END 
					  END), 					  					  					  
					 OpeningMoneyLine = (CASE 
						WHEN X.IdSport = 'NHL' 
					  THEN 
					   CASE 
						WHEN Play = 0 THEN OL.VisitorSpecialOdds 
						WHEN Play = 1 THEN OL.HomeSpecialOdds 
						WHEN Play = 2 THEN OL.OverOdds 
						WHEN Play = 3 THEN OL.UnderOdds 
						WHEN Play = 4 THEN OL.VisitorOdds
						WHEN Play = 5 THEN OL.HomeOdds 
						WHEN Play = 6 THEN OL.VisitorSpecialOdds 
						ELSE - 999999 
						END 
					   ELSE CASE
						WHEN Play = 0 THEN OL.VisitorSpreadOdds 
						WHEN Play = 1 THEN OL.HomeSpreadOdds 
						WHEN Play = 2 THEN OL.OverOdds 
						WHEN Play = 3 THEN OL.UnderOdds 
						WHEN Play = 4 THEN OL.VisitorOdds 
						WHEN Play = 5 THEN OL.HomeOdds 
						WHEN Play = 6 THEN OL.VisitorSpecialOdds
						   ELSE - 999999 
						END 
						END),
											
					ClosingPoints = (CASE 
					   WHEN X.IdSport = 'NHL' 
						 THEN 
					  CASE 
					  WHEN Play = 0 THEN CL.VisitorSpecial 
					  WHEN Play = 1 THEN CL.HomeSpecial 
					  WHEN Play = 2 THEN CL.TotalOver 
					  WHEN Play = 3 THEN CL.TotalUnder 
					  WHEN Play = 4 THEN 0 
					  WHEN Play = 5 THEN 0 
					  WHEN Play = 6 THEN 0 
					  ELSE - 999999 
					  END 
					  ELSE 
					  CASE 
					  WHEN Play = 0 THEN CL.VisitorSpread 
					  WHEN Play = 1 THEN CL.HomeSpread 
					  WHEN Play = 2 THEN CL.TotalOver 
					  WHEN Play = 3 THEN CL.TotalUnder 
					  WHEN Play = 4 THEN 0
					  WHEN Play = 5 THEN 0
					  WHEN Play = 6 THEN 0 
					  ELSE - 999999 
					  END 
					  END), 					  					  					  
					 ClosingMoneyLine = (CASE 
						WHEN X.IdSport = 'NHL' 
					  THEN 
					   CASE 
						WHEN Play = 0 THEN CL.VisitorSpecialOdds 
						WHEN Play = 1 THEN CL.HomeSpecialOdds 
						WHEN Play = 2 THEN CL.OverOdds 
						WHEN Play = 3 THEN CL.UnderOdds 
						WHEN Play = 4 THEN CL.VisitorOdds
						WHEN Play = 5 THEN CL.HomeOdds 
						WHEN Play = 6 THEN CL.VisitorSpecialOdds 
						ELSE - 999999 
						END 
					   ELSE CASE
						WHEN Play = 0 THEN CL.VisitorSpreadOdds 
						WHEN Play = 1 THEN CL.HomeSpreadOdds 
						WHEN Play = 2 THEN CL.OverOdds 
						WHEN Play = 3 THEN CL.UnderOdds 
						WHEN Play = 4 THEN CL.VisitorOdds 
						WHEN Play = 5 THEN CL.HomeOdds 
						WHEN Play = 6 THEN CL.VisitorSpecialOdds
						   ELSE - 999999 
						END 
						END)
										
					FROM @Betsidentifier X
					INNER JOIN PLAYER P 
						ON P.IdPlayer = X.[IdPlayer]
					INNER JOIN AGENT A 
						ON A.IdAgent = P.IdAgent
					INNER JOIN LEAGUE L 
						ON L.IdLeague = X.[IdLeague]
					INNER JOIN LINETYPE LT
						ON LT.IdLineType = X.IdLineType	
					LEFT JOIN _web_ClosingLines CL 
						ON CL.idgame = X.[IdGame] and CL.idLinetype = X.[IdLineType]--(SELECT IdLineTypeIn FROM LINETYPELINKS WHERE IdLineTypeOut = X.[IdLineType] AND IdSport = X.IdSport)--
					LEFT JOIN _web_OpeningLines OL 
						ON OL.idgame = X.[IdGame] and OL.idLinetype = X.[IdLineType]--(SELECT IdLineTypeIn FROM LINETYPELINKS WHERE IdLineTypeOut = X.[IdLineType] AND IdSport = X.IdSport)--
						
						
)							 
AS summary
ORDER BY IdWager ASC


END