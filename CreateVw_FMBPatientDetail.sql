/****** Script for SelectTopNRows command from SSMS  ******/
SELECT p.[AccountNumber]
      ,p.[PTAccountNumber]
      ,p.[LastName]
      ,p.[FirstName]
      ,p.[MiddleInitial]
      ,p.[Gender]
      ,p.[DateOfBirth]
      ,p.[SSN]
      ,p.[PatientID]
	  ,pn.Number
	  ,pa.Street1
	  ,pa.Street2
	  ,pa.City
	  ,pa.State
	  ,pa.Zip
	  ,pn.number
      --,[AddedDate]
      --,[AddedBy]
      --,[ModifiedDate]
      --,[ModifiedBy]
      --,[ProviderCode]
      --,[TerminateFlag]
      --,[ReferringPhysician]
      --,[DateOfInjury]
      --,[DateOfSimilarIllness]
      --,[PriorAuthorizationNumber]
      --,[DLNumber]
      --,[DLState]
      --,[rfid]
      --,[gblID]
      --,[Generation]
  FROM [DEMO].[dbo].[tblPatient] p
LEFT OUTER JOIN dbo.tblPatientHist ph 
	ON p.PatientID = ph.PatientID 
LEFT OUTER JOIN dbo.tblPhone pn 
	ON ph.Phone1ID = pn.PhoneID
LEFT OUTER JOIN tblAddress pa
	ON ph.BillingAddressID	=	pa.AddressID
WHERE     (p.Status <> 0)
