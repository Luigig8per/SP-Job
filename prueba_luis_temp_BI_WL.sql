USE [G8Apps]
GO
/****** Object:  Table [dbo].[_prueba_luis_temp_BI_WL]    Script Date: 11/21/2017 9:10:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
START
CREATE TABLE [dbo].[_prueba_luis_temp_BI_WL](
	[Id_BI] [bigint] NULL,
	[IdWager] [int] NOT NULL,
	[IdWagerDetail] [int] NOT NULL,
	[IdAgent] [int] NULL,
	[Agent] [varchar](50) NOT NULL,
	[IdPlayer] [int] NULL,
	[Player] [varchar](50) NOT NULL,
	[IdLineType] [int] NOT NULL,
	[LineTypeName] [varchar](100) NOT NULL,
	[LoginName] [varchar](50) NOT NULL,
	[WinAmount] [real] NOT NULL,
	[RiskAmount] [real] NOT NULL,
	[Result] [varchar](20) NOT NULL,
	[Net] [real] NULL,
	[GamePeriod] [varchar](20) NULL,
	[League] [varchar](50) NOT NULL,
	[CompleteDescription] [varchar](1000) NOT NULL,
	[DetailDescription] [varchar](1000) NOT NULL,
	[Team] [varchar](1000) NULL,
	[IdGame] [int] NOT NULL,
	[IdLeague] [int] NOT NULL,
	[Period] [int] NULL,
	[FAV_DOG] [varchar](50) NULL,
	[Play] [int] NOT NULL,
	[WagerPlay] [varchar](20) NOT NULL,
	[IdSport] [varchar](5) NOT NULL,
	[SettledDate] [datetime] NOT NULL,
	[PlacedDate] [datetime] NOT NULL,
	[Odds] [int] NOT NULL,
	[Points] [real] NOT NULL,
	[Score] [varchar](20) NOT NULL,
	[IP] [varchar](50) NOT NULL,
	[OpeningPoints] [real] NULL,
	[OpeningOdds] [int] NULL,
	[ClosingPoints] [real] NULL,
	[ClosingOdds] [int] NULL,
	[BeatLine] [varchar](10) NOT NULL,
	[OpeningMoneyLine] [int] NULL,
	[ClosingMoneyLine] [int] NULL
) ON [PRIMARY]
COMMIT,
GO
SET ANSI_PADDING OFF
GO
