USE [FMBQuickBooks]
GO

/****** Object:  StoredProcedure [dbo].[spPatientDatatoTransfertoQB]    Script Date: 8/28/2018 10:36:47 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		JPLouw Consulting LTD
-- Create date: 28 Aug 2018 @ 16:16
-- Description:	Used to insert missing data from Patient data ready to be transfered to QuickBooks
-- =============================================
CREATE PROCEDURE [dbo].[spPatientDatatoTransfertoQB]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	MERGE [FMBDataHub].[dbo].[tblPatientAudit] AS TARGET
	USING [DEMO].[dbo].[tblPatient] AS SOURCE
		ON (TARGET.[PatientID] = SOURCE.[PatientID])
	WHEN NOT MATCHED BY TARGET THEN 
		INSERT (PatientID) VALUES (SOURCE.PatientID)
	OUTPUT $action,
		INSERTED.PatientID as SOURCEPatientID;
END
GO


