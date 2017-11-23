USE [DGSDATA]
GO
/****** Object:  StoredProcedure [dbo].[_BI_Feed_Mood_wo_Params_v2]    Script Date: 11/20/2017 5:48:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[_BI_Feed_Mood_wo_Params_v2] 
	-- Add the parameters for the stored procedure here
		
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	declare @Day1 datetime
declare @Dat2 datetime 
declare @Today datetime
declare @Yesterday datetime
declare @Sport Varchar(5)
declare		@League Varchar(50)
declare		@Player Varchar(15)

set @Day1 =CAST(DATEADD(day,0, GETDATE()) AS DATE) 


set @Today= DATEADD(ms, -3, CONVERT(DATETIME,CAST(@day1 AS DATE)) )
set @Yesterday = CAST(DATEADD(day,-1, @Day1) AS DATE) 

set @Sport = ''
set @League = ''
set @Player = ''



DECLARE @Betsidentifier TABLE 
(
	[TicketNumber]			[int] NOT NULL,
	[IdWager]				[int] NOT NULL,
	[PhoneLine]				[smallint] NOT NULL,
	[IdPlayer]				[int] NULL,
	[Player]				[varchar](10) NOT NULL,
	[IdLineType]			[int] NULL,
	[LoginName]				[varchar](15) NULL, --NOT NULL
	[PlacedDate]			[datetime] NOT NULL,
	[SettledDate]			[datetime] NULL,
	[CompleteDescription]	[varchar](100) NOT NULL,
	[RiskAmount]			[money] NOT NULL,
	[WinAmount]				[money] NOT NULL,
	[DetailDescription]		[varchar](1000) NOT NULL,
	[IdGame]				[int] NULL,
	[IdLeague]				[int] NULL,
	[Period]				[tinyint] NULL,
	[Play]					[int] NULL,
	[Points]				[real] NULL,
	[Odds]					[int] NULL,
	[IdWagerDetail]			[int] NOT NULL,
	[IdSport]				[varchar](5) NULL,
	[Score]					[varchar](12) NULL,
	[Result]				[varchar](15) NULL,
	[ResultDetail]			[varchar](15) NULL,
	[Neto]					[money],
	[IP]					[varchar](100) NOT NULL
)

INSERT INTO  [G8Apps].[dbo].[_prueba_luis_temp_BI_WL]
	EXEC [dbo].[_BI_Report_Wager_Listing]
		74, -- @LogIdUser			Int,
		'', -- @Office				Varchar(30),
		'', -- @Group				VarChar(30),
		'', -- @Book				Varchar(30),
		'', -- @LineType			VarChar(20), 
		'', -- @AgentFrom			Varchar(15),
		'', -- @AgentTo				Varchar(15),
		'VAW', -- @Distributor			Varchar(15),
		@Player, -- @Player				Varchar(15),
		'', -- @User				Varchar(30),
	--	'', -- @Station				VarChar(30),
	--	'',	-- @Ip					Varchar(20),
	--	 0,	-- @SameIP				Integer [0 = disable],
	--	 0,	-- @HigherThan			Money  [ WinAmount >= ],
		'',	-- @WagerTypes			Varchar(100), --	Straight,Parlay,Teaser,Reverse,Card
		@Sport,	-- @Sport				Varchar(5),
		@League,	-- @League				Varchar(50), 
		 0,	-- @AgentLine			Integer [ GradedWagerDetail.LineFromAgent = 1 ],
		 0,	-- @FreePlay     		Integer [ GradedWagerHeader.FreePlay = 1 ],
		 0,	-- @OpenPlay			Integer [ GradedWagerHeader.OpenPlay = 1 ],
		 0,	-- @PastPost			Integer [GradedWagerHeader.SettledDate <= GradedWagerHeader.PlacedDate],
		 1, -- @WagerStatus			Integer,	/*0:Both	1:Graded  	2:UnGraded	*/
		 0,	-- @PlayerType			Integer,	/*0:Both	1:Normal	2:Master	*/
		-- 1, -- @AllPlacedDate		Integer [ 1= ALL ],
	--	 '',-- @StartPlacedDate		VarChar(30),	/*if null then lifetime*/
	--	 '',-- @EndPlacedDate		VarChar(30),
	--	 0, -- @AllSettledDate		Integer [ 1= ALL ],
		 @yesterday,	-- @StartSettledDate	VarChar(30),	/*if null then lifetime*/
		 @today,	-- @EndSettledDate		VarChar(30),
		 0	-- @WithDetailsIn		Integer,  /*0: None, 1: Same Game, 2: Related Games*/
--		 0,	-- @WagerPlaced			Integer,	/*0:Both	1:Phone		2:Internet	*/
--		 0	-- @Orderby				Integer [0 = Player, else = Ticket]



		 
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
						
				where (X.[IdWager]>678395) and (X.[IdWager] NOT IN (select IdWager from [G8Apps].[dbo].[_prueba_luis_temp_BI_WL] ))  
)							 
AS summary
ORDER BY IdWager ASC



END
