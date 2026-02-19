Use Hosipatel_System

/* Data Quality checks */ 

/* 
•	Duplicate patient records (same name, DOB, phone)
•	Orphaned appointments (appointments with non-existent patients or doctors)
•	Invalid phone numbers (incorrect format or length)
•	Missing critical data (NULL values in important fields)
•	Expired medications in inventory
•	Bills without corresponding appointments */  ---- Not done srtill need to work on more 

Alter procedure USP_dataqualitychecks
As 
BEGIN 
SET NOCOUNT ON 

-------------- Create temporary table for quality check results ------------------

Create table #qulaitychecks 
(
issueid int identity(1,1), 
Checkcategory Nvarchar(100), 
issuedescription Nvarchar(100), 
issuecount Int, 
Severity nvarchar(100), 
Sampledata Varchar(100)
) ;

----Check 1 ----------Duplicate checks--------- 

Insert into #qulaitychecks (Checkcategory,issuedescription,issuecount,Severity,Sampledata) 
Select 
'Duplicates' as Checkcategory, 
'Duplicate patient record' as issuedescription, 
Count(*) as issuecount, 
'High' as severity, 
STRING_AGG(CAST(Patientid as Nvarchar(10)),', ') as Sampledata 
from (SELECT PatientID, FirstName, LastName, phone
        FROM Patients
        WHERE FirstName IS NOT NULL AND LastName IS NOT NULL
        GROUP BY Patientid,FirstName, LastName,Phone
        HAVING COUNT(*) > 1
    ) AS Duplicates
	
HAVING COUNT(*) > 0;

----- Orphaned Appointments (Invalid PatientID) --------------- 

Insert into #qulaitychecks (Checkcategory,issuedescription,issuecount,Severity,Sampledata) 
SELECT 
'Orphaned RECORD' AS Checkcategory,
'Appointments with non-existent patients' as issuedescription,
Count(*) as Issuecount,
'Critical' as Severity, 
STRING_AGG(CAST(A.AppointmentID as Nvarchar(10)),', ') as Sampledata 
From Appointments A Left Join Patients P 
on A.PatientID = p.PatientID
Where P.patientid is NULL
having Count(*)>0 

---------------- ----- Orphaned Appointments (Invalid Doctorid) ---------------  

Insert into #qulaitychecks (Checkcategory,issuedescription,issuecount,Severity,Sampledata) 
SELECT 
'Orphaned RECORD' AS Checkcategory,
'Appointments with non-existent doctors' as issuedescription,
Count(*) as Issuecount,
'Critical' as Severity, 
STRING_AGG(CAST(A.AppointmentID as Nvarchar(10)),', ') as Sampledata 
From Appointments A Left Join Doctors D
on A.DoctorID = D.DoctorID
Where D.DoctorID is NULL
having Count(*)>0 

------- Missing important patient details -------------------------- 

INSERT INTO #qulaitychecks (CheckCategory, IssueDescription, IssueCount, Severity, SampleData)
    SELECT 
        'Missing Data' AS CheckCategory,
        'Patients with missing critical information (Name, DOB, or Phone)' AS IssueDescription,
        COUNT(*) AS IssueCount,
        'High' AS Severity,
        STRING_AGG(CAST(PatientID AS NVARCHAR(10)), ', ') AS SampleData
    FROM Patients
    WHERE FirstName IS NULL OR LastName IS NULL OR DateOfBirth IS NULL OR Phone IS NULL
    HAVING COUNT(*) > 0;

--------------- invalid contact number --------------------

INSERT INTO #qulaitychecks (CheckCategory, IssueDescription, IssueCount, Severity, SampleData)
    SELECT 
        'Invalid contact number' AS CheckCategory,
        'Patients with invalid phone numbers (incorrect length)' AS IssueDescription,
        COUNT(*) AS IssueCount,
        'High' AS Severity,
        STRING_AGG(CAST(PatientID AS NVARCHAR(10)), ', ') AS SampleData
    FROM Patients
    WHERE Phone IS NOT NULL AND LEN(Phone) NOT IN (10, 12, 14)
    HAVING COUNT(*) > 0;

-------- expire medications on inventory ------------ 

INSERT INTO #qulaitychecks (CheckCategory, IssueDescription, IssueCount, Severity, SampleData)
    SELECT 
        'Business Rule Violation' AS CheckCategory,
        'Expired medications still in active inventory' AS IssueDescription,
        COUNT(*) AS IssueCount,
        'High' AS Severity,
        STRING_AGG(CAST(inventoryID AS VARCHAR(10)), ', ') AS SampleData
    FROM [dbo].[MedicationInventory]
    WHERE ExpireDate < GETDATE() AND IsActive = 1
    HAVING COUNT(*) > 0;

--------Bills without Appointments --------------
INSERT INTO #qulaitychecks (CheckCategory, IssueDescription, IssueCount, Severity, SampleData)
    SELECT 
        'Referential Integrity' AS CheckCategory,
        'Bills linked to non-existent appointments' AS IssueDescription,
        COUNT(*) AS IssueCount,
        'HIGH' AS Severity,
        STRING_AGG(CAST(BillID AS NVARCHAR(10)), ', ') AS SampleData
    FROM Bills b
    LEFT JOIN Appointments a ON b.AppointmentID = a.AppointmentID
    WHERE b.AppointmentID IS NOT NULL AND a.AppointmentID IS NULL
    HAVING COUNT(*) > 0;
 
------- Display Summary

    SELECT 
        IssueID,
        CheckCategory,
        IssueDescription,
        IssueCount,
        Severity,
        SampleData
    FROM #qulaitychecks
    ORDER BY 
        CASE Severity
            WHEN 'Critical' THEN 1
            WHEN 'High' THEN 2
            WHEN 'Medium' THEN 3
            ELSE 4
        END,
        IssueCount DESC;
    
    -- Summary Statistics
    SELECT 
        COUNT(*) AS TotalIssueTypes,
        SUM(IssueCount) AS TotalIssues,
        SUM(CASE WHEN Severity = 'Critical' THEN IssueCount ELSE 0 END) AS CriticalIssues,
        SUM(CASE WHEN Severity = 'High' THEN IssueCount ELSE 0 END) AS HighIssues,
        SUM(CASE WHEN Severity = 'Medium' THEN IssueCount ELSE 0 END) AS MediumIssues
    FROM #qulaitychecks;
    
    -- Cleanup
    DROP TABLE #qulaitychecks;
    
    PRINT 'Data Quality Check Completed!';
END

GO
Exec USP_dataqualitychecks

/* Create a complete patient management system with stored procedures for patient registration 
- Patient id generation automatically */ 

Select top 1 * from patients 

CREATE OR ALTER PROCEDURE USP_patientinformation
(
    @patientfirstname VARCHAR(100),
    @patientlastname VARCHAR(100),
    @gender VARCHAR(10),
    @dateofbirth DATE,
    @phone VARCHAR(15),
    @providerid int,
    @city VARCHAR(100),
    @Newpatientid INT OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validation
        IF @patientfirstname IS NULL
            RAISERROR('First name is required',16,1);

        IF @patientlastname IS NULL
            RAISERROR('Last name is required',16,1);

        IF @dateofbirth >= GETDATE()
            RAISERROR('Date of birth cannot be in future',16,1);

        IF @gender NOT IN ('M','F','Other')
            RAISERROR('Invalid gender value',16,1);

        -- Duplicate Check
        IF EXISTS (
            SELECT 1
            FROM Patients
            WHERE FirstName = @patientfirstname
              AND LastName = @patientlastname
              AND DateOfBirth = @dateofbirth
        )
            RAISERROR('Duplicate patient record found',16,1);

        -- Insert
		DECLARE @NextPatientID INT;

-- Generate next ID manually
SELECT @NextPatientID = ISNULL(MAX(PatientID), 0) + 1
FROM Patients WITH (UPDLOCK, HOLDLOCK);

INSERT INTO Patients
(
    PatientID,
    FirstName,
    LastName,
    Gender,
    DateOfBirth,
    Phone,
    City,
    providerid
)
VALUES
(
    @NextPatientID,
    @patientfirstname,
    @patientlastname,
    @gender,
    @dateofbirth,
    @phone,
    @city,
    @providerid
);

SET @NewPatientID = @NextPatientID;


        COMMIT TRANSACTION;

        PRINT 'Patient registered successfully';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;  -- Better than RAISERROR in modern SQL Server
    END CATCH
END


DECLARE @NewPatientID INT;

EXEC USP_patientinformation
    @patientfirstname = 'vamsi',
    @patientlastname = 'keishna',
    @gender = 'M',
    @dateofbirth = '1980-04-15',
    @phone = '25623478952',
    @Providerid = 1,
    @city = 'New York',
    @Newpatientid = @NewPatientID OUTPUT;

SELECT @NewPatientID AS NewPatientID;


Select *from Patients
    












