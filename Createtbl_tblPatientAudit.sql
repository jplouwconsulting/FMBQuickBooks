USE [FMBQuickBooks]
GO

/****** Object:  Table [dbo].[tblPatientAudit]    Script Date: 8/28/2018 10:35:53 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tblPatientAudit](
	[QBClientAuditID] [int] IDENTITY(1,1) NOT NULL,
	[PatientID] [int] NOT NULL,
	[QBID] [int] NULL,
	[LastUpdatedDate] [smalldatetime] NULL,
	[CreatedDate] [smalldatetime] NOT NULL,
 CONSTRAINT [PK_tblPatientAudit] PRIMARY KEY CLUSTERED 
(
	[QBClientAuditID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[tblPatientAudit] ADD  CONSTRAINT [DF_tblPatientAudit_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO


