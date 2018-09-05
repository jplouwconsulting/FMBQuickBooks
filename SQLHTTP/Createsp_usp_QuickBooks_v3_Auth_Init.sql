USE [FMBQuickBooks]
GO

/****** Object:  StoredProcedure [dbo].[usp_QuickBooks_v3_Auth_Init]    Script Date: 9/5/2018 3:54:27 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_QuickBooks_v3_Auth_Init](    @Profile nvarchar(100),
                    @ClientID varchar(50),
                    @ClientSecret varchar(50),
                    @RedirectURL varchar(100))
AS
 
SET NOCOUNT ON
 
DECLARE @UserBrowseToURL varchar(MAX)
DECLARE @QueryString nvarchar(MAX)
 
EXEC SQLHTTP.net.AuthParamSet @Profile = @Profile, @Name = 'ClientID', @Value = @ClientID
EXEC SQLHTTP.net.AuthParamSet @Profile = @Profile, @Name = 'ClientSecret', @Value = @ClientSecret
EXEC SQLHTTP.net.AuthParamSet @Profile = @Profile, @Name = 'RedirectURL', @Value = @RedirectURL
 
SET @UserBrowseToURL = 'https://appcenter.intuit.com/connect/oauth2'
 
EXEC SQLHTTP.net.QueryStringBuilder     @QueryString OUTPUT,
                    @Profile,
                    'response_type', 'code',
                    'client_id', @ClientID,
                    --'redirect_uri', @RedirectURL,
                    'scope', 'com.intuit.quickbooks.accounting',
                    'state', 'change-if-desired'
 
SET @QueryString = @QueryString 
                + '&redirect_uri=' COLLATE SQL_Latin1_General_CP1_CI_AS 
                + @RedirectURL
 
SET @UserBrowseToURL = @UserBrowseToURL + @QueryString
 
DECLARE @URL nvarchar(MAX)
DECLARE @Body nvarchar(MAX)
DECLARE @HTTPSessionID uniqueidentifier
DECLARE @Response nvarchar(MAX)
DECLARE @StatusCode int
DECLARE @StatusDescription nvarchar(MAX)
DECLARE @RedirectURLCode varchar(50)
DECLARE @RealmID varchar(50)
 
DECLARE @Timeout int
DECLARE @TimeoutReached bit = 0
 
SET @Timeout = 180 --three minutes wait
 
EXEC SQLHTTP.net.AuthListener @UserBrowseToURL = @UserBrowseToURL,
                @RedirectURL = @RedirectURL,
                @Timeout = @Timeout,
                @QueryString = @QueryString OUTPUT, 
                @TimeoutReached = @TimeoutReached OUTPUT
 
IF @TimeoutReached = 1
    BEGIN
        RAISERROR('Timeout reached waiting for browser authentication', 16, 1)
        RETURN
    END
 
SET @RedirectURLCode = SQLHTTP.net.MidText(@QueryString, 'code=', '&', 1)
SET @RealmID = SQLHTTP.net.Split(@QueryString, 'realmId=', 2)
 
EXEC SQLHTTP.net.AuthParamSet    @Profile = @Profile, 
                        @Name = 'RealmID', 
                        @value = @RealmID
 
SET @URL = 'https://oauth.platform.intuit.com/oauth2/v1/tokens/bearer'
 
EXEC SQLHTTP.net.FormDataBuilder        @Body OUTPUT,
                    @Profile,
                    'grant_type', 'authorization_code',
                    'code', @RedirectURLCode
 
SET @Body = @Body 
            + '&redirect_uri=' COLLATE SQL_Latin1_General_CP1_CI_AS
            + @RedirectURL
                            
EXEC SQLHTTP.net.HTTPSession @HTTPSessionID OUTPUT
 
EXEC SQLHTTP.net.BasicAuthHeader @HttpSessionID, @ClientID, @ClientSecret
 
EXEC SQLHTTP.net.HTTPRequest     @HttpSessionID,
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
 
        DECLARE @TokenCreatedDateTime nvarchar(100)
        SET @TokenCreatedDateTime = GetDate()
 
        EXEC SQLHTTP.net.AuthParamSet    @Profile = @Profile, 
                        @Name = 'TokenCreatedDateTime', 
                        @Value = @TokenCreatedDateTime
    END
GO


