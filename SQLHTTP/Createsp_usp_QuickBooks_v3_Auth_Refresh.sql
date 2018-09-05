USE [FMBQuickBooks]
GO

/****** Object:  StoredProcedure [dbo].[usp_QuickBooks_v3_Auth_Refresh]    Script Date: 9/5/2018 3:55:45 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_QuickBooks_v3_Auth_Refresh](    @Profile nvarchar(100))
AS
 
DECLARE @TokenCreatedDateTime nvarchar(100)
 
SET @TokenCreatedDateTime = SQLHTTP.net.AuthParam(@Profile, 'TokenCreatedDateTime')
 
IF DATEDIFF(hour, @TokenCreatedDateTime, GetDate()) < 12 RETURN --Too early for a token refresh
 
DECLARE @URL nvarchar(MAX)
DECLARE @ClientID varchar(50)
DECLARE @ClientSecret varchar(50)
DECLARE @HTTPSessionID uniqueidentifier
DECLARE @Body nvarchar(MAX)
DECLARE @Response nvarchar(MAX)
DECLARE @StatusCode int
DECLARE @StatusDescription nvarchar(MAX)
 
SET @URL = 'https://oauth.platform.intuit.com/oauth2/v1/tokens/bearer'
 
SET @ClientID = SQLHTTP.net.AuthParam( @Profile, 'ClientID')
SET @ClientSecret = SQLHTTP.net.AuthParam( @Profile, 'ClientSecret')
 
EXEC SQLHTTP.net.FormDataBuilder        @Body OUTPUT,
                    @Profile,
                    'grant_type', 'refresh_token',
                    'refresh_token', '#RefreshToken'
 
EXEC SQLHTTP.net.HTTPSession @HTTPSessionID OUTPUT
 
EXEC SQLHTTP.net.BasicAuthHeader @HttpSessionID, @ClientID, @ClientSecret
 
EXEC SQLHTTP.net.HTTPRequest    @HttpSessionID,
                @URL = @URL,
                @Method = 'POST',
                @Body = @Body,
                @StatusCode = @StatusCode OUTPUT,
                @StatusDescription = @StatusDescription OUTPUT,
                @Response = @Response OUTPUT
 
IF @StatusCode >= 400
    EXEC SQLHTTP.net.RaiseHttpError @StatusCode, @StatusDescription, @Response
ELSE
    BEGIN
        DECLARE @BearerToken varchar(MAX)
        DECLARE @RefreshToken varchar(MAX)
 
        SELECT @BearerToken = [value]
        FROM SQLHTTP.net.Json_To_NodeTable(@Response)
        WHERE [Name] = 'access_token'
 
        SELECT @RefreshToken = [value]
        FROM SQLHTTP.net.Json_To_NodeTable(@Response)
        WHERE [Name] = 'refresh_token'
 
        EXEC SQLHTTP.net.AuthParamSet    @Profile = @Profile, 
                        @Name = 'BearerToken', 
                        @value = @BearerToken
 
        EXEC SQLHTTP.net.AuthParamSet    @Profile = @Profile, 
                        @Name = 'RefreshToken', 
                        @Value = @RefreshToken
 
        SET @TokenCreatedDateTime = GetDate()
 
        EXEC SQLHTTP.net.AuthParamSet    @Profile = @Profile, 
                @Name = 'TokenCreatedDateTime', 
                @Value = @TokenCreatedDateTime
    END
GO


