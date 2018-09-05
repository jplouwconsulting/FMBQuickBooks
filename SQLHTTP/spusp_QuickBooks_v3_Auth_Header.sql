USE [FMBDataHub]
GO

/****** Object:  StoredProcedure [dbo].[usp_QuickBooks_v3_Auth_Header]    Script Date: 9/5/2018 3:50:41 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_QuickBooks_v3_Auth_Header]( @Profile nvarchar(100), @HttpSessionID uniqueidentifier)
AS
 
DECLARE @AuthorizationHeaderValue varchar(MAX)
SET @AuthorizationHeaderValue = 'Bearer ' + SQLHTTP.net.AuthParam(@Profile, 'BearerToken')
 
EXEC SQLHTTP.net.RequestHeaderSet @HTTPSessionID, 'Authorization', @AuthorizationHeaderValue

GO


